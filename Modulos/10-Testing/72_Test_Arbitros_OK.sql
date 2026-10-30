/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Prueba exitosa del SP de negocio para designar la terna arbitral completa, sin conflictos de nacionalidad ni residuos.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBA EXITOSA: 72_Test_OK_Arbitraje';
PRINT N'=====================================================================';

DECLARE @v_id_partido INT;
DECLARE @v_id_pais_local SMALLINT;
DECLARE @v_id_pais_visitante SMALLINT;
DECLARE @v_advertencia NVARCHAR(500);
DECLARE @v_designaciones_antes INT;
DECLARE @v_designaciones_despues INT;
DECLARE @v_cantidad_roles INT;
DECLARE @v_cantidad_arbitros_neutrales INT;
DECLARE @v_terna arbitraje.tt_Designacion;

-------------------------------------------------------------------------------
-- 1. Validar los objetos requeridos
-------------------------------------------------------------------------------

IF OBJECT_ID(N'arbitraje.usp_Negocio_DesignarTerna', N'P') IS NULL
BEGIN
    ;THROW 50001, N'72_Test_OK_Arbitraje: no existe arbitraje.usp_Negocio_DesignarTerna',1;
END;

IF TYPE_ID(N'arbitraje.tt_Designacion') IS NULL
BEGIN
    ;THROW 50001,N'72_Test_OK_Arbitraje: no existe arbitraje.tt_Designacion', 1;
END;

SELECT @v_cantidad_roles = COUNT(*)
FROM arbitraje.rol_arbitral;

IF @v_cantidad_roles <> 5
BEGIN
    ;THROW 50001, N'72_Test_OK_Arbitraje: deben existir exactamente cinco roles arbitrales',1;
END;

-------------------------------------------------------------------------------
-- 2. Obtener un partido valido y las nacionalidades de sus selecciones
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
  AND 5 <=
      (
          SELECT COUNT(*)
          FROM persona.arbitro AS a
          JOIN persona.persona AS pa
            ON pa.id_persona = a.id_persona
          WHERE pa.id_pais NOT IN (sl.id_pais, sv.id_pais)
      )
ORDER BY p.id_partido;

IF @v_id_partido IS NULL
BEGIN
    ;THROW 50001, N'72_Test_OK_Arbitraje: se requiere un partido PROGRAMADO sin designaciones y con cinco arbitros neutrales disponibles', 1;
END;

SELECT @v_cantidad_arbitros_neutrales = COUNT(*)
FROM persona.arbitro AS a
JOIN persona.persona AS pa
  ON pa.id_persona = a.id_persona
WHERE pa.id_pais NOT IN (@v_id_pais_local, @v_id_pais_visitante);

IF @v_cantidad_arbitros_neutrales < 5
BEGIN
    ;THROW 50001, N'72_Test_OK_Arbitraje: no hay cinco arbitros neutrales disponibles',1;
END;

-------------------------------------------------------------------------------
-- 3. Armar el TVP con IDs de rol reales y cinco arbitros distintos
-------------------------------------------------------------------------------

;WITH roles AS
(
    SELECT
        r.id_rol,
        ROW_NUMBER() OVER (ORDER BY r.id_rol) AS rn
    FROM arbitraje.rol_arbitral AS r
),
arbitros AS
(
    SELECT TOP (5)
        a.id_persona AS id_arbitro,
        ROW_NUMBER() OVER (ORDER BY a.id_persona) AS rn
    FROM persona.arbitro AS a
    JOIN persona.persona AS pa
      ON pa.id_persona = a.id_persona
    WHERE pa.id_pais NOT IN (@v_id_pais_local, @v_id_pais_visitante)
    ORDER BY a.id_persona
)
INSERT INTO @v_terna
(
    id_rol,
    id_arbitro
)
SELECT
    r.id_rol,
    a.id_arbitro
FROM roles AS r
JOIN arbitros AS a
  ON a.rn = r.rn;

IF (SELECT COUNT(*) FROM @v_terna) <> 5
BEGIN
    ;THROW 50001, N'72_Test_OK_Arbitraje: el TVP no contiene las cinco designaciones requeridas',1;
END;

IF EXISTS
(
    SELECT id_arbitro
    FROM @v_terna
    GROUP BY id_arbitro
    HAVING COUNT(*) > 1
)
BEGIN
    ;THROW 50001, N'72_Test_OK_Arbitraje: un arbitro no puede ocupar mas de un rol en el mismo partido',1;
END;

PRINT N'--- EVIDENCIA DEL TVP ANTES DE DESIGNAR LA TERNA ---';

SELECT
    @v_id_partido AS id_partido,
    @v_id_pais_local AS pais_local,
    @v_id_pais_visitante AS pais_visitante,
    @v_cantidad_arbitros_neutrales AS arbitros_neutrales_disponibles;

SELECT
    t.id_rol,
    r.descripcion AS rol,
    t.id_arbitro,
    pa.id_pais AS pais_arbitro
FROM @v_terna AS t
JOIN arbitraje.rol_arbitral AS r
  ON r.id_rol = t.id_rol
JOIN persona.persona AS pa
  ON pa.id_persona = t.id_arbitro
ORDER BY t.id_rol;

-------------------------------------------------------------------------------
-- 4. Ejecutar la designacion y comprobar el resultado
-------------------------------------------------------------------------------

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT @v_designaciones_antes = COUNT(*)
    FROM arbitraje.designacion_arbitral
    WHERE id_partido = @v_id_partido;

    EXEC arbitraje.usp_Negocio_DesignarTerna
        @id_partido = @v_id_partido,
        @terna = @v_terna,
        @advertencia = @v_advertencia OUTPUT;

    SELECT @v_designaciones_despues = COUNT(*)
    FROM arbitraje.designacion_arbitral
    WHERE id_partido = @v_id_partido;

    SELECT CASE
        WHEN @v_designaciones_antes = 0
         AND @v_designaciones_despues = 5
         AND NOT EXISTS
             (
                 SELECT 1
                 FROM @v_terna AS t
                 WHERE NOT EXISTS
                       (
                           SELECT 1
                           FROM arbitraje.designacion_arbitral AS da
                           WHERE da.id_partido = @v_id_partido
                             AND da.id_rol = t.id_rol
                             AND da.id_arbitro = t.id_arbitro
                             AND da.estado = 'DESIGNADA'
                       )
             )
         AND NOT EXISTS
             (
                 SELECT 1
                 FROM arbitraje.designacion_arbitral AS da
                 JOIN persona.persona AS pa
                   ON pa.id_persona = da.id_arbitro
                 WHERE da.id_partido = @v_id_partido
                   AND pa.id_pais IN (@v_id_pais_local, @v_id_pais_visitante)
             )
            THEN N'PASS designar terna arbitral'
        ELSE N'FAIL designar terna arbitral'
    END AS resultado;

    PRINT N'--- EVIDENCIA DESPUES DE DESIGNAR LA TERNA ---';
    PRINT CONCAT(N'Advertencia emitida: ', COALESCE(@v_advertencia, N'Ninguna'));

    SELECT
        da.id_partido,
        da.id_rol,
        r.descripcion AS rol,
        da.id_arbitro,
        pa.id_pais AS pais_arbitro,
        da.fecha_designacion,
        da.estado
    FROM arbitraje.designacion_arbitral AS da
    JOIN arbitraje.rol_arbitral AS r
      ON r.id_rol = da.id_rol
    JOIN persona.persona AS pa
      ON pa.id_persona = da.id_arbitro
    WHERE da.id_partido = @v_id_partido
    ORDER BY da.id_rol;

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
PRINT N'FIN PRUEBA EXITOSA: 72_Test_OK_Arbitraje';
PRINT N'ROLLBACK EJECUTADO';
PRINT N'=====================================================================';
GO
