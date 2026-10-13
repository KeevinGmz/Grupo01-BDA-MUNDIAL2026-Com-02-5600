/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Validar errores de los SP de eventos de juego:autor y asistente iguales; jugador saliente fuera de cancha; arbitro no designado.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS DE ERROR: 71_Test_ERR_Eventos';
PRINT N'=====================================================================';
GO

/* =====================================================================
   CASO 1: autor y asistente del gol son la misma persona
===================================================================== */
PRINT N'';
PRINT N'-> Test 1: registrar gol con autor igual al asistente';

DECLARE @v_id_partido INT;
DECLARE @v_id_seleccion INT;
DECLARE @v_id_jugador INT;
DECLARE @v_nro_gol TINYINT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_filas_antes INT;
DECLARE @v_filas_despues INT;

IF OBJECT_ID(N'juego.usp_Negocio_RegistrarGol', N'P') IS NULL
BEGIN
    ;THROW 50001,N'71_Test_ERR_Eventos: no existe juego.usp_Negocio_RegistrarGol',1;
END;

SELECT TOP (1)
    @v_id_partido = a.id_partido,
    @v_id_seleccion = a.id_seleccion,
    @v_id_jugador = a.id_jugador
FROM juego.alineacion AS a
JOIN torneo.partido AS p
  ON p.id_partido = a.id_partido
WHERE p.estado = 'EN_CURSO'
  AND a.es_titular = 1
ORDER BY a.id_partido, a.id_seleccion, a.dorsal, a.id_jugador;

IF @v_id_partido IS NULL
   OR @v_id_seleccion IS NULL
   OR @v_id_jugador IS NULL
BEGIN
    ;THROW 50001,N'71_Test_ERR_Eventos: se requiere un partido EN_CURSO con un titular alineado para el Test 1', 1;
END;

SELECT @v_filas_antes = COUNT(*)
FROM juego.gol AS g
WHERE g.id_partido = @v_id_partido
  AND g.id_seleccion = @v_id_seleccion;

BEGIN TRANSACTION;

BEGIN TRY
    EXEC juego.usp_Negocio_RegistrarGol
        @id_partido = @v_id_partido,
        @id_seleccion = @v_id_seleccion,
        @id_jugador_autor = @v_id_jugador,
        @id_jugador_asistente = @v_id_jugador,
        @minuto = 25,
        @tipo_gol = 'JUGADA',
        @en_contra = 0,
        @periodo = 'PT',
        @nro_gol = @v_nro_gol OUTPUT;

    SET @v_error_numero = 0;
    SET @v_error_mensaje = N'El SP permitio que autor y asistente fueran iguales';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

SELECT @v_filas_despues = COUNT(*)
FROM juego.gol AS g
WHERE g.id_partido = @v_id_partido
  AND g.id_seleccion = @v_id_seleccion;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

PRINT CONCAT(N'Error capturado ', @v_error_numero, N': ', @v_error_mensaje);

IF @v_error_numero IN (50001, 50003)
   AND
   (
       @v_error_mensaje LIKE N'%autor%asistente%distint%'
       OR @v_error_mensaje LIKE N'%autor%asistente%igual%'
       OR @v_error_mensaje LIKE N'%mismo%jugador%'
   )
   AND @v_filas_despues = @v_filas_antes
BEGIN
    PRINT N'PASS Test 1: se rechazo el gol con autor y asistente iguales.';
END
ELSE
BEGIN
    PRINT N'FAIL Test 1: numero, mensaje o persistencia distintos de lo esperado.';
END;
GO

/* =====================================================================
   CASO 2: el jugador que sale no esta en cancha
===================================================================== */
PRINT N'';
PRINT N'-> Test 2: sustituir a un jugador que no esta en cancha';

DECLARE @v_id_partido INT;
DECLARE @v_id_seleccion INT;
DECLARE @v_jugador_sale INT;
DECLARE @v_jugador_entra INT;
DECLARE @v_nro_sustitucion TINYINT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_filas_antes INT;
DECLARE @v_filas_despues INT;

IF OBJECT_ID(N'juego.usp_Negocio_RegistrarSustitucion', N'P') IS NULL
BEGIN
    ;THROW 50001,N'71_Test_ERR_Eventos: no existe juego.usp_Negocio_RegistrarSustitucion',1;
END;

;WITH suplentes AS
(
    SELECT
        a.id_partido,
        a.id_seleccion,
        a.id_jugador,
        ROW_NUMBER() OVER
        (
            PARTITION BY a.id_partido, a.id_seleccion
            ORDER BY a.dorsal, a.id_jugador
        ) AS rn
    FROM juego.alineacion AS a
    JOIN torneo.partido AS p
      ON p.id_partido = a.id_partido
    WHERE p.estado = 'EN_CURSO'
      AND a.es_titular = 0
)
SELECT TOP (1)
    @v_id_partido = s1.id_partido,
    @v_id_seleccion = s1.id_seleccion,
    @v_jugador_sale = s1.id_jugador,
    @v_jugador_entra = s2.id_jugador
FROM suplentes AS s1
JOIN suplentes AS s2
  ON s2.id_partido = s1.id_partido
 AND s2.id_seleccion = s1.id_seleccion
 AND s2.rn = 2
WHERE s1.rn = 1
ORDER BY s1.id_partido, s1.id_seleccion;

IF @v_id_partido IS NULL
   OR @v_id_seleccion IS NULL
   OR @v_jugador_sale IS NULL
   OR @v_jugador_entra IS NULL
BEGIN
    ;THROW 50001, N'71_Test_ERR_Eventos: se requiere un partido EN_CURSO con al menos dos suplentes para el Test 2',1;
END;

SELECT @v_filas_antes = COUNT(*)
FROM juego.sustitucion AS s
WHERE s.id_partido = @v_id_partido
  AND s.id_seleccion = @v_id_seleccion;

BEGIN TRANSACTION;

BEGIN TRY
    EXEC juego.usp_Negocio_RegistrarSustitucion
        @id_partido = @v_id_partido,
        @id_seleccion = @v_id_seleccion,
        @id_jugador_sale = @v_jugador_sale,
        @id_jugador_entra = @v_jugador_entra,
        @minuto = 60,
        @motivo = 'TACTICA',
        @nro_sustitucion = @v_nro_sustitucion OUTPUT;

    SET @v_error_numero = 0;
    SET @v_error_mensaje = N'El SP permitio que saliera un jugador que no estaba en cancha';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

SELECT @v_filas_despues = COUNT(*)
FROM juego.sustitucion AS s
WHERE s.id_partido = @v_id_partido
  AND s.id_seleccion = @v_id_seleccion;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

PRINT CONCAT(N'Error capturado ', @v_error_numero, N': ', @v_error_mensaje);

IF @v_error_numero IN (50001, 50003)
   AND
   (
       @v_error_mensaje LIKE N'%sale%cancha%'
       OR @v_error_mensaje LIKE N'%jugador%no%esta%cancha%'
       OR @v_error_mensaje LIKE N'%jugador saliente%titular%'
   )
   AND @v_filas_despues = @v_filas_antes
BEGIN
    PRINT N'PASS Test 2: se rechazo la salida de un jugador que no estaba en cancha.';
END
ELSE
BEGIN
    PRINT N'FAIL Test 2: numero, mensaje o persistencia distintos de lo esperado.';
END;
GO

/* =====================================================================
   CASO 3: tarjeta aplicada por un arbitro no designado
===================================================================== */
PRINT N'';
PRINT N'-> Test 3: registrar tarjeta con un arbitro no designado';

DECLARE @v_id_partido INT;
DECLARE @v_id_seleccion INT;
DECLARE @v_id_jugador INT;
DECLARE @v_id_arbitro_no_designado INT;
DECLARE @v_id_tipo_tarjeta TINYINT;
DECLARE @v_nro_tarjeta TINYINT;
DECLARE @v_id_suspension INT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_filas_antes INT;
DECLARE @v_filas_despues INT;

IF OBJECT_ID(N'juego.usp_Negocio_RegistrarTarjeta', N'P') IS NULL
BEGIN
    ;THROW 50001,N'71_Test_ERR_Eventos: no existe juego.usp_Negocio_RegistrarTarjeta',1;
END;

SELECT TOP (1)
    @v_id_partido = a.id_partido,
    @v_id_seleccion = a.id_seleccion,
    @v_id_jugador = a.id_jugador
FROM juego.alineacion AS a
JOIN torneo.partido AS p
  ON p.id_partido = a.id_partido
WHERE p.estado = 'EN_CURSO'
  AND a.es_titular = 1
ORDER BY a.id_partido, a.id_seleccion, a.dorsal, a.id_jugador;

SELECT TOP (1)
    @v_id_arbitro_no_designado = ar.id_persona
FROM persona.arbitro AS ar
WHERE NOT EXISTS
      (
          SELECT 1
          FROM arbitraje.designacion_arbitral AS da
          WHERE da.id_partido = @v_id_partido
            AND da.id_arbitro = ar.id_persona
            AND da.estado = 'DESIGNADA'
      )
ORDER BY ar.id_persona;

-- No se supone que la tarjeta amarilla tenga id_tipo = 1.
SELECT TOP (1)
    @v_id_tipo_tarjeta = tt.id_tipo
FROM juego.tipo_tarjeta AS tt
WHERE UPPER(tt.descripcion) LIKE N'%AMARILL%'
ORDER BY tt.id_tipo;

IF @v_id_partido IS NULL
   OR @v_id_seleccion IS NULL
   OR @v_id_jugador IS NULL
   OR @v_id_arbitro_no_designado IS NULL
   OR @v_id_tipo_tarjeta IS NULL
BEGIN
    ;THROW 50001,N'71_Test_ERR_Eventos: se requiere un partido EN_CURSO, titular, tarjeta amarilla y arbitro no designado para el Test 3',1;
END;

SELECT @v_filas_antes = COUNT(*)
FROM juego.tarjeta AS t
WHERE t.id_partido = @v_id_partido
  AND t.id_seleccion = @v_id_seleccion;

BEGIN TRANSACTION;

BEGIN TRY
    EXEC juego.usp_Negocio_RegistrarTarjeta
        @id_partido = @v_id_partido,
        @id_seleccion = @v_id_seleccion,
        @id_jugador = @v_id_jugador,
        @id_tipo = @v_id_tipo_tarjeta,
        @id_arbitro = @v_id_arbitro_no_designado,
        @minuto = 30,
        @motivo = N'Conducta antideportiva',
        @nro_tarjeta = @v_nro_tarjeta OUTPUT,
        @id_suspension = @v_id_suspension OUTPUT;

    SET @v_error_numero = 0;
    SET @v_error_mensaje = N'El SP permitio una tarjeta aplicada por un arbitro no designado';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

SELECT @v_filas_despues = COUNT(*)
FROM juego.tarjeta AS t
WHERE t.id_partido = @v_id_partido
  AND t.id_seleccion = @v_id_seleccion;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

PRINT CONCAT(N'Error capturado ', @v_error_numero, N': ', @v_error_mensaje);

SELECT
    @v_id_partido AS id_partido_prueba,
    @v_id_arbitro_no_designado AS arbitro_no_designado,
    @v_filas_antes AS filas_antes,
    @v_filas_despues AS filas_despues;

IF @v_error_numero IN (50001, 50003)
   AND
   (
       @v_error_mensaje LIKE N'%arbitro%no%designad%'
       OR @v_error_mensaje LIKE N'%arbitro%terna%'
       OR @v_error_mensaje LIKE N'%designacion%arbitral%'
   )
   AND @v_filas_despues = @v_filas_antes
BEGIN
    PRINT N'PASS Test 3: se rechazo la tarjeta del arbitro no designado.';
END
ELSE
BEGIN
    PRINT N'FAIL Test 3: numero, mensaje o persistencia distintos de lo esperado.';
END;
GO

PRINT N'';
PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS DE ERROR: 71_Test_ERR_Eventos';
PRINT N'CADA CASO EJECUTO SU PROPIO ROLLBACK';
PRINT N'=====================================================================';
GO
