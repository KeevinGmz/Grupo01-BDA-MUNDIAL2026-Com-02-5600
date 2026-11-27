/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 8. Lote de reportes 4 de 10: ejecuta los procedimientos del esquema reporte
          (script 38) con parametros reales tomados de la base y guarda OK, ERROR o SKIP en la tabla
          temporal global ##lote_resultado (SKIP: ese numero de sujeto no existe en la base).
          Requiere los scripts 00 a 47 y 90 a 93. Conviene activar en SSMS: Consulta > Opciones de
          consulta > Resultados > Cuadricula > Descartar resultados despues de la ejecucion.

Casos 0187 a 0248 de este lote:
  - Tarjetas seleccion #N solo_activas=0 (6 casos)
  - Designaciones arbitrales arbitro #N (45 casos)
  - Ocupacion publicitaria sede #N (11 casos)
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

-- Caso 0187: Tarjetas seleccion #43 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 43);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0187', 'Tarjetas seleccion #43 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0187', 'Tarjetas seleccion #43 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0187', 'Tarjetas seleccion #43 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0188: Tarjetas seleccion #44 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 44);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0188', 'Tarjetas seleccion #44 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0188', 'Tarjetas seleccion #44 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0188', 'Tarjetas seleccion #44 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0189: Tarjetas seleccion #45 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 45);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0189', 'Tarjetas seleccion #45 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0189', 'Tarjetas seleccion #45 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0189', 'Tarjetas seleccion #45 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0190: Tarjetas seleccion #46 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 46);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0190', 'Tarjetas seleccion #46 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0190', 'Tarjetas seleccion #46 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0190', 'Tarjetas seleccion #46 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0191: Tarjetas seleccion #47 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 47);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0191', 'Tarjetas seleccion #47 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0191', 'Tarjetas seleccion #47 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0191', 'Tarjetas seleccion #47 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0192: Tarjetas seleccion #48 solo_activas=0
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_seleccion FROM (SELECT id_seleccion, ROW_NUMBER() OVER (ORDER BY id_seleccion) AS rn FROM torneo.seleccion) AS t WHERE t.rn = 48);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0192', 'Tarjetas seleccion #48 solo_activas=0', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_Tarjetas @id_seleccion = @id, @solo_activas = 0;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0192', 'Tarjetas seleccion #48 solo_activas=0', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0192', 'Tarjetas seleccion #48 solo_activas=0', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0193: Designaciones arbitrales arbitro #1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 1);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0193', 'Designaciones arbitrales arbitro #1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0193', 'Designaciones arbitrales arbitro #1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0193', 'Designaciones arbitrales arbitro #1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0194: Designaciones arbitrales arbitro #2
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 2);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0194', 'Designaciones arbitrales arbitro #2', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0194', 'Designaciones arbitrales arbitro #2', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0194', 'Designaciones arbitrales arbitro #2', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0195: Designaciones arbitrales arbitro #3
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 3);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0195', 'Designaciones arbitrales arbitro #3', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0195', 'Designaciones arbitrales arbitro #3', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0195', 'Designaciones arbitrales arbitro #3', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0196: Designaciones arbitrales arbitro #4
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 4);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0196', 'Designaciones arbitrales arbitro #4', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0196', 'Designaciones arbitrales arbitro #4', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0196', 'Designaciones arbitrales arbitro #4', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0197: Designaciones arbitrales arbitro #5
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 5);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0197', 'Designaciones arbitrales arbitro #5', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0197', 'Designaciones arbitrales arbitro #5', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0197', 'Designaciones arbitrales arbitro #5', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0198: Designaciones arbitrales arbitro #6
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 6);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0198', 'Designaciones arbitrales arbitro #6', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0198', 'Designaciones arbitrales arbitro #6', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0198', 'Designaciones arbitrales arbitro #6', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0199: Designaciones arbitrales arbitro #7
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 7);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0199', 'Designaciones arbitrales arbitro #7', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0199', 'Designaciones arbitrales arbitro #7', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0199', 'Designaciones arbitrales arbitro #7', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0200: Designaciones arbitrales arbitro #8
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 8);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0200', 'Designaciones arbitrales arbitro #8', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0200', 'Designaciones arbitrales arbitro #8', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0200', 'Designaciones arbitrales arbitro #8', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0201: Designaciones arbitrales arbitro #9
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 9);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0201', 'Designaciones arbitrales arbitro #9', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0201', 'Designaciones arbitrales arbitro #9', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0201', 'Designaciones arbitrales arbitro #9', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0202: Designaciones arbitrales arbitro #10
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 10);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0202', 'Designaciones arbitrales arbitro #10', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0202', 'Designaciones arbitrales arbitro #10', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0202', 'Designaciones arbitrales arbitro #10', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0203: Designaciones arbitrales arbitro #11
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 11);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0203', 'Designaciones arbitrales arbitro #11', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0203', 'Designaciones arbitrales arbitro #11', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0203', 'Designaciones arbitrales arbitro #11', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0204: Designaciones arbitrales arbitro #12
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 12);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0204', 'Designaciones arbitrales arbitro #12', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0204', 'Designaciones arbitrales arbitro #12', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0204', 'Designaciones arbitrales arbitro #12', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0205: Designaciones arbitrales arbitro #13
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 13);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0205', 'Designaciones arbitrales arbitro #13', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0205', 'Designaciones arbitrales arbitro #13', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0205', 'Designaciones arbitrales arbitro #13', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0206: Designaciones arbitrales arbitro #14
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 14);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0206', 'Designaciones arbitrales arbitro #14', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0206', 'Designaciones arbitrales arbitro #14', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0206', 'Designaciones arbitrales arbitro #14', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0207: Designaciones arbitrales arbitro #15
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 15);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0207', 'Designaciones arbitrales arbitro #15', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0207', 'Designaciones arbitrales arbitro #15', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0207', 'Designaciones arbitrales arbitro #15', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0208: Designaciones arbitrales arbitro #16
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 16);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0208', 'Designaciones arbitrales arbitro #16', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0208', 'Designaciones arbitrales arbitro #16', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0208', 'Designaciones arbitrales arbitro #16', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0209: Designaciones arbitrales arbitro #17
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 17);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0209', 'Designaciones arbitrales arbitro #17', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0209', 'Designaciones arbitrales arbitro #17', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0209', 'Designaciones arbitrales arbitro #17', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0210: Designaciones arbitrales arbitro #18
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 18);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0210', 'Designaciones arbitrales arbitro #18', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0210', 'Designaciones arbitrales arbitro #18', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0210', 'Designaciones arbitrales arbitro #18', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0211: Designaciones arbitrales arbitro #19
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 19);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0211', 'Designaciones arbitrales arbitro #19', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0211', 'Designaciones arbitrales arbitro #19', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0211', 'Designaciones arbitrales arbitro #19', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0212: Designaciones arbitrales arbitro #20
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 20);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0212', 'Designaciones arbitrales arbitro #20', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0212', 'Designaciones arbitrales arbitro #20', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0212', 'Designaciones arbitrales arbitro #20', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0213: Designaciones arbitrales arbitro #21
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 21);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0213', 'Designaciones arbitrales arbitro #21', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0213', 'Designaciones arbitrales arbitro #21', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0213', 'Designaciones arbitrales arbitro #21', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0214: Designaciones arbitrales arbitro #22
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 22);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0214', 'Designaciones arbitrales arbitro #22', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0214', 'Designaciones arbitrales arbitro #22', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0214', 'Designaciones arbitrales arbitro #22', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0215: Designaciones arbitrales arbitro #23
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 23);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0215', 'Designaciones arbitrales arbitro #23', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0215', 'Designaciones arbitrales arbitro #23', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0215', 'Designaciones arbitrales arbitro #23', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0216: Designaciones arbitrales arbitro #24
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 24);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0216', 'Designaciones arbitrales arbitro #24', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0216', 'Designaciones arbitrales arbitro #24', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0216', 'Designaciones arbitrales arbitro #24', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0217: Designaciones arbitrales arbitro #25
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 25);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0217', 'Designaciones arbitrales arbitro #25', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0217', 'Designaciones arbitrales arbitro #25', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0217', 'Designaciones arbitrales arbitro #25', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0218: Designaciones arbitrales arbitro #26
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 26);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0218', 'Designaciones arbitrales arbitro #26', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0218', 'Designaciones arbitrales arbitro #26', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0218', 'Designaciones arbitrales arbitro #26', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0219: Designaciones arbitrales arbitro #27
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 27);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0219', 'Designaciones arbitrales arbitro #27', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0219', 'Designaciones arbitrales arbitro #27', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0219', 'Designaciones arbitrales arbitro #27', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0220: Designaciones arbitrales arbitro #28
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 28);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0220', 'Designaciones arbitrales arbitro #28', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0220', 'Designaciones arbitrales arbitro #28', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0220', 'Designaciones arbitrales arbitro #28', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0221: Designaciones arbitrales arbitro #29
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 29);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0221', 'Designaciones arbitrales arbitro #29', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0221', 'Designaciones arbitrales arbitro #29', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0221', 'Designaciones arbitrales arbitro #29', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0222: Designaciones arbitrales arbitro #30
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 30);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0222', 'Designaciones arbitrales arbitro #30', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0222', 'Designaciones arbitrales arbitro #30', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0222', 'Designaciones arbitrales arbitro #30', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0223: Designaciones arbitrales arbitro #31
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 31);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0223', 'Designaciones arbitrales arbitro #31', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0223', 'Designaciones arbitrales arbitro #31', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0223', 'Designaciones arbitrales arbitro #31', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0224: Designaciones arbitrales arbitro #32
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 32);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0224', 'Designaciones arbitrales arbitro #32', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0224', 'Designaciones arbitrales arbitro #32', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0224', 'Designaciones arbitrales arbitro #32', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0225: Designaciones arbitrales arbitro #33
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 33);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0225', 'Designaciones arbitrales arbitro #33', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0225', 'Designaciones arbitrales arbitro #33', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0225', 'Designaciones arbitrales arbitro #33', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0226: Designaciones arbitrales arbitro #34
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 34);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0226', 'Designaciones arbitrales arbitro #34', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0226', 'Designaciones arbitrales arbitro #34', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0226', 'Designaciones arbitrales arbitro #34', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0227: Designaciones arbitrales arbitro #35
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 35);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0227', 'Designaciones arbitrales arbitro #35', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0227', 'Designaciones arbitrales arbitro #35', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0227', 'Designaciones arbitrales arbitro #35', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0228: Designaciones arbitrales arbitro #36
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 36);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0228', 'Designaciones arbitrales arbitro #36', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0228', 'Designaciones arbitrales arbitro #36', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0228', 'Designaciones arbitrales arbitro #36', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0229: Designaciones arbitrales arbitro #37
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 37);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0229', 'Designaciones arbitrales arbitro #37', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0229', 'Designaciones arbitrales arbitro #37', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0229', 'Designaciones arbitrales arbitro #37', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0230: Designaciones arbitrales arbitro #38
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 38);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0230', 'Designaciones arbitrales arbitro #38', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0230', 'Designaciones arbitrales arbitro #38', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0230', 'Designaciones arbitrales arbitro #38', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0231: Designaciones arbitrales arbitro #39
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 39);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0231', 'Designaciones arbitrales arbitro #39', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0231', 'Designaciones arbitrales arbitro #39', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0231', 'Designaciones arbitrales arbitro #39', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0232: Designaciones arbitrales arbitro #40
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 40);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0232', 'Designaciones arbitrales arbitro #40', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0232', 'Designaciones arbitrales arbitro #40', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0232', 'Designaciones arbitrales arbitro #40', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0233: Designaciones arbitrales arbitro #41
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 41);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0233', 'Designaciones arbitrales arbitro #41', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0233', 'Designaciones arbitrales arbitro #41', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0233', 'Designaciones arbitrales arbitro #41', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0234: Designaciones arbitrales arbitro #42
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 42);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0234', 'Designaciones arbitrales arbitro #42', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0234', 'Designaciones arbitrales arbitro #42', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0234', 'Designaciones arbitrales arbitro #42', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0235: Designaciones arbitrales arbitro #43
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 43);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0235', 'Designaciones arbitrales arbitro #43', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0235', 'Designaciones arbitrales arbitro #43', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0235', 'Designaciones arbitrales arbitro #43', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0236: Designaciones arbitrales arbitro #44
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 44);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0236', 'Designaciones arbitrales arbitro #44', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0236', 'Designaciones arbitrales arbitro #44', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0236', 'Designaciones arbitrales arbitro #44', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0237: Designaciones arbitrales arbitro #45
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_persona FROM (SELECT id_persona, ROW_NUMBER() OVER (ORDER BY id_persona) AS rn FROM persona.arbitro) AS t WHERE t.rn = 45);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0237', 'Designaciones arbitrales arbitro #45', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0237', 'Designaciones arbitrales arbitro #45', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0237', 'Designaciones arbitrales arbitro #45', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0238: Ocupacion publicitaria sede #1
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 1);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0238', 'Ocupacion publicitaria sede #1', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0238', 'Ocupacion publicitaria sede #1', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0238', 'Ocupacion publicitaria sede #1', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0239: Ocupacion publicitaria sede #2
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 2);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0239', 'Ocupacion publicitaria sede #2', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0239', 'Ocupacion publicitaria sede #2', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0239', 'Ocupacion publicitaria sede #2', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0240: Ocupacion publicitaria sede #3
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 3);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0240', 'Ocupacion publicitaria sede #3', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0240', 'Ocupacion publicitaria sede #3', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0240', 'Ocupacion publicitaria sede #3', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0241: Ocupacion publicitaria sede #4
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 4);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0241', 'Ocupacion publicitaria sede #4', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0241', 'Ocupacion publicitaria sede #4', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0241', 'Ocupacion publicitaria sede #4', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0242: Ocupacion publicitaria sede #5
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 5);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0242', 'Ocupacion publicitaria sede #5', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0242', 'Ocupacion publicitaria sede #5', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0242', 'Ocupacion publicitaria sede #5', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0243: Ocupacion publicitaria sede #6
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 6);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0243', 'Ocupacion publicitaria sede #6', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0243', 'Ocupacion publicitaria sede #6', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0243', 'Ocupacion publicitaria sede #6', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0244: Ocupacion publicitaria sede #7
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 7);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0244', 'Ocupacion publicitaria sede #7', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0244', 'Ocupacion publicitaria sede #7', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0244', 'Ocupacion publicitaria sede #7', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0245: Ocupacion publicitaria sede #8
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 8);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0245', 'Ocupacion publicitaria sede #8', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0245', 'Ocupacion publicitaria sede #8', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0245', 'Ocupacion publicitaria sede #8', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0246: Ocupacion publicitaria sede #9
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 9);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0246', 'Ocupacion publicitaria sede #9', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0246', 'Ocupacion publicitaria sede #9', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0246', 'Ocupacion publicitaria sede #9', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0247: Ocupacion publicitaria sede #10
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 10);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0247', 'Ocupacion publicitaria sede #10', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0247', 'Ocupacion publicitaria sede #10', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0247', 'Ocupacion publicitaria sede #10', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO
-- Caso 0248: Ocupacion publicitaria sede #11
BEGIN TRY
    DECLARE @id INT = (SELECT t.id_sede FROM (SELECT id_sede, ROW_NUMBER() OVER (ORDER BY id_sede) AS rn FROM torneo.sede) AS t WHERE t.rn = 11);
    IF @id IS NULL
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0248', 'Ocupacion publicitaria sede #11', 'SKIP', 'no existe el sujeto');
    ELSE
    BEGIN
        EXEC reporte.usp_OcupacionPublicitaria @id_sede = @id;
        INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0248', 'Ocupacion publicitaria sede #11', 'OK', 'id=' + CAST(@id AS VARCHAR(10)));
    END
END TRY
BEGIN CATCH
    INSERT INTO ##lote_resultado (caso, descripcion, estado, detalle) VALUES ('0248', 'Ocupacion publicitaria sede #11', 'ERROR', ERROR_MESSAGE());
END CATCH;
GO

PRINT '-> Resumen de 113_Lote_Reportes_04.sql';
SELECT estado, COUNT(*) AS casos FROM ##lote_resultado GROUP BY estado ORDER BY estado;
SELECT caso, descripcion, estado, detalle FROM ##lote_resultado WHERE estado IN ('FAIL', 'ERROR') ORDER BY orden;
GO
