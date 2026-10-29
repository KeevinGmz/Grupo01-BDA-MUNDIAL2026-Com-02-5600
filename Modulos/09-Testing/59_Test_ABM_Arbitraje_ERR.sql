/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Validar la unicidad de arbitraje.designacion_arbitral:un arbitro no puede ocupar dos roles en el mismo partido.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS DE ERROR: 59_Test_ABM_Arbitraje_ERR';
PRINT N'=====================================================================';
GO

/* =====================================================================
   CASO 1: mismo arbitro, mismo partido, dos roles diferentes
===================================================================== */
PRINT N'';
PRINT N'-> Test 1: asignar al mismo arbitro dos roles en el mismo partido';

DECLARE @v_id_partido INT;
DECLARE @v_id_arbitro INT;
DECLARE @v_id_rol_1 TINYINT;
DECLARE @v_id_rol_2 TINYINT;
DECLARE @v_fecha_designacion DATETIME2(0) = SYSUTCDATETIME();
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_designaciones_antes INT;
DECLARE @v_designaciones_despues INT;

-------------------------------------------------------------------------------
-- 1. Validaciones previas
-------------------------------------------------------------------------------

IF OBJECT_ID(N'arbitraje.usp_DesignacionArbitral_Insertar', N'P') IS NULL
BEGIN
    ;THROW 50001,N'59_Test_ABM_Arbitraje_ERR: no existe arbitraje.usp_DesignacionArbitral_Insertar',1;
END;

-- Se busca una combinacion completamente valida para la preparacion:
-- dos roles libres en el mismo partido y un arbitro aun no designado alli.
SELECT TOP (1)
    @v_id_partido = p.id_partido,
    @v_id_arbitro = a.id_persona,
    @v_id_rol_1 = r1.id_rol,
    @v_id_rol_2 = r2.id_rol
FROM torneo.partido AS p
CROSS JOIN persona.arbitro AS a
CROSS JOIN arbitraje.rol_arbitral AS r1
CROSS JOIN arbitraje.rol_arbitral AS r2
WHERE r1.id_rol < r2.id_rol
  AND NOT EXISTS
      (
          SELECT 1
          FROM arbitraje.designacion_arbitral AS d
          WHERE d.id_partido = p.id_partido
            AND d.id_arbitro = a.id_persona
      )
  AND NOT EXISTS
      (
          SELECT 1
          FROM arbitraje.designacion_arbitral AS d
          WHERE d.id_partido = p.id_partido
            AND d.id_rol = r1.id_rol
      )
  AND NOT EXISTS
      (
          SELECT 1
          FROM arbitraje.designacion_arbitral AS d
          WHERE d.id_partido = p.id_partido
            AND d.id_rol = r2.id_rol
      )
ORDER BY p.id_partido, a.id_persona, r1.id_rol, r2.id_rol;

IF @v_id_partido IS NULL
   OR @v_id_arbitro IS NULL
   OR @v_id_rol_1 IS NULL
   OR @v_id_rol_2 IS NULL
BEGIN
    ;THROW 50001,N'59_Test_ABM_Arbitraje_ERR: se requiere un partido, un arbitro y dos roles libres para ejecutar la prueba',1;
END;

SELECT @v_designaciones_antes = COUNT(*)
FROM arbitraje.designacion_arbitral AS d
WHERE d.id_partido = @v_id_partido
  AND d.id_arbitro = @v_id_arbitro;

BEGIN TRANSACTION;

BEGIN TRY
    ---------------------------------------------------------------------------
    -- 2. Primera designacion valida
    ---------------------------------------------------------------------------

    EXEC arbitraje.usp_DesignacionArbitral_Insertar
        @id_partido = @v_id_partido,
        @id_rol = @v_id_rol_1,
        @id_arbitro = @v_id_arbitro,
        @fecha_designacion = @v_fecha_designacion,
        @estado = 'DESIGNADA';

    IF NOT EXISTS
    (
        SELECT 1
        FROM arbitraje.designacion_arbitral AS d
        WHERE d.id_partido = @v_id_partido
          AND d.id_rol = @v_id_rol_1
          AND d.id_arbitro = @v_id_arbitro
    )
    BEGIN
        ;THROW 50003,N'59_Test_ABM_Arbitraje_ERR: no se pudo preparar la primera designacion valida', 1;
    END;

    ---------------------------------------------------------------------------
    -- 3. Segunda designacion invalida: mismo arbitro, otro rol
    ---------------------------------------------------------------------------
    DECLARE @v_fecha2 DATETIME2(0);
    SET @v_fecha2 = DATEADD(MINUTE, 1, @v_fecha_designacion);
    BEGIN TRY
        EXEC arbitraje.usp_DesignacionArbitral_Insertar
            @id_partido = @v_id_partido,
            @id_rol = @v_id_rol_2,
            @id_arbitro = @v_id_arbitro,
            @fecha_designacion = @v_fecha2,
            @estado = 'DESIGNADA';

        SET @v_error_numero = 0;
        SET @v_error_mensaje =
            N'El SP permitio asignar al mismo arbitro dos veces en el partido';
    END TRY
    BEGIN CATCH
        SET @v_error_numero = ERROR_NUMBER();
        SET @v_error_mensaje = ERROR_MESSAGE();
    END CATCH;

    SELECT @v_designaciones_despues = COUNT(*)
    FROM arbitraje.designacion_arbitral AS d
    WHERE d.id_partido = @v_id_partido
      AND d.id_arbitro = @v_id_arbitro;

    ---------------------------------------------------------------------------
    -- 4. Evidencia y evaluacion
    ---------------------------------------------------------------------------

    PRINT CONCAT
    (
        N'Error capturado ',
        @v_error_numero,
        N': ',
        @v_error_mensaje
    );

    SELECT
        @v_id_partido AS id_partido_prueba,
        @v_id_arbitro AS id_arbitro_prueba,
        @v_id_rol_1 AS primer_rol,
        @v_id_rol_2 AS segundo_rol,
        @v_designaciones_antes AS designaciones_antes,
        @v_designaciones_despues AS designaciones_despues;

    IF @v_error_numero = 50001
       AND @v_designaciones_antes = 0
       AND @v_designaciones_despues = 1
       AND
       (
           @v_error_mensaje LIKE N'%arbitro%ya%design%'
           OR @v_error_mensaje LIKE N'%arbitro%partido%registrado%'
           OR @v_error_mensaje LIKE N'%designacion%arbitro%exist%'
           OR @v_error_mensaje LIKE N'%arbitro%ya%asignado%partido%'
       )
    BEGIN
        PRINT N'PASS Test 1: se rechazo la segunda designacion del mismo arbitro.';
    END
    ELSE
    BEGIN
        PRINT N'FAIL Test 1: numero, mensaje o cantidad de filas distintos de lo esperado.';
    END;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT CONCAT
    (
        N'FAIL de preparacion. Error ',
        ERROR_NUMBER(),
        N': ',
        ERROR_MESSAGE()
    );

    ;THROW;
END CATCH;
GO

PRINT N'';
PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS DE ERROR: 59_Test_ABM_Arbitraje_ERR';
PRINT N'ROLLBACK EJECUTADO';
PRINT N'=====================================================================';
GO
