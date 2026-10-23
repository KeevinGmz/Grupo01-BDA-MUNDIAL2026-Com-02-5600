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
-- CASO 1: Minuto de gol fuera de rango (0-130)
-- ---------------------------------------------------------------------
BEGIN TRY
    PRINT '-> Test 1: Insertar gol en el minuto 150...';

    EXEC juego.usp_Gol_Insertar
        @id_partido = 1,
        @id_seleccion = 1,
        @nro_gol = 1,
        @minuto = 150, -- Inválido
        @tipo_gol = 'JUGADA',
        @en_contra = 0,
        @periodo = 'ST',
        @id_jugador_autor = 1,
        @id_jugador_asistente = NULL;

    PRINT '   [ERROR] El procedimiento debió fallar y no falló.';
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