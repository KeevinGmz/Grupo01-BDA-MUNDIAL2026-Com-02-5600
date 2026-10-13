/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Prueba exitosa del SP de negocio para reemplazar un convocado, registrando la baja, el alta y su trazabilidad sin dejar residuos.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT N'=== 66_Test_OK_Convocatoria: reemplazar convocado ===';

DECLARE @v_id_seleccion INT;
DECLARE @v_jugador_baja INT;
DECLARE @v_jugador_alta INT;
DECLARE @v_dorsal_baja TINYINT;
DECLARE @v_dorsal_alta TINYINT;
DECLARE @v_fecha DATE = CAST(SYSUTCDATETIME() AS DATE);
DECLARE @v_motivo NVARCHAR(200) = N'Lesion grave de rodilla';
DECLARE @v_ultimo_cambio_antes INT;
DECLARE @v_convocatorias_antes INT;
DECLARE @v_convocatorias_despues INT;

-------------------------------------------------------------------------------
-- 1. Validaciones previas
-------------------------------------------------------------------------------

IF OBJECT_ID(N'torneo.usp_Negocio_ReemplazarConvocado', N'P') IS NULL
BEGIN
    ;THROW 50001, N'66_Test_OK_Convocatoria: no existe torneo.usp_Negocio_ReemplazarConvocado',1;
END;

;WITH numeros AS
(
    SELECT 1 AS nro
    UNION ALL
    SELECT nro + 1
    FROM numeros
    WHERE nro < 99
)
SELECT TOP (1)
    @v_id_seleccion = c.id_seleccion,
    @v_jugador_baja = c.id_jugador,
    @v_dorsal_baja = c.dorsal,
    @v_jugador_alta = p_alta.id_persona,
    @v_dorsal_alta = CONVERT(TINYINT, n.nro)
FROM torneo.convocatoria AS c
JOIN torneo.seleccion AS s
  ON s.id_seleccion = c.id_seleccion
JOIN persona.persona AS p_alta
  ON p_alta.id_pais = s.id_pais
 AND p_alta.tipo_persona = 'J'
JOIN persona.jugador AS j_alta
  ON j_alta.id_persona = p_alta.id_persona
CROSS JOIN numeros AS n
WHERE c.estado = 'ACTIVO'
  AND p_alta.id_persona <> c.id_jugador
  AND NOT EXISTS
      (
          SELECT 1
          FROM torneo.convocatoria AS cx
          WHERE cx.id_jugador = p_alta.id_persona
      )
  AND NOT EXISTS
      (
          SELECT 1
          FROM torneo.convocatoria AS cd
          WHERE cd.id_seleccion = c.id_seleccion
            AND cd.dorsal = n.nro
      )
ORDER BY c.id_seleccion, c.id_jugador, p_alta.id_persona, n.nro
OPTION (MAXRECURSION 100);

IF @v_id_seleccion IS NULL
   OR @v_jugador_baja IS NULL
   OR @v_jugador_alta IS NULL
   OR @v_dorsal_baja IS NULL
   OR @v_dorsal_alta IS NULL
BEGIN
    ;THROW 50001, N'66_Test_OK_Convocatoria: se requiere una seleccion con convocado activo, un jugador elegible no convocado y un dorsal libre',1;
END;

IF @v_jugador_baja = @v_jugador_alta
BEGIN
    ;THROW 50001,N'66_Test_OK_Convocatoria: los jugadores de baja y alta deben ser distintos', 1;
END;

IF @v_dorsal_baja = @v_dorsal_alta
BEGIN
    ;THROW 50001, N'66_Test_OK_Convocatoria: el dorsal del alta debe estar libre y ser distinto del dorsal retenido por la baja',1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    ---------------------------------------------------------------------------
    -- 2. Evidencia inicial
    ---------------------------------------------------------------------------

    SELECT @v_convocatorias_antes = COUNT(*)
    FROM torneo.convocatoria
    WHERE id_seleccion = @v_id_seleccion;

    SELECT @v_ultimo_cambio_antes = ISNULL(MAX(id_cambio), 0)
    FROM torneo.cambio_convocatoria;

    PRINT N'--- EVIDENCIA ANTES DE REEMPLAZAR AL CONVOCADO ---';

    SELECT
        @v_id_seleccion AS id_seleccion_prueba,
        @v_jugador_baja AS jugador_baja,
        @v_dorsal_baja AS dorsal_baja,
        @v_jugador_alta AS jugador_alta,
        @v_dorsal_alta AS dorsal_alta,
        @v_fecha AS fecha_cambio;

    SELECT c.*
    FROM torneo.convocatoria AS c
    WHERE c.id_seleccion = @v_id_seleccion
      AND c.id_jugador = @v_jugador_baja;

    SELECT c.*
    FROM torneo.convocatoria AS c
    WHERE c.id_jugador = @v_jugador_alta;

    ---------------------------------------------------------------------------
    -- 3. Ejecutar el reemplazo
    ---------------------------------------------------------------------------

    EXEC torneo.usp_Negocio_ReemplazarConvocado
        @id_seleccion = @v_id_seleccion,
        @id_jugador_baja = @v_jugador_baja,
        @id_jugador_alta = @v_jugador_alta,
        @dorsal = @v_dorsal_alta,
        @motivo = @v_motivo,
        @fecha = @v_fecha;

    ---------------------------------------------------------------------------
    -- 4. Verificar convocatoria
    ---------------------------------------------------------------------------

    SELECT @v_convocatorias_despues = COUNT(*)
    FROM torneo.convocatoria
    WHERE id_seleccion = @v_id_seleccion;

    SELECT CASE
        WHEN @v_convocatorias_despues = @v_convocatorias_antes + 1
         AND EXISTS
             (
                 SELECT 1
                 FROM torneo.convocatoria AS c
                 WHERE c.id_seleccion = @v_id_seleccion
                   AND c.id_jugador = @v_jugador_baja
                   AND c.dorsal = @v_dorsal_baja
                   AND c.estado = 'BAJA'
             )
         AND EXISTS
             (
                 SELECT 1
                 FROM torneo.convocatoria AS c
                 WHERE c.id_seleccion = @v_id_seleccion
                   AND c.id_jugador = @v_jugador_alta
                   AND c.dorsal = @v_dorsal_alta
                   AND c.estado = 'ACTIVO'
             )
            THEN N'PASS reemplazo de convocatoria'
        ELSE N'FAIL reemplazo de convocatoria'
    END AS resultado;

    ---------------------------------------------------------------------------
    -- 5. Verificar trazabilidad de BAJA y ALTA
    ---------------------------------------------------------------------------

    SELECT CASE
        WHEN 2 =
             (
                 SELECT COUNT(*)
                 FROM torneo.cambio_convocatoria AS cc
                 WHERE cc.id_cambio > @v_ultimo_cambio_antes
                   AND cc.id_seleccion = @v_id_seleccion
                   AND cc.fecha = @v_fecha
                   AND cc.motivo = @v_motivo
                   AND
                   (
                       (cc.id_jugador = @v_jugador_baja AND cc.tipo = 'BAJA')
                       OR
                       (cc.id_jugador = @v_jugador_alta AND cc.tipo = 'ALTA')
                   )
             )
            THEN N'PASS trazabilidad de baja y alta'
        ELSE N'FAIL trazabilidad de baja y alta'
    END AS resultado;

    PRINT N'--- EVIDENCIA DESPUES DEL REEMPLAZO ---';

    SELECT c.*
    FROM torneo.convocatoria AS c
    WHERE c.id_seleccion = @v_id_seleccion
      AND c.id_jugador IN (@v_jugador_baja, @v_jugador_alta)
    ORDER BY c.id_jugador;

    SELECT cc.*
    FROM torneo.cambio_convocatoria AS cc
    WHERE cc.id_cambio > @v_ultimo_cambio_antes
      AND cc.id_seleccion = @v_id_seleccion
      AND cc.id_jugador IN (@v_jugador_baja, @v_jugador_alta)
    ORDER BY cc.id_cambio;

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
