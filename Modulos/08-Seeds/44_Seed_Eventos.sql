/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Carga inicial de eventos para demostrar sustitucion temprana, doble amarilla, roja directa y acumulacion de amarillas.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @v_errores NVARCHAR(2000) = N'';
DECLARE @v_propia BIT = 0;
DECLARE @v_sp BIT = 0;

-------------------------------------------------------------------------------
-- 1. Validaciones de objetos y catalogos
-------------------------------------------------------------------------------

IF OBJECT_ID(N'juego.usp_Negocio_RegistrarSustitucion', N'P') IS NULL
    SET @v_errores += N'no existe juego.usp_Negocio_RegistrarSustitucion; ';

IF OBJECT_ID(N'juego.usp_Negocio_RegistrarTarjeta', N'P') IS NULL
    SET @v_errores += N'no existe juego.usp_Negocio_RegistrarTarjeta; ';

IF OBJECT_ID(N'torneo.usp_Partido_Modificar', N'P') IS NULL
    SET @v_errores += N'no existe torneo.usp_Partido_Modificar; ';

DECLARE @v_tipo_amarilla TINYINT;
DECLARE @v_tipo_roja_directa TINYINT;
DECLARE @v_tipo_roja_doble TINYINT;

SELECT @v_tipo_amarilla = tt.id_tipo
FROM juego.tipo_tarjeta AS tt
WHERE tt.descripcion = N'AMARILLA';

SELECT @v_tipo_roja_directa = tt.id_tipo
FROM juego.tipo_tarjeta AS tt
WHERE tt.descripcion = N'ROJA_DIRECTA';

SELECT @v_tipo_roja_doble = tt.id_tipo
FROM juego.tipo_tarjeta AS tt
WHERE tt.descripcion = N'ROJA_DOBLE_AMARILLA';

IF @v_tipo_amarilla IS NULL
    SET @v_errores += N'no existe el tipo AMARILLA; ';

IF @v_tipo_roja_directa IS NULL
    SET @v_errores += N'no existe el tipo ROJA_DIRECTA; ';

IF @v_tipo_roja_doble IS NULL
    SET @v_errores += N'no existe el tipo ROJA_DOBLE_AMARILLA; ';

IF NOT EXISTS
(
    SELECT 1
    FROM juego.criterio_suspension AS cs
    WHERE cs.id_tipo = @v_tipo_amarilla
      AND cs.vigente = 1
)
    SET @v_errores += N'no existe criterio vigente para AMARILLA; ';

IF NOT EXISTS
(
    SELECT 1
    FROM juego.criterio_suspension AS cs
    WHERE cs.id_tipo = @v_tipo_roja_directa
      AND cs.vigente = 1
)
    SET @v_errores += N'no existe criterio vigente para ROJA_DIRECTA; ';

IF NOT EXISTS
(
    SELECT 1
    FROM juego.criterio_suspension AS cs
    WHERE cs.id_tipo = @v_tipo_roja_doble
      AND cs.vigente = 1
)
    SET @v_errores += N'no existe criterio vigente para ROJA_DOBLE_AMARILLA; ';

IF @v_errores <> N''
BEGIN
    SET @v_errores = LEFT(CONCAT(N'44_Seed_Eventos: ', @v_errores), 2048);
    ;THROW 50001, @v_errores, 1;
END;

-------------------------------------------------------------------------------
-- 2. Buscar una seleccion con tres partidos aptos
--
-- Los partidos deben tener alineacion para la seleccion, arbitro designado y
-- no poseer eventos previos de esa seleccion. Se usan IDs reales.
-------------------------------------------------------------------------------

DECLARE @v_id_seleccion INT;

;WITH aptos AS
(
    SELECT
        ep.id_seleccion,
        p.id_partido,
        p.fecha_hora_utc
    FROM torneo.partido AS p
    JOIN torneo.equipo_en_partido AS ep
      ON ep.id_partido = p.id_partido
    WHERE EXISTS
          (
              SELECT 1
              FROM juego.alineacion AS a
              WHERE a.id_partido = p.id_partido
                AND a.id_seleccion = ep.id_seleccion
          )
      AND EXISTS
          (
              SELECT 1
              FROM arbitraje.designacion_arbitral AS da
              WHERE da.id_partido = p.id_partido
                AND da.estado = 'DESIGNADA'
          )
      AND NOT EXISTS
          (
              SELECT 1
              FROM juego.sustitucion AS s
              WHERE s.id_partido = p.id_partido
                AND s.id_seleccion = ep.id_seleccion
          )
      AND NOT EXISTS
          (
              SELECT 1
              FROM juego.tarjeta AS t
              WHERE t.id_partido = p.id_partido
                AND t.id_seleccion = ep.id_seleccion
          )
)
SELECT TOP (1) @v_id_seleccion = a.id_seleccion
FROM aptos AS a
GROUP BY a.id_seleccion
HAVING COUNT(*) >= 3
ORDER BY a.id_seleccion;

IF @v_id_seleccion IS NULL
BEGIN
    ;THROW 50003,
           N'44_Seed_Eventos: no existe una seleccion con tres partidos alineados, sin eventos y con arbitros designados. Ejecute antes el seed de designaciones arbitrales.',
           1;
END;

DECLARE @v_partidos TABLE
(
    orden TINYINT NOT NULL PRIMARY KEY,
    id_partido INT NOT NULL UNIQUE,
    fecha_hora_utc DATETIME2(0) NOT NULL,
    id_sede INT NOT NULL,
    nro_fase TINYINT NOT NULL,
    definido_por_penales BIT NOT NULL,
    asistencia_publico INT NULL,
    id_arbitro INT NOT NULL
);

;WITH partidos_aptos AS
(
    SELECT TOP (3)
        p.id_partido,
        p.fecha_hora_utc,
        p.id_sede,
        p.nro_fase,
        p.definido_por_penales,
        p.asistencia_publico,
        arbitro.id_arbitro
    FROM torneo.partido AS p
    JOIN torneo.equipo_en_partido AS ep
      ON ep.id_partido = p.id_partido
     AND ep.id_seleccion = @v_id_seleccion
    CROSS APPLY
    (
        SELECT TOP (1) da.id_arbitro
        FROM arbitraje.designacion_arbitral AS da
        JOIN arbitraje.rol_arbitral AS ra
          ON ra.id_rol = da.id_rol
        WHERE da.id_partido = p.id_partido
          AND da.estado = 'DESIGNADA'
        ORDER BY
            CASE WHEN ra.descripcion = N'PRINCIPAL' THEN 0 ELSE 1 END,
            da.id_rol
    ) AS arbitro
    WHERE EXISTS
          (
              SELECT 1
              FROM juego.alineacion AS a
              WHERE a.id_partido = p.id_partido
                AND a.id_seleccion = @v_id_seleccion
          )
      AND NOT EXISTS
          (
              SELECT 1
              FROM juego.sustitucion AS s
              WHERE s.id_partido = p.id_partido
                AND s.id_seleccion = @v_id_seleccion
          )
      AND NOT EXISTS
          (
              SELECT 1
              FROM juego.tarjeta AS t
              WHERE t.id_partido = p.id_partido
                AND t.id_seleccion = @v_id_seleccion
          )
    ORDER BY p.fecha_hora_utc, p.id_partido
)
INSERT INTO @v_partidos
(
    orden,
    id_partido,
    fecha_hora_utc,
    id_sede,
    nro_fase,
    definido_por_penales,
    asistencia_publico,
    id_arbitro
)
SELECT
    CONVERT(TINYINT, ROW_NUMBER() OVER (ORDER BY pa.fecha_hora_utc, pa.id_partido)),
    pa.id_partido,
    pa.fecha_hora_utc,
    pa.id_sede,
    pa.nro_fase,
    pa.definido_por_penales,
    pa.asistencia_publico,
    pa.id_arbitro
FROM partidos_aptos AS pa;

-------------------------------------------------------------------------------
-- 3. Identificar jugadores reales de las alineaciones
-------------------------------------------------------------------------------

DECLARE @v_partido_1 INT;
DECLARE @v_partido_2 INT;
DECLARE @v_partido_3 INT;
DECLARE @v_arbitro_1 INT;
DECLARE @v_arbitro_2 INT;
DECLARE @v_arbitro_3 INT;

SELECT @v_partido_1 = id_partido, @v_arbitro_1 = id_arbitro FROM @v_partidos WHERE orden = 1;
SELECT @v_partido_2 = id_partido, @v_arbitro_2 = id_arbitro FROM @v_partidos WHERE orden = 2;
SELECT @v_partido_3 = id_partido, @v_arbitro_3 = id_arbitro FROM @v_partidos WHERE orden = 3;

DECLARE @v_sale INT;
DECLARE @v_entra INT;
DECLARE @v_doble_amarilla INT;
DECLARE @v_roja_directa INT;
DECLARE @v_acumulacion INT;

-- Titular que sale y suplente que entra en el partido 1.
SELECT TOP (1) @v_sale = a.id_jugador
FROM juego.alineacion AS a
WHERE a.id_partido = @v_partido_1
  AND a.id_seleccion = @v_id_seleccion
  AND a.es_titular = 1
ORDER BY a.dorsal;

SELECT TOP (1) @v_entra = a.id_jugador
FROM juego.alineacion AS a
WHERE a.id_partido = @v_partido_1
  AND a.id_seleccion = @v_id_seleccion
  AND a.es_titular = 0
ORDER BY a.dorsal;

-- Otro titular recibe doble amarilla en el partido 1.
SELECT TOP (1) @v_doble_amarilla = a.id_jugador
FROM juego.alineacion AS a
WHERE a.id_partido = @v_partido_1
  AND a.id_seleccion = @v_id_seleccion
  AND a.es_titular = 1
  AND a.id_jugador <> @v_sale
ORDER BY a.dorsal;

-- Titular del partido 2 para roja directa.
SELECT TOP (1) @v_roja_directa = a.id_jugador
FROM juego.alineacion AS a
WHERE a.id_partido = @v_partido_2
  AND a.id_seleccion = @v_id_seleccion
  AND a.es_titular = 1
  AND a.id_jugador <> @v_doble_amarilla
ORDER BY a.dorsal;

-- Jugador titular en partidos 1 y 2 para acumulacion de amarillas.
SELECT TOP (1) @v_acumulacion = a1.id_jugador
FROM juego.alineacion AS a1
JOIN juego.alineacion AS a2
  ON a2.id_jugador = a1.id_jugador
 AND a2.id_partido = @v_partido_2
 AND a2.id_seleccion = @v_id_seleccion
 AND a2.es_titular = 1
WHERE a1.id_partido = @v_partido_1
  AND a1.id_seleccion = @v_id_seleccion
  AND a1.es_titular = 1
  AND a1.id_jugador NOT IN (@v_sale, @v_doble_amarilla, @v_roja_directa)
ORDER BY a1.dorsal;

IF @v_sale IS NULL OR @v_entra IS NULL OR @v_doble_amarilla IS NULL
   OR @v_roja_directa IS NULL OR @v_acumulacion IS NULL
BEGIN
    ;THROW 50003,
           N'44_Seed_Eventos: no se pudieron seleccionar jugadores aptos de las alineaciones',
           1;
END;

-------------------------------------------------------------------------------
-- 4. Registrar los casos dentro de una unica transaccion
-------------------------------------------------------------------------------

BEGIN TRY
    IF @@TRANCOUNT = 0
    BEGIN
        BEGIN TRANSACTION;
        SET @v_propia = 1;
    END
    ELSE
    BEGIN
        SAVE TRANSACTION sv_seed_eventos;
        SET @v_sp = 1;
    END;

    -- Los eventos se registran con el partido EN_CURSO mediante el ABM.
    DECLARE @v_orden TINYINT = 1;
    DECLARE @v_id_partido INT;
    DECLARE @v_fecha DATETIME2(0);
    DECLARE @v_asistencia INT;
    DECLARE @v_penales BIT;
    DECLARE @v_id_sede INT;
    DECLARE @v_nro_fase TINYINT;

    WHILE @v_orden <= 3
    BEGIN
        SELECT
            @v_id_partido = p.id_partido,
            @v_fecha = p.fecha_hora_utc,
            @v_asistencia = p.asistencia_publico,
            @v_penales = p.definido_por_penales,
            @v_id_sede = p.id_sede,
            @v_nro_fase = p.nro_fase
        FROM @v_partidos AS p
        WHERE p.orden = @v_orden;

        EXEC torneo.usp_Partido_Modificar
            @id_partido = @v_id_partido,
            @fecha_hora_utc = @v_fecha,
            @asistencia_publico = @v_asistencia,
            @definido_por_penales = @v_penales,
            @estado = 'EN_CURSO',
            @id_sede = @v_id_sede,
            @nro_fase = @v_nro_fase;

        SET @v_orden += 1;
    END;

    DECLARE @v_nro_sustitucion TINYINT;
    DECLARE @v_nro_tarjeta TINYINT;
    DECLARE @v_id_suspension INT;

    ---------------------------------------------------------------------------
    -- Caso 3: sustitucion por lesion antes del minuto 20
    ---------------------------------------------------------------------------
    EXEC juego.usp_Negocio_RegistrarSustitucion
        @id_partido = @v_partido_1,
        @id_seleccion = @v_id_seleccion,
        @id_jugador_sale = @v_sale,
        @id_jugador_entra = @v_entra,
        @minuto = 15,
        @motivo = 'LESION',
        @nro_sustitucion = @v_nro_sustitucion OUTPUT;

    ---------------------------------------------------------------------------
    -- Caso 1: doble amarilla en el partido 1
    -- El llamador siempre envia AMARILLA; el SP convierte la segunda.
    ---------------------------------------------------------------------------
    EXEC juego.usp_Negocio_RegistrarTarjeta
        @id_partido = @v_partido_1,
        @id_seleccion = @v_id_seleccion,
        @id_jugador = @v_doble_amarilla,
        @id_arbitro = @v_arbitro_1,
        @minuto = 30,
        @id_tipo = @v_tipo_amarilla,
        @motivo = N'Falta tactica',
        @nro_tarjeta = @v_nro_tarjeta OUTPUT,
        @id_suspension = @v_id_suspension OUTPUT;

    EXEC juego.usp_Negocio_RegistrarTarjeta
        @id_partido = @v_partido_1,
        @id_seleccion = @v_id_seleccion,
        @id_jugador = @v_doble_amarilla,
        @id_arbitro = @v_arbitro_1,
        @minuto = 60,
        @id_tipo = @v_tipo_amarilla,
        @motivo = N'Segunda amonestacion',
        @nro_tarjeta = @v_nro_tarjeta OUTPUT,
        @id_suspension = @v_id_suspension OUTPUT;

    ---------------------------------------------------------------------------
    -- Caso 1: roja directa en un partido distinto
    ---------------------------------------------------------------------------
    EXEC juego.usp_Negocio_RegistrarTarjeta
        @id_partido = @v_partido_2,
        @id_seleccion = @v_id_seleccion,
        @id_jugador = @v_roja_directa,
        @id_arbitro = @v_arbitro_2,
        @minuto = 10,
        @id_tipo = @v_tipo_roja_directa,
        @motivo = N'Conducta violenta',
        @nro_tarjeta = @v_nro_tarjeta OUTPUT,
        @id_suspension = @v_id_suspension OUTPUT;

    ---------------------------------------------------------------------------
    -- Caso 2: acumulacion de amarillas en partidos distintos
    ---------------------------------------------------------------------------
    EXEC juego.usp_Negocio_RegistrarTarjeta
        @id_partido = @v_partido_1,
        @id_seleccion = @v_id_seleccion,
        @id_jugador = @v_acumulacion,
        @id_arbitro = @v_arbitro_1,
        @minuto = 40,
        @id_tipo = @v_tipo_amarilla,
        @motivo = N'Falta reiterada',
        @nro_tarjeta = @v_nro_tarjeta OUTPUT,
        @id_suspension = @v_id_suspension OUTPUT;

    EXEC juego.usp_Negocio_RegistrarTarjeta
        @id_partido = @v_partido_2,
        @id_seleccion = @v_id_seleccion,
        @id_jugador = @v_acumulacion,
        @id_arbitro = @v_arbitro_2,
        @minuto = 35,
        @id_tipo = @v_tipo_amarilla,
        @motivo = N'Falta reiterada',
        @nro_tarjeta = @v_nro_tarjeta OUTPUT,
        @id_suspension = @v_id_suspension OUTPUT;

    IF @v_propia = 1
        COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @v_propia = 1 AND @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    ELSE IF @v_sp = 1 AND XACT_STATE() = 1
        ROLLBACK TRANSACTION sv_seed_eventos;
    ;THROW;
END CATCH;
GO

-------------------------------------------------------------------------------
-- 5. Evidencia final
-------------------------------------------------------------------------------

SELECT
    s.id_partido,
    s.id_seleccion,
    s.nro_sustitucion,
    s.minuto,
    s.motivo,
    s.id_jugador_sale,
    s.id_jugador_entra
FROM juego.sustitucion AS s
WHERE s.minuto = 15
  AND s.motivo = 'LESION'
ORDER BY s.id_partido, s.id_seleccion, s.nro_sustitucion;

SELECT
    t.id_partido,
    t.id_seleccion,
    t.nro_tarjeta,
    t.minuto,
    tt.descripcion AS tipo_tarjeta,
    t.id_jugador,
    t.id_arbitro,
    t.motivo
FROM juego.tarjeta AS t
JOIN juego.tipo_tarjeta AS tt
  ON tt.id_tipo = t.id_tipo
ORDER BY t.id_partido, t.id_seleccion, t.nro_tarjeta;

SELECT
    s.id_suspension,
    s.id_jugador,
    tt.descripcion AS origen,
    s.cant_partidos,
    s.estado,
    s.fecha_alta,
    s.motivo
FROM juego.suspension AS s
JOIN juego.criterio_suspension AS cs
  ON cs.id_criterio = s.id_criterio
JOIN juego.tipo_tarjeta AS tt
  ON tt.id_tipo = cs.id_tipo
ORDER BY s.id_suspension;
GO
