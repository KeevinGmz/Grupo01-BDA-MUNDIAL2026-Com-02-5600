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
       CASE WHEN cantidad >= minimo_esperado THEN N'OK' ELSE N'REVISAR' END AS resultado
FROM
(
    SELECT N'Sedes' AS control, (SELECT COUNT(*) FROM torneo.sede) AS cantidad, 8 AS minimo_esperado
    UNION ALL SELECT N'Selecciones', (SELECT COUNT(*) FROM torneo.seleccion), 16
    UNION ALL SELECT N'Convocados activos', (SELECT COUNT(*) FROM torneo.convocatoria WHERE estado = 'ACTIVO'), 368
    UNION ALL SELECT N'Partidos', (SELECT COUNT(*) FROM torneo.partido), 24
    UNION ALL SELECT N'Partidos FINALIZADOS', (SELECT COUNT(*) FROM torneo.partido WHERE estado = 'FINALIZADO'), 10
    UNION ALL SELECT N'Alineaciones', (SELECT COUNT(*) FROM juego.alineacion), 1
    UNION ALL SELECT N'Goles', (SELECT COUNT(*) FROM juego.gol), 10
    UNION ALL SELECT N'Goleadores distintos', (SELECT COUNT(DISTINCT id_jugador_autor) FROM juego.gol), 5
    UNION ALL SELECT N'Tarjetas amarillas', (SELECT COUNT(*) FROM juego.tarjeta t JOIN juego.tipo_tarjeta tt ON tt.id_tipo = t.id_tipo WHERE tt.descripcion = N'AMARILLA'), 1
    UNION ALL SELECT N'Rojas por doble amarilla', (SELECT COUNT(*) FROM juego.tarjeta t JOIN juego.tipo_tarjeta tt ON tt.id_tipo = t.id_tipo WHERE tt.descripcion = N'ROJA_DOBLE_AMARILLA'), 1
    UNION ALL SELECT N'Rojas directas', (SELECT COUNT(*) FROM juego.tarjeta t JOIN juego.tipo_tarjeta tt ON tt.id_tipo = t.id_tipo WHERE tt.descripcion = N'ROJA_DIRECTA'), 1
    UNION ALL SELECT N'Suspensiones (todas)', (SELECT COUNT(*) FROM juego.suspension), 1
    UNION ALL SELECT N'Suspensiones activas (PENDIENTE)', (SELECT COUNT(*) FROM juego.suspension WHERE estado = 'PENDIENTE'), 1
    UNION ALL SELECT N'Arbitros', (SELECT COUNT(*) FROM persona.arbitro), 15
    UNION ALL SELECT N'Designaciones', (SELECT COUNT(*) FROM arbitraje.designacion_arbitral), 24
    UNION ALL SELECT N'Anunciantes', (SELECT COUNT(*) FROM publicidad.anunciante), 6
    UNION ALL SELECT N'Paises de anunciantes distintos', (SELECT COUNT(DISTINCT id_pais) FROM publicidad.anunciante), 6
    UNION ALL SELECT N'Mercados de piezas distintos', (SELECT COUNT(DISTINCT id_pais_mercado) FROM publicidad.pieza_publicitaria), 5
    UNION ALL SELECT N'Exhibiciones', (SELECT COUNT(*) FROM publicidad.exhibicion), 4
    UNION ALL SELECT N'Tipos de cambio', (SELECT COUNT(*) FROM publicidad.tipo_cambio), 1
    UNION ALL SELECT N'Indicadores PBI per capita', (SELECT COUNT(*) FROM geo.indicador_pais WHERE codigo_indicador = 'NY.GDP.PCAP.CD'), 1
) AS v
ORDER BY CASE WHEN cantidad >= minimo_esperado THEN 1 ELSE 0 END, control;
GO

-- Casos obligatorios del enunciado (seccion IV) que alimentan los reportes
SELECT N'Partido con prime time en mas de 4 mercados' AS caso,
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
