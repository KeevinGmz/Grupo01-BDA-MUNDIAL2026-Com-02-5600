/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada 
Comisión: 02-5600
Grupo : 01  
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro, Agustin
Fecha : 2026-10-03
Objetivo: Prueba exitosa de ABM para el esquema Arbitraje (registro de informe post partido)
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT '=== 58_Test_ABM_Arbitraje_OK: informe_post_partido, camino feliz ===';

DECLARE @v_id_informe INT;
DECLARE @v_informes_antes INT;
DECLARE @v_informes_despues INT;
DECLARE @v_fecha_informe DATETIME2(0) = '2026-06-12T20:00:00';
DECLARE @v_descripcion VARCHAR(1000) =
    'Informe Test ABM Arbitraje: detalle disciplinario de prueba.';

-------------------------------------------------------------------------------
-- 1. Validaciones previas
-------------------------------------------------------------------------------

IF OBJECT_ID('arbitraje.usp_InformePostPartido_Insertar', 'P') IS NULL
   OR OBJECT_ID('arbitraje.usp_InformePostPartido_Modificar', 'P') IS NULL
   OR OBJECT_ID('arbitraje.usp_InformePostPartido_Eliminar', 'P') IS NULL
BEGIN
    ;THROW 50001,'58_Test_ABM_Arbitraje_OK: faltan procedimientos ABM de informe_post_partido',1;
END;

IF EXISTS
(
    SELECT 1
    FROM arbitraje.informe_post_partido AS i
    WHERE i.descripcion = @v_descripcion
)
BEGIN
    ;THROW 50001,'58_Test_ABM_Arbitraje_OK: existe un informe residual de una prueba anterior',1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    ---------------------------------------------------------------------------
    -- 2. Evidencia inicial
    ---------------------------------------------------------------------------

    SELECT @v_informes_antes = COUNT(*)
    FROM arbitraje.informe_post_partido;

    PRINT '--- EVIDENCIA ANTES DE INSERTAR INFORME ---';

    SELECT @v_informes_antes AS informes_antes;

    SELECT i.*
    FROM arbitraje.informe_post_partido AS i
    WHERE i.descripcion = @v_descripcion;

    ---------------------------------------------------------------------------
    -- 3. Insertar informe
    ---------------------------------------------------------------------------

    EXEC arbitraje.usp_InformePostPartido_Insertar
        @fecha_informe = @v_fecha_informe,
        @tipo = 'DISCIPLINARIO',
        @descripcion = @v_descripcion,
        @sancion_aplicada = '1 partido de suspension',
        @id_informe = @v_id_informe OUTPUT;

    SELECT @v_informes_despues = COUNT(*)
    FROM arbitraje.informe_post_partido;

    SELECT CASE
        WHEN @v_informes_despues = @v_informes_antes + 1
         AND EXISTS
             (
                 SELECT 1
                 FROM arbitraje.informe_post_partido AS i
                 WHERE i.id_informe = @v_id_informe
                   AND i.fecha_informe = @v_fecha_informe
                   AND i.tipo = 'DISCIPLINARIO'
                   AND i.descripcion = @v_descripcion
                   AND i.sancion_aplicada = '1 partido de suspension'
             )
            THEN 'PASS informe_post_partido insertar'
        ELSE 'FAIL informe_post_partido insertar'
    END AS resultado;

    PRINT CONCAT
    (
        '--- EVIDENCIA DESPUES DE INSERTAR INFORME. ID: ',
        @v_id_informe,
        ' ---'
    );

    SELECT i.*
    FROM arbitraje.informe_post_partido AS i
    WHERE i.id_informe = @v_id_informe;

    ---------------------------------------------------------------------------
    -- 4. Modificar informe
    ---------------------------------------------------------------------------

    EXEC arbitraje.usp_InformePostPartido_Modificar
        @id_informe = @v_id_informe,
        @fecha_informe = '2026-06-12T21:30:00',
        @tipo = 'DISCIPLINARIO',
        @descripcion = 'Informe Test ABM Arbitraje modificado con pruebas de video.',
        @sancion_aplicada = '2 partidos de suspension';

    SELECT CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM arbitraje.informe_post_partido AS i
                 WHERE i.id_informe = @v_id_informe
                   AND i.fecha_informe = '2026-06-12T21:30:00'
                   AND i.tipo = 'DISCIPLINARIO'
                   AND i.descripcion = 'Informe Test ABM Arbitraje modificado con pruebas de video.'
                   AND i.sancion_aplicada = '2 partidos de suspension'
             )
            THEN 'PASS informe_post_partido modificar'
        ELSE 'FAIL informe_post_partido modificar'
    END AS resultado;

    PRINT '--- EVIDENCIA DESPUES DE MODIFICAR INFORME ---';

    SELECT i.*
    FROM arbitraje.informe_post_partido AS i
    WHERE i.id_informe = @v_id_informe;

    ---------------------------------------------------------------------------
    -- 5. Eliminar informe
    ---------------------------------------------------------------------------

    EXEC arbitraje.usp_InformePostPartido_Eliminar
        @id_informe = @v_id_informe;

    SELECT CASE
        WHEN NOT EXISTS
             (
                 SELECT 1
                 FROM arbitraje.informe_post_partido AS i
                 WHERE i.id_informe = @v_id_informe
             )
         AND (SELECT COUNT(*) FROM arbitraje.informe_post_partido) = @v_informes_antes
            THEN 'PASS informe_post_partido eliminar'
        ELSE 'FAIL informe_post_partido eliminar'
    END AS resultado;

    PRINT '--- EVIDENCIA DESPUES DE ELIMINAR INFORME ---';

    SELECT i.*
    FROM arbitraje.informe_post_partido AS i
    WHERE i.id_informe = @v_id_informe;

    ---------------------------------------------------------------------------
    -- 6. Revertir la prueba
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
             FROM arbitraje.informe_post_partido AS i
             WHERE i.descripcion LIKE 'Informe Test ABM Arbitraje%'
         )
        THEN 'PASS rollback: no quedaron residuos'
    ELSE 'FAIL rollback: quedaron residuos'
END AS resultado_final;
GO
