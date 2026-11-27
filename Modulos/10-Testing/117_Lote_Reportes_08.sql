/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de reportes 8 de 10: ejecuta los procedimientos del esquema reporte
          (script 38) con parametros reales tomados de la base y guarda OK, ERROR o SKIP en la tabla
          temporal global ##lote_resultado (SKIP: ese numero de sujeto no existe en la base).
          Requiere los scripts 00 a 47 y 90 a 93. Conviene activar en SSMS: Consulta > Opciones de
          consulta > Resultados > Cuadricula > Descartar resultados despues de la ejecucion.

Casos 0435 a 0496 de este lote:
  - Matriz prime time partido #N (27 casos)
  - Selecciones y plantillas seleccion #N incluir_bajas=0 (35 casos)
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

-- Caso 0435: Matriz prime time partido #78
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 78);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0435', 'Matriz prime time partido #78', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0435', 'Matriz prime time partido #78', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0435', 'Matriz prime time partido #78', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0436: Matriz prime time partido #79
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 79);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0436', 'Matriz prime time partido #79', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0436', 'Matriz prime time partido #79', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0436', 'Matriz prime time partido #79', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0437: Matriz prime time partido #80
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 80);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0437', 'Matriz prime time partido #80', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0437', 'Matriz prime time partido #80', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0437', 'Matriz prime time partido #80', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0438: Matriz prime time partido #81
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 81);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0438', 'Matriz prime time partido #81', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0438', 'Matriz prime time partido #81', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0438', 'Matriz prime time partido #81', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0439: Matriz prime time partido #82
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 82);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0439', 'Matriz prime time partido #82', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0439', 'Matriz prime time partido #82', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0439', 'Matriz prime time partido #82', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0440: Matriz prime time partido #83
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 83);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0440', 'Matriz prime time partido #83', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0440', 'Matriz prime time partido #83', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0440', 'Matriz prime time partido #83', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0441: Matriz prime time partido #84
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 84);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0441', 'Matriz prime time partido #84', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0441', 'Matriz prime time partido #84', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0441', 'Matriz prime time partido #84', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0442: Matriz prime time partido #85
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 85);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0442', 'Matriz prime time partido #85', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0442', 'Matriz prime time partido #85', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0442', 'Matriz prime time partido #85', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0443: Matriz prime time partido #86
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 86);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0443', 'Matriz prime time partido #86', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0443', 'Matriz prime time partido #86', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0443', 'Matriz prime time partido #86', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0444: Matriz prime time partido #87
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 87);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0444', 'Matriz prime time partido #87', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0444', 'Matriz prime time partido #87', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0444', 'Matriz prime time partido #87', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0445: Matriz prime time partido #88
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 88);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0445', 'Matriz prime time partido #88', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0445', 'Matriz prime time partido #88', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0445', 'Matriz prime time partido #88', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0446: Matriz prime time partido #89
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 89);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0446', 'Matriz prime time partido #89', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0446', 'Matriz prime time partido #89', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0446', 'Matriz prime time partido #89', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0447: Matriz prime time partido #90
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 90);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0447', 'Matriz prime time partido #90', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0447', 'Matriz prime time partido #90', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0447', 'Matriz prime time partido #90', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0448: Matriz prime time partido #91
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 91);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0448', 'Matriz prime time partido #91', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0448', 'Matriz prime time partido #91', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0448', 'Matriz prime time partido #91', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0449: Matriz prime time partido #92
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 92);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0449', 'Matriz prime time partido #92', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0449', 'Matriz prime time partido #92', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0449', 'Matriz prime time partido #92', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0450: Matriz prime time partido #93
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 93);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0450', 'Matriz prime time partido #93', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0450', 'Matriz prime time partido #93', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0450', 'Matriz prime time partido #93', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0451: Matriz prime time partido #94
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 94);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0451', 'Matriz prime time partido #94', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0451', 'Matriz prime time partido #94', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0451', 'Matriz prime time partido #94', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0452: Matriz prime time partido #95
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 95);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0452', 'Matriz prime time partido #95', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0452', 'Matriz prime time partido #95', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0452', 'Matriz prime time partido #95', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0453: Matriz prime time partido #96
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 96);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0453', 'Matriz prime time partido #96', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0453', 'Matriz prime time partido #96', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0453', 'Matriz prime time partido #96', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0454: Matriz prime time partido #97
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 97);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0454', 'Matriz prime time partido #97', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0454', 'Matriz prime time partido #97', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0454', 'Matriz prime time partido #97', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0455: Matriz prime time partido #98
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 98);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0455', 'Matriz prime time partido #98', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0455', 'Matriz prime time partido #98', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0455', 'Matriz prime time partido #98', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0456: Matriz prime time partido #99
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 99);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0456', 'Matriz prime time partido #99', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0456', 'Matriz prime time partido #99', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0456', 'Matriz prime time partido #99', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0457: Matriz prime time partido #100
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 100);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0457', 'Matriz prime time partido #100', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0457', 'Matriz prime time partido #100', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0457', 'Matriz prime time partido #100', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0458: Matriz prime time partido #101
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 101);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0458', 'Matriz prime time partido #101', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0458', 'Matriz prime time partido #101', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0458', 'Matriz prime time partido #101', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0459: Matriz prime time partido #102
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 102);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0459', 'Matriz prime time partido #102', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0459', 'Matriz prime time partido #102', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0459', 'Matriz prime time partido #102', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0460: Matriz prime time partido #103
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 103);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0460', 'Matriz prime time partido #103', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0460', 'Matriz prime time partido #103', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0460', 'Matriz prime time partido #103', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0461: Matriz prime time partido #104
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_partido FROM (SELECT id_partido, ROW_NUMBER() OVER (ORDER BY id_partido) AS rn FROM torneo.partido) AS t WHERE t.rn = 104);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0461', 'Matriz prime time partido #104', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_MatrizPrimeTime @id_partido = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0461', 'Matriz prime time partido #104', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0461', 'Matriz prime time partido #104', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0462: Selecciones y plantillas seleccion #1 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 1);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0462', 'Selecciones y plantillas seleccion #1 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0462', 'Selecciones y plantillas seleccion #1 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0462', 'Selecciones y plantillas seleccion #1 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0463: Selecciones y plantillas seleccion #2 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 2);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0463', 'Selecciones y plantillas seleccion #2 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0463', 'Selecciones y plantillas seleccion #2 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0463', 'Selecciones y plantillas seleccion #2 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0464: Selecciones y plantillas seleccion #3 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 3);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0464', 'Selecciones y plantillas seleccion #3 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0464', 'Selecciones y plantillas seleccion #3 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0464', 'Selecciones y plantillas seleccion #3 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0465: Selecciones y plantillas seleccion #4 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 4);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0465', 'Selecciones y plantillas seleccion #4 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0465', 'Selecciones y plantillas seleccion #4 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0465', 'Selecciones y plantillas seleccion #4 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0466: Selecciones y plantillas seleccion #5 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 5);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0466', 'Selecciones y plantillas seleccion #5 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0466', 'Selecciones y plantillas seleccion #5 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0466', 'Selecciones y plantillas seleccion #5 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0467: Selecciones y plantillas seleccion #6 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 6);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0467', 'Selecciones y plantillas seleccion #6 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0467', 'Selecciones y plantillas seleccion #6 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0467', 'Selecciones y plantillas seleccion #6 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0468: Selecciones y plantillas seleccion #7 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 7);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0468', 'Selecciones y plantillas seleccion #7 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0468', 'Selecciones y plantillas seleccion #7 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0468', 'Selecciones y plantillas seleccion #7 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0469: Selecciones y plantillas seleccion #8 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 8);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0469', 'Selecciones y plantillas seleccion #8 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0469', 'Selecciones y plantillas seleccion #8 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0469', 'Selecciones y plantillas seleccion #8 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0470: Selecciones y plantillas seleccion #9 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 9);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0470', 'Selecciones y plantillas seleccion #9 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0470', 'Selecciones y plantillas seleccion #9 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0470', 'Selecciones y plantillas seleccion #9 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0471: Selecciones y plantillas seleccion #10 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 10);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0471', 'Selecciones y plantillas seleccion #10 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0471', 'Selecciones y plantillas seleccion #10 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0471', 'Selecciones y plantillas seleccion #10 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0472: Selecciones y plantillas seleccion #11 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 11);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0472', 'Selecciones y plantillas seleccion #11 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0472', 'Selecciones y plantillas seleccion #11 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0472', 'Selecciones y plantillas seleccion #11 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0473: Selecciones y plantillas seleccion #12 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 12);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0473', 'Selecciones y plantillas seleccion #12 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0473', 'Selecciones y plantillas seleccion #12 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0473', 'Selecciones y plantillas seleccion #12 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0474: Selecciones y plantillas seleccion #13 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 13);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0474', 'Selecciones y plantillas seleccion #13 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0474', 'Selecciones y plantillas seleccion #13 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0474', 'Selecciones y plantillas seleccion #13 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0475: Selecciones y plantillas seleccion #14 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 14);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0475', 'Selecciones y plantillas seleccion #14 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0475', 'Selecciones y plantillas seleccion #14 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0475', 'Selecciones y plantillas seleccion #14 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0476: Selecciones y plantillas seleccion #15 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 15);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0476', 'Selecciones y plantillas seleccion #15 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0476', 'Selecciones y plantillas seleccion #15 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0476', 'Selecciones y plantillas seleccion #15 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0477: Selecciones y plantillas seleccion #16 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 16);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0477', 'Selecciones y plantillas seleccion #16 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0477', 'Selecciones y plantillas seleccion #16 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0477', 'Selecciones y plantillas seleccion #16 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0478: Selecciones y plantillas seleccion #17 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 17);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0478', 'Selecciones y plantillas seleccion #17 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0478', 'Selecciones y plantillas seleccion #17 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0478', 'Selecciones y plantillas seleccion #17 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0479: Selecciones y plantillas seleccion #18 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 18);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0479', 'Selecciones y plantillas seleccion #18 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0479', 'Selecciones y plantillas seleccion #18 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0479', 'Selecciones y plantillas seleccion #18 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0480: Selecciones y plantillas seleccion #19 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 19);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0480', 'Selecciones y plantillas seleccion #19 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0480', 'Selecciones y plantillas seleccion #19 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0480', 'Selecciones y plantillas seleccion #19 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0481: Selecciones y plantillas seleccion #20 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 20);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0481', 'Selecciones y plantillas seleccion #20 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0481', 'Selecciones y plantillas seleccion #20 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0481', 'Selecciones y plantillas seleccion #20 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0482: Selecciones y plantillas seleccion #21 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 21);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0482', 'Selecciones y plantillas seleccion #21 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0482', 'Selecciones y plantillas seleccion #21 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0482', 'Selecciones y plantillas seleccion #21 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0483: Selecciones y plantillas seleccion #22 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 22);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0483', 'Selecciones y plantillas seleccion #22 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0483', 'Selecciones y plantillas seleccion #22 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0483', 'Selecciones y plantillas seleccion #22 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0484: Selecciones y plantillas seleccion #23 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 23);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0484', 'Selecciones y plantillas seleccion #23 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0484', 'Selecciones y plantillas seleccion #23 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0484', 'Selecciones y plantillas seleccion #23 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0485: Selecciones y plantillas seleccion #24 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 24);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0485', 'Selecciones y plantillas seleccion #24 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0485', 'Selecciones y plantillas seleccion #24 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0485', 'Selecciones y plantillas seleccion #24 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0486: Selecciones y plantillas seleccion #25 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 25);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0486', 'Selecciones y plantillas seleccion #25 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0486', 'Selecciones y plantillas seleccion #25 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0486', 'Selecciones y plantillas seleccion #25 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0487: Selecciones y plantillas seleccion #26 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 26);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0487', 'Selecciones y plantillas seleccion #26 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0487', 'Selecciones y plantillas seleccion #26 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0487', 'Selecciones y plantillas seleccion #26 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0488: Selecciones y plantillas seleccion #27 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 27);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0488', 'Selecciones y plantillas seleccion #27 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0488', 'Selecciones y plantillas seleccion #27 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0488', 'Selecciones y plantillas seleccion #27 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0489: Selecciones y plantillas seleccion #28 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 28);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0489', 'Selecciones y plantillas seleccion #28 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0489', 'Selecciones y plantillas seleccion #28 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0489', 'Selecciones y plantillas seleccion #28 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0490: Selecciones y plantillas seleccion #29 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 29);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0490', 'Selecciones y plantillas seleccion #29 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0490', 'Selecciones y plantillas seleccion #29 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0490', 'Selecciones y plantillas seleccion #29 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0491: Selecciones y plantillas seleccion #30 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 30);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0491', 'Selecciones y plantillas seleccion #30 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0491', 'Selecciones y plantillas seleccion #30 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0491', 'Selecciones y plantillas seleccion #30 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0492: Selecciones y plantillas seleccion #31 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 31);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0492', 'Selecciones y plantillas seleccion #31 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0492', 'Selecciones y plantillas seleccion #31 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0492', 'Selecciones y plantillas seleccion #31 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0493: Selecciones y plantillas seleccion #32 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 32);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0493', 'Selecciones y plantillas seleccion #32 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0493', 'Selecciones y plantillas seleccion #32 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0493', 'Selecciones y plantillas seleccion #32 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0494: Selecciones y plantillas seleccion #33 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 33);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0494', 'Selecciones y plantillas seleccion #33 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0494', 'Selecciones y plantillas seleccion #33 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0494', 'Selecciones y plantillas seleccion #33 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0495: Selecciones y plantillas seleccion #34 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 34);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0495', 'Selecciones y plantillas seleccion #34 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0495', 'Selecciones y plantillas seleccion #34 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0495', 'Selecciones y plantillas seleccion #34 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0496: Selecciones y plantillas seleccion #35 incluir_bajas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 35);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0496', 'Selecciones y plantillas seleccion #35 incluir_bajas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = @id, @incluir_bajas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0496', 'Selecciones y plantillas seleccion #35 incluir_bajas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0496', 'Selecciones y plantillas seleccion #35 incluir_bajas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 117_Lote_Reportes_08.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
