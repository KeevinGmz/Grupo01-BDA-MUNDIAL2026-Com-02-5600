/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Prueba exitosa de la asignacion automatica de cuatro piezas publicitarias para un partido.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBA EXITOSA: 74_Test_OK_Publicidad';
PRINT N'=====================================================================';

DECLARE @v_id_partido INT;
DECLARE @v_id_sede INT;
DECLARE @v_fecha_hora_utc DATETIME2(0);
DECLARE @v_exhibiciones_antes INT;
DECLARE @v_exhibiciones_despues INT;
DECLARE @v_reemplazar BIT = 1;

-------------------------------------------------------------------------------
-- 1. Validar el procedimiento requerido
-------------------------------------------------------------------------------

IF OBJECT_ID(N'publicidad.usp_Negocio_AsignarPublicidad', N'P') IS NULL
BEGIN
    ;THROW 50001, N'74_Test_OK_Publicidad: no existe publicidad.usp_Negocio_AsignarPublicidad',1;
END;

-------------------------------------------------------------------------------
-- 2. Obtener un partido apto
-------------------------------------------------------------------------------

SELECT TOP (1)
    @v_id_partido = p.id_partido,
    @v_id_sede = p.id_sede,
    @v_fecha_hora_utc = p.fecha_hora_utc
FROM torneo.partido AS p
WHERE p.estado = 'PROGRAMADO'
  AND 4 =
      (
          SELECT COUNT(*)
          FROM publicidad.espacio_publicitario AS ep
          WHERE ep.id_sede = p.id_sede
            AND ep.nro_espacio BETWEEN 1 AND 4
      )
ORDER BY
    CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM publicidad.exhibicion AS ex
                 WHERE ex.id_partido = p.id_partido
             )
            THEN 1
        ELSE 0
    END,
    p.id_partido;

IF @v_id_partido IS NULL
BEGIN
    ;THROW 50001, N'74_Test_OK_Publicidad: se requiere un partido PROGRAMADO cuya sede tenga cuatro espacios publicitarios', 1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    ---------------------------------------------------------------------------
    -- 3. Evidencia inicial
    ---------------------------------------------------------------------------

    SELECT @v_exhibiciones_antes = COUNT(*)
    FROM publicidad.exhibicion AS e
    WHERE e.id_partido = @v_id_partido;

    PRINT N'--- EVIDENCIA ANTES DE ASIGNAR PUBLICIDAD ---';

    SELECT
        @v_id_partido AS id_partido,
        @v_id_sede AS id_sede,
        @v_fecha_hora_utc AS fecha_hora_partido,
        @v_reemplazar AS reemplazar,
        @v_exhibiciones_antes AS exhibiciones_antes;

    SELECT e.*
    FROM publicidad.exhibicion AS e
    WHERE e.id_partido = @v_id_partido
    ORDER BY e.orden_prioridad;

    ---------------------------------------------------------------------------
    -- 4. Ejecutar la asignacion automatica
    ---------------------------------------------------------------------------

    EXEC publicidad.usp_Negocio_AsignarPublicidad
        @id_partido = @v_id_partido,
        @reemplazar = @v_reemplazar;

    ---------------------------------------------------------------------------
    -- 5. Verificar las cuatro exhibiciones generadas
    ---------------------------------------------------------------------------

    SELECT @v_exhibiciones_despues = COUNT(*)
    FROM publicidad.exhibicion AS e
    WHERE e.id_partido = @v_id_partido;

    SELECT CASE
        WHEN @v_exhibiciones_despues = 4
         AND 4 =
             (
                 SELECT COUNT(DISTINCT e.nro_espacio)
                 FROM publicidad.exhibicion AS e
                 WHERE e.id_partido = @v_id_partido
             )
         AND 4 =
             (
                 SELECT COUNT(DISTINCT e.id_pieza)
                 FROM publicidad.exhibicion AS e
                 WHERE e.id_partido = @v_id_partido
             )
         AND 4 =
             (
                 SELECT COUNT(DISTINCT e.orden_prioridad)
                 FROM publicidad.exhibicion AS e
                 WHERE e.id_partido = @v_id_partido
             )
         AND NOT EXISTS
             (
                 SELECT 1
                 FROM publicidad.exhibicion AS e
                 WHERE e.id_partido = @v_id_partido
                   AND
                   (
                       e.id_sede <> @v_id_sede
                       OR e.nro_espacio NOT BETWEEN 1 AND 4
                       OR e.orden_prioridad NOT BETWEEN 1 AND 4
                       OR e.fecha_hora_emision <> @v_fecha_hora_utc
                       OR e.importe_facturado < 0
                       OR e.cotizacion_aplicada <= 0
                   )
             )
         AND NOT EXISTS
             (
                 SELECT v.nro
                 FROM (VALUES (1), (2), (3), (4)) AS v(nro)
                 WHERE NOT EXISTS
                       (
                           SELECT 1
                           FROM publicidad.exhibicion AS e
                           WHERE e.id_partido = @v_id_partido
                             AND e.nro_espacio = v.nro
                             AND e.orden_prioridad = v.nro
                       )
             )
            THEN N'PASS asignar cuatro piezas publicitarias'
        ELSE N'FAIL asignar cuatro piezas publicitarias'
    END AS resultado;

    PRINT N'--- EVIDENCIA DESPUES DE ASIGNAR PUBLICIDAD ---';

    SELECT
        e.id_exhibicion,
        e.id_partido,
        e.id_sede,
        e.nro_espacio,
        e.id_pieza,
        e.id_tarifa,
        e.fecha_hora_emision,
        e.orden_prioridad,
        e.importe_facturado,
        e.cotizacion_aplicada
    FROM publicidad.exhibicion AS e
    WHERE e.id_partido = @v_id_partido
    ORDER BY e.orden_prioridad;

    ---------------------------------------------------------------------------
    -- 6. Revertir toda la prueba
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

PRINT N'=====================================================================';
PRINT N'FIN PRUEBA EXITOSA: 74_Test_OK_Publicidad';
PRINT N'ROLLBACK EJECUTADO';
PRINT N'=====================================================================';
GO
