/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Pruebas de error de 37_SP_Importacion_Plantillas.sql: URL no
          permitida, página sin tablas de plantillas y página con filas
          inválidas (datos\pruebas\plantillas_con_errores.html).
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS DE ERROR: 86_Test_Importacion_Plantillas_ERR';
PRINT N'=====================================================================';
GO

-------------------------------------------------------------------------------
-- Caso 1: URL fuera de Wikipedia
-- Resultado esperado: excepción 50001 antes de registrar la importación.
-------------------------------------------------------------------------------
PRINT N'-> Test 1: url no permitida';
DECLARE @v_antes INT = (SELECT COUNT(*) FROM soporte.importacion);
DECLARE @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Importar_PlantillasWikipedia @url = N'https://example.com/plantillas';
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;

SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50001 AND @v_msj LIKE N'%wikipedia%' AND (SELECT COUNT(*) FROM soporte.importacion) = @v_antes
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 2: página sin tablas de plantillas (pagina_sin_plantillas.html)
-- Resultado esperado: excepción 50002 y la importación queda CON_ERROR.
-------------------------------------------------------------------------------
PRINT N'-> Test 2: pagina sin plantillas';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\pruebas\pagina_sin_plantillas.html';
DECLARE @v_id INT, @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Importar_PlantillasWikipedia @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;

SELECT TOP (1) @v_id = id_importacion FROM soporte.importacion WHERE archivo = @v_archivo ORDER BY id_importacion DESC;

SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50002 AND (SELECT estado FROM soporte.importacion WHERE id_importacion = @v_id) = 'CON_ERROR'
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- Caso 3: filas inválidas (plantillas_con_errores.html)
-- Fila 1: selección inexistente (Atlantis).
-- Fila 2: dorsal no numérico. Fila 3: posición desconocida (XX).
-- Fila 4: sin fecha de nacimiento.
-- Resultado esperado: CON_ERROR, 4 filas con error, ningún jugador ni club
-- nuevo, y la convocatoria de México no se compara por los errores.
-------------------------------------------------------------------------------
PRINT N'-> Test 3: filas de jugadores invalidas';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\pruebas\plantillas_con_errores.html';
DECLARE @v_id INT;
DECLARE @v_jugadores INT = (SELECT COUNT(*) FROM persona.jugador);
DECLARE @v_clubes INT = (SELECT COUNT(*) FROM persona.club);

EXEC soporte.usp_Importar_PlantillasWikipedia @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;

SELECT e.nro_fila, e.columna, e.valor, e.mensaje
FROM soporte.importacion_error AS e
WHERE e.id_importacion = @v_id
ORDER BY e.nro_error;

SELECT i.estado, i.filas_leidas, i.filas_ok, i.filas_error,
       CASE WHEN i.estado = 'CON_ERROR' AND i.filas_leidas = 4 AND i.filas_error = 4
             AND (SELECT COUNT(*) FROM persona.jugador) = @v_jugadores
             AND (SELECT COUNT(*) FROM persona.club) = @v_clubes
            THEN N'PASS' ELSE N'FAIL' END AS resultado
FROM soporte.importacion AS i
WHERE i.id_importacion = @v_id;
GO

PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS DE ERROR: 86_Test_Importacion_Plantillas_ERR';
PRINT N'=====================================================================';
GO
