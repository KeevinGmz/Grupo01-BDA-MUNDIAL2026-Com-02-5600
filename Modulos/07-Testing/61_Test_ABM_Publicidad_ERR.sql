/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Objetivo: Validar V-12 Límite de 4 espacios por sede y valores mayores a cero
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
        @id_sede = 1, @ubicacion = 'ESTATICA',
        @precio = 0.00, -- Error
        @id_tarifa = @id_out OUTPUT;
END TRY
BEGIN CATCH
    PRINT '   [ÉXITO CAPTURANDO ERROR] Código: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT '   Mensaje retornado: ' + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
PRINT CHAR(10) + '=====================================================================';
PRINT 'FIN PRUEBAS DE ERROR: 61_Test_ERR_ABM_Publicidad';
PRINT '=====================================================================';
GO