/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Validar fallas del ABM Publicidad:importe de tarifa mayor a cero y V-12, prioridad 1 a 4.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS DE ERROR: 61_Test_ABM_Publicidad_ERR';
PRINT N'=====================================================================';
GO

/* =====================================================================
   CASO 1: tarifa con importe igual a cero
===================================================================== */
PRINT N'';
PRINT N'-> Test 1: insertar tarifa con importe igual a cero';

DECLARE @v_id_franja TINYINT;
DECLARE @v_id_moneda TINYINT;
DECLARE @v_id_tarifa INT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_filas_antes INT;
DECLARE @v_filas_despues INT;

IF OBJECT_ID(N'publicidad.usp_Tarifa_Insertar', N'P') IS NULL
BEGIN
    ;THROW 50001,N'61_Test_ABM_Publicidad_ERR: no existe publicidad.usp_Tarifa_Insertar', 1;
END;

SELECT TOP (1)
    @v_id_franja = f.id_franja,
    @v_id_moneda = m.id_moneda
FROM publicidad.franja_horaria AS f
CROSS JOIN publicidad.moneda AS m
WHERE NOT EXISTS
      (
          SELECT 1
          FROM publicidad.tarifa AS t
          WHERE t.id_franja = f.id_franja
            AND t.id_moneda = m.id_moneda
      )
ORDER BY f.id_franja, m.id_moneda;

IF @v_id_franja IS NULL OR @v_id_moneda IS NULL
BEGIN
    ;THROW 50001,N'61_Test_ABM_Publicidad_ERR: se requiere una combinacion franja-moneda libre para el Test 1',1;
END;

SELECT @v_filas_antes = COUNT(*)
FROM publicidad.tarifa AS t
WHERE t.id_franja = @v_id_franja
  AND t.id_moneda = @v_id_moneda;

BEGIN TRANSACTION;

BEGIN TRY
    EXEC publicidad.usp_Tarifa_Insertar
        @id_franja = @v_id_franja,
        @id_moneda = @v_id_moneda,
        @importe = 0.00,
        @id_tarifa = @v_id_tarifa OUTPUT;

    SET @v_error_numero = 0;
    SET @v_error_mensaje = N'El SP no lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

SELECT @v_filas_despues = COUNT(*)
FROM publicidad.tarifa AS t
WHERE t.id_franja = @v_id_franja
  AND t.id_moneda = @v_id_moneda;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

PRINT CONCAT(N'Error capturado ', @v_error_numero, N': ', @v_error_mensaje);

IF @v_error_numero = 50001
   AND @v_error_mensaje LIKE N'%importe%debe ser mayor a 0%'
   AND @v_filas_antes = 0
   AND @v_filas_despues = 0
BEGIN
    PRINT N'PASS Test 1: se rechazo la tarifa con importe cero.';
END
ELSE
BEGIN
    PRINT N'FAIL Test 1: numero, mensaje o persistencia distintos de lo esperado.';
END;
GO

/* =====================================================================
   CASO 2: V-12, orden de prioridad fuera del rango 1 a 4
===================================================================== */
PRINT N'';
PRINT N'-> Test 2: insertar exhibicion con orden_prioridad igual a 5';

DECLARE @v_id_partido INT;
DECLARE @v_id_sede INT;
DECLARE @v_nro_espacio TINYINT;
DECLARE @v_id_pieza INT;
DECLARE @v_id_tarifa INT;
DECLARE @v_id_exhibicion INT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_filas_antes INT;
DECLARE @v_filas_despues INT;
DECLARE @v_fecha_hora_emision DATETIME2(0) = SYSUTCDATETIME();

IF OBJECT_ID(N'publicidad.usp_Exhibicion_Insertar', N'P') IS NULL
BEGIN
    ;THROW 50001,
           N'61_Test_ABM_Publicidad_ERR: no existe publicidad.usp_Exhibicion_Insertar',
           1;
END;

-- Se eligen referencias existentes y una combinacion no utilizada para que
-- el unico dato invalido sea orden_prioridad = 5.
SELECT TOP (1)
    @v_id_partido = p.id_partido,
    @v_id_sede = p.id_sede,
    @v_nro_espacio = e.nro_espacio,
    @v_id_pieza = pp.id_pieza,
    @v_id_tarifa = t.id_tarifa
FROM torneo.partido AS p
JOIN publicidad.espacio_publicitario AS e
  ON e.id_sede = p.id_sede
CROSS JOIN publicidad.pieza_publicitaria AS pp
CROSS JOIN publicidad.tarifa AS t
WHERE NOT EXISTS
      (
          SELECT 1
          FROM publicidad.exhibicion AS x
          WHERE x.id_partido = p.id_partido
            AND x.id_sede = p.id_sede
            AND x.nro_espacio = e.nro_espacio
      )
  AND NOT EXISTS
      (
          SELECT 1
          FROM publicidad.exhibicion AS x
          WHERE x.id_partido = p.id_partido
            AND x.id_pieza = pp.id_pieza
      )
ORDER BY p.id_partido, e.nro_espacio, pp.id_pieza, t.id_tarifa;

IF @v_id_partido IS NULL
   OR @v_id_sede IS NULL
   OR @v_nro_espacio IS NULL
   OR @v_id_pieza IS NULL
   OR @v_id_tarifa IS NULL
BEGIN
    ;THROW 50001,
           N'61_Test_ABM_Publicidad_ERR: faltan referencias validas para preparar el Test 2',
           1;
END;

SELECT @v_filas_antes = COUNT(*)
FROM publicidad.exhibicion AS x
WHERE x.id_partido = @v_id_partido
  AND x.id_sede = @v_id_sede
  AND x.nro_espacio = @v_nro_espacio;

BEGIN TRANSACTION;

BEGIN TRY
    EXEC publicidad.usp_Exhibicion_Insertar
        @id_partido = @v_id_partido,
        @id_sede = @v_id_sede,
        @nro_espacio = @v_nro_espacio,
        @id_pieza = @v_id_pieza,
        @id_tarifa = @v_id_tarifa,
        @fecha_hora_emision = @v_fecha_hora_emision,
        @orden_prioridad = 5,
        @importe_facturado = 50000.00,
        @cotizacion_aplicada = 1.000000,
        @id_exhibicion = @v_id_exhibicion OUTPUT;

    SET @v_error_numero = 0;
    SET @v_error_mensaje = N'El SP no lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

SELECT @v_filas_despues = COUNT(*)
FROM publicidad.exhibicion AS x
WHERE x.id_partido = @v_id_partido
  AND x.id_sede = @v_id_sede
  AND x.nro_espacio = @v_nro_espacio;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

PRINT CONCAT(N'Error capturado ', @v_error_numero, N': ', @v_error_mensaje);

SELECT
    @v_id_partido AS id_partido_prueba,
    @v_id_sede AS id_sede_prueba,
    @v_nro_espacio AS nro_espacio_valido,
    @v_id_pieza AS id_pieza_prueba,
    @v_id_tarifa AS id_tarifa_prueba,
    5 AS orden_prioridad_invalido,
    @v_filas_antes AS filas_antes,
    @v_filas_despues AS filas_despues;

IF @v_error_numero = 50001
   AND @v_error_mensaje LIKE N'%orden_prioridad%entre 1 y 4%'
   AND @v_filas_antes = 0
   AND @v_filas_despues = 0
BEGIN
    PRINT N'PASS Test 2: se rechazo la quinta prioridad y no se inserto la exhibicion.';
END
ELSE
BEGIN
    PRINT N'FAIL Test 2: numero, mensaje o persistencia distintos de lo esperado.';
END;
GO

PRINT N'';
PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS DE ERROR: 61_Test_ABM_Publicidad_ERR';
PRINT N'Cada caso ejecuto su propio ROLLBACK.';
PRINT N'=====================================================================';
GO
