/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Validar rechazo de una designacion arbitral cuando unarbitro comparte nacionalidad con una seleccion del partido.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS DE ERROR: 73_Test_ERR_Arbitros';
PRINT N'=====================================================================';
GO

/* =====================================================================
   CASO 5: conflicto de nacionalidad
===================================================================== */
PRINT N'';
PRINT N'-> Test 1: designar un arbitro de la misma nacionalidad que el equipo local';

DECLARE @v_id_partido INT;
DECLARE @v_id_pais_local SMALLINT;
DECLARE @v_id_pais_visitante SMALLINT;
DECLARE @v_id_arbitro_conflicto INT;
DECLARE @v_advertencia NVARCHAR(500);
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_filas_antes INT;
DECLARE @v_filas_despues INT;
DECLARE @v_cantidad_roles INT;
DECLARE @v_terna arbitraje.tt_Designacion;

-------------------------------------------------------------------------------
-- 1. Validar objetos requeridos
-------------------------------------------------------------------------------

IF OBJECT_ID(N'arbitraje.usp_Negocio_DesignarTerna', N'P') IS NULL
BEGIN
    ;THROW 50001,N'73_Test_ERR_Arbitros: no existe arbitraje.usp_Negocio_DesignarTerna',1;
END;

IF TYPE_ID(N'arbitraje.tt_Designacion') IS NULL
BEGIN
    ;THROW 50001, N'73_Test_ERR_Arbitros: no existe arbitraje.tt_Designacion',1;
END;

SELECT @v_cantidad_roles = COUNT(*)
FROM arbitraje.rol_arbitral;

IF @v_cantidad_roles <> 5
BEGIN
    ;THROW 50001, N'73_Test_ERR_Arbitros: deben existir exactamente cinco roles arbitrales',1;
END;

-------------------------------------------------------------------------------
-- 2. Elegir un partido apto sin alterar datos maestros
-------------------------------------------------------------------------------

SELECT TOP (1)
    @v_id_partido = p.id_partido,
    @v_id_pais_local = sl.id_pais,
    @v_id_pais_visitante = sv.id_pais
FROM torneo.partido AS p
JOIN torneo.equipo_en_partido AS epl
  ON epl.id_partido = p.id_partido
 AND epl.condicion = 'L'
JOIN torneo.seleccion AS sl
  ON sl.id_seleccion = epl.id_seleccion
JOIN torneo.equipo_en_partido AS epv
  ON epv.id_partido = p.id_partido
 AND epv.condicion = 'V'
JOIN torneo.seleccion AS sv
  ON sv.id_seleccion = epv.id_seleccion
WHERE p.estado = 'PROGRAMADO'
  AND NOT EXISTS
      (
          SELECT 1
          FROM arbitraje.designacion_arbitral AS da
          WHERE da.id_partido = p.id_partido
      )
  AND EXISTS
      (
          SELECT 1
          FROM persona.arbitro AS ac
          JOIN persona.persona AS pc
            ON pc.id_persona = ac.id_persona
          WHERE pc.id_pais = sl.id_pais
      )
  AND 4 <=
      (
          SELECT COUNT(*)
          FROM persona.arbitro AS an
          JOIN persona.persona AS pn
            ON pn.id_persona = an.id_persona
          WHERE pn.id_pais NOT IN (sl.id_pais, sv.id_pais)
      )
ORDER BY p.id_partido;

IF @v_id_partido IS NULL
BEGIN
    ;THROW 50001,N'73_Test_ERR_Arbitros: se requiere un partido programado, un arbitro del pais local y cuatro arbitros neutrales', 1;
END;

SELECT TOP (1)
    @v_id_arbitro_conflicto = a.id_persona
FROM persona.arbitro AS a
JOIN persona.persona AS pa
  ON pa.id_persona = a.id_persona
WHERE pa.id_pais = @v_id_pais_local
ORDER BY a.id_persona;

-------------------------------------------------------------------------------
-- 3. Preparar una terna completa con IDs de rol reales
-------------------------------------------------------------------------------

;WITH roles AS
(
    SELECT
        r.id_rol,
        ROW_NUMBER() OVER (ORDER BY r.id_rol) AS rn
    FROM arbitraje.rol_arbitral AS r
),
arbitros_neutrales AS
(
    SELECT TOP (4)
        a.id_persona AS id_arbitro,
        ROW_NUMBER() OVER (ORDER BY a.id_persona) + 1 AS rn
    FROM persona.arbitro AS a
    JOIN persona.persona AS pa
      ON pa.id_persona = a.id_persona
    WHERE pa.id_pais NOT IN (@v_id_pais_local, @v_id_pais_visitante)
      AND a.id_persona <> @v_id_arbitro_conflicto
    ORDER BY a.id_persona
),
arbitros_prueba AS
(
    SELECT 1 AS rn, @v_id_arbitro_conflicto AS id_arbitro
    UNION ALL
    SELECT an.rn, an.id_arbitro
    FROM arbitros_neutrales AS an
)
INSERT INTO @v_terna
(
    id_rol,
    id_arbitro
)
SELECT
    r.id_rol,
    ap.id_arbitro
FROM roles AS r
JOIN arbitros_prueba AS ap
  ON ap.rn = r.rn;

IF (SELECT COUNT(*) FROM @v_terna) <> 5
BEGIN
    ;THROW 50001,N'73_Test_ERR_Arbitros: no se pudo completar el TVP con cinco designaciones',1;
END;

IF EXISTS
(
    SELECT t.id_arbitro
    FROM @v_terna AS t
    GROUP BY t.id_arbitro
    HAVING COUNT(*) > 1
)
BEGIN
    ;THROW 50001, N'73_Test_ERR_Arbitros: el TVP contiene arbitros repetidos',1;
END;

IF 1 <>
   (
       SELECT COUNT(*)
       FROM @v_terna AS t
       JOIN persona.persona AS pa
         ON pa.id_persona = t.id_arbitro
       WHERE pa.id_pais IN (@v_id_pais_local, @v_id_pais_visitante)
   )
BEGIN
    ;THROW 50001, N'73_Test_ERR_Arbitros: el TVP debe contener exactamente un conflicto de nacionalidad',1;
END;

SELECT @v_filas_antes = COUNT(*)
FROM arbitraje.designacion_arbitral AS da
WHERE da.id_partido = @v_id_partido;

PRINT N'--- EVIDENCIA DEL TVP ANTES DEL INTENTO ---';

SELECT
    @v_id_partido AS id_partido,
    @v_id_pais_local AS pais_local,
    @v_id_pais_visitante AS pais_visitante,
    @v_id_arbitro_conflicto AS arbitro_en_conflicto,
    @v_filas_antes AS designaciones_antes;

SELECT
    t.id_rol,
    r.descripcion AS rol,
    t.id_arbitro,
    pa.id_pais AS pais_arbitro,
    CASE
        WHEN pa.id_pais IN (@v_id_pais_local, @v_id_pais_visitante)
            THEN N'CONFLICTO'
        ELSE N'NEUTRAL'
    END AS validacion_nacionalidad
FROM @v_terna AS t
JOIN arbitraje.rol_arbitral AS r
  ON r.id_rol = t.id_rol
JOIN persona.persona AS pa
  ON pa.id_persona = t.id_arbitro
ORDER BY t.id_rol;

-------------------------------------------------------------------------------
-- 4. Ejecutar el caso de error
-------------------------------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY
    EXEC arbitraje.usp_Negocio_DesignarTerna
        @id_partido = @v_id_partido,
        @terna = @v_terna,
        @advertencia = @v_advertencia OUTPUT;

    SET @v_error_numero = 0;
    SET @v_error_mensaje =
        N'El SP permitio una terna con conflicto de nacionalidad';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

SELECT @v_filas_despues = COUNT(*)
FROM arbitraje.designacion_arbitral AS da
WHERE da.id_partido = @v_id_partido;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

-------------------------------------------------------------------------------
-- 5. Evaluar el resultado
-------------------------------------------------------------------------------

PRINT CONCAT(N'Error capturado ', @v_error_numero, N': ', @v_error_mensaje);
PRINT CONCAT(N'Advertencia devuelta: ', COALESCE(@v_advertencia, N'Ninguna'));

SELECT
    @v_id_partido AS id_partido,
    @v_id_arbitro_conflicto AS arbitro_en_conflicto,
    @v_filas_antes AS filas_antes,
    @v_filas_despues AS filas_despues;

IF @v_error_numero IN (50001, 50003)
   AND
   (
       @v_error_mensaje LIKE N'%nacionalidad%'
       OR @v_error_mensaje LIKE N'%mismo pais%'
       OR @v_error_mensaje LIKE N'%pais%seleccion%'
       OR @v_error_mensaje LIKE N'%arbitro%pais%'
   )
   AND @v_filas_despues = @v_filas_antes
BEGIN
    PRINT N'PASS Test 1: se rechazo la terna con conflicto de nacionalidad.';
END
ELSE
BEGIN
    PRINT N'FAIL Test 1: numero, mensaje o persistencia distintos de lo esperado.';
END;
GO

PRINT N'';
PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS DE ERROR: 73_Test_ERR_Arbitros';
PRINT N'ROLLBACK EJECUTADO';
PRINT N'=====================================================================';
GO
