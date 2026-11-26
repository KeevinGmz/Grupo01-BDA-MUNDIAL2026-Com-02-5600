/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de prueba 5 de 5 (verificaciones de integridad sobre los datos cargados).
          Cada caso mira un partido, seleccion, sede o arbitro y guarda OK, FAIL, SKIP o ERROR
          en la tabla temporal global ##lote_resultado (SKIP: ese numero de partido, seleccion,
          sede o arbitro no existe en la base). Requiere los scripts 00 a 47 y 90 a 93.
          Ejecutar los 5 lotes en la misma ventana de SSMS, en orden, y mirar el resumen al final.

Casos 0249 a 0310 de este lote:
  - Seleccion #N: dorsales sin repetir en la convocatoria (8 casos)
  - Sede #N: asistencia de cada partido no supera la capacidad del estadio (16 casos)
  - Arbitro #N: no esta designado dos veces en el mismo partido (38 casos)
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

-- Caso 0249: Seleccion #41: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 41)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0249', 'Seleccion #41: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0249', 'Seleccion #41: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0250: Seleccion #42: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 42)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0250', 'Seleccion #42: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0250', 'Seleccion #42: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0251: Seleccion #43: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 43)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0251', 'Seleccion #43: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0251', 'Seleccion #43: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0252: Seleccion #44: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 44)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0252', 'Seleccion #44: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0252', 'Seleccion #44: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0253: Seleccion #45: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 45)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0253', 'Seleccion #45: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0253', 'Seleccion #45: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0254: Seleccion #46: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 46)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0254', 'Seleccion #46: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0254', 'Seleccion #46: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0255: Seleccion #47: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 47)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0255', 'Seleccion #47: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0255', 'Seleccion #47: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0256: Seleccion #48: dorsales sin repetir en la convocatoria
BEGIN TRY
;WITH s AS (SELECT t.id_seleccion AS id FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 48)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0256', 'Seleccion #48: dorsales sin repetir en la convocatoria',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT c.dorsal FROM torneo.convocatoria AS c WHERE c.id_seleccion = s.id GROUP BY c.dorsal HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0256', 'Seleccion #48: dorsales sin repetir en la convocatoria', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0257: Sede #1: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 1)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0257', 'Sede #1: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0257', 'Sede #1: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0258: Sede #2: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 2)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0258', 'Sede #2: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0258', 'Sede #2: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0259: Sede #3: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 3)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0259', 'Sede #3: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0259', 'Sede #3: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0260: Sede #4: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 4)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0260', 'Sede #4: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0260', 'Sede #4: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0261: Sede #5: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 5)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0261', 'Sede #5: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0261', 'Sede #5: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0262: Sede #6: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 6)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0262', 'Sede #6: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0262', 'Sede #6: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0263: Sede #7: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 7)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0263', 'Sede #7: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0263', 'Sede #7: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0264: Sede #8: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 8)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0264', 'Sede #8: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0264', 'Sede #8: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0265: Sede #9: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 9)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0265', 'Sede #9: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0265', 'Sede #9: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0266: Sede #10: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 10)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0266', 'Sede #10: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0266', 'Sede #10: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0267: Sede #11: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 11)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0267', 'Sede #11: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0267', 'Sede #11: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0268: Sede #12: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 12)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0268', 'Sede #12: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0268', 'Sede #12: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0269: Sede #13: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 13)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0269', 'Sede #13: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0269', 'Sede #13: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0270: Sede #14: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 14)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0270', 'Sede #14: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0270', 'Sede #14: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0271: Sede #15: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 15)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0271', 'Sede #15: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0271', 'Sede #15: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0272: Sede #16: asistencia de cada partido no supera la capacidad del estadio
BEGIN TRY
;WITH s AS (SELECT t.id_sede AS id FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 16)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0272', 'Sede #16: asistencia de cada partido no supera la capacidad del estadio',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM torneo.partido AS p JOIN torneo.sede AS se ON se.id_sede = p.id_sede WHERE p.id_sede = s.id AND p.asistencia_publico > se.capacidad) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0272', 'Sede #16: asistencia de cada partido no supera la capacidad del estadio', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0273: Arbitro #1: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 1)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0273', 'Arbitro #1: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0273', 'Arbitro #1: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0274: Arbitro #2: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 2)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0274', 'Arbitro #2: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0274', 'Arbitro #2: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0275: Arbitro #3: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 3)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0275', 'Arbitro #3: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0275', 'Arbitro #3: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0276: Arbitro #4: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 4)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0276', 'Arbitro #4: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0276', 'Arbitro #4: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0277: Arbitro #5: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 5)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0277', 'Arbitro #5: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0277', 'Arbitro #5: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0278: Arbitro #6: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 6)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0278', 'Arbitro #6: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0278', 'Arbitro #6: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0279: Arbitro #7: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 7)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0279', 'Arbitro #7: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0279', 'Arbitro #7: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0280: Arbitro #8: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 8)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0280', 'Arbitro #8: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0280', 'Arbitro #8: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0281: Arbitro #9: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 9)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0281', 'Arbitro #9: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0281', 'Arbitro #9: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0282: Arbitro #10: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 10)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0282', 'Arbitro #10: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0282', 'Arbitro #10: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0283: Arbitro #11: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 11)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0283', 'Arbitro #11: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0283', 'Arbitro #11: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0284: Arbitro #12: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 12)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0284', 'Arbitro #12: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0284', 'Arbitro #12: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0285: Arbitro #13: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 13)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0285', 'Arbitro #13: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0285', 'Arbitro #13: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0286: Arbitro #14: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 14)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0286', 'Arbitro #14: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0286', 'Arbitro #14: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0287: Arbitro #15: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 15)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0287', 'Arbitro #15: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0287', 'Arbitro #15: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0288: Arbitro #16: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 16)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0288', 'Arbitro #16: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0288', 'Arbitro #16: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0289: Arbitro #17: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 17)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0289', 'Arbitro #17: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0289', 'Arbitro #17: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0290: Arbitro #18: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 18)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0290', 'Arbitro #18: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0290', 'Arbitro #18: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0291: Arbitro #19: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 19)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0291', 'Arbitro #19: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0291', 'Arbitro #19: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0292: Arbitro #20: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 20)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0292', 'Arbitro #20: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0292', 'Arbitro #20: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0293: Arbitro #21: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 21)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0293', 'Arbitro #21: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0293', 'Arbitro #21: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0294: Arbitro #22: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 22)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0294', 'Arbitro #22: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0294', 'Arbitro #22: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0295: Arbitro #23: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 23)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0295', 'Arbitro #23: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0295', 'Arbitro #23: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0296: Arbitro #24: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 24)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0296', 'Arbitro #24: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0296', 'Arbitro #24: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0297: Arbitro #25: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 25)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0297', 'Arbitro #25: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0297', 'Arbitro #25: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0298: Arbitro #26: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 26)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0298', 'Arbitro #26: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0298', 'Arbitro #26: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0299: Arbitro #27: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 27)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0299', 'Arbitro #27: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0299', 'Arbitro #27: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0300: Arbitro #28: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 28)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0300', 'Arbitro #28: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0300', 'Arbitro #28: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0301: Arbitro #29: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 29)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0301', 'Arbitro #29: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0301', 'Arbitro #29: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0302: Arbitro #30: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 30)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0302', 'Arbitro #30: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0302', 'Arbitro #30: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0303: Arbitro #31: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 31)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0303', 'Arbitro #31: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0303', 'Arbitro #31: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0304: Arbitro #32: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 32)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0304', 'Arbitro #32: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0304', 'Arbitro #32: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0305: Arbitro #33: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 33)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0305', 'Arbitro #33: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0305', 'Arbitro #33: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0306: Arbitro #34: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 34)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0306', 'Arbitro #34: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0306', 'Arbitro #34: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0307: Arbitro #35: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 35)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0307', 'Arbitro #35: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0307', 'Arbitro #35: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0308: Arbitro #36: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 36)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0308', 'Arbitro #36: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0308', 'Arbitro #36: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0309: Arbitro #37: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 37)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0309', 'Arbitro #37: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0309', 'Arbitro #37: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0310: Arbitro #38: no esta designado dos veces en el mismo partido
BEGIN TRY
;WITH s AS (SELECT t.id_persona AS id FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 38)
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle)
    SELECT '0310', 'Arbitro #38: no esta designado dos veces en el mismo partido',
           CASE WHEN s.id IS NULL THEN 'SKIP' WHEN m.n = 0 THEN 'OK' ELSE 'FAIL' END,
           'id=' + ISNULL(CAST(s.id AS VARCHAR(10)), '-') + ' valor=' + ISNULL(CAST(m.n AS VARCHAR(10)), '-')
    FROM (SELECT 1 AS d) AS d1
    LEFT JOIN s ON 1 = 1
    OUTER APPLY (SELECT COUNT(*) AS n FROM (SELECT d.id_partido FROM arbitraje.designacion_arbitral AS d WHERE d.id_arbitro = s.id GROUP BY d.id_partido HAVING COUNT(*) > 1) AS g) AS m;
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0310', 'Arbitro #38: no esta designado dos veces en el mismo partido', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 104_Lote_Prueba_Integridad_05.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
-- Al terminar todos los lotes: DROP TABLE ##lote_resultado;
