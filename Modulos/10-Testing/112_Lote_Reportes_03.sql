/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de reportes 3 de 10: ejecuta los procedimientos del esquema reporte
          (script 38) con parametros reales tomados de la base y guarda OK, ERROR o SKIP en la tabla
          temporal global ##lote_resultado (SKIP: ese numero de sujeto no existe en la base).
          Requiere los scripts 00 a 47 y 90 a 93. Conviene activar en SSMS: Consulta > Opciones de
          consulta > Resultados > Cuadricula > Descartar resultados despues de la ejecucion.

Casos 0125 a 0186 de este lote:
  - Tarjetas seleccion #N solo_activas=1 (20 casos)
  - Tarjetas seleccion #N solo_activas=0 (42 casos)
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

-- Caso 0125: Tarjetas seleccion #29 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 29);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0125', 'Tarjetas seleccion #29 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0125', 'Tarjetas seleccion #29 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0125', 'Tarjetas seleccion #29 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0126: Tarjetas seleccion #30 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 30);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0126', 'Tarjetas seleccion #30 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0126', 'Tarjetas seleccion #30 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0126', 'Tarjetas seleccion #30 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0127: Tarjetas seleccion #31 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 31);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0127', 'Tarjetas seleccion #31 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0127', 'Tarjetas seleccion #31 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0127', 'Tarjetas seleccion #31 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0128: Tarjetas seleccion #32 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 32);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0128', 'Tarjetas seleccion #32 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0128', 'Tarjetas seleccion #32 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0128', 'Tarjetas seleccion #32 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0129: Tarjetas seleccion #33 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 33);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0129', 'Tarjetas seleccion #33 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0129', 'Tarjetas seleccion #33 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0129', 'Tarjetas seleccion #33 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0130: Tarjetas seleccion #34 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 34);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0130', 'Tarjetas seleccion #34 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0130', 'Tarjetas seleccion #34 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0130', 'Tarjetas seleccion #34 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0131: Tarjetas seleccion #35 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 35);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0131', 'Tarjetas seleccion #35 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0131', 'Tarjetas seleccion #35 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0131', 'Tarjetas seleccion #35 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0132: Tarjetas seleccion #36 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 36);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0132', 'Tarjetas seleccion #36 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0132', 'Tarjetas seleccion #36 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0132', 'Tarjetas seleccion #36 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0133: Tarjetas seleccion #37 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 37);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0133', 'Tarjetas seleccion #37 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0133', 'Tarjetas seleccion #37 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0133', 'Tarjetas seleccion #37 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0134: Tarjetas seleccion #38 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 38);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0134', 'Tarjetas seleccion #38 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0134', 'Tarjetas seleccion #38 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0134', 'Tarjetas seleccion #38 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0135: Tarjetas seleccion #39 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 39);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0135', 'Tarjetas seleccion #39 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0135', 'Tarjetas seleccion #39 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0135', 'Tarjetas seleccion #39 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0136: Tarjetas seleccion #40 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 40);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0136', 'Tarjetas seleccion #40 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0136', 'Tarjetas seleccion #40 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0136', 'Tarjetas seleccion #40 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0137: Tarjetas seleccion #41 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 41);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0137', 'Tarjetas seleccion #41 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0137', 'Tarjetas seleccion #41 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0137', 'Tarjetas seleccion #41 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0138: Tarjetas seleccion #42 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 42);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0138', 'Tarjetas seleccion #42 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0138', 'Tarjetas seleccion #42 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0138', 'Tarjetas seleccion #42 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0139: Tarjetas seleccion #43 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 43);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0139', 'Tarjetas seleccion #43 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0139', 'Tarjetas seleccion #43 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0139', 'Tarjetas seleccion #43 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0140: Tarjetas seleccion #44 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 44);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0140', 'Tarjetas seleccion #44 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0140', 'Tarjetas seleccion #44 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0140', 'Tarjetas seleccion #44 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0141: Tarjetas seleccion #45 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 45);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0141', 'Tarjetas seleccion #45 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0141', 'Tarjetas seleccion #45 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0141', 'Tarjetas seleccion #45 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0142: Tarjetas seleccion #46 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 46);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0142', 'Tarjetas seleccion #46 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0142', 'Tarjetas seleccion #46 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0142', 'Tarjetas seleccion #46 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0143: Tarjetas seleccion #47 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 47);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0143', 'Tarjetas seleccion #47 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0143', 'Tarjetas seleccion #47 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0143', 'Tarjetas seleccion #47 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0144: Tarjetas seleccion #48 solo_activas=1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 48);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0144', 'Tarjetas seleccion #48 solo_activas=1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 1;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0144', 'Tarjetas seleccion #48 solo_activas=1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0144', 'Tarjetas seleccion #48 solo_activas=1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0145: Tarjetas seleccion #1 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 1);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0145', 'Tarjetas seleccion #1 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0145', 'Tarjetas seleccion #1 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0145', 'Tarjetas seleccion #1 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0146: Tarjetas seleccion #2 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 2);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0146', 'Tarjetas seleccion #2 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0146', 'Tarjetas seleccion #2 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0146', 'Tarjetas seleccion #2 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0147: Tarjetas seleccion #3 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 3);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0147', 'Tarjetas seleccion #3 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0147', 'Tarjetas seleccion #3 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0147', 'Tarjetas seleccion #3 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0148: Tarjetas seleccion #4 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 4);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0148', 'Tarjetas seleccion #4 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0148', 'Tarjetas seleccion #4 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0148', 'Tarjetas seleccion #4 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0149: Tarjetas seleccion #5 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 5);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0149', 'Tarjetas seleccion #5 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0149', 'Tarjetas seleccion #5 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0149', 'Tarjetas seleccion #5 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0150: Tarjetas seleccion #6 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 6);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0150', 'Tarjetas seleccion #6 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0150', 'Tarjetas seleccion #6 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0150', 'Tarjetas seleccion #6 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0151: Tarjetas seleccion #7 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 7);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0151', 'Tarjetas seleccion #7 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0151', 'Tarjetas seleccion #7 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0151', 'Tarjetas seleccion #7 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0152: Tarjetas seleccion #8 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 8);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0152', 'Tarjetas seleccion #8 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0152', 'Tarjetas seleccion #8 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0152', 'Tarjetas seleccion #8 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0153: Tarjetas seleccion #9 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 9);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0153', 'Tarjetas seleccion #9 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0153', 'Tarjetas seleccion #9 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0153', 'Tarjetas seleccion #9 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0154: Tarjetas seleccion #10 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 10);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0154', 'Tarjetas seleccion #10 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0154', 'Tarjetas seleccion #10 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0154', 'Tarjetas seleccion #10 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0155: Tarjetas seleccion #11 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 11);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0155', 'Tarjetas seleccion #11 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0155', 'Tarjetas seleccion #11 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0155', 'Tarjetas seleccion #11 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0156: Tarjetas seleccion #12 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 12);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0156', 'Tarjetas seleccion #12 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0156', 'Tarjetas seleccion #12 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0156', 'Tarjetas seleccion #12 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0157: Tarjetas seleccion #13 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 13);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0157', 'Tarjetas seleccion #13 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0157', 'Tarjetas seleccion #13 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0157', 'Tarjetas seleccion #13 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0158: Tarjetas seleccion #14 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 14);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0158', 'Tarjetas seleccion #14 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0158', 'Tarjetas seleccion #14 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0158', 'Tarjetas seleccion #14 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0159: Tarjetas seleccion #15 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 15);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0159', 'Tarjetas seleccion #15 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0159', 'Tarjetas seleccion #15 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0159', 'Tarjetas seleccion #15 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0160: Tarjetas seleccion #16 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 16);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0160', 'Tarjetas seleccion #16 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0160', 'Tarjetas seleccion #16 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0160', 'Tarjetas seleccion #16 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0161: Tarjetas seleccion #17 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 17);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0161', 'Tarjetas seleccion #17 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0161', 'Tarjetas seleccion #17 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0161', 'Tarjetas seleccion #17 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0162: Tarjetas seleccion #18 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 18);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0162', 'Tarjetas seleccion #18 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0162', 'Tarjetas seleccion #18 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0162', 'Tarjetas seleccion #18 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0163: Tarjetas seleccion #19 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 19);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0163', 'Tarjetas seleccion #19 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0163', 'Tarjetas seleccion #19 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0163', 'Tarjetas seleccion #19 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0164: Tarjetas seleccion #20 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 20);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0164', 'Tarjetas seleccion #20 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0164', 'Tarjetas seleccion #20 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0164', 'Tarjetas seleccion #20 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0165: Tarjetas seleccion #21 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 21);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0165', 'Tarjetas seleccion #21 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0165', 'Tarjetas seleccion #21 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0165', 'Tarjetas seleccion #21 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0166: Tarjetas seleccion #22 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 22);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0166', 'Tarjetas seleccion #22 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0166', 'Tarjetas seleccion #22 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0166', 'Tarjetas seleccion #22 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0167: Tarjetas seleccion #23 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 23);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0167', 'Tarjetas seleccion #23 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0167', 'Tarjetas seleccion #23 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0167', 'Tarjetas seleccion #23 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0168: Tarjetas seleccion #24 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 24);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0168', 'Tarjetas seleccion #24 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0168', 'Tarjetas seleccion #24 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0168', 'Tarjetas seleccion #24 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0169: Tarjetas seleccion #25 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 25);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0169', 'Tarjetas seleccion #25 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0169', 'Tarjetas seleccion #25 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0169', 'Tarjetas seleccion #25 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0170: Tarjetas seleccion #26 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 26);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0170', 'Tarjetas seleccion #26 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0170', 'Tarjetas seleccion #26 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0170', 'Tarjetas seleccion #26 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0171: Tarjetas seleccion #27 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 27);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0171', 'Tarjetas seleccion #27 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0171', 'Tarjetas seleccion #27 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0171', 'Tarjetas seleccion #27 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0172: Tarjetas seleccion #28 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 28);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0172', 'Tarjetas seleccion #28 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0172', 'Tarjetas seleccion #28 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0172', 'Tarjetas seleccion #28 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0173: Tarjetas seleccion #29 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 29);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0173', 'Tarjetas seleccion #29 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0173', 'Tarjetas seleccion #29 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0173', 'Tarjetas seleccion #29 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0174: Tarjetas seleccion #30 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 30);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0174', 'Tarjetas seleccion #30 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0174', 'Tarjetas seleccion #30 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0174', 'Tarjetas seleccion #30 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0175: Tarjetas seleccion #31 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 31);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0175', 'Tarjetas seleccion #31 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0175', 'Tarjetas seleccion #31 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0175', 'Tarjetas seleccion #31 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0176: Tarjetas seleccion #32 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 32);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0176', 'Tarjetas seleccion #32 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0176', 'Tarjetas seleccion #32 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0176', 'Tarjetas seleccion #32 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0177: Tarjetas seleccion #33 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 33);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0177', 'Tarjetas seleccion #33 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0177', 'Tarjetas seleccion #33 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0177', 'Tarjetas seleccion #33 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0178: Tarjetas seleccion #34 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 34);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0178', 'Tarjetas seleccion #34 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0178', 'Tarjetas seleccion #34 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0178', 'Tarjetas seleccion #34 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0179: Tarjetas seleccion #35 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 35);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0179', 'Tarjetas seleccion #35 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0179', 'Tarjetas seleccion #35 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0179', 'Tarjetas seleccion #35 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0180: Tarjetas seleccion #36 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 36);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0180', 'Tarjetas seleccion #36 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0180', 'Tarjetas seleccion #36 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0180', 'Tarjetas seleccion #36 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0181: Tarjetas seleccion #37 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 37);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0181', 'Tarjetas seleccion #37 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0181', 'Tarjetas seleccion #37 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0181', 'Tarjetas seleccion #37 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0182: Tarjetas seleccion #38 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 38);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0182', 'Tarjetas seleccion #38 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0182', 'Tarjetas seleccion #38 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0182', 'Tarjetas seleccion #38 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0183: Tarjetas seleccion #39 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 39);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0183', 'Tarjetas seleccion #39 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0183', 'Tarjetas seleccion #39 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0183', 'Tarjetas seleccion #39 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0184: Tarjetas seleccion #40 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 40);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0184', 'Tarjetas seleccion #40 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0184', 'Tarjetas seleccion #40 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0184', 'Tarjetas seleccion #40 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0185: Tarjetas seleccion #41 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 41);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0185', 'Tarjetas seleccion #41 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0185', 'Tarjetas seleccion #41 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0185', 'Tarjetas seleccion #41 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0186: Tarjetas seleccion #42 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 42);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0186', 'Tarjetas seleccion #42 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0186', 'Tarjetas seleccion #42 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0186', 'Tarjetas seleccion #42 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 112_Lote_Reportes_03.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
