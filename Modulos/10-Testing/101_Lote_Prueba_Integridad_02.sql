/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de prueba 2 de 5 (verificaciones de integridad sobre los datos cargados).
          Cada caso mira un partido, seleccion, sede o arbitro y guarda OK, FAIL, SKIP o ERROR
          en la tabla temporal global ##lote_resultado (SKIP: ese numero de partido, seleccion,
          sede o arbitro no existe en la base). Requiere los scripts 00 a 47 y 90 a 93.
          Ejecutar los 5 lotes en la misma ventana de SSMS, en orden, y mirar el resumen al final.

Casos 0063 a 0124 de este lote:
  - Partido #N: tiene 2 equipos o ninguno (ninguno equipo suelto) (42 casos)
  - Partido #N: dorsales sin repetir dentro de cada equipo en la alineacion (20 casos)
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

-- Caso 0063: Partido #63: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 63)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0063', 'Partido #63: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0063', 'Partido #63: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0064: Partido #64: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 64)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0064', 'Partido #64: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0064', 'Partido #64: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0065: Partido #65: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 65)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0065', 'Partido #65: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0065', 'Partido #65: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0066: Partido #66: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 66)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0066', 'Partido #66: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0066', 'Partido #66: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0067: Partido #67: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 67)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0067', 'Partido #67: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0067', 'Partido #67: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0068: Partido #68: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 68)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0068', 'Partido #68: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0068', 'Partido #68: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0069: Partido #69: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 69)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0069', 'Partido #69: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0069', 'Partido #69: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0070: Partido #70: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 70)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0070', 'Partido #70: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0070', 'Partido #70: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0071: Partido #71: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 71)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0071', 'Partido #71: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0071', 'Partido #71: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0072: Partido #72: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 72)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0072', 'Partido #72: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0072', 'Partido #72: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0073: Partido #73: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 73)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0073', 'Partido #73: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0073', 'Partido #73: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0074: Partido #74: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 74)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0074', 'Partido #74: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0074', 'Partido #74: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0075: Partido #75: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 75)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0075', 'Partido #75: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0075', 'Partido #75: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0076: Partido #76: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 76)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0076', 'Partido #76: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0076', 'Partido #76: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0077: Partido #77: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 77)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0077', 'Partido #77: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0077', 'Partido #77: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0078: Partido #78: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 78)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0078', 'Partido #78: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0078', 'Partido #78: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0079: Partido #79: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 79)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0079', 'Partido #79: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0079', 'Partido #79: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0080: Partido #80: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 80)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0080', 'Partido #80: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0080', 'Partido #80: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0081: Partido #81: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 81)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0081', 'Partido #81: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0081', 'Partido #81: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0082: Partido #82: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 82)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0082', 'Partido #82: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0082', 'Partido #82: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0083: Partido #83: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 83)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0083', 'Partido #83: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0083', 'Partido #83: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0084: Partido #84: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 84)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0084', 'Partido #84: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0084', 'Partido #84: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0085: Partido #85: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 85)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0085', 'Partido #85: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0085', 'Partido #85: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0086: Partido #86: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 86)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0086', 'Partido #86: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0086', 'Partido #86: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0087: Partido #87: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 87)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0087', 'Partido #87: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0087', 'Partido #87: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0088: Partido #88: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 88)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0088', 'Partido #88: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0088', 'Partido #88: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0089: Partido #89: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 89)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0089', 'Partido #89: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0089', 'Partido #89: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0090: Partido #90: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 90)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0090', 'Partido #90: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0090', 'Partido #90: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0091: Partido #91: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 91)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0091', 'Partido #91: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0091', 'Partido #91: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0092: Partido #92: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 92)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0092', 'Partido #92: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0092', 'Partido #92: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0093: Partido #93: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 93)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0093', 'Partido #93: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0093', 'Partido #93: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0094: Partido #94: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 94)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0094', 'Partido #94: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0094', 'Partido #94: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0095: Partido #95: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 95)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0095', 'Partido #95: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0095', 'Partido #95: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0096: Partido #96: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 96)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0096', 'Partido #96: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0096', 'Partido #96: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0097: Partido #97: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 97)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0097', 'Partido #97: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0097', 'Partido #97: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0098: Partido #98: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 98)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0098', 'Partido #98: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0098', 'Partido #98: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0099: Partido #99: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 99)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0099', 'Partido #99: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0099', 'Partido #99: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0100: Partido #100: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 100)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0100', 'Partido #100: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0100', 'Partido #100: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0101: Partido #101: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 101)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0101', 'Partido #101: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0101', 'Partido #101: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0102: Partido #102: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 102)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0102', 'Partido #102: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0102', 'Partido #102: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0103: Partido #103: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 103)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0103', 'Partido #103: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0103', 'Partido #103: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0104: Partido #104: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 104)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0104', 'Partido #104: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0104', 'Partido #104: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0105: Partido #1: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 1)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0105', 'Partido #1: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0105', 'Partido #1: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0106: Partido #2: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 2)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0106', 'Partido #2: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0106', 'Partido #2: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0107: Partido #3: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 3)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0107', 'Partido #3: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0107', 'Partido #3: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0108: Partido #4: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 4)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0108', 'Partido #4: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0108', 'Partido #4: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0109: Partido #5: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 5)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0109', 'Partido #5: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0109', 'Partido #5: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0110: Partido #6: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 6)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0110', 'Partido #6: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0110', 'Partido #6: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0111: Partido #7: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 7)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0111', 'Partido #7: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0111', 'Partido #7: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0112: Partido #8: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 8)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0112', 'Partido #8: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0112', 'Partido #8: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0113: Partido #9: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 9)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0113', 'Partido #9: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0113', 'Partido #9: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0114: Partido #10: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 10)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0114', 'Partido #10: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0114', 'Partido #10: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0115: Partido #11: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 11)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0115', 'Partido #11: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0115', 'Partido #11: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0116: Partido #12: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 12)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0116', 'Partido #12: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0116', 'Partido #12: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0117: Partido #13: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 13)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0117', 'Partido #13: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0117', 'Partido #13: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0118: Partido #14: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 14)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0118', 'Partido #14: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0118', 'Partido #14: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0119: Partido #15: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 15)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0119', 'Partido #15: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0119', 'Partido #15: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0120: Partido #16: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 16)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0120', 'Partido #16: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0120', 'Partido #16: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0121: Partido #17: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 17)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0121', 'Partido #17: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0121', 'Partido #17: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0122: Partido #18: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 18)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0122', 'Partido #18: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0122', 'Partido #18: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0123: Partido #19: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 19)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0123', 'Partido #19: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0123', 'Partido #19: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0124: Partido #20: dorsales sin repetir dentro de cada equipo en la alineacion
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 20)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0124', 'Partido #20: dorsales sin repetir dentro de cada equipo en la alineacion',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT a.id_seleccion, a.dorsal FROM juego.alineacion AS a WHERE a.id_partido = s.id GROUP BY a.id_seleccion, a.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0124', 'Partido #20: dorsales sin repetir dentro de cada equipo en la alineacion', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 101_Lote_Prueba_Integridad_02.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
