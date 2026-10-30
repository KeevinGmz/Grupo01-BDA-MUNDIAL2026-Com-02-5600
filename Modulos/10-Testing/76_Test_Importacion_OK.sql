/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Pruebas exitosas de 36_SP_Negocio_Importacion.sql (importación del
          fixture oficial). Se importa el fixture completo, se vuelve a
          importar para demostrar que no se generan duplicados y se muestra la
          evidencia de los partidos cargados.
          Las importaciones confirman cada fila, por eso no se revierten.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBA EXITOSA: 76_Test_Importacion_OK';
PRINT N'=====================================================================';
GO

IF OBJECT_ID(N'soporte.usp_Negocio_ImportarFixture', N'P') IS NULL
    THROW 50001, N'76_Test_Importacion_OK: no existe soporte.usp_Negocio_ImportarFixture', 1;
GO

-------------------------------------------------------------------------------
-- 1. Primera importación del fixture (104 partidos)
-- Resultado esperado: los partidos que no existían se registran; los cruces
-- que ya había cargado el seed (fase de grupos) se reconocen por la fase y
-- las selecciones, y se actualizan a la fecha y la sede oficiales.
-- Ninguna fila con error: estado OK.
-------------------------------------------------------------------------------
PRINT N'-> Test 1: primera importacion del fixture';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\worldcup.json';
DECLARE @v_id INT;

EXEC soporte.usp_Negocio_ImportarFixture @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;

SELECT i.id_importacion, i.estado, i.filas_leidas, i.filas_ok, i.filas_error,
       CASE WHEN i.estado = 'OK' AND i.filas_leidas = 104 AND i.filas_ok = 104 THEN N'PASS' ELSE N'FAIL' END AS resultado
FROM soporte.importacion AS i
WHERE i.id_importacion = @v_id;
GO

-------------------------------------------------------------------------------
-- 2. Segunda importación del mismo archivo
-- Resultado esperado: la cantidad de partidos no cambia y las 104 filas
-- quedan sin cambios (no hay duplicados).
-------------------------------------------------------------------------------
PRINT N'-> Test 2: reimportacion sin duplicados';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\worldcup.json';
DECLARE @v_id INT;
DECLARE @v_antes INT = (SELECT COUNT(*) FROM torneo.partido);

EXEC soporte.usp_Negocio_ImportarFixture @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;

SELECT @v_antes AS partidos_antes, (SELECT COUNT(*) FROM torneo.partido) AS partidos_despues,
       CASE WHEN (SELECT COUNT(*) FROM torneo.partido) = @v_antes
             AND (SELECT estado FROM soporte.importacion WHERE id_importacion = @v_id) = 'OK'
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- 3. Evidencia: partidos por fase y primeros partidos con hora UTC y local
-- Resultado esperado: 72 partidos de grupos, 16 de dieciseisavos, 8 de
-- octavos, 4 de cuartos, 2 semifinales, 1 tercer puesto y 1 final con sede
-- del Mundial. El partido inaugural (México - Sudáfrica) es el 11/06/2026 a
-- las 19:00 UTC (13:00 en Ciudad de México).
-------------------------------------------------------------------------------
PRINT N'-> Test 3: evidencia del fixture importado';

SELECT f.nro_fase, f.nombre AS fase, COUNT(*) AS partidos
FROM torneo.partido AS p
JOIN torneo.fase AS f ON f.nro_fase = p.nro_fase
JOIN torneo.sede AS s ON s.id_sede = p.id_sede
WHERE s.latitud IS NOT NULL
GROUP BY f.nro_fase, f.nombre
ORDER BY f.nro_fase;

SELECT TOP (6)
    p.id_partido,
    p.fecha_hora_utc,
    geo.fn_FechaHoraLocal(p.fecha_hora_utc, c.id_huso) AS fecha_hora_local_sede,
    s.nombre_estadio,
    c.nombre AS ciudad,
    pl.nombre AS local,
    pv.nombre AS visitante
FROM torneo.partido AS p
JOIN torneo.sede AS s ON s.id_sede = p.id_sede
JOIN geo.ciudad AS c ON c.id_ciudad = s.id_ciudad
JOIN torneo.equipo_en_partido AS el ON el.id_partido = p.id_partido AND el.condicion = 'L'
JOIN torneo.seleccion AS sl ON sl.id_seleccion = el.id_seleccion
JOIN geo.pais AS pl ON pl.id_pais = sl.id_pais
JOIN torneo.equipo_en_partido AS ev ON ev.id_partido = p.id_partido AND ev.condicion = 'V'
JOIN torneo.seleccion AS sv ON sv.id_seleccion = ev.id_seleccion
JOIN geo.pais AS pv ON pv.id_pais = sv.id_pais
WHERE s.latitud IS NOT NULL
ORDER BY p.fecha_hora_utc;

SELECT CASE WHEN EXISTS (
            SELECT 1
            FROM torneo.partido AS p
            JOIN torneo.equipo_en_partido AS e1 ON e1.id_partido = p.id_partido
            JOIN torneo.seleccion AS s1 ON s1.id_seleccion = e1.id_seleccion
            JOIN geo.pais AS p1 ON p1.id_pais = s1.id_pais AND p1.cod_fifa = 'MEX'
            JOIN torneo.equipo_en_partido AS e2 ON e2.id_partido = p.id_partido AND e2.id_seleccion <> e1.id_seleccion
            JOIN torneo.seleccion AS s2 ON s2.id_seleccion = e2.id_seleccion
            JOIN geo.pais AS p2 ON p2.id_pais = s2.id_pais AND p2.cod_fifa = 'RSA'
            WHERE p.fecha_hora_utc = '2026-06-11T19:00:00' AND p.nro_fase = 1)
            THEN N'PASS partido inaugural en fecha y hora UTC correctas'
            ELSE N'FAIL partido inaugural' END AS resultado;
GO

PRINT N'=====================================================================';
PRINT N'FIN PRUEBA EXITOSA: 76_Test_Importacion_OK';
PRINT N'=====================================================================';
GO
