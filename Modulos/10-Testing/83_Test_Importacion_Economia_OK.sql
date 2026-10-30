/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Pruebas exitosas de 19_SP_Importacion_Economia.sql: cotizaciones del
          BCE (XML), API Frankfurter y API del Banco Mundial. Se verifica la
          conversión de monedas a USD hecha en T-SQL y que las
          reimportaciones no dupliquen registros históricos.
          Requiere conexión a internet para las APIs.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS EXITOSAS: 83_Test_Importacion_Economia_OK';
PRINT N'=====================================================================';
GO

-------------------------------------------------------------------------------
-- 1. Cotizaciones del BCE (XML, base EUR)
-- Resultado esperado: estado OK; la reimportación no agrega filas. Para cada
-- fecha, cotizacion_usd(EUR) es el valor del USD en el archivo y
-- cotizacion_usd(X) = valor del USD / valor de X.
-------------------------------------------------------------------------------
PRINT N'-> Test 1: cotizaciones del BCE (XML)';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\eurofxref-hist-90d.xml';
DECLARE @v_id INT;
DECLARE @v_antes INT = (SELECT COUNT(*) FROM publicidad.tipo_cambio);

EXEC soporte.usp_Importar_TipoCambioXml @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;

SELECT @v_antes AS cotizaciones_antes, (SELECT COUNT(*) FROM publicidad.tipo_cambio) AS cotizaciones_despues,
       CASE WHEN (SELECT COUNT(*) FROM publicidad.tipo_cambio) = @v_antes
             AND (SELECT estado FROM soporte.importacion WHERE id_importacion = @v_id) = 'OK'
            THEN N'PASS sin duplicados' ELSE N'FAIL' END AS resultado;

PRINT N'--- Evidencia: ultima fecha importada, EUR y otras monedas expresadas en USD ---';
SELECT TOP (8) m.cod_iso4217, m.nombre, tc.fecha, tc.cotizacion_usd,
       CONVERT(DECIMAL(18,4), 1 / tc.cotizacion_usd) AS unidades_por_usd
FROM publicidad.tipo_cambio AS tc
JOIN publicidad.moneda AS m ON m.id_moneda = tc.id_moneda
WHERE tc.fecha = (SELECT MAX(x.fecha) FROM publicidad.tipo_cambio AS x JOIN publicidad.moneda AS y ON y.id_moneda = x.id_moneda WHERE y.cod_iso4217 = 'EUR')
  AND m.cod_iso4217 IN ('EUR', 'GBP', 'JPY', 'MXN', 'CAD', 'BRL', 'CHF', 'KRW')
ORDER BY m.cod_iso4217;
GO

-------------------------------------------------------------------------------
-- 2. API Frankfurter: cotizaciones del período del Mundial (base USD)
-- Resultado esperado: estado OK; cotizacion_usd(X) = 1 / (X por USD).
-- Al repetir la llamada no se agregan filas.
-------------------------------------------------------------------------------
PRINT N'-> Test 2: API Frankfurter';
DECLARE @v_id1 INT, @v_id2 INT;
DECLARE @v_despues1 INT;

EXEC soporte.usp_Importar_TipoCambioApi
    @fecha_desde = '2026-06-11', @fecha_hasta = '2026-07-19', @monedas = N'EUR,MXN,CAD,GBP,BRL,JPY',
    @id_importacion = @v_id1 OUTPUT;
SET @v_despues1 = (SELECT COUNT(*) FROM publicidad.tipo_cambio);

EXEC soporte.usp_Importar_TipoCambioApi
    @fecha_desde = '2026-06-11', @fecha_hasta = '2026-07-19', @monedas = N'EUR,MXN,CAD,GBP,BRL,JPY',
    @id_importacion = @v_id2 OUTPUT;

SELECT (SELECT estado FROM soporte.importacion WHERE id_importacion = @v_id1) AS estado_primera,
       (SELECT filas_ok FROM soporte.importacion WHERE id_importacion = @v_id1) AS filas_ok_primera,
       @v_despues1 AS cotizaciones_tras_primera,
       (SELECT COUNT(*) FROM publicidad.tipo_cambio) AS cotizaciones_tras_segunda,
       CASE WHEN (SELECT estado FROM soporte.importacion WHERE id_importacion = @v_id1) = 'OK'
             AND (SELECT COUNT(*) FROM publicidad.tipo_cambio) = @v_despues1
            THEN N'PASS' ELSE N'FAIL' END AS resultado;

PRINT N'--- Evidencia: tarifa de 1000 MXN el dia de la final convertida a USD ---';
SELECT m.cod_iso4217, tc.fecha, tc.cotizacion_usd,
       publicidad.fn_ImporteEnUSD(1000, m.id_moneda, '2026-07-19') AS mil_unidades_en_usd
FROM publicidad.moneda AS m
JOIN publicidad.tipo_cambio AS tc ON tc.id_moneda = m.id_moneda
WHERE m.cod_iso4217 = 'MXN'
  AND tc.fecha = (SELECT MAX(x.fecha) FROM publicidad.tipo_cambio AS x WHERE x.id_moneda = m.id_moneda AND x.fecha <= '2026-07-19');
GO

-------------------------------------------------------------------------------
-- 3. API del Banco Mundial: PBI per cápita (NY.GDP.PCAP.CD) 2022-2024
-- Resultado esperado: estado OK; los agregados regionales se omiten; al
-- repetir la llamada no se agregan filas (un registro por país y año).
-------------------------------------------------------------------------------
PRINT N'-> Test 3: API del Banco Mundial';
DECLARE @v_id1 INT, @v_id2 INT, @v_despues1 INT;

EXEC soporte.usp_Importar_IndicadorApi @anio_desde = 2022, @anio_hasta = 2024, @id_importacion = @v_id1 OUTPUT;
SET @v_despues1 = (SELECT COUNT(*) FROM geo.indicador_pais);

EXEC soporte.usp_Importar_IndicadorApi @anio_desde = 2022, @anio_hasta = 2024, @id_importacion = @v_id2 OUTPUT;

SELECT (SELECT estado FROM soporte.importacion WHERE id_importacion = @v_id1) AS estado_primera,
       @v_despues1 AS indicadores_tras_primera,
       (SELECT COUNT(*) FROM geo.indicador_pais) AS indicadores_tras_segunda,
       CASE WHEN (SELECT estado FROM soporte.importacion WHERE id_importacion = @v_id1) = 'OK'
             AND (SELECT COUNT(*) FROM geo.indicador_pais) = @v_despues1
             AND @v_despues1 > 0
            THEN N'PASS' ELSE N'FAIL' END AS resultado;

PRINT N'--- Evidencia: mercados de mayor PBI per capita en 2024 entre las selecciones ---';
SELECT TOP (10) p.nombre, i.anio, i.valor AS pbi_per_capita_usd
FROM geo.indicador_pais AS i
JOIN geo.pais AS p ON p.id_pais = i.id_pais
WHERE i.codigo_indicador = 'NY.GDP.PCAP.CD' AND i.anio = 2024
  AND EXISTS (SELECT 1 FROM torneo.seleccion AS s WHERE s.id_pais = p.id_pais)
ORDER BY i.valor DESC;
GO

PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS EXITOSAS: 83_Test_Importacion_Economia_OK';
PRINT N'=====================================================================';
GO
