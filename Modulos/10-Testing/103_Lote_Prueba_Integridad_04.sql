/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de prueba 4 de 5 (verificaciones de integridad sobre los datos cargados).
          Cada caso mira un partido, seleccion, sede o arbitro y guarda OK, FAIL, SKIP o ERROR
          en la tabla temporal global ##lote_resultado (SKIP: ese numero de partido, seleccion,
          sede o arbitro no existe en la base). Requiere los scripts 00 a 47 y 90 a 93.
          Ejecutar los 5 lotes en la misma ventana de SSMS, en orden, y mirar el resumen al final.

Casos 0187 a 0248 de este lote:
  - Partido #N: dorsales sin repetir dentro de cada equipo en la alineacion (22 casos)
  - Seleccion #N: dorsales sin repetir en la convocatoria (40 casos)
Como leer el resultado (tabla ##lote_resultado, columna estado):
  OK    : el caso se cumplio (la verificacion dio lo esperado o el reporte se ejecuto sin error).
  FAIL  : la verificacion encontro filas que no cumplen; la columna detalle muestra el valor.
  SKIP  : el numero de sujeto del caso no existe (por ejemplo, hay menos partidos cargados).
  ERROR : la instruccion fallo; la columna detalle trae el mensaje de SQL Server.
Cada lote se puede volver a correr: los casos se agregan a la tabla, no la borran.
Para empezar de cero: DROP TABLE ##lote_resultado; y volver a ejecutar desde el primer lote.
La tabla es temporal global: vive mientras la ventana de SSMS siga abierta.
Los sujetos se eligen por posicion (ROW_NUMBER por id), asi no depende de los ids reales.
No se modifica ningun dato de negocio: los casos solo leen o ejecutan reportes de lectura.
Si un caso da FAIL, revisar primero si el dato esta mal cargado o si el criterio no aplica.
Un SKIP no es un error: indica que ese caso quedo sin sujeto con los datos actuales.
Ejecutar con la base Mundial2026 ya construida (EJECUTAR_TODO.sql) y los seeds cargados.
Si se cambia de base, modificar solo la linea USE del principio de cada lote.
El resumen del final cuenta los casos de todos los lotes ejecutados hasta el momento.
Los numeros de caso son correlativos entre lotes (el lote siguiente sigue la numeracion).
Un mismo caso nunca depende del resultado de otro: se puede ejecutar de forma aislada.
Cada caso tiene su propio TRY/CATCH: un error en uno no corta el lote.
Los mensajes de error quedan en detalle, recortados a 400 caracteres por la tabla.
Para ver todo en orden de ejecucion: SELECT * FROM ##lote_resultado ORDER BY orden;
Para ver solo problemas: SELECT * FROM ##lote_resultado WHERE estado <> 'OK' AND estado <> 'SKIP';
Para contar por tipo de caso: agrupar por LEFT(descripcion, 12).
Con el usuario de un rol de prueba, estos lotes pueden dar ERROR por falta de permisos.
Se recomienda ejecutarlos con el usuario administrador de la base.
Al exportar a la entrega, incluir este lote junto con los demas de la misma serie.
La numeracion de archivos (100 en adelante) sigue a los tests 94 a 98 de la Entrega 8.
El orden de los archivos importa solo para la numeracion de casos, no para el resultado.
Todos los textos estan sin tildes dentro de las cadenas para evitar problemas de codificacion.
Los encabezados siguen el mismo formato que los scripts de las entregas anteriores.
Fin de las notas del lote.


===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

IF OBJECT_ID('tempdb..##lote_resultado') IS NULL
    CREATE TABLE ##lote_resultado (
        orden       INT IDENTITY(1,1) NOT NULL,
        caso        CHAR(4)           NOT NULL,
        descripcion VARCHAR(200)      NOT NULL,
        estado      VARCHAR(5)        NOT NULL,
        detalle     NVARCHAR(400)     NULL
    );
GO

-- Caso 0187: Partido #83: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 83)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0187', 'Partido #83: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0187', 'Partido #83: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0188: Partido #84: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 84)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0188', 'Partido #84: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0188', 'Partido #84: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0189: Partido #85: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 85)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0189', 'Partido #85: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0189', 'Partido #85: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0190: Partido #86: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 86)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0190', 'Partido #86: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0190', 'Partido #86: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0191: Partido #87: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 87)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0191', 'Partido #87: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0191', 'Partido #87: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0192: Partido #88: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 88)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0192', 'Partido #88: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0192', 'Partido #88: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0193: Partido #89: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 89)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0193', 'Partido #89: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0193', 'Partido #89: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0194: Partido #90: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 90)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0194', 'Partido #90: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0194', 'Partido #90: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0195: Partido #91: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 91)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0195', 'Partido #91: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0195', 'Partido #91: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0196: Partido #92: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 92)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0196', 'Partido #92: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0196', 'Partido #92: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0197: Partido #93: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 93)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0197', 'Partido #93: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0197', 'Partido #93: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0198: Partido #94: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 94)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0198', 'Partido #94: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0198', 'Partido #94: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0199: Partido #95: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 95)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0199', 'Partido #95: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0199', 'Partido #95: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0200: Partido #96: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 96)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0200', 'Partido #96: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0200', 'Partido #96: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0201: Partido #97: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 97)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0201', 'Partido #97: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0201', 'Partido #97: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0202: Partido #98: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 98)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0202', 'Partido #98: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0202', 'Partido #98: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0203: Partido #99: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 99)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0203', 'Partido #99: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0203', 'Partido #99: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0204: Partido #100: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 100)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0204', 'Partido #100: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0204', 'Partido #100: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0205: Partido #101: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 101)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0205', 'Partido #101: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0205', 'Partido #101: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0206: Partido #102: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 102)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0206', 'Partido #102: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0206', 'Partido #102: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0207: Partido #103: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 103)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0207', 'Partido #103: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0207', 'Partido #103: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0208: Partido #104: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 104)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0208', 'Partido #104: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0208', 'Partido #104: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0209: Seleccion #1: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 1)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0209', 'Seleccion #1: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0209', 'Seleccion #1: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0210: Seleccion #2: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 2)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0210', 'Seleccion #2: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0210', 'Seleccion #2: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0211: Seleccion #3: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 3)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0211', 'Seleccion #3: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0211', 'Seleccion #3: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0212: Seleccion #4: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 4)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0212', 'Seleccion #4: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0212', 'Seleccion #4: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0213: Seleccion #5: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 5)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0213', 'Seleccion #5: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0213', 'Seleccion #5: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0214: Seleccion #6: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 6)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0214', 'Seleccion #6: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0214', 'Seleccion #6: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0215: Seleccion #7: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 7)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0215', 'Seleccion #7: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0215', 'Seleccion #7: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0216: Seleccion #8: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 8)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0216', 'Seleccion #8: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0216', 'Seleccion #8: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0217: Seleccion #9: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 9)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0217', 'Seleccion #9: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0217', 'Seleccion #9: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0218: Seleccion #10: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 10)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0218', 'Seleccion #10: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0218', 'Seleccion #10: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0219: Seleccion #11: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 11)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0219', 'Seleccion #11: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0219', 'Seleccion #11: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0220: Seleccion #12: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 12)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0220', 'Seleccion #12: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0220', 'Seleccion #12: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0221: Seleccion #13: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 13)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0221', 'Seleccion #13: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0221', 'Seleccion #13: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0222: Seleccion #14: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 14)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0222', 'Seleccion #14: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0222', 'Seleccion #14: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0223: Seleccion #15: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 15)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0223', 'Seleccion #15: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0223', 'Seleccion #15: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0224: Seleccion #16: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 16)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0224', 'Seleccion #16: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0224', 'Seleccion #16: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0225: Seleccion #17: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 17)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0225', 'Seleccion #17: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0225', 'Seleccion #17: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0226: Seleccion #18: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 18)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0226', 'Seleccion #18: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0226', 'Seleccion #18: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0227: Seleccion #19: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 19)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0227', 'Seleccion #19: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0227', 'Seleccion #19: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0228: Seleccion #20: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 20)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0228', 'Seleccion #20: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0228', 'Seleccion #20: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0229: Seleccion #21: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 21)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0229', 'Seleccion #21: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0229', 'Seleccion #21: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0230: Seleccion #22: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 22)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0230', 'Seleccion #22: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0230', 'Seleccion #22: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0231: Seleccion #23: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 23)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0231', 'Seleccion #23: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0231', 'Seleccion #23: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0232: Seleccion #24: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 24)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0232', 'Seleccion #24: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0232', 'Seleccion #24: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0233: Seleccion #25: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 25)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0233', 'Seleccion #25: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0233', 'Seleccion #25: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0234: Seleccion #26: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 26)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0234', 'Seleccion #26: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0234', 'Seleccion #26: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0235: Seleccion #27: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 27)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0235', 'Seleccion #27: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0235', 'Seleccion #27: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0236: Seleccion #28: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 28)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0236', 'Seleccion #28: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0236', 'Seleccion #28: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0237: Seleccion #29: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 29)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0237', 'Seleccion #29: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0237', 'Seleccion #29: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0238: Seleccion #30: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 30)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0238', 'Seleccion #30: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0238', 'Seleccion #30: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0239: Seleccion #31: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 31)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0239', 'Seleccion #31: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0239', 'Seleccion #31: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0240: Seleccion #32: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 32)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0240', 'Seleccion #32: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0240', 'Seleccion #32: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0241: Seleccion #33: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 33)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0241', 'Seleccion #33: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0241', 'Seleccion #33: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0242: Seleccion #34: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 34)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0242', 'Seleccion #34: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0242', 'Seleccion #34: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0243: Seleccion #35: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 35)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0243', 'Seleccion #35: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0243', 'Seleccion #35: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0244: Seleccion #36: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 36)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0244', 'Seleccion #36: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0244', 'Seleccion #36: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0245: Seleccion #37: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 37)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0245', 'Seleccion #37: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0245', 'Seleccion #37: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0246: Seleccion #38: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 38)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0246', 'Seleccion #38: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0246', 'Seleccion #38: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0247: Seleccion #39: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 39)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0247', 'Seleccion #39: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0247', 'Seleccion #39: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0248: Seleccion #40: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 40)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0248', 'Seleccion #40: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0248', 'Seleccion #40: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 103_Lote_Prueba_Integridad_04.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
