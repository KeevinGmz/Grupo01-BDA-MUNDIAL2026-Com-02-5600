/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Prueba exitosa de los SP de negocio para registrar y cerrar partidos, sin dejar residuos.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT N'=== 64_Test_OK_Partidos: registrar y cerrar partido ===';

DECLARE @v_id_partido INT;
DECLARE @v_id_sede INT;
DECLARE @v_nro_fase TINYINT;
DECLARE @v_id_local INT;
DECLARE @v_id_visitante INT;
DECLARE @v_id_jugador_local INT;
DECLARE @v_id_jugador_visitante INT;
DECLARE @v_dorsal_local TINYINT;
DECLARE @v_dorsal_visitante TINYINT;
DECLARE @v_posicion_local TINYINT;
DECLARE @v_posicion_visitante TINYINT;
DECLARE @v_id_arbitro INT;
DECLARE @v_id_rol_principal TINYINT;
DECLARE @v_fecha_partido DATETIME2(0);
DECLARE @v_partidos_antes INT;
DECLARE @v_equipos_antes INT;

-------------------------------------------------------------------------------
-- 1. Validaciones previas y obtencion de datos reales
-------------------------------------------------------------------------------

IF OBJECT_ID(N'torneo.usp_Negocio_RegistrarPartido', N'P') IS NULL
   OR OBJECT_ID(N'torneo.usp_Negocio_CerrarPartido', N'P') IS NULL
BEGIN
    ;THROW 50001,N'64_Test_OK_Partidos: faltan los procedimientos de negocio requeridos',1;
END;

-- Se elige una fase no eliminatoria para no exigir un ganador al cerrar.
SELECT TOP (1)
    @v_nro_fase = f.nro_fase
FROM torneo.fase AS f
WHERE f.es_eliminacion = 0
ORDER BY f.nro_fase;

-- Se eligen dos selecciones distintas del mismo grupo que tengan al menos un
-- convocado activo. Esto permite preparar las alineaciones minimas que exige
-- el cierre sin utilizar IDs fisicos fijos.
SELECT TOP (1)
    @v_id_local = sl.id_seleccion,
    @v_id_visitante = sv.id_seleccion,
    @v_id_jugador_local = cl.id_jugador,
    @v_dorsal_local = cl.dorsal,
    @v_posicion_local = jl.id_posicion_habitual,
    @v_id_jugador_visitante = cv.id_jugador,
    @v_dorsal_visitante = cv.dorsal,
    @v_posicion_visitante = jv.id_posicion_habitual
FROM torneo.seleccion AS sl
JOIN torneo.seleccion AS sv
  ON sv.id_seleccion <> sl.id_seleccion
 AND sv.id_letra = sl.id_letra
JOIN torneo.convocatoria AS cl
  ON cl.id_seleccion = sl.id_seleccion
 AND cl.estado = 'ACTIVO'
JOIN persona.jugador AS jl
  ON jl.id_persona = cl.id_jugador
JOIN torneo.convocatoria AS cv
  ON cv.id_seleccion = sv.id_seleccion
 AND cv.estado = 'ACTIVO'
JOIN persona.jugador AS jv
  ON jv.id_persona = cv.id_jugador
ORDER BY sl.id_seleccion, sv.id_seleccion, cl.id_jugador, cv.id_jugador;

SELECT TOP (1)
    @v_id_sede = s.id_sede
FROM torneo.sede AS s
ORDER BY s.id_sede;

SELECT TOP (1)
    @v_id_rol_principal = r.id_rol
FROM arbitraje.rol_arbitral AS r
WHERE UPPER(r.descripcion) = 'PRINCIPAL'
ORDER BY r.id_rol;

SELECT TOP (1)
    @v_id_arbitro = a.id_persona
FROM persona.arbitro AS a
ORDER BY a.id_persona;

IF @v_nro_fase IS NULL
   OR @v_id_sede IS NULL
   OR @v_id_local IS NULL
   OR @v_id_visitante IS NULL
   OR @v_id_jugador_local IS NULL
   OR @v_id_jugador_visitante IS NULL
   OR @v_posicion_local IS NULL
   OR @v_posicion_visitante IS NULL
   OR @v_id_rol_principal IS NULL
   OR @v_id_arbitro IS NULL
BEGIN
    ;THROW 50001,N'64_Test_OK_Partidos: faltan fase de grupos, sede, selecciones con convocados, posiciones o arbitro principal',1;
END;

-- Se busca un horario libre para la sede y las selecciones.
-- torneo.fase no posee fecha_desde ni fecha_hasta. Por eso, la prueba
-- parte de una fecha valida del Mundial 2026 y avanza por dias hasta
-- encontrar una combinacion libre.
DECLARE @v_intentos TINYINT = 0;
DECLARE @v_horario_ocupado BIT = 1;

SET @v_fecha_partido = '2026-06-15T18:00:00';

WHILE @v_intentos < 30
  AND @v_horario_ocupado = 1
BEGIN
    SET @v_horario_ocupado = 0;

    -- Disponibilidad de la sede: separacion minima de 180 minutos.
    IF EXISTS
    (
        SELECT 1
        FROM torneo.partido AS p
        WHERE p.id_sede = @v_id_sede
          AND p.estado <> 'SUSPENDIDO'
          AND ABS(DATEDIFF(MINUTE, p.fecha_hora_utc, @v_fecha_partido)) < 180
    )
    BEGIN
        SET @v_horario_ocupado = 1;
    END;

    -- Descanso minimo de 48 horas para ambas selecciones.
    IF EXISTS
    (
        SELECT 1
        FROM torneo.partido AS p
        JOIN torneo.equipo_en_partido AS ep
          ON ep.id_partido = p.id_partido
        WHERE ep.id_seleccion IN (@v_id_local, @v_id_visitante)
          AND p.estado <> 'SUSPENDIDO'
          AND ABS(DATEDIFF(HOUR, p.fecha_hora_utc, @v_fecha_partido)) < 48
    )
    BEGIN
        SET @v_horario_ocupado = 1;
    END;

    IF @v_horario_ocupado = 1
    BEGIN
        SET @v_fecha_partido = DATEADD(DAY, 1, @v_fecha_partido);
        SET @v_intentos += 1;
    END;
END;

IF @v_horario_ocupado = 1
BEGIN
    ;THROW 50001, N'64_Test_OK_Partidos: no se encontro un horario libre luego de 30 intentos', 1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Entrega 6: el fixture importado ya tiene los cruces reales de la fase de
    -- grupos. Dentro de esta transacción de prueba se suspenden los partidos de
    -- las selecciones elegidas, para que no interfieran; el ROLLBACK los restaura.
    UPDATE p
    SET p.estado = 'SUSPENDIDO'
    FROM torneo.partido AS p
    WHERE p.nro_fase = 1
      AND EXISTS (SELECT 1 FROM torneo.equipo_en_partido AS e
                  WHERE e.id_partido = p.id_partido AND e.id_seleccion IN (@v_id_local, @v_id_visitante));

    SELECT @v_partidos_antes = COUNT(*) FROM torneo.partido;
    SELECT @v_equipos_antes = COUNT(*) FROM torneo.equipo_en_partido;

    PRINT N'--- EVIDENCIA ANTES DE REGISTRAR PARTIDO ---';
    SELECT @v_partidos_antes AS partidos_antes,
           @v_equipos_antes AS equipos_en_partido_antes;

    ---------------------------------------------------------------------------
    -- 2. Registrar el partido y sus dos equipos
    ---------------------------------------------------------------------------

    EXEC torneo.usp_Negocio_RegistrarPartido
        @fecha_hora_utc = @v_fecha_partido,
        @id_sede = @v_id_sede,
        @nro_fase = @v_nro_fase,
        @id_seleccion_local = @v_id_local,
        @id_seleccion_visitante = @v_id_visitante,
        @esquema_local = '4-3-3',
        @esquema_visitante = '4-4-2',
        @id_partido = @v_id_partido OUTPUT;

    SELECT CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM torneo.partido AS p
                 WHERE p.id_partido = @v_id_partido
                   AND p.fecha_hora_utc = @v_fecha_partido
                   AND p.id_sede = @v_id_sede
                   AND p.nro_fase = @v_nro_fase
                   AND p.estado = 'PROGRAMADO'
             )
         AND 2 =
             (
                 SELECT COUNT(*)
                 FROM torneo.equipo_en_partido AS ep
                 WHERE ep.id_partido = @v_id_partido
                   AND ep.id_seleccion IN (@v_id_local, @v_id_visitante)
             )
            THEN N'PASS registrar partido'
        ELSE N'FAIL registrar partido'
    END AS resultado;

    PRINT CONCAT(N'--- EVIDENCIA DESPUES DE REGISTRAR. ID: ', @v_id_partido, N' ---');
    SELECT p.* FROM torneo.partido AS p WHERE p.id_partido = @v_id_partido;
    SELECT ep.* FROM torneo.equipo_en_partido AS ep WHERE ep.id_partido = @v_id_partido;

    ---------------------------------------------------------------------------
    -- 3. Preparar las precondiciones requeridas por CerrarPartido
    ---------------------------------------------------------------------------

    INSERT INTO juego.alineacion
    (
        id_partido, id_seleccion, id_jugador, dorsal,
        es_titular, id_posicion, es_posicion_habitual
    )
    VALUES
    (
        @v_id_partido, @v_id_local, @v_id_jugador_local, @v_dorsal_local,
        1, @v_posicion_local, 1
    ),
    (
        @v_id_partido, @v_id_visitante, @v_id_jugador_visitante, @v_dorsal_visitante,
        1, @v_posicion_visitante, 1
    );

    INSERT INTO arbitraje.designacion_arbitral
    (
        id_partido, id_rol, id_arbitro, fecha_designacion, estado
    )
    VALUES
    (
        @v_id_partido, @v_id_rol_principal, @v_id_arbitro,
        SYSUTCDATETIME(), 'DESIGNADA'
    );

    UPDATE torneo.partido
    SET estado = 'EN_CURSO'
    WHERE id_partido = @v_id_partido;

    ---------------------------------------------------------------------------
    -- 4. Cerrar el partido
    ---------------------------------------------------------------------------

    EXEC torneo.usp_Negocio_CerrarPartido
        @id_partido = @v_id_partido,
        @asistencia_publico = 45000,
        @definido_por_penales = 0;

    SELECT CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM torneo.partido AS p
                 WHERE p.id_partido = @v_id_partido
                   AND p.estado = 'FINALIZADO'
                   AND p.asistencia_publico = 45000
                   AND p.definido_por_penales = 0
             )
            THEN N'PASS cerrar partido'
        ELSE N'FAIL cerrar partido'
    END AS resultado;

    PRINT N'--- EVIDENCIA DESPUES DE CERRAR PARTIDO ---';
    SELECT p.id_partido, p.estado, p.asistencia_publico, p.definido_por_penales
    FROM torneo.partido AS p
    WHERE p.id_partido = @v_id_partido;

    ---------------------------------------------------------------------------
    -- 5. Revertir toda la prueba
    ---------------------------------------------------------------------------

    ROLLBACK TRANSACTION;
    PRINT N'PASS general: prueba finalizada y transaccion revertida.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT CONCAT(N'FAIL general. Error ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
    ;THROW;
END CATCH;
GO
