/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Objetivo: Caso 6 - Errores en módulo de importación masiva (Archivo inexistente)
===================================================================== */
USE Mundial2026;
GO
PRINT '=====================================================================';
PRINT 'INICIO PRUEBAS DE ERROR: 77_Test_ERR_Importacion';
PRINT '=====================================================================';

BEGIN TRANSACTION;

BEGIN TRY
    PRINT '-> Test 1: Intentar importar un archivo físico que no existe en el disco...';
    EXEC soporte.usp_Negocio_ImportarJugadoresCSV
        @ruta_archivo = 'C:\RutaFalsa\Jugadores_Inexistentes.csv';
END TRY
BEGIN CATCH
    PRINT '   [ÉXITO CAPTURANDO ERROR] Código: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT '   Mensaje retornado: ' + ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
PRINT CHAR(10) + '=====================================================================';
PRINT 'FIN PRUEBAS DE ERROR: 77_Test_ERR_Importacion';
PRINT '=====================================================================';
GO