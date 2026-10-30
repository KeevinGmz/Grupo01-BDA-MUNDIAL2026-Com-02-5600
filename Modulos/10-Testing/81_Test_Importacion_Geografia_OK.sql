/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Pruebas exitosas de 18_SP_Importacion_Geografia.sql. Los datos ya
          se cargaron en 39_Importacion_Carga_Inicial.sql; aquí se vuelven a
          importar los mismos archivos para demostrar el upsert: no se
          generan duplicados y las filas quedan "sin cambios". Se muestra
          evidencia de los datos importados.
          Las importaciones confirman cada fila, por eso no se revierten.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS EXITOSAS: 81_Test_Importacion_Geografia_OK';
PRINT N'=====================================================================';
GO

-------------------------------------------------------------------------------
-- 1. Países y monedas (CSV)
-- Resultado esperado: estado OK, 0 insertadas, la cantidad de países y de
-- monedas no cambia (no hay duplicados).
-------------------------------------------------------------------------------
PRINT N'-> Test 1: reimportacion de paises (CSV)';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\country-codes.csv';
DECLARE @v_id INT;
DECLARE @v_paises_antes INT = (SELECT COUNT(*) FROM geo.pais);
DECLARE @v_monedas_antes INT = (SELECT COUNT(*) FROM publicidad.moneda);

EXEC soporte.usp_Importar_PaisesCsv @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;

SELECT @v_paises_antes AS paises_antes, (SELECT COUNT(*) FROM geo.pais) AS paises_despues,
       @v_monedas_antes AS monedas_antes, (SELECT COUNT(*) FROM publicidad.moneda) AS monedas_despues,
       CASE WHEN (SELECT COUNT(*) FROM geo.pais) = @v_paises_antes
             AND (SELECT COUNT(*) FROM publicidad.moneda) = @v_monedas_antes
             AND (SELECT estado FROM soporte.importacion WHERE id_importacion = @v_id) = 'OK'
            THEN N'PASS' ELSE N'FAIL' END AS resultado;

PRINT N'--- Evidencia: paises de las selecciones con su confederacion y monedas ---';
SELECT TOP (10) p.nombre, p.cod_iso3, p.cod_fifa, c.sigla AS confederacion
FROM geo.pais AS p
JOIN geo.confederacion AS c ON c.id_confederacion = p.id_confederacion
WHERE p.cod_iso3 IN ('ARG', 'BRA', 'MEX', 'USA', 'DEU', 'ESP', 'JPN', 'AUS', 'TUR', 'ENG')
ORDER BY p.nombre;
GO

-------------------------------------------------------------------------------
-- 2. Husos horarios (TXT)
-- Resultado esperado: estado OK y sin altas nuevas. Buenos Aires con -180
-- minutos y sin horario de verano; Nueva York con -300 y horario de verano.
-------------------------------------------------------------------------------
PRINT N'-> Test 2: reimportacion de husos horarios (TXT)';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\timeZones.txt';
DECLARE @v_id INT;
DECLARE @v_antes INT = (SELECT COUNT(*) FROM geo.huso_horario);

EXEC soporte.usp_Importar_HusosTxt @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;

SELECT zona_horaria, offset_utc, horario_verano
FROM geo.huso_horario
WHERE zona_horaria IN (N'America/Argentina/Buenos_Aires', N'America/New_York', N'Europe/Madrid', N'Asia/Tokyo');

SELECT @v_antes AS husos_antes, (SELECT COUNT(*) FROM geo.huso_horario) AS husos_despues,
       CASE WHEN (SELECT COUNT(*) FROM geo.huso_horario) = @v_antes
             AND EXISTS (SELECT 1 FROM geo.huso_horario WHERE zona_horaria = N'America/Argentina/Buenos_Aires' AND offset_utc = -180 AND horario_verano = 0)
             AND EXISTS (SELECT 1 FROM geo.huso_horario WHERE zona_horaria = N'America/New_York' AND offset_utc = -300 AND horario_verano = 1)
             AND (SELECT estado FROM soporte.importacion WHERE id_importacion = @v_id) = 'OK'
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- 3. Ciudades (TXT)
-- Resultado esperado: sin altas nuevas; las capitales quedan cargadas con su
-- huso (Buenos Aires, Bogotá) y el huso de cada país es el de su ciudad
-- más poblada (geo.fn_HusoDePais).
-------------------------------------------------------------------------------
PRINT N'-> Test 3: reimportacion de ciudades (TXT)';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\cities15000.txt';
DECLARE @v_id INT;
DECLARE @v_antes INT = (SELECT COUNT(*) FROM geo.ciudad);

EXEC soporte.usp_Importar_CiudadesTxt @archivo = @v_archivo, @poblacion_minima = 100000, @id_importacion = @v_id OUTPUT;

SELECT TOP (5) c.nombre, p.nombre AS pais, c.poblacion, h.zona_horaria
FROM geo.ciudad AS c
JOIN geo.pais AS p ON p.id_pais = c.id_pais
JOIN geo.huso_horario AS h ON h.id_huso = c.id_huso
WHERE p.cod_iso3 IN ('ARG', 'COL', 'USA')
ORDER BY c.poblacion DESC;

SELECT @v_antes AS ciudades_antes, (SELECT COUNT(*) FROM geo.ciudad) AS ciudades_despues,
       CASE WHEN (SELECT COUNT(*) FROM geo.ciudad) = @v_antes
             AND EXISTS (SELECT 1 FROM geo.ciudad AS c JOIN geo.huso_horario AS h ON h.id_huso = c.id_huso
                         WHERE c.nombre = N'Buenos Aires' AND h.zona_horaria = N'America/Argentina/Buenos_Aires')
             -- El archivo real trae ciudades de territorios sin país cargado
             -- (GS, TF, XK): quedan informadas como error de fila.
             AND (SELECT i.filas_error FROM soporte.importacion AS i WHERE i.id_importacion = @v_id)
                 = (SELECT COUNT(*) FROM soporte.importacion_error AS e
                    WHERE e.id_importacion = @v_id AND e.mensaje LIKE N'pais inexistente%')
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- 4. Sedes (JSON)
-- Resultado esperado: las 16 sedes del Mundial siguen siendo 16, con
-- coordenadas en grados decimales y su ciudad.
-------------------------------------------------------------------------------
PRINT N'-> Test 4: reimportacion de sedes (JSON)';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\worldcup.stadiums.json';
DECLARE @v_id INT;
DECLARE @v_antes INT = (SELECT COUNT(*) FROM torneo.sede);

EXEC soporte.usp_Importar_SedesJson @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;

SELECT s.nombre_estadio, c.nombre AS ciudad, p.nombre AS pais, s.capacidad, s.latitud, s.longitud, h.zona_horaria
FROM torneo.sede AS s
JOIN geo.ciudad AS c ON c.id_ciudad = s.id_ciudad
JOIN geo.pais AS p ON p.id_pais = c.id_pais
JOIN geo.huso_horario AS h ON h.id_huso = c.id_huso
WHERE s.latitud IS NOT NULL
ORDER BY s.nombre_estadio;

SELECT @v_antes AS sedes_antes, (SELECT COUNT(*) FROM torneo.sede) AS sedes_despues,
       CASE WHEN (SELECT COUNT(*) FROM torneo.sede) = @v_antes
             AND (SELECT COUNT(*) FROM torneo.sede WHERE latitud IS NOT NULL) = 16
             AND (SELECT estado FROM soporte.importacion WHERE id_importacion = @v_id) = 'OK'
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- 5. Selecciones (JSON)
-- Resultado esperado: 48 selecciones del torneo en 12 grupos de 4, con los
-- tres anfitriones marcados, sin altas nuevas al reimportar.
-------------------------------------------------------------------------------
PRINT N'-> Test 5: reimportacion de selecciones (JSON)';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\worldcup.teams.json';
DECLARE @v_id INT;
DECLARE @v_antes INT = (SELECT COUNT(*) FROM torneo.seleccion);

EXEC soporte.usp_Importar_SeleccionesJson @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;

SELECT s.id_letra AS grupo, STRING_AGG(p.nombre, N', ') WITHIN GROUP (ORDER BY p.nombre) AS selecciones
FROM torneo.seleccion AS s
JOIN geo.pais AS p ON p.id_pais = s.id_pais
GROUP BY s.id_letra
ORDER BY s.id_letra;

SELECT @v_antes AS selecciones_antes, (SELECT COUNT(*) FROM torneo.seleccion) AS selecciones_despues,
       CASE WHEN (SELECT COUNT(*) FROM torneo.seleccion) = @v_antes
             AND (SELECT COUNT(*) FROM torneo.seleccion WHERE es_anfitrion = 1) = 3
             AND (SELECT estado FROM soporte.importacion WHERE id_importacion = @v_id) = 'OK'
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS EXITOSAS: 81_Test_Importacion_Geografia_OK';
PRINT N'=====================================================================';
GO
