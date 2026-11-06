/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada 
Comisión: 02-5600
Grupo : 01 
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro, Agustin
Fecha : 2026-10-03
Objetivo: Prueba exitosa de ABM para el esquema Juego (inserción y actualización de criterio de suspensión)
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT '=== 56_Test_ABM_Juego_OK: criterio_suspension, camino feliz ===';

DECLARE @v_id_tipo TINYINT;
DECLARE @v_id_criterio INT;
DECLARE @v_criterios_antes INT;
DECLARE @v_criterios_despues INT;
DECLARE @v_descripcion_tipo VARCHAR(30) = 'TEST_CRITERIO_ABM';

-------------------------------------------------------------------------------
-- 1. Validaciones previas
-------------------------------------------------------------------------------

IF OBJECT_ID('juego.usp_TipoTarjeta_Insertar', 'P') IS NULL
   OR OBJECT_ID('juego.usp_CriterioSuspension_Insertar', 'P') IS NULL
   OR OBJECT_ID('juego.usp_CriterioSuspension_Modificar', 'P') IS NULL
   OR OBJECT_ID('juego.usp_CriterioSuspension_Eliminar', 'P') IS NULL
BEGIN
    ;THROW 50001,'56_Test_ABM_Juego_OK: faltan procedimientos ABM necesarios',1;
END;

IF EXISTS
(
    SELECT 1
    FROM juego.tipo_tarjeta AS tt
    WHERE tt.descripcion = @v_descripcion_tipo
)
BEGIN
    ;THROW 50001, '56_Test_ABM_Juego_OK: existe un tipo de tarjeta residual de una prueba anterior',1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    ---------------------------------------------------------------------------
    -- 2. Crear un tipo de tarjeta exclusivo para la prueba
    ---------------------------------------------------------------------------

    EXEC juego.usp_TipoTarjeta_Insertar
        @descripcion = @v_descripcion_tipo,
        @id_tipo = @v_id_tipo OUTPUT;

    SELECT @v_criterios_antes = COUNT(*)
    FROM juego.criterio_suspension;

    PRINT '--- EVIDENCIA ANTES DE INSERTAR CRITERIO ---';

    SELECT
        @v_criterios_antes AS criterios_antes,
        @v_id_tipo AS id_tipo_prueba;

    SELECT cs.*
    FROM juego.criterio_suspension AS cs
    WHERE cs.id_tipo = @v_id_tipo;

    ---------------------------------------------------------------------------
    -- 3. Insertar criterio de suspension
    ---------------------------------------------------------------------------

    EXEC juego.usp_CriterioSuspension_Insertar
        @id_tipo = @v_id_tipo,
        @cant_tarjetas_requeridas = 5,
        @cant_partidos_suspension = 1,
        @vigente = 1,
        @id_criterio = @v_id_criterio OUTPUT;

    SELECT @v_criterios_despues = COUNT(*)
    FROM juego.criterio_suspension;

    SELECT CASE
        WHEN @v_criterios_despues = @v_criterios_antes + 1
         AND EXISTS
             (
                 SELECT 1
                 FROM juego.criterio_suspension AS cs
                 WHERE cs.id_criterio = @v_id_criterio
                   AND cs.id_tipo = @v_id_tipo
                   AND cs.cant_tarjetas_requeridas = 5
                   AND cs.cant_partidos_suspension = 1
                   AND cs.vigente = 1
             )
            THEN 'PASS criterio_suspension insertar'
        ELSE 'FAIL criterio_suspension insertar'
    END AS resultado;

    PRINT CONCAT
    (
        '--- EVIDENCIA DESPUES DE INSERTAR CRITERIO. ID: ',
        @v_id_criterio,
        ' ---'
    );

    SELECT cs.*
    FROM juego.criterio_suspension AS cs
    WHERE cs.id_criterio = @v_id_criterio;

    ---------------------------------------------------------------------------
    -- 4. Modificar criterio de suspension
    ---------------------------------------------------------------------------

    EXEC juego.usp_CriterioSuspension_Modificar
        @id_criterio = @v_id_criterio,
        @id_tipo = @v_id_tipo,
        @cant_tarjetas_requeridas = 3,
        @cant_partidos_suspension = 2,
        @vigente = 0;

    SELECT CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM juego.criterio_suspension AS cs
                 WHERE cs.id_criterio = @v_id_criterio
                   AND cs.id_tipo = @v_id_tipo
                   AND cs.cant_tarjetas_requeridas = 3
                   AND cs.cant_partidos_suspension = 2
                   AND cs.vigente = 0
             )
            THEN 'PASS criterio_suspension modificar'
        ELSE 'FAIL criterio_suspension modificar'
    END AS resultado;

    PRINT '--- EVIDENCIA DESPUES DE MODIFICAR CRITERIO ---';

    SELECT cs.*
    FROM juego.criterio_suspension AS cs
    WHERE cs.id_criterio = @v_id_criterio;

    ---------------------------------------------------------------------------
    -- 5. Eliminar criterio de suspension
    ---------------------------------------------------------------------------

    EXEC juego.usp_CriterioSuspension_Eliminar
        @id_criterio = @v_id_criterio;

    SELECT CASE
        WHEN NOT EXISTS
             (
                 SELECT 1
                 FROM juego.criterio_suspension AS cs
                 WHERE cs.id_criterio = @v_id_criterio
             )
         AND (SELECT COUNT(*) FROM juego.criterio_suspension) = @v_criterios_antes
            THEN 'PASS criterio_suspension eliminar'
        ELSE 'FAIL criterio_suspension eliminar'
    END AS resultado;

    PRINT '--- EVIDENCIA DESPUES DE ELIMINAR CRITERIO ---';

    SELECT cs.*
    FROM juego.criterio_suspension AS cs
    WHERE cs.id_criterio = @v_id_criterio;

    ---------------------------------------------------------------------------
    -- 6. Revertir toda la prueba
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
-- 7. Verificacion posterior al ROLLBACK
-------------------------------------------------------------------------------

SELECT CASE
    WHEN NOT EXISTS
         (
             SELECT 1
             FROM juego.tipo_tarjeta AS tt
             WHERE tt.descripcion = 'TEST_CRITERIO_ABM'
         )
        THEN 'PASS rollback: no quedaron residuos'
    ELSE 'FAIL rollback: quedaron residuos'
END AS resultado_final;
GO
