/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Pruebas exitosas de 37_SP_Importacion_Plantillas.sql: scraping de
          la página de plantillas de Wikipedia en el momento. Al repetirse
          sobre datos ya cargados (39) demuestra que no se duplican jugadores,
          clubes ni convocatorias. Requiere conexión a internet.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS EXITOSAS: 85_Test_Importacion_Plantillas_OK';
PRINT N'=====================================================================';
GO

-------------------------------------------------------------------------------
-- 1. Scraping de las plantillas
-- Resultado esperado: se leen las filas de jugadores de las 48 selecciones
-- (26 por selección); la importación termina OK y la cantidad de jugadores,
-- clubes y convocados no cambia respecto de la carga inicial.
-------------------------------------------------------------------------------
PRINT N'-> Test 1: scraping de plantillas de Wikipedia';
DECLARE @v_id INT;
DECLARE @v_jugadores INT = (SELECT COUNT(*) FROM persona.jugador);
DECLARE @v_clubes INT = (SELECT COUNT(*) FROM persona.club);
DECLARE @v_convocados INT = (SELECT COUNT(*) FROM torneo.convocatoria WHERE estado = 'ACTIVO');

EXEC soporte.usp_Importar_PlantillasWikipedia @id_importacion = @v_id OUTPUT;

SELECT i.estado, i.filas_leidas, i.filas_ok, i.filas_error,
       @v_jugadores AS jugadores_antes, (SELECT COUNT(*) FROM persona.jugador) AS jugadores_despues,
       @v_clubes AS clubes_antes, (SELECT COUNT(*) FROM persona.club) AS clubes_despues,
       @v_convocados AS convocados_antes, (SELECT COUNT(*) FROM torneo.convocatoria WHERE estado = 'ACTIVO') AS convocados_despues,
       CASE WHEN i.estado = 'OK' AND i.filas_leidas >= 48 * 23
             AND (SELECT COUNT(*) FROM persona.jugador) = @v_jugadores
             AND (SELECT COUNT(*) FROM persona.club) = @v_clubes
             AND (SELECT COUNT(*) FROM torneo.convocatoria WHERE estado = 'ACTIVO') = @v_convocados
            THEN N'PASS' ELSE N'FAIL' END AS resultado
FROM soporte.importacion AS i
WHERE i.id_importacion = @v_id;
GO

-------------------------------------------------------------------------------
-- 2. Evidencia: plantilla de Argentina y convocados por selección
-- Resultado esperado: cada selección tiene entre 23 y 26 convocados activos,
-- con nombre, apellido, fecha de nacimiento, posición y club.
-------------------------------------------------------------------------------
PRINT N'-> Test 2: evidencia de plantillas importadas';

SELECT c.dorsal, p.apellido, p.nombre, p.fecha_nac, po.descripcion AS posicion, cl.nombre AS club, cl.pais_club, p.nro_doc
FROM torneo.convocatoria AS c
JOIN torneo.seleccion AS s ON s.id_seleccion = c.id_seleccion
JOIN geo.pais AS pa ON pa.id_pais = s.id_pais
JOIN persona.persona AS p ON p.id_persona = c.id_jugador
JOIN persona.jugador AS j ON j.id_persona = p.id_persona
JOIN persona.posicion AS po ON po.id_posicion = j.id_posicion_habitual
LEFT JOIN persona.club AS cl ON cl.id_club = j.id_club
WHERE pa.cod_fifa = 'ARG' AND c.estado = 'ACTIVO'
ORDER BY c.dorsal;

SELECT CASE WHEN NOT EXISTS (
            SELECT 1
            FROM torneo.seleccion AS s
            OUTER APPLY (SELECT COUNT(*) AS cantidad FROM torneo.convocatoria AS c
                         WHERE c.id_seleccion = s.id_seleccion AND c.estado = 'ACTIVO') AS x
            WHERE x.cantidad NOT BETWEEN 23 AND 26)
            THEN N'PASS todas las selecciones con 23 a 26 convocados'
            ELSE N'FAIL hay selecciones fuera del rango reglamentario' END AS resultado;
GO

PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS EXITOSAS: 85_Test_Importacion_Plantillas_OK';
PRINT N'=====================================================================';
GO
