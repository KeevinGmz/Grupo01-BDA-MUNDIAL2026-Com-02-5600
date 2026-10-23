/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Validar fallas de alineaciones mediante TVP: mas de 11 titulares y jugador no convocado.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT '=====================================================================';
PRINT 'INICIO PRUEBAS DE ERROR: 69_Test_ERR_Alineaciones';
PRINT '=====================================================================';
GO

/* =====================================================================
   CASO 1:  alineacion con 12 titulares
===================================================================== */
PRINT '';
PRINT '-> Test 1: registrar una alineacion con 12 titulares';

DECLARE @v_id_partido INT;
DECLARE @v_id_seleccion INT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje VARCHAR(2048) = NULL;
DECLARE @v_filas_antes INT;
DECLARE @v_filas_despues INT;
DECLARE @v_alineacion juego.tt_Alineacion;

IF OBJECT_ID('juego.usp_Negocio_RegistrarAlineacion', 'P') IS NULL
BEGIN
    ;THROW 50001, '69_Test_ERR_Alineaciones: no existe juego.usp_Negocio_RegistrarAlineacion', 1;
END;

IF TYPE_ID('juego.tt_Alineacion') IS NULL
BEGIN
    ;THROW 50001, '69_Test_ERR_Alineaciones: no existe juego.tt_Alineacion',1;
END;

-- Se busca un equipo sin alineacion previa y con al menos 12 convocados activos.
SELECT TOP (1)
    @v_id_partido = ep.id_partido,
    @v_id_seleccion = ep.id_seleccion
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
GROUP BY ep.id_partido, ep.id_seleccion
HAVING COUNT(*) >= 12
ORDER BY ep.id_partido, ep.id_seleccion;

IF @v_id_partido IS NULL OR @v_id_seleccion IS NULL
BEGIN
    ;THROW 50001,'69_Test_ERR_Alineaciones: se requiere un equipo sin alineacion y con al menos 12 convocados activos para el Test 1',1;
END;

;WITH convocados AS
(
    SELECT
        c.id_jugador,
        c.dorsal,
        j.id_posicion_habitual AS id_posicion,
        ROW_NUMBER() OVER (ORDER BY c.dorsal, c.id_jugador) AS rn
    FROM torneo.convocatoria AS c
    JOIN persona.jugador AS j
      ON j.id_persona = c.id_jugador
    WHERE c.id_seleccion = @v_id_seleccion
      AND c.estado = 'ACTIVO'
)
INSERT INTO @v_alineacion
    (id_jugador, dorsal, es_titular, id_posicion, es_posicion_habitual)
SELECT
    c.id_jugador,
    c.dorsal,
    CONVERT(BIT, CASE WHEN c.rn <= 12 THEN 1 ELSE 0 END),
    c.id_posicion,
    CONVERT(BIT, 1)
FROM convocados AS c;

IF (SELECT COUNT(*) FROM @v_alineacion WHERE es_titular = 1) <> 12
BEGIN
    ;THROW 50001,'69_Test_ERR_Alineaciones: no se pudo preparar el TVP con 12 titulares', 1;
END;

SELECT @v_filas_antes = COUNT(*)
FROM juego.alineacion AS a
WHERE a.id_partido = @v_id_partido
  AND a.id_seleccion = @v_id_seleccion;

BEGIN TRANSACTION;

BEGIN TRY
    EXEC juego.usp_Negocio_RegistrarAlineacion
        @id_partido = @v_id_partido,
        @id_seleccion = @v_id_seleccion,
        @esquema_tactico = '4-3-3',
        @alineacion = @v_alineacion;

    SET @v_error_numero = 0;
    SET @v_error_mensaje = 'El SP permitio registrar 12 titulares';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

SELECT @v_filas_despues = COUNT(*)
FROM juego.alineacion AS a
WHERE a.id_partido = @v_id_partido
  AND a.id_seleccion = @v_id_seleccion;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

PRINT CONCAT('Error capturado ', @v_error_numero, ': ', @v_error_mensaje);

IF @v_error_numero IN (50001, 50003)
   AND
   (
       @v_error_mensaje LIKE '%11%titular%'
       OR @v_error_mensaje LIKE '%titular%exactamente%11%'
       OR @v_error_mensaje LIKE '%exceso%titular%'
   )
   AND @v_filas_despues = @v_filas_antes
BEGIN
    PRINT 'PASS Test 1: se rechazo la alineacion con 12 titulares.';
END
ELSE
BEGIN
    PRINT 'FAIL Test 1: numero, mensaje o persistencia distintos de lo esperado.';
END;
GO

/* =====================================================================
   CASO 2: jugador no convocado
===================================================================== */
PRINT '';
PRINT '-> Test 2: registrar una alineacion con un jugador no convocado';

DECLARE @v_id_partido INT;
DECLARE @v_id_seleccion INT;
DECLARE @v_id_jugador_no_convocado INT;
DECLARE @v_dorsal_reemplazado TINYINT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje VARCHAR(2048) = NULL;
DECLARE @v_filas_antes INT;
DECLARE @v_filas_despues INT;
DECLARE @v_alineacion juego.tt_Alineacion;

-- Se requiere un suplente para reemplazarlo sin alterar los 11 titulares.
SELECT TOP (1)
    @v_id_partido = ep.id_partido,
    @v_id_seleccion = ep.id_seleccion
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
GROUP BY ep.id_partido, ep.id_seleccion
HAVING COUNT(*) >= 12
ORDER BY ep.id_partido, ep.id_seleccion;

SELECT TOP (1)
    @v_id_jugador_no_convocado = p.id_persona
FROM torneo.seleccion AS s
JOIN persona.persona AS p
  ON p.id_pais = s.id_pais
 AND p.tipo_persona = 'J'
JOIN persona.jugador AS j
  ON j.id_persona = p.id_persona
WHERE s.id_seleccion = @v_id_seleccion
  AND NOT EXISTS
      (
          SELECT 1
          FROM torneo.convocatoria AS c
          WHERE c.id_seleccion = @v_id_seleccion
            AND c.id_jugador = p.id_persona
            AND c.estado = 'ACTIVO'
      )
ORDER BY p.id_persona;

IF @v_id_partido IS NULL
   OR @v_id_seleccion IS NULL
   OR @v_id_jugador_no_convocado IS NULL
BEGIN
    ;THROW 50001,'69_Test_ERR_Alineaciones: faltan equipo, convocados o jugador no convocado para el Test 2',1;
END;

;WITH convocados AS
(
    SELECT
        c.id_jugador,
        c.dorsal,
        j.id_posicion_habitual AS id_posicion,
        ROW_NUMBER() OVER (ORDER BY c.dorsal, c.id_jugador) AS rn
    FROM torneo.convocatoria AS c
    JOIN persona.jugador AS j
      ON j.id_persona = c.id_jugador
    WHERE c.id_seleccion = @v_id_seleccion
      AND c.estado = 'ACTIVO'
)
INSERT INTO @v_alineacion
    (id_jugador, dorsal, es_titular, id_posicion, es_posicion_habitual)
SELECT
    c.id_jugador,
    c.dorsal,
    CONVERT(BIT, CASE WHEN c.rn <= 11 THEN 1 ELSE 0 END),
    c.id_posicion,
    CONVERT(BIT, 1)
FROM convocados AS c;

-- Se toma el dorsal de un suplente, se elimina ese suplente del TVP y se
-- incorpora el jugador no convocado con una posicion real.
SELECT TOP (1)
    @v_dorsal_reemplazado = a.dorsal
FROM @v_alineacion AS a
WHERE a.es_titular = 0
ORDER BY a.dorsal, a.id_jugador;

DELETE FROM @v_alineacion
WHERE dorsal = @v_dorsal_reemplazado
  AND es_titular = 0;

INSERT INTO @v_alineacion
    (id_jugador, dorsal, es_titular, id_posicion, es_posicion_habitual)
SELECT
    @v_id_jugador_no_convocado,
    @v_dorsal_reemplazado,
    CONVERT(BIT, 0),
    j.id_posicion_habitual,
    CONVERT(BIT, 1)
FROM persona.jugador AS j
WHERE j.id_persona = @v_id_jugador_no_convocado;

IF (SELECT COUNT(*) FROM @v_alineacion WHERE es_titular = 1) <> 11
BEGIN
    ;THROW 50001, '69_Test_ERR_Alineaciones: el TVP del Test 2 no conserva exactamente 11 titulares',1;
END;

IF NOT EXISTS
   (
       SELECT 1
       FROM @v_alineacion AS a
       WHERE a.id_jugador = @v_id_jugador_no_convocado
   )
BEGIN
    ;THROW 50001, '69_Test_ERR_Alineaciones: no se pudo incorporar al jugador no convocado en el TVP',1;
END;

SELECT @v_filas_antes = COUNT(*)
FROM juego.alineacion AS a
WHERE a.id_partido = @v_id_partido
  AND a.id_seleccion = @v_id_seleccion;

BEGIN TRANSACTION;

BEGIN TRY
    EXEC juego.usp_Negocio_RegistrarAlineacion
        @id_partido = @v_id_partido,
        @id_seleccion = @v_id_seleccion,
        @esquema_tactico = '4-3-3',
        @alineacion = @v_alineacion;

    SET @v_error_numero = 0;
    SET @v_error_mensaje = 'El SP permitio alinear a un jugador no convocado';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

SELECT @v_filas_despues = COUNT(*)
FROM juego.alineacion AS a
WHERE a.id_partido = @v_id_partido
  AND a.id_seleccion = @v_id_seleccion;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

PRINT CONCAT('Error capturado ', @v_error_numero, ': ', @v_error_mensaje);

SELECT
    @v_id_partido AS id_partido_prueba,
    @v_id_seleccion AS id_seleccion_prueba,
    @v_id_jugador_no_convocado AS jugador_no_convocado,
    @v_filas_antes AS filas_antes,
    @v_filas_despues AS filas_despues;

IF @v_error_numero IN (50001, 50003)
   AND
   (
       @v_error_mensaje LIKE '%jugador%no%convocad%'
       OR @v_error_mensaje LIKE '%convocatoria%activa%'
       OR @v_error_mensaje LIKE '%alineacion%convocad%'
   )
   AND @v_filas_despues = @v_filas_antes
BEGIN
    PRINT 'PASS Test 2: se rechazo al jugador no convocado.';
END
ELSE
BEGIN
    PRINT 'FAIL Test 2: numero, mensaje o persistencia distintos de lo esperado.';
END;
GO

PRINT '';
PRINT '=====================================================================';
PRINT 'FIN PRUEBAS DE ERROR: 69_Test_ERR_Alineaciones';
PRINT 'CADA CASO EJECUTO SU PROPIO ROLLBACK';
PRINT '=====================================================================';
GO
