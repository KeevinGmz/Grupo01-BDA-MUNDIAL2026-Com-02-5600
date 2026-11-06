/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Entrega 6. Importación de las plantillas (convocados) de las
          selecciones mediante scraping de Wikipedia: descarga la página con
          HTTP desde T-SQL, recorre el HTML para extraer cada jugador (dorsal,
          posición, nombre, fecha de nacimiento y club) y aplica el upsert de
          clubes, jugadores y convocatorias con los SP de la Entrega 5.
===================================================================== */
USE Mundial2026;
GO

/*
   Fuente: https://en.wikipedia.org/wiki/2026_FIFA_World_Cup_squads
   La información de las plantillas no se publica como archivo descargable
   (CSV/XML/JSON): está en tablas HTML, una por selección. Técnica de scraping:

   1. Descarga: soporte.usp_Http_Obtener hace un GET con MSXML2.ServerXMLHTTP
      (procedimientos sp_OA*) y devuelve el HTML completo (unos 3 MB).
      También se puede importar una copia guardada de la página (@archivo).
   2. Recorrido del HTML con CHARINDEX/SUBSTRING:
      - cada selección comienza con un encabezado <h3 id="...">Nombre</h3>;
      - cada jugador es una fila <tr class="nat-fs-player"> con 7 celdas:
        dorsal | posición | jugador (<th data-sort-value="Apellido, Nombre">) |
        fecha de nacimiento (<span class="bday">AAAA-MM-DD</span>) | partidos |
        goles | club (bandera "Flag_of_<país>.svg" + nombre del club).
      - el texto de cada celda se obtiene con soporte.fn_HtmlATexto, que
        descarta etiquetas, bloques ocultos y referencias.
   3. Validación y upsert por fila, y registro de la convocatoria por selección.

   Identificación de los jugadores: la fuente no publica documentos, por lo que
   se usa tipo_doc = 'EXT' con un identificador externo estable:
   código FIFA + fecha de nacimiento + 8 caracteres del hash SHA-256 del nombre
   (por ejemplo MEX-20000517-1A2B3C4D). Volver a importar la misma página
   reconoce a cada jugador y no genera duplicados.
*/

-- Devuelve el apellido de un nombre visible ("Matěj Kovář") usando la clave
-- de orden de Wikipedia ("Kovar, Matej"): el apellido tiene tantas palabras
-- como la parte anterior a la coma. Sin coma, el apellido es la última palabra.
CREATE OR ALTER FUNCTION soporte.fn_ApellidoDesdeClave
(
    @nombre_visible NVARCHAR(200),
    @clave_orden NVARCHAR(200)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @v_nombre NVARCHAR(200) = soporte.fn_Limpiar(@nombre_visible);
    DECLARE @v_clave NVARCHAR(200) = soporte.fn_Limpiar(@clave_orden);
    DECLARE @v_palabras INT = 1;
    DECLARE @v_pos INT;
    DECLARE @v_resto INT;

    IF @v_nombre IS NULL
        RETURN NULL;

    IF CHARINDEX(N' ', @v_nombre) = 0
        RETURN @v_nombre;

    IF @v_clave IS NOT NULL AND CHARINDEX(N',', @v_clave) > 1
    BEGIN
        SET @v_clave = LTRIM(RTRIM(LEFT(@v_clave, CHARINDEX(N',', @v_clave) - 1)));
        SET @v_palabras = LEN(@v_clave) - LEN(REPLACE(@v_clave, N' ', N'')) + 1;
    END

    -- Posición del espacio que separa las últimas @v_palabras palabras.
    SET @v_pos = LEN(@v_nombre) + 1;
    SET @v_resto = @v_palabras;
    WHILE @v_resto > 0 AND @v_pos > 1
    BEGIN
        SET @v_pos = @v_pos - 1;
        WHILE @v_pos > 0 AND SUBSTRING(@v_nombre, @v_pos, 1) <> N' '
            SET @v_pos = @v_pos - 1;
        SET @v_resto = @v_resto - 1;
    END

    -- Si el apellido ocuparía el nombre completo, se deja una palabra de nombre.
    IF @v_pos <= 1
        SET @v_pos = CHARINDEX(N' ', @v_nombre);

    RETURN LTRIM(RTRIM(SUBSTRING(@v_nombre, @v_pos + 1, 200)));
END;
GO

CREATE OR ALTER PROCEDURE soporte.usp_Importar_PlantillasWikipedia
    @url NVARCHAR(260) = N'https://en.wikipedia.org/wiki/2026_FIFA_World_Cup_squads',
    @archivo NVARCHAR(260) = NULL,          -- opcional: copia guardada de la página (.html)
    @id_importacion INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @c_sp NVARCHAR(60) = N'soporte.usp_Importar_PlantillasWikipedia';
    DECLARE @c_fuente NVARCHAR(60) = N'Wikipedia (scraping)';
    DECLARE @c_marca_fila NVARCHAR(40) = N'<tr class="nat-fs-player">';
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_mensaje NVARCHAR(2048);
    DECLARE @v_origen NVARCHAR(260);
    DECLARE @v_html NVARCHAR(MAX);
    DECLARE @v_estado INT;
    DECLARE @v_leidas INT = 0;

    IF @archivo IS NOT NULL
        SET @v_errores += soporte.fn_ValidarRutaArchivo(@archivo, N'.html,.htm');
    ELSE IF NULLIF(LTRIM(RTRIM(@url)), N'') IS NULL OR @url NOT LIKE N'https://%.wikipedia.org/wiki/%'
        SET @v_errores += N'url obligatoria y debe ser una pagina de wikipedia.org; ';
    IF @@TRANCOUNT > 0
        SET @v_errores += N'no puede ejecutarse dentro de una transaccion; ';

    IF @v_errores <> N''
    BEGIN
        SET @v_mensaje = LEFT(CONCAT(@c_sp, N': ', @v_errores), 2048);
        THROW 50001, @v_mensaje, 1;
    END

    SET @v_origen = ISNULL(@archivo, @url);

    EXEC soporte.usp_Importacion_Iniciar
        @fuente = @c_fuente, @archivo = @v_origen, @formato = 'HTML',
        @id_importacion = @id_importacion OUTPUT;

    ---------------------------------------------------------------------------
    -- 1. Descarga (o lectura) de la página y extracción de las filas
    ---------------------------------------------------------------------------
    BEGIN TRY
        IF @archivo IS NOT NULL
            EXEC soporte.usp_Archivo_Leer @archivo = @archivo, @contenido = @v_html OUTPUT;
        ELSE
            EXEC soporte.usp_Http_Obtener @url = @url, @contenido = @v_html OUTPUT, @estado_http = @v_estado OUTPUT;

        IF CHARINDEX(@c_marca_fila, @v_html) = 0
            THROW 50002, N'la pagina no contiene tablas de plantillas (filas <tr class="nat-fs-player">)', 1;

        DELETE FROM soporte.stg_jugador_html;

        DECLARE @v_pos INT = 1;
        DECLARE @v_ini INT;
        DECLARE @v_fin INT;
        DECLARE @v_sig_h3 INT = CHARINDEX(N'<h3', @v_html);
        DECLARE @v_fin_h3 INT;
        DECLARE @v_equipo NVARCHAR(150);
        DECLARE @v_fila_html NVARCHAR(MAX);
        DECLARE @v_nro INT = 0;
        DECLARE @v_celdas TABLE (orden INT PRIMARY KEY, atributos NVARCHAR(MAX), contenido NVARCHAR(MAX));
        DECLARE @v_p INT;
        DECLARE @v_td INT;
        DECLARE @v_th INT;
        DECLARE @v_ini_celda INT;
        DECLARE @v_ini_cont INT;
        DECLARE @v_fin_celda INT;
        DECLARE @v_orden INT;
        DECLARE @v_es_th BIT;
        DECLARE @v_atr NVARCHAR(MAX);
        DECLARE @v_club_html NVARCHAR(MAX);
        DECLARE @v_bandera INT;
        DECLARE @v_club_pais NVARCHAR(200);
        DECLARE @v_clave NVARCHAR(200);
        DECLARE @v_bday INT;

        WHILE 1 = 1
        BEGIN
            SET @v_ini = CHARINDEX(@c_marca_fila, @v_html, @v_pos);
            IF @v_ini = 0 BREAK;

            -- Selección vigente: último encabezado <h3> anterior a la fila.
            WHILE @v_sig_h3 > 0 AND @v_sig_h3 < @v_ini
            BEGIN
                SET @v_fin_h3 = CHARINDEX(N'</h3>', @v_html, @v_sig_h3);
                IF @v_fin_h3 = 0 BREAK;
                SET @v_equipo = LEFT(soporte.fn_HtmlATexto(SUBSTRING(@v_html, @v_sig_h3, @v_fin_h3 - @v_sig_h3)), 150);
                SET @v_sig_h3 = CHARINDEX(N'<h3', @v_html, @v_fin_h3);
            END

            SET @v_fin = CHARINDEX(N'</tr>', @v_html, @v_ini);
            IF @v_fin = 0 SET @v_fin = LEN(@v_html) + 1;
            SET @v_fila_html = SUBSTRING(@v_html, @v_ini, @v_fin - @v_ini);
            SET @v_nro += 1;

            -- Celdas <td> y <th> de la fila, en orden.
            DELETE FROM @v_celdas;
            SET @v_p = LEN(@c_marca_fila) + 1;
            SET @v_orden = 0;
            WHILE @v_orden < 10
            BEGIN
                SET @v_td = CHARINDEX(N'<td', @v_fila_html, @v_p);
                SET @v_th = CHARINDEX(N'<th', @v_fila_html, @v_p);
                IF @v_td = 0 AND @v_th = 0 BREAK;
                SET @v_es_th = CASE WHEN @v_td = 0 OR (@v_th > 0 AND @v_th < @v_td) THEN 1 ELSE 0 END;
                SET @v_ini_celda = CASE WHEN @v_es_th = 1 THEN @v_th ELSE @v_td END;
                SET @v_ini_cont = CHARINDEX(N'>', @v_fila_html, @v_ini_celda) + 1;
                SET @v_fin_celda = CHARINDEX(CASE WHEN @v_es_th = 1 THEN N'</th>' ELSE N'</td>' END, @v_fila_html, @v_ini_cont);
                IF @v_ini_cont = 1 OR @v_fin_celda = 0 BREAK;

                SET @v_orden += 1;
                INSERT INTO @v_celdas (orden, atributos, contenido)
                VALUES (@v_orden,
                        SUBSTRING(@v_fila_html, @v_ini_celda, @v_ini_cont - @v_ini_celda),
                        SUBSTRING(@v_fila_html, @v_ini_cont, @v_fin_celda - @v_ini_cont));
                SET @v_p = @v_fin_celda + 5;
            END

            SET @v_atr = NULL;
            SET @v_club_html = NULL;
            SET @v_bday = 0;

            -- Clave de orden del jugador: data-sort-value="Apellido, Nombre"
            SELECT @v_atr = c.atributos FROM @v_celdas AS c WHERE c.orden = 3;
            SET @v_clave = NULL;
            IF CHARINDEX(N'data-sort-value="', ISNULL(@v_atr, N'')) > 0
                SET @v_clave = SUBSTRING(@v_atr, CHARINDEX(N'data-sort-value="', @v_atr) + 17,
                                         CHARINDEX(N'"', @v_atr, CHARINDEX(N'data-sort-value="', @v_atr) + 17)
                                         - CHARINDEX(N'data-sort-value="', @v_atr) - 17);

            -- País del club: nombre del archivo de la bandera (Flag_of_the_Netherlands.svg)
            SELECT @v_club_html = c.contenido FROM @v_celdas AS c WHERE c.orden = 7;
            SET @v_club_pais = NULL;
            SET @v_bandera = CHARINDEX(N'Flag_of_', ISNULL(@v_club_html, N''));
            IF @v_bandera > 0 AND CHARINDEX(N'.svg', @v_club_html, @v_bandera) > 0
            BEGIN
                SET @v_club_pais = SUBSTRING(@v_club_html, @v_bandera + 8, CHARINDEX(N'.svg', @v_club_html, @v_bandera) - @v_bandera - 8);
                SET @v_club_pais = REPLACE(REPLACE(REPLACE(@v_club_pais, N'_', N' '), N'%27', N''''), N'%28', N'(');
                SET @v_club_pais = REPLACE(@v_club_pais, N'%29', N')');
                IF @v_club_pais LIKE N'the %'
                    SET @v_club_pais = SUBSTRING(@v_club_pais, 5, 200);
            END

            SELECT @v_bday = CHARINDEX(N'class="bday">', c.contenido) FROM @v_celdas AS c WHERE c.orden = 4;

            INSERT INTO soporte.stg_jugador_html
                (nro_fila, seleccion_texto, dorsal, posicion, jugador, clave_orden, fecha_nac, club, club_pais)
            SELECT
                @v_nro,
                @v_equipo,
                LEFT(soporte.fn_HtmlATexto((SELECT c.contenido FROM @v_celdas AS c WHERE c.orden = 1)), 20),
                LEFT(soporte.fn_HtmlATexto((SELECT c.contenido FROM @v_celdas AS c WHERE c.orden = 2)), 20),
                LEFT(soporte.fn_HtmlATexto((SELECT c.contenido FROM @v_celdas AS c WHERE c.orden = 3)), 200),
                LEFT(soporte.fn_HtmlATexto(@v_clave), 200),
                CASE WHEN @v_bday > 0
                     THEN (SELECT SUBSTRING(c.contenido, @v_bday + 13, 10) FROM @v_celdas AS c WHERE c.orden = 4) END,
                LEFT(soporte.fn_HtmlATexto(@v_club_html), 200),
                LEFT(soporte.fn_Limpiar(@v_club_pais), 100);

            SET @v_pos = @v_fin;
        END

        SET @v_leidas = @v_nro;
    END TRY
    BEGIN CATCH
        SET @v_mensaje = ERROR_MESSAGE();
        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, 1, N'(pagina)', @v_origen, @v_mensaje;
        EXEC soporte.usp_Importacion_Finalizar @id_importacion, 0, 0, 0, @error_general = 1, @mostrar_resumen = 0;
        THROW;
    END CATCH

    ---------------------------------------------------------------------------
    -- 2. Transformación y validación por conjuntos
    ---------------------------------------------------------------------------
    CREATE TABLE #jug
    (
        nro_fila      INT            NOT NULL PRIMARY KEY,
        seleccion     NVARCHAR(150) COLLATE DATABASE_DEFAULT  NULL,
        id_pais       SMALLINT       NULL,
        cod_pais      CHAR(3) COLLATE DATABASE_DEFAULT        NULL,
        id_seleccion  INT            NULL,
        dorsal_txt    NVARCHAR(20) COLLATE DATABASE_DEFAULT   NULL,
        dorsal        INT            NULL,
        posicion_txt  NVARCHAR(20) COLLATE DATABASE_DEFAULT   NULL,
        id_posicion   TINYINT        NULL,
        jugador       NVARCHAR(200) COLLATE DATABASE_DEFAULT  NULL,
        nombre        NVARCHAR(200) COLLATE DATABASE_DEFAULT  NULL,
        apellido      NVARCHAR(200) COLLATE DATABASE_DEFAULT  NULL,
        fecha_txt     NVARCHAR(20) COLLATE DATABASE_DEFAULT   NULL,
        fecha_nac     DATE           NULL,
        club          NVARCHAR(200) COLLATE DATABASE_DEFAULT  NULL,
        club_pais     NVARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
        nro_doc       NVARCHAR(30) COLLATE DATABASE_DEFAULT   NULL,
        id_jugador    INT            NULL,
        estado        CHAR(1) COLLATE DATABASE_DEFAULT        NULL,     -- I insertado, U actualizado, S sin cambios, E error
        error         NVARCHAR(1000) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #jug (nro_fila, seleccion, dorsal_txt, dorsal, posicion_txt, jugador, nombre, apellido,
                      fecha_txt, fecha_nac, club, club_pais)
    SELECT
        s.nro_fila,
        s.seleccion_texto,
        s.dorsal,
        TRY_CONVERT(INT, s.dorsal),
        UPPER(s.posicion),
        x.jugador,
        NULL,
        soporte.fn_ApellidoDesdeClave(x.jugador, s.clave_orden),
        s.fecha_nac,
        TRY_CONVERT(DATE, s.fecha_nac, 23),
        CASE WHEN s.club IN (N'Unattached', N'Free agent', N'Without club') THEN NULL ELSE s.club END,
        ISNULL(s.club_pais, N'(sin datos)')
    FROM soporte.stg_jugador_html AS s
    CROSS APPLY
    (
        -- Se quita la marca de capitán: "Nombre (captain)".
        SELECT CASE WHEN CHARINDEX(N'captain', s.jugador) > 0 AND CHARINDEX(N' (', s.jugador) > 1
                    THEN LTRIM(RTRIM(LEFT(s.jugador, CHARINDEX(N' (', s.jugador) - 1)))
                    ELSE s.jugador END AS jugador
    ) AS x;

    UPDATE j
    SET nombre = CASE WHEN LEN(j.jugador) > LEN(j.apellido)
                      THEN LTRIM(RTRIM(LEFT(j.jugador, LEN(j.jugador) - LEN(j.apellido))))
                      ELSE j.jugador END,
        id_pais = soporte.fn_BuscarPais('NOMBRE', j.seleccion),
        id_posicion = po.id_posicion
    FROM #jug AS j
    LEFT JOIN persona.posicion AS po
           ON po.descripcion = CASE j.posicion_txt
                                   WHEN N'GK' THEN N'Arquero'
                                   WHEN N'DF' THEN N'Defensor'
                                   WHEN N'MF' THEN N'Mediocampista'
                                   WHEN N'FW' THEN N'Delantero'
                               END;

    UPDATE j
    SET id_seleccion = s.id_seleccion,
        cod_pais = COALESCE(p.cod_fifa, p.cod_iso3)
    FROM #jug AS j
    LEFT JOIN geo.pais AS p ON p.id_pais = j.id_pais
    LEFT JOIN torneo.seleccion AS s ON s.id_pais = j.id_pais;

    UPDATE #jug
    SET nro_doc = CONCAT(cod_pais, N'-', CONVERT(CHAR(8), fecha_nac, 112), N'-',
                         LEFT(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', UPPER(jugador)), 2), 8))
    WHERE cod_pais IS NOT NULL AND fecha_nac IS NOT NULL AND jugador IS NOT NULL;

    UPDATE j
    SET error = NULLIF(CONCAT(
            CASE WHEN j.id_seleccion IS NULL THEN CONCAT(N'seleccion inexistente: ', ISNULL(j.seleccion, N'sin encabezado'), N'; ') END,
            CASE WHEN j.dorsal IS NULL OR j.dorsal NOT BETWEEN 1 AND 99
                 THEN CONCAT(N'dorsal invalido (', ISNULL(j.dorsal_txt, N'vacio'), N'); ') END,
            CASE WHEN j.id_posicion IS NULL THEN CONCAT(N'posicion desconocida (', ISNULL(j.posicion_txt, N'vacia'), N'); ') END,
            CASE WHEN j.jugador IS NULL THEN N'jugador sin nombre; ' END,
            CASE WHEN LEN(j.nombre) > 80 OR LEN(j.apellido) > 80 THEN N'nombre o apellido de mas de 80 caracteres; ' END,
            CASE WHEN j.fecha_nac IS NULL THEN CONCAT(N'fecha de nacimiento invalida (', ISNULL(j.fecha_txt, N'vacia'), N'); ')
                 WHEN j.fecha_nac > CONVERT(DATE, SYSDATETIME()) THEN N'fecha de nacimiento futura; ' END,
            CASE WHEN LEN(j.club) > 100 THEN N'nombre de club de mas de 100 caracteres; ' END,
            CASE WHEN EXISTS (SELECT 1 FROM #jug AS d WHERE d.id_seleccion = j.id_seleccion AND d.dorsal = j.dorsal AND d.nro_fila < j.nro_fila)
                 THEN N'dorsal repetido en la seleccion; ' END,
            CASE WHEN EXISTS (SELECT 1 FROM #jug AS d WHERE d.nro_doc = j.nro_doc AND d.nro_fila < j.nro_fila)
                 THEN N'jugador repetido en la pagina; ' END
        ), N'')
    FROM #jug AS j;

    UPDATE #jug SET estado = 'E' WHERE error IS NOT NULL;

    DECLARE @v_fila INT = 0;
    DECLARE @v_texto NVARCHAR(1000);
    DECLARE @v_jugador NVARCHAR(200);

    WHILE 1 = 1
    BEGIN
        SELECT TOP (1) @v_fila = j.nro_fila, @v_texto = j.error, @v_jugador = CONCAT(j.seleccion, N' - ', j.jugador)
        FROM #jug AS j
        WHERE j.error IS NOT NULL AND j.nro_fila > @v_fila
        ORDER BY j.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, N'jugador', @v_jugador, @v_texto;
    END

    ---------------------------------------------------------------------------
    -- 3. Upsert de clubes y jugadores (una transacción por fila)
    ---------------------------------------------------------------------------
    DECLARE @v_nombre NVARCHAR(80), @v_apellido NVARCHAR(80), @v_fecha DATE, @v_id_pais SMALLINT;
    DECLARE @v_nro_doc NVARCHAR(30), @v_id_posicion TINYINT, @v_club NVARCHAR(100), @v_club_pais_f NVARCHAR(80);
    DECLARE @v_id_club INT, @v_id_jugador INT;
    DECLARE @a_nombre NVARCHAR(80), @a_apellido NVARCHAR(80), @a_fecha DATE, @a_id_pais SMALLINT;
    DECLARE @a_pie CHAR(1), @a_altura SMALLINT, @a_club INT, @a_posicion TINYINT;

    SET @v_fila = 0;
    WHILE 1 = 1
    BEGIN
        SELECT TOP (1)
            @v_fila = j.nro_fila,
            @v_nombre = LEFT(j.nombre, 80),
            @v_apellido = LEFT(j.apellido, 80),
            @v_fecha = j.fecha_nac,
            @v_id_pais = j.id_pais,
            @v_nro_doc = j.nro_doc,
            @v_id_posicion = j.id_posicion,
            @v_club = LEFT(j.club, 100),
            @v_club_pais_f = LEFT(j.club_pais, 80),
            @v_jugador = CONCAT(j.seleccion, N' - ', j.jugador)
        FROM #jug AS j
        WHERE j.error IS NULL AND j.nro_fila > @v_fila
        ORDER BY j.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        BEGIN TRY
            BEGIN TRANSACTION;

            SET @v_id_club = NULL;
            IF @v_club IS NOT NULL
            BEGIN
                SELECT @v_id_club = c.id_club
                FROM persona.club AS c
                WHERE c.nombre = @v_club AND c.pais_club = @v_club_pais_f;

                IF @v_id_club IS NULL
                    EXEC persona.usp_Club_Insertar
                        @nombre = @v_club,
                        @pais_club = @v_club_pais_f,
                        @id_club = @v_id_club OUTPUT;
            END

            SET @v_id_jugador = NULL;
            SELECT @v_id_jugador = p.id_persona,
                   @a_nombre = p.nombre, @a_apellido = p.apellido, @a_fecha = p.fecha_nac, @a_id_pais = p.id_pais,
                   @a_pie = j.pie_habil, @a_altura = j.altura_cm, @a_club = j.id_club, @a_posicion = j.id_posicion_habitual
            FROM persona.persona AS p
            JOIN persona.jugador AS j ON j.id_persona = p.id_persona
            WHERE p.tipo_doc = 'EXT' AND p.nro_doc = @v_nro_doc;

            IF @v_id_jugador IS NULL
            BEGIN
                EXEC persona.usp_Jugador_Insertar
                    @tipo_doc = 'EXT',
                    @nro_doc = @v_nro_doc,
                    @nombre = @v_nombre,
                    @apellido = @v_apellido,
                    @fecha_nac = @v_fecha,
                    @id_pais = @v_id_pais,
                    @pie_habil = NULL,
                    @altura_cm = NULL,
                    @id_club = @v_id_club,
                    @id_posicion_habitual = @v_id_posicion,
                    @id_persona = @v_id_jugador OUTPUT;
                UPDATE #jug SET estado = 'I', id_jugador = @v_id_jugador WHERE nro_fila = @v_fila;
            END
            ELSE IF @a_nombre <> @v_nombre OR @a_apellido <> @v_apellido OR @a_fecha <> @v_fecha
                 OR @a_id_pais <> @v_id_pais OR ISNULL(@a_club, -1) <> ISNULL(@v_id_club, -1)
                 OR @a_posicion <> @v_id_posicion
            BEGIN
                EXEC persona.usp_Jugador_Modificar
                    @id_persona = @v_id_jugador,
                    @tipo_doc = 'EXT',
                    @nro_doc = @v_nro_doc,
                    @nombre = @v_nombre,
                    @apellido = @v_apellido,
                    @fecha_nac = @v_fecha,
                    @id_pais = @v_id_pais,
                    @pie_habil = @a_pie,
                    @altura_cm = @a_altura,
                    @id_club = @v_id_club,
                    @id_posicion_habitual = @v_id_posicion;
                UPDATE #jug SET estado = 'U', id_jugador = @v_id_jugador WHERE nro_fila = @v_fila;
            END
            ELSE
                UPDATE #jug SET estado = 'S', id_jugador = @v_id_jugador WHERE nro_fila = @v_fila;

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SET @v_mensaje = ERROR_MESSAGE();
            UPDATE #jug SET estado = 'E' WHERE nro_fila = @v_fila;
            EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, N'jugador', @v_jugador, @v_mensaje;
        END CATCH
    END

    ---------------------------------------------------------------------------
    -- 4. Convocatoria de cada selección
    --    Sin convocatoria activa: se registra la lista completa con
    --    torneo.usp_Negocio_RegistrarConvocatoria (valida mínimo y máximo).
    --    Con convocatoria activa idéntica: sin cambios.
    --    Con diferencias: se informan como error; las altas y bajas de último
    --    momento se registran con torneo.usp_Negocio_ReemplazarConvocado, que
    --    exige motivo y fecha.
    ---------------------------------------------------------------------------
    DECLARE @v_id_seleccion INT = 0;
    DECLARE @v_primera_fila INT;
    DECLARE @v_nombre_sel NVARCHAR(150);
    DECLARE @v_lista torneo.tt_Convocado;
    DECLARE @v_altas INT, @v_bajas INT, @v_cambian INT;
    DECLARE @v_convocatorias_nuevas INT = 0;
    DECLARE @v_convocatorias_iguales INT = 0;
    DECLARE @v_convocatorias_error INT = 0;

    WHILE 1 = 1
    BEGIN
        SELECT TOP (1) @v_id_seleccion = j.id_seleccion
        FROM #jug AS j
        WHERE j.id_seleccion > @v_id_seleccion
        ORDER BY j.id_seleccion;
        IF @@ROWCOUNT = 0 BREAK;

        SELECT @v_primera_fila = MIN(j.nro_fila), @v_nombre_sel = MIN(j.seleccion)
        FROM #jug AS j
        WHERE j.id_seleccion = @v_id_seleccion;

        DELETE FROM @v_lista;
        INSERT INTO @v_lista (id_jugador, dorsal)
        SELECT j.id_jugador, CONVERT(TINYINT, j.dorsal)
        FROM #jug AS j
        WHERE j.id_seleccion = @v_id_seleccion AND j.estado IN ('I', 'U', 'S');

        BEGIN TRY
            IF EXISTS (SELECT 1 FROM #jug AS j WHERE j.id_seleccion = @v_id_seleccion AND j.estado = 'E')
                THROW 50003, N'no se registra ni se compara la convocatoria porque hay jugadores de la seleccion con errores', 1;

            IF NOT EXISTS (SELECT 1 FROM torneo.convocatoria AS c WHERE c.id_seleccion = @v_id_seleccion AND c.estado = 'ACTIVO')
            BEGIN
                EXEC torneo.usp_Negocio_RegistrarConvocatoria
                    @id_seleccion = @v_id_seleccion,
                    @convocados = @v_lista;
                SET @v_convocatorias_nuevas += 1;
            END
            ELSE
            BEGIN
                SELECT @v_altas = COUNT(*)
                FROM @v_lista AS l
                WHERE NOT EXISTS (SELECT 1 FROM torneo.convocatoria AS c
                                  WHERE c.id_seleccion = @v_id_seleccion AND c.estado = 'ACTIVO' AND c.id_jugador = l.id_jugador);

                SELECT @v_bajas = COUNT(*)
                FROM torneo.convocatoria AS c
                WHERE c.id_seleccion = @v_id_seleccion AND c.estado = 'ACTIVO'
                  AND NOT EXISTS (SELECT 1 FROM @v_lista AS l WHERE l.id_jugador = c.id_jugador);

                SELECT @v_cambian = COUNT(*)
                FROM @v_lista AS l
                JOIN torneo.convocatoria AS c
                  ON c.id_seleccion = @v_id_seleccion AND c.estado = 'ACTIVO' AND c.id_jugador = l.id_jugador
                WHERE c.dorsal <> l.dorsal;

                IF @v_altas = 0 AND @v_bajas = 0 AND @v_cambian = 0
                    SET @v_convocatorias_iguales += 1;
                ELSE
                BEGIN
                    SET @v_mensaje = CONCAT(N'la seleccion ya tiene una convocatoria activa distinta de la publicada (',
                                            @v_altas, N' altas, ', @v_bajas, N' bajas, ', @v_cambian,
                                            N' cambios de dorsal); registre los reemplazos con torneo.usp_Negocio_ReemplazarConvocado');
                    THROW 50003, @v_mensaje, 1;
                END
            END
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SET @v_mensaje = ERROR_MESSAGE();
            EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_primera_fila, N'convocatoria', @v_nombre_sel, @v_mensaje;
            SET @v_convocatorias_error += 1;
            -- Las filas de la selección quedan contadas como filas con error.
            UPDATE #jug SET estado = 'E' WHERE id_seleccion = @v_id_seleccion;
        END CATCH
    END

    ---------------------------------------------------------------------------
    -- 5. Cierre
    ---------------------------------------------------------------------------
    DECLARE @v_ok INT = (SELECT COUNT(*) FROM #jug WHERE estado IN ('I', 'U', 'S'));
    DECLARE @v_err INT = (SELECT COUNT(*) FROM #jug WHERE estado = 'E');

    EXEC soporte.usp_Importacion_Finalizar @id_importacion, @v_leidas,
         @filas_ok = @v_ok,
         @filas_error = @v_err;

    SELECT @id_importacion AS id_importacion,
           @v_leidas AS filas_leidas,
           (SELECT COUNT(*) FROM #jug WHERE estado = 'I') AS jugadores_insertados,
           (SELECT COUNT(*) FROM #jug WHERE estado = 'U') AS jugadores_actualizados,
           (SELECT COUNT(*) FROM #jug WHERE estado = 'S') AS jugadores_sin_cambios,
           @v_err AS filas_con_error,
           @v_convocatorias_nuevas AS convocatorias_registradas,
           @v_convocatorias_iguales AS convocatorias_sin_cambios,
           @v_convocatorias_error AS convocatorias_con_error;
END;
GO
