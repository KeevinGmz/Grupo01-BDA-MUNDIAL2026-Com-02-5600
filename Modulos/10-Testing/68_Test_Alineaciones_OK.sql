/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Prueba exitosa del SP de negocio para registrar una alineacion mediante el Table-Valued Parameter juego.tt_Alineacion.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT '=====================================================================';
PRINT 'INICIO PRUEBA EXITOSA: 68_Test_OK_Alineacion';
PRINT '=====================================================================';

DECLARE @v_id_partido INT;
DECLARE @v_id_seleccion INT;
DECLARE @v_cantidad_convocados INT;
DECLARE @v_alineados_antes INT;
DECLARE @v_alineados_despues INT;
DECLARE @v_titulares_despues INT;
DECLARE @v_esquema_original VARCHAR(10);
DECLARE @v_esquema_prueba VARCHAR(10) = '4-3-3';
DECLARE @v_alineacion juego.tt_Alineacion;

-------------------------------------------------------------------------------
-- 1. Validaciones previas
-------------------------------------------------------------------------------

IF OBJECT_ID('juego.usp_Negocio_RegistrarAlineacion', 'P') IS NULL
BEGIN
    ;THROW 50001,'68_Test_OK_Alineacion: no existe juego.usp_Negocio_RegistrarAlineacion',1;
END;

IF TYPE_ID('juego.tt_Alineacion') IS NULL
BEGIN
    ;THROW 50001,'68_Test_OK_Alineacion: no existe el tipo juego.tt_Alineacion',1;
END;

SELECT TOP (1)
    @v_id_partido = ep.id_partido,
    @v_id_seleccion = ep.id_seleccion,
    @v_esquema_original = ep.esquema_tactico,
    @v_cantidad_convocados = COUNT(*)
FROM torneo.equipo_en_partido AS ep
JOIN torneo.convocatoria AS c
  ON c.id_seleccion = ep.id_seleccion
 AND c.estado = 'ACTIVO'
JOIN persona.jugador AS j
  ON j.id_persona = c.id_jugador
WHERE NOT EXISTS
      (
          SELECT 1
          FROM juego.alineacion AS a
          WHERE a.id_partido = ep.id_partido
            AND a.id_seleccion = ep.id_seleccion
      )
GROUP BY
    ep.id_partido,
    ep.id_seleccion,
    ep.esquema_tactico
HAVING COUNT(*) >= 11
ORDER BY ep.id_partido, ep.id_seleccion;

IF @v_id_partido IS NULL
   OR @v_id_seleccion IS NULL
   OR @v_cantidad_convocados < 11
BEGIN
    ;THROW 50001,'68_Test_OK_Alineacion: se requiere un equipo en un partido, sin alineacion previa y con al menos 11 convocados activos',1;
END;

-------------------------------------------------------------------------------
-- 2. Armar el TVP
-------------------------------------------------------------------------------

;WITH convocados AS
(
    SELECT
        c.id_jugador,
        c.dorsal,
        j.id_posicion_habitual AS id_posicion,
        ROW_NUMBER() OVER
        (
            ORDER BY c.dorsal, c.id_jugador
        ) AS rn
    FROM torneo.convocatoria AS c
    JOIN persona.jugador AS j
      ON j.id_persona = c.id_jugador
    WHERE c.id_seleccion = @v_id_seleccion
      AND c.estado = 'ACTIVO'
)
INSERT INTO @v_alineacion
(
    id_jugador,
    dorsal,
    es_titular,
    id_posicion,
    es_posicion_habitual
)
SELECT
    c.id_jugador,
    c.dorsal,
    CONVERT(BIT, CASE WHEN c.rn <= 11 THEN 1 ELSE 0 END),
    c.id_posicion,
    CONVERT(BIT, 1)
FROM convocados AS c;

IF (SELECT COUNT(*) FROM @v_alineacion) <> @v_cantidad_convocados
BEGIN
    ;THROW 50001,'68_Test_OK_Alineacion: el TVP no contiene todos los convocados activos',1;
END;

IF (SELECT COUNT(*) FROM @v_alineacion WHERE es_titular = 1) <> 11
BEGIN
    ;THROW 50001, '68_Test_OK_Alineacion: el TVP debe contener exactamente 11 titulares',1;
END;

SELECT @v_alineados_antes = COUNT(*)
FROM juego.alineacion AS a
WHERE a.id_partido = @v_id_partido
  AND a.id_seleccion = @v_id_seleccion;

PRINT '--- EVIDENCIA ANTES DE REGISTRAR LA ALINEACION ---';

SELECT
    @v_id_partido AS id_partido_prueba,
    @v_id_seleccion AS id_seleccion_prueba,
    @v_cantidad_convocados AS convocados_enviados,
    @v_alineados_antes AS alineados_antes,
    @v_esquema_original AS esquema_original,
    @v_esquema_prueba AS esquema_prueba;

SELECT tvp.*
FROM @v_alineacion AS tvp
ORDER BY tvp.es_titular DESC, tvp.dorsal, tvp.id_jugador;

-------------------------------------------------------------------------------
-- 3. Ejecutar el caso exitoso
-------------------------------------------------------------------------------

BEGIN TRY
    BEGIN TRANSACTION;

    EXEC juego.usp_Negocio_RegistrarAlineacion
        @id_partido = @v_id_partido,
        @id_seleccion = @v_id_seleccion,
        @esquema_tactico = @v_esquema_prueba,
        @alineacion = @v_alineacion;

    ---------------------------------------------------------------------------
    -- 4. Verificar persistencia y actualización del esquema
    ---------------------------------------------------------------------------

    SELECT @v_alineados_despues = COUNT(*),
           @v_titulares_despues = SUM(CASE WHEN a.es_titular = 1 THEN 1 ELSE 0 END)
    FROM juego.alineacion AS a
    WHERE a.id_partido = @v_id_partido
      AND a.id_seleccion = @v_id_seleccion;

    SELECT CASE
        WHEN @v_alineados_antes = 0
         AND @v_alineados_despues = @v_cantidad_convocados
         AND @v_titulares_despues = 11
         AND NOT EXISTS
             (
                 SELECT 1
                 FROM @v_alineacion AS tvp
                 WHERE NOT EXISTS
                       (
                           SELECT 1
                           FROM juego.alineacion AS a
                           WHERE a.id_partido = @v_id_partido
                             AND a.id_seleccion = @v_id_seleccion
                             AND a.id_jugador = tvp.id_jugador
                             AND a.dorsal = tvp.dorsal
                             AND a.es_titular = tvp.es_titular
                             AND a.id_posicion = tvp.id_posicion
                             AND a.es_posicion_habitual = tvp.es_posicion_habitual
                       )
             )
         AND EXISTS
             (
                 SELECT 1
                 FROM torneo.equipo_en_partido AS ep
                 WHERE ep.id_partido = @v_id_partido
                   AND ep.id_seleccion = @v_id_seleccion
                   AND ep.esquema_tactico = @v_esquema_prueba
             )
            THEN 'PASS registrar alineacion mediante TVP'
        ELSE 'FAIL registrar alineacion mediante TVP'
    END AS resultado;

    PRINT '--- EVIDENCIA DESPUES DE REGISTRAR LA ALINEACION ---';

    SELECT a.*
    FROM juego.alineacion AS a
    WHERE a.id_partido = @v_id_partido
      AND a.id_seleccion = @v_id_seleccion
    ORDER BY a.es_titular DESC, a.dorsal, a.id_jugador;

    SELECT ep.id_partido,
           ep.id_seleccion,
           ep.condicion,
           ep.esquema_tactico
    FROM torneo.equipo_en_partido AS ep
    WHERE ep.id_partido = @v_id_partido
      AND ep.id_seleccion = @v_id_seleccion;

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

PRINT '=====================================================================';
PRINT 'FIN PRUEBA EXITOSA: 68_Test_OK_Alineacion';
PRINT 'ROLLBACK EJECUTADO';
PRINT '=====================================================================';
GO
