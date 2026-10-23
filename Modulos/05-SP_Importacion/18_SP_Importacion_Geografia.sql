/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Entrega 6. SP de importación masiva de los datos geográficos y de
          las selecciones, con lógica de upsert mediante los SP de ABM de la
          Entrega 5:
          1. soporte.usp_Importar_PaisesCsv       países y monedas (CSV)
          2. soporte.usp_Importar_HusosTxt        husos horarios (TXT)
          3. soporte.usp_Importar_CiudadesTxt     ciudades (TXT)
          4. soporte.usp_Importar_SedesJson       sedes del torneo (JSON)
          5. soporte.usp_Importar_SeleccionesJson selecciones y grupos (JSON)
===================================================================== */
USE Mundial2026;
GO

/*
   Esquema común de todos los SP de importación
   --------------------------------------------
   1) Validación de parámetros (errores acumulados en un único mensaje y THROW).
   2) Cabecera de auditoría EN_CURSO (soporte.usp_Importacion_Iniciar).
   3) Carga del archivo, tal como se publica, en su tabla de paso. Si el archivo
      no se puede leer, se registra el error, se cierra la importación como
      CON_ERROR y se relanza la excepción (THROW).
   4) Validación por conjuntos: cada fila de la tabla de paso acumula en la
      columna "error" todos los motivos de rechazo.
   5) Recorrido de las filas válidas (bucle WHILE por número de fila). Cada fila
      se confirma en su propia transacción y se aplica el upsert llamando a los
      SP de ABM: si la clave natural no existe se inserta, si existe y cambió
      algún dato se modifica, y si no cambió nada no se toca. Un error en una
      fila se registra y la importación continúa con la siguiente.
   6) Cierre de la cabecera (OK o CON_ERROR) y resumen con las filas
      insertadas, actualizadas, sin cambios, omitidas y con error.
   Volver a importar el mismo archivo no genera duplicados: todas las filas
   quedan "sin cambios".
*/

-- ============================================================================
-- 1. PAISES Y MONEDAS (datasets/country-codes, CSV)
--    https://github.com/datasets/country-codes  (data/country-codes.csv)
--    Clave natural del país: código ISO 3166-1 alfa-3.
--    Clave natural de la moneda: código ISO 4217.
-- ============================================================================
CREATE OR ALTER PROCEDURE soporte.usp_Importar_PaisesCsv
    @archivo NVARCHAR(260),
    @id_importacion INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @c_sp NVARCHAR(60) = N'soporte.usp_Importar_PaisesCsv';
    DECLARE @c_fuente NVARCHAR(60) = N'datasets/country-codes (GitHub)';
    DECLARE @v_errores NVARCHAR(2000) = soporte.fn_ValidarRutaArchivo(@archivo, N'.csv');
    DECLARE @v_mensaje NVARCHAR(2048);
    DECLARE @v_leidas INT = 0;
    DECLARE @v_insertadas INT = 0;
    DECLARE @v_actualizadas INT = 0;
    DECLARE @v_sin_cambios INT = 0;
    DECLARE @v_con_error INT = 0;
    DECLARE @v_id_min INT;

    IF @@TRANCOUNT > 0
        SET @v_errores += N'no puede ejecutarse dentro de una transaccion; ';

    IF @v_errores <> N''
    BEGIN
        SET @v_mensaje = CONCAT(@c_sp, N': ', @v_errores);
        THROW 50001, @v_mensaje, 1;
    END

    EXEC soporte.usp_Importacion_Iniciar
        @fuente = @c_fuente, @archivo = @archivo, @formato = 'CSV',
        @id_importacion = @id_importacion OUTPUT;

    ---------------------------------------------------------------------------
    -- Carga del archivo en la tabla de paso
    ---------------------------------------------------------------------------
    BEGIN TRY
        DELETE FROM soporte.stg_pais_csv;
        EXEC soporte.usp_Archivo_CargarDelimitado
            @archivo = @archivo,
            @vista_destino = N'soporte.vw_stg_pais_csv_carga',
            @es_csv = 1,
            @primera_fila = 2,
            @filas_cargadas = @v_leidas OUTPUT;
    END TRY
    BEGIN CATCH
        SET @v_mensaje = ERROR_MESSAGE();
        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, 1, N'(archivo)', @archivo, @v_mensaje;
        EXEC soporte.usp_Importacion_Finalizar @id_importacion, 0, 0, 0, @error_general = 1, @mostrar_resumen = 0;
        THROW;
    END CATCH

    SELECT @v_id_min = MIN(s.id_stg) FROM soporte.stg_pais_csv AS s;

    ---------------------------------------------------------------------------
    -- Transformación y validación por conjuntos
    ---------------------------------------------------------------------------
    CREATE TABLE #pais
    (
        nro_fila       INT           NOT NULL PRIMARY KEY,
        cod_iso3       NVARCHAR(400) COLLATE DATABASE_DEFAULT NULL,
        cod_iso2       NVARCHAR(400) COLLATE DATABASE_DEFAULT NULL,
        cod_fifa       NVARCHAR(400) COLLATE DATABASE_DEFAULT NULL,
        nombre         NVARCHAR(400) COLLATE DATABASE_DEFAULT NULL,
        nombre_en      NVARCHAR(400) COLLATE DATABASE_DEFAULT NULL,
        nombre_cldr    NVARCHAR(400) COLLATE DATABASE_DEFAULT NULL,
        nombre_unterm  NVARCHAR(400) COLLATE DATABASE_DEFAULT NULL,
        continente     NVARCHAR(400) COLLATE DATABASE_DEFAULT NULL,
        sigla_confed   NVARCHAR(10) COLLATE DATABASE_DEFAULT  NULL,
        id_confed      TINYINT       NULL,
        monedas        NVARCHAR(400) COLLATE DATABASE_DEFAULT NULL,
        nombres_moneda NVARCHAR(400) COLLATE DATABASE_DEFAULT NULL,
        omitida        BIT           NOT NULL DEFAULT 0,
        error          NVARCHAR(1000) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #pais (nro_fila, cod_iso3, cod_iso2, cod_fifa, nombre, nombre_en, nombre_cldr,
                       nombre_unterm, continente, monedas, nombres_moneda)
    SELECT
        s.id_stg - @v_id_min + 2,                                   -- línea del archivo (la 1 es el encabezado)
        UPPER(soporte.fn_Limpiar(s.iso3166_1_alpha_3)),
        UPPER(soporte.fn_Limpiar(s.iso3166_1_alpha_2)),
        CASE WHEN soporte.fn_Limpiar(s.fifa) LIKE N'[A-Za-z][A-Za-z][A-Za-z]'
             THEN UPPER(soporte.fn_Limpiar(s.fifa)) END,              -- se descartan valores como "1" o "ROS3"
        COALESCE(soporte.fn_Limpiar(s.official_name_es),
                 soporte.fn_Limpiar(REPLACE(REPLACE(REPLACE(REPLACE(s.unterm_spanish_short,
                     N' (el)', N''), N' (la)', N''), N' (los)', N''), N' (las)', N'')),
                 soporte.fn_Limpiar(s.cldr_display_name)),
        soporte.fn_Limpiar(s.official_name_en),
        soporte.fn_Limpiar(s.cldr_display_name),
        soporte.fn_Limpiar(REPLACE(s.unterm_english_short, N' (the)', N'')),
        UPPER(soporte.fn_Limpiar(s.continent)),
        UPPER(soporte.fn_Limpiar(s.iso4217_currency_alphabetic_code)),
        soporte.fn_Limpiar(s.iso4217_currency_name)
    FROM soporte.stg_pais_csv AS s;

    -- Confederación: por continente, con las excepciones conocidas de FIFA.
    -- La importación de selecciones (openfootball) corrige la confederación
    -- de los 48 participantes con el dato oficial.
    UPDATE p
    SET sigla_confed =
        CASE
            WHEN p.cod_iso3 = N'AUS' THEN N'AFC'
            WHEN p.cod_iso3 IN (N'ISR', N'KAZ', N'TUR', N'CYP', N'ARM', N'AZE', N'GEO', N'RUS') THEN N'UEFA'
            WHEN p.cod_iso3 IN (N'GUY', N'SUR', N'GUF') THEN N'CONCACAF'
            WHEN p.continente = N'SA' THEN N'CONMEBOL'
            WHEN p.continente = N'EU' THEN N'UEFA'
            WHEN p.continente = N'AF' THEN N'CAF'
            WHEN p.continente = N'AS' THEN N'AFC'
            WHEN p.continente = N'OC' THEN N'OFC'
            WHEN p.continente = N'NA' THEN N'CONCACAF'
        END
    FROM #pais AS p;

    UPDATE p
    SET id_confed = c.id_confederacion
    FROM #pais AS p
    JOIN geo.confederacion AS c ON c.sigla = p.sigla_confed;

    -- Territorios sin confederación (Antártida y similares): se omiten.
    UPDATE #pais SET omitida = 1 WHERE continente = N'AN' AND cod_iso3 IS NOT NULL;

    UPDATE p
    SET error = NULLIF(CONCAT(
            CASE WHEN p.cod_iso3 IS NULL OR p.cod_iso3 NOT LIKE N'[A-Z][A-Z][A-Z]'
                 THEN CONCAT(N'ISO3166-1-Alpha-3 invalido (', ISNULL(p.cod_iso3, N'vacio'), N'); ') END,
            CASE WHEN p.cod_iso2 IS NOT NULL AND p.cod_iso2 NOT LIKE N'[A-Z][A-Z]'
                 THEN CONCAT(N'ISO3166-1-Alpha-2 invalido (', p.cod_iso2, N'); ') END,
            CASE WHEN p.nombre IS NULL THEN N'el pais no tiene nombre; ' END,
            CASE WHEN LEN(p.nombre) > 80 THEN N'nombre de mas de 80 caracteres; ' END,
            CASE WHEN p.omitida = 0 AND p.id_confed IS NULL
                 THEN CONCAT(N'continente invalido (', ISNULL(p.continente, N'vacio'), N'); ') END,
            CASE WHEN EXISTS (SELECT 1 FROM #pais AS d WHERE d.cod_iso3 = p.cod_iso3 AND d.nro_fila < p.nro_fila)
                 THEN N'codigo ISO3 repetido en el archivo; ' END
        ), N'')
    FROM #pais AS p
    WHERE p.omitida = 0 OR p.cod_iso3 IS NULL;

    ---------------------------------------------------------------------------
    -- Registro de las filas rechazadas
    ---------------------------------------------------------------------------
    DECLARE @v_fila INT = 0;
    DECLARE @v_texto NVARCHAR(1000);

    WHILE 1 = 1
    BEGIN
        SELECT TOP (1) @v_fila = p.nro_fila, @v_texto = p.error
        FROM #pais AS p
        WHERE p.error IS NOT NULL AND p.nro_fila > @v_fila
        ORDER BY p.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, NULL, NULL, @v_texto;
        SET @v_con_error += 1;
    END

    ---------------------------------------------------------------------------
    -- Upsert fila por fila
    ---------------------------------------------------------------------------
    DECLARE @v_iso3 CHAR(3), @v_iso2 NVARCHAR(10), @v_fifa CHAR(3), @v_nombre NVARCHAR(80);
    DECLARE @v_nombre_en NVARCHAR(150), @v_nombre_cldr NVARCHAR(150), @v_nombre_unterm NVARCHAR(150);
    DECLARE @v_id_confed TINYINT, @v_monedas NVARCHAR(400), @v_nombres_moneda NVARCHAR(400);
    DECLARE @v_id_pais SMALLINT, @v_nombre_act NVARCHAR(80), @v_fifa_act CHAR(3);
    DECLARE @v_gentilicio_act NVARCHAR(60), @v_confed_act TINYINT;
    DECLARE @v_id_moneda TINYINT, @v_cod_moneda CHAR(3), @v_nom_moneda NVARCHAR(50);
    DECLARE @v_monedas_fila TABLE (orden INT, codigo NVARCHAR(10), nombre NVARCHAR(100));
    DECLARE @v_orden INT;

    SET @v_fila = 0;
    WHILE 1 = 1
    BEGIN
        SELECT TOP (1)
            @v_fila = p.nro_fila,
            @v_iso3 = p.cod_iso3,
            @v_iso2 = p.cod_iso2,
            @v_fifa = p.cod_fifa,
            @v_nombre = p.nombre,
            @v_nombre_en = LEFT(p.nombre_en, 150),
            @v_nombre_cldr = LEFT(p.nombre_cldr, 150),
            @v_nombre_unterm = LEFT(p.nombre_unterm, 150),
            @v_id_confed = p.id_confed,
            @v_monedas = p.monedas,
            @v_nombres_moneda = p.nombres_moneda
        FROM #pais AS p
        WHERE p.error IS NULL AND p.omitida = 0 AND p.nro_fila > @v_fila
        ORDER BY p.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        SET @v_id_pais = NULL;
        SELECT
            @v_id_pais = g.id_pais,
            @v_nombre_act = g.nombre,
            @v_fifa_act = g.cod_fifa,
            @v_gentilicio_act = g.gentilicio,
            @v_confed_act = g.id_confederacion
        FROM geo.pais AS g
        WHERE g.cod_iso3 = @v_iso3;

        BEGIN TRY
            BEGIN TRANSACTION;

            IF @v_id_pais IS NULL
            BEGIN
                EXEC geo.usp_Pais_Insertar
                    @nombre = @v_nombre,
                    @cod_iso3 = @v_iso3,
                    @cod_fifa = @v_fifa,
                    @gentilicio = NULL,
                    @id_confederacion = @v_id_confed,
                    @id_pais = @v_id_pais OUTPUT;
                SET @v_insertadas += 1;
            END
            ELSE IF @v_nombre <> @v_nombre_act
                 OR (@v_fifa IS NOT NULL AND ISNULL(@v_fifa_act, '') <> @v_fifa)
            BEGIN
                -- La confederación vigente no se pisa: puede haberla corregido
                -- la importación de selecciones.
                EXEC geo.usp_Pais_Modificar
                    @id_pais = @v_id_pais,
                    @nombre = @v_nombre,
                    @cod_iso3 = @v_iso3,
                    @cod_fifa = @v_fifa,
                    @gentilicio = @v_gentilicio_act,
                    @id_confederacion = @v_confed_act;
                SET @v_actualizadas += 1;
            END
            ELSE
                SET @v_sin_cambios += 1;

            -- Equivalencias para reconocer el país en otras fuentes.
            IF @v_iso2 IS NOT NULL
                EXEC soporte.usp_EquivalenciaPais_Asegurar 'ISO2', @v_iso2, @v_id_pais, @c_fuente;
            EXEC soporte.usp_EquivalenciaPais_Asegurar 'NOMBRE', @v_nombre, @v_id_pais, @c_fuente;
            EXEC soporte.usp_EquivalenciaPais_Asegurar 'NOMBRE', @v_nombre_en, @v_id_pais, @c_fuente;
            EXEC soporte.usp_EquivalenciaPais_Asegurar 'NOMBRE', @v_nombre_cldr, @v_id_pais, @c_fuente;
            EXEC soporte.usp_EquivalenciaPais_Asegurar 'NOMBRE', @v_nombre_unterm, @v_id_pais, @c_fuente;

            -- Monedas: el archivo puede traer varias separadas por coma
            -- ("HTG,USD" con nombres "Gourde,US Dollar"); se emparejan por posición.
            DELETE FROM @v_monedas_fila;
            IF @v_monedas IS NOT NULL
            BEGIN
                INSERT INTO @v_monedas_fila (orden, codigo, nombre)
                SELECT CONVERT(INT, c.[key]), LTRIM(RTRIM(c.value)), LTRIM(RTRIM(n.value))
                FROM OPENJSON(N'["' + REPLACE(STRING_ESCAPE(@v_monedas, 'json'), N',', N'","') + N'"]') AS c
                LEFT JOIN OPENJSON(N'["' + REPLACE(STRING_ESCAPE(ISNULL(@v_nombres_moneda, N''), 'json'), N',', N'","') + N'"]') AS n
                       ON n.[key] = c.[key];

                SET @v_orden = -1;
                WHILE 1 = 1
                BEGIN
                    SELECT TOP (1) @v_orden = m.orden, @v_cod_moneda = m.codigo,
                                   @v_nom_moneda = LEFT(ISNULL(NULLIF(m.nombre, N''), m.codigo), 50)
                    FROM @v_monedas_fila AS m
                    WHERE m.orden > @v_orden
                    ORDER BY m.orden;
                    IF @@ROWCOUNT = 0 BREAK;

                    IF @v_cod_moneda LIKE N'[A-Z][A-Z][A-Z]'
                       AND NOT EXISTS (SELECT 1 FROM publicidad.moneda AS mo WHERE mo.cod_iso4217 = @v_cod_moneda)
                        EXEC publicidad.usp_Moneda_Insertar
                            @cod_iso4217 = @v_cod_moneda,
                            @nombre = @v_nom_moneda,
                            @id_moneda = @v_id_moneda OUTPUT;
                END
            END

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SET @v_mensaje = ERROR_MESSAGE();
            EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, N'ISO3166-1-Alpha-3', @v_iso3, @v_mensaje;
            SET @v_con_error += 1;
        END CATCH
    END

    ---------------------------------------------------------------------------
    -- Cierre
    ---------------------------------------------------------------------------
    DECLARE @v_filas_ok INT = @v_insertadas + @v_actualizadas + @v_sin_cambios;
    EXEC soporte.usp_Importacion_Finalizar @id_importacion, @v_leidas,
         @filas_ok = @v_filas_ok,
         @filas_error = @v_con_error;

    SELECT @id_importacion AS id_importacion,
           @v_leidas AS filas_leidas,
           @v_insertadas AS insertadas,
           @v_actualizadas AS actualizadas,
           @v_sin_cambios AS sin_cambios,
           (SELECT COUNT(*) FROM #pais WHERE omitida = 1 AND error IS NULL) AS omitidas,
           @v_con_error AS con_error;
END;
GO

-- ============================================================================
-- 2. HUSOS HORARIOS (GeoNames timeZones.txt)
--    https://download.geonames.org/export/dump/timeZones.txt
--    Clave natural: nombre IANA de la zona (zona_horaria).
--    offset_utc = desplazamiento estándar en minutos; horario_verano = 1 si
--    al 1 de julio (época del Mundial) la zona suma una hora.
-- ============================================================================
CREATE OR ALTER PROCEDURE soporte.usp_Importar_HusosTxt
    @archivo NVARCHAR(260),
    @id_importacion INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @c_sp NVARCHAR(60) = N'soporte.usp_Importar_HusosTxt';
    DECLARE @c_fuente NVARCHAR(60) = N'GeoNames timeZones.txt';
    DECLARE @v_errores NVARCHAR(2000) = soporte.fn_ValidarRutaArchivo(@archivo, N'.txt');
    DECLARE @v_mensaje NVARCHAR(2048);
    DECLARE @v_leidas INT = 0;
    DECLARE @v_insertadas INT = 0;
    DECLARE @v_actualizadas INT = 0;
    DECLARE @v_sin_cambios INT = 0;
    DECLARE @v_con_error INT = 0;
    DECLARE @v_id_min INT;

    IF @@TRANCOUNT > 0
        SET @v_errores += N'no puede ejecutarse dentro de una transaccion; ';

    IF @v_errores <> N''
    BEGIN
        SET @v_mensaje = CONCAT(@c_sp, N': ', @v_errores);
        THROW 50001, @v_mensaje, 1;
    END

    EXEC soporte.usp_Importacion_Iniciar
        @fuente = @c_fuente, @archivo = @archivo, @formato = 'TXT',
        @id_importacion = @id_importacion OUTPUT;

    BEGIN TRY
        DELETE FROM soporte.stg_huso_txt;
        EXEC soporte.usp_Archivo_CargarDelimitado
            @archivo = @archivo,
            @vista_destino = N'soporte.vw_stg_huso_txt_carga',
            @es_csv = 0,
            @primera_fila = 2,
            @filas_cargadas = @v_leidas OUTPUT;
    END TRY
    BEGIN CATCH
        SET @v_mensaje = ERROR_MESSAGE();
        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, 1, N'(archivo)', @archivo, @v_mensaje;
        EXEC soporte.usp_Importacion_Finalizar @id_importacion, 0, 0, 0, @error_general = 1, @mostrar_resumen = 0;
        THROW;
    END CATCH

    SELECT @v_id_min = MIN(s.id_stg) FROM soporte.stg_huso_txt AS s;

    CREATE TABLE #huso
    (
        nro_fila       INT            NOT NULL PRIMARY KEY,
        zona_horaria   NVARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
        offset_base    DECIMAL(6,2)   NULL,
        offset_julio   DECIMAL(6,2)   NULL,
        texto_base     NVARCHAR(20) COLLATE DATABASE_DEFAULT   NULL,
        texto_julio    NVARCHAR(20) COLLATE DATABASE_DEFAULT   NULL,
        error          NVARCHAR(1000) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #huso (nro_fila, zona_horaria, texto_base, texto_julio, offset_base, offset_julio)
    SELECT
        s.id_stg - @v_id_min + 2,
        soporte.fn_Limpiar(s.zona_horaria),
        soporte.fn_Limpiar(s.offset_base),
        soporte.fn_Limpiar(s.offset_julio),
        TRY_CONVERT(DECIMAL(6,2), soporte.fn_Limpiar(s.offset_base)),
        TRY_CONVERT(DECIMAL(6,2), soporte.fn_Limpiar(s.offset_julio))
    FROM soporte.stg_huso_txt AS s;

    UPDATE h
    SET error = NULLIF(CONCAT(
            CASE WHEN h.zona_horaria IS NULL THEN N'zona horaria vacia; ' END,
            CASE WHEN LEN(h.zona_horaria) > 60 THEN N'zona horaria de mas de 60 caracteres; ' END,
            CASE WHEN h.offset_base IS NULL THEN CONCAT(N'rawOffset no numerico (', ISNULL(h.texto_base, N'vacio'), N'); ')
                 WHEN h.offset_base * 60 NOT BETWEEN -720 AND 840 THEN CONCAT(N'rawOffset fuera de rango (', h.texto_base, N'); ') END,
            CASE WHEN h.offset_julio IS NULL THEN CONCAT(N'DST offset no numerico (', ISNULL(h.texto_julio, N'vacio'), N'); ') END,
            CASE WHEN EXISTS (SELECT 1 FROM #huso AS d WHERE d.zona_horaria = h.zona_horaria AND d.nro_fila < h.nro_fila)
                 THEN N'zona horaria repetida en el archivo; ' END
        ), N'')
    FROM #huso AS h;

    DECLARE @v_fila INT = 0;
    DECLARE @v_texto NVARCHAR(1000);

    WHILE 1 = 1
    BEGIN
        SELECT TOP (1) @v_fila = h.nro_fila, @v_texto = h.error
        FROM #huso AS h
        WHERE h.error IS NOT NULL AND h.nro_fila > @v_fila
        ORDER BY h.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, NULL, NULL, @v_texto;
        SET @v_con_error += 1;
    END

    DECLARE @v_zona NVARCHAR(60), @v_offset SMALLINT, @v_verano BIT;
    DECLARE @v_id_huso SMALLINT, @v_offset_act SMALLINT, @v_verano_act BIT;

    SET @v_fila = 0;
    WHILE 1 = 1
    BEGIN
        SELECT TOP (1)
            @v_fila = h.nro_fila,
            @v_zona = h.zona_horaria,
            @v_offset = CONVERT(SMALLINT, ROUND(h.offset_base * 60, 0)),
            @v_verano = CASE WHEN h.offset_julio <> h.offset_base THEN 1 ELSE 0 END
        FROM #huso AS h
        WHERE h.error IS NULL AND h.nro_fila > @v_fila
        ORDER BY h.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        SET @v_id_huso = NULL;
        SELECT @v_id_huso = x.id_huso, @v_offset_act = x.offset_utc, @v_verano_act = x.horario_verano
        FROM geo.huso_horario AS x
        WHERE x.zona_horaria = @v_zona;

        BEGIN TRY
            IF @v_id_huso IS NULL
            BEGIN
                EXEC geo.usp_HusoHorario_Insertar
                    @zona_horaria = @v_zona,
                    @offset_utc = @v_offset,
                    @horario_verano = @v_verano,
                    @id_huso = @v_id_huso OUTPUT;
                SET @v_insertadas += 1;
            END
            ELSE IF @v_offset_act <> @v_offset OR @v_verano_act <> @v_verano
            BEGIN
                EXEC geo.usp_HusoHorario_Modificar
                    @id_huso = @v_id_huso,
                    @zona_horaria = @v_zona,
                    @offset_utc = @v_offset,
                    @horario_verano = @v_verano;
                SET @v_actualizadas += 1;
            END
            ELSE
                SET @v_sin_cambios += 1;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SET @v_mensaje = ERROR_MESSAGE();
            EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, N'TimeZoneId', @v_zona, @v_mensaje;
            SET @v_con_error += 1;
        END CATCH
    END

    DECLARE @v_filas_ok INT = @v_insertadas + @v_actualizadas + @v_sin_cambios;
    EXEC soporte.usp_Importacion_Finalizar @id_importacion, @v_leidas,
         @filas_ok = @v_filas_ok,
         @filas_error = @v_con_error;

    SELECT @id_importacion AS id_importacion,
           @v_leidas AS filas_leidas,
           @v_insertadas AS insertadas,
           @v_actualizadas AS actualizadas,
           @v_sin_cambios AS sin_cambios,
           0 AS omitidas,
           @v_con_error AS con_error;
END;
GO

-- ============================================================================
-- 3. CIUDADES (GeoNames cities15000.txt)
--    https://download.geonames.org/export/dump/cities15000.zip
--    El archivo se publica comprimido: se descomprime sin modificarlo y se
--    importa el .txt. Se cargan las capitales (código PPLC) y las ciudades con
--    al menos @poblacion_minima habitantes. Clave natural: país + nombre.
--    Si un mismo país tiene dos ciudades homónimas, se conserva la más poblada.
-- ============================================================================
CREATE OR ALTER PROCEDURE soporte.usp_Importar_CiudadesTxt
    @archivo NVARCHAR(260),
    @poblacion_minima INT = 100000,
    @id_importacion INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @c_sp NVARCHAR(60) = N'soporte.usp_Importar_CiudadesTxt';
    DECLARE @c_fuente NVARCHAR(60) = N'GeoNames cities15000';
    DECLARE @v_errores NVARCHAR(2000) = soporte.fn_ValidarRutaArchivo(@archivo, N'.txt');
    DECLARE @v_mensaje NVARCHAR(2048);
    DECLARE @v_leidas INT = 0;
    DECLARE @v_insertadas INT = 0;
    DECLARE @v_actualizadas INT = 0;
    DECLARE @v_sin_cambios INT = 0;
    DECLARE @v_con_error INT = 0;
    DECLARE @v_id_min INT;

    IF @poblacion_minima IS NULL OR @poblacion_minima < 0
        SET @v_errores += N'poblacion_minima debe ser mayor o igual a 0; ';
    IF @@TRANCOUNT > 0
        SET @v_errores += N'no puede ejecutarse dentro de una transaccion; ';

    IF @v_errores <> N''
    BEGIN
        SET @v_mensaje = CONCAT(@c_sp, N': ', @v_errores);
        THROW 50001, @v_mensaje, 1;
    END

    EXEC soporte.usp_Importacion_Iniciar
        @fuente = @c_fuente, @archivo = @archivo, @formato = 'TXT',
        @id_importacion = @id_importacion OUTPUT;

    BEGIN TRY
        DELETE FROM soporte.stg_ciudad_txt;
        EXEC soporte.usp_Archivo_CargarDelimitado
            @archivo = @archivo,
            @vista_destino = N'soporte.vw_stg_ciudad_txt_carga',
            @es_csv = 0,
            @primera_fila = 1,
            @filas_cargadas = @v_leidas OUTPUT;
    END TRY
    BEGIN CATCH
        SET @v_mensaje = ERROR_MESSAGE();
        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, 1, N'(archivo)', @archivo, @v_mensaje;
        EXEC soporte.usp_Importacion_Finalizar @id_importacion, 0, 0, 0, @error_general = 1, @mostrar_resumen = 0;
        THROW;
    END CATCH

    SELECT @v_id_min = MIN(s.id_stg) FROM soporte.stg_ciudad_txt AS s;

    CREATE TABLE #ciudad
    (
        nro_fila      INT            NOT NULL PRIMARY KEY,
        nombre        NVARCHAR(200) COLLATE DATABASE_DEFAULT  NULL,
        cod_pais      NVARCHAR(10) COLLATE DATABASE_DEFAULT   NULL,
        zona_horaria  NVARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
        texto_pob     NVARCHAR(30) COLLATE DATABASE_DEFAULT   NULL,
        poblacion     BIGINT         NULL,
        es_capital    BIT            NOT NULL,
        id_pais       SMALLINT       NULL,
        id_huso       SMALLINT       NULL,
        seleccionada  BIT            NOT NULL DEFAULT 0,
        error         NVARCHAR(1000) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #ciudad (nro_fila, nombre, cod_pais, zona_horaria, texto_pob, poblacion, es_capital)
    SELECT
        s.id_stg - @v_id_min + 1,
        soporte.fn_Limpiar(s.nombre),
        UPPER(soporte.fn_Limpiar(s.cod_pais)),
        soporte.fn_Limpiar(s.zona_horaria),
        soporte.fn_Limpiar(s.poblacion),
        TRY_CONVERT(BIGINT, soporte.fn_Limpiar(s.poblacion)),
        CASE WHEN soporte.fn_Limpiar(s.codigo_tipo) = N'PPLC' THEN 1 ELSE 0 END
    FROM soporte.stg_ciudad_txt AS s;

    -- Filas que interesan: capitales y ciudades grandes (las demás se omiten).
    UPDATE #ciudad
    SET seleccionada = 1
    WHERE es_capital = 1 OR poblacion >= @poblacion_minima OR poblacion IS NULL;

    UPDATE c
    SET id_pais = soporte.fn_BuscarPais('ISO2', c.cod_pais)
    FROM #ciudad AS c
    WHERE c.seleccionada = 1;

    UPDATE c
    SET id_huso = h.id_huso
    FROM #ciudad AS c
    JOIN geo.huso_horario AS h ON h.zona_horaria = c.zona_horaria
    WHERE c.seleccionada = 1;

    UPDATE c
    SET error = NULLIF(CONCAT(
            CASE WHEN c.nombre IS NULL THEN N'nombre vacio; ' END,
            CASE WHEN LEN(c.nombre) > 100 THEN N'nombre de mas de 100 caracteres; ' END,
            CASE WHEN c.poblacion IS NULL THEN CONCAT(N'poblacion no numerica (', ISNULL(c.texto_pob, N'vacia'), N'); ')
                 WHEN c.poblacion < 0 OR c.poblacion > 2147483647 THEN N'poblacion fuera de rango; ' END,
            CASE WHEN c.id_pais IS NULL THEN CONCAT(N'pais inexistente para el codigo ISO2 ', ISNULL(c.cod_pais, N'vacio'), N' (importe antes los paises); ') END,
            CASE WHEN c.id_huso IS NULL THEN CONCAT(N'huso horario inexistente: ', ISNULL(c.zona_horaria, N'vacio'), N' (importe antes los husos); ') END
        ), N'')
    FROM #ciudad AS c
    WHERE c.seleccionada = 1;

    -- Homónimas dentro del mismo país: queda la más poblada; el resto se omite.
    ;WITH orden AS
    (
        SELECT c.nro_fila,
               ROW_NUMBER() OVER (PARTITION BY c.id_pais, c.nombre ORDER BY c.poblacion DESC, c.nro_fila) AS rn
        FROM #ciudad AS c
        WHERE c.seleccionada = 1 AND c.error IS NULL
    )
    UPDATE c
    SET seleccionada = 0
    FROM #ciudad AS c
    JOIN orden AS o ON o.nro_fila = c.nro_fila
    WHERE o.rn > 1;

    DECLARE @v_fila INT = 0;
    DECLARE @v_texto NVARCHAR(1000);

    WHILE 1 = 1
    BEGIN
        SELECT TOP (1) @v_fila = c.nro_fila, @v_texto = c.error
        FROM #ciudad AS c
        WHERE c.seleccionada = 1 AND c.error IS NOT NULL AND c.nro_fila > @v_fila
        ORDER BY c.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, NULL, NULL, @v_texto;
        SET @v_con_error += 1;
    END

    DECLARE @v_nombre NVARCHAR(100), @v_poblacion INT, @v_id_pais SMALLINT, @v_id_huso SMALLINT;
    DECLARE @v_id_ciudad INT, @v_poblacion_act INT, @v_huso_act SMALLINT;

    SET @v_fila = 0;
    WHILE 1 = 1
    BEGIN
        SELECT TOP (1)
            @v_fila = c.nro_fila,
            @v_nombre = c.nombre,
            @v_poblacion = CONVERT(INT, c.poblacion),
            @v_id_pais = c.id_pais,
            @v_id_huso = c.id_huso
        FROM #ciudad AS c
        WHERE c.seleccionada = 1 AND c.error IS NULL AND c.nro_fila > @v_fila
        ORDER BY c.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        SET @v_id_ciudad = NULL;
        SELECT @v_id_ciudad = g.id_ciudad, @v_poblacion_act = g.poblacion, @v_huso_act = g.id_huso
        FROM geo.ciudad AS g
        WHERE g.id_pais = @v_id_pais AND g.nombre = @v_nombre;

        BEGIN TRY
            IF @v_id_ciudad IS NULL
            BEGIN
                EXEC geo.usp_Ciudad_Insertar
                    @nombre = @v_nombre,
                    @poblacion = @v_poblacion,
                    @id_pais = @v_id_pais,
                    @id_huso = @v_id_huso,
                    @id_ciudad = @v_id_ciudad OUTPUT;
                SET @v_insertadas += 1;
            END
            ELSE IF @v_poblacion_act <> @v_poblacion OR @v_huso_act <> @v_id_huso
            BEGIN
                EXEC geo.usp_Ciudad_Modificar
                    @id_ciudad = @v_id_ciudad,
                    @nombre = @v_nombre,
                    @poblacion = @v_poblacion,
                    @id_pais = @v_id_pais,
                    @id_huso = @v_id_huso;
                SET @v_actualizadas += 1;
            END
            ELSE
                SET @v_sin_cambios += 1;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SET @v_mensaje = ERROR_MESSAGE();
            EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, N'name', @v_nombre, @v_mensaje;
            SET @v_con_error += 1;
        END CATCH
    END

    DECLARE @v_filas_ok INT = @v_insertadas + @v_actualizadas + @v_sin_cambios;
    EXEC soporte.usp_Importacion_Finalizar @id_importacion, @v_leidas,
         @filas_ok = @v_filas_ok,
         @filas_error = @v_con_error;

    SELECT @id_importacion AS id_importacion,
           @v_leidas AS filas_leidas,
           @v_insertadas AS insertadas,
           @v_actualizadas AS actualizadas,
           @v_sin_cambios AS sin_cambios,
           @v_leidas - @v_insertadas - @v_actualizadas - @v_sin_cambios - @v_con_error AS omitidas,
           @v_con_error AS con_error;
END;
GO

-- ============================================================================
-- 4. SEDES DEL TORNEO (openfootball worldcup.stadiums.json)
--    https://github.com/openfootball/worldcup.json  (2026/worldcup.stadiums.json)
--    Clave natural: nombre del estadio.
--    La ciudad de la sede es la que figura entre paréntesis ("Dallas
--    (Arlington)" -> Arlington); si no existe en geo.ciudad se crea con
--    población 0 y con el huso de la ciudad más poblada del mismo país cuyo
--    desplazamiento en julio coincide con el informado ("UTC-5").
--    Las coordenadas se convierten de grados/minutos/segundos a decimales.
-- ============================================================================
CREATE OR ALTER PROCEDURE soporte.usp_Importar_SedesJson
    @archivo NVARCHAR(260),
    @id_importacion INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @c_sp NVARCHAR(60) = N'soporte.usp_Importar_SedesJson';
    DECLARE @c_fuente NVARCHAR(60) = N'openfootball worldcup.stadiums.json';
    DECLARE @v_errores NVARCHAR(2000) = soporte.fn_ValidarRutaArchivo(@archivo, N'.json');
    DECLARE @v_mensaje NVARCHAR(2048);
    DECLARE @v_json NVARCHAR(MAX);
    DECLARE @v_leidas INT = 0;
    DECLARE @v_insertadas INT = 0;
    DECLARE @v_actualizadas INT = 0;
    DECLARE @v_sin_cambios INT = 0;
    DECLARE @v_con_error INT = 0;

    IF @@TRANCOUNT > 0
        SET @v_errores += N'no puede ejecutarse dentro de una transaccion; ';

    IF @v_errores <> N''
    BEGIN
        SET @v_mensaje = CONCAT(@c_sp, N': ', @v_errores);
        THROW 50001, @v_mensaje, 1;
    END

    EXEC soporte.usp_Importacion_Iniciar
        @fuente = @c_fuente, @archivo = @archivo, @formato = 'JSON',
        @id_importacion = @id_importacion OUTPUT;

    BEGIN TRY
        EXEC soporte.usp_Archivo_Leer @archivo = @archivo, @contenido = @v_json OUTPUT;

        IF ISJSON(@v_json) <> 1
            THROW 50002, N'el archivo no contiene un JSON valido', 1;
        IF JSON_QUERY(@v_json, '$.stadiums') IS NULL
            THROW 50002, N'el JSON no tiene el arreglo "stadiums"', 1;

        DELETE FROM soporte.stg_sede_json;
        INSERT INTO soporte.stg_sede_json (nro_fila, estadio, ciudad_texto, cod_pais, zona_texto, capacidad, coordenadas)
        SELECT
            CONVERT(INT, a.[key]) + 1,
            d.estadio, d.ciudad, d.cc, d.zona, d.capacidad, d.coords
        FROM OPENJSON(@v_json, '$.stadiums') AS a
        CROSS APPLY OPENJSON(a.value)
        WITH
        (
            estadio   NVARCHAR(200) '$.name',
            ciudad    NVARCHAR(200) '$.city',
            cc        NVARCHAR(10)  '$.cc',
            zona      NVARCHAR(20)  '$.timezone',
            capacidad NVARCHAR(30)  '$.capacity',
            coords    NVARCHAR(100) '$.coords'
        ) AS d;

        SET @v_leidas = @@ROWCOUNT;
    END TRY
    BEGIN CATCH
        SET @v_mensaje = ERROR_MESSAGE();
        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, 1, N'(archivo)', @archivo, @v_mensaje;
        EXEC soporte.usp_Importacion_Finalizar @id_importacion, 0, 0, 0, @error_general = 1, @mostrar_resumen = 0;
        THROW;
    END CATCH

    CREATE TABLE #sede
    (
        nro_fila      INT            NOT NULL PRIMARY KEY,
        estadio       NVARCHAR(200) COLLATE DATABASE_DEFAULT  NULL,
        ciudad_texto  NVARCHAR(200) COLLATE DATABASE_DEFAULT  NULL,
        ciudad        NVARCHAR(200) COLLATE DATABASE_DEFAULT  NULL,
        cod_pais      NVARCHAR(10) COLLATE DATABASE_DEFAULT   NULL,
        id_pais       SMALLINT       NULL,
        offset_julio  INT            NULL,
        capacidad     INT            NULL,
        coordenadas   NVARCHAR(100) COLLATE DATABASE_DEFAULT  NULL,
        latitud       DECIMAL(9,6)   NULL,
        longitud      DECIMAL(9,6)   NULL,
        error         NVARCHAR(1000) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #sede (nro_fila, estadio, ciudad_texto, cod_pais, capacidad, coordenadas, offset_julio)
    SELECT
        s.nro_fila,
        soporte.fn_Limpiar(s.estadio),
        soporte.fn_Limpiar(s.ciudad_texto),
        UPPER(soporte.fn_Limpiar(s.cod_pais)),
        TRY_CONVERT(INT, soporte.fn_Limpiar(s.capacidad)),
        soporte.fn_Limpiar(s.coordenadas),
        CASE WHEN soporte.fn_Limpiar(s.zona_texto) = N'UTC' THEN 0
             WHEN soporte.fn_Limpiar(s.zona_texto) LIKE N'UTC[+-]%'
             THEN TRY_CONVERT(INT, SUBSTRING(soporte.fn_Limpiar(s.zona_texto), 4, 10)) * 60 END
    FROM soporte.stg_sede_json AS s;

    -- Ciudad: texto entre paréntesis, o el texto completo si no hay paréntesis.
    UPDATE x
    SET ciudad = CASE
                    WHEN CHARINDEX(N'(', x.ciudad_texto) > 0 AND CHARINDEX(N')', x.ciudad_texto) > CHARINDEX(N'(', x.ciudad_texto)
                    THEN soporte.fn_Limpiar(SUBSTRING(x.ciudad_texto,
                                                      CHARINDEX(N'(', x.ciudad_texto) + 1,
                                                      CHARINDEX(N')', x.ciudad_texto) - CHARINDEX(N'(', x.ciudad_texto) - 1))
                    ELSE x.ciudad_texto
                 END,
        id_pais = soporte.fn_BuscarPais('ISO2', x.cod_pais),
        latitud = soporte.fn_CoordenadaADecimal(LEFT(x.coordenadas, CHARINDEX(N' ', x.coordenadas + N' ') - 1)),
        longitud = soporte.fn_CoordenadaADecimal(LTRIM(SUBSTRING(x.coordenadas, CHARINDEX(N' ', x.coordenadas + N' ') + 1, 100)))
    FROM #sede AS x;

    UPDATE x
    SET error = NULLIF(CONCAT(
            CASE WHEN x.estadio IS NULL THEN N'estadio sin nombre; ' END,
            CASE WHEN LEN(x.estadio) > 100 THEN N'nombre de estadio de mas de 100 caracteres; ' END,
            CASE WHEN x.ciudad IS NULL THEN N'ciudad vacia; ' END,
            CASE WHEN x.id_pais IS NULL THEN CONCAT(N'pais inexistente para el codigo ', ISNULL(x.cod_pais, N'vacio'), N'; ') END,
            CASE WHEN x.capacidad IS NULL OR x.capacidad <= 0 THEN N'capacidad invalida; ' END,
            CASE WHEN x.offset_julio IS NULL THEN N'huso horario con formato invalido (se espera UTC-5); ' END,
            CASE WHEN x.coordenadas IS NOT NULL AND (x.latitud IS NULL OR x.longitud IS NULL)
                 THEN CONCAT(N'coordenadas con formato invalido (', x.coordenadas, N'); ') END,
            CASE WHEN x.latitud NOT BETWEEN -90 AND 90 THEN N'latitud fuera de rango; ' END,
            CASE WHEN EXISTS (SELECT 1 FROM #sede AS d WHERE d.estadio = x.estadio AND d.nro_fila < x.nro_fila)
                 THEN N'estadio repetido en el archivo; ' END
        ), N'')
    FROM #sede AS x;

    DECLARE @v_fila INT = 0;
    DECLARE @v_texto NVARCHAR(1000);

    WHILE 1 = 1
    BEGIN
        SELECT TOP (1) @v_fila = x.nro_fila, @v_texto = x.error
        FROM #sede AS x
        WHERE x.error IS NOT NULL AND x.nro_fila > @v_fila
        ORDER BY x.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, NULL, NULL, @v_texto;
        SET @v_con_error += 1;
    END

    DECLARE @v_estadio NVARCHAR(100), @v_ciudad NVARCHAR(100), @v_id_pais SMALLINT, @v_offset INT;
    DECLARE @v_capacidad INT, @v_latitud DECIMAL(9,6), @v_longitud DECIMAL(9,6);
    DECLARE @v_id_ciudad INT, @v_id_huso SMALLINT, @v_id_sede INT;
    DECLARE @v_cap_act INT, @v_lat_act DECIMAL(9,6), @v_lon_act DECIMAL(9,6), @v_ciudad_act INT, @v_dir_act NVARCHAR(200);

    SET @v_fila = 0;
    WHILE 1 = 1
    BEGIN
        SELECT TOP (1)
            @v_fila = x.nro_fila,
            @v_estadio = x.estadio,
            @v_ciudad = LEFT(x.ciudad, 100),
            @v_id_pais = x.id_pais,
            @v_offset = x.offset_julio,
            @v_capacidad = x.capacidad,
            @v_latitud = x.latitud,
            @v_longitud = x.longitud
        FROM #sede AS x
        WHERE x.error IS NULL AND x.nro_fila > @v_fila
        ORDER BY x.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        BEGIN TRY
            BEGIN TRANSACTION;

            -- Ciudad de la sede
            SET @v_id_ciudad = NULL;
            SELECT @v_id_ciudad = c.id_ciudad
            FROM geo.ciudad AS c
            WHERE c.id_pais = @v_id_pais AND c.nombre = @v_ciudad;

            IF @v_id_ciudad IS NULL
            BEGIN
                SET @v_id_huso = NULL;
                SELECT TOP (1) @v_id_huso = c.id_huso
                FROM geo.ciudad AS c
                JOIN geo.huso_horario AS h ON h.id_huso = c.id_huso
                WHERE c.id_pais = @v_id_pais
                  AND h.offset_utc + 60 * h.horario_verano = @v_offset
                ORDER BY c.poblacion DESC, c.id_ciudad;

                IF @v_id_huso IS NULL
                BEGIN
                    SET @v_mensaje = CONCAT(N'no existe la ciudad ', @v_ciudad,
                                            N' y no hay otra ciudad del pais con el mismo huso para deducirlo (importe antes ciudades y husos)');
                    THROW 50003, @v_mensaje, 1;
                END

                EXEC geo.usp_Ciudad_Insertar
                    @nombre = @v_ciudad,
                    @poblacion = 0,
                    @id_pais = @v_id_pais,
                    @id_huso = @v_id_huso,
                    @id_ciudad = @v_id_ciudad OUTPUT;
            END

            -- Sede
            SET @v_id_sede = NULL;
            SELECT @v_id_sede = s.id_sede, @v_cap_act = s.capacidad, @v_lat_act = s.latitud,
                   @v_lon_act = s.longitud, @v_ciudad_act = s.id_ciudad, @v_dir_act = s.direccion
            FROM torneo.sede AS s
            WHERE s.nombre_estadio = @v_estadio;

            IF @v_id_sede IS NULL
            BEGIN
                EXEC torneo.usp_Sede_Insertar
                    @nombre_estadio = @v_estadio,
                    @capacidad = @v_capacidad,
                    @direccion = NULL,
                    @latitud = @v_latitud,
                    @longitud = @v_longitud,
                    @id_ciudad = @v_id_ciudad,
                    @id_sede = @v_id_sede OUTPUT;
                SET @v_insertadas += 1;
            END
            ELSE IF @v_cap_act <> @v_capacidad
                 OR ISNULL(@v_lat_act, 999) <> ISNULL(@v_latitud, 999)
                 OR ISNULL(@v_lon_act, 999) <> ISNULL(@v_longitud, 999)
                 OR @v_ciudad_act <> @v_id_ciudad
            BEGIN
                EXEC torneo.usp_Sede_Modificar
                    @id_sede = @v_id_sede,
                    @nombre_estadio = @v_estadio,
                    @capacidad = @v_capacidad,
                    @direccion = @v_dir_act,
                    @latitud = @v_latitud,
                    @longitud = @v_longitud,
                    @id_ciudad = @v_id_ciudad;
                SET @v_actualizadas += 1;
            END
            ELSE
                SET @v_sin_cambios += 1;

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SET @v_mensaje = ERROR_MESSAGE();
            EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, N'name', @v_estadio, @v_mensaje;
            SET @v_con_error += 1;
        END CATCH
    END

    DECLARE @v_filas_ok INT = @v_insertadas + @v_actualizadas + @v_sin_cambios;
    EXEC soporte.usp_Importacion_Finalizar @id_importacion, @v_leidas,
         @filas_ok = @v_filas_ok,
         @filas_error = @v_con_error;

    SELECT @id_importacion AS id_importacion,
           @v_leidas AS filas_leidas,
           @v_insertadas AS insertadas,
           @v_actualizadas AS actualizadas,
           @v_sin_cambios AS sin_cambios,
           0 AS omitidas,
           @v_con_error AS con_error;
END;
GO

-- ============================================================================
-- 5. SELECCIONES (openfootball worldcup.teams.json)
--    https://github.com/openfootball/worldcup.json  (2026/worldcup.teams.json)
--    Clave natural de la selección: el país (una selección por país).
--    El país se busca por código FIFA y, si no, por nombre (equivalencias).
--    Las asociaciones FIFA sin código ISO propio (Inglaterra, Escocia) se
--    crean como país usando el código FIFA también como código de 3 letras.
--    Se corrige la confederación del país con el dato oficial del torneo.
-- ============================================================================
CREATE OR ALTER PROCEDURE soporte.usp_Importar_SeleccionesJson
    @archivo NVARCHAR(260),
    @anfitriones NVARCHAR(100) = N'MEX,USA,CAN',     -- códigos FIFA de los países organizadores
    @id_importacion INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @c_sp NVARCHAR(60) = N'soporte.usp_Importar_SeleccionesJson';
    DECLARE @c_fuente NVARCHAR(60) = N'openfootball worldcup.teams.json';
    DECLARE @v_errores NVARCHAR(2000) = soporte.fn_ValidarRutaArchivo(@archivo, N'.json');
    DECLARE @v_mensaje NVARCHAR(2048);
    DECLARE @v_json NVARCHAR(MAX);
    DECLARE @v_leidas INT = 0;
    DECLARE @v_insertadas INT = 0;
    DECLARE @v_actualizadas INT = 0;
    DECLARE @v_sin_cambios INT = 0;
    DECLARE @v_con_error INT = 0;

    IF @@TRANCOUNT > 0
        SET @v_errores += N'no puede ejecutarse dentro de una transaccion; ';

    IF @v_errores <> N''
    BEGIN
        SET @v_mensaje = CONCAT(@c_sp, N': ', @v_errores);
        THROW 50001, @v_mensaje, 1;
    END

    EXEC soporte.usp_Importacion_Iniciar
        @fuente = @c_fuente, @archivo = @archivo, @formato = 'JSON',
        @id_importacion = @id_importacion OUTPUT;

    BEGIN TRY
        EXEC soporte.usp_Archivo_Leer @archivo = @archivo, @contenido = @v_json OUTPUT;

        IF ISJSON(@v_json) <> 1
            THROW 50002, N'el archivo no contiene un JSON valido', 1;
        IF LEFT(LTRIM(@v_json), 1) <> N'['
            THROW 50002, N'se esperaba un arreglo JSON de selecciones', 1;

        DELETE FROM soporte.stg_seleccion_json;
        INSERT INTO soporte.stg_seleccion_json (nro_fila, nombre, nombre_normalizado, cod_fifa, grupo, confederacion)
        SELECT
            CONVERT(INT, a.[key]) + 1,
            d.nombre, d.nombre_normalizado, d.cod_fifa, d.grupo, d.confederacion
        FROM OPENJSON(@v_json) AS a
        CROSS APPLY OPENJSON(a.value)
        WITH
        (
            nombre             NVARCHAR(150) '$.name',
            nombre_normalizado NVARCHAR(150) '$.name_normalised',
            cod_fifa           NVARCHAR(10)  '$.fifa_code',
            grupo              NVARCHAR(10)  '$.group',
            confederacion      NVARCHAR(20)  '$.confed'
        ) AS d;

        SET @v_leidas = @@ROWCOUNT;
    END TRY
    BEGIN CATCH
        SET @v_mensaje = ERROR_MESSAGE();
        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, 1, N'(archivo)', @archivo, @v_mensaje;
        EXEC soporte.usp_Importacion_Finalizar @id_importacion, 0, 0, 0, @error_general = 1, @mostrar_resumen = 0;
        THROW;
    END CATCH

    CREATE TABLE #sel
    (
        nro_fila           INT            NOT NULL PRIMARY KEY,
        nombre             NVARCHAR(150) COLLATE DATABASE_DEFAULT  NULL,
        nombre_normalizado NVARCHAR(150) COLLATE DATABASE_DEFAULT  NULL,
        cod_fifa           NVARCHAR(10) COLLATE DATABASE_DEFAULT   NULL,
        grupo              NVARCHAR(10) COLLATE DATABASE_DEFAULT   NULL,
        sigla_confed       NVARCHAR(20) COLLATE DATABASE_DEFAULT   NULL,
        id_confed          TINYINT        NULL,
        error              NVARCHAR(1000) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #sel (nro_fila, nombre, nombre_normalizado, cod_fifa, grupo, sigla_confed)
    SELECT s.nro_fila,
           soporte.fn_Limpiar(s.nombre),
           soporte.fn_Limpiar(s.nombre_normalizado),
           UPPER(soporte.fn_Limpiar(s.cod_fifa)),
           UPPER(soporte.fn_Limpiar(s.grupo)),
           UPPER(soporte.fn_Limpiar(s.confederacion))
    FROM soporte.stg_seleccion_json AS s;

    UPDATE x
    SET id_confed = c.id_confederacion
    FROM #sel AS x
    JOIN geo.confederacion AS c ON c.sigla = x.sigla_confed;

    UPDATE x
    SET error = NULLIF(CONCAT(
            CASE WHEN x.nombre IS NULL THEN N'seleccion sin nombre; ' END,
            CASE WHEN x.cod_fifa IS NULL OR x.cod_fifa NOT LIKE N'[A-Z][A-Z][A-Z]'
                 THEN CONCAT(N'codigo FIFA invalido (', ISNULL(x.cod_fifa, N'vacio'), N'); ') END,
            CASE WHEN NOT EXISTS (SELECT 1 FROM torneo.grupo AS g WHERE g.id_letra = x.grupo)
                 THEN CONCAT(N'grupo inexistente (', ISNULL(x.grupo, N'vacio'), N'); ') END,
            CASE WHEN x.id_confed IS NULL THEN CONCAT(N'confederacion inexistente (', ISNULL(x.sigla_confed, N'vacia'), N'); ') END,
            CASE WHEN EXISTS (SELECT 1 FROM #sel AS d WHERE d.cod_fifa = x.cod_fifa AND d.nro_fila < x.nro_fila)
                 THEN N'codigo FIFA repetido en el archivo; ' END
        ), N'')
    FROM #sel AS x;

    DECLARE @v_fila INT = 0;
    DECLARE @v_texto NVARCHAR(1000);

    WHILE 1 = 1
    BEGIN
        SELECT TOP (1) @v_fila = x.nro_fila, @v_texto = x.error
        FROM #sel AS x
        WHERE x.error IS NOT NULL AND x.nro_fila > @v_fila
        ORDER BY x.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, NULL, NULL, @v_texto;
        SET @v_con_error += 1;
    END

    DECLARE @v_nombre NVARCHAR(150), @v_nombre_norm NVARCHAR(150), @v_fifa CHAR(3), @v_grupo CHAR(1), @v_id_confed TINYINT;
    DECLARE @v_id_pais SMALLINT, @v_nombre_pais NVARCHAR(80), @v_iso3 CHAR(3), @v_fifa_act CHAR(3);
    DECLARE @v_gentilicio NVARCHAR(60), @v_confed_act TINYINT;
    DECLARE @v_id_seleccion INT, @v_grupo_act CHAR(1), @v_anfitrion_act BIT, @v_fecha_conf DATE;
    DECLARE @v_anfitrion BIT, @v_cambio BIT;

    SET @v_fila = 0;
    WHILE 1 = 1
    BEGIN
        SELECT TOP (1)
            @v_fila = x.nro_fila,
            @v_nombre = x.nombre,
            @v_nombre_norm = x.nombre_normalizado,
            @v_fifa = x.cod_fifa,
            @v_grupo = x.grupo,
            @v_id_confed = x.id_confed
        FROM #sel AS x
        WHERE x.error IS NULL AND x.nro_fila > @v_fila
        ORDER BY x.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        SET @v_anfitrion = CASE WHEN EXISTS (SELECT 1 FROM STRING_SPLIT(@anfitriones, N',') AS a
                                             WHERE UPPER(LTRIM(RTRIM(a.value))) = @v_fifa) THEN 1 ELSE 0 END;
        SET @v_cambio = 0;

        BEGIN TRY
            BEGIN TRANSACTION;

            -- País: por código FIFA, luego por nombre.
            SET @v_id_pais = NULL;
            SELECT @v_id_pais = p.id_pais FROM geo.pais AS p WHERE p.cod_fifa = @v_fifa;
            IF @v_id_pais IS NULL
                SET @v_id_pais = soporte.fn_BuscarPais('NOMBRE', @v_nombre);
            IF @v_id_pais IS NULL
                SET @v_id_pais = soporte.fn_BuscarPais('NOMBRE', @v_nombre_norm);

            IF @v_id_pais IS NULL
            BEGIN
                -- Asociación sin país ISO propio (Inglaterra, Escocia, etc.).
                IF EXISTS (SELECT 1 FROM geo.pais AS p WHERE p.cod_iso3 = @v_fifa)
                BEGIN
                    SET @v_mensaje = CONCAT(N'no se pudo identificar el pais de ', @v_nombre,
                                            N' y el codigo ', @v_fifa, N' ya pertenece a otro pais');
                    THROW 50003, @v_mensaje, 1;
                END

                SET @v_nombre_pais = LEFT(@v_nombre, 80);
                EXEC geo.usp_Pais_Insertar
                    @nombre = @v_nombre_pais,
                    @cod_iso3 = @v_fifa,
                    @cod_fifa = @v_fifa,
                    @gentilicio = NULL,
                    @id_confederacion = @v_id_confed,
                    @id_pais = @v_id_pais OUTPUT;
                SET @v_cambio = 1;
            END
            ELSE
            BEGIN
                SELECT @v_nombre_pais = p.nombre, @v_iso3 = p.cod_iso3, @v_fifa_act = p.cod_fifa,
                       @v_gentilicio = p.gentilicio, @v_confed_act = p.id_confederacion
                FROM geo.pais AS p
                WHERE p.id_pais = @v_id_pais;

                IF ISNULL(@v_fifa_act, '') <> @v_fifa OR @v_confed_act <> @v_id_confed
                BEGIN
                    EXEC geo.usp_Pais_Modificar
                        @id_pais = @v_id_pais,
                        @nombre = @v_nombre_pais,
                        @cod_iso3 = @v_iso3,
                        @cod_fifa = @v_fifa,
                        @gentilicio = @v_gentilicio,
                        @id_confederacion = @v_id_confed;
                    SET @v_cambio = 1;
                END
            END

            EXEC soporte.usp_EquivalenciaPais_Asegurar 'NOMBRE', @v_nombre, @v_id_pais, @c_fuente;
            EXEC soporte.usp_EquivalenciaPais_Asegurar 'NOMBRE', @v_nombre_norm, @v_id_pais, @c_fuente;

            -- Selección
            SET @v_id_seleccion = NULL;
            SELECT @v_id_seleccion = s.id_seleccion, @v_grupo_act = s.id_letra,
                   @v_anfitrion_act = s.es_anfitrion, @v_fecha_conf = s.fecha_confirmacion
            FROM torneo.seleccion AS s
            WHERE s.id_pais = @v_id_pais;

            IF @v_id_seleccion IS NULL
            BEGIN
                EXEC torneo.usp_Seleccion_Insertar
                    @id_letra = @v_grupo,
                    @id_pais = @v_id_pais,
                    @fecha_confirmacion = NULL,
                    @es_anfitrion = @v_anfitrion,
                    @id_seleccion = @v_id_seleccion OUTPUT;
                SET @v_insertadas += 1;
            END
            ELSE IF @v_grupo_act <> @v_grupo OR @v_anfitrion_act <> @v_anfitrion OR @v_cambio = 1
            BEGIN
                IF @v_grupo_act <> @v_grupo OR @v_anfitrion_act <> @v_anfitrion
                    EXEC torneo.usp_Seleccion_Modificar
                        @id_seleccion = @v_id_seleccion,
                        @id_letra = @v_grupo,
                        @id_pais = @v_id_pais,
                        @fecha_confirmacion = @v_fecha_conf,
                        @es_anfitrion = @v_anfitrion;
                SET @v_actualizadas += 1;
            END
            ELSE
                SET @v_sin_cambios += 1;

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SET @v_mensaje = ERROR_MESSAGE();
            EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, N'fifa_code', @v_fifa, @v_mensaje;
            SET @v_con_error += 1;
        END CATCH
    END

    DECLARE @v_filas_ok INT = @v_insertadas + @v_actualizadas + @v_sin_cambios;
    EXEC soporte.usp_Importacion_Finalizar @id_importacion, @v_leidas,
         @filas_ok = @v_filas_ok,
         @filas_error = @v_con_error;

    SELECT @id_importacion AS id_importacion,
           @v_leidas AS filas_leidas,
           @v_insertadas AS insertadas,
           @v_actualizadas AS actualizadas,
           @v_sin_cambios AS sin_cambios,
           0 AS omitidas,
           @v_con_error AS con_error;
END;
GO
