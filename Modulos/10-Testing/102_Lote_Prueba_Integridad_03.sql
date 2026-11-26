/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de prueba 3 de 5 (verificaciones de integridad sobre los datos cargados).
          Cada caso mira un partido, seleccion, sede o arbitro y guarda OK, FAIL, SKIP o ERROR
          en la tabla temporal global ##lote_resultado (SKIP: ese numero de partido, seleccion,
          sede o arbitro no existe en la base). Requiere los scripts 00 a 47 y 90 a 93.
          Ejecutar los 5 lotes en la misma ventana de SSMS, en orden, y mirar el resumen al final.

Casos 0125 a 0186 de este lote:
  - Partido #N: dorsales sin repetir dentro de cada equipo en la alineacion (62 casos)
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

-- Caso 0125: Partido #21: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 21)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0125', 'Partido #21: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0125', 'Partido #21: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0126: Partido #22: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 22)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0126', 'Partido #22: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0126', 'Partido #22: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0127: Partido #23: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 23)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0127', 'Partido #23: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0127', 'Partido #23: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0128: Partido #24: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 24)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0128', 'Partido #24: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0128', 'Partido #24: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0129: Partido #25: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 25)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0129', 'Partido #25: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0129', 'Partido #25: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0130: Partido #26: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 26)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0130', 'Partido #26: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0130', 'Partido #26: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0131: Partido #27: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 27)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0131', 'Partido #27: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0131', 'Partido #27: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0132: Partido #28: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 28)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0132', 'Partido #28: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0132', 'Partido #28: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0133: Partido #29: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 29)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0133', 'Partido #29: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0133', 'Partido #29: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0134: Partido #30: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 30)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0134', 'Partido #30: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0134', 'Partido #30: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0135: Partido #31: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 31)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0135', 'Partido #31: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0135', 'Partido #31: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0136: Partido #32: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 32)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0136', 'Partido #32: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0136', 'Partido #32: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0137: Partido #33: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 33)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0137', 'Partido #33: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0137', 'Partido #33: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0138: Partido #34: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 34)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0138', 'Partido #34: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0138', 'Partido #34: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0139: Partido #35: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 35)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0139', 'Partido #35: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0139', 'Partido #35: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0140: Partido #36: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 36)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0140', 'Partido #36: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0140', 'Partido #36: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0141: Partido #37: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 37)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0141', 'Partido #37: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0141', 'Partido #37: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0142: Partido #38: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 38)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0142', 'Partido #38: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0142', 'Partido #38: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0143: Partido #39: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 39)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0143', 'Partido #39: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0143', 'Partido #39: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0144: Partido #40: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 40)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0144', 'Partido #40: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0144', 'Partido #40: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0145: Partido #41: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 41)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0145', 'Partido #41: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0145', 'Partido #41: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0146: Partido #42: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 42)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0146', 'Partido #42: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0146', 'Partido #42: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0147: Partido #43: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 43)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0147', 'Partido #43: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0147', 'Partido #43: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0148: Partido #44: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 44)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0148', 'Partido #44: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0148', 'Partido #44: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0149: Partido #45: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 45)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0149', 'Partido #45: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0149', 'Partido #45: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0150: Partido #46: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 46)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0150', 'Partido #46: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0150', 'Partido #46: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0151: Partido #47: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 47)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0151', 'Partido #47: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0151', 'Partido #47: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0152: Partido #48: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 48)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0152', 'Partido #48: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0152', 'Partido #48: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0153: Partido #49: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 49)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0153', 'Partido #49: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0153', 'Partido #49: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0154: Partido #50: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 50)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0154', 'Partido #50: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0154', 'Partido #50: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0155: Partido #51: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 51)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0155', 'Partido #51: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0155', 'Partido #51: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0156: Partido #52: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 52)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0156', 'Partido #52: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0156', 'Partido #52: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0157: Partido #53: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 53)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0157', 'Partido #53: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0157', 'Partido #53: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0158: Partido #54: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 54)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0158', 'Partido #54: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0158', 'Partido #54: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0159: Partido #55: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 55)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0159', 'Partido #55: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0159', 'Partido #55: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0160: Partido #56: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 56)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0160', 'Partido #56: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0160', 'Partido #56: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0161: Partido #57: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 57)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0161', 'Partido #57: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0161', 'Partido #57: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0162: Partido #58: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 58)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0162', 'Partido #58: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0162', 'Partido #58: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0163: Partido #59: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 59)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0163', 'Partido #59: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0163', 'Partido #59: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0164: Partido #60: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 60)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0164', 'Partido #60: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0164', 'Partido #60: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0165: Partido #61: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 61)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0165', 'Partido #61: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0165', 'Partido #61: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0166: Partido #62: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 62)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0166', 'Partido #62: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0166', 'Partido #62: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0167: Partido #63: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 63)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0167', 'Partido #63: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0167', 'Partido #63: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0168: Partido #64: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 64)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0168', 'Partido #64: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0168', 'Partido #64: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0169: Partido #65: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 65)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0169', 'Partido #65: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0169', 'Partido #65: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0170: Partido #66: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 66)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0170', 'Partido #66: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0170', 'Partido #66: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0171: Partido #67: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 67)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0171', 'Partido #67: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0171', 'Partido #67: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0172: Partido #68: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 68)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0172', 'Partido #68: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0172', 'Partido #68: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0173: Partido #69: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 69)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0173', 'Partido #69: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0173', 'Partido #69: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0174: Partido #70: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 70)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0174', 'Partido #70: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0174', 'Partido #70: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0175: Partido #71: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 71)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0175', 'Partido #71: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0175', 'Partido #71: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0176: Partido #72: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 72)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0176', 'Partido #72: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0176', 'Partido #72: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0177: Partido #73: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 73)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0177', 'Partido #73: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0177', 'Partido #73: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0178: Partido #74: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 74)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0178', 'Partido #74: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0178', 'Partido #74: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0179: Partido #75: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 75)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0179', 'Partido #75: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0179', 'Partido #75: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0180: Partido #76: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 76)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0180', 'Partido #76: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0180', 'Partido #76: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0181: Partido #77: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 77)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0181', 'Partido #77: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0181', 'Partido #77: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0182: Partido #78: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 78)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0182', 'Partido #78: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0182', 'Partido #78: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0183: Partido #79: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 79)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0183', 'Partido #79: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0183', 'Partido #79: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0184: Partido #80: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 80)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0184', 'Partido #80: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0184', 'Partido #80: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0185: Partido #81: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 81)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0185', 'Partido #81: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0185', 'Partido #81: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0186: Partido #82: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 82)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0186', 'Partido #82: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0186', 'Partido #82: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 102_Lote_Prueba_Integridad_03.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
