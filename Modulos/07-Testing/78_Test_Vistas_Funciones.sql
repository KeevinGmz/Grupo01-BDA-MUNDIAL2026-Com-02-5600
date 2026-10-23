/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Pruebas individuales de tres funciones escalares y dos vistas de apoyo, con evidencia y resultado PASS/FAIL.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT '=====================================================================';
PRINT 'INICIO PRUEBAS: 78_Test_Funciones_Vistas';
PRINT '=====================================================================';

DECLARE @v_id_partido INT;
DECLARE @v_fecha_hora_utc DATETIME2(0);
DECLARE @v_id_huso SMALLINT;
DECLARE @v_id_jugador INT;
DECLARE @v_id_moneda TINYINT;
DECLARE @v_fecha_cotizacion DATE;
DECLARE @v_importe DECIMAL(18, 2) = 1500.00;


SELECT TOP (1)
    @v_id_partido = p.id_partido,
    @v_fecha_hora_utc = p.fecha_hora_utc,
    @v_id_huso = c.id_huso
FROM torneo.partido AS p
JOIN torneo.sede AS s
  ON s.id_sede = p.id_sede
JOIN geo.ciudad AS c
  ON c.id_ciudad = s.id_ciudad
ORDER BY p.id_partido;

SELECT TOP (1)
    @v_id_jugador = j.id_persona
FROM persona.jugador AS j
ORDER BY j.id_persona;

SELECT TOP (1)
    @v_id_moneda = tc.id_moneda,
    @v_fecha_cotizacion = tc.fecha
FROM publicidad.tipo_cambio AS tc
ORDER BY tc.fecha DESC, tc.id_moneda;

PRINT '--- DATOS DINAMICOS UTILIZADOS ---';
SELECT
    @v_id_partido AS id_partido,
    @v_fecha_hora_utc AS fecha_hora_utc,
    @v_id_huso AS id_huso,
    @v_id_jugador AS id_jugador,
    @v_id_moneda AS id_moneda,
    @v_fecha_cotizacion AS fecha_cotizacion,
    @v_importe AS importe_prueba;

-------------------------------------------------------------------------------
-- 1. geo.fn_FechaHoraLocal
-------------------------------------------------------------------------------
PRINT '';
PRINT '--- 1/5: geo.fn_FechaHoraLocal ---';

BEGIN TRY
    IF OBJECT_ID('geo.fn_FechaHoraLocal', 'F') IS NULL
        THROW 50001, 'No existe geo.fn_FechaHoraLocal', 1;

    IF @v_fecha_hora_utc IS NULL OR @v_id_huso IS NULL
        THROW 50001, 'No hay partido, sede, ciudad o huso para probar fn_FechaHoraLocal', 1;

    SELECT
        @v_id_partido AS id_partido,
        @v_fecha_hora_utc AS fecha_hora_utc,
        @v_id_huso AS id_huso,
        geo.fn_FechaHoraLocal(@v_fecha_hora_utc, @v_id_huso) AS fecha_hora_local;

    PRINT 'PASS 1/5: geo.fn_FechaHoraLocal se ejecuto correctamente.';
END TRY
BEGIN CATCH
    PRINT CONCAT('FAIL 1/5: ', ERROR_NUMBER(), ' - ', ERROR_MESSAGE());
END CATCH;

-------------------------------------------------------------------------------
-- 2. juego.fn_JugadorSuspendidoEnPartido
-------------------------------------------------------------------------------
PRINT '';
PRINT '--- 2/5: juego.fn_JugadorSuspendidoEnPartido ---';

BEGIN TRY
    IF OBJECT_ID('juego.fn_JugadorSuspendidoEnPartido', 'FN') IS NULL
        THROW 50001, 'No existe juego.fn_JugadorSuspendidoEnPartido', 1;

    IF @v_id_jugador IS NULL OR @v_id_partido IS NULL
        THROW 50001, 'No hay jugador o partido para probar la funcion de suspensio', 1;

    SELECT
        @v_id_jugador AS id_jugador,
        @v_id_partido AS id_partido,
        juego.fn_JugadorSuspendidoEnPartido
        (
            @v_id_jugador,
            @v_id_partido
        ) AS esta_suspendido;

    PRINT 'PASS 2/5: juego.fn_JugadorSuspendidoEnPartido se ejecuto correctamente.';
END TRY
BEGIN CATCH
    PRINT CONCAT('FAIL 2/5: ', ERROR_NUMBER(), ' - ', ERROR_MESSAGE());
END CATCH;

-------------------------------------------------------------------------------
-- 3. publicidad.fn_ImporteEnUSD
-------------------------------------------------------------------------------
PRINT '';
PRINT '--- 3/5: publicidad.fn_ImporteEnUSD ---';

BEGIN TRY
    IF OBJECT_ID('publicidad.fn_ImporteEnUSD', 'FN') IS NULL
        THROW 50001, 'No existe publicidad.fn_ImporteEnUSD', 1;

    IF @v_id_moneda IS NULL OR @v_fecha_cotizacion IS NULL
        THROW 50001, 'No hay una cotizacion disponible para probar fn_ImporteEnUSD', 1;

    SELECT
        @v_importe AS importe_origen,
        @v_id_moneda AS id_moneda,
        @v_fecha_cotizacion AS fecha_cotizacion,
        publicidad.fn_ImporteEnUSD
        (
            @v_importe,
            @v_id_moneda,
            @v_fecha_cotizacion
        ) AS importe_convertido_usd;

    PRINT 'PASS 3/5: publicidad.fn_ImporteEnUSD se ejecuto correctamente.';
END TRY
BEGIN CATCH
    PRINT CONCAT('FAIL 3/5: ', ERROR_NUMBER(), ' - ', ERROR_MESSAGE());
END CATCH;

-------------------------------------------------------------------------------
-- 4. torneo.vw_Posiciones
-------------------------------------------------------------------------------
PRINT '';
PRINT '--- 4/5: torneo.vw_Posiciones ---';

BEGIN TRY
    IF OBJECT_ID('torneo.vw_Posiciones', 'V') IS NULL
        THROW 50001, 'No existe torneo.vw_Posiciones', 1;

    SELECT TOP (32) *
    FROM torneo.vw_PosicionesGrupo;

    PRINT 'PASS 4/5: torneo.vw_Posiciones se consulto correctamente.';
END TRY
BEGIN CATCH
    PRINT CONCAT('FAIL 4/5: ', ERROR_NUMBER(), ' - ', ERROR_MESSAGE());
END CATCH;

-------------------------------------------------------------------------------
-- 5. juego.vw_Goleadores
-------------------------------------------------------------------------------
PRINT '';
PRINT '--- 5/5: juego.vw_Goleadores ---';

BEGIN TRY
    IF OBJECT_ID('juego.vw_Goleadores', 'V') IS NULL
        THROW 50001, 'No existe juego.vw_Goleadores', 1;

    SELECT TOP (10) *
    FROM juego.vw_Goleadores;

    PRINT 'PASS 5/5: juego.vw_Goleadores se consulto correctamente.';
END TRY
BEGIN CATCH
    PRINT CONCAT('FAIL 5/5: ', ERROR_NUMBER(), ' - ', ERROR_MESSAGE());
END CATCH;

PRINT '';
PRINT '=====================================================================';
PRINT 'FIN PRUEBAS: 78_Test_Funciones_Vistas';
PRINT 'PRUEBA DE SOLO LECTURA: NO SE REQUIERE TRANSACCION NI ROLLBACK';
PRINT '=====================================================================';
GO
