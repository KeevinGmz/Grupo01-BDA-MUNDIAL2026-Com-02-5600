/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de prueba 1 de 5 (verificaciones de integridad sobre los datos cargados).
          Cada caso mira un partido, seleccion, sede o arbitro y guarda OK, FAIL, SKIP o ERROR
          en la tabla temporal global ##lote_resultado (SKIP: ese numero de partido, seleccion,
          sede o arbitro no existe en la base). Requiere los scripts 00 a 47 y 90 a 93.
          Ejecutar los 5 lotes en la misma ventana de SSMS, en orden, y mirar el resumen al final.

Casos 0001 a 0062 de este lote:
  - Partido #N: tiene 2 equipos o ninguno (ninguno equipo suelto) (62 casos)
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

-- Caso 0001: Partido #1: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 1)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0001', 'Partido #1: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0001', 'Partido #1: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0002: Partido #2: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 2)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0002', 'Partido #2: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0002', 'Partido #2: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0003: Partido #3: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 3)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0003', 'Partido #3: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0003', 'Partido #3: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0004: Partido #4: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 4)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0004', 'Partido #4: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0004', 'Partido #4: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0005: Partido #5: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 5)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0005', 'Partido #5: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0005', 'Partido #5: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0006: Partido #6: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 6)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0006', 'Partido #6: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0006', 'Partido #6: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0007: Partido #7: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 7)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0007', 'Partido #7: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0007', 'Partido #7: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0008: Partido #8: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 8)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0008', 'Partido #8: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0008', 'Partido #8: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0009: Partido #9: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 9)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0009', 'Partido #9: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0009', 'Partido #9: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0010: Partido #10: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 10)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0010', 'Partido #10: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0010', 'Partido #10: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0011: Partido #11: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 11)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0011', 'Partido #11: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0011', 'Partido #11: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0012: Partido #12: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 12)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0012', 'Partido #12: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0012', 'Partido #12: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0013: Partido #13: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 13)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0013', 'Partido #13: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0013', 'Partido #13: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0014: Partido #14: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 14)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0014', 'Partido #14: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0014', 'Partido #14: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0015: Partido #15: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 15)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0015', 'Partido #15: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0015', 'Partido #15: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0016: Partido #16: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 16)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0016', 'Partido #16: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0016', 'Partido #16: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0017: Partido #17: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 17)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0017', 'Partido #17: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0017', 'Partido #17: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0018: Partido #18: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 18)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0018', 'Partido #18: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0018', 'Partido #18: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0019: Partido #19: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 19)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0019', 'Partido #19: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0019', 'Partido #19: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0020: Partido #20: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 20)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0020', 'Partido #20: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0020', 'Partido #20: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0021: Partido #21: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 21)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0021', 'Partido #21: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0021', 'Partido #21: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0022: Partido #22: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 22)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0022', 'Partido #22: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0022', 'Partido #22: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0023: Partido #23: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 23)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0023', 'Partido #23: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0023', 'Partido #23: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0024: Partido #24: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 24)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0024', 'Partido #24: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0024', 'Partido #24: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0025: Partido #25: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 25)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0025', 'Partido #25: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0025', 'Partido #25: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0026: Partido #26: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 26)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0026', 'Partido #26: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0026', 'Partido #26: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0027: Partido #27: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 27)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0027', 'Partido #27: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0027', 'Partido #27: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0028: Partido #28: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 28)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0028', 'Partido #28: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0028', 'Partido #28: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0029: Partido #29: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 29)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0029', 'Partido #29: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0029', 'Partido #29: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0030: Partido #30: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 30)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0030', 'Partido #30: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0030', 'Partido #30: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0031: Partido #31: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 31)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0031', 'Partido #31: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0031', 'Partido #31: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0032: Partido #32: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 32)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0032', 'Partido #32: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0032', 'Partido #32: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0033: Partido #33: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 33)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0033', 'Partido #33: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0033', 'Partido #33: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0034: Partido #34: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 34)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0034', 'Partido #34: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0034', 'Partido #34: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0035: Partido #35: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 35)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0035', 'Partido #35: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0035', 'Partido #35: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0036: Partido #36: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 36)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0036', 'Partido #36: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0036', 'Partido #36: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0037: Partido #37: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 37)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0037', 'Partido #37: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0037', 'Partido #37: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0038: Partido #38: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 38)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0038', 'Partido #38: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0038', 'Partido #38: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0039: Partido #39: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 39)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0039', 'Partido #39: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0039', 'Partido #39: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0040: Partido #40: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 40)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0040', 'Partido #40: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0040', 'Partido #40: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0041: Partido #41: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 41)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0041', 'Partido #41: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0041', 'Partido #41: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0042: Partido #42: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 42)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0042', 'Partido #42: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0042', 'Partido #42: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0043: Partido #43: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 43)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0043', 'Partido #43: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0043', 'Partido #43: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0044: Partido #44: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 44)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0044', 'Partido #44: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0044', 'Partido #44: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0045: Partido #45: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 45)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0045', 'Partido #45: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0045', 'Partido #45: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0046: Partido #46: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 46)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0046', 'Partido #46: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0046', 'Partido #46: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0047: Partido #47: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 47)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0047', 'Partido #47: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0047', 'Partido #47: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0048: Partido #48: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 48)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0048', 'Partido #48: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0048', 'Partido #48: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0049: Partido #49: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 49)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0049', 'Partido #49: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0049', 'Partido #49: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0050: Partido #50: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 50)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0050', 'Partido #50: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0050', 'Partido #50: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0051: Partido #51: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 51)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0051', 'Partido #51: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0051', 'Partido #51: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0052: Partido #52: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 52)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0052', 'Partido #52: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0052', 'Partido #52: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0053: Partido #53: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 53)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0053', 'Partido #53: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0053', 'Partido #53: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0054: Partido #54: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 54)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0054', 'Partido #54: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0054', 'Partido #54: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0055: Partido #55: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 55)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0055', 'Partido #55: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0055', 'Partido #55: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0056: Partido #56: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 56)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0056', 'Partido #56: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0056', 'Partido #56: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0057: Partido #57: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 57)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0057', 'Partido #57: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0057', 'Partido #57: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0058: Partido #58: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 58)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0058', 'Partido #58: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0058', 'Partido #58: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0059: Partido #59: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 59)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0059', 'Partido #59: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0059', 'Partido #59: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0060: Partido #60: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 60)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0060', 'Partido #60: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0060', 'Partido #60: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0061: Partido #61: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 61)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0061', 'Partido #61: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0061', 'Partido #61: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0062: Partido #62: tiene 2 equipos o ninguno (ninguno equipo suelto)
BEGIN TRY
;WITH s AS (SELECT t.id_partido AS id FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 62)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0062', 'Partido #62: tiene 2 equipos o ninguno (ninguno equipo suelto)',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n IN (0, 2) THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(DISTINCT e.id_seleccion) AS n FROM torneo.equipo_en_partido AS e WHERE e.id_partido = s.id) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0062', 'Partido #62: tiene 2 equipos o ninguno (ninguno equipo suelto)', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 100_Lote_Prueba_Integridad_01.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
