/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-26
Objetivo: Entrega 7. Verifica que las tablas que alimentan los reportes tienen
          datos suficientes. Muestra OK / REVISAR por cada control. Solo lectura.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

SELECT control, cantidad, minimo_esperado,
       CASE WHEN cantidad >= minimo_esperado THEN 'OK' ELSE 'REVISAR' END AS resultado
FROM
(
    SELECT 'Sedes' AS control, (SELECT COUNT(*) FROM torneo.sede) AS cantidad, 8 AS minimo_esperado
    UNION ALL SELECT 'Selecciones', (SELECT COUNT(*) FROM torneo.seleccion), 16
    UNION ALL SELECT 'Convocados activos', (SELECT COUNT(*) FROM torneo.convocatoria WHERE estado = 'ACTIVO'), 368
    UNION ALL SELECT 'Partidos', (SELECT COUNT(*) FROM torneo.partido), 24
    UNION ALL SELECT 'Partidos FINALIZADOS', (SELECT COUNT(*) FROM torneo.partido WHERE estado = 'FINALIZADO'), 10
    UNION ALL SELECT 'Alineaciones', (SELECT COUNT(*) FROM juego.alineacion), 1
    UNION ALL SELECT 'Goles', (SELECT COUNT(*) FROM juego.gol), 10
    UNION ALL SELECT 'Goleadores distintos', (SELECT COUNT(DISTINCT id_jugador_autor) FROM juego.gol), 5
    UNION ALL SELECT 'Tarjetas amarillas', (SELECT COUNT(*) FROM juego.tarjeta t JOIN juego.tipo_tarjeta tt ON tt.id_tipo = t.id_tipo WHERE tt.descripcion = 'AMARILLA'), 1
    UNION ALL SELECT 'Rojas por doble amarilla', (SELECT COUNT(*) FROM juego.tarjeta t JOIN juego.tipo_tarjeta tt ON tt.id_tipo = t.id_tipo WHERE tt.descripcion = 'ROJA_DOBLE_AMARILLA'), 1
    UNION ALL SELECT 'Rojas directas', (SELECT COUNT(*) FROM juego.tarjeta t JOIN juego.tipo_tarjeta tt ON tt.id_tipo = t.id_tipo WHERE tt.descripcion = 'ROJA_DIRECTA'), 1
    UNION ALL SELECT 'Suspensiones (todas)', (SELECT COUNT(*) FROM juego.suspension), 1
    UNION ALL SELECT 'Suspensiones activas (PENDIENTE)', (SELECT COUNT(*) FROM juego.suspension WHERE estado = 'PENDIENTE'), 1
    UNION ALL SELECT 'Arbitros', (SELECT COUNT(*) FROM persona.arbitro), 15
    UNION ALL SELECT 'Designaciones', (SELECT COUNT(*) FROM arbitraje.designacion_arbitral), 24
    UNION ALL SELECT 'Anunciantes', (SELECT COUNT(*) FROM publicidad.anunciante), 6
    UNION ALL SELECT 'Paises de anunciantes distintos', (SELECT COUNT(DISTINCT id_pais) FROM publicidad.anunciante), 6
    UNION ALL SELECT 'Mercados de piezas distintos', (SELECT COUNT(DISTINCT id_pais_mercado) FROM publicidad.pieza_publicitaria), 5
    UNION ALL SELECT 'Exhibiciones', (SELECT COUNT(*) FROM publicidad.exhibicion), 4
    UNION ALL SELECT 'Tipos de cambio', (SELECT COUNT(*) FROM publicidad.tipo_cambio), 1
    UNION ALL SELECT 'Indicadores PBI per capita', (SELECT COUNT(*) FROM geo.indicador_pais WHERE codigo_indicador = 'NY.GDP.PCAP.CD'), 1
) AS v
ORDER BY CASE WHEN cantidad >= minimo_esperado THEN 1 ELSE 0 END, control;
GO

-- Casos obligatorios del enunciado (seccion IV) que alimentan los reportes
SELECT 'Partido con prime time en mas de 4 mercados' AS caso,
       COUNT(*) AS partidos
FROM
(
    SELECT p.id_partido
    FROM torneo.partido AS p
    CROSS JOIN (SELECT DISTINCT id_pais_mercado AS id_pais
                FROM publicidad.pieza_publicitaria
                WHERE id_pais_mercado IS NOT NULL) AS m
    GROUP BY p.id_partido
    HAVING SUM(CONVERT(INT, publicidad.fn_EsPrimeTime(p.id_partido, m.id_pais))) > 4
) AS x;
-- Esperado: al menos 1. Si da 0, ajustar el horario de un partido o sumar mercados.
GO
