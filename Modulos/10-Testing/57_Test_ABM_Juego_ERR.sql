/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada                  
Comision: 02-5600
Grupo   : 01  
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Validar el rechazo de un gol cuyo minuto se encuentra fuera del dominio permitido por el ABM de juego.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT '=====================================================================';
PRINT 'INICIO PRUEBAS DE ERROR: 57_Test_ABM_Juego_ERR';
PRINT '=====================================================================';
GO

/* =====================================================================
   CASO 1: minuto de gol mayor que 130
===================================================================== */
PRINT '';
PRINT '-> Test 1: insertar un gol en el minuto 150';

DECLARE @v_id_partido INT;
DECLARE @v_id_seleccion INT;
DECLARE @v_id_jugador_autor INT;
DECLARE @v_nro_gol TINYINT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje VARCHAR(2048) = NULL;
DECLARE @v_filas_antes INT;
DECLARE @v_filas_despues INT;

-------------------------------------------------------------------------------
-- 1. Validaciones previas del entorno
-------------------------------------------------------------------------------

IF OBJECT_ID('juego.usp_Gol_Insertar', 'P') IS NULL
BEGIN
    ;THROW 50001,'57_Test_ABM_Juego_ERR: no existe juego.usp_Gol_Insertar',1;
END;

-- Se selecciona un jugador realmente alineado. No se suponen IDs fisicos.
SELECT TOP (1)
    @v_id_partido = a.id_partido,
    @v_id_seleccion = a.id_seleccion,
    @v_id_jugador_autor = a.id_jugador
FROM juego.alineacion AS a
JOIN torneo.equipo_en_partido AS ep
  ON ep.id_partido = a.id_partido
 AND ep.id_seleccion = a.id_seleccion
ORDER BY a.id_partido, a.id_seleccion, a.es_titular DESC, a.dorsal;

IF @v_id_partido IS NULL
   OR @v_id_seleccion IS NULL
   OR @v_id_jugador_autor IS NULL
BEGIN
    ;THROW 50001, '57_Test_ABM_Juego_ERR: debe existir al menos una alineacion valida para ejecutar la prueba',1;
END;

-- Se obtiene un numero libre dentro del dominio TINYINT para no mezclar el
-- error de minuto con una posible duplicacion de la PK del gol.
SELECT @v_nro_gol = CONVERT
(
    TINYINT,
    ISNULL(MAX(CONVERT(INT, g.nro_gol)), 0) + 1
)
FROM juego.gol AS g
WHERE g.id_partido = @v_id_partido
  AND g.id_seleccion = @v_id_seleccion;

IF @v_nro_gol IS NULL
BEGIN
    ;THROW 50001,'57_Test_ABM_Juego_ERR: no hay un nro_gol TINYINT disponible para la prueba',1;
END;

SELECT @v_filas_antes = COUNT(*)
FROM juego.gol AS g
WHERE g.id_partido = @v_id_partido
  AND g.id_seleccion = @v_id_seleccion
  AND g.nro_gol = @v_nro_gol;

BEGIN TRANSACTION;

BEGIN TRY
    EXEC juego.usp_Gol_Insertar
        @id_partido = @v_id_partido,
        @id_seleccion = @v_id_seleccion,
        @nro_gol = @v_nro_gol,
        @minuto = 150,
        @tipo_gol = 'JUGADA',
        @en_contra = 0,
        @periodo = 'ST',
        @id_jugador_autor = @v_id_jugador_autor,
        @id_jugador_asistente = NULL;

    SET @v_error_numero = 0;
    SET @v_error_mensaje = 'El SP no lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

SELECT @v_filas_despues = COUNT(*)
FROM juego.gol AS g
WHERE g.id_partido = @v_id_partido
  AND g.id_seleccion = @v_id_seleccion
  AND g.nro_gol = @v_nro_gol;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

-------------------------------------------------------------------------------
-- 2. Evidencia y evaluacion
-------------------------------------------------------------------------------

PRINT CONCAT
(
    'Error capturado ',
    @v_error_numero,
    ': ',
    @v_error_mensaje
);

SELECT
    @v_id_partido AS id_partido_prueba,
    @v_id_seleccion AS id_seleccion_prueba,
    @v_id_jugador_autor AS id_jugador_autor_prueba,
    @v_nro_gol AS nro_gol_prueba,
    150 AS minuto_invalido,
    @v_filas_antes AS filas_antes,
    @v_filas_despues AS filas_despues;

IF @v_error_numero = 50001
   AND @v_error_mensaje LIKE '%minuto%fuera de rango%'
   AND @v_filas_antes = 0
   AND @v_filas_despues = 0
BEGIN
    PRINT 'PASS Test 1: se rechazo el minuto 150 con error 50001 y no se inserto el gol.';
END
ELSE
BEGIN
    PRINT 'FAIL Test 1: numero, mensaje o persistencia distintos de lo esperado.';
END;
GO

PRINT '';
PRINT '=====================================================================';
PRINT 'FIN PRUEBAS DE ERROR: 57_Test_ABM_Juego_ERR';
PRINT 'ROLLBACK EJECUTADO';
PRINT '=====================================================================';
GO
