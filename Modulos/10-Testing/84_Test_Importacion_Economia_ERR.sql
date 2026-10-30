/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Pruebas de error de 19_SP_Importacion_Economia.sql: XML mal formado,
          XML con cotizaciones inválidas (errores por fila), parámetros
          inválidos para las APIs y error devuelto por la API del Banco
          Mundial.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS DE ERROR: 84_Test_Importacion_Economia_ERR';
PRINT N'=====================================================================';
GO

-------------------------------------------------------------------------------
-- Caso 1: XML mal formado (xml_invalido.xml)
-- Resultado esperado: excepción 50002 y la importación queda CON_ERROR.
-------------------------------------------------------------------------------
PRINT N'-> Test 1: XML mal formado';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\pruebas\xml_invalido.xml';
DECLARE @v_id INT, @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Importar_TipoCambioXml @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;

SELECT TOP (1) @v_id = id_importacion FROM soporte.importacion WHERE archivo = @v_archivo ORDER BY id_importacion DESC;

SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50002 AND @v_msj LIKE N'%XML%'
             AND (SELECT estado FROM soporte.importacion WHERE id_importacion = @v_id) = 'CON_ERROR'
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 2: XML con cotizaciones inválidas (ecb_con_errores.xml)
-- - 30/02/2026: fecha inexistente (JPY rechazado; el USD se omite).
-- - 03/01/2001: GBP sin cotización del USD ese día: no se puede convertir.
-- - 04/01/2001: el USD no es numérico, código de moneda inválido (1AB),
--   cotización no numérica (CHF) y negativa (SEK).
-- Resultado esperado: CON_ERROR, ninguna fila válida y ninguna cotización
-- nueva en publicidad.tipo_cambio.
-------------------------------------------------------------------------------
PRINT N'-> Test 2: cotizaciones invalidas en el XML';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\pruebas\ecb_con_errores.xml';
DECLARE @v_id INT;
DECLARE @v_antes INT = (SELECT COUNT(*) FROM publicidad.tipo_cambio);

EXEC soporte.usp_Importar_TipoCambioXml @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;

SELECT i.estado, i.filas_leidas, i.filas_ok, i.filas_error,
       CASE WHEN i.estado = 'CON_ERROR' AND i.filas_ok = 0 AND i.filas_error >= 5
             AND (SELECT COUNT(*) FROM publicidad.tipo_cambio) = @v_antes
            THEN N'PASS' ELSE N'FAIL' END AS resultado
FROM soporte.importacion AS i
WHERE i.id_importacion = @v_id;
GO

-------------------------------------------------------------------------------
-- Caso 3: parámetros inválidos para la API Frankfurter
-- Resultado esperado: excepción 50001 (período invertido y lista de monedas
-- con caracteres no permitidos), sin registrar importación.
-------------------------------------------------------------------------------
PRINT N'-> Test 3: parametros invalidos para la API de cotizaciones';
DECLARE @v_antes INT = (SELECT COUNT(*) FROM soporte.importacion);
DECLARE @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Importar_TipoCambioApi @fecha_desde = '2026-07-19', @fecha_hasta = '2026-06-11', @monedas = N'EUR;DROP';
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;

SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50001 AND @v_msj LIKE N'%fecha_desde%' AND @v_msj LIKE N'%monedas%'
             AND (SELECT COUNT(*) FROM soporte.importacion) = @v_antes
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 4: cotizaciones futuras
-- Resultado esperado: excepción 50001 (no se pueden pedir cotizaciones futuras).
-------------------------------------------------------------------------------
PRINT N'-> Test 4: cotizaciones futuras';
DECLARE @v_desde DATE = DATEADD(DAY, 10, CONVERT(DATE, SYSDATETIME()));
DECLARE @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Importar_TipoCambioApi @fecha_desde = @v_desde;
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;

SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50001 AND @v_msj LIKE N'%futuras%' THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 5: indicador inexistente en la API del Banco Mundial
-- Resultado esperado: la API responde con un mensaje de error; el SP lanza
-- la excepción 50002 y deja la importación CON_ERROR con ese mensaje.
-------------------------------------------------------------------------------
PRINT N'-> Test 5: indicador inexistente en el Banco Mundial';
DECLARE @v_id INT, @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Importar_IndicadorApi @anio_desde = 2023, @indicador = 'XX.NO.EXISTE', @id_importacion = @v_id OUTPUT;
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;

SELECT TOP (1) @v_id = id_importacion FROM soporte.importacion WHERE archivo LIKE N'%XX.NO.EXISTE%' ORDER BY id_importacion DESC;

SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50002 AND (SELECT estado FROM soporte.importacion WHERE id_importacion = @v_id) = 'CON_ERROR'
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS DE ERROR: 84_Test_Importacion_Economia_ERR';
PRINT N'=====================================================================';
GO
