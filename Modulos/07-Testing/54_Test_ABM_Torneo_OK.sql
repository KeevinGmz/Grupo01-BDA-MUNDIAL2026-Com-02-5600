/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada 
Comisión: 02-5600
Grupo : 01 
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro, Agustin
Fecha : 2026-10-03
Objetivo: Prueba exitosa de ABM para el esquema Torneo (inserción y modificación de sede)
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT N'=== 54_Test_ABM_Torneo_OK: sede, camino feliz ===';

DECLARE @v_id_ciudad INT;
DECLARE @v_id_sede INT;
DECLARE @v_nombre_prueba NVARCHAR(100) = N'Estadio Test ABM Torneo';
DECLARE @v_sedes_antes INT;
DECLARE @v_sedes_despues INT;

-------------------------------------------------------------------------------
-- 1. Validaciones previas
-------------------------------------------------------------------------------

IF OBJECT_ID(N'torneo.usp_Sede_Insertar', N'P') IS NULL
   OR OBJECT_ID(N'torneo.usp_Sede_Modificar', N'P') IS NULL
   OR OBJECT_ID(N'torneo.usp_Sede_Eliminar', N'P') IS NULL
BEGIN
    ;THROW 50001,N'54_Test_ABM_Torneo_OK: faltan uno o mas procedimientos ABM de sede',1;
END;

SELECT TOP (1)@v_id_ciudad = c.id_ciudad
FROM geo.ciudad AS c
ORDER BY c.id_ciudad;

IF @v_id_ciudad IS NULL
BEGIN
    ;THROW 50001,N'54_Test_ABM_Torneo_OK: debe existir al menos una ciudad para ejecutar la prueba', 1;
END;

IF EXISTS
(
    SELECT 1
    FROM torneo.sede AS s
    WHERE s.nombre_estadio = @v_nombre_prueba
)
BEGIN
    ;THROW 50001, N'54_Test_ABM_Torneo_OK: ya existe la sede reservada para esta prueba', 1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    ---------------------------------------------------------------------------
    -- 2. Evidencia inicial
    ---------------------------------------------------------------------------

    SELECT @v_sedes_antes = COUNT(*)
    FROM torneo.sede;

    PRINT N'--- EVIDENCIA ANTES DE INSERTAR SEDE ---';

    SELECT
        @v_sedes_antes AS sedes_antes;

    SELECT s.*
    FROM torneo.sede AS s
    WHERE s.nombre_estadio = @v_nombre_prueba;

    ---------------------------------------------------------------------------
    -- 3. Insertar sede
    ---------------------------------------------------------------------------

    EXEC torneo.usp_Sede_Insertar
        @nombre_estadio = @v_nombre_prueba,
        @capacidad = 50000,
        @direccion = N'Av. Siempre Viva 123',
        @latitud = -34.640000,
        @longitud = -58.565000,
        @id_ciudad = @v_id_ciudad,
        @id_sede = @v_id_sede OUTPUT;

    SELECT @v_sedes_despues = COUNT(*)
    FROM torneo.sede;

    SELECT CASE
        WHEN @v_sedes_despues = @v_sedes_antes + 1
         AND EXISTS
             (
                 SELECT 1
                 FROM torneo.sede AS s
                 WHERE s.id_sede = @v_id_sede
                   AND s.nombre_estadio = @v_nombre_prueba
                   AND s.capacidad = 50000
                   AND s.direccion = N'Av. Siempre Viva 123'
                   AND s.latitud = -34.640000
                   AND s.longitud = -58.565000
                   AND s.id_ciudad = @v_id_ciudad
             )
            THEN N'PASS sede insertar'
        ELSE N'FAIL sede insertar'
    END AS resultado;

    PRINT CONCAT
    (
        N'--- EVIDENCIA DESPUES DE INSERTAR SEDE. ID: ',
        @v_id_sede,
        N' ---'
    );

    SELECT s.*
    FROM torneo.sede AS s
    WHERE s.id_sede = @v_id_sede;

    ---------------------------------------------------------------------------
    -- 4. Modificar sede
    ---------------------------------------------------------------------------

    EXEC torneo.usp_Sede_Modificar
        @id_sede = @v_id_sede,
        @nombre_estadio = N'Estadio Test ABM Torneo Modificado',
        @capacidad = 55000,
        @direccion = N'Av. Siempre Viva 123 Modificada',
        @latitud = -34.641000,
        @longitud = -58.566000,
        @id_ciudad = @v_id_ciudad;

    SELECT CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM torneo.sede AS s
                 WHERE s.id_sede = @v_id_sede
                   AND s.nombre_estadio = N'Estadio Test ABM Torneo Modificado'
                   AND s.capacidad = 55000
                   AND s.direccion = N'Av. Siempre Viva 123 Modificada'
                   AND s.latitud = -34.641000
                   AND s.longitud = -58.566000
                   AND s.id_ciudad = @v_id_ciudad
             )
            THEN N'PASS sede modificar'
        ELSE N'FAIL sede modificar'
    END AS resultado;

    PRINT N'--- EVIDENCIA DESPUES DE MODIFICAR SEDE ---';

    SELECT s.*
    FROM torneo.sede AS s
    WHERE s.id_sede = @v_id_sede;

    ---------------------------------------------------------------------------
    -- 5. Eliminar sede
    ---------------------------------------------------------------------------

    EXEC torneo.usp_Sede_Eliminar
        @id_sede = @v_id_sede;

    SELECT CASE
        WHEN NOT EXISTS
             (
                 SELECT 1
                 FROM torneo.sede AS s
                 WHERE s.id_sede = @v_id_sede
             )
         AND (SELECT COUNT(*) FROM torneo.sede) = @v_sedes_antes
            THEN N'PASS sede eliminar'
        ELSE N'FAIL sede eliminar'
    END AS resultado;

    PRINT N'--- EVIDENCIA DESPUES DE ELIMINAR SEDE ---';

    SELECT s.*
    FROM torneo.sede AS s
    WHERE s.id_sede = @v_id_sede;

    ---------------------------------------------------------------------------
    -- 6. Revertir la prueba para conservar el estado original
    ---------------------------------------------------------------------------

    ROLLBACK TRANSACTION;

    PRINT N'PASS general: prueba finalizada y transaccion revertida.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT CONCAT
    (
        N'FAIL general. Error ',
        ERROR_NUMBER(),
        N': ',
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
             FROM torneo.sede AS s
             WHERE s.nombre_estadio IN
                   (
                       N'Estadio Test ABM Torneo',
                       N'Estadio Test ABM Torneo Modificado'
                   )
         )
        THEN N'PASS rollback: no quedaron residuos'
    ELSE N'FAIL rollback: quedaron residuos'
END AS resultado_final;
GO
