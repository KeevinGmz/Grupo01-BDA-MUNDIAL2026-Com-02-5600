/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada 
Comisión: 02-5600
Grupo : 01 
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro, Agustin
Fecha : 2026-10-03
Objetivo: Prueba exitosa de ABM para el esquema Persona (inserción de jugador con datos de persona en una sola transacción)
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT '=== 52_Test_ABM_Persona_OK: jugador, camino feliz ===';

DECLARE @v_id_pais SMALLINT;
DECLARE @v_id_club INT;
DECLARE @v_id_posicion TINYINT;
DECLARE @v_id_persona INT;
DECLARE @v_nro_doc VARCHAR(30) = 'JUG-TEST-0001';
DECLARE @v_personas_antes INT;
DECLARE @v_jugadores_antes INT;
DECLARE @v_personas_despues INT;
DECLARE @v_jugadores_despues INT;

-------------------------------------------------------------------------------
-- 1. Validaciones previas
-------------------------------------------------------------------------------

IF OBJECT_ID('persona.usp_Jugador_Insertar', 'P') IS NULL
   OR OBJECT_ID('persona.usp_Jugador_Modificar', 'P') IS NULL
   OR OBJECT_ID('persona.usp_Jugador_Eliminar', 'P') IS NULL
BEGIN
    ;THROW 50001,
           '52_Test_ABM_Persona_OK: faltan uno o mas procedimientos ABM de jugador',
           1;
END;

SELECT TOP (1) @v_id_pais = p.id_pais
FROM geo.pais AS p
ORDER BY p.id_pais;

SELECT TOP (1) @v_id_club = c.id_club
FROM persona.club AS c
ORDER BY c.id_club;

SELECT TOP (1) @v_id_posicion = p.id_posicion
FROM persona.posicion AS p
ORDER BY p.id_posicion;

IF @v_id_pais IS NULL
BEGIN
    ;THROW 50001, '52_Test_ABM_Persona_OK: debe existir al menos un pais',1;
END;

IF @v_id_club IS NULL
BEGIN
    ;THROW 50001, '52_Test_ABM_Persona_OK: debe existir al menos un club',1;
END;

IF @v_id_posicion IS NULL
BEGIN
    ;THROW 50001, '52_Test_ABM_Persona_OK: debe existir al menos una posicio', 1;
END;

IF EXISTS
(
    SELECT 1
    FROM persona.persona AS p
    WHERE p.tipo_doc = 'DNI'
      AND p.nro_doc = @v_nro_doc
)
BEGIN
    ;THROW 50001,'52_Test_ABM_Persona_OK: ya existe el documento de prueba JUG-TEST-0001', 1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    ---------------------------------------------------------------------------
    -- 2. Evidencia inicial
    ---------------------------------------------------------------------------

    SELECT @v_personas_antes = COUNT(*)
    FROM persona.persona;

    SELECT @v_jugadores_antes = COUNT(*)
    FROM persona.jugador;

    PRINT '--- EVIDENCIA ANTES DE INSERTAR ---';

    SELECT
        @v_personas_antes AS personas_antes,
        @v_jugadores_antes AS jugadores_antes;

    SELECT p.*
    FROM persona.persona AS p
    WHERE p.tipo_doc = 'DNI'
      AND p.nro_doc = @v_nro_doc;

    ---------------------------------------------------------------------------
    -- 3. Insertar persona y jugador con un unico SP jerarquico
    ---------------------------------------------------------------------------

    EXEC persona.usp_Jugador_Insertar
        @tipo_doc = 'DNI',
        @nro_doc = @v_nro_doc,
        @nombre = 'Jugador',
        @apellido = 'De Prueba',
        @fecha_nac = '1998-05-10',
        @id_pais = @v_id_pais,
        @pie_habil = 'D',
        @altura_cm = 180,
        @id_club = @v_id_club,
        @id_posicion_habitual = @v_id_posicion,
        @id_persona = @v_id_persona OUTPUT;

    SELECT @v_personas_despues = COUNT(*)
    FROM persona.persona;

    SELECT @v_jugadores_despues = COUNT(*)
    FROM persona.jugador;

    SELECT CASE
        WHEN @v_personas_despues = @v_personas_antes + 1
         AND @v_jugadores_despues = @v_jugadores_antes + 1
         AND EXISTS
             (
                 SELECT 1
                 FROM persona.persona AS p
                 JOIN persona.jugador AS j
                   ON j.id_persona = p.id_persona
                 WHERE p.id_persona = @v_id_persona
                   AND p.tipo_persona = 'J'
                   AND p.tipo_doc = 'DNI'
                   AND p.nro_doc = @v_nro_doc
                   AND j.tipo_persona = 'J'
                   AND j.pie_habil = 'D'
                   AND j.altura_cm = 180
                   AND j.id_club = @v_id_club
                   AND j.id_posicion_habitual = @v_id_posicion
             )
            THEN 'PASS jugador insertar: persona y subtipo creados'
        ELSE 'FAIL jugador insertar'
    END AS resultado;

    PRINT '--- EVIDENCIA DESPUES DE INSERTAR ---';

    SELECT
        p.*,
        j.pie_habil,
        j.altura_cm,
        j.id_club,
        j.id_posicion_habitual
    FROM persona.persona AS p
    JOIN persona.jugador AS j
      ON j.id_persona = p.id_persona
    WHERE p.id_persona = @v_id_persona;

    ---------------------------------------------------------------------------
    -- 4. Modificar persona y jugador con el SP del subtipo
    ---------------------------------------------------------------------------

    EXEC persona.usp_Jugador_Modificar
        @id_persona = @v_id_persona,
        @tipo_doc = 'DNI',
        @nro_doc = @v_nro_doc,
        @nombre = 'Jugador Modificado',
        @apellido = 'De Prueba Modificado',
        @fecha_nac = '1998-05-10',
        @id_pais = @v_id_pais,
        @pie_habil = 'I',
        @altura_cm = 185,
        @id_club = @v_id_club,
        @id_posicion_habitual = @v_id_posicion;

    SELECT CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM persona.persona AS p
                 JOIN persona.jugador AS j
                   ON j.id_persona = p.id_persona
                 WHERE p.id_persona = @v_id_persona
                   AND p.nombre = 'Jugador Modificado'
                   AND p.apellido = 'De Prueba Modificado'
                   AND j.pie_habil = 'I'
                   AND j.altura_cm = 185
                   AND j.id_club = @v_id_club
                   AND j.id_posicion_habitual = @v_id_posicion
             )
            THEN 'PASS jugador modificar: persona y subtipo actualizados'
        ELSE 'FAIL jugador modificar'
    END AS resultado;

    PRINT '--- EVIDENCIA DESPUES DE MODIFICAR ---';

    SELECT
        p.*,
        j.pie_habil,
        j.altura_cm,
        j.id_club,
        j.id_posicion_habitual
    FROM persona.persona AS p
    JOIN persona.jugador AS j
      ON j.id_persona = p.id_persona
    WHERE p.id_persona = @v_id_persona;

    ---------------------------------------------------------------------------
    -- 5. Eliminar jugador sin dependencias
    ---------------------------------------------------------------------------

    EXEC persona.usp_Jugador_Eliminar
        @id_persona = @v_id_persona;

    SELECT CASE
        WHEN NOT EXISTS
             (
                 SELECT 1
                 FROM persona.jugador AS j
                 WHERE j.id_persona = @v_id_persona
             )
         AND NOT EXISTS
             (
                 SELECT 1
                 FROM persona.persona AS p
                 WHERE p.id_persona = @v_id_persona
             )
            THEN 'PASS jugador eliminar: persona y subtipo eliminados'
        ELSE 'FAIL jugador eliminar'
    END AS resultado;

    PRINT '--- EVIDENCIA DESPUES DE ELIMINAR ---';

    SELECT p.*
    FROM persona.persona AS p
    WHERE p.id_persona = @v_id_persona;

    SELECT j.*
    FROM persona.jugador AS j
    WHERE j.id_persona = @v_id_persona;

    ---------------------------------------------------------------------------
    -- 6. Revertir toda la prueba
    ---------------------------------------------------------------------------

    ROLLBACK TRANSACTION;

    PRINT 'PASS general: prueba finalizada y transaccion revertida.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT CONCAT
    (
        'FAIL general. Error ',
        ERROR_NUMBER(),
        ': ',
        ERROR_MESSAGE()
    );

    ;THROW;
END CATCH;
GO

-------------------------------------------------------------------------------
-- 7. Verificacion posterior al ROLLBACK
-------------------------------------------------------------------------------

SELECT CASE
    WHEN NOT EXISTS
         (
             SELECT 1
             FROM persona.persona AS p
             WHERE p.tipo_doc = 'DNI'
               AND p.nro_doc = 'JUG-TEST-0001'
         )
        THEN 'PASS rollback: no quedaron residuos'
    ELSE 'FAIL rollback: quedaron residuos'
END AS resultado_final;
GO
