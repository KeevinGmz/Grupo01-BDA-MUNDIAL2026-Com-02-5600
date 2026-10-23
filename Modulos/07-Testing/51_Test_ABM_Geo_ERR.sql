/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada Comisión: Com02-5600
Grupo : 01 - Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro, Agustin
Fecha : 2026-10-03
Objetivo: Demostrar las validaciones fallidas y mensajes agrupados en SPs de ABM Geo
===================================================================== */
USE Mundial2026;
GO

PRINT '=====================================================================';
PRINT 'INICIO PRUEBAS DE ERROR: 51_Test_ERR_ABM_Geo';
PRINT '=====================================================================';

BEGIN TRANSACTION;

-- ---------------------------------------------------------------------
-- CASO 1: Validación acumulada en geo.usp_Pais_Insertar (Múltiples fallas)
-- Texto esperado: Mensaje con 50001 detallando nombre obligatorio, ISO3 inválido y confederación inexistente
-- ---------------------------------------------------------------------
BEGIN TRY
    PRINT '-> Test 1.1: Insertar país con múltiples parámetros inválidos...';
    DECLARE @id_out SMALLINT;
    EXEC geo.usp_Pais_Insertar 
        @nombre = '', 
        @cod_iso3 = 'ARGENTINA', -- Excede los 3 caracteres
        @cod_fifa = NULL, 
        @gentilicio = NULL, 
        @id_confederacion = 99,   -- Inexistente
        @id_pais = @id_out OUTPUT;
    
    PRINT '   [FALLO CONTROLANDO ERROR]: El SP debió lanzar una excepción y no lo hizo.';
END TRY
BEGIN CATCH
    PRINT '   [ÉXITO CAPTURANDO ERROR] Código: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT '   Mensaje retornado:' + CHAR(10) + ERROR_MESSAGE();
END CATCH;

-- ---------------------------------------------------------------------
-- CASO 2: Unicidad duplicada en geo.usp_Pais_Insertar
-- Texto esperado: Error 50001 indicando que cod_iso3 o nombre ya están registrados
-- ---------------------------------------------------------------------
BEGIN TRY
    PRINT CHAR(10) + '-> Test 1.2: Insertar país con código ISO3 duplicado...';
    EXEC geo.usp_Pais_Insertar 
        @nombre = 'Nación Duplicada', 
        @cod_iso3 = 'ARG', -- ISO3 existente de Argentina
        @cod_fifa = 'NDP', 
        @gentilicio = 'Duplicado', 
        @id_confederacion = 1, 
        @id_pais = @id_out OUTPUT;
END TRY
BEGIN CATCH
    PRINT '   [ÉXITO CAPTURANDO ERROR] Código: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT '   Mensaje retornado: ' + ERROR_MESSAGE();
END CATCH;

-- ---------------------------------------------------------------------
-- CASO 3: Eliminación con dependencias activas en geo.usp_Pais_Eliminar
-- Texto esperado: Error 50002 notificando tablas que impiden el borrado
-- ---------------------------------------------------------------------
BEGIN TRY
    PRINT CHAR(10) + '-> Test 1.3: Eliminar país con ciudades y selecciones asociadas...';
    DECLARE @id_pais_arg SMALLINT;
    SELECT TOP 1 @id_pais_arg = id_pais FROM geo.pais WHERE cod_iso3 = 'ARG';

    EXEC geo.usp_Pais_Eliminar @id_pais = @id_pais_arg;
END TRY
BEGIN CATCH
    PRINT '   [ÉXITO CAPTURANDO ERROR] Código: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT '   Mensaje retornado: ' + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
PRINT CHAR(10) + '=====================================================================';
PRINT 'FIN PRUEBAS DE ERROR: 51_Test_ERR_ABM_Geo (ROLLBACK EJECUTADO)';
PRINT '=====================================================================';
GO