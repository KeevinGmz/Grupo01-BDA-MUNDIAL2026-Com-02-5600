/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Prueba exitosa del ABM de publicidad.anunciante y publicidad.campania sin dejar residuos.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT '=== 60_Test_ABM_Publicidad_OK: anunciante y campania ===';

DECLARE @v_id_pais SMALLINT;
DECLARE @v_id_anunciante INT;
DECLARE @v_id_campania INT;
DECLARE @v_identificacion_fiscal VARCHAR(30) = 'TAX-TEST-ABM-0001';
DECLARE @v_anunciantes_antes INT;
DECLARE @v_campanias_antes INT;
DECLARE @v_anunciantes_despues INT;
DECLARE @v_campanias_despues INT;

-------------------------------------------------------------------------------
-- 1. Validaciones previas
-------------------------------------------------------------------------------

IF OBJECT_ID('publicidad.usp_Anunciante_Insertar', 'P') IS NULL
   OR OBJECT_ID('publicidad.usp_Anunciante_Modificar', 'P') IS NULL
   OR OBJECT_ID('publicidad.usp_Anunciante_Eliminar', 'P') IS NULL
   OR OBJECT_ID('publicidad.usp_Campania_Insertar', 'P') IS NULL
   OR OBJECT_ID('publicidad.usp_Campania_Modificar', 'P') IS NULL
   OR OBJECT_ID('publicidad.usp_Campania_Eliminar', 'P') IS NULL
BEGIN
    ;THROW 50001,'60_Test_ABM_Publicidad_OK: faltan procedimientos ABM requeridos',1;
END;

SELECT TOP (1)
    @v_id_pais = p.id_pais
FROM geo.pais AS p
ORDER BY p.id_pais;

IF @v_id_pais IS NULL
BEGIN
    ;THROW 50001,'60_Test_ABM_Publicidad_OK: debe existir al menos un pais',1;
END;

IF EXISTS
(
    SELECT 1
    FROM publicidad.anunciante AS a
    WHERE a.identificacion_fiscal = @v_identificacion_fiscal
)
BEGIN
    ;THROW 50001,'60_Test_ABM_Publicidad_OK: existe un anunciante residual de una prueba anterior',1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    ---------------------------------------------------------------------------
    -- 2. Evidencia inicial
    ---------------------------------------------------------------------------

    SELECT @v_anunciantes_antes = COUNT(*)
    FROM publicidad.anunciante;

    SELECT @v_campanias_antes = COUNT(*)
    FROM publicidad.campania;

    PRINT '--- EVIDENCIA ANTES DE INSERTAR ---';

    SELECT
        @v_anunciantes_antes AS anunciantes_antes,
        @v_campanias_antes AS campanias_antes;

    SELECT a.*
    FROM publicidad.anunciante AS a
    WHERE a.identificacion_fiscal = @v_identificacion_fiscal;

    ---------------------------------------------------------------------------
    -- 3. Insertar anunciante
    ---------------------------------------------------------------------------

    EXEC publicidad.usp_Anunciante_Insertar
        @razon_social = 'Empresa de Prueba S.A.',
        @identificacion_fiscal = @v_identificacion_fiscal,
        @contacto = 'contacto@prueba.com',
        @id_pais = @v_id_pais,
        @id_anunciante = @v_id_anunciante OUTPUT;

    SELECT @v_anunciantes_despues = COUNT(*)
    FROM publicidad.anunciante;

    SELECT CASE
        WHEN @v_anunciantes_despues = @v_anunciantes_antes + 1
         AND EXISTS
             (
                 SELECT 1
                 FROM publicidad.anunciante AS a
                 WHERE a.id_anunciante = @v_id_anunciante
                   AND a.razon_social = 'Empresa de Prueba S.A.'
                   AND a.identificacion_fiscal = @v_identificacion_fiscal
                   AND a.contacto = 'contacto@prueba.com'
                   AND a.id_pais = @v_id_pais
             )
            THEN 'PASS anunciante insertar'
        ELSE 'FAIL anunciante insertar'
    END AS resultado;

    PRINT CONCAT
    (
        '--- EVIDENCIA DESPUES DE INSERTAR ANUNCIANTE. ID: ',
        @v_id_anunciante,
        ' ---'
    );

    SELECT a.*
    FROM publicidad.anunciante AS a
    WHERE a.id_anunciante = @v_id_anunciante;

    ---------------------------------------------------------------------------
    -- 4. Insertar campania
    ---------------------------------------------------------------------------

    EXEC publicidad.usp_Campania_Insertar
        @nombre = 'Campania Mundial Test',
        @id_anunciante = @v_id_anunciante,
        @fecha_desde = '2026-05-01',
        @fecha_hasta = '2026-07-31',
        @presupuesto = 1000000.00,
        @id_campania = @v_id_campania OUTPUT;

    SELECT @v_campanias_despues = COUNT(*)
    FROM publicidad.campania;

    SELECT CASE
        WHEN @v_campanias_despues = @v_campanias_antes + 1
         AND EXISTS
             (
                 SELECT 1
                 FROM publicidad.campania AS c
                 WHERE c.id_campania = @v_id_campania
                   AND c.nombre = 'Campania Mundial Test'
                   AND c.id_anunciante = @v_id_anunciante
                   AND c.fecha_desde = '2026-05-01'
                   AND c.fecha_hasta = '2026-07-31'
                   AND c.presupuesto = 1000000.00
             )
            THEN 'PASS campania insertar'
        ELSE 'FAIL campania insertar'
    END AS resultado;

    PRINT CONCAT
    (
        '--- EVIDENCIA DESPUES DE INSERTAR CAMPANIA. ID: ',
        @v_id_campania,
        ' ---'
    );

    SELECT c.*
    FROM publicidad.campania AS c
    WHERE c.id_campania = @v_id_campania;

    ---------------------------------------------------------------------------
    -- 5. Modificar campania y anunciante
    ---------------------------------------------------------------------------

    EXEC publicidad.usp_Campania_Modificar
        @id_campania = @v_id_campania,
        @nombre = 'Campania Mundial Test Modificada',
        @id_anunciante = @v_id_anunciante,
        @fecha_desde = '2026-05-01',
        @fecha_hasta = '2026-08-15',
        @presupuesto = 1250000.00;

    EXEC publicidad.usp_Anunciante_Modificar
        @id_anunciante = @v_id_anunciante,
        @razon_social = 'Empresa de Prueba S.A. Modificada',
        @identificacion_fiscal = @v_identificacion_fiscal,
        @contacto = 'nuevo_contacto@prueba.com',
        @id_pais = @v_id_pais;

    SELECT CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM publicidad.anunciante AS a
                 WHERE a.id_anunciante = @v_id_anunciante
                   AND a.razon_social = 'Empresa de Prueba S.A. Modificada'
                   AND a.contacto = 'nuevo_contacto@prueba.com'
                   AND a.id_pais = @v_id_pais
             )
         AND EXISTS
             (
                 SELECT 1
                 FROM publicidad.campania AS c
                 WHERE c.id_campania = @v_id_campania
                   AND c.nombre = 'Campania Mundial Test Modificada'
                   AND c.fecha_desde = '2026-05-01'
                   AND c.fecha_hasta = '2026-08-15'
                   AND c.presupuesto = 1250000.00
             )
            THEN 'PASS anunciante y campania modificar'
        ELSE 'FAIL anunciante y campania modificar'
    END AS resultado;

    PRINT '--- EVIDENCIA DESPUES DE MODIFICAR ---';

    SELECT a.*
    FROM publicidad.anunciante AS a
    WHERE a.id_anunciante = @v_id_anunciante;

    SELECT c.*
    FROM publicidad.campania AS c
    WHERE c.id_campania = @v_id_campania;

    ---------------------------------------------------------------------------
    -- 6. Eliminar en orden inverso de dependencias
    ---------------------------------------------------------------------------

    EXEC publicidad.usp_Campania_Eliminar
        @id_campania = @v_id_campania;

    EXEC publicidad.usp_Anunciante_Eliminar
        @id_anunciante = @v_id_anunciante;

    SELECT CASE
        WHEN NOT EXISTS
             (
                 SELECT 1
                 FROM publicidad.campania AS c
                 WHERE c.id_campania = @v_id_campania
             )
         AND NOT EXISTS
             (
                 SELECT 1
                 FROM publicidad.anunciante AS a
                 WHERE a.id_anunciante = @v_id_anunciante
             )
         AND (SELECT COUNT(*) FROM publicidad.campania) = @v_campanias_antes
         AND (SELECT COUNT(*) FROM publicidad.anunciante) = @v_anunciantes_antes
            THEN 'PASS campania y anunciante eliminar'
        ELSE 'FAIL campania y anunciante eliminar'
    END AS resultado;

    PRINT '--- EVIDENCIA DESPUES DE ELIMINAR ---';

    SELECT c.*
    FROM publicidad.campania AS c
    WHERE c.id_campania = @v_id_campania;

    SELECT a.*
    FROM publicidad.anunciante AS a
    WHERE a.id_anunciante = @v_id_anunciante;

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
             FROM publicidad.anunciante AS a
             WHERE a.identificacion_fiscal = 'TAX-TEST-ABM-0001'
         )
        THEN 'PASS rollback: no quedaron residuos'
    ELSE 'FAIL rollback: quedaron residuos'
END AS resultado_final;
GO
