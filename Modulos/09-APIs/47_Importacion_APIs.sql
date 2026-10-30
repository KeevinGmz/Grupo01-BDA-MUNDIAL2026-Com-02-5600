/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-28
Objetivo: Ejecuta las dos importaciones por API que el script 39 no
          incluye: PBI per capita (Banco Mundial) y tipo de cambio
          (Frankfurter, ultimos 30 dias). Requiere internet y la opcion
          Ole Automation Procedures (la habilita el script 17).
          Es repetible: el upsert evita duplicados. Si una API falla, avisa
          y continua con la siguiente.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT N'=== 1/2 PBI per capita (API del Banco Mundial, JSON) ===';
BEGIN TRY
    EXEC soporte.usp_Importar_IndicadorApi @anio_desde = 2022, @anio_hasta = 2024;
END TRY
BEGIN CATCH
    PRINT CONCAT(N'Aviso: no se pudo importar el PBI. ', ERROR_MESSAGE());
END CATCH;
GO

PRINT N'=== 2/2 Tipo de cambio (API Frankfurter, JSON) ===';
BEGIN TRY
    DECLARE @v_desde DATE = DATEADD(DAY, -30, CONVERT(DATE, GETDATE()));
    EXEC soporte.usp_Importar_TipoCambioApi @fecha_desde = @v_desde;
END TRY
BEGIN CATCH
    PRINT CONCAT(N'Aviso: no se pudo importar el tipo de cambio. ', ERROR_MESSAGE());
END CATCH;
GO

-- Resultado esperado: indicadores_pbi mayor a 0 (el control del script 89 pasa a OK)
SELECT
    (SELECT COUNT(*) FROM geo.indicador_pais
     WHERE codigo_indicador = 'NY.GDP.PCAP.CD') AS indicadores_pbi,
    (SELECT COUNT(*) FROM publicidad.tipo_cambio) AS cotizaciones;
GO
