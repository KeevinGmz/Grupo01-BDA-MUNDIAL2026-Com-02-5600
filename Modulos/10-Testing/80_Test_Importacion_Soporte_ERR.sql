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

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS DE ERROR: 80_Test_Importacion_Soporte_ERR';
PRINT N'=====================================================================';
GO

-------------------------------------------------------------------------------
-- Caso 1: ruta inválida (relativa, con comilla y con extensión no admitida)
-- Resultado esperado: error 50001 que agrupa los tres problemas.
-------------------------------------------------------------------------------
PRINT N'-> Test 1: ruta de archivo invalida';
DECLARE @v_texto NVARCHAR(MAX), @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Archivo_Leer @archivo = N'datos\o''brien.exe', @contenido = @v_texto OUTPUT;
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50001 AND @v_msj LIKE N'%comillas%' AND @v_msj LIKE N'%absoluta%' AND @v_msj LIKE N'%extension%'
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 2: archivo inexistente
-- Resultado esperado: error 50002 indicando que no se pudo leer el archivo.
-------------------------------------------------------------------------------
PRINT N'-> Test 2: archivo inexistente';
DECLARE @v_texto NVARCHAR(MAX), @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Archivo_Leer @archivo = N'C:\Mundial2026\datos\no_existe_80.json', @contenido = @v_texto OUTPUT;
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50002 AND @v_msj LIKE N'%no se pudo leer el archivo%' THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 3: carga con BULK INSERT hacia una tabla no autorizada
-- Resultado esperado: error 50001 (solo se admiten las vistas de carga).
-------------------------------------------------------------------------------
PRINT N'-> Test 3: vista de carga no admitida';
DECLARE @v_filas INT, @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Archivo_CargarDelimitado
        @archivo = N'C:\Mundial2026\datos\country-codes.csv',
        @vista_destino = N'geo.pais',
        @es_csv = 1,
        @primera_fila = 2,
        @filas_cargadas = @v_filas OUTPUT;
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50001 AND @v_msj LIKE N'%vista de carga no admitida%' THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 4: URL inválida para el cliente HTTP
-- Resultado esperado: error 50001 (la url debe comenzar con http:// o https://).
-------------------------------------------------------------------------------
PRINT N'-> Test 4: url invalida';
DECLARE @v_resp NVARCHAR(MAX), @v_estado INT, @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Http_Obtener @url = N'ftp://servidor/archivo.csv', @contenido = @v_resp OUTPUT, @estado_http = @v_estado OUTPUT;
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50001 AND @v_msj LIKE N'%http%' THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 5: recurso inexistente en el servidor (HTTP 404)
-- Resultado esperado: error 50002 con el estado HTTP recibido.
-------------------------------------------------------------------------------
PRINT N'-> Test 5: pagina inexistente (404)';
DECLARE @v_resp NVARCHAR(MAX), @v_estado INT, @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Http_Obtener @url = N'https://api.frankfurter.dev/v1/no-existe-80',
         @contenido = @v_resp OUTPUT, @estado_http = @v_estado OUTPUT;
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50002 AND @v_msj LIKE N'%estado HTTP 404%' THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 6: iniciar una importación dentro de una transacción abierta
-- Resultado esperado: error 50003 (las importaciones confirman fila a fila).
-------------------------------------------------------------------------------
PRINT N'-> Test 6: importacion dentro de una transaccion';
DECLARE @v_id INT, @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRANSACTION;
BEGIN TRY
    EXEC soporte.usp_Importacion_Iniciar @fuente = N'Prueba 80', @archivo = N'C:\x.csv', @formato = 'CSV',
         @id_importacion = @v_id OUTPUT;
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50003 AND @v_msj LIKE N'%fuera de una transaccion%' THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 7: equivalencia con un país inexistente y código ISO2 de 3 letras
-- Resultado esperado: error 50001 que agrupa ambas validaciones.
-------------------------------------------------------------------------------
PRINT N'-> Test 7: equivalencia de pais invalida';
DECLARE @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_EquivalenciaPais_Insertar @tipo = 'ISO2', @valor = N'ARG', @id_pais = -1, @fuente = N'Prueba 80';
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;
SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50001 AND @v_msj LIKE N'%2 letras%' AND @v_msj LIKE N'%pais inexistente%' THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS DE ERROR: 80_Test_Importacion_Soporte_ERR';
PRINT N'=====================================================================';
GO
