/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada Comisión: Com02-5600
Grupo : 01 - Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro, Agustin
Fecha : 2026-10-03
Objetivo: Prueba exitosa de ABM para el esquema Geo (insertar, modificar y eliminar pais, ciudad, indicador_pais)
===================================================================== */
USE Mundial2026;
GO

-- Resultado esperado: Inserción, modificación y borrado físico correcto de un país de prueba sin dejar residuos.
BEGIN TRANSACTION;

    PRINT '--- EVIDENCIA ANTES DE LA INSERCION ---';
    SELECT * FROM geo.pais WHERE cod_iso3 = 'TST';

    -- 1. Insertar país
    DECLARE @v_id_pais SMALLINT;
    EXEC geo.usp_Pais_Insertar 
        @nombre = 'País De Prueba', 
        @cod_iso3 = 'TST', 
        @cod_fifa = 'TST', 
        @gentilicio = 'Testiano', 
        @id_confederacion = 1, 
        @id_pais = @v_id_pais OUTPUT;

    PRINT '--- EVIDENCIA DESPUES DE INSERTAR PAIS (ID: ' + CAST(@v_id_pais AS VARCHAR) + ') ---';
    SELECT * FROM geo.pais WHERE id_pais = @v_id_pais;

    -- 2. Modificar país
    EXEC geo.usp_Pais_Modificar 
        @id_pais = @v_id_pais, 
        @nombre = 'País De Prueba Modificado', 
        @cod_iso3 = 'TST', 
        @cod_fifa = 'TST', 
        @gentilicio = 'Testiano Mod', 
        @id_confederacion = 1;

    PRINT '--- EVIDENCIA DESPUES DE MODIFICAR PAIS ---';
    SELECT * FROM geo.pais WHERE id_pais = @v_id_pais;

    -- 3. Eliminar país
    EXEC geo.usp_Pais_Eliminar @id_pais = @v_id_pais;

    PRINT '--- EVIDENCIA DESPUES DE ELIMINAR PAIS ---';
    SELECT * FROM geo.pais WHERE id_pais = @v_id_pais;

ROLLBACK TRANSACTION;
GO