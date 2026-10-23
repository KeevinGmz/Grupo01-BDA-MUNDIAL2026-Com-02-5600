/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Objetivo: Validar valores mayores a cero
===================================================================== */
USE Mundial2026;
GO

PRINT '=====================================================================';
PRINT 'INICIO PRUEBAS DE ERROR: 61_Test_ERR_ABM_Publicidad';
PRINT '=====================================================================';

BEGIN TRANSACTION;

BEGIN TRY
    PRINT '-> Test 1: Importe de tarifa publicitaria en cero...';

    DECLARE @id_out INT;

    EXEC publicidad.usp_Tarifa_Insertar
        @id_franja = 1,
        @id_moneda = 1,
        @importe = 0.00, 
        @id_tarifa = @id_out OUTPUT;

    PRINT '[ERROR] El SP debería haber lanzado una excepción.';
END TRY
BEGIN CATCH
    PRINT '   [ÉXITO CAPTURANDO ERROR] Código: '
          + CAST(ERROR_NUMBER() AS VARCHAR(10));

    PRINT '   Mensaje retornado: '
          + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;

PRINT CHAR(10) + '=====================================================================';
PRINT 'FIN PRUEBAS DE ERROR: 61_Test_ERR_ABM_Publicidad';
PRINT '=====================================================================';
GO