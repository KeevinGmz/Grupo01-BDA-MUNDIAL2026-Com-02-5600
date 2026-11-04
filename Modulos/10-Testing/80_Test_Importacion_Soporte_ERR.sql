/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Pruebas de error de 17_SP_Importacion_Soporte.sql: cada caso debe
          lanzar una excepción con un mensaje claro. Se muestra el número y el
          mensaje recibidos y PASS si coinciden con lo esperado.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT '=====================================================================';
PRINT 'INICIO PRUEBAS DE ERROR: 80_Test_Importacion_Soporte_ERR';
PRINT '=====================================================================';
GO

-------------------------------------------------------------------------------
-- Caso 1: ruta inválida (relativa, con comilla y con extensión no admitida)
-- Resultado esperado: error 50001 que agrupa los tres problemas.
-------------------------------------------------------------------------------
PRINT '-> Test 1: ruta de archivo invalida';
DECLARE @v_texto VARCHAR(MAX), @v_nro INT, @v_msj VARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Archivo_Leer @archivo = 'datos\o''brien.exe', @contenido = @v_texto OUTPUT;
    SELECT @v_nro = 0, @v_msj = 'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50001 AND @v_msj LIKE '%comillas%' AND @v_msj LIKE '%absoluta%' AND @v_msj LIKE '%extension%'
            THEN 'PASS' ELSE 'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 2: archivo inexistente
-- Resultado esperado: error 50002 indicando que no se pudo leer el archivo.
-------------------------------------------------------------------------------
PRINT '-> Test 2: archivo inexistente';
DECLARE @v_texto VARCHAR(MAX), @v_nro INT, @v_msj VARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Archivo_Leer @archivo = 'C:\Mundial2026\datos\no_existe_80.json', @contenido = @v_texto OUTPUT;
    SELECT @v_nro = 0, @v_msj = 'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50002 AND @v_msj LIKE '%no se pudo leer el archivo%' THEN 'PASS' ELSE 'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 3: carga con BULK INSERT hacia una tabla no autorizada
-- Resultado esperado: error 50001 (solo se admiten las vistas de carga).
-------------------------------------------------------------------------------
PRINT '-> Test 3: vista de carga no admitida';
DECLARE @v_filas INT, @v_nro INT, @v_msj VARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Archivo_CargarDelimitado
        @archivo = 'C:\Mundial2026\datos\country-codes.csv',
        @vista_destino = 'geo.pais',
        @es_csv = 1,
        @primera_fila = 2,
        @filas_cargadas = @v_filas OUTPUT;
    SELECT @v_nro = 0, @v_msj = 'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50001 AND @v_msj LIKE '%vista de carga no admitida%' THEN 'PASS' ELSE 'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 4: URL inválida para el cliente HTTP
-- Resultado esperado: error 50001 (la url debe comenzar con http:// o https://).
-------------------------------------------------------------------------------
PRINT '-> Test 4: url invalida';
DECLARE @v_resp VARCHAR(MAX), @v_estado INT, @v_nro INT, @v_msj VARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Http_Obtener @url = 'ftp://servidor/archivo.csv', @contenido = @v_resp OUTPUT, @estado_http = @v_estado OUTPUT;
    SELECT @v_nro = 0, @v_msj = 'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50001 AND @v_msj LIKE '%http%' THEN 'PASS' ELSE 'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 5: recurso inexistente en el servidor (HTTP 404)
-- Resultado esperado: error 50002 con el estado HTTP recibido.
-------------------------------------------------------------------------------
PRINT '-> Test 5: pagina inexistente (404)';
DECLARE @v_resp VARCHAR(MAX), @v_estado INT, @v_nro INT, @v_msj VARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Http_Obtener @url = 'https://api.frankfurter.dev/v1/no-existe-80',
         @contenido = @v_resp OUTPUT, @estado_http = @v_estado OUTPUT;
    SELECT @v_nro = 0, @v_msj = 'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50002 AND @v_msj LIKE '%estado HTTP 404%' THEN 'PASS' ELSE 'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 6: iniciar una importación dentro de una transacción abierta
-- Resultado esperado: error 50003 (las importaciones confirman fila a fila).
-------------------------------------------------------------------------------
PRINT '-> Test 6: importacion dentro de una transaccion';
DECLARE @v_id INT, @v_nro INT, @v_msj VARCHAR(2048);
BEGIN TRANSACTION;
BEGIN TRY
    EXEC soporte.usp_Importacion_Iniciar @fuente = 'Prueba 80', @archivo = 'C:\x.csv', @formato = 'CSV',
         @id_importacion = @v_id OUTPUT;
    SELECT @v_nro = 0, @v_msj = 'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50003 AND @v_msj LIKE '%fuera de una transaccion%' THEN 'PASS' ELSE 'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 7: equivalencia con un país inexistente y código ISO2 de 3 letras
-- Resultado esperado: error 50001 que agrupa ambas validaciones.
-------------------------------------------------------------------------------
PRINT '-> Test 7: equivalencia de pais invalida';
DECLARE @v_nro INT, @v_msj VARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_EquivalenciaPais_Insertar @tipo = 'ISO2', @valor = 'ARG', @id_pais = -1, @fuente = 'Prueba 80';
    SELECT @v_nro = 0, @v_msj = 'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50001 AND @v_msj LIKE '%2 letras%' AND @v_msj LIKE '%pais inexistente%' THEN 'PASS' ELSE 'FAIL' END AS resultado;
GO

PRINT '=====================================================================';
PRINT 'FIN PRUEBAS DE ERROR: 80_Test_Importacion_Soporte_ERR';
PRINT '=====================================================================';
GO
