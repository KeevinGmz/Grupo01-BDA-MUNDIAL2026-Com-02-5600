/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de reportes 6 de 10: ejecuta los procedimientos del esquema reporte
          (script 38) con parametros reales tomados de la base y guarda OK, ERROR o SKIP en la tabla
          temporal global ##lote_resultado (SKIP: ese numero de sujeto no existe en la base).
          Requiere los scripts 00 a 47 y 90 a 93. Conviene activar en SSMS: Consulta > Opciones de
          consulta > Resultados > Cuadricula > Descartar resultados despues de la ejecucion.

Casos 0311 a 0372 de este lote:
  - Ocupacion publicitaria partido #N (47 casos)
  - Matriz prime time partido #N (15 casos)
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

-- Caso 0311: Ocupacion publicitaria partido #58
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 58);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0311', 'Ocupacion publicitaria partido #58', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0311', 'Ocupacion publicitaria partido #58', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0311', 'Ocupacion publicitaria partido #58', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0312: Ocupacion publicitaria partido #59
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 59);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0312', 'Ocupacion publicitaria partido #59', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0312', 'Ocupacion publicitaria partido #59', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0312', 'Ocupacion publicitaria partido #59', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0313: Ocupacion publicitaria partido #60
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 60);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0313', 'Ocupacion publicitaria partido #60', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0313', 'Ocupacion publicitaria partido #60', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0313', 'Ocupacion publicitaria partido #60', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0314: Ocupacion publicitaria partido #61
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 61);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0314', 'Ocupacion publicitaria partido #61', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0314', 'Ocupacion publicitaria partido #61', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0314', 'Ocupacion publicitaria partido #61', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0315: Ocupacion publicitaria partido #62
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 62);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0315', 'Ocupacion publicitaria partido #62', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0315', 'Ocupacion publicitaria partido #62', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0315', 'Ocupacion publicitaria partido #62', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0316: Ocupacion publicitaria partido #63
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 63);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0316', 'Ocupacion publicitaria partido #63', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0316', 'Ocupacion publicitaria partido #63', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0316', 'Ocupacion publicitaria partido #63', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0317: Ocupacion publicitaria partido #64
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 64);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0317', 'Ocupacion publicitaria partido #64', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0317', 'Ocupacion publicitaria partido #64', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0317', 'Ocupacion publicitaria partido #64', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0318: Ocupacion publicitaria partido #65
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 65);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0318', 'Ocupacion publicitaria partido #65', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0318', 'Ocupacion publicitaria partido #65', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0318', 'Ocupacion publicitaria partido #65', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0319: Ocupacion publicitaria partido #66
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 66);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0319', 'Ocupacion publicitaria partido #66', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0319', 'Ocupacion publicitaria partido #66', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0319', 'Ocupacion publicitaria partido #66', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0320: Ocupacion publicitaria partido #67
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 67);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0320', 'Ocupacion publicitaria partido #67', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0320', 'Ocupacion publicitaria partido #67', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0320', 'Ocupacion publicitaria partido #67', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0321: Ocupacion publicitaria partido #68
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 68);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0321', 'Ocupacion publicitaria partido #68', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0321', 'Ocupacion publicitaria partido #68', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0321', 'Ocupacion publicitaria partido #68', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0322: Ocupacion publicitaria partido #69
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 69);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0322', 'Ocupacion publicitaria partido #69', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0322', 'Ocupacion publicitaria partido #69', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0322', 'Ocupacion publicitaria partido #69', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0323: Ocupacion publicitaria partido #70
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 70);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0323', 'Ocupacion publicitaria partido #70', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0323', 'Ocupacion publicitaria partido #70', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0323', 'Ocupacion publicitaria partido #70', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0324: Ocupacion publicitaria partido #71
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 71);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0324', 'Ocupacion publicitaria partido #71', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0324', 'Ocupacion publicitaria partido #71', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0324', 'Ocupacion publicitaria partido #71', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0325: Ocupacion publicitaria partido #72
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 72);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0325', 'Ocupacion publicitaria partido #72', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0325', 'Ocupacion publicitaria partido #72', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0325', 'Ocupacion publicitaria partido #72', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0326: Ocupacion publicitaria partido #73
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 73);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0326', 'Ocupacion publicitaria partido #73', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0326', 'Ocupacion publicitaria partido #73', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0326', 'Ocupacion publicitaria partido #73', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0327: Ocupacion publicitaria partido #74
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 74);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0327', 'Ocupacion publicitaria partido #74', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0327', 'Ocupacion publicitaria partido #74', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0327', 'Ocupacion publicitaria partido #74', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0328: Ocupacion publicitaria partido #75
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 75);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0328', 'Ocupacion publicitaria partido #75', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0328', 'Ocupacion publicitaria partido #75', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0328', 'Ocupacion publicitaria partido #75', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0329: Ocupacion publicitaria partido #76
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 76);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0329', 'Ocupacion publicitaria partido #76', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0329', 'Ocupacion publicitaria partido #76', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0329', 'Ocupacion publicitaria partido #76', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0330: Ocupacion publicitaria partido #77
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 77);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0330', 'Ocupacion publicitaria partido #77', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0330', 'Ocupacion publicitaria partido #77', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0330', 'Ocupacion publicitaria partido #77', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0331: Ocupacion publicitaria partido #78
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 78);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0331', 'Ocupacion publicitaria partido #78', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0331', 'Ocupacion publicitaria partido #78', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0331', 'Ocupacion publicitaria partido #78', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0332: Ocupacion publicitaria partido #79
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 79);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0332', 'Ocupacion publicitaria partido #79', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0332', 'Ocupacion publicitaria partido #79', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0332', 'Ocupacion publicitaria partido #79', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0333: Ocupacion publicitaria partido #80
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 80);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0333', 'Ocupacion publicitaria partido #80', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0333', 'Ocupacion publicitaria partido #80', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0333', 'Ocupacion publicitaria partido #80', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0334: Ocupacion publicitaria partido #81
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 81);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0334', 'Ocupacion publicitaria partido #81', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0334', 'Ocupacion publicitaria partido #81', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0334', 'Ocupacion publicitaria partido #81', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0335: Ocupacion publicitaria partido #82
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 82);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0335', 'Ocupacion publicitaria partido #82', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0335', 'Ocupacion publicitaria partido #82', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0335', 'Ocupacion publicitaria partido #82', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0336: Ocupacion publicitaria partido #83
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 83);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0336', 'Ocupacion publicitaria partido #83', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0336', 'Ocupacion publicitaria partido #83', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0336', 'Ocupacion publicitaria partido #83', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0337: Ocupacion publicitaria partido #84
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 84);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0337', 'Ocupacion publicitaria partido #84', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0337', 'Ocupacion publicitaria partido #84', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0337', 'Ocupacion publicitaria partido #84', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0338: Ocupacion publicitaria partido #85
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 85);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0338', 'Ocupacion publicitaria partido #85', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0338', 'Ocupacion publicitaria partido #85', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0338', 'Ocupacion publicitaria partido #85', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0339: Ocupacion publicitaria partido #86
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 86);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0339', 'Ocupacion publicitaria partido #86', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0339', 'Ocupacion publicitaria partido #86', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0339', 'Ocupacion publicitaria partido #86', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0340: Ocupacion publicitaria partido #87
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 87);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0340', 'Ocupacion publicitaria partido #87', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0340', 'Ocupacion publicitaria partido #87', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0340', 'Ocupacion publicitaria partido #87', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0341: Ocupacion publicitaria partido #88
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 88);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0341', 'Ocupacion publicitaria partido #88', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0341', 'Ocupacion publicitaria partido #88', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0341', 'Ocupacion publicitaria partido #88', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0342: Ocupacion publicitaria partido #89
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 89);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0342', 'Ocupacion publicitaria partido #89', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0342', 'Ocupacion publicitaria partido #89', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0342', 'Ocupacion publicitaria partido #89', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0343: Ocupacion publicitaria partido #90
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 90);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0343', 'Ocupacion publicitaria partido #90', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0343', 'Ocupacion publicitaria partido #90', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0343', 'Ocupacion publicitaria partido #90', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0344: Ocupacion publicitaria partido #91
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 91);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0344', 'Ocupacion publicitaria partido #91', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0344', 'Ocupacion publicitaria partido #91', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0344', 'Ocupacion publicitaria partido #91', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0345: Ocupacion publicitaria partido #92
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 92);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0345', 'Ocupacion publicitaria partido #92', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0345', 'Ocupacion publicitaria partido #92', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0345', 'Ocupacion publicitaria partido #92', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0346: Ocupacion publicitaria partido #93
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 93);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0346', 'Ocupacion publicitaria partido #93', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0346', 'Ocupacion publicitaria partido #93', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0346', 'Ocupacion publicitaria partido #93', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0347: Ocupacion publicitaria partido #94
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 94);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0347', 'Ocupacion publicitaria partido #94', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0347', 'Ocupacion publicitaria partido #94', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0347', 'Ocupacion publicitaria partido #94', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0348: Ocupacion publicitaria partido #95
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 95);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0348', 'Ocupacion publicitaria partido #95', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0348', 'Ocupacion publicitaria partido #95', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0348', 'Ocupacion publicitaria partido #95', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0349: Ocupacion publicitaria partido #96
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 96);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0349', 'Ocupacion publicitaria partido #96', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0349', 'Ocupacion publicitaria partido #96', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0349', 'Ocupacion publicitaria partido #96', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0350: Ocupacion publicitaria partido #97
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 97);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0350', 'Ocupacion publicitaria partido #97', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0350', 'Ocupacion publicitaria partido #97', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0350', 'Ocupacion publicitaria partido #97', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0351: Ocupacion publicitaria partido #98
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 98);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0351', 'Ocupacion publicitaria partido #98', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0351', 'Ocupacion publicitaria partido #98', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0351', 'Ocupacion publicitaria partido #98', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0352: Ocupacion publicitaria partido #99
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 99);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0352', 'Ocupacion publicitaria partido #99', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0352', 'Ocupacion publicitaria partido #99', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0352', 'Ocupacion publicitaria partido #99', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0353: Ocupacion publicitaria partido #100
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 100);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0353', 'Ocupacion publicitaria partido #100', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0353', 'Ocupacion publicitaria partido #100', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0353', 'Ocupacion publicitaria partido #100', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0354: Ocupacion publicitaria partido #101
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 101);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0354', 'Ocupacion publicitaria partido #101', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0354', 'Ocupacion publicitaria partido #101', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0354', 'Ocupacion publicitaria partido #101', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0355: Ocupacion publicitaria partido #102
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 102);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0355', 'Ocupacion publicitaria partido #102', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0355', 'Ocupacion publicitaria partido #102', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0355', 'Ocupacion publicitaria partido #102', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0356: Ocupacion publicitaria partido #103
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 103);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0356', 'Ocupacion publicitaria partido #103', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0356', 'Ocupacion publicitaria partido #103', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0356', 'Ocupacion publicitaria partido #103', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0357: Ocupacion publicitaria partido #104
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 104);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0357', 'Ocupacion publicitaria partido #104', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0357', 'Ocupacion publicitaria partido #104', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0357', 'Ocupacion publicitaria partido #104', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0358: Matriz prime time partido #1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 1);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0358', 'Matriz prime time partido #1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0358', 'Matriz prime time partido #1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0358', 'Matriz prime time partido #1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0359: Matriz prime time partido #2
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 2);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0359', 'Matriz prime time partido #2', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0359', 'Matriz prime time partido #2', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0359', 'Matriz prime time partido #2', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0360: Matriz prime time partido #3
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 3);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0360', 'Matriz prime time partido #3', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0360', 'Matriz prime time partido #3', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0360', 'Matriz prime time partido #3', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0361: Matriz prime time partido #4
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 4);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0361', 'Matriz prime time partido #4', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0361', 'Matriz prime time partido #4', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0361', 'Matriz prime time partido #4', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0362: Matriz prime time partido #5
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 5);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0362', 'Matriz prime time partido #5', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0362', 'Matriz prime time partido #5', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0362', 'Matriz prime time partido #5', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0363: Matriz prime time partido #6
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 6);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0363', 'Matriz prime time partido #6', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0363', 'Matriz prime time partido #6', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0363', 'Matriz prime time partido #6', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0364: Matriz prime time partido #7
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 7);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0364', 'Matriz prime time partido #7', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0364', 'Matriz prime time partido #7', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0364', 'Matriz prime time partido #7', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0365: Matriz prime time partido #8
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 8);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0365', 'Matriz prime time partido #8', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0365', 'Matriz prime time partido #8', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0365', 'Matriz prime time partido #8', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0366: Matriz prime time partido #9
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 9);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0366', 'Matriz prime time partido #9', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0366', 'Matriz prime time partido #9', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0366', 'Matriz prime time partido #9', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0367: Matriz prime time partido #10
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 10);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0367', 'Matriz prime time partido #10', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0367', 'Matriz prime time partido #10', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0367', 'Matriz prime time partido #10', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0368: Matriz prime time partido #11
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 11);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0368', 'Matriz prime time partido #11', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0368', 'Matriz prime time partido #11', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0368', 'Matriz prime time partido #11', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0369: Matriz prime time partido #12
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 12);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0369', 'Matriz prime time partido #12', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0369', 'Matriz prime time partido #12', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0369', 'Matriz prime time partido #12', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0370: Matriz prime time partido #13
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 13);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0370', 'Matriz prime time partido #13', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0370', 'Matriz prime time partido #13', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0370', 'Matriz prime time partido #13', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0371: Matriz prime time partido #14
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 14);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0371', 'Matriz prime time partido #14', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0371', 'Matriz prime time partido #14', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0371', 'Matriz prime time partido #14', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0372: Matriz prime time partido #15
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 15);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0372', 'Matriz prime time partido #15', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0372', 'Matriz prime time partido #15', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0372', 'Matriz prime time partido #15', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 115_Lote_Reportes_06.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
