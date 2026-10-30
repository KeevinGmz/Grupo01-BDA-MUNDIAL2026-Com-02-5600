/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Pruebas de error de 18_SP_Importacion_Geografia.sql con archivos
          de prueba (carpeta datos\pruebas) que mezclan filas válidas e
          inválidas: se importan las válidas, se registra un error por cada
          fila rechazada y la importación termina CON_ERROR. También se
          prueban archivos inexistentes, JSON mal formado y parámetros
          inválidos.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS DE ERROR: 82_Test_Importacion_Geografia_ERR';
PRINT N'=====================================================================';
GO

-------------------------------------------------------------------------------
-- Caso 1: países con errores parciales (paises_con_errores.csv)
-- Fila 2: Argentina válida (sin cambios).
-- Fila 3: códigos ISO inválidos. Fila 4: continente inexistente.
-- Fila 5: país sin nombre. Fila 6: código ISO3 repetido.
-- Resultado esperado: CON_ERROR, 1 fila ok, 4 errores, sin países nuevos.
-------------------------------------------------------------------------------
PRINT N'-> Test 1: paises con errores parciales';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\pruebas\paises_con_errores.csv';
DECLARE @v_id INT;
DECLARE @v_antes INT = (SELECT COUNT(*) FROM geo.pais);

EXEC soporte.usp_Importar_PaisesCsv @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;

SELECT i.estado, i.filas_leidas, i.filas_ok, i.filas_error,
       CASE WHEN i.estado = 'CON_ERROR' AND i.filas_ok = 1 AND i.filas_error = 4
             AND (SELECT COUNT(*) FROM geo.pais) = @v_antes
            THEN N'PASS' ELSE N'FAIL' END AS resultado
FROM soporte.importacion AS i
WHERE i.id_importacion = @v_id;
GO

-------------------------------------------------------------------------------
-- Caso 2: husos con errores parciales (husos_con_errores.txt)
-- Resultado esperado: Buenos Aires sin cambios; offset no numérico, offset
-- fuera de rango y zona repetida se rechazan (3 errores).
-------------------------------------------------------------------------------
PRINT N'-> Test 2: husos con errores parciales';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\pruebas\husos_con_errores.txt';
DECLARE @v_id INT;

EXEC soporte.usp_Importar_HusosTxt @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;

SELECT i.estado, i.filas_leidas, i.filas_ok, i.filas_error,
       CASE WHEN i.estado = 'CON_ERROR' AND i.filas_ok = 1 AND i.filas_error = 3
             AND NOT EXISTS (SELECT 1 FROM geo.huso_horario WHERE zona_horaria LIKE N'Prueba/%')
            THEN N'PASS' ELSE N'FAIL' END AS resultado
FROM soporte.importacion AS i
WHERE i.id_importacion = @v_id;
GO

-------------------------------------------------------------------------------
-- Caso 3: ciudades con errores (ciudades_con_errores.txt)
-- Resultado esperado: país inexistente, huso inexistente y población no
-- numérica se rechazan (3 errores); el pueblo de 20.000 habitantes se omite
-- por no alcanzar la población mínima. No se crea ninguna ciudad.
-------------------------------------------------------------------------------
PRINT N'-> Test 3: ciudades con errores';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\pruebas\ciudades_con_errores.txt';
DECLARE @v_id INT;
DECLARE @v_antes INT = (SELECT COUNT(*) FROM geo.ciudad);

EXEC soporte.usp_Importar_CiudadesTxt @archivo = @v_archivo, @poblacion_minima = 100000, @id_importacion = @v_id OUTPUT;

SELECT i.estado, i.filas_leidas, i.filas_ok, i.filas_error,
       CASE WHEN i.estado = 'CON_ERROR' AND i.filas_leidas = 4 AND i.filas_ok = 0 AND i.filas_error = 3
             AND (SELECT COUNT(*) FROM geo.ciudad) = @v_antes
            THEN N'PASS' ELSE N'FAIL' END AS resultado
FROM soporte.importacion AS i
WHERE i.id_importacion = @v_id;
GO

-------------------------------------------------------------------------------
-- Caso 4: sedes con errores parciales (sedes_con_errores.json)
-- Resultado esperado: BC Place sin cambios; país inexistente, capacidad 0,
-- coordenadas ilegibles y huso con formato inválido se rechazan (4 errores).
-------------------------------------------------------------------------------
PRINT N'-> Test 4: sedes con errores parciales';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\pruebas\sedes_con_errores.json';
DECLARE @v_id INT;
DECLARE @v_antes INT = (SELECT COUNT(*) FROM torneo.sede);

EXEC soporte.usp_Importar_SedesJson @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;

SELECT i.estado, i.filas_leidas, i.filas_ok, i.filas_error,
       CASE WHEN i.estado = 'CON_ERROR' AND i.filas_ok = 1 AND i.filas_error = 4
             AND (SELECT COUNT(*) FROM torneo.sede) = @v_antes
            THEN N'PASS' ELSE N'FAIL' END AS resultado
FROM soporte.importacion AS i
WHERE i.id_importacion = @v_id;
GO

-------------------------------------------------------------------------------
-- Caso 5: selecciones con errores parciales (selecciones_con_errores.json)
-- Resultado esperado: México sin cambios; grupo inexistente, código FIFA
-- inválido, confederación inexistente y código repetido (4 errores).
-------------------------------------------------------------------------------
PRINT N'-> Test 5: selecciones con errores parciales';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\pruebas\selecciones_con_errores.json';
DECLARE @v_id INT;
DECLARE @v_antes INT = (SELECT COUNT(*) FROM torneo.seleccion);

EXEC soporte.usp_Importar_SeleccionesJson @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;

SELECT i.estado, i.filas_leidas, i.filas_ok, i.filas_error,
       CASE WHEN i.estado = 'CON_ERROR' AND i.filas_ok = 1 AND i.filas_error = 4
             AND (SELECT COUNT(*) FROM torneo.seleccion) = @v_antes
            THEN N'PASS' ELSE N'FAIL' END AS resultado
FROM soporte.importacion AS i
WHERE i.id_importacion = @v_id;
GO

-------------------------------------------------------------------------------
-- Caso 6: archivo JSON mal formado
-- Resultado esperado: excepción 50002, la importación queda registrada
-- CON_ERROR con el error de archivo en la fila 1.
-------------------------------------------------------------------------------
PRINT N'-> Test 6: JSON mal formado';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\pruebas\json_invalido.json';
DECLARE @v_id INT, @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Importar_SedesJson @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;

SELECT TOP (1) @v_id = id_importacion FROM soporte.importacion WHERE archivo = @v_archivo ORDER BY id_importacion DESC;

SELECT @v_nro AS error_numero, @v_msj AS error_mensaje, i.estado,
       CASE WHEN @v_nro = 50002 AND i.estado = 'CON_ERROR'
             AND EXISTS (SELECT 1 FROM soporte.importacion_error AS e WHERE e.id_importacion = i.id_importacion AND e.columna = N'(archivo)')
            THEN N'PASS' ELSE N'FAIL' END AS resultado
FROM soporte.importacion AS i
WHERE i.id_importacion = @v_id;
GO

-------------------------------------------------------------------------------
-- Caso 7: archivo inexistente
-- Resultado esperado: excepción 50002 y la importación queda CON_ERROR.
-------------------------------------------------------------------------------
PRINT N'-> Test 7: archivo inexistente';
DECLARE @v_archivo NVARCHAR(260) = N'C:\Mundial2026\datos\no_existe_82.csv';
DECLARE @v_id INT, @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Importar_PaisesCsv @archivo = @v_archivo, @id_importacion = @v_id OUTPUT;
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
-- Caso 8: parámetros inválidos (extensión incorrecta y población negativa)
-- Resultado esperado: excepción 50001 con ambos motivos; no se registra
-- ninguna importación porque falla antes de abrir la cabecera.
-------------------------------------------------------------------------------
PRINT N'-> Test 8: parametros invalidos';
DECLARE @v_antes INT = (SELECT COUNT(*) FROM soporte.importacion);
DECLARE @v_nro INT, @v_msj NVARCHAR(2048);
BEGIN TRY
    EXEC soporte.usp_Importar_CiudadesTxt @archivo = N'C:\Mundial2026\datos\cities15000.zip', @poblacion_minima = -1;
    SELECT @v_nro = 0, @v_msj = N'no se lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SELECT @v_nro = ERROR_NUMBER(), @v_msj = ERROR_MESSAGE();
END CATCH;

SELECT @v_nro AS error_numero, @v_msj AS error_mensaje,
       CASE WHEN @v_nro = 50001 AND @v_msj LIKE N'%extension%' AND @v_msj LIKE N'%poblacion_minima%'
             AND (SELECT COUNT(*) FROM soporte.importacion) = @v_antes
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS DE ERROR: 82_Test_Importacion_Geografia_ERR';
PRINT N'=====================================================================';
GO
