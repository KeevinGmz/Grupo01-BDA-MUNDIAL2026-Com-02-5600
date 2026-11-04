/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-26
Objetivo: Entrega 7. Ejecuta cada reporte con parametros validos y deja en
          comentarios el resultado esperado. Requiere haber corrido los
          scripts 00 a 46 (y 89 para verificar que hay datos).
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT '=====================================================================';
PRINT 'INICIO PRUEBAS OK: 87_Test_Reportes_OK';
PRINT '=====================================================================';
GO

/* ---------------------------------------------------------------------
   Test 1: Goleadores (tabla, sin filtros)
   Esperado: 3 resultados.
     (1) ranking de goleadores con posicion, jugador, seleccion, goles
         (la posicion 1 tiene el mayor numero de goles; empates comparten posicion)
     (2) goles por seleccion
     (3) goles por fase: solo "Fase de grupos" mientras no haya otras fases cargadas
   --------------------------------------------------------------------- */
PRINT '';
PRINT '-> Test 1: reporte.usp_Goleadores (torneo completo)';
EXEC reporte.usp_Goleadores;
GO

/* ---------------------------------------------------------------------
   Test 2: Goleadores filtrado por una seleccion y por fase
   Esperado: el ranking incluye solo jugadores de esa seleccion y la fase 1.
   --------------------------------------------------------------------- */
PRINT '';
PRINT '-> Test 2: reporte.usp_Goleadores filtrado por seleccion y fase 1';
DECLARE @v_sel INT;
SELECT TOP (1) @v_sel = g.id_seleccion FROM juego.gol AS g ORDER BY g.id_partido, g.id_seleccion;
EXEC reporte.usp_Goleadores @id_seleccion = @v_sel, @nro_fase = 1;
GO

/* ---------------------------------------------------------------------
   Test 3: Goleadores en XML
   Esperado: una sola celda XML <goleadores> con <torneo>, <porSeleccion>
   y <porFase> (hacer clic en la celda para verla formateada).
   --------------------------------------------------------------------- */
PRINT '';
PRINT '-> Test 3: reporte.usp_Goleadores en XML';
EXEC reporte.usp_Goleadores @formato = 'XML';
GO

/* ---------------------------------------------------------------------
   Test 4: Tarjetas, todas las selecciones, suspensiones activas
   Esperado:
     (1) tarjetas por seleccion (amarillas, rojas doble amarilla, rojas directas)
     (2) tarjetas por jugador con la columna suspension_activa
     (3) suspensiones en estado PENDIENTE, con origen ACUMULACION o EXPULSION
         (el seed 44 genera una por acumulacion y las de expulsion)
   --------------------------------------------------------------------- */
PRINT '';
PRINT '-> Test 4: reporte.usp_Tarjetas (solo suspensiones activas)';
EXEC reporte.usp_Tarjetas;
GO

/* ---------------------------------------------------------------------
   Test 5: Tarjetas incluyendo suspensiones ya cumplidas
   Esperado: el tercer resultado agrega filas con estado CUMPLIDA (si las hay).
   --------------------------------------------------------------------- */
PRINT '';
PRINT '-> Test 5: reporte.usp_Tarjetas con historial de suspensiones';
EXEC reporte.usp_Tarjetas @solo_activas = 0;
GO

/* ---------------------------------------------------------------------
   Test 6: Designaciones arbitrales de todos los arbitros
   Esperado:
     (1) resumen por arbitro (designaciones, como principal, tarjetas mostradas)
     (2) un renglon por designacion con partido, fase, sede, encuentro
     (3) detalle de tarjetas senaladas (arbitro, partido, minuto, jugador)
   --------------------------------------------------------------------- */
PRINT '';
PRINT '-> Test 6: reporte.usp_DesignacionesArbitrales (todos)';
EXEC reporte.usp_DesignacionesArbitrales;
GO

PRINT '';
PRINT '-> Test 7: reporte.usp_DesignacionesArbitrales de un arbitro con tarjetas';
DECLARE @v_arb INT;
SELECT TOP (1) @v_arb = t.id_arbitro FROM juego.tarjeta AS t ORDER BY t.id_partido, t.minuto;
EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @v_arb;
-- Esperado: las tres tablas contienen solo filas del arbitro elegido.
GO

/* ---------------------------------------------------------------------
   Test 8: Ocupacion publicitaria
   Esperado:
     (1) hasta 4 espacios por partido con anunciante, campania, pieza e importe USD
     (2) por sede: partidos, espacios disponibles (partidos x 4), ocupados,
         porcentaje de ocupacion e ingresos USD
     (3) ingresos por anunciante
   --------------------------------------------------------------------- */
PRINT '';
PRINT '-> Test 8: reporte.usp_OcupacionPublicitaria (todas las sedes)';
EXEC reporte.usp_OcupacionPublicitaria;
GO

PRINT '';
PRINT '-> Test 9: reporte.usp_OcupacionPublicitaria de un partido con exhibiciones';
DECLARE @v_part INT;
SELECT TOP (1) @v_part = ex.id_partido FROM publicidad.exhibicion AS ex ORDER BY ex.id_partido;
EXEC reporte.usp_OcupacionPublicitaria @id_partido = @v_part;
-- Esperado: exactamente 4 filas de detalle (una por espacio, nro_espacio 1 a 4).
GO

/* ---------------------------------------------------------------------
   Test 10: Matriz de prime time (pivot)
   Esperado: una fila por partido; una columna por mercado (pais de interes de
   las piezas); valores 1 (prime time) o 0. mercados_en_prime_time cuenta los
   unos de la fila y requiere_priorizacion = SI si son mas de 4.
   --------------------------------------------------------------------- */
PRINT '';
PRINT '-> Test 10: reporte.usp_MatrizPrimeTime (todos los partidos)';
EXEC reporte.usp_MatrizPrimeTime;
GO

PRINT '';
PRINT '-> Test 11: reporte.usp_MatrizPrimeTime de un partido';
DECLARE @v_p INT;
SELECT TOP (1) @v_p = p.id_partido FROM torneo.partido AS p ORDER BY p.fecha_hora_utc;
EXEC reporte.usp_MatrizPrimeTime @id_partido = @v_p;
-- Esperado: una sola fila.
GO

/* ---------------------------------------------------------------------
   Test 12: Selecciones y plantillas (XML)
   Esperado: <selecciones> con un <seleccion> por equipo (pais, confederacion,
   grupo, cantidad_convocados) y dentro <convocados><convocado dorsal nombre
   posicion club/> ordenados por dorsal. Las selecciones del seed tienen 23.
   --------------------------------------------------------------------- */
PRINT '';
PRINT '-> Test 12: reporte.usp_SeleccionesPlantillas (todas)';
EXEC reporte.usp_SeleccionesPlantillas;
GO

PRINT '';
PRINT '-> Test 13: reporte.usp_SeleccionesPlantillas de una seleccion';
DECLARE @v_s INT;
SELECT TOP (1) @v_s = s.id_seleccion FROM torneo.seleccion AS s ORDER BY s.id_seleccion;
EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @v_s;
-- Esperado: un unico <seleccion> con su lista de convocados.
GO

/* ---------------------------------------------------------------------
   Test 14: Resultados
   Esperado: un renglon por partido con fase, sede, local, visitante, marcador,
   ganador y asistencia. Los FINALIZADOS muestran marcador y ganador; los
   PROGRAMADOS muestran "0 - 0" y ganador "-".
   --------------------------------------------------------------------- */
PRINT '';
PRINT '-> Test 14: reporte.usp_Resultados (tabla)';
EXEC reporte.usp_Resultados;
GO

PRINT '';
PRINT '-> Test 15: reporte.usp_Resultados (XML, fase 1)';
EXEC reporte.usp_Resultados @nro_fase = 1, @formato = 'XML';
-- Esperado: XML <resultados> con un <partido> por encuentro de la fase 1.
GO

PRINT '';
PRINT '=====================================================================';
PRINT 'FIN PRUEBAS OK: 87_Test_Reportes_OK';
PRINT '=====================================================================';
GO
