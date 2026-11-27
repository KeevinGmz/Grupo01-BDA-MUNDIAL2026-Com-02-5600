/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de reportes 7 de 10: ejecuta los procedimientos del esquema reporte
          (script 38) con parametros reales tomados de la base y guarda OK, ERROR o SKIP en la tabla
          temporal global ##lote_resultado (SKIP: ese numero de sujeto no existe en la base).
          Requiere los scripts 00 a 47 y 90 a 93. Conviene activar en SSMS: Consulta > Opciones de
          consulta > Resultados > Cuadricula > Descartar resultados despues de la ejecucion.

Casos 0373 a 0434 de este lote:
  - Matriz prime time partido #N (62 casos)
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

-- Caso 0373: Matriz prime time partido #16
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 16);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0373', 'Matriz prime time partido #16', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0373', 'Matriz prime time partido #16', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0373', 'Matriz prime time partido #16', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0374: Matriz prime time partido #17
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 17);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0374', 'Matriz prime time partido #17', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0374', 'Matriz prime time partido #17', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0374', 'Matriz prime time partido #17', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0375: Matriz prime time partido #18
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 18);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0375', 'Matriz prime time partido #18', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0375', 'Matriz prime time partido #18', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0375', 'Matriz prime time partido #18', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0376: Matriz prime time partido #19
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 19);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0376', 'Matriz prime time partido #19', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0376', 'Matriz prime time partido #19', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0376', 'Matriz prime time partido #19', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0377: Matriz prime time partido #20
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 20);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0377', 'Matriz prime time partido #20', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0377', 'Matriz prime time partido #20', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0377', 'Matriz prime time partido #20', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0378: Matriz prime time partido #21
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 21);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0378', 'Matriz prime time partido #21', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0378', 'Matriz prime time partido #21', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0378', 'Matriz prime time partido #21', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0379: Matriz prime time partido #22
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 22);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0379', 'Matriz prime time partido #22', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0379', 'Matriz prime time partido #22', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0379', 'Matriz prime time partido #22', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0380: Matriz prime time partido #23
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 23);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0380', 'Matriz prime time partido #23', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0380', 'Matriz prime time partido #23', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0380', 'Matriz prime time partido #23', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0381: Matriz prime time partido #24
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 24);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0381', 'Matriz prime time partido #24', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0381', 'Matriz prime time partido #24', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0381', 'Matriz prime time partido #24', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0382: Matriz prime time partido #25
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 25);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0382', 'Matriz prime time partido #25', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0382', 'Matriz prime time partido #25', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0382', 'Matriz prime time partido #25', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0383: Matriz prime time partido #26
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 26);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0383', 'Matriz prime time partido #26', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0383', 'Matriz prime time partido #26', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0383', 'Matriz prime time partido #26', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0384: Matriz prime time partido #27
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 27);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0384', 'Matriz prime time partido #27', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0384', 'Matriz prime time partido #27', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0384', 'Matriz prime time partido #27', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0385: Matriz prime time partido #28
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 28);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0385', 'Matriz prime time partido #28', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0385', 'Matriz prime time partido #28', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0385', 'Matriz prime time partido #28', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0386: Matriz prime time partido #29
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 29);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0386', 'Matriz prime time partido #29', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0386', 'Matriz prime time partido #29', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0386', 'Matriz prime time partido #29', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0387: Matriz prime time partido #30
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 30);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0387', 'Matriz prime time partido #30', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0387', 'Matriz prime time partido #30', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0387', 'Matriz prime time partido #30', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0388: Matriz prime time partido #31
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 31);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0388', 'Matriz prime time partido #31', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0388', 'Matriz prime time partido #31', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0388', 'Matriz prime time partido #31', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0389: Matriz prime time partido #32
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 32);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0389', 'Matriz prime time partido #32', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0389', 'Matriz prime time partido #32', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0389', 'Matriz prime time partido #32', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0390: Matriz prime time partido #33
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 33);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0390', 'Matriz prime time partido #33', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0390', 'Matriz prime time partido #33', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0390', 'Matriz prime time partido #33', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0391: Matriz prime time partido #34
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 34);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0391', 'Matriz prime time partido #34', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0391', 'Matriz prime time partido #34', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0391', 'Matriz prime time partido #34', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0392: Matriz prime time partido #35
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 35);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0392', 'Matriz prime time partido #35', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0392', 'Matriz prime time partido #35', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0392', 'Matriz prime time partido #35', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0393: Matriz prime time partido #36
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 36);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0393', 'Matriz prime time partido #36', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0393', 'Matriz prime time partido #36', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0393', 'Matriz prime time partido #36', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0394: Matriz prime time partido #37
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 37);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0394', 'Matriz prime time partido #37', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0394', 'Matriz prime time partido #37', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0394', 'Matriz prime time partido #37', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0395: Matriz prime time partido #38
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 38);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0395', 'Matriz prime time partido #38', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0395', 'Matriz prime time partido #38', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0395', 'Matriz prime time partido #38', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0396: Matriz prime time partido #39
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 39);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0396', 'Matriz prime time partido #39', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0396', 'Matriz prime time partido #39', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0396', 'Matriz prime time partido #39', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0397: Matriz prime time partido #40
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 40);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0397', 'Matriz prime time partido #40', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0397', 'Matriz prime time partido #40', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0397', 'Matriz prime time partido #40', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0398: Matriz prime time partido #41
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 41);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0398', 'Matriz prime time partido #41', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0398', 'Matriz prime time partido #41', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0398', 'Matriz prime time partido #41', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0399: Matriz prime time partido #42
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 42);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0399', 'Matriz prime time partido #42', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0399', 'Matriz prime time partido #42', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0399', 'Matriz prime time partido #42', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0400: Matriz prime time partido #43
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 43);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0400', 'Matriz prime time partido #43', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0400', 'Matriz prime time partido #43', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0400', 'Matriz prime time partido #43', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0401: Matriz prime time partido #44
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 44);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0401', 'Matriz prime time partido #44', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0401', 'Matriz prime time partido #44', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0401', 'Matriz prime time partido #44', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0402: Matriz prime time partido #45
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 45);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0402', 'Matriz prime time partido #45', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0402', 'Matriz prime time partido #45', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0402', 'Matriz prime time partido #45', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0403: Matriz prime time partido #46
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 46);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0403', 'Matriz prime time partido #46', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0403', 'Matriz prime time partido #46', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0403', 'Matriz prime time partido #46', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0404: Matriz prime time partido #47
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 47);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0404', 'Matriz prime time partido #47', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0404', 'Matriz prime time partido #47', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0404', 'Matriz prime time partido #47', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0405: Matriz prime time partido #48
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 48);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0405', 'Matriz prime time partido #48', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0405', 'Matriz prime time partido #48', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0405', 'Matriz prime time partido #48', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0406: Matriz prime time partido #49
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 49);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0406', 'Matriz prime time partido #49', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0406', 'Matriz prime time partido #49', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0406', 'Matriz prime time partido #49', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0407: Matriz prime time partido #50
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 50);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0407', 'Matriz prime time partido #50', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0407', 'Matriz prime time partido #50', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0407', 'Matriz prime time partido #50', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0408: Matriz prime time partido #51
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 51);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0408', 'Matriz prime time partido #51', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0408', 'Matriz prime time partido #51', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0408', 'Matriz prime time partido #51', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0409: Matriz prime time partido #52
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 52);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0409', 'Matriz prime time partido #52', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0409', 'Matriz prime time partido #52', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0409', 'Matriz prime time partido #52', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0410: Matriz prime time partido #53
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 53);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0410', 'Matriz prime time partido #53', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0410', 'Matriz prime time partido #53', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0410', 'Matriz prime time partido #53', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0411: Matriz prime time partido #54
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 54);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0411', 'Matriz prime time partido #54', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0411', 'Matriz prime time partido #54', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0411', 'Matriz prime time partido #54', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0412: Matriz prime time partido #55
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 55);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0412', 'Matriz prime time partido #55', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0412', 'Matriz prime time partido #55', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0412', 'Matriz prime time partido #55', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0413: Matriz prime time partido #56
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 56);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0413', 'Matriz prime time partido #56', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0413', 'Matriz prime time partido #56', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0413', 'Matriz prime time partido #56', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0414: Matriz prime time partido #57
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 57);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0414', 'Matriz prime time partido #57', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0414', 'Matriz prime time partido #57', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0414', 'Matriz prime time partido #57', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0415: Matriz prime time partido #58
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 58);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0415', 'Matriz prime time partido #58', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0415', 'Matriz prime time partido #58', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0415', 'Matriz prime time partido #58', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0416: Matriz prime time partido #59
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 59);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0416', 'Matriz prime time partido #59', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0416', 'Matriz prime time partido #59', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0416', 'Matriz prime time partido #59', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0417: Matriz prime time partido #60
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 60);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0417', 'Matriz prime time partido #60', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0417', 'Matriz prime time partido #60', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0417', 'Matriz prime time partido #60', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0418: Matriz prime time partido #61
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 61);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0418', 'Matriz prime time partido #61', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0418', 'Matriz prime time partido #61', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0418', 'Matriz prime time partido #61', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0419: Matriz prime time partido #62
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 62);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0419', 'Matriz prime time partido #62', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0419', 'Matriz prime time partido #62', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0419', 'Matriz prime time partido #62', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0420: Matriz prime time partido #63
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 63);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0420', 'Matriz prime time partido #63', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0420', 'Matriz prime time partido #63', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0420', 'Matriz prime time partido #63', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0421: Matriz prime time partido #64
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 64);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0421', 'Matriz prime time partido #64', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0421', 'Matriz prime time partido #64', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0421', 'Matriz prime time partido #64', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0422: Matriz prime time partido #65
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 65);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0422', 'Matriz prime time partido #65', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0422', 'Matriz prime time partido #65', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0422', 'Matriz prime time partido #65', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0423: Matriz prime time partido #66
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 66);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0423', 'Matriz prime time partido #66', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0423', 'Matriz prime time partido #66', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0423', 'Matriz prime time partido #66', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0424: Matriz prime time partido #67
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 67);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0424', 'Matriz prime time partido #67', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0424', 'Matriz prime time partido #67', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0424', 'Matriz prime time partido #67', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0425: Matriz prime time partido #68
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 68);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0425', 'Matriz prime time partido #68', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0425', 'Matriz prime time partido #68', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0425', 'Matriz prime time partido #68', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0426: Matriz prime time partido #69
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 69);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0426', 'Matriz prime time partido #69', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0426', 'Matriz prime time partido #69', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0426', 'Matriz prime time partido #69', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0427: Matriz prime time partido #70
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 70);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0427', 'Matriz prime time partido #70', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0427', 'Matriz prime time partido #70', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0427', 'Matriz prime time partido #70', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0428: Matriz prime time partido #71
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 71);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0428', 'Matriz prime time partido #71', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0428', 'Matriz prime time partido #71', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0428', 'Matriz prime time partido #71', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0429: Matriz prime time partido #72
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 72);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0429', 'Matriz prime time partido #72', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0429', 'Matriz prime time partido #72', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0429', 'Matriz prime time partido #72', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0430: Matriz prime time partido #73
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 73);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0430', 'Matriz prime time partido #73', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0430', 'Matriz prime time partido #73', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0430', 'Matriz prime time partido #73', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0431: Matriz prime time partido #74
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 74);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0431', 'Matriz prime time partido #74', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0431', 'Matriz prime time partido #74', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0431', 'Matriz prime time partido #74', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0432: Matriz prime time partido #75
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 75);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0432', 'Matriz prime time partido #75', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0432', 'Matriz prime time partido #75', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0432', 'Matriz prime time partido #75', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0433: Matriz prime time partido #76
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 76);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0433', 'Matriz prime time partido #76', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0433', 'Matriz prime time partido #76', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0433', 'Matriz prime time partido #76', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0434: Matriz prime time partido #77
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 77);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0434', 'Matriz prime time partido #77', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0434', 'Matriz prime time partido #77', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0434', 'Matriz prime time partido #77', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 116_Lote_Reportes_07.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
