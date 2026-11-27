/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de reportes 5 de 10: ejecuta los procedimientos del esquema reporte
          (script 38) con parametros reales tomados de la base y guarda OK, ERROR o SKIP en la tabla
          temporal global ##lote_resultado (SKIP: ese numero de sujeto no existe en la base).
          Requiere los scripts 00 a 47 y 90 a 93. Conviene activar en SSMS: Consulta > Opciones de
          consulta > Resultados > Cuadricula > Descartar resultados despues de la ejecucion.

Casos 0249 a 0310 de este lote:
  - Ocupacion publicitaria sede #N (5 casos)
  - Ocupacion publicitaria partido #N (57 casos)
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

-- Caso 0249: Ocupacion publicitaria sede #12
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 12);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0249', 'Ocupacion publicitaria sede #12', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0249', 'Ocupacion publicitaria sede #12', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0249', 'Ocupacion publicitaria sede #12', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0250: Ocupacion publicitaria sede #13
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 13);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0250', 'Ocupacion publicitaria sede #13', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0250', 'Ocupacion publicitaria sede #13', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0250', 'Ocupacion publicitaria sede #13', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0251: Ocupacion publicitaria sede #14
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 14);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0251', 'Ocupacion publicitaria sede #14', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0251', 'Ocupacion publicitaria sede #14', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0251', 'Ocupacion publicitaria sede #14', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0252: Ocupacion publicitaria sede #15
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 15);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0252', 'Ocupacion publicitaria sede #15', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0252', 'Ocupacion publicitaria sede #15', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0252', 'Ocupacion publicitaria sede #15', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0253: Ocupacion publicitaria sede #16
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 16);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0253', 'Ocupacion publicitaria sede #16', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0253', 'Ocupacion publicitaria sede #16', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0253', 'Ocupacion publicitaria sede #16', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0254: Ocupacion publicitaria partido #1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 1);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0254', 'Ocupacion publicitaria partido #1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0254', 'Ocupacion publicitaria partido #1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0254', 'Ocupacion publicitaria partido #1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0255: Ocupacion publicitaria partido #2
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 2);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0255', 'Ocupacion publicitaria partido #2', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0255', 'Ocupacion publicitaria partido #2', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0255', 'Ocupacion publicitaria partido #2', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0256: Ocupacion publicitaria partido #3
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 3);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0256', 'Ocupacion publicitaria partido #3', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0256', 'Ocupacion publicitaria partido #3', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0256', 'Ocupacion publicitaria partido #3', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0257: Ocupacion publicitaria partido #4
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 4);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0257', 'Ocupacion publicitaria partido #4', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0257', 'Ocupacion publicitaria partido #4', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0257', 'Ocupacion publicitaria partido #4', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0258: Ocupacion publicitaria partido #5
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 5);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0258', 'Ocupacion publicitaria partido #5', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0258', 'Ocupacion publicitaria partido #5', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0258', 'Ocupacion publicitaria partido #5', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0259: Ocupacion publicitaria partido #6
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 6);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0259', 'Ocupacion publicitaria partido #6', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0259', 'Ocupacion publicitaria partido #6', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0259', 'Ocupacion publicitaria partido #6', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0260: Ocupacion publicitaria partido #7
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 7);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0260', 'Ocupacion publicitaria partido #7', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0260', 'Ocupacion publicitaria partido #7', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0260', 'Ocupacion publicitaria partido #7', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0261: Ocupacion publicitaria partido #8
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 8);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0261', 'Ocupacion publicitaria partido #8', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0261', 'Ocupacion publicitaria partido #8', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0261', 'Ocupacion publicitaria partido #8', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0262: Ocupacion publicitaria partido #9
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 9);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0262', 'Ocupacion publicitaria partido #9', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0262', 'Ocupacion publicitaria partido #9', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0262', 'Ocupacion publicitaria partido #9', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0263: Ocupacion publicitaria partido #10
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 10);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0263', 'Ocupacion publicitaria partido #10', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0263', 'Ocupacion publicitaria partido #10', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0263', 'Ocupacion publicitaria partido #10', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0264: Ocupacion publicitaria partido #11
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 11);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0264', 'Ocupacion publicitaria partido #11', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0264', 'Ocupacion publicitaria partido #11', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0264', 'Ocupacion publicitaria partido #11', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0265: Ocupacion publicitaria partido #12
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 12);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0265', 'Ocupacion publicitaria partido #12', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0265', 'Ocupacion publicitaria partido #12', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0265', 'Ocupacion publicitaria partido #12', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0266: Ocupacion publicitaria partido #13
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 13);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0266', 'Ocupacion publicitaria partido #13', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0266', 'Ocupacion publicitaria partido #13', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0266', 'Ocupacion publicitaria partido #13', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0267: Ocupacion publicitaria partido #14
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 14);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0267', 'Ocupacion publicitaria partido #14', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0267', 'Ocupacion publicitaria partido #14', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0267', 'Ocupacion publicitaria partido #14', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0268: Ocupacion publicitaria partido #15
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 15);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0268', 'Ocupacion publicitaria partido #15', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0268', 'Ocupacion publicitaria partido #15', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0268', 'Ocupacion publicitaria partido #15', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0269: Ocupacion publicitaria partido #16
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 16);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0269', 'Ocupacion publicitaria partido #16', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0269', 'Ocupacion publicitaria partido #16', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0269', 'Ocupacion publicitaria partido #16', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0270: Ocupacion publicitaria partido #17
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 17);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0270', 'Ocupacion publicitaria partido #17', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0270', 'Ocupacion publicitaria partido #17', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0270', 'Ocupacion publicitaria partido #17', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0271: Ocupacion publicitaria partido #18
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 18);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0271', 'Ocupacion publicitaria partido #18', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0271', 'Ocupacion publicitaria partido #18', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0271', 'Ocupacion publicitaria partido #18', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0272: Ocupacion publicitaria partido #19
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 19);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0272', 'Ocupacion publicitaria partido #19', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0272', 'Ocupacion publicitaria partido #19', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0272', 'Ocupacion publicitaria partido #19', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0273: Ocupacion publicitaria partido #20
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 20);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0273', 'Ocupacion publicitaria partido #20', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0273', 'Ocupacion publicitaria partido #20', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0273', 'Ocupacion publicitaria partido #20', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0274: Ocupacion publicitaria partido #21
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 21);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0274', 'Ocupacion publicitaria partido #21', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0274', 'Ocupacion publicitaria partido #21', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0274', 'Ocupacion publicitaria partido #21', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0275: Ocupacion publicitaria partido #22
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 22);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0275', 'Ocupacion publicitaria partido #22', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0275', 'Ocupacion publicitaria partido #22', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0275', 'Ocupacion publicitaria partido #22', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0276: Ocupacion publicitaria partido #23
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 23);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0276', 'Ocupacion publicitaria partido #23', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0276', 'Ocupacion publicitaria partido #23', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0276', 'Ocupacion publicitaria partido #23', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0277: Ocupacion publicitaria partido #24
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 24);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0277', 'Ocupacion publicitaria partido #24', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0277', 'Ocupacion publicitaria partido #24', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0277', 'Ocupacion publicitaria partido #24', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0278: Ocupacion publicitaria partido #25
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 25);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0278', 'Ocupacion publicitaria partido #25', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0278', 'Ocupacion publicitaria partido #25', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0278', 'Ocupacion publicitaria partido #25', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0279: Ocupacion publicitaria partido #26
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 26);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0279', 'Ocupacion publicitaria partido #26', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0279', 'Ocupacion publicitaria partido #26', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0279', 'Ocupacion publicitaria partido #26', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0280: Ocupacion publicitaria partido #27
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 27);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0280', 'Ocupacion publicitaria partido #27', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0280', 'Ocupacion publicitaria partido #27', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0280', 'Ocupacion publicitaria partido #27', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0281: Ocupacion publicitaria partido #28
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 28);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0281', 'Ocupacion publicitaria partido #28', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0281', 'Ocupacion publicitaria partido #28', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0281', 'Ocupacion publicitaria partido #28', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0282: Ocupacion publicitaria partido #29
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 29);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0282', 'Ocupacion publicitaria partido #29', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0282', 'Ocupacion publicitaria partido #29', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0282', 'Ocupacion publicitaria partido #29', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0283: Ocupacion publicitaria partido #30
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 30);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0283', 'Ocupacion publicitaria partido #30', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0283', 'Ocupacion publicitaria partido #30', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0283', 'Ocupacion publicitaria partido #30', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0284: Ocupacion publicitaria partido #31
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 31);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0284', 'Ocupacion publicitaria partido #31', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0284', 'Ocupacion publicitaria partido #31', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0284', 'Ocupacion publicitaria partido #31', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0285: Ocupacion publicitaria partido #32
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 32);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0285', 'Ocupacion publicitaria partido #32', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0285', 'Ocupacion publicitaria partido #32', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0285', 'Ocupacion publicitaria partido #32', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0286: Ocupacion publicitaria partido #33
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 33);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0286', 'Ocupacion publicitaria partido #33', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0286', 'Ocupacion publicitaria partido #33', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0286', 'Ocupacion publicitaria partido #33', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0287: Ocupacion publicitaria partido #34
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 34);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0287', 'Ocupacion publicitaria partido #34', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0287', 'Ocupacion publicitaria partido #34', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0287', 'Ocupacion publicitaria partido #34', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0288: Ocupacion publicitaria partido #35
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 35);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0288', 'Ocupacion publicitaria partido #35', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0288', 'Ocupacion publicitaria partido #35', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0288', 'Ocupacion publicitaria partido #35', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0289: Ocupacion publicitaria partido #36
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 36);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0289', 'Ocupacion publicitaria partido #36', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0289', 'Ocupacion publicitaria partido #36', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0289', 'Ocupacion publicitaria partido #36', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0290: Ocupacion publicitaria partido #37
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 37);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0290', 'Ocupacion publicitaria partido #37', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0290', 'Ocupacion publicitaria partido #37', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0290', 'Ocupacion publicitaria partido #37', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0291: Ocupacion publicitaria partido #38
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 38);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0291', 'Ocupacion publicitaria partido #38', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0291', 'Ocupacion publicitaria partido #38', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0291', 'Ocupacion publicitaria partido #38', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0292: Ocupacion publicitaria partido #39
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 39);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0292', 'Ocupacion publicitaria partido #39', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0292', 'Ocupacion publicitaria partido #39', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0292', 'Ocupacion publicitaria partido #39', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0293: Ocupacion publicitaria partido #40
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 40);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0293', 'Ocupacion publicitaria partido #40', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0293', 'Ocupacion publicitaria partido #40', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0293', 'Ocupacion publicitaria partido #40', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0294: Ocupacion publicitaria partido #41
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 41);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0294', 'Ocupacion publicitaria partido #41', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0294', 'Ocupacion publicitaria partido #41', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0294', 'Ocupacion publicitaria partido #41', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0295: Ocupacion publicitaria partido #42
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 42);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0295', 'Ocupacion publicitaria partido #42', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0295', 'Ocupacion publicitaria partido #42', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0295', 'Ocupacion publicitaria partido #42', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0296: Ocupacion publicitaria partido #43
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 43);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0296', 'Ocupacion publicitaria partido #43', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0296', 'Ocupacion publicitaria partido #43', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0296', 'Ocupacion publicitaria partido #43', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0297: Ocupacion publicitaria partido #44
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 44);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0297', 'Ocupacion publicitaria partido #44', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0297', 'Ocupacion publicitaria partido #44', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0297', 'Ocupacion publicitaria partido #44', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0298: Ocupacion publicitaria partido #45
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 45);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0298', 'Ocupacion publicitaria partido #45', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0298', 'Ocupacion publicitaria partido #45', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0298', 'Ocupacion publicitaria partido #45', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0299: Ocupacion publicitaria partido #46
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 46);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0299', 'Ocupacion publicitaria partido #46', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0299', 'Ocupacion publicitaria partido #46', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0299', 'Ocupacion publicitaria partido #46', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0300: Ocupacion publicitaria partido #47
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 47);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0300', 'Ocupacion publicitaria partido #47', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0300', 'Ocupacion publicitaria partido #47', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0300', 'Ocupacion publicitaria partido #47', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0301: Ocupacion publicitaria partido #48
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 48);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0301', 'Ocupacion publicitaria partido #48', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0301', 'Ocupacion publicitaria partido #48', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0301', 'Ocupacion publicitaria partido #48', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0302: Ocupacion publicitaria partido #49
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 49);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0302', 'Ocupacion publicitaria partido #49', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0302', 'Ocupacion publicitaria partido #49', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0302', 'Ocupacion publicitaria partido #49', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0303: Ocupacion publicitaria partido #50
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 50);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0303', 'Ocupacion publicitaria partido #50', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0303', 'Ocupacion publicitaria partido #50', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0303', 'Ocupacion publicitaria partido #50', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0304: Ocupacion publicitaria partido #51
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 51);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0304', 'Ocupacion publicitaria partido #51', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0304', 'Ocupacion publicitaria partido #51', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0304', 'Ocupacion publicitaria partido #51', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0305: Ocupacion publicitaria partido #52
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 52);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0305', 'Ocupacion publicitaria partido #52', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0305', 'Ocupacion publicitaria partido #52', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0305', 'Ocupacion publicitaria partido #52', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0306: Ocupacion publicitaria partido #53
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 53);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0306', 'Ocupacion publicitaria partido #53', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0306', 'Ocupacion publicitaria partido #53', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0306', 'Ocupacion publicitaria partido #53', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0307: Ocupacion publicitaria partido #54
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 54);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0307', 'Ocupacion publicitaria partido #54', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0307', 'Ocupacion publicitaria partido #54', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0307', 'Ocupacion publicitaria partido #54', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0308: Ocupacion publicitaria partido #55
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 55);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0308', 'Ocupacion publicitaria partido #55', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0308', 'Ocupacion publicitaria partido #55', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0308', 'Ocupacion publicitaria partido #55', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0309: Ocupacion publicitaria partido #56
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 56);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0309', 'Ocupacion publicitaria partido #56', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0309', 'Ocupacion publicitaria partido #56', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0309', 'Ocupacion publicitaria partido #56', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0310: Ocupacion publicitaria partido #57
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 57);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0310', 'Ocupacion publicitaria partido #57', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0310', 'Ocupacion publicitaria partido #57', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0310', 'Ocupacion publicitaria partido #57', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 114_Lote_Reportes_05.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
