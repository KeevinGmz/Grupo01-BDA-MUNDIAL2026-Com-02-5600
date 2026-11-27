/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de reportes 1 de 10: ejecuta los procedimientos del esquema reporte
          (script 38) con parametros reales tomados de la base y guarda OK, ERROR o SKIP en la tabla
          temporal global ##lote_resultado (SKIP: ese numero de sujeto no existe en la base).
          Requiere los scripts 00 a 47 y 90 a 93. Conviene activar en SSMS: Consulta > Opciones de
          consulta > Resultados > Cuadricula > Descartar resultados despues de la ejecucion.

Casos 0001 a 0062 de este lote:
  - Goleadores seleccion #N formato TABLA (48 casos)
  - Goleadores seleccion #N formato XML (14 casos)
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

-- Caso 0001: Goleadores seleccion #1 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 1);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0001', 'Goleadores seleccion #1 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0001', 'Goleadores seleccion #1 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0001', 'Goleadores seleccion #1 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0002: Goleadores seleccion #2 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 2);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0002', 'Goleadores seleccion #2 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0002', 'Goleadores seleccion #2 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0002', 'Goleadores seleccion #2 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0003: Goleadores seleccion #3 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 3);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0003', 'Goleadores seleccion #3 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0003', 'Goleadores seleccion #3 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0003', 'Goleadores seleccion #3 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0004: Goleadores seleccion #4 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 4);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0004', 'Goleadores seleccion #4 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0004', 'Goleadores seleccion #4 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0004', 'Goleadores seleccion #4 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0005: Goleadores seleccion #5 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 5);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0005', 'Goleadores seleccion #5 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0005', 'Goleadores seleccion #5 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0005', 'Goleadores seleccion #5 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0006: Goleadores seleccion #6 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 6);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0006', 'Goleadores seleccion #6 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0006', 'Goleadores seleccion #6 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0006', 'Goleadores seleccion #6 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0007: Goleadores seleccion #7 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 7);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0007', 'Goleadores seleccion #7 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0007', 'Goleadores seleccion #7 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0007', 'Goleadores seleccion #7 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0008: Goleadores seleccion #8 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 8);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0008', 'Goleadores seleccion #8 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0008', 'Goleadores seleccion #8 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0008', 'Goleadores seleccion #8 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0009: Goleadores seleccion #9 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 9);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0009', 'Goleadores seleccion #9 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0009', 'Goleadores seleccion #9 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0009', 'Goleadores seleccion #9 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0010: Goleadores seleccion #10 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 10);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0010', 'Goleadores seleccion #10 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0010', 'Goleadores seleccion #10 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0010', 'Goleadores seleccion #10 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0011: Goleadores seleccion #11 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 11);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0011', 'Goleadores seleccion #11 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0011', 'Goleadores seleccion #11 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0011', 'Goleadores seleccion #11 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0012: Goleadores seleccion #12 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 12);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0012', 'Goleadores seleccion #12 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0012', 'Goleadores seleccion #12 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0012', 'Goleadores seleccion #12 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0013: Goleadores seleccion #13 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 13);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0013', 'Goleadores seleccion #13 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0013', 'Goleadores seleccion #13 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0013', 'Goleadores seleccion #13 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0014: Goleadores seleccion #14 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 14);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0014', 'Goleadores seleccion #14 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0014', 'Goleadores seleccion #14 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0014', 'Goleadores seleccion #14 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0015: Goleadores seleccion #15 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 15);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0015', 'Goleadores seleccion #15 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0015', 'Goleadores seleccion #15 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0015', 'Goleadores seleccion #15 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0016: Goleadores seleccion #16 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 16);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0016', 'Goleadores seleccion #16 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0016', 'Goleadores seleccion #16 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0016', 'Goleadores seleccion #16 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0017: Goleadores seleccion #17 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 17);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0017', 'Goleadores seleccion #17 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0017', 'Goleadores seleccion #17 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0017', 'Goleadores seleccion #17 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0018: Goleadores seleccion #18 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 18);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0018', 'Goleadores seleccion #18 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0018', 'Goleadores seleccion #18 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0018', 'Goleadores seleccion #18 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0019: Goleadores seleccion #19 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 19);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0019', 'Goleadores seleccion #19 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0019', 'Goleadores seleccion #19 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0019', 'Goleadores seleccion #19 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0020: Goleadores seleccion #20 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 20);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0020', 'Goleadores seleccion #20 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0020', 'Goleadores seleccion #20 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0020', 'Goleadores seleccion #20 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0021: Goleadores seleccion #21 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 21);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0021', 'Goleadores seleccion #21 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0021', 'Goleadores seleccion #21 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0021', 'Goleadores seleccion #21 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0022: Goleadores seleccion #22 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 22);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0022', 'Goleadores seleccion #22 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0022', 'Goleadores seleccion #22 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0022', 'Goleadores seleccion #22 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0023: Goleadores seleccion #23 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 23);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0023', 'Goleadores seleccion #23 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0023', 'Goleadores seleccion #23 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0023', 'Goleadores seleccion #23 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0024: Goleadores seleccion #24 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 24);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0024', 'Goleadores seleccion #24 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0024', 'Goleadores seleccion #24 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0024', 'Goleadores seleccion #24 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0025: Goleadores seleccion #25 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 25);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0025', 'Goleadores seleccion #25 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0025', 'Goleadores seleccion #25 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0025', 'Goleadores seleccion #25 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0026: Goleadores seleccion #26 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 26);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0026', 'Goleadores seleccion #26 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0026', 'Goleadores seleccion #26 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0026', 'Goleadores seleccion #26 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0027: Goleadores seleccion #27 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 27);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0027', 'Goleadores seleccion #27 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0027', 'Goleadores seleccion #27 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0027', 'Goleadores seleccion #27 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0028: Goleadores seleccion #28 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 28);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0028', 'Goleadores seleccion #28 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0028', 'Goleadores seleccion #28 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0028', 'Goleadores seleccion #28 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0029: Goleadores seleccion #29 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 29);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0029', 'Goleadores seleccion #29 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0029', 'Goleadores seleccion #29 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0029', 'Goleadores seleccion #29 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0030: Goleadores seleccion #30 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 30);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0030', 'Goleadores seleccion #30 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0030', 'Goleadores seleccion #30 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0030', 'Goleadores seleccion #30 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0031: Goleadores seleccion #31 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 31);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0031', 'Goleadores seleccion #31 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0031', 'Goleadores seleccion #31 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0031', 'Goleadores seleccion #31 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0032: Goleadores seleccion #32 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 32);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0032', 'Goleadores seleccion #32 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0032', 'Goleadores seleccion #32 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0032', 'Goleadores seleccion #32 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0033: Goleadores seleccion #33 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 33);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0033', 'Goleadores seleccion #33 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0033', 'Goleadores seleccion #33 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0033', 'Goleadores seleccion #33 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0034: Goleadores seleccion #34 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 34);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0034', 'Goleadores seleccion #34 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0034', 'Goleadores seleccion #34 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0034', 'Goleadores seleccion #34 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0035: Goleadores seleccion #35 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 35);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0035', 'Goleadores seleccion #35 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0035', 'Goleadores seleccion #35 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0035', 'Goleadores seleccion #35 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0036: Goleadores seleccion #36 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 36);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0036', 'Goleadores seleccion #36 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0036', 'Goleadores seleccion #36 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0036', 'Goleadores seleccion #36 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0037: Goleadores seleccion #37 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 37);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0037', 'Goleadores seleccion #37 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0037', 'Goleadores seleccion #37 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0037', 'Goleadores seleccion #37 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0038: Goleadores seleccion #38 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 38);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0038', 'Goleadores seleccion #38 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0038', 'Goleadores seleccion #38 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0038', 'Goleadores seleccion #38 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0039: Goleadores seleccion #39 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 39);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0039', 'Goleadores seleccion #39 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0039', 'Goleadores seleccion #39 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0039', 'Goleadores seleccion #39 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0040: Goleadores seleccion #40 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 40);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0040', 'Goleadores seleccion #40 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0040', 'Goleadores seleccion #40 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0040', 'Goleadores seleccion #40 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0041: Goleadores seleccion #41 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 41);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0041', 'Goleadores seleccion #41 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0041', 'Goleadores seleccion #41 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0041', 'Goleadores seleccion #41 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0042: Goleadores seleccion #42 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 42);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0042', 'Goleadores seleccion #42 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0042', 'Goleadores seleccion #42 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0042', 'Goleadores seleccion #42 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0043: Goleadores seleccion #43 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 43);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0043', 'Goleadores seleccion #43 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0043', 'Goleadores seleccion #43 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0043', 'Goleadores seleccion #43 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0044: Goleadores seleccion #44 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 44);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0044', 'Goleadores seleccion #44 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0044', 'Goleadores seleccion #44 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0044', 'Goleadores seleccion #44 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0045: Goleadores seleccion #45 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 45);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0045', 'Goleadores seleccion #45 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0045', 'Goleadores seleccion #45 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0045', 'Goleadores seleccion #45 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0046: Goleadores seleccion #46 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 46);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0046', 'Goleadores seleccion #46 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0046', 'Goleadores seleccion #46 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0046', 'Goleadores seleccion #46 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0047: Goleadores seleccion #47 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 47);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0047', 'Goleadores seleccion #47 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0047', 'Goleadores seleccion #47 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0047', 'Goleadores seleccion #47 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0048: Goleadores seleccion #48 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 48);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0048', 'Goleadores seleccion #48 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0048', 'Goleadores seleccion #48 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0048', 'Goleadores seleccion #48 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0049: Goleadores seleccion #1 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 1);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0049', 'Goleadores seleccion #1 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0049', 'Goleadores seleccion #1 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0049', 'Goleadores seleccion #1 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0050: Goleadores seleccion #2 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 2);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0050', 'Goleadores seleccion #2 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0050', 'Goleadores seleccion #2 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0050', 'Goleadores seleccion #2 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0051: Goleadores seleccion #3 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 3);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0051', 'Goleadores seleccion #3 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0051', 'Goleadores seleccion #3 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0051', 'Goleadores seleccion #3 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0052: Goleadores seleccion #4 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 4);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0052', 'Goleadores seleccion #4 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0052', 'Goleadores seleccion #4 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0052', 'Goleadores seleccion #4 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0053: Goleadores seleccion #5 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 5);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0053', 'Goleadores seleccion #5 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0053', 'Goleadores seleccion #5 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0053', 'Goleadores seleccion #5 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0054: Goleadores seleccion #6 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 6);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0054', 'Goleadores seleccion #6 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0054', 'Goleadores seleccion #6 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0054', 'Goleadores seleccion #6 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0055: Goleadores seleccion #7 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 7);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0055', 'Goleadores seleccion #7 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0055', 'Goleadores seleccion #7 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0055', 'Goleadores seleccion #7 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0056: Goleadores seleccion #8 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 8);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0056', 'Goleadores seleccion #8 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0056', 'Goleadores seleccion #8 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0056', 'Goleadores seleccion #8 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0057: Goleadores seleccion #9 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 9);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0057', 'Goleadores seleccion #9 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0057', 'Goleadores seleccion #9 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0057', 'Goleadores seleccion #9 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0058: Goleadores seleccion #10 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 10);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0058', 'Goleadores seleccion #10 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0058', 'Goleadores seleccion #10 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0058', 'Goleadores seleccion #10 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0059: Goleadores seleccion #11 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 11);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0059', 'Goleadores seleccion #11 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0059', 'Goleadores seleccion #11 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0059', 'Goleadores seleccion #11 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0060: Goleadores seleccion #12 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 12);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0060', 'Goleadores seleccion #12 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0060', 'Goleadores seleccion #12 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0060', 'Goleadores seleccion #12 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0061: Goleadores seleccion #13 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 13);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0061', 'Goleadores seleccion #13 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0061', 'Goleadores seleccion #13 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0061', 'Goleadores seleccion #13 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0062: Goleadores seleccion #14 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 14);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0062', 'Goleadores seleccion #14 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Goleadores @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0062', 'Goleadores seleccion #14 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0062', 'Goleadores seleccion #14 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 110_Lote_Reportes_01.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
