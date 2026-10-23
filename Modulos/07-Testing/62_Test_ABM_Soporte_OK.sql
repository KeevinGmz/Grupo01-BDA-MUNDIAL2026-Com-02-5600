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

PRINT '=== 62_Test_ABM_Soporte_OK: importacion e importacion_error ===';

DECLARE @v_id_importacion INT;
DECLARE @v_nro_error INT = 1;
DECLARE @v_importaciones_antes INT;
DECLARE @v_errores_antes INT;
DECLARE @v_importaciones_despues INT;
DECLARE @v_errores_despues INT;
DECLARE @v_archivo VARCHAR(260) = 'test_fixture_abm.csv';

-------------------------------------------------------------------------------
-- 1. Validaciones previas
-------------------------------------------------------------------------------

IF OBJECT_ID('soporte.usp_Importacion_Insertar', 'P') IS NULL
   OR OBJECT_ID('soporte.usp_Importacion_Modificar', 'P') IS NULL
   OR OBJECT_ID('soporte.usp_Importacion_Eliminar', 'P') IS NULL
   OR OBJECT_ID('soporte.usp_ImportacionError_Insertar', 'P') IS NULL
   OR OBJECT_ID('soporte.usp_ImportacionError_Eliminar', 'P') IS NULL
BEGIN
    ;THROW 50001,'62_Test_ABM_Soporte_OK: faltan uno o mas procedimientos ABM requeridos',1;
END;

IF EXISTS
(
    SELECT 1
    FROM soporte.importacion AS i
    WHERE i.archivo = @v_archivo
)
BEGIN
    ;THROW 50001,'62_Test_ABM_Soporte_OK: existe una importacion residual de una prueba anterior', 1;
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

    PRINT '--- EVIDENCIA ANTES DE INSERTAR ---';

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
        @fuente = 'Dataset Test',
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
                   AND i.fuente = 'Dataset Test'
                   AND i.archivo = @v_archivo
                   AND i.formato = 'CSV'
                   AND i.fecha_inicio = '2026-10-03T10:00:00'
                   AND i.fecha_fin IS NULL
                   AND i.filas_leidas = 0
                   AND i.filas_ok = 0
                   AND i.filas_error = 0
                   AND i.estado = 'EN_CURSO'
             )
            THEN 'PASS importacion insertar'
        ELSE 'FAIL importacion insertar'
    END AS resultado;

    PRINT CONCAT
    (
        '--- EVIDENCIA DESPUES DE INSERTAR IMPORTACION. ID: ',
        @v_id_importacion,
        ' ---'
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
        @columna = 'fecha_partido',
        @valor = 'fecha-invalida',
        @mensaje = 'Formato de fecha invalido';

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
                   AND ie.columna = 'fecha_partido'
                   AND ie.valor = 'fecha-invalida'
                   AND ie.mensaje = 'Formato de fecha invalido'
             )
            THEN 'PASS importacion_error insertar'
        ELSE 'FAIL importacion_error insertar'
    END AS resultado;

    PRINT '--- EVIDENCIA DESPUES DE INSERTAR DETALLE DE ERROR ---';

    SELECT ie.*
    FROM soporte.importacion_error AS ie
    WHERE ie.id_importacion = @v_id_importacion
      AND ie.nro_error = @v_nro_error;

    ---------------------------------------------------------------------------
    -- 5. Finalizar la importacion con errores
    ---------------------------------------------------------------------------

    EXEC soporte.usp_Importacion_Modificar
        @id_importacion = @v_id_importacion,
        @fuente = 'Dataset Test Modificado',
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
                   AND i.fuente = 'Dataset Test Modificado'
                   AND i.archivo = @v_archivo
                   AND i.formato = 'CSV'
                   AND i.fecha_inicio = '2026-10-03T10:00:00'
                   AND i.fecha_fin = '2026-10-03T10:05:00'
                   AND i.filas_leidas = 100
                   AND i.filas_ok = 98
                   AND i.filas_error = 2
                   AND i.estado = 'CON_ERROR'
             )
            THEN 'PASS importacion modificar'
        ELSE 'FAIL importacion modificar'
    END AS resultado;

    PRINT '--- EVIDENCIA DESPUES DE MODIFICAR IMPORTACION ---';

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
            THEN 'PASS importacion_error e importacion eliminar'
        ELSE 'FAIL importacion_error e importacion eliminar'
    END AS resultado;

    PRINT '--- EVIDENCIA DESPUES DE ELIMINAR ---';

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

    PRINT 'PASS general: prueba finalizada y transaccion revertida.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT CONCAT
    (
        'FAIL general. Error ',
        ERROR_NUMBER(),
        ': ',
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
             WHERE i.archivo = 'test_fixture_abm.csv'
         )
        THEN 'PASS rollback: no quedaron residuos'
    ELSE 'FAIL rollback: quedaron residuos'
END AS resultado_final;
GO
