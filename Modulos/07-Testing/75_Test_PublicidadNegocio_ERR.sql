/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Validar el rechazo de una nueva asignacion de publicidad cuando el partido ya posee cuatro exhibiciones y @reemplazar = 0.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT '=====================================================================';
PRINT 'INICIO PRUEBAS DE ERROR: 75_Test_ERR_Publicidad';
PRINT '=====================================================================';
GO

/* =====================================================================
   CASO 1: partido con cuatro exhibiciones previas y @reemplazar = 0
===================================================================== */
PRINT '';
PRINT '-> Test 1: reasignar publicidad sin reemplazar un partido ya completo';

DECLARE @v_id_partido INT;
DECLARE @v_id_sede INT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje VARCHAR(2048) = NULL;
DECLARE @v_filas_antes INT;
DECLARE @v_filas_despues INT;
DECLARE @v_reemplazar_preparacion BIT = 1;
DECLARE @v_reemplazar_prueba BIT = 0;
DECLARE @v_exhibiciones_preparadas TABLE
(
    id_exhibicion INT NOT NULL,
    id_pieza INT NOT NULL,
    nro_espacio TINYINT NOT NULL,
    orden_prioridad TINYINT NOT NULL,
    PRIMARY KEY (id_exhibicion)
);

-------------------------------------------------------------------------------
-- 1. Validar el procedimiento y obtener un partido apto
-------------------------------------------------------------------------------

IF OBJECT_ID('publicidad.usp_Negocio_AsignarPublicidad', 'P') IS NULL
BEGIN
    ;THROW 50001, '75_Test_ERR_Publicidad: no existe publicidad.usp_Negocio_AsignarPublicidad',1;
END;


--Se elige un partido PROGRAMADO cuya sede tenga los cuatro espacios. .
SELECT TOP (1)
    @v_id_partido = p.id_partido,
    @v_id_sede = p.id_sede
FROM torneo.partido AS p
WHERE p.estado = 'PROGRAMADO'
  AND 4 =
      (
          SELECT COUNT(*)
          FROM publicidad.espacio_publicitario AS ep
          WHERE ep.id_sede = p.id_sede
            AND ep.nro_espacio BETWEEN 1 AND 4
      )
ORDER BY p.id_partido;

IF @v_id_partido IS NULL
BEGIN
    ;THROW 50001,'75_Test_ERR_Publicidad: se requiere un partido PROGRAMADO cuya sede tenga cuatro espacios publicitarios', 1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    ---------------------------------------------------------------------------
    -- 2. Preparar la precondicion: cuatro exhibiciones completas
    ---------------------------------------------------------------------------

    EXEC publicidad.usp_Negocio_AsignarPublicidad
        @id_partido = @v_id_partido,
        @reemplazar = @v_reemplazar_preparacion;

    SELECT @v_filas_antes = COUNT(*)
    FROM publicidad.exhibicion AS e
    WHERE e.id_partido = @v_id_partido;

    IF @v_filas_antes <> 4
    BEGIN
        ;THROW 50001,'75_Test_ERR_Publicidad: la preparacion no genero exactamente cuatro exhibiciones', 1;
    END;

    INSERT INTO @v_exhibiciones_preparadas
        (id_exhibicion, id_pieza, nro_espacio, orden_prioridad)
    SELECT
        e.id_exhibicion,
        e.id_pieza,
        e.nro_espacio,
        e.orden_prioridad
    FROM publicidad.exhibicion AS e
    WHERE e.id_partido = @v_id_partido;

    PRINT '--- EVIDENCIA ANTES DEL INTENTO INVALIDO ---';

    SELECT
        @v_id_partido AS id_partido,
        @v_id_sede AS id_sede,
        @v_filas_antes AS exhibiciones_antes,
        @v_reemplazar_prueba AS reemplazar_en_prueba;

    SELECT e.*
    FROM publicidad.exhibicion AS e
    WHERE e.id_partido = @v_id_partido
    ORDER BY e.orden_prioridad;

    ---------------------------------------------------------------------------
    -- 3. Intentar una nueva asignacion sin permitir reemplazo
    ---------------------------------------------------------------------------

    BEGIN TRY
        EXEC publicidad.usp_Negocio_AsignarPublicidad
            @id_partido = @v_id_partido,
            @reemplazar = @v_reemplazar_prueba;

        SET @v_error_numero = 0;
        SET @v_error_mensaje =
            'El SP permitio reasignar publicidad sin habilitar el reemplazo';
    END TRY
    BEGIN CATCH
        SET @v_error_numero = ERROR_NUMBER();
        SET @v_error_mensaje = ERROR_MESSAGE();
    END CATCH;

    SELECT @v_filas_despues = COUNT(*)
    FROM publicidad.exhibicion AS e
    WHERE e.id_partido = @v_id_partido;

    ---------------------------------------------------------------------------
    -- 4. Evaluar antes del rollback
    ---------------------------------------------------------------------------

    PRINT CONCAT('Error capturado ', @v_error_numero, ': ', @v_error_mensaje);

    IF @v_error_numero IN (50001, 50003)
       AND
       (
           @v_error_mensaje LIKE '%exhibicion%previa%'
           OR @v_error_mensaje LIKE '%publicidad%asignada%'
           OR @v_error_mensaje LIKE '%reemplaz%'
           OR @v_error_mensaje LIKE '%cuatro%exhibicion%'
           OR @v_error_mensaje LIKE '%4%exhibicion%'
       )
       AND @v_filas_despues = 4
       AND NOT EXISTS
           (
               SELECT 1
               FROM @v_exhibiciones_preparadas AS p
               WHERE NOT EXISTS
                     (
                         SELECT 1
                         FROM publicidad.exhibicion AS e
                         WHERE e.id_partido = @v_id_partido
                           AND e.id_exhibicion = p.id_exhibicion
                           AND e.id_pieza = p.id_pieza
                           AND e.nro_espacio = p.nro_espacio
                           AND e.orden_prioridad = p.orden_prioridad
                     )
           )
    BEGIN
        PRINT 'PASS Test 1: se rechazo la reasignacion y se conservaron las cuatro exhibiciones.';
    END
    ELSE
    BEGIN
        PRINT 'FAIL Test 1: numero, mensaje o persistencia distintos de lo esperado.';
    END;

    ROLLBACK TRANSACTION;
    PRINT 'ROLLBACK ejecutado: la base queda sin cambios de la prueba.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT CONCAT
    (
        'FAIL de preparacion. Error ',
        ERROR_NUMBER(),
        ': ',
        ERROR_MESSAGE()
    );

    ;THROW;
END CATCH;
GO

PRINT '';
PRINT '=====================================================================';
PRINT 'FIN PRUEBAS DE ERROR: 75_Test_ERR_Publicidad';
PRINT '=====================================================================';
GO
