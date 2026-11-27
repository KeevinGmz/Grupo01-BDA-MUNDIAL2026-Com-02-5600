/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de reportes 10 de 10: ejecuta los procedimientos del esquema reporte
          (script 38) con parametros reales tomados de la base y guarda OK, ERROR o SKIP en la tabla
          temporal global ##lote_resultado (SKIP: ese numero de sujeto no existe en la base).
          Requiere los scripts 00 a 47 y 90 a 93. Conviene activar en SSMS: Consulta > Opciones de
          consulta > Resultados > Cuadricula > Descartar resultados despues de la ejecucion.

Casos 0559 a 0619 de este lote:
  - Resultados fase #N formato TABLA (6 casos)
  - Resultados fase #N formato XML (7 casos)
  - Resultados seleccion #N formato XML (48 casos)
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

-- Caso 0559: Resultados fase #2 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.nro_fase FROM (SELECT nro_fase, ROW_NUMBER() OVER (ORDER BY nro_fase) AS rn FROM torneo.fase) AS t WHERE t.rn = 2);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0559', 'Resultados fase #2 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @nro_fase = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0559', 'Resultados fase #2 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0559', 'Resultados fase #2 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0560: Resultados fase #3 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.nro_fase FROM (SELECT nro_fase, ROW_NUMBER() OVER (ORDER BY nro_fase) AS rn FROM torneo.fase) AS t WHERE t.rn = 3);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0560', 'Resultados fase #3 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @nro_fase = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0560', 'Resultados fase #3 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0560', 'Resultados fase #3 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0561: Resultados fase #4 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.nro_fase FROM (SELECT nro_fase, ROW_NUMBER() OVER (ORDER BY nro_fase) AS rn FROM torneo.fase) AS t WHERE t.rn = 4);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0561', 'Resultados fase #4 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @nro_fase = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0561', 'Resultados fase #4 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0561', 'Resultados fase #4 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0562: Resultados fase #5 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.nro_fase FROM (SELECT nro_fase, ROW_NUMBER() OVER (ORDER BY nro_fase) AS rn FROM torneo.fase) AS t WHERE t.rn = 5);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0562', 'Resultados fase #5 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @nro_fase = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0562', 'Resultados fase #5 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0562', 'Resultados fase #5 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0563: Resultados fase #6 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.nro_fase FROM (SELECT nro_fase, ROW_NUMBER() OVER (ORDER BY nro_fase) AS rn FROM torneo.fase) AS t WHERE t.rn = 6);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0563', 'Resultados fase #6 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @nro_fase = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0563', 'Resultados fase #6 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0563', 'Resultados fase #6 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0564: Resultados fase #7 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.nro_fase FROM (SELECT nro_fase, ROW_NUMBER() OVER (ORDER BY nro_fase) AS rn FROM torneo.fase) AS t WHERE t.rn = 7);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0564', 'Resultados fase #7 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @nro_fase = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0564', 'Resultados fase #7 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0564', 'Resultados fase #7 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0565: Resultados fase #1 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.nro_fase FROM (SELECT nro_fase, ROW_NUMBER() OVER (ORDER BY nro_fase) AS rn FROM torneo.fase) AS t WHERE t.rn = 1);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0565', 'Resultados fase #1 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @nro_fase = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0565', 'Resultados fase #1 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0565', 'Resultados fase #1 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0566: Resultados fase #2 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.nro_fase FROM (SELECT nro_fase, ROW_NUMBER() OVER (ORDER BY nro_fase) AS rn FROM torneo.fase) AS t WHERE t.rn = 2);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0566', 'Resultados fase #2 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @nro_fase = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0566', 'Resultados fase #2 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0566', 'Resultados fase #2 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0567: Resultados fase #3 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.nro_fase FROM (SELECT nro_fase, ROW_NUMBER() OVER (ORDER BY nro_fase) AS rn FROM torneo.fase) AS t WHERE t.rn = 3);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0567', 'Resultados fase #3 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @nro_fase = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0567', 'Resultados fase #3 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0567', 'Resultados fase #3 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0568: Resultados fase #4 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.nro_fase FROM (SELECT nro_fase, ROW_NUMBER() OVER (ORDER BY nro_fase) AS rn FROM torneo.fase) AS t WHERE t.rn = 4);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0568', 'Resultados fase #4 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @nro_fase = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0568', 'Resultados fase #4 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0568', 'Resultados fase #4 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0569: Resultados fase #5 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.nro_fase FROM (SELECT nro_fase, ROW_NUMBER() OVER (ORDER BY nro_fase) AS rn FROM torneo.fase) AS t WHERE t.rn = 5);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0569', 'Resultados fase #5 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @nro_fase = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0569', 'Resultados fase #5 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0569', 'Resultados fase #5 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0570: Resultados fase #6 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.nro_fase FROM (SELECT nro_fase, ROW_NUMBER() OVER (ORDER BY nro_fase) AS rn FROM torneo.fase) AS t WHERE t.rn = 6);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0570', 'Resultados fase #6 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @nro_fase = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0570', 'Resultados fase #6 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0570', 'Resultados fase #6 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0571: Resultados fase #7 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.nro_fase FROM (SELECT nro_fase, ROW_NUMBER() OVER (ORDER BY nro_fase) AS rn FROM torneo.fase) AS t WHERE t.rn = 7);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0571', 'Resultados fase #7 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @nro_fase = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0571', 'Resultados fase #7 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0571', 'Resultados fase #7 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0572: Resultados seleccion #1 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 1);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0572', 'Resultados seleccion #1 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0572', 'Resultados seleccion #1 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0572', 'Resultados seleccion #1 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0573: Resultados seleccion #2 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 2);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0573', 'Resultados seleccion #2 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0573', 'Resultados seleccion #2 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0573', 'Resultados seleccion #2 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0574: Resultados seleccion #3 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 3);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0574', 'Resultados seleccion #3 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0574', 'Resultados seleccion #3 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0574', 'Resultados seleccion #3 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0575: Resultados seleccion #4 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 4);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0575', 'Resultados seleccion #4 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0575', 'Resultados seleccion #4 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0575', 'Resultados seleccion #4 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0576: Resultados seleccion #5 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 5);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0576', 'Resultados seleccion #5 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0576', 'Resultados seleccion #5 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0576', 'Resultados seleccion #5 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0577: Resultados seleccion #6 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 6);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0577', 'Resultados seleccion #6 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0577', 'Resultados seleccion #6 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0577', 'Resultados seleccion #6 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0578: Resultados seleccion #7 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 7);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0578', 'Resultados seleccion #7 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0578', 'Resultados seleccion #7 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0578', 'Resultados seleccion #7 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0579: Resultados seleccion #8 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 8);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0579', 'Resultados seleccion #8 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0579', 'Resultados seleccion #8 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0579', 'Resultados seleccion #8 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0580: Resultados seleccion #9 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 9);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0580', 'Resultados seleccion #9 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0580', 'Resultados seleccion #9 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0580', 'Resultados seleccion #9 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0581: Resultados seleccion #10 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 10);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0581', 'Resultados seleccion #10 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0581', 'Resultados seleccion #10 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0581', 'Resultados seleccion #10 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0582: Resultados seleccion #11 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 11);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0582', 'Resultados seleccion #11 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0582', 'Resultados seleccion #11 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0582', 'Resultados seleccion #11 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0583: Resultados seleccion #12 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 12);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0583', 'Resultados seleccion #12 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0583', 'Resultados seleccion #12 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0583', 'Resultados seleccion #12 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0584: Resultados seleccion #13 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 13);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0584', 'Resultados seleccion #13 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0584', 'Resultados seleccion #13 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0584', 'Resultados seleccion #13 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0585: Resultados seleccion #14 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 14);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0585', 'Resultados seleccion #14 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0585', 'Resultados seleccion #14 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0585', 'Resultados seleccion #14 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0586: Resultados seleccion #15 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 15);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0586', 'Resultados seleccion #15 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0586', 'Resultados seleccion #15 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0586', 'Resultados seleccion #15 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0587: Resultados seleccion #16 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 16);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0587', 'Resultados seleccion #16 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0587', 'Resultados seleccion #16 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0587', 'Resultados seleccion #16 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0588: Resultados seleccion #17 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 17);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0588', 'Resultados seleccion #17 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0588', 'Resultados seleccion #17 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0588', 'Resultados seleccion #17 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0589: Resultados seleccion #18 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 18);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0589', 'Resultados seleccion #18 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0589', 'Resultados seleccion #18 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0589', 'Resultados seleccion #18 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0590: Resultados seleccion #19 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 19);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0590', 'Resultados seleccion #19 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0590', 'Resultados seleccion #19 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0590', 'Resultados seleccion #19 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0591: Resultados seleccion #20 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 20);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0591', 'Resultados seleccion #20 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0591', 'Resultados seleccion #20 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0591', 'Resultados seleccion #20 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0592: Resultados seleccion #21 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 21);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0592', 'Resultados seleccion #21 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0592', 'Resultados seleccion #21 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0592', 'Resultados seleccion #21 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0593: Resultados seleccion #22 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 22);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0593', 'Resultados seleccion #22 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0593', 'Resultados seleccion #22 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0593', 'Resultados seleccion #22 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0594: Resultados seleccion #23 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 23);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0594', 'Resultados seleccion #23 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0594', 'Resultados seleccion #23 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0594', 'Resultados seleccion #23 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0595: Resultados seleccion #24 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 24);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0595', 'Resultados seleccion #24 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0595', 'Resultados seleccion #24 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0595', 'Resultados seleccion #24 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0596: Resultados seleccion #25 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 25);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0596', 'Resultados seleccion #25 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0596', 'Resultados seleccion #25 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0596', 'Resultados seleccion #25 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0597: Resultados seleccion #26 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 26);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0597', 'Resultados seleccion #26 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0597', 'Resultados seleccion #26 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0597', 'Resultados seleccion #26 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0598: Resultados seleccion #27 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 27);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0598', 'Resultados seleccion #27 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0598', 'Resultados seleccion #27 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0598', 'Resultados seleccion #27 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0599: Resultados seleccion #28 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 28);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0599', 'Resultados seleccion #28 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0599', 'Resultados seleccion #28 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0599', 'Resultados seleccion #28 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0600: Resultados seleccion #29 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 29);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0600', 'Resultados seleccion #29 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0600', 'Resultados seleccion #29 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0600', 'Resultados seleccion #29 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0601: Resultados seleccion #30 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 30);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0601', 'Resultados seleccion #30 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0601', 'Resultados seleccion #30 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0601', 'Resultados seleccion #30 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0602: Resultados seleccion #31 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 31);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0602', 'Resultados seleccion #31 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0602', 'Resultados seleccion #31 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0602', 'Resultados seleccion #31 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0603: Resultados seleccion #32 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 32);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0603', 'Resultados seleccion #32 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0603', 'Resultados seleccion #32 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0603', 'Resultados seleccion #32 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0604: Resultados seleccion #33 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 33);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0604', 'Resultados seleccion #33 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0604', 'Resultados seleccion #33 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0604', 'Resultados seleccion #33 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0605: Resultados seleccion #34 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 34);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0605', 'Resultados seleccion #34 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0605', 'Resultados seleccion #34 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0605', 'Resultados seleccion #34 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0606: Resultados seleccion #35 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 35);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0606', 'Resultados seleccion #35 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0606', 'Resultados seleccion #35 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0606', 'Resultados seleccion #35 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0607: Resultados seleccion #36 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 36);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0607', 'Resultados seleccion #36 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0607', 'Resultados seleccion #36 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0607', 'Resultados seleccion #36 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0608: Resultados seleccion #37 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 37);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0608', 'Resultados seleccion #37 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0608', 'Resultados seleccion #37 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0608', 'Resultados seleccion #37 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0609: Resultados seleccion #38 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 38);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0609', 'Resultados seleccion #38 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0609', 'Resultados seleccion #38 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0609', 'Resultados seleccion #38 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0610: Resultados seleccion #39 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 39);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0610', 'Resultados seleccion #39 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0610', 'Resultados seleccion #39 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0610', 'Resultados seleccion #39 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0611: Resultados seleccion #40 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 40);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0611', 'Resultados seleccion #40 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0611', 'Resultados seleccion #40 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0611', 'Resultados seleccion #40 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0612: Resultados seleccion #41 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 41);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0612', 'Resultados seleccion #41 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0612', 'Resultados seleccion #41 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0612', 'Resultados seleccion #41 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0613: Resultados seleccion #42 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 42);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0613', 'Resultados seleccion #42 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0613', 'Resultados seleccion #42 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0613', 'Resultados seleccion #42 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0614: Resultados seleccion #43 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 43);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0614', 'Resultados seleccion #43 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0614', 'Resultados seleccion #43 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0614', 'Resultados seleccion #43 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0615: Resultados seleccion #44 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 44);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0615', 'Resultados seleccion #44 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0615', 'Resultados seleccion #44 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0615', 'Resultados seleccion #44 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0616: Resultados seleccion #45 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 45);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0616', 'Resultados seleccion #45 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0616', 'Resultados seleccion #45 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0616', 'Resultados seleccion #45 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0617: Resultados seleccion #46 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 46);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0617', 'Resultados seleccion #46 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0617', 'Resultados seleccion #46 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0617', 'Resultados seleccion #46 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0618: Resultados seleccion #47 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 47);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0618', 'Resultados seleccion #47 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0618', 'Resultados seleccion #47 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0618', 'Resultados seleccion #47 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0619: Resultados seleccion #48 formato XML
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 48);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0619', 'Resultados seleccion #48 formato XML', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @id_seleccion = @id, @formato = 'XML';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0619', 'Resultados seleccion #48 formato XML', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0619', 'Resultados seleccion #48 formato XML', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 119_Lote_Reportes_10.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
-- Al terminar todos los lotes: DROP TABLE ##lote_resultado;
