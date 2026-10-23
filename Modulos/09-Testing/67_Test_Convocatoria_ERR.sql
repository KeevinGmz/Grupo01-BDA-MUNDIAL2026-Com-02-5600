/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Validar en el SP de negocio de convocatorias:no permitir un dorsal duplicado en la misma seleccion.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS DE ERROR: 67_Test_ERR_Convocatoria';
PRINT N'=====================================================================';
GO

/* =====================================================================
   CASO 1: dorsal duplicado dentro de la convocatoria recibida
===================================================================== */
PRINT N'';
PRINT N'-> Test 1: registrar una convocatoria con un dorsal repetido';

DECLARE @v_id_seleccion INT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_filas_antes INT;
DECLARE @v_filas_despues INT;
DECLARE @v_cantidad_requerida INT = 26;
DECLARE @v_jugadores_disponibles INT;
DECLARE @v_convocados torneo.tt_Convocado;

-------------------------------------------------------------------------------
-- 1. Validaciones previas
-------------------------------------------------------------------------------

IF OBJECT_ID(N'torneo.usp_Negocio_RegistrarConvocatoria', N'P') IS NULL
BEGIN
    ;THROW 50001,N'67_Test_ERR_Convocatoria: no existe torneo.usp_Negocio_RegistrarConvocatoria', 1;
END;

IF TYPE_ID(N'torneo.tt_Convocado') IS NULL
BEGIN
    ;THROW 50001,N'67_Test_ERR_Convocatoria: no existe el tipo torneo.tt_Convocado',1;
END;

SELECT TOP (1)
    @v_id_seleccion = s.id_seleccion,
    @v_jugadores_disponibles = COUNT(*)
FROM torneo.seleccion AS s
JOIN persona.persona AS p
  ON p.id_pais = s.id_pais
 AND p.tipo_persona = 'J'
JOIN persona.jugador AS j
  ON j.id_persona = p.id_persona
WHERE NOT EXISTS
      (
          SELECT 1
          FROM torneo.convocatoria AS ca
          WHERE ca.id_seleccion = s.id_seleccion
            AND ca.estado = 'ACTIVO'
      )
  AND NOT EXISTS
      (
          SELECT 1
          FROM torneo.convocatoria AS cj
          WHERE cj.id_jugador = p.id_persona
      )
GROUP BY s.id_seleccion
HAVING COUNT(*) >= @v_cantidad_requerida
ORDER BY s.id_seleccion;

IF @v_id_seleccion IS NULL
BEGIN
    ;THROW 50001,N'67_Test_ERR_Convocatoria: se requiere una seleccion sin convocatoria activa y con al menos 26 jugadores elegibles no convocados',1;
END;

-------------------------------------------------------------------------------
-- 2. Preparar el TVP con exactamente dos dorsales repetidos
-------------------------------------------------------------------------------

;WITH jugadores_elegibles AS
(
    SELECT
        p.id_persona AS id_jugador,
        ROW_NUMBER() OVER (ORDER BY p.id_persona) AS rn
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
              WHERE c.id_jugador = p.id_persona
          )
)
INSERT INTO @v_convocados
(
    id_jugador,
    dorsal
)
SELECT
    je.id_jugador,
    CONVERT
    (
        TINYINT,
        CASE
            WHEN je.rn IN (1, 2) THEN 10
            WHEN je.rn BETWEEN 3 AND 10 THEN je.rn - 2
            ELSE je.rn
        END
    ) AS dorsal
FROM jugadores_elegibles AS je
WHERE je.rn <= @v_cantidad_requerida;

IF (SELECT COUNT(*) FROM @v_convocados) <> @v_cantidad_requerida
BEGIN
    ;THROW 50001, N'67_Test_ERR_Convocatoria: no se pudo completar la lista de prueba', 1;
END;

IF 2 <>
   (
       SELECT COUNT(*)
       FROM @v_convocados AS c
       WHERE c.dorsal = 10
   )
BEGIN
    ;THROW 50001, N'67_Test_ERR_Convocatoria: no se pudo preparar el dorsal duplicado',1;
END;

SELECT @v_filas_antes = COUNT(*)
FROM torneo.convocatoria AS c
WHERE c.id_seleccion = @v_id_seleccion;

PRINT N'--- EVIDENCIA DEL TVP ANTES DEL INTENTO ---';

SELECT
    @v_id_seleccion AS id_seleccion_prueba,
    @v_cantidad_requerida AS cantidad_convocados,
    10 AS dorsal_duplicado,
    @v_filas_antes AS filas_antes;

SELECT c.id_jugador, c.dorsal
FROM @v_convocados AS c
ORDER BY c.dorsal, c.id_jugador;

-------------------------------------------------------------------------------
-- 3. Ejecutar el caso de error en su propia transaccion
-------------------------------------------------------------------------------

BEGIN TRANSACTION;

BEGIN TRY
    EXEC torneo.usp_Negocio_RegistrarConvocatoria
        @id_seleccion = @v_id_seleccion,
        @convocados = @v_convocados;

    SET @v_error_numero = 0;
    SET @v_error_mensaje =
        N'El SP permitio registrar una convocatoria con dorsal duplicado';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

SELECT @v_filas_despues = COUNT(*)
FROM torneo.convocatoria AS c
WHERE c.id_seleccion = @v_id_seleccion;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

-------------------------------------------------------------------------------
-- 4. Evidencia y evaluacion
-------------------------------------------------------------------------------

PRINT CONCAT
(
    N'Error capturado ',
    @v_error_numero,
    N': ',
    @v_error_mensaje
);

SELECT
    @v_id_seleccion AS id_seleccion_prueba,
    @v_error_numero AS error_capturado,
    @v_filas_antes AS filas_antes,
    @v_filas_despues AS filas_despues;

IF @v_error_numero IN (50001, 50003)
   AND
   (
       @v_error_mensaje LIKE N'%dorsal%duplic%'
       OR @v_error_mensaje LIKE N'%dorsal%repet%'
       OR @v_error_mensaje LIKE N'%dorsales%unicos%'
   )
   AND @v_filas_despues = @v_filas_antes
BEGIN
    PRINT N'PASS Test 1: se rechazo el dorsal duplicado y no se registro la convocatoria.';
END
ELSE
BEGIN
    PRINT N'FAIL Test 1: numero, mensaje o persistencia distintos de lo esperado.';
END;
GO

PRINT N'';
PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS DE ERROR: 67_Test_ERR_Convocatoria';
PRINT N'ROLLBACK EJECUTADO';
PRINT N'=====================================================================';
GO
