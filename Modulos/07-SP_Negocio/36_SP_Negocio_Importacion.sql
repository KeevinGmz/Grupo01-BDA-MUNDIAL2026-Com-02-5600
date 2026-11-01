/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Entrega 6. Completa el procedimiento de importación del fixture
          (esqueleto de la Entrega 5): lee el fixture oficial publicado por
          openfootball (worldcup.json), lo valida y aplica el upsert de los
          partidos con los SP de la Entrega 5 (torneo.usp_Negocio_RegistrarPartido
          y torneo.usp_Partido_Modificar), registrando cada error por fila.
===================================================================== */
USE Mundial2026;
GO

/*
   Fuente: https://github.com/openfootball/worldcup.json  (2026/worldcup.json)
   Cada partido trae: round, num (eliminatorias), date, time ("13:00 UTC-6",
   hora local de la sede), team1, team2, group (fase de grupos), ground
   (ciudad de la sede) y score.

   Cambio respecto del plan de la Entrega 5: el fixture se importa en JSON y
   no en CSV, porque es el único formato publicado que trae los 104 partidos
   con la sede y la hora local con su desplazamiento UTC. El CSV ya se usa en
   la importación de países (soporte.usp_Importar_PaisesCsv).

   Transformaciones:
   - Fase: "Matchday n" -> 1 (grupos), "Round of 32" -> 2, "Round of 16" -> 3,
     "Quarter-final" -> 4, "Semi-final" -> 5, "Match for third place" -> 6,
     "Final" -> 7.
   - Fecha y hora UTC = fecha y hora local - desplazamiento ("UTC-6" suma 6 h).
   - Selección: el nombre del equipo se traduce al país con las equivalencias
     que registró la importación de selecciones.
   - Sede: la ciudad de "ground" se toma entre paréntesis si los hay, igual que
     en la importación de sedes, y se busca la sede ubicada en esa ciudad.

   Upsert (clave natural del partido: fase + par de selecciones):
   - Si ya existe un partido de la misma fase entre las mismas selecciones
     (en cualquier condición local/visitante) y cambió la fecha o la sede, se
     actualiza con torneo.usp_Partido_Modificar; si no cambió nada, no se toca.
   - Si no existe, se registra con torneo.usp_Negocio_RegistrarPartido, que
     valida la disponibilidad de la sede, los grupos y los cruces.
   El resultado (score) no se importa: en el modelo el marcador se deriva de
   los goles registrados (juego.gol), que requieren las alineaciones.
*/
CREATE OR ALTER PROCEDURE soporte.usp_Negocio_ImportarFixture
    @archivo NVARCHAR(260),
    @id_importacion INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @c_sp NVARCHAR(60) = N'soporte.usp_Negocio_ImportarFixture';
    DECLARE @c_fuente NVARCHAR(60) = N'openfootball worldcup.json';
    DECLARE @v_errores NVARCHAR(2000) = soporte.fn_ValidarRutaArchivo(@archivo, N'.json');
    DECLARE @v_mensaje NVARCHAR(2048);
    DECLARE @v_json NVARCHAR(MAX);
    DECLARE @v_leidas INT = 0;
    DECLARE @v_insertadas INT = 0;
    DECLARE @v_actualizadas INT = 0;
    DECLARE @v_sin_cambios INT = 0;
    DECLARE @v_con_error INT = 0;

    SET @id_importacion = NULL;

    IF @@TRANCOUNT > 0
        SET @v_errores += N'no puede ejecutarse dentro de una transaccion; ';

    IF @v_errores <> N''
    BEGIN
        SET @v_mensaje = LEFT(CONCAT(@c_sp, N': ', @v_errores), 2048);
        THROW 50001, @v_mensaje, 1;
    END

    EXEC soporte.usp_Importacion_Iniciar
        @fuente = @c_fuente, @archivo = @archivo, @formato = 'JSON',
        @id_importacion = @id_importacion OUTPUT;

    ---------------------------------------------------------------------------
    -- 1. Lectura del archivo y carga de la tabla de paso
    ---------------------------------------------------------------------------
    BEGIN TRY
        EXEC soporte.usp_Archivo_Leer @archivo = @archivo, @contenido = @v_json OUTPUT;

        IF ISJSON(@v_json) <> 1
            THROW 50002, N'el archivo no contiene un JSON valido', 1;
        IF JSON_QUERY(@v_json, '$.matches') IS NULL
            THROW 50002, N'el JSON no tiene el arreglo "matches"', 1;

        DELETE FROM soporte.stg_partido_json;
        INSERT INTO soporte.stg_partido_json (nro_fila, ronda, numero, fecha, hora, equipo1, equipo2, grupo, sede_texto)
        SELECT CONVERT(INT, a.[key]) + 1,
               d.ronda, d.numero, d.fecha, d.hora, d.equipo1, d.equipo2, d.grupo, d.sede
        FROM OPENJSON(@v_json, '$.matches') AS a
        CROSS APPLY OPENJSON(a.value)
        WITH
        (
            ronda   NVARCHAR(60)  '$.round',
            numero  NVARCHAR(10)  '$.num',
            fecha   NVARCHAR(20)  '$.date',
            hora    NVARCHAR(30)  '$.time',
            equipo1 NVARCHAR(150) '$.team1',
            equipo2 NVARCHAR(150) '$.team2',
            grupo   NVARCHAR(30)  '$.group',
            sede    NVARCHAR(200) '$.ground'
        ) AS d;

        SET @v_leidas = @@ROWCOUNT;
    END TRY
    BEGIN CATCH
        SET @v_mensaje = ERROR_MESSAGE();
        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, 1, N'(archivo)', @archivo, @v_mensaje;
        EXEC soporte.usp_Importacion_Finalizar @id_importacion, 0, 0, 0, @error_general = 1, @mostrar_resumen = 0;
        THROW;
    END CATCH

    ---------------------------------------------------------------------------
    -- 2. Transformación y validación por conjuntos
    ---------------------------------------------------------------------------
    CREATE TABLE #partido
    (
        nro_fila      INT            NOT NULL PRIMARY KEY,
        ronda         NVARCHAR(60) COLLATE DATABASE_DEFAULT   NULL,
        nro_fase      TINYINT        NULL,
        fecha_texto   NVARCHAR(20) COLLATE DATABASE_DEFAULT   NULL,
        hora_texto    NVARCHAR(30) COLLATE DATABASE_DEFAULT   NULL,
        fecha_local   DATETIME2(0)   NULL,
        offset_min    INT            NULL,
        fecha_utc     DATETIME2(0)   NULL,
        equipo1       NVARCHAR(150) COLLATE DATABASE_DEFAULT  NULL,
        equipo2       NVARCHAR(150) COLLATE DATABASE_DEFAULT  NULL,
        grupo         CHAR(1) COLLATE DATABASE_DEFAULT        NULL,
        sede_texto    NVARCHAR(200) COLLATE DATABASE_DEFAULT  NULL,
        ciudad        NVARCHAR(200) COLLATE DATABASE_DEFAULT  NULL,
        id_sede       INT            NULL,
        cant_sedes    INT            NULL,
        id_sel1       INT            NULL,
        id_sel2       INT            NULL,
        grupo_sel1    CHAR(1) COLLATE DATABASE_DEFAULT        NULL,
        grupo_sel2    CHAR(1) COLLATE DATABASE_DEFAULT        NULL,
        error         NVARCHAR(1000) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #partido (nro_fila, ronda, fecha_texto, hora_texto, equipo1, equipo2, grupo, sede_texto)
    SELECT s.nro_fila,
           soporte.fn_Limpiar(s.ronda),
           soporte.fn_Limpiar(s.fecha),
           soporte.fn_Limpiar(s.hora),
           soporte.fn_Limpiar(s.equipo1),
           soporte.fn_Limpiar(s.equipo2),
           CASE WHEN soporte.fn_Limpiar(s.grupo) LIKE N'Group [A-Z]' THEN RIGHT(soporte.fn_Limpiar(s.grupo), 1) END,
           soporte.fn_Limpiar(s.sede_texto)
    FROM soporte.stg_partido_json AS s;

    UPDATE p
    SET nro_fase = CASE
                       WHEN p.ronda LIKE N'Matchday%' THEN 1
                       WHEN p.ronda = N'Round of 32' THEN 2
                       WHEN p.ronda = N'Round of 16' THEN 3
                       WHEN p.ronda = N'Quarter-final' THEN 4
                       WHEN p.ronda = N'Semi-final' THEN 5
                       WHEN p.ronda = N'Match for third place' THEN 6
                       WHEN p.ronda = N'Final' THEN 7
                   END,
        -- "13:00 UTC-6": hora local y desplazamiento respecto de UTC
        fecha_local = TRY_CONVERT(DATETIME2(0), CONCAT(p.fecha_texto, N'T', LEFT(p.hora_texto, CHARINDEX(N' ', p.hora_texto + N' ') - 1), N':00'), 126),
        offset_min = CASE
                         WHEN SUBSTRING(p.hora_texto, CHARINDEX(N' ', p.hora_texto + N' ') + 1, 30) = N'UTC' THEN 0
                         WHEN SUBSTRING(p.hora_texto, CHARINDEX(N' ', p.hora_texto + N' ') + 1, 30) LIKE N'UTC[+-]%'
                         THEN TRY_CONVERT(INT, SUBSTRING(p.hora_texto, CHARINDEX(N' ', p.hora_texto + N' ') + 4, 10)) * 60
                     END,
        ciudad = CASE
                     WHEN CHARINDEX(N'(', p.sede_texto) > 0 AND CHARINDEX(N')', p.sede_texto) > CHARINDEX(N'(', p.sede_texto)
                     THEN soporte.fn_Limpiar(SUBSTRING(p.sede_texto,
                                                       CHARINDEX(N'(', p.sede_texto) + 1,
                                                       CHARINDEX(N')', p.sede_texto) - CHARINDEX(N'(', p.sede_texto) - 1))
                     ELSE p.sede_texto
                 END
    FROM #partido AS p;

    UPDATE #partido
    SET fecha_utc = DATEADD(MINUTE, -offset_min, fecha_local)
    WHERE fecha_local IS NOT NULL AND offset_min IS NOT NULL;

    -- Sede: la ubicada en la ciudad indicada.
    UPDATE p
    SET id_sede = x.id_sede,
        cant_sedes = x.cantidad
    FROM #partido AS p
    CROSS APPLY
    (
        SELECT MIN(s.id_sede) AS id_sede, COUNT(*) AS cantidad
        FROM torneo.sede AS s
        JOIN geo.ciudad AS c ON c.id_ciudad = s.id_ciudad
        WHERE c.nombre = p.ciudad
    ) AS x;

    -- Selecciones: nombre -> país -> selección.
    UPDATE p
    SET id_sel1 = s1.id_seleccion, grupo_sel1 = s1.id_letra,
        id_sel2 = s2.id_seleccion, grupo_sel2 = s2.id_letra
    FROM #partido AS p
    LEFT JOIN torneo.seleccion AS s1 ON s1.id_pais = soporte.fn_BuscarPais('NOMBRE', p.equipo1)
    LEFT JOIN torneo.seleccion AS s2 ON s2.id_pais = soporte.fn_BuscarPais('NOMBRE', p.equipo2);

    UPDATE p
    SET error = NULLIF(CONCAT(
            CASE WHEN p.nro_fase IS NULL THEN CONCAT(N'ronda desconocida (', ISNULL(p.ronda, N'vacia'), N'); ') END,
            CASE WHEN p.fecha_local IS NULL THEN CONCAT(N'fecha u hora invalidas (', ISNULL(p.fecha_texto, N'?'), N' ', ISNULL(p.hora_texto, N'?'), N'); ') END,
            CASE WHEN p.fecha_local IS NOT NULL AND p.offset_min IS NULL
                 THEN CONCAT(N'desplazamiento horario invalido (', p.hora_texto, N'); ') END,
            CASE WHEN p.id_sel1 IS NULL THEN CONCAT(N'seleccion inexistente: ', ISNULL(p.equipo1, N'vacia'), N'; ') END,
            CASE WHEN p.id_sel2 IS NULL THEN CONCAT(N'seleccion inexistente: ', ISNULL(p.equipo2, N'vacia'), N'; ') END,
            CASE WHEN p.cant_sedes = 0 OR p.id_sede IS NULL THEN CONCAT(N'no hay sede registrada en la ciudad ', ISNULL(p.ciudad, N'vacia'), N'; ')
                 WHEN p.cant_sedes > 1 THEN CONCAT(N'hay mas de una sede en la ciudad ', p.ciudad, N'; ') END,
            CASE WHEN p.nro_fase = 1 AND p.grupo IS NOT NULL
                  AND (p.grupo_sel1 <> p.grupo OR p.grupo_sel2 <> p.grupo)
                 THEN CONCAT(N'las selecciones no pertenecen al grupo ', p.grupo, N'; ') END,
            CASE WHEN EXISTS (SELECT 1 FROM #partido AS d
                              WHERE d.nro_fila < p.nro_fila AND d.nro_fase = p.nro_fase
                                AND ((d.id_sel1 = p.id_sel1 AND d.id_sel2 = p.id_sel2) OR (d.id_sel1 = p.id_sel2 AND d.id_sel2 = p.id_sel1)))
                 THEN N'partido repetido en el archivo; ' END
        ), N'')
    FROM #partido AS p;

    DECLARE @v_fila INT = 0;
    DECLARE @v_texto NVARCHAR(1000);

    WHILE 1 = 1
    BEGIN
        SELECT TOP (1) @v_fila = p.nro_fila, @v_texto = p.error
        FROM #partido AS p
        WHERE p.error IS NOT NULL AND p.nro_fila > @v_fila
        ORDER BY p.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, NULL, NULL, @v_texto;
        SET @v_con_error += 1;
    END

    ---------------------------------------------------------------------------
    -- 3. Upsert fila por fila
    ---------------------------------------------------------------------------
    DECLARE @v_fase TINYINT, @v_fecha DATETIME2(0), @v_id_sede INT, @v_sel1 INT, @v_sel2 INT, @v_clave NVARCHAR(400);
    DECLARE @v_id_partido INT, @v_fecha_act DATETIME2(0), @v_sede_act INT, @v_estado_act VARCHAR(12);
    DECLARE @v_asistencia_act INT, @v_penales_act BIT;

    SET @v_fila = 0;
    WHILE 1 = 1
    BEGIN
        SELECT TOP (1)
            @v_fila = p.nro_fila,
            @v_fase = p.nro_fase,
            @v_fecha = p.fecha_utc,
            @v_id_sede = p.id_sede,
            @v_sel1 = p.id_sel1,
            @v_sel2 = p.id_sel2,
            @v_clave = CONCAT(p.equipo1, N' vs ', p.equipo2, N' (', p.fecha_texto, N')')
        FROM #partido AS p
        WHERE p.error IS NULL AND p.nro_fila > @v_fila
        ORDER BY p.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        -- Partido existente de la misma fase entre las mismas selecciones.
        SET @v_id_partido = NULL;
        SELECT TOP (1)
            @v_id_partido = pa.id_partido,
            @v_fecha_act = pa.fecha_hora_utc,
            @v_sede_act = pa.id_sede,
            @v_estado_act = pa.estado,
            @v_asistencia_act = pa.asistencia_publico,
            @v_penales_act = pa.definido_por_penales
        FROM torneo.partido AS pa
        JOIN torneo.equipo_en_partido AS e1 ON e1.id_partido = pa.id_partido AND e1.id_seleccion = @v_sel1
        JOIN torneo.equipo_en_partido AS e2 ON e2.id_partido = pa.id_partido AND e2.id_seleccion = @v_sel2
        WHERE pa.nro_fase = @v_fase
          AND pa.estado <> 'SUSPENDIDO'
        ORDER BY pa.id_partido;

        BEGIN TRY
            IF @v_id_partido IS NULL
            BEGIN
                EXEC torneo.usp_Negocio_RegistrarPartido
                    @fecha_hora_utc = @v_fecha,
                    @id_sede = @v_id_sede,
                    @nro_fase = @v_fase,
                    @id_seleccion_local = @v_sel1,
                    @id_seleccion_visitante = @v_sel2,
                    @esquema_local = NULL,
                    @esquema_visitante = NULL,
                    @id_partido = @v_id_partido OUTPUT;
                SET @v_insertadas += 1;
            END
            ELSE IF @v_fecha_act <> @v_fecha OR @v_sede_act <> @v_id_sede
            BEGIN
                EXEC torneo.usp_Partido_Modificar
                    @id_partido = @v_id_partido,
                    @fecha_hora_utc = @v_fecha,
                    @asistencia_publico = @v_asistencia_act,
                    @definido_por_penales = @v_penales_act,
                    @estado = @v_estado_act,
                    @id_sede = @v_id_sede,
                    @nro_fase = @v_fase;
                SET @v_actualizadas += 1;
            END
            ELSE
                SET @v_sin_cambios += 1;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SET @v_mensaje = ERROR_MESSAGE();
            EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, N'partido', @v_clave, @v_mensaje;
            SET @v_con_error += 1;
        END CATCH
    END

    ---------------------------------------------------------------------------
    -- 4. Cierre
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
           0 AS omitidas,
           @v_con_error AS con_error;
END;
GO
