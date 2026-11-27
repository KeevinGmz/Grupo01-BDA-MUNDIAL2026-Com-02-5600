/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de reportes 2 de 10: ejecuta los procedimientos del esquema reporte
          (script 38) con parametros reales tomados de la base y guarda OK, ERROR o SKIP en la tabla
          temporal global ##lote_resultado (SKIP: ese numero de sujeto no existe en la base).
          Requiere los scripts 00 a 47 y 90 a 93. Conviene activar en SSMS: Consulta > Opciones de
          consulta > Resultados > Cuadricula > Descartar resultados despues de la ejecucion.

Casos 0063 a 0124 de este lote:
  - Goleadores seleccion #N formato XML (34 casos)
  - Tarjetas seleccion #N solo_activas=1 (28 casos)
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

-- Caso 0063: Goleadores seleccion #15 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 15);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0063', 'Goleadores seleccion #15 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0063', 'Goleadores seleccion #15 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0063', 'Goleadores seleccion #15 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0064: Goleadores seleccion #16 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 16);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0064', 'Goleadores seleccion #16 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0064', 'Goleadores seleccion #16 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0064', 'Goleadores seleccion #16 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0065: Goleadores seleccion #17 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 17);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0065', 'Goleadores seleccion #17 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0065', 'Goleadores seleccion #17 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0065', 'Goleadores seleccion #17 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0066: Goleadores seleccion #18 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 18);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0066', 'Goleadores seleccion #18 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0066', 'Goleadores seleccion #18 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0066', 'Goleadores seleccion #18 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0067: Goleadores seleccion #19 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 19);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0067', 'Goleadores seleccion #19 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0067', 'Goleadores seleccion #19 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0067', 'Goleadores seleccion #19 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0068: Goleadores seleccion #20 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 20);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0068', 'Goleadores seleccion #20 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0068', 'Goleadores seleccion #20 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0068', 'Goleadores seleccion #20 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0069: Goleadores seleccion #21 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 21);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0069', 'Goleadores seleccion #21 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0069', 'Goleadores seleccion #21 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0069', 'Goleadores seleccion #21 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0070: Goleadores seleccion #22 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 22);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0070', 'Goleadores seleccion #22 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0070', 'Goleadores seleccion #22 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0070', 'Goleadores seleccion #22 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0071: Goleadores seleccion #23 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 23);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0071', 'Goleadores seleccion #23 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0071', 'Goleadores seleccion #23 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0071', 'Goleadores seleccion #23 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0072: Goleadores seleccion #24 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 24);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0072', 'Goleadores seleccion #24 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0072', 'Goleadores seleccion #24 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0072', 'Goleadores seleccion #24 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0073: Goleadores seleccion #25 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 25);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0073', 'Goleadores seleccion #25 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0073', 'Goleadores seleccion #25 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0073', 'Goleadores seleccion #25 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0074: Goleadores seleccion #26 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 26);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0074', 'Goleadores seleccion #26 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0074', 'Goleadores seleccion #26 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0074', 'Goleadores seleccion #26 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0075: Goleadores seleccion #27 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 27);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0075', 'Goleadores seleccion #27 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0075', 'Goleadores seleccion #27 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0075', 'Goleadores seleccion #27 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0076: Goleadores seleccion #28 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 28);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0076', 'Goleadores seleccion #28 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0076', 'Goleadores seleccion #28 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0076', 'Goleadores seleccion #28 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0077: Goleadores seleccion #29 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 29);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0077', 'Goleadores seleccion #29 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0077', 'Goleadores seleccion #29 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0077', 'Goleadores seleccion #29 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0078: Goleadores seleccion #30 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 30);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0078', 'Goleadores seleccion #30 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0078', 'Goleadores seleccion #30 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0078', 'Goleadores seleccion #30 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0079: Goleadores seleccion #31 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 31);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0079', 'Goleadores seleccion #31 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0079', 'Goleadores seleccion #31 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0079', 'Goleadores seleccion #31 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0080: Goleadores seleccion #32 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 32);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0080', 'Goleadores seleccion #32 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0080', 'Goleadores seleccion #32 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0080', 'Goleadores seleccion #32 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0081: Goleadores seleccion #33 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 33);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0081', 'Goleadores seleccion #33 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0081', 'Goleadores seleccion #33 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0081', 'Goleadores seleccion #33 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0082: Goleadores seleccion #34 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 34);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0082', 'Goleadores seleccion #34 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0082', 'Goleadores seleccion #34 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0082', 'Goleadores seleccion #34 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0083: Goleadores seleccion #35 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 35);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0083', 'Goleadores seleccion #35 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0083', 'Goleadores seleccion #35 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0083', 'Goleadores seleccion #35 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0084: Goleadores seleccion #36 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 36);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0084', 'Goleadores seleccion #36 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0084', 'Goleadores seleccion #36 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0084', 'Goleadores seleccion #36 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0085: Goleadores seleccion #37 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 37);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0085', 'Goleadores seleccion #37 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0085', 'Goleadores seleccion #37 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0085', 'Goleadores seleccion #37 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0086: Goleadores seleccion #38 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 38);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0086', 'Goleadores seleccion #38 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0086', 'Goleadores seleccion #38 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0086', 'Goleadores seleccion #38 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0087: Goleadores seleccion #39 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 39);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0087', 'Goleadores seleccion #39 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0087', 'Goleadores seleccion #39 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0087', 'Goleadores seleccion #39 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0088: Goleadores seleccion #40 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 40);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0088', 'Goleadores seleccion #40 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0088', 'Goleadores seleccion #40 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0088', 'Goleadores seleccion #40 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0089: Goleadores seleccion #41 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 41);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0089', 'Goleadores seleccion #41 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0089', 'Goleadores seleccion #41 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0089', 'Goleadores seleccion #41 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0090: Goleadores seleccion #42 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 42);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0090', 'Goleadores seleccion #42 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0090', 'Goleadores seleccion #42 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0090', 'Goleadores seleccion #42 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0091: Goleadores seleccion #43 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 43);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0091', 'Goleadores seleccion #43 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0091', 'Goleadores seleccion #43 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0091', 'Goleadores seleccion #43 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0092: Goleadores seleccion #44 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 44);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0092', 'Goleadores seleccion #44 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0092', 'Goleadores seleccion #44 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0092', 'Goleadores seleccion #44 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0093: Goleadores seleccion #45 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 45);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0093', 'Goleadores seleccion #45 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0093', 'Goleadores seleccion #45 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0093', 'Goleadores seleccion #45 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0094: Goleadores seleccion #46 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 46);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0094', 'Goleadores seleccion #46 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0094', 'Goleadores seleccion #46 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0094', 'Goleadores seleccion #46 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0095: Goleadores seleccion #47 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 47);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0095', 'Goleadores seleccion #47 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0095', 'Goleadores seleccion #47 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0095', 'Goleadores seleccion #47 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0096: Goleadores seleccion #48 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 48);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0096', 'Goleadores seleccion #48 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0096', 'Goleadores seleccion #48 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0096', 'Goleadores seleccion #48 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0097: Tarjetas seleccion #1 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 1);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0097', 'Tarjetas seleccion #1 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0097', 'Tarjetas seleccion #1 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0097', 'Tarjetas seleccion #1 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0098: Tarjetas seleccion #2 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 2);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0098', 'Tarjetas seleccion #2 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0098', 'Tarjetas seleccion #2 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0098', 'Tarjetas seleccion #2 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0099: Tarjetas seleccion #3 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 3);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0099', 'Tarjetas seleccion #3 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0099', 'Tarjetas seleccion #3 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0099', 'Tarjetas seleccion #3 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0100: Tarjetas seleccion #4 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 4);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0100', 'Tarjetas seleccion #4 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0100', 'Tarjetas seleccion #4 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0100', 'Tarjetas seleccion #4 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0101: Tarjetas seleccion #5 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 5);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0101', 'Tarjetas seleccion #5 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0101', 'Tarjetas seleccion #5 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0101', 'Tarjetas seleccion #5 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0102: Tarjetas seleccion #6 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 6);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0102', 'Tarjetas seleccion #6 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0102', 'Tarjetas seleccion #6 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0102', 'Tarjetas seleccion #6 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0103: Tarjetas seleccion #7 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 7);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0103', 'Tarjetas seleccion #7 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0103', 'Tarjetas seleccion #7 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0103', 'Tarjetas seleccion #7 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0104: Tarjetas seleccion #8 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 8);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0104', 'Tarjetas seleccion #8 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0104', 'Tarjetas seleccion #8 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0104', 'Tarjetas seleccion #8 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0105: Tarjetas seleccion #9 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 9);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0105', 'Tarjetas seleccion #9 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0105', 'Tarjetas seleccion #9 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0105', 'Tarjetas seleccion #9 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0106: Tarjetas seleccion #10 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 10);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0106', 'Tarjetas seleccion #10 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0106', 'Tarjetas seleccion #10 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0106', 'Tarjetas seleccion #10 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0107: Tarjetas seleccion #11 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 11);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0107', 'Tarjetas seleccion #11 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0107', 'Tarjetas seleccion #11 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0107', 'Tarjetas seleccion #11 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0108: Tarjetas seleccion #12 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 12);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0108', 'Tarjetas seleccion #12 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0108', 'Tarjetas seleccion #12 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0108', 'Tarjetas seleccion #12 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0109: Tarjetas seleccion #13 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 13);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0109', 'Tarjetas seleccion #13 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0109', 'Tarjetas seleccion #13 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0109', 'Tarjetas seleccion #13 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0110: Tarjetas seleccion #14 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 14);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0110', 'Tarjetas seleccion #14 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0110', 'Tarjetas seleccion #14 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0110', 'Tarjetas seleccion #14 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0111: Tarjetas seleccion #15 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 15);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0111', 'Tarjetas seleccion #15 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0111', 'Tarjetas seleccion #15 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0111', 'Tarjetas seleccion #15 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0112: Tarjetas seleccion #16 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 16);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0112', 'Tarjetas seleccion #16 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0112', 'Tarjetas seleccion #16 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0112', 'Tarjetas seleccion #16 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0113: Tarjetas seleccion #17 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 17);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0113', 'Tarjetas seleccion #17 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0113', 'Tarjetas seleccion #17 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0113', 'Tarjetas seleccion #17 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0114: Tarjetas seleccion #18 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 18);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0114', 'Tarjetas seleccion #18 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0114', 'Tarjetas seleccion #18 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0114', 'Tarjetas seleccion #18 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0115: Tarjetas seleccion #19 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 19);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0115', 'Tarjetas seleccion #19 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0115', 'Tarjetas seleccion #19 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0115', 'Tarjetas seleccion #19 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0116: Tarjetas seleccion #20 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 20);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0116', 'Tarjetas seleccion #20 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0116', 'Tarjetas seleccion #20 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0116', 'Tarjetas seleccion #20 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0117: Tarjetas seleccion #21 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 21);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0117', 'Tarjetas seleccion #21 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0117', 'Tarjetas seleccion #21 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0117', 'Tarjetas seleccion #21 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0118: Tarjetas seleccion #22 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 22);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0118', 'Tarjetas seleccion #22 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0118', 'Tarjetas seleccion #22 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0118', 'Tarjetas seleccion #22 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0119: Tarjetas seleccion #23 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 23);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0119', 'Tarjetas seleccion #23 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0119', 'Tarjetas seleccion #23 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0119', 'Tarjetas seleccion #23 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0120: Tarjetas seleccion #24 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 24);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0120', 'Tarjetas seleccion #24 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0120', 'Tarjetas seleccion #24 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0120', 'Tarjetas seleccion #24 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0121: Tarjetas seleccion #25 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 25);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0121', 'Tarjetas seleccion #25 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0121', 'Tarjetas seleccion #25 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0121', 'Tarjetas seleccion #25 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0122: Tarjetas seleccion #26 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 26);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0122', 'Tarjetas seleccion #26 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0122', 'Tarjetas seleccion #26 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0122', 'Tarjetas seleccion #26 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0123: Tarjetas seleccion #27 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 27);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0123', 'Tarjetas seleccion #27 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0123', 'Tarjetas seleccion #27 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0123', 'Tarjetas seleccion #27 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0124: Tarjetas seleccion #28 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 28);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0124', 'Tarjetas seleccion #28 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0124', 'Tarjetas seleccion #28 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0124', 'Tarjetas seleccion #28 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 111_Lote_Reportes_02.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
