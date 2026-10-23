/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Pruebas exitosas de 17_SP_Importacion_Soporte.sql: funciones de
          limpieza y conversión, lectura de archivos, consumo HTTP y auditoría
          de importaciones. Cada caso indica el resultado esperado y muestra
          PASS o FAIL.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS EXITOSAS: 79_Test_Importacion_Soporte_OK';
PRINT N'=====================================================================';
GO

-------------------------------------------------------------------------------
-- 1. Funciones de limpieza y conversión
-- Resultado esperado: todas las filas en PASS.
-------------------------------------------------------------------------------
PRINT N'-> Test 1: funciones de limpieza y conversion';

SELECT caso, obtenido, esperado,
       CASE WHEN obtenido = esperado OR (obtenido IS NULL AND esperado IS NULL) THEN N'PASS' ELSE N'FAIL' END AS resultado
FROM (VALUES
    (N'fn_Limpiar quita espacios, tabulaciones y saltos',
        soporte.fn_Limpiar(CONCAT(NCHAR(9), N'  Buenos   Aires ', NCHAR(13), NCHAR(10))), N'Buenos Aires'),
    (N'fn_Limpiar devuelve NULL si queda vacio',
        soporte.fn_Limpiar(N'   '), NULL),
    (N'fn_HtmlATexto quita etiquetas y bloques ocultos',
        soporte.fn_HtmlATexto(N'<td><span style="display:none">1</span><a href="x">GK</a></td>'), N'GK'),
    (N'fn_HtmlATexto decodifica entidades y referencias',
        soporte.fn_HtmlATexto(N'<a>AT&amp;T Stadium</a><sup class="reference">[1]</sup>'), N'AT&T Stadium'),
    (N'fn_CoordenadaADecimal grados/minutos/segundos norte',
        CONVERT(NVARCHAR(20), soporte.fn_CoordenadaADecimal(CONCAT(N'49', NCHAR(176), N'16''36"N'))), N'49.276667'),
    (N'fn_CoordenadaADecimal grados decimales oeste',
        CONVERT(NVARCHAR(20), soporte.fn_CoordenadaADecimal(CONCAT(N'121.970', NCHAR(176), N'W'))), N'-121.970000'),
    (N'fn_ValidarRutaArchivo acepta una ruta valida',
        soporte.fn_ValidarRutaArchivo(N'C:\Mundial2026\datos\country-codes.csv', N'.csv'), N''),
    (N'fn_ApellidoDesdeClave usa la clave de orden',
        soporte.fn_ApellidoDesdeClave(N'Matías Fernández Pardo', N'Fernandez Pardo, Matias'), N'Fernández Pardo')
) AS t(caso, obtenido, esperado);
GO

-------------------------------------------------------------------------------
-- 2. Búsqueda de países por código o nombre externo
-- Resultado esperado: AR y "Argentina" devuelven el mismo país; un nombre
-- desconocido devuelve NULL. Requiere la carga inicial (39).
-------------------------------------------------------------------------------
PRINT N'-> Test 2: busqueda de paises por equivalencias';

DECLARE @v_por_iso2 SMALLINT = soporte.fn_BuscarPais('ISO2', N'AR');
DECLARE @v_por_nombre SMALLINT = soporte.fn_BuscarPais('NOMBRE', N'Argentina');
DECLARE @v_desconocido SMALLINT = soporte.fn_BuscarPais('NOMBRE', N'Atlantis');

SELECT @v_por_iso2 AS id_por_iso2, @v_por_nombre AS id_por_nombre, @v_desconocido AS id_desconocido,
       CASE WHEN @v_por_iso2 IS NOT NULL AND @v_por_iso2 = @v_por_nombre AND @v_desconocido IS NULL
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- 3. Lectura de un archivo UTF-8
-- Resultado esperado: se lee el archivo completo, se decodifican los
-- caracteres acentuados (Curaçao) y el contenido es un JSON válido.
-------------------------------------------------------------------------------
PRINT N'-> Test 3: lectura de archivo UTF-8';

DECLARE @v_ruta NVARCHAR(200) = N'C:\Mundial2026\datos\';
DECLARE @v_archivo NVARCHAR(260) = @v_ruta + N'worldcup.teams.json';
DECLARE @v_texto NVARCHAR(MAX);

EXEC soporte.usp_Archivo_Leer @archivo = @v_archivo, @contenido = @v_texto OUTPUT;

SELECT LEN(@v_texto) AS caracteres_leidos,
       ISJSON(@v_texto) AS es_json,
       CASE WHEN ISJSON(@v_texto) = 1 AND CHARINDEX(N'Cura' + NCHAR(231) + N'ao', @v_texto) > 0
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- 4. Consumo HTTP
-- Resultado esperado: estado 200 y una respuesta JSON de la API Frankfurter.
-- Requiere conexión a internet y Ole Automation Procedures.
-------------------------------------------------------------------------------
PRINT N'-> Test 4: GET a una API publica';

DECLARE @v_respuesta NVARCHAR(MAX);
DECLARE @v_estado INT;

EXEC soporte.usp_Http_Obtener
    @url = N'https://api.frankfurter.dev/v1/latest?base=USD&symbols=EUR',
    @contenido = @v_respuesta OUTPUT,
    @estado_http = @v_estado OUTPUT;

SELECT @v_estado AS estado_http, LEFT(@v_respuesta, 200) AS respuesta,
       CASE WHEN @v_estado = 200 AND ISJSON(@v_respuesta) = 1 AND JSON_VALUE(@v_respuesta, '$.base') = N'USD'
            THEN N'PASS' ELSE N'FAIL' END AS resultado;
GO

-------------------------------------------------------------------------------
-- 5. Auditoría: iniciar, registrar un error y finalizar
-- Resultado esperado: la cabecera pasa de EN_CURSO a CON_ERROR con un error
-- registrado. Al final se eliminan con los SP de ABM para no dejar rastro.
-------------------------------------------------------------------------------
PRINT N'-> Test 5: ciclo de auditoria de una importacion';

DECLARE @v_id INT;
DECLARE @v_estado_inicial VARCHAR(10);

EXEC soporte.usp_Importacion_Iniciar
    @fuente = N'Prueba 79', @archivo = N'C:\Mundial2026\datos\prueba79.csv', @formato = 'CSV',
    @id_importacion = @v_id OUTPUT;

SELECT @v_estado_inicial = estado FROM soporte.importacion WHERE id_importacion = @v_id;

EXEC soporte.usp_Importacion_RegistrarError @v_id, 3, N'columna_prueba', N'valor', N'error de prueba';
EXEC soporte.usp_Importacion_Finalizar @v_id, @filas_leidas = 5, @filas_ok = 4, @filas_error = 1, @mostrar_resumen = 0;

SELECT i.id_importacion, @v_estado_inicial AS estado_inicial, i.estado AS estado_final,
       i.filas_leidas, i.filas_ok, i.filas_error,
       (SELECT COUNT(*) FROM soporte.importacion_error AS e WHERE e.id_importacion = i.id_importacion) AS errores,
       CASE WHEN @v_estado_inicial = 'EN_CURSO' AND i.estado = 'CON_ERROR' AND i.fecha_fin IS NOT NULL
             AND (SELECT COUNT(*) FROM soporte.importacion_error AS e WHERE e.id_importacion = i.id_importacion) = 1
            THEN N'PASS' ELSE N'FAIL' END AS resultado
FROM soporte.importacion AS i
WHERE i.id_importacion = @v_id;

EXEC soporte.usp_ImportacionError_Eliminar @id_importacion = @v_id, @nro_error = 1;
EXEC soporte.usp_Importacion_Eliminar @id_importacion = @v_id;
GO

PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS EXITOSAS: 79_Test_Importacion_Soporte_OK';
PRINT N'=====================================================================';
GO
