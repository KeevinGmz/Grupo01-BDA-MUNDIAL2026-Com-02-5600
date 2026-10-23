/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Validar el rechazo de formatos no admitidos en el ABM de soporte.importacion.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS DE ERROR: 63_Test_ABM_Soporte_ERR';
PRINT N'=====================================================================';
GO

/* =====================================================================
   CASO 1: importacion con formato fuera del dominio permitido
===================================================================== */
PRINT N'';
PRINT N'-> Test 1: insertar importacion con formato EXE';

DECLARE @v_id_importacion INT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_filas_antes INT;
DECLARE @v_filas_despues INT;
DECLARE @v_archivo NVARCHAR(260) = N'test_formato_invalido.exe';

-------------------------------------------------------------------------------
-- 1. Validaciones previas
-------------------------------------------------------------------------------

IF OBJECT_ID(N'soporte.usp_Importacion_Insertar', N'P') IS NULL
BEGIN
    ;THROW 50001, N'63_Test_ABM_Soporte_ERR: no existe soporte.usp_Importacion_Insertar',1;
END;

IF EXISTS
(
    SELECT 1
    FROM soporte.importacion AS i
    WHERE i.archivo = @v_archivo
)
BEGIN
    ;THROW 50001,N'63_Test_ABM_Soporte_ERR: existe una importacion residual de una prueba anterior',1;
END;

SELECT @v_filas_antes = COUNT(*)
FROM soporte.importacion AS i
WHERE i.archivo = @v_archivo;

-------------------------------------------------------------------------------
-- 2. Ejecutar el caso de error dentro de su propia transaccion
-------------------------------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY
    EXEC soporte.usp_Importacion_Insertar
        @fuente = N'Prueba de formato invalido',
        @archivo = @v_archivo,
        @formato = 'EXE',
        @fecha_inicio = '2026-10-03T10:00:00',
        @fecha_fin = NULL,
        @filas_leidas = 0,
        @filas_ok = 0,
        @filas_error = 0,
        @estado = 'EN_CURSO',
        @id_importacion = @v_id_importacion OUTPUT;

    SET @v_error_numero = 0;
    SET @v_error_mensaje = N'El SP no lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

SELECT @v_filas_despues = COUNT(*)
FROM soporte.importacion AS i
WHERE i.archivo = @v_archivo;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

-------------------------------------------------------------------------------
-- 3. Evidencia y evaluacion
-------------------------------------------------------------------------------

PRINT CONCAT
(
    N'Error capturado ',
    @v_error_numero,
    N': ',
    @v_error_mensaje
);

SELECT
    @v_archivo AS archivo_prueba,
    'EXE' AS formato_invalido,
    'EN_CURSO' AS estado_valido,
    @v_filas_antes AS filas_antes,
    @v_filas_despues AS filas_despues;

IF @v_error_numero = 50001
   AND
   (
       @v_error_mensaje LIKE N'%formato%invalido%'
       OR @v_error_mensaje LIKE N'%formato%CSV%JSON%XML%'
       OR @v_error_mensaje LIKE N'%formato%permitido%'
   )
   AND @v_filas_antes = 0
   AND @v_filas_despues = 0
BEGIN
    PRINT N'PASS Test 1: se rechazo el formato EXE con error 50001 y no se inserto la importacion.';
END
ELSE
BEGIN
    PRINT N'FAIL Test 1: numero, mensaje o persistencia distintos de lo esperado.';
END;
GO

-------------------------------------------------------------------------------
-- 4. Verificacion posterior al ROLLBACK
-------------------------------------------------------------------------------

SELECT CASE
    WHEN NOT EXISTS
         (
             SELECT 1
             FROM soporte.importacion AS i
             WHERE i.archivo = N'test_formato_invalido.exe'
         )
        THEN N'PASS rollback: no quedaron residuos'
    ELSE N'FAIL rollback: quedaron residuos'
END AS resultado_final;
GO

PRINT N'';
PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS DE ERROR: 63_Test_ABM_Soporte_ERR';
PRINT N'ROLLBACK EJECUTADO';
PRINT N'=====================================================================';
GO
