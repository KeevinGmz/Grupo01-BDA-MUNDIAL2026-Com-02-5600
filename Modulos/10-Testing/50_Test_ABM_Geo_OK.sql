/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Prueba exitosa de ABM para el esquema Geo (insertar, modificar y eliminar pais, ciudad, indicador_pais)
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT '=== 50_Test_ABM_Geo_OK: camino feliz ===';

DECLARE @v_id_confederacion TINYINT;
DECLARE @v_id_huso SMALLINT;
DECLARE @v_id_pais SMALLINT;
DECLARE @v_id_ciudad INT;
DECLARE @v_anio SMALLINT = 2026;
DECLARE @v_codigo_indicador VARCHAR(30) = 'SP.POP.TOTL';
DECLARE @v_antes_pais INT;
DECLARE @v_despues_pais INT;
DECLARE @v_antes_indicador INT;
DECLARE @v_despues_indicador INT;
DECLARE @v_antes_ciudad INT;
DECLARE @v_despues_ciudad INT;

-------------------------------------------------------------------------------
-- 1. Validaciones previas del entorno
-------------------------------------------------------------------------------

SELECT TOP (1)
    @v_id_confederacion = c.id_confederacion
FROM geo.confederacion AS c
ORDER BY c.id_confederacion;

SELECT TOP (1)
    @v_id_huso = h.id_huso
FROM geo.huso_horario AS h
ORDER BY h.id_huso;

IF @v_id_confederacion IS NULL
BEGIN
    ;THROW 50001,
           '50_Test_ABM_Geo_OK: debe existir al menos una confederacion para ejecutar la prueba',
           1;
END;

IF @v_id_huso IS NULL
BEGIN
    ;THROW 50001,
           '50_Test_ABM_Geo_OK: debe existir al menos un huso horario para ejecutar la prueba',
           1;
END;

IF OBJECT_ID('geo.usp_Pais_Insertar', 'P') IS NULL
   OR OBJECT_ID('geo.usp_Pais_Modificar', 'P') IS NULL
   OR OBJECT_ID('geo.usp_Pais_Eliminar', 'P') IS NULL
   OR OBJECT_ID('geo.usp_IndicadorPais_Insertar', 'P') IS NULL
   OR OBJECT_ID('geo.usp_IndicadorPais_Modificar', 'P') IS NULL
   OR OBJECT_ID('geo.usp_IndicadorPais_Eliminar', 'P') IS NULL
   OR OBJECT_ID('geo.usp_Ciudad_Insertar', 'P') IS NULL
   OR OBJECT_ID('geo.usp_Ciudad_Modificar', 'P') IS NULL
   OR OBJECT_ID('geo.usp_Ciudad_Eliminar', 'P') IS NULL
BEGIN
    ;THROW 50001,
           '50_Test_ABM_Geo_OK: faltan uno o mas procedimientos ABM del esquema geo',
           1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    ---------------------------------------------------------------------------
    -- 2. Evidencia inicial
    ---------------------------------------------------------------------------

    SELECT @v_antes_pais = COUNT(*)
    FROM geo.pais;

    SELECT @v_antes_indicador = COUNT(*)
    FROM geo.indicador_pais;

    SELECT @v_antes_ciudad = COUNT(*)
    FROM geo.ciudad;

    PRINT '--- EVIDENCIA ANTES DE INSERTAR ---';

    SELECT
        @v_antes_pais AS paises_antes,
        @v_antes_indicador AS indicadores_antes,
        @v_antes_ciudad AS ciudades_antes;

    ---------------------------------------------------------------------------
    -- 3. Insertar pais
    ---------------------------------------------------------------------------

    EXEC geo.usp_Pais_Insertar
        @nombre = 'Pais de Prueba',
        @cod_iso3 = 'TST',
        @cod_fifa = 'TST',
        @gentilicio = 'testiano',
        @id_confederacion = @v_id_confederacion,
        @id_pais = @v_id_pais OUTPUT;

    SELECT @v_despues_pais = COUNT(*)
    FROM geo.pais;

    SELECT CASE
        WHEN @v_despues_pais = @v_antes_pais + 1
         AND EXISTS
             (
                 SELECT 1
                 FROM geo.pais
                 WHERE id_pais = @v_id_pais
                   AND nombre = 'Pais de Prueba'
                   AND cod_iso3 = 'TST'
             )
            THEN 'PASS pais insertar'
        ELSE 'FAIL pais insertar'
    END;

    SELECT *
    FROM geo.pais
    WHERE id_pais = @v_id_pais;

    ---------------------------------------------------------------------------
    -- 4. Insertar indicador de pais
    --
    -- El modelo final no guarda poblacion y PBI en columnas separadas.
    -- Cada indicador es una fila identificada por pais, anio y codigo.
    ---------------------------------------------------------------------------

    EXEC geo.usp_IndicadorPais_Insertar
        @id_pais = @v_id_pais,
        @anio = @v_anio,
        @codigo_indicador = @v_codigo_indicador,
        @valor = 1000000.00;

    SELECT @v_despues_indicador = COUNT(*)
    FROM geo.indicador_pais;

    SELECT CASE
        WHEN @v_despues_indicador = @v_antes_indicador + 1
         AND EXISTS
             (
                 SELECT 1
                 FROM geo.indicador_pais
                 WHERE id_pais = @v_id_pais
                   AND anio = @v_anio
                   AND codigo_indicador = @v_codigo_indicador
                   AND valor = 1000000.00
             )
            THEN 'PASS indicador_pais insertar'
        ELSE 'FAIL indicador_pais insertar'
    END;

    SELECT *
    FROM geo.indicador_pais
    WHERE id_pais = @v_id_pais
      AND anio = @v_anio
      AND codigo_indicador = @v_codigo_indicador;

    ---------------------------------------------------------------------------
    -- 5. Insertar ciudad
    ---------------------------------------------------------------------------

    EXEC geo.usp_Ciudad_Insertar
        @nombre = 'Ciudad de Prueba',
        @poblacion = 500000,
        @id_pais = @v_id_pais,
        @id_huso = @v_id_huso,
        @id_ciudad = @v_id_ciudad OUTPUT;

    SELECT @v_despues_ciudad = COUNT(*)
    FROM geo.ciudad;

    SELECT CASE
        WHEN @v_despues_ciudad = @v_antes_ciudad + 1
         AND EXISTS
             (
                 SELECT 1
                 FROM geo.ciudad
                 WHERE id_ciudad = @v_id_ciudad
                   AND nombre = 'Ciudad de Prueba'
                   AND id_pais = @v_id_pais
                   AND id_huso = @v_id_huso
             )
            THEN 'PASS ciudad insertar'
        ELSE 'FAIL ciudad insertar'
    END;

    SELECT *
    FROM geo.ciudad
    WHERE id_ciudad = @v_id_ciudad;

    ---------------------------------------------------------------------------
    -- 6. Modificar las tres entidades
    ---------------------------------------------------------------------------

    EXEC geo.usp_Pais_Modificar
        @id_pais = @v_id_pais,
        @nombre = 'Pais de Prueba Modificado',
        @cod_iso3 = 'TST',
        @cod_fifa = 'TST',
        @gentilicio = 'testiano modificado',
        @id_confederacion = @v_id_confederacion;

    SELECT CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM geo.pais
                 WHERE id_pais = @v_id_pais
                   AND nombre = 'Pais de Prueba Modificado'
                   AND gentilicio = 'testiano modificado'
             )
            THEN 'PASS pais modificar'
        ELSE 'FAIL pais modificar'
    END;

    EXEC geo.usp_IndicadorPais_Modificar
        @id_pais = @v_id_pais,
        @anio = @v_anio,
        @codigo_indicador = @v_codigo_indicador,
        @valor = 2000000.00;

    SELECT CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM geo.indicador_pais
                 WHERE id_pais = @v_id_pais
                   AND anio = @v_anio
                   AND codigo_indicador = @v_codigo_indicador
                   AND valor = 2000000.00
             )
            THEN 'PASS indicador_pais modificar'
        ELSE 'FAIL indicador_pais modificar'
    END;

    EXEC geo.usp_Ciudad_Modificar
        @id_ciudad = @v_id_ciudad,
        @nombre = 'Ciudad de Prueba Modificada',
        @poblacion = 600000,
        @id_pais = @v_id_pais,
        @id_huso = @v_id_huso;

    SELECT CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM geo.ciudad
                 WHERE id_ciudad = @v_id_ciudad
                   AND nombre = 'Ciudad de Prueba Modificada'
                   AND poblacion = 600000
             )
            THEN 'PASS ciudad modificar'
        ELSE 'FAIL ciudad modificar'
    END;

    PRINT '--- EVIDENCIA DESPUES DE MODIFICAR ---';

    SELECT * FROM geo.pais WHERE id_pais = @v_id_pais;

    SELECT *
    FROM geo.indicador_pais
    WHERE id_pais = @v_id_pais
      AND anio = @v_anio
      AND codigo_indicador = @v_codigo_indicador;

    SELECT * FROM geo.ciudad WHERE id_ciudad = @v_id_ciudad;

    ---------------------------------------------------------------------------
    -- 7. Eliminar en orden inverso de dependencias
    ---------------------------------------------------------------------------

    EXEC geo.usp_Ciudad_Eliminar
        @id_ciudad = @v_id_ciudad;

    SELECT CASE
        WHEN NOT EXISTS
             (
                 SELECT 1
                 FROM geo.ciudad
                 WHERE id_ciudad = @v_id_ciudad
             )
            THEN 'PASS ciudad eliminar'
        ELSE 'FAIL ciudad eliminar'
    END;

    EXEC geo.usp_IndicadorPais_Eliminar
        @id_pais = @v_id_pais,
        @anio = @v_anio,
        @codigo_indicador = @v_codigo_indicador;

    SELECT CASE
        WHEN NOT EXISTS
             (
                 SELECT 1
                 FROM geo.indicador_pais
                 WHERE id_pais = @v_id_pais
                   AND anio = @v_anio
                   AND codigo_indicador = @v_codigo_indicador
             )
            THEN 'PASS indicador_pais eliminar'
        ELSE 'FAIL indicador_pais eliminar'
    END;

    EXEC geo.usp_Pais_Eliminar
        @id_pais = @v_id_pais;

    SELECT CASE
        WHEN NOT EXISTS
             (
                 SELECT 1
                 FROM geo.pais
                 WHERE id_pais = @v_id_pais
             )
            THEN 'PASS pais eliminar'
        ELSE 'FAIL pais eliminar'
    END;

    PRINT '--- EVIDENCIA DESPUES DE ELIMINAR ---';

    SELECT * FROM geo.ciudad WHERE id_ciudad = @v_id_ciudad;

    SELECT *
    FROM geo.indicador_pais
    WHERE id_pais = @v_id_pais
      AND anio = @v_anio
      AND codigo_indicador = @v_codigo_indicador;

    SELECT * FROM geo.pais WHERE id_pais = @v_id_pais;

    ---------------------------------------------------------------------------
    -- 8. La prueba siempre revierte para no dejar residuos
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
-- 9. Verificacion posterior al ROLLBACK
-------------------------------------------------------------------------------

SELECT
    CASE
        WHEN NOT EXISTS
             (
                 SELECT 1
                 FROM geo.pais
                 WHERE cod_iso3 = 'TST'
             )
            THEN 'PASS rollback: no quedaron residuos'
        ELSE 'FAIL rollback: quedaron residuos'
    END AS resultado_final;
GO
