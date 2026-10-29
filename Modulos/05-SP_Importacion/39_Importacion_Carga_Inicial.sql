/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Entrega 6. Carga inicial de los datos de referencia mediante los SP
          de importación, antes de los scripts de seed (40 a 45), que
          necesitan países, husos, ciudades, sedes, selecciones, partidos y clubes.
===================================================================== */
USE Mundial2026;
GO

/*
   Antes de ejecutar:
   1. Copiar la carpeta "datos" del repositorio a C:\Mundial2026\datos\ (o
      cambiar @v_ruta en cada bloque). La cuenta del servicio de SQL Server
      debe poder leer esa carpeta.
   2. cities15000.txt se publica comprimido (cities15000.zip): se descomprime
      sin modificarlo.
   3. La importación de plantillas descarga la página de Wikipedia en el
      momento (requiere conexión a internet y Ole Automation Procedures).

   Orden: países -> husos -> ciudades -> sedes -> selecciones -> fixture
          -> plantillas -> cotizaciones del BCE.
   Cada bloque es independiente: si uno falla se informa y se sigue con el
   siguiente. Volver a ejecutar el script no duplica datos.
*/

PRINT N'=== 1/8 Paises y monedas (CSV) ===';
DECLARE @v_ruta NVARCHAR(200) = N'C:\Mundial2026\datos\';
DECLARE @v_archivo NVARCHAR(260) = @v_ruta + N'country-codes.csv';
EXEC soporte.usp_Importar_PaisesCsv @archivo = @v_archivo;
GO

PRINT N'=== 2/8 Husos horarios (TXT) ===';
DECLARE @v_ruta NVARCHAR(200) = N'C:\Mundial2026\datos\';
DECLARE @v_archivo NVARCHAR(260) = @v_ruta + N'timeZones.txt';
EXEC soporte.usp_Importar_HusosTxt @archivo = @v_archivo;
GO

PRINT N'=== 3/8 Ciudades (TXT) ===';
DECLARE @v_ruta NVARCHAR(200) = N'C:\Mundial2026\datos\';
DECLARE @v_archivo NVARCHAR(260) = @v_ruta + N'cities15000.txt';
EXEC soporte.usp_Importar_CiudadesTxt @archivo = @v_archivo, @poblacion_minima = 100000;
GO

PRINT N'=== 4/8 Sedes (JSON) ===';
DECLARE @v_ruta NVARCHAR(200) = N'C:\Mundial2026\datos\';
DECLARE @v_archivo NVARCHAR(260) = @v_ruta + N'worldcup.stadiums.json';
EXEC soporte.usp_Importar_SedesJson @archivo = @v_archivo;
GO

PRINT N'=== 5/8 Selecciones (JSON) ===';
DECLARE @v_ruta NVARCHAR(200) = N'C:\Mundial2026\datos\';
DECLARE @v_archivo NVARCHAR(260) = @v_ruta + N'worldcup.teams.json';
EXEC soporte.usp_Importar_SeleccionesJson @archivo = @v_archivo;
GO

PRINT N'=== 6/8 Fixture del torneo (JSON) ===';
DECLARE @v_ruta NVARCHAR(200) = N'C:\Mundial2026\datos\';
DECLARE @v_archivo NVARCHAR(260) = @v_ruta + N'worldcup.json';
EXEC soporte.usp_Negocio_ImportarFixture @archivo = @v_archivo;
GO

PRINT N'=== 7/8 Plantillas (scraping de Wikipedia) ===';
BEGIN TRY
    EXEC soporte.usp_Importar_PlantillasWikipedia;
END TRY
BEGIN CATCH
    -- Sin conexión la carga sigue: el seed 41 genera convocatorias de prueba.
    PRINT CONCAT(N'Aviso: no se pudieron importar las plantillas. ', ERROR_MESSAGE());
END CATCH;
GO

PRINT N'=== 8/8 Cotizaciones del BCE (XML) ===';
DECLARE @v_ruta NVARCHAR(200) = N'C:\Mundial2026\datos\';
DECLARE @v_archivo NVARCHAR(260) = @v_ruta + N'eurofxref-hist-90d.xml';
EXEC soporte.usp_Importar_TipoCambioXml @archivo = @v_archivo;
GO

-- Resumen de la carga
SELECT i.id_importacion, i.fuente, i.formato, i.filas_leidas, i.filas_ok, i.filas_error, i.estado,
       DATEDIFF(SECOND, i.fecha_inicio, i.fecha_fin) AS segundos
FROM soporte.importacion AS i
ORDER BY i.id_importacion;
GO
