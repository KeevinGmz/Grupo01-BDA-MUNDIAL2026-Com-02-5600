/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Prueba exitosa del ABM de soporte.importacion y soporte.importacion_error sin dejar residuos.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT N'=== 62_Test_ABM_Soporte_OK: importacion e importacion_error ===';

DECLARE @v_id_importacion INT;
DECLARE @v_nro_error INT = 1;
DECLARE @v_importaciones_antes INT;
DECLARE @v_errores_antes INT;
DECLARE @v_importaciones_despues INT;
DECLARE @v_errores_despues INT;
DECLARE @v_archivo NVARCHAR(260) = N'test_fixture_abm.csv';

-------------------------------------------------------------------------------
-- 1. Validaciones previas
-------------------------------------------------------------------------------

IF OBJECT_ID(N'soporte.usp_Importacion_Insertar', N'P') IS NULL
   OR OBJECT_ID(N'soporte.usp_Importacion_Modificar', N'P') IS NULL
   OR OBJECT_ID(N'soporte.usp_Importacion_Eliminar', N'P') IS NULL
   OR OBJECT_ID(N'soporte.usp_ImportacionError_Insertar', N'P') IS NULL
   OR OBJECT_ID(N'soporte.usp_ImportacionError_Eliminar', N'P') IS NULL
BEGIN
    ;THROW 50001,N'62_Test_ABM_Soporte_OK: faltan uno o mas procedimientos ABM requeridos',1;
END;

IF EXISTS
(
    SELECT 1
    FROM soporte.importacion AS i
    WHERE i.archivo = @v_archivo
)
BEGIN
    ;THROW 50001,N'62_Test_ABM_Soporte_OK: existe una importacion residual de una prueba anterior', 1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    ---------------------------------------------------------------------------
    -- 2. Evidencia inicial
    ---------------------------------------------------------------------------

    SELECT @v_importaciones_antes = COUNT(*)
    FROM soporte.importacion;

    SELECT @v_errores_antes = COUNT(*)
    FROM soporte.importacion_error;

    PRINT N'--- EVIDENCIA ANTES DE INSERTAR ---';

    SELECT
        @v_importaciones_antes AS importaciones_antes,
        @v_errores_antes AS errores_antes;

    SELECT i.*
    FROM soporte.importacion AS i
    WHERE i.archivo = @v_archivo;

    ---------------------------------------------------------------------------
    -- 3. Insertar cabecera de importacion en estado EN_CURSO
    ---------------------------------------------------------------------------

    EXEC soporte.usp_Importacion_Insertar
        @fuente = N'Dataset Test',
        @archivo = @v_archivo,
        @formato = 'CSV',
        @fecha_inicio = '2026-10-03T10:00:00',
        @fecha_fin = NULL,
        @filas_leidas = 0,
        @filas_ok = 0,
        @filas_error = 0,
        @estado = 'EN_CURSO',
        @id_importacion = @v_id_importacion OUTPUT;

    SELECT @v_importaciones_despues = COUNT(*)
    FROM soporte.importacion;

    SELECT CASE
        WHEN @v_importaciones_despues = @v_importaciones_antes + 1
         AND EXISTS
             (
                 SELECT 1
                 FROM soporte.importacion AS i
                 WHERE i.id_importacion = @v_id_importacion
                   AND i.fuente = N'Dataset Test'
                   AND i.archivo = @v_archivo
                   AND i.formato = 'CSV'
                   AND i.fecha_inicio = '2026-10-03T10:00:00'
                   AND i.fecha_fin IS NULL
                   AND i.filas_leidas = 0
                   AND i.filas_ok = 0
                   AND i.filas_error = 0
                   AND i.estado = 'EN_CURSO'
             )
            THEN N'PASS importacion insertar'
        ELSE N'FAIL importacion insertar'
    END AS resultado;

    PRINT CONCAT
    (
        N'--- EVIDENCIA DESPUES DE INSERTAR IMPORTACION. ID: ',
        @v_id_importacion,
        N' ---'
    );

    SELECT i.*
    FROM soporte.importacion AS i
    WHERE i.id_importacion = @v_id_importacion;

    ---------------------------------------------------------------------------
    -- 4. Insertar detalle de error
    ---------------------------------------------------------------------------

    EXEC soporte.usp_ImportacionError_Insertar
        @id_importacion = @v_id_importacion,
        @nro_error = @v_nro_error,
        @nro_fila = 45,
        @columna = N'fecha_partido',
        @valor = N'fecha-invalida',
        @mensaje = N'Formato de fecha invalido';

    SELECT @v_errores_despues = COUNT(*)
    FROM soporte.importacion_error;

    SELECT CASE
        WHEN @v_errores_despues = @v_errores_antes + 1
         AND EXISTS
             (
                 SELECT 1
                 FROM soporte.importacion_error AS ie
                 WHERE ie.id_importacion = @v_id_importacion
                   AND ie.nro_error = @v_nro_error
                   AND ie.nro_fila = 45
                   AND ie.columna = N'fecha_partido'
                   AND ie.valor = N'fecha-invalida'
                   AND ie.mensaje = N'Formato de fecha invalido'
             )
            THEN N'PASS importacion_error insertar'
        ELSE N'FAIL importacion_error insertar'
    END AS resultado;

    PRINT N'--- EVIDENCIA DESPUES DE INSERTAR DETALLE DE ERROR ---';

    SELECT ie.*
    FROM soporte.importacion_error AS ie
    WHERE ie.id_importacion = @v_id_importacion
      AND ie.nro_error = @v_nro_error;

    ---------------------------------------------------------------------------
    -- 5. Finalizar la importacion con errores
    ---------------------------------------------------------------------------

    EXEC soporte.usp_Importacion_Modificar
        @id_importacion = @v_id_importacion,
        @fuente = N'Dataset Test Modificado',
        @archivo = @v_archivo,
        @formato = 'CSV',
        @fecha_inicio = '2026-10-03T10:00:00',
        @fecha_fin = '2026-10-03T10:05:00',
        @filas_leidas = 100,
        @filas_ok = 98,
        @filas_error = 2,
        @estado = 'CON_ERROR';

    SELECT CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM soporte.importacion AS i
                 WHERE i.id_importacion = @v_id_importacion
                   AND i.fuente = N'Dataset Test Modificado'
                   AND i.archivo = @v_archivo
                   AND i.formato = 'CSV'
                   AND i.fecha_inicio = '2026-10-03T10:00:00'
                   AND i.fecha_fin = '2026-10-03T10:05:00'
                   AND i.filas_leidas = 100
                   AND i.filas_ok = 98
                   AND i.filas_error = 2
                   AND i.estado = 'CON_ERROR'
             )
            THEN N'PASS importacion modificar'
        ELSE N'FAIL importacion modificar'
    END AS resultado;

    PRINT N'--- EVIDENCIA DESPUES DE MODIFICAR IMPORTACION ---';

    SELECT i.*
    FROM soporte.importacion AS i
    WHERE i.id_importacion = @v_id_importacion;

    ---------------------------------------------------------------------------
    -- 6. Eliminar en orden inverso para respetar la integridad referencial
    ---------------------------------------------------------------------------

    EXEC soporte.usp_ImportacionError_Eliminar
        @id_importacion = @v_id_importacion,
        @nro_error = @v_nro_error;

    EXEC soporte.usp_Importacion_Eliminar
        @id_importacion = @v_id_importacion;

    SELECT CASE
        WHEN NOT EXISTS
             (
                 SELECT 1
                 FROM soporte.importacion_error AS ie
                 WHERE ie.id_importacion = @v_id_importacion
                   AND ie.nro_error = @v_nro_error
             )
         AND NOT EXISTS
             (
                 SELECT 1
                 FROM soporte.importacion AS i
                 WHERE i.id_importacion = @v_id_importacion
             )
         AND (SELECT COUNT(*) FROM soporte.importacion_error) = @v_errores_antes
         AND (SELECT COUNT(*) FROM soporte.importacion) = @v_importaciones_antes
            THEN N'PASS importacion_error e importacion eliminar'
        ELSE N'FAIL importacion_error e importacion eliminar'
    END AS resultado;

    PRINT N'--- EVIDENCIA DESPUES DE ELIMINAR ---';

    SELECT ie.*
    FROM soporte.importacion_error AS ie
    WHERE ie.id_importacion = @v_id_importacion
      AND ie.nro_error = @v_nro_error;

    SELECT i.*
    FROM soporte.importacion AS i
    WHERE i.id_importacion = @v_id_importacion;

    ---------------------------------------------------------------------------
    -- 7. Revertir toda la prueba
    ---------------------------------------------------------------------------

    ROLLBACK TRANSACTION;

    PRINT N'PASS general: prueba finalizada y transaccion revertida.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT CONCAT
    (
        N'FAIL general. Error ',
        ERROR_NUMBER(),
        N': ',
        ERROR_MESSAGE()
    );

    ;THROW;
END CATCH;
GO

-------------------------------------------------------------------------------
-- 8. Verificacion posterior al ROLLBACK
-------------------------------------------------------------------------------

SELECT CASE
    WHEN NOT EXISTS
         (
             SELECT 1
             FROM soporte.importacion AS i
             WHERE i.archivo = N'test_fixture_abm.csv'
         )
        THEN N'PASS rollback: no quedaron residuos'
    ELSE N'FAIL rollback: quedaron residuos'
END AS resultado_final;
GO
