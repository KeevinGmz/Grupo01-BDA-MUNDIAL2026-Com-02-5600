/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada Comisión: Com02-5600
Grupo : 01 - Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro, Agustin
Fecha : 2026-10-03
Objetivo: Prueba exitosa del SP de importación de fixture (invocación básica)
===================================================================== */
USE Mundial2026;
GO

-- Resultado esperado: Ejecución de la cabecera del proceso de importación registrando id_importacion.
BEGIN TRANSACTION;

    PRINT '--- EVIDENCIA IMPORTACION ANTES DE EJECUTAR ---';
    SELECT COUNT(*) AS total_importaciones FROM soporte.importacion;

    DECLARE @v_id_imp INT;
    EXEC soporte.usp_Negocio_ImportarFixture
        @archivo = 'sample_fixture.csv',
        @id_importacion = @v_id_imp OUTPUT;

    PRINT '--- EVIDENCIA DESPUES DE EJECUTAR IMPORTACION (ID: ' + CAST(@v_id_imp AS VARCHAR) + ') ---';
    SELECT * FROM soporte.importacion WHERE id_importacion = @v_id_imp;

ROLLBACK TRANSACTION;
GO