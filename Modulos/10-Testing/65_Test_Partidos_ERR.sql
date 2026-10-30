/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Validar errores de los SP de negocio de partidos:V-04 selecciones distintas, V-03 disponibilidad de sede y asistencia no superior a la capacidad.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS DE ERROR: 65_Test_ERR_Partidos';
PRINT N'=====================================================================';
GO

/* =====================================================================
   CASO 1: misma seleccion como local y visitante
===================================================================== */
PRINT N'';
PRINT N'-> Test 1: registrar un partido con la misma seleccion en ambos lados';

DECLARE @v_id_seleccion INT;
DECLARE @v_id_sede INT;
DECLARE @v_nro_fase TINYINT;
DECLARE @v_id_partido INT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_partidos_antes INT;
DECLARE @v_partidos_despues INT;

IF OBJECT_ID(N'torneo.usp_Negocio_RegistrarPartido', N'P') IS NULL
BEGIN
    ;THROW 50001, N'65_Test_ERR_Partidos: no existe usp_Negocio_RegistrarPartido', 1;
END;

SELECT TOP (1) @v_id_seleccion = s.id_seleccion
FROM torneo.seleccion AS s
ORDER BY s.id_seleccion;

SELECT TOP (1) @v_id_sede = s.id_sede
FROM torneo.sede AS s
ORDER BY s.id_sede;

SELECT TOP (1) @v_nro_fase = f.nro_fase
FROM torneo.fase AS f
WHERE f.es_eliminacion = 0
ORDER BY f.nro_fase;

IF @v_id_seleccion IS NULL OR @v_id_sede IS NULL OR @v_nro_fase IS NULL
BEGIN
    ;THROW 50001, N'65_Test_ERR_Partidos: faltan seleccion, sede o fase para el Test 1', 1;
END;

SELECT @v_partidos_antes = COUNT(*) FROM torneo.partido;
BEGIN TRANSACTION;

BEGIN TRY
    EXEC torneo.usp_Negocio_RegistrarPartido
        @fecha_hora_utc = '2026-06-15T18:00:00',
        @id_sede = @v_id_sede,
        @nro_fase = @v_nro_fase,
        @id_seleccion_local = @v_id_seleccion,
        @id_seleccion_visitante = @v_id_seleccion,
        @esquema_local = '4-3-3',
        @esquema_visitante = '4-4-2',
        @id_partido = @v_id_partido OUTPUT;

    SET @v_error_numero = 0;
    SET @v_error_mensaje = N'El SP acepto selecciones identicas';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

SELECT @v_partidos_despues = COUNT(*) FROM torneo.partido;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

PRINT CONCAT(N'Error capturado ', @v_error_numero, N': ', @v_error_mensaje);

IF @v_error_numero IN (50001, 50003)
   AND (@v_error_mensaje LIKE N'%seleccion%distint%' OR @v_error_mensaje LIKE N'%local%visitante%igual%')
   AND @v_partidos_despues = @v_partidos_antes
    PRINT N'PASS Test 1: se rechazaron las selecciones identicas.';
ELSE
    PRINT N'FAIL Test 1: numero, mensaje o persistencia distintos de lo esperado.';
GO

/* =====================================================================
   CASO 2: misma sede en el mismo horario
===================================================================== */
PRINT N'';
PRINT N'-> Test 2: registrar dos partidos en la misma sede y horario';

DECLARE @v_id_sede INT;
DECLARE @v_nro_fase TINYINT;
DECLARE @v_sel_1 INT;
DECLARE @v_sel_2 INT;
DECLARE @v_sel_3 INT;
DECLARE @v_sel_4 INT;
DECLARE @v_id_partido_1 INT;
DECLARE @v_id_partido_2 INT;
DECLARE @v_fecha DATETIME2(0) = '2026-06-20T20:00:00';
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_cantidad_slot INT;

SELECT TOP (1) @v_id_sede = s.id_sede FROM torneo.sede AS s ORDER BY s.id_sede;
SELECT TOP (1) @v_nro_fase = f.nro_fase FROM torneo.fase AS f WHERE f.es_eliminacion = 0 ORDER BY f.nro_fase;

;WITH selecciones AS
(
    SELECT s.id_seleccion,
           ROW_NUMBER() OVER (ORDER BY s.id_seleccion) AS rn
    FROM torneo.seleccion AS s
    WHERE s.id_letra =
    (
        SELECT TOP (1) s2.id_letra
        FROM torneo.seleccion AS s2
        WHERE s2.id_letra IS NOT NULL
        GROUP BY s2.id_letra
        HAVING COUNT(*) >= 4
        ORDER BY s2.id_letra
    )
)
SELECT
    @v_sel_1 = MAX(CASE WHEN rn = 1 THEN id_seleccion END),
    @v_sel_2 = MAX(CASE WHEN rn = 2 THEN id_seleccion END),
    @v_sel_3 = MAX(CASE WHEN rn = 3 THEN id_seleccion END),
    @v_sel_4 = MAX(CASE WHEN rn = 4 THEN id_seleccion END)
FROM selecciones
WHERE rn <= 4;

IF @v_id_sede IS NULL OR @v_nro_fase IS NULL OR @v_sel_4 IS NULL
BEGIN
    ;THROW 50001, N'65_Test_ERR_Partidos: se requiere una sede, fase y grupo con cuatro selecciones para el Test 2', 1;
END;

-- Buscar hasta 30 dias un horario inicialmente libre.
DECLARE @v_intentos TINYINT = 0;
WHILE @v_intentos < 30
  AND EXISTS
      (
          SELECT 1 FROM torneo.partido AS p
          WHERE p.id_sede = @v_id_sede
            AND p.estado <> 'SUSPENDIDO'
            AND ABS(DATEDIFF(MINUTE, p.fecha_hora_utc, @v_fecha)) < 180
      )
BEGIN
    SET @v_fecha = DATEADD(DAY, 1, @v_fecha);
    SET @v_intentos += 1;
END;

IF @v_intentos = 30
BEGIN
    ;THROW 50001, N'65_Test_ERR_Partidos: no se encontro un horario libre para preparar el Test 2', 1;
END;

BEGIN TRANSACTION;
BEGIN TRY
    -- Entrega 6: el fixture importado ya tiene los cruces reales de la fase de
    -- grupos. Dentro de esta transacción de prueba se suspenden los partidos de
    -- las selecciones elegidas, para que no interfieran; el ROLLBACK los restaura.
    UPDATE p
    SET p.estado = 'SUSPENDIDO'
    FROM torneo.partido AS p
    WHERE p.nro_fase = 1
      AND EXISTS (SELECT 1 FROM torneo.equipo_en_partido AS e
                  WHERE e.id_partido = p.id_partido AND e.id_seleccion IN (@v_sel_1, @v_sel_2, @v_sel_3, @v_sel_4));

    EXEC torneo.usp_Negocio_RegistrarPartido
        @fecha_hora_utc = @v_fecha,
        @id_sede = @v_id_sede,
        @nro_fase = @v_nro_fase,
        @id_seleccion_local = @v_sel_1,
        @id_seleccion_visitante = @v_sel_2,
        @esquema_local = '4-3-3',
        @esquema_visitante = '4-4-2',
        @id_partido = @v_id_partido_1 OUTPUT;

    BEGIN TRY
        EXEC torneo.usp_Negocio_RegistrarPartido
            @fecha_hora_utc = @v_fecha,
            @id_sede = @v_id_sede,
            @nro_fase = @v_nro_fase,
            @id_seleccion_local = @v_sel_3,
            @id_seleccion_visitante = @v_sel_4,
            @esquema_local = '4-2-3-1',
            @esquema_visitante = '3-5-2',
            @id_partido = @v_id_partido_2 OUTPUT;

        SET @v_error_numero = 0;
        SET @v_error_mensaje = N'El SP permitio dos partidos en la misma sede y horario';
    END TRY
    BEGIN CATCH
        SET @v_error_numero = ERROR_NUMBER();
        SET @v_error_mensaje = ERROR_MESSAGE();
    END CATCH;

    SELECT @v_cantidad_slot = COUNT(*)
    FROM torneo.partido AS p
    WHERE p.id_sede = @v_id_sede
      AND p.fecha_hora_utc = @v_fecha;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    ;THROW;
END CATCH;

PRINT CONCAT(N'Error capturado ', @v_error_numero, N': ', @v_error_mensaje);

IF @v_error_numero IN (50001, 50003)
   AND (@v_error_mensaje LIKE N'%sede%ocupad%' OR @v_error_mensaje LIKE N'%sede%horario%' OR @v_error_mensaje LIKE N'%solap%'
        OR @v_error_mensaje LIKE N'%sede no esta libre%')
   AND @v_cantidad_slot = 1
    PRINT N'PASS Test 2: se rechazo el solapamiento de sede y horario.';
ELSE
    PRINT N'FAIL Test 2: numero, mensaje o cantidad de partidos distintos de lo esperado.';
GO

/* =====================================================================
   CASO 3: cierre con asistencia superior a la capacidad
===================================================================== */
PRINT N'';
PRINT N'-> Test 3: cerrar partido con asistencia superior a la capacidad';

DECLARE @v_id_sede INT;
DECLARE @v_capacidad INT;
DECLARE @v_nro_fase TINYINT;
DECLARE @v_id_local INT;
DECLARE @v_id_visitante INT;
DECLARE @v_jugador_local INT;
DECLARE @v_jugador_visitante INT;
DECLARE @v_dorsal_local TINYINT;
DECLARE @v_dorsal_visitante TINYINT;
DECLARE @v_posicion_local TINYINT;
DECLARE @v_posicion_visitante TINYINT;
DECLARE @v_id_arbitro INT;
DECLARE @v_id_rol_principal TINYINT;
DECLARE @v_id_partido INT;
DECLARE @v_fecha DATETIME2(0) = '2026-07-05T18:00:00';
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_estado_despues VARCHAR(12);
DECLARE @v_asistencia_despues INT;

SELECT TOP (1) @v_id_sede = s.id_sede, @v_capacidad = s.capacidad
FROM torneo.sede AS s ORDER BY s.id_sede;

SELECT TOP (1) @v_nro_fase = f.nro_fase
FROM torneo.fase AS f WHERE f.es_eliminacion = 0 ORDER BY f.nro_fase;

SELECT TOP (1)
    @v_id_local = sl.id_seleccion,
    @v_id_visitante = sv.id_seleccion,
    @v_jugador_local = cl.id_jugador,
    @v_dorsal_local = cl.dorsal,
    @v_posicion_local = jl.id_posicion_habitual,
    @v_jugador_visitante = cv.id_jugador,
    @v_dorsal_visitante = cv.dorsal,
    @v_posicion_visitante = jv.id_posicion_habitual
FROM torneo.seleccion AS sl
JOIN torneo.seleccion AS sv ON sv.id_letra = sl.id_letra AND sv.id_seleccion <> sl.id_seleccion
JOIN torneo.convocatoria AS cl ON cl.id_seleccion = sl.id_seleccion AND cl.estado = 'ACTIVO'
JOIN persona.jugador AS jl ON jl.id_persona = cl.id_jugador
JOIN torneo.convocatoria AS cv ON cv.id_seleccion = sv.id_seleccion AND cv.estado = 'ACTIVO'
JOIN persona.jugador AS jv ON jv.id_persona = cv.id_jugador
ORDER BY sl.id_seleccion, sv.id_seleccion, cl.id_jugador, cv.id_jugador;

SELECT TOP (1) @v_id_arbitro = a.id_persona FROM persona.arbitro AS a ORDER BY a.id_persona;
SELECT TOP (1) @v_id_rol_principal = r.id_rol
FROM arbitraje.rol_arbitral AS r WHERE UPPER(r.descripcion) = 'PRINCIPAL' ORDER BY r.id_rol;

IF @v_id_sede IS NULL OR @v_capacidad IS NULL OR @v_nro_fase IS NULL
   OR @v_id_local IS NULL OR @v_id_visitante IS NULL
   OR @v_jugador_local IS NULL OR @v_jugador_visitante IS NULL
   OR @v_posicion_local IS NULL OR @v_posicion_visitante IS NULL
   OR @v_id_arbitro IS NULL OR @v_id_rol_principal IS NULL
BEGIN
    ;THROW 50001, N'65_Test_ERR_Partidos: faltan datos para preparar el Test 3', 1;
END;

DECLARE @v_intentos TINYINT = 0;
WHILE @v_intentos < 30
  AND EXISTS
      (
          SELECT 1
          FROM torneo.partido AS p
          LEFT JOIN torneo.equipo_en_partido AS ep ON ep.id_partido = p.id_partido
          WHERE p.estado <> 'SUSPENDIDO'
            AND ((p.id_sede = @v_id_sede AND ABS(DATEDIFF(MINUTE, p.fecha_hora_utc, @v_fecha)) < 180)
              OR (ep.id_seleccion IN (@v_id_local, @v_id_visitante)
                  AND ABS(DATEDIFF(HOUR, p.fecha_hora_utc, @v_fecha)) < 48))
      )
BEGIN
    SET @v_fecha = DATEADD(DAY, 1, @v_fecha);
    SET @v_intentos += 1;
END;

IF @v_intentos = 30
BEGIN
    ;THROW 50001, N'65_Test_ERR_Partidos: no se encontro un horario libre para preparar el Test 3', 1;
END;

BEGIN TRANSACTION;
BEGIN TRY
    -- Entrega 6: el fixture importado ya tiene los cruces reales de la fase de
    -- grupos. Dentro de esta transacción de prueba se suspenden los partidos de
    -- las selecciones elegidas, para que no interfieran; el ROLLBACK los restaura.
    UPDATE p
    SET p.estado = 'SUSPENDIDO'
    FROM torneo.partido AS p
    WHERE p.nro_fase = 1
      AND EXISTS (SELECT 1 FROM torneo.equipo_en_partido AS e
                  WHERE e.id_partido = p.id_partido AND e.id_seleccion IN (@v_id_local, @v_id_visitante));

    EXEC torneo.usp_Negocio_RegistrarPartido
        @fecha_hora_utc = @v_fecha,
        @id_sede = @v_id_sede,
        @nro_fase = @v_nro_fase,
        @id_seleccion_local = @v_id_local,
        @id_seleccion_visitante = @v_id_visitante,
        @esquema_local = '4-3-3',
        @esquema_visitante = '4-4-2',
        @id_partido = @v_id_partido OUTPUT;

    INSERT INTO juego.alineacion
        (id_partido, id_seleccion, id_jugador, dorsal, es_titular, id_posicion, es_posicion_habitual)
    VALUES
        (@v_id_partido, @v_id_local, @v_jugador_local, @v_dorsal_local, 1, @v_posicion_local, 1),
        (@v_id_partido, @v_id_visitante, @v_jugador_visitante, @v_dorsal_visitante, 1, @v_posicion_visitante, 1);

    INSERT INTO arbitraje.designacion_arbitral
        (id_partido, id_rol, id_arbitro, fecha_designacion, estado)
    VALUES
        (@v_id_partido, @v_id_rol_principal, @v_id_arbitro, SYSUTCDATETIME(), 'DESIGNADA');

    UPDATE torneo.partido SET estado = 'EN_CURSO' WHERE id_partido = @v_id_partido;

    DECLARE @v_asistencia_invalida INT;
    SET @v_asistencia_invalida = @v_capacidad + 1;
    
    BEGIN TRY
        EXEC torneo.usp_Negocio_CerrarPartido
            @id_partido = @v_id_partido,
            @asistencia_publico = @v_asistencia_invalida,
            @definido_por_penales = 0;

        SET @v_error_numero = 0;
        SET @v_error_mensaje =
            N'El SP permitió asistencia superior a la capacidad';
    END TRY
    BEGIN CATCH
        SET @v_error_numero = ERROR_NUMBER();
        SET @v_error_mensaje = ERROR_MESSAGE();
    END CATCH;

    SELECT
        @v_estado_despues = p.estado,
        @v_asistencia_despues = p.asistencia_publico
    FROM torneo.partido AS p
    WHERE p.id_partido = @v_id_partido;

    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    END TRY
 BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    ;THROW;
END CATCH;

PRINT CONCAT(N'Error capturado ', @v_error_numero, N': ', @v_error_mensaje);

IF @v_error_numero IN (50001, 50003)
   AND (@v_error_mensaje LIKE N'%asistencia%capacidad%' OR @v_error_mensaje LIKE N'%capacidad%sede%')
   AND @v_estado_despues = 'EN_CURSO'
   AND @v_asistencia_despues IS NULL
    PRINT N'PASS Test 3: se rechazo la asistencia superior a la capacidad.';
ELSE
    PRINT N'FAIL Test 3: numero, mensaje o estado distintos de lo esperado.';
GO

PRINT N'';
PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS DE ERROR: 65_Test_ERR_Partidos';
PRINT N'CADA CASO EJECUTO SU PROPIO ROLLBACK';
PRINT N'=====================================================================';
GO
