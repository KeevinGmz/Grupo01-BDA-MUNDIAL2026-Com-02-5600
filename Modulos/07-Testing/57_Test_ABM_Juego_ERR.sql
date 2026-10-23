/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Objetivo: Validar rangos en ABM Juego (Minutos inválidos)
===================================================================== */
USE Mundial2026;
GO

PRINT '=====================================================================';
PRINT 'INICIO PRUEBAS DE ERROR: 57_Test_ERR_ABM_Juego';
PRINT '=====================================================================';

BEGIN TRANSACTION;

-- ---------------------------------------------------------------------
-- CASO 1: Minuto de incidencia fuera de rango (0-130)
-- ---------------------------------------------------------------------
BEGIN TRY
    PRINT '-> Test 1: Insertar incidencia en el minuto 150...';
    DECLARE @id_out INT;
    EXEC juego.usp_Incidencia_Insertar 
        @id_partido = 1, @id_seleccion = 1, @minuto = 150, -- Inválido
        @tipo_incidencia = 'GOL', @periodo = 'ST',
        @id_incidencia = @id_out OUTPUT;
END TRY
BEGIN CATCH
    PRINT '   [ÉXITO CAPTURANDO ERROR] Código: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT '   Mensaje retornado: ' + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
PRINT CHAR(10) + '=====================================================================';
PRINT 'FIN PRUEBAS DE ERROR: 57_Test_ERR_ABM_Juego';
PRINT '=====================================================================';
GO