/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de reportes 9 de 10: ejecuta los procedimientos del esquema reporte
          (script 38) con parametros reales tomados de la base y guarda OK, ERROR o SKIP en la tabla
          temporal global ##lote_resultado (SKIP: ese numero de sujeto no existe en la base).
          Requiere los scripts 00 a 47 y 90 a 93. Conviene activar en SSMS: Consulta > Opciones de
          consulta > Resultados > Cuadricula > Descartar resultados despues de la ejecucion.

Casos 0497 a 0558 de este lote:
  - Selecciones y plantillas seleccion #N incluir_bajas=0 (13 casos)
  - Selecciones y plantillas seleccion #N incluir_bajas=1 (48 casos)
  - Resultados fase #N formato TABLA (1 casos)
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

-- Caso 0497: Selecciones y plantillas seleccion #36 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 36);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0497', 'Selecciones y plantillas seleccion #36 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0497', 'Selecciones y plantillas seleccion #36 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0497', 'Selecciones y plantillas seleccion #36 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0498: Selecciones y plantillas seleccion #37 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 37);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0498', 'Selecciones y plantillas seleccion #37 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0498', 'Selecciones y plantillas seleccion #37 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0498', 'Selecciones y plantillas seleccion #37 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0499: Selecciones y plantillas seleccion #38 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 38);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0499', 'Selecciones y plantillas seleccion #38 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0499', 'Selecciones y plantillas seleccion #38 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0499', 'Selecciones y plantillas seleccion #38 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0500: Selecciones y plantillas seleccion #39 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 39);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0500', 'Selecciones y plantillas seleccion #39 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0500', 'Selecciones y plantillas seleccion #39 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0500', 'Selecciones y plantillas seleccion #39 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0501: Selecciones y plantillas seleccion #40 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 40);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0501', 'Selecciones y plantillas seleccion #40 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0501', 'Selecciones y plantillas seleccion #40 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0501', 'Selecciones y plantillas seleccion #40 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0502: Selecciones y plantillas seleccion #41 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 41);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0502', 'Selecciones y plantillas seleccion #41 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0502', 'Selecciones y plantillas seleccion #41 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0502', 'Selecciones y plantillas seleccion #41 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0503: Selecciones y plantillas seleccion #42 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 42);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0503', 'Selecciones y plantillas seleccion #42 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0503', 'Selecciones y plantillas seleccion #42 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0503', 'Selecciones y plantillas seleccion #42 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0504: Selecciones y plantillas seleccion #43 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 43);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0504', 'Selecciones y plantillas seleccion #43 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0504', 'Selecciones y plantillas seleccion #43 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0504', 'Selecciones y plantillas seleccion #43 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0505: Selecciones y plantillas seleccion #44 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 44);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0505', 'Selecciones y plantillas seleccion #44 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0505', 'Selecciones y plantillas seleccion #44 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0505', 'Selecciones y plantillas seleccion #44 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0506: Selecciones y plantillas seleccion #45 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 45);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0506', 'Selecciones y plantillas seleccion #45 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0506', 'Selecciones y plantillas seleccion #45 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0506', 'Selecciones y plantillas seleccion #45 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0507: Selecciones y plantillas seleccion #46 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 46);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0507', 'Selecciones y plantillas seleccion #46 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0507', 'Selecciones y plantillas seleccion #46 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0507', 'Selecciones y plantillas seleccion #46 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0508: Selecciones y plantillas seleccion #47 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 47);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0508', 'Selecciones y plantillas seleccion #47 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0508', 'Selecciones y plantillas seleccion #47 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0508', 'Selecciones y plantillas seleccion #47 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0509: Selecciones y plantillas seleccion #48 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 48);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0509', 'Selecciones y plantillas seleccion #48 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0509', 'Selecciones y plantillas seleccion #48 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0509', 'Selecciones y plantillas seleccion #48 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0510: Selecciones y plantillas seleccion #1 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 1);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0510', 'Selecciones y plantillas seleccion #1 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0510', 'Selecciones y plantillas seleccion #1 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0510', 'Selecciones y plantillas seleccion #1 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0511: Selecciones y plantillas seleccion #2 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 2);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0511', 'Selecciones y plantillas seleccion #2 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0511', 'Selecciones y plantillas seleccion #2 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0511', 'Selecciones y plantillas seleccion #2 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0512: Selecciones y plantillas seleccion #3 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 3);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0512', 'Selecciones y plantillas seleccion #3 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0512', 'Selecciones y plantillas seleccion #3 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0512', 'Selecciones y plantillas seleccion #3 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0513: Selecciones y plantillas seleccion #4 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 4);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0513', 'Selecciones y plantillas seleccion #4 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0513', 'Selecciones y plantillas seleccion #4 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0513', 'Selecciones y plantillas seleccion #4 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0514: Selecciones y plantillas seleccion #5 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 5);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0514', 'Selecciones y plantillas seleccion #5 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0514', 'Selecciones y plantillas seleccion #5 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0514', 'Selecciones y plantillas seleccion #5 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0515: Selecciones y plantillas seleccion #6 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 6);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0515', 'Selecciones y plantillas seleccion #6 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0515', 'Selecciones y plantillas seleccion #6 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0515', 'Selecciones y plantillas seleccion #6 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0516: Selecciones y plantillas seleccion #7 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 7);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0516', 'Selecciones y plantillas seleccion #7 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0516', 'Selecciones y plantillas seleccion #7 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0516', 'Selecciones y plantillas seleccion #7 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0517: Selecciones y plantillas seleccion #8 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 8);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0517', 'Selecciones y plantillas seleccion #8 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0517', 'Selecciones y plantillas seleccion #8 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0517', 'Selecciones y plantillas seleccion #8 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0518: Selecciones y plantillas seleccion #9 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 9);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0518', 'Selecciones y plantillas seleccion #9 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0518', 'Selecciones y plantillas seleccion #9 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0518', 'Selecciones y plantillas seleccion #9 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0519: Selecciones y plantillas seleccion #10 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 10);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0519', 'Selecciones y plantillas seleccion #10 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0519', 'Selecciones y plantillas seleccion #10 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0519', 'Selecciones y plantillas seleccion #10 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0520: Selecciones y plantillas seleccion #11 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 11);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0520', 'Selecciones y plantillas seleccion #11 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0520', 'Selecciones y plantillas seleccion #11 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0520', 'Selecciones y plantillas seleccion #11 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0521: Selecciones y plantillas seleccion #12 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 12);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0521', 'Selecciones y plantillas seleccion #12 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0521', 'Selecciones y plantillas seleccion #12 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0521', 'Selecciones y plantillas seleccion #12 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0522: Selecciones y plantillas seleccion #13 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 13);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0522', 'Selecciones y plantillas seleccion #13 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0522', 'Selecciones y plantillas seleccion #13 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0522', 'Selecciones y plantillas seleccion #13 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0523: Selecciones y plantillas seleccion #14 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 14);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0523', 'Selecciones y plantillas seleccion #14 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0523', 'Selecciones y plantillas seleccion #14 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0523', 'Selecciones y plantillas seleccion #14 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0524: Selecciones y plantillas seleccion #15 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 15);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0524', 'Selecciones y plantillas seleccion #15 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0524', 'Selecciones y plantillas seleccion #15 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0524', 'Selecciones y plantillas seleccion #15 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0525: Selecciones y plantillas seleccion #16 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 16);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0525', 'Selecciones y plantillas seleccion #16 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0525', 'Selecciones y plantillas seleccion #16 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0525', 'Selecciones y plantillas seleccion #16 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0526: Selecciones y plantillas seleccion #17 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 17);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0526', 'Selecciones y plantillas seleccion #17 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0526', 'Selecciones y plantillas seleccion #17 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0526', 'Selecciones y plantillas seleccion #17 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0527: Selecciones y plantillas seleccion #18 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 18);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0527', 'Selecciones y plantillas seleccion #18 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0527', 'Selecciones y plantillas seleccion #18 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0527', 'Selecciones y plantillas seleccion #18 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0528: Selecciones y plantillas seleccion #19 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 19);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0528', 'Selecciones y plantillas seleccion #19 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0528', 'Selecciones y plantillas seleccion #19 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0528', 'Selecciones y plantillas seleccion #19 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0529: Selecciones y plantillas seleccion #20 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 20);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0529', 'Selecciones y plantillas seleccion #20 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0529', 'Selecciones y plantillas seleccion #20 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0529', 'Selecciones y plantillas seleccion #20 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0530: Selecciones y plantillas seleccion #21 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 21);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0530', 'Selecciones y plantillas seleccion #21 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0530', 'Selecciones y plantillas seleccion #21 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0530', 'Selecciones y plantillas seleccion #21 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0531: Selecciones y plantillas seleccion #22 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 22);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0531', 'Selecciones y plantillas seleccion #22 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0531', 'Selecciones y plantillas seleccion #22 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0531', 'Selecciones y plantillas seleccion #22 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0532: Selecciones y plantillas seleccion #23 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 23);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0532', 'Selecciones y plantillas seleccion #23 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0532', 'Selecciones y plantillas seleccion #23 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0532', 'Selecciones y plantillas seleccion #23 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0533: Selecciones y plantillas seleccion #24 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 24);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0533', 'Selecciones y plantillas seleccion #24 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0533', 'Selecciones y plantillas seleccion #24 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0533', 'Selecciones y plantillas seleccion #24 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0534: Selecciones y plantillas seleccion #25 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 25);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0534', 'Selecciones y plantillas seleccion #25 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0534', 'Selecciones y plantillas seleccion #25 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0534', 'Selecciones y plantillas seleccion #25 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0535: Selecciones y plantillas seleccion #26 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 26);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0535', 'Selecciones y plantillas seleccion #26 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0535', 'Selecciones y plantillas seleccion #26 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0535', 'Selecciones y plantillas seleccion #26 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0536: Selecciones y plantillas seleccion #27 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 27);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0536', 'Selecciones y plantillas seleccion #27 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0536', 'Selecciones y plantillas seleccion #27 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0536', 'Selecciones y plantillas seleccion #27 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0537: Selecciones y plantillas seleccion #28 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 28);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0537', 'Selecciones y plantillas seleccion #28 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0537', 'Selecciones y plantillas seleccion #28 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0537', 'Selecciones y plantillas seleccion #28 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0538: Selecciones y plantillas seleccion #29 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 29);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0538', 'Selecciones y plantillas seleccion #29 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0538', 'Selecciones y plantillas seleccion #29 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0538', 'Selecciones y plantillas seleccion #29 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0539: Selecciones y plantillas seleccion #30 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 30);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0539', 'Selecciones y plantillas seleccion #30 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0539', 'Selecciones y plantillas seleccion #30 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0539', 'Selecciones y plantillas seleccion #30 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0540: Selecciones y plantillas seleccion #31 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 31);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0540', 'Selecciones y plantillas seleccion #31 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0540', 'Selecciones y plantillas seleccion #31 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0540', 'Selecciones y plantillas seleccion #31 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0541: Selecciones y plantillas seleccion #32 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 32);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0541', 'Selecciones y plantillas seleccion #32 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0541', 'Selecciones y plantillas seleccion #32 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0541', 'Selecciones y plantillas seleccion #32 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0542: Selecciones y plantillas seleccion #33 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 33);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0542', 'Selecciones y plantillas seleccion #33 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0542', 'Selecciones y plantillas seleccion #33 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0542', 'Selecciones y plantillas seleccion #33 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0543: Selecciones y plantillas seleccion #34 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 34);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0543', 'Selecciones y plantillas seleccion #34 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0543', 'Selecciones y plantillas seleccion #34 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0543', 'Selecciones y plantillas seleccion #34 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0544: Selecciones y plantillas seleccion #35 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 35);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0544', 'Selecciones y plantillas seleccion #35 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0544', 'Selecciones y plantillas seleccion #35 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0544', 'Selecciones y plantillas seleccion #35 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0545: Selecciones y plantillas seleccion #36 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 36);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0545', 'Selecciones y plantillas seleccion #36 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0545', 'Selecciones y plantillas seleccion #36 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0545', 'Selecciones y plantillas seleccion #36 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0546: Selecciones y plantillas seleccion #37 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 37);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0546', 'Selecciones y plantillas seleccion #37 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0546', 'Selecciones y plantillas seleccion #37 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0546', 'Selecciones y plantillas seleccion #37 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0547: Selecciones y plantillas seleccion #38 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 38);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0547', 'Selecciones y plantillas seleccion #38 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0547', 'Selecciones y plantillas seleccion #38 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0547', 'Selecciones y plantillas seleccion #38 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0548: Selecciones y plantillas seleccion #39 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 39);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0548', 'Selecciones y plantillas seleccion #39 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0548', 'Selecciones y plantillas seleccion #39 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0548', 'Selecciones y plantillas seleccion #39 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0549: Selecciones y plantillas seleccion #40 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 40);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0549', 'Selecciones y plantillas seleccion #40 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0549', 'Selecciones y plantillas seleccion #40 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0549', 'Selecciones y plantillas seleccion #40 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0550: Selecciones y plantillas seleccion #41 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 41);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0550', 'Selecciones y plantillas seleccion #41 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0550', 'Selecciones y plantillas seleccion #41 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0550', 'Selecciones y plantillas seleccion #41 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0551: Selecciones y plantillas seleccion #42 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 42);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0551', 'Selecciones y plantillas seleccion #42 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0551', 'Selecciones y plantillas seleccion #42 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0551', 'Selecciones y plantillas seleccion #42 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0552: Selecciones y plantillas seleccion #43 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 43);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0552', 'Selecciones y plantillas seleccion #43 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0552', 'Selecciones y plantillas seleccion #43 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0552', 'Selecciones y plantillas seleccion #43 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0553: Selecciones y plantillas seleccion #44 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 44);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0553', 'Selecciones y plantillas seleccion #44 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0553', 'Selecciones y plantillas seleccion #44 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0553', 'Selecciones y plantillas seleccion #44 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0554: Selecciones y plantillas seleccion #45 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 45);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0554', 'Selecciones y plantillas seleccion #45 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0554', 'Selecciones y plantillas seleccion #45 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0554', 'Selecciones y plantillas seleccion #45 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0555: Selecciones y plantillas seleccion #46 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 46);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0555', 'Selecciones y plantillas seleccion #46 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0555', 'Selecciones y plantillas seleccion #46 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0555', 'Selecciones y plantillas seleccion #46 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0556: Selecciones y plantillas seleccion #47 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 47);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0556', 'Selecciones y plantillas seleccion #47 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0556', 'Selecciones y plantillas seleccion #47 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0556', 'Selecciones y plantillas seleccion #47 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0557: Selecciones y plantillas seleccion #48 incluir_bajas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 48);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0557', 'Selecciones y plantillas seleccion #48 incluir_bajas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0557', 'Selecciones y plantillas seleccion #48 incluir_bajas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0557', 'Selecciones y plantillas seleccion #48 incluir_bajas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0558: Resultados fase #1 formato TABLA
BEGIN TRY
    DECLARE @id INT = (SELECT t.nro_fase FROM (SELECT nro_fase, ROW_NUMBER() OVER (ORDER BY nro_fase) AS rn FROM torneo.fase) AS t WHERE t.rn = 1);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0558', 'Resultados fase #1 formato TABLA', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Resultados @nro_fase = @id, @formato = 'TABLA';
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0558', 'Resultados fase #1 formato TABLA', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0558', 'Resultados fase #1 formato TABLA', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 118_Lote_Reportes_09.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
