/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Pruebas de error de 36_SP_Negocio_Importacion.sql (fixture): archivo
          inexistente, extensión inválida, ejecución dentro de una
          transacción e importación con errores parciales
          (datos\pruebas\fixture_con_errores.json).
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT '=====================================================================';
PRINT 'INICIO PRUEBAS DE ERROR: 77_Test_Importacion_ERR';
PRINT '=====================================================================';
GO

-------------------------------------------------------------------------------
-- Caso 1: archivo inexistente
-- Resultado esperado: excepción 50002; la importación queda registrada
-- CON_ERROR con el motivo en soporte.importacion_error.
-------------------------------------------------------------------------------
PRINT '-> Test 1: archivo de fixture inexistente';
DECLARE @v_archivo VARCHAR(260) = 'C:\Ruta_Inexistente_Mundial2026\fixture_que_no_existe_77.json';
DECLARE @v_id INT, @v_nro INT, @v_msj VARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Negocio_ImportarFixture @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;
    SELECT @v_nro = 0, @v_msj = 'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;

SELECT TOP (1) @v_id = id_importacion FROM soporte.importacion WHERE archivo = @v_archivo ORDER BY id_importacion DESC;

SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50002 AND (SELECT estado FROM soporte.importacion WHERE id_importacion = @v_id) = 'CON_ERROR'
            THEN 'PASS' ELSE 'FAIL' END AS resultado;

SELECT e.nro_fila, e.columna, e.mensaje FROM soporte.importacion_error AS e WHERE e.id_importacion = @v_id;
GO

-------------------------------------------------------------------------------
-- Caso 2: extensión no admitida y ruta con comilla
-- Resultado esperado: excepción 50001 antes de registrar la importación.
-------------------------------------------------------------------------------
PRINT '-> Test 2: ruta invalida';
DECLARE @v_antes INT = (SELECT COUNT(*) FROM soporte.importacion);
DECLARE @v_nro INT, @v_msj VARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Negocio_ImportarFixture @archivo = 'C:\Mundial2026\datos\fixture''2026.csv';
    SELECT @v_nro = 0, @v_msj = 'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;

SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50001 AND @v_msj LIKE '%comillas%' AND @v_msj LIKE '%extension%'
             AND (SELECT COUNT(*) FROM soporte.importacion) = @v_antes
            THEN 'PASS' ELSE 'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 3: ejecución dentro de una transacción
-- Resultado esperado: excepción 50001 (la importación confirma fila a fila).
-------------------------------------------------------------------------------
PRINT '-> Test 3: importacion dentro de una transaccion';
DECLARE @v_nro INT, @v_msj VARCHAR(2048);
BEGIN TRANSACTION;
BEGIN TRY
    EXEC soporte.usp_Negocio_ImportarFixture @archivo = 'C:\Mundial2026\datos\worldcup.json';
    SELECT @v_nro = 0, @v_msj = 'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50001 AND @v_msj LIKE '%transaccion%' THEN 'PASS' ELSE 'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 4: importación con errores parciales (fixture_con_errores.json)
-- Fila 1: México - Sudáfrica válida (ya importada: sin cambios).
-- Fila 2: ronda desconocida. Fila 3: selección inexistente (Atlantis).
-- Fila 4: ciudad sin sede (Springfield). Fila 5: fecha inválida.
-- Fila 6: desplazamiento horario inválido. Fila 7: grupo que no corresponde.
-- Resultado esperado: estado CON_ERROR, 1 fila ok y 6 errores (uno por fila
-- rechazada, con todos sus motivos), sin partidos nuevos.
-------------------------------------------------------------------------------
PRINT '-> Test 4: fixture con errores parciales';
DECLARE @v_archivo VARCHAR(260) = 'C:\Mundial2026\datos\pruebas\fixture_con_errores.json';
DECLARE @v_id INT;
DECLARE @v_antes INT = (SELECT COUNT(*) FROM torneo.partido);

EXEC soporte.usp_Negocio_ImportarFixture @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;

SELECT i.estado, i.filas_leidas, i.filas_ok, i.filas_error,
       CASE WHEN i.estado = 'CON_ERROR' AND i.filas_ok = 1 AND i.filas_error = 6
             AND (SELECT COUNT(*) FROM torneo.partido) = @v_antes
            THEN 'PASS' ELSE 'FAIL' END AS resultado
FROM soporte.importacion AS i
WHERE i.id_importacion = @v_id;
GO

PRINT '=====================================================================';
PRINT 'FIN PRUEBAS DE ERROR: 77_Test_Importacion_ERR';
PRINT '=====================================================================';
GO
