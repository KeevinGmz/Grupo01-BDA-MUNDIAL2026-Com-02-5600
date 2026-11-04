/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Crea los tipos de tabla, funciones auxiliares y vistas derivadas requeridos por los procedimientos de logica de negocio.
===================================================================== */
USE Mundial2026;
GO

-- ============================================================================
-- 1. TIPOS DE TABLA
-- ============================================================================

CREATE TYPE torneo.tt_Convocado AS TABLE (
    id_jugador INT NOT NULL PRIMARY KEY,
    dorsal     TINYINT NOT NULL
);
GO

CREATE TYPE juego.tt_Alineacion AS TABLE (
    id_jugador           INT NOT NULL PRIMARY KEY,
    dorsal               TINYINT NOT NULL,
    es_titular           BIT NOT NULL,
    id_posicion          TINYINT NOT NULL,
    es_posicion_habitual BIT NOT NULL
);
GO

CREATE TYPE arbitraje.tt_Designacion AS TABLE (
    id_rol     TINYINT NOT NULL PRIMARY KEY,
    id_arbitro INT NOT NULL
);
GO

-- ============================================================================
-- 2. FUNCIONES AUXILIARES
-- ============================================================================

-- Jugadores que se encuentran en cancha para un equipo y minuto determinados.
CREATE OR ALTER FUNCTION juego.fn_EquipoEnCancha
(
    @id_partido   INT,
    @id_seleccion INT,
    @minuto       SMALLINT
)
RETURNS TABLE
AS
RETURN
(
    SELECT a.id_jugador
    FROM juego.alineacion AS a
    WHERE a.id_partido = @id_partido
      AND a.id_seleccion = @id_seleccion
      AND
      (
          a.es_titular = 1
          OR EXISTS
          (
              SELECT 1
              FROM juego.sustitucion AS s
              WHERE s.id_partido = a.id_partido
                AND s.id_seleccion = a.id_seleccion
                AND s.id_jugador_entra = a.id_jugador
                AND s.minuto <= @minuto
          )
      )
      AND NOT EXISTS
      (
          SELECT 1
          FROM juego.sustitucion AS s
          WHERE s.id_partido = a.id_partido
            AND s.id_seleccion = a.id_seleccion
            AND s.id_jugador_sale = a.id_jugador
            AND s.minuto <= @minuto
      )
      AND NOT EXISTS
      (
          SELECT 1
          FROM juego.tarjeta AS t
          JOIN juego.tipo_tarjeta AS tt
            ON tt.id_tipo = t.id_tipo
          WHERE t.id_partido = a.id_partido
            AND t.id_seleccion = a.id_seleccion
            AND t.id_jugador = a.id_jugador
            AND tt.descripcion IN ('ROJA_DOBLE_AMARILLA', 'ROJA_DIRECTA')
            AND t.minuto <= @minuto
      )
);
GO



-- Huso de un pais: huso de su ciudad mas poblada.
CREATE OR ALTER FUNCTION geo.fn_HusoDePais
(
    @id_pais SMALLINT
)
RETURNS SMALLINT
AS
BEGIN
    RETURN
    (
        SELECT TOP (1) c.id_huso
        FROM geo.ciudad AS c
        WHERE c.id_pais = @id_pais
        ORDER BY c.poblacion DESC, c.id_ciudad
    );
END;
GO



-- Convierte una fecha/hora UTC a la hora del huso indicado.
CREATE OR ALTER FUNCTION geo.fn_FechaHoraLocal
(
    @fecha_hora_utc DATETIME2(0),
    @id_huso        SMALLINT
)
RETURNS DATETIME2(0)
AS
BEGIN
    RETURN
    (
        SELECT DATEADD
        (
            MINUTE,
            h.offset_utc + CASE WHEN h.horario_verano = 1 THEN 60 ELSE 0 END,
            @fecha_hora_utc
        )
        FROM geo.huso_horario AS h
        WHERE h.id_huso = @id_huso
    );
END;
GO


-- Indica si un jugador debe cumplir una suspension en un partido determinado.
CREATE OR ALTER FUNCTION juego.fn_JugadorSuspendidoEnPartido
(
    @id_jugador INT,
    @id_partido INT
)
RETURNS BIT
AS
BEGIN
    RETURN
    (
        SELECT CASE WHEN EXISTS
        (
            SELECT 1
            FROM juego.suspension AS s
            JOIN torneo.partido AS p
              ON p.id_partido = @id_partido
            JOIN torneo.convocatoria AS c
              ON c.id_jugador = s.id_jugador
            JOIN torneo.equipo_en_partido AS e
              ON e.id_partido = p.id_partido
             AND e.id_seleccion = c.id_seleccion
            WHERE s.id_jugador = @id_jugador
              AND s.estado <> 'ANULADA'
              AND p.fecha_hora_utc > s.fecha_alta
              AND
              (
                  SELECT COUNT(*)
                  FROM torneo.equipo_en_partido AS e2
                  JOIN torneo.partido AS p2
                    ON p2.id_partido = e2.id_partido
                  WHERE e2.id_seleccion = c.id_seleccion
                    AND p2.estado <> 'SUSPENDIDO'
                    AND p2.fecha_hora_utc > s.fecha_alta
                    AND p2.fecha_hora_utc < p.fecha_hora_utc
              ) < s.cant_partidos
        ) THEN 1 ELSE 0 END
    );
END;
GO


-- Determina si la hora de un partido cae en prime time local del mercado.
CREATE OR ALTER FUNCTION publicidad.fn_EsPrimeTime
(
    @id_partido      INT,
    @id_pais_mercado SMALLINT
)
RETURNS BIT
AS
BEGIN
    DECLARE @v_hora TIME(0);
    DECLARE @v_desde INT;
    DECLARE @v_hasta INT;
    DECLARE @v_fecha_partido DATE;
    DECLARE @v_id_huso SMALLINT;

    SELECT @v_fecha_partido = CAST(p.fecha_hora_utc AS DATE),
           @v_id_huso = geo.fn_HusoDePais(@id_pais_mercado),
           @v_hora = CAST(geo.fn_FechaHoraLocal(p.fecha_hora_utc, geo.fn_HusoDePais(@id_pais_mercado)) AS TIME(0))
    FROM torneo.partido AS p
    WHERE p.id_partido = @id_partido;

    SELECT TOP (1) @v_desde = CONVERT(INT, pr.valor)
    FROM torneo.parametro_reglamento AS pr
    WHERE pr.clave = 'PRIME_DESDE_HORA'
      AND pr.vigente_desde <= @v_fecha_partido
    ORDER BY pr.vigente_desde DESC;

    SELECT TOP (1) @v_hasta = CONVERT(INT, pr.valor)
    FROM torneo.parametro_reglamento AS pr
    WHERE pr.clave = 'PRIME_HASTA_HORA'
      AND pr.vigente_desde <= @v_fecha_partido
    ORDER BY pr.vigente_desde DESC;

    RETURN
    (
        CASE
            WHEN @v_hora IS NOT NULL
             AND @v_desde IS NOT NULL
             AND @v_hasta IS NOT NULL
             AND DATEPART(HOUR, @v_hora) >= @v_desde
             AND DATEPART(HOUR, @v_hora) < @v_hasta
            THEN 1
            ELSE 0
        END
    );
END;
GO


-- Convierte un importe a USD con la ultima cotizacion disponible a la fecha.
CREATE OR ALTER FUNCTION publicidad.fn_ImporteEnUSD
(
    @importe   DECIMAL(18,2),
    @id_moneda TINYINT,
    @fecha     DATE
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @v_cotizacion DECIMAL(18,6);

    SELECT TOP (1) @v_cotizacion = tc.cotizacion_usd
    FROM publicidad.tipo_cambio AS tc
    WHERE tc.id_moneda = @id_moneda
      AND tc.fecha <= @fecha
    ORDER BY tc.fecha DESC;

    RETURN CONVERT(DECIMAL(18,2), @importe * @v_cotizacion);
END;
GO


-- ============================================================================
-- 3. VISTAS DERIVADAS
-- ============================================================================

-- Goles acreditados por equipo. Los goles de la tanda se informan aparte.
CREATE OR ALTER VIEW torneo.vw_ResultadoEquipo
AS
SELECT
    e.id_partido,
    e.id_seleccion,
    ISNULL(SUM(CASE WHEN x.periodo <> 'PEN' THEN 1 ELSE 0 END), 0) AS goles,
    ISNULL(SUM(CASE WHEN x.periodo = 'PEN' THEN 1 ELSE 0 END), 0) AS penales
FROM torneo.equipo_en_partido AS e
LEFT JOIN
(
    SELECT
        g.id_partido,
        g.periodo,
        CASE WHEN g.en_contra = 1 THEN rival.id_seleccion ELSE g.id_seleccion END AS id_acredita
    FROM juego.gol AS g
    JOIN torneo.equipo_en_partido AS rival
      ON rival.id_partido = g.id_partido
     AND rival.id_seleccion <> g.id_seleccion
) AS x
  ON x.id_partido = e.id_partido
 AND x.id_acredita = e.id_seleccion
GROUP BY e.id_partido, e.id_seleccion;
GO


-- Marcador por partido, derivado de vw_ResultadoEquipo.
CREATE OR ALTER VIEW juego.vw_MarcadorPartido
AS
SELECT
    p.id_partido,
    MAX(CASE WHEN ep.condicion = 'L' THEN ep.id_seleccion END) AS id_local,
    MAX(CASE WHEN ep.condicion = 'V' THEN ep.id_seleccion END) AS id_visitante,
    ISNULL(MAX(CASE WHEN ep.condicion = 'L' THEN r.goles END), 0) AS goles_local,
    ISNULL(MAX(CASE WHEN ep.condicion = 'V' THEN r.goles END), 0) AS goles_visitante,
    ISNULL(MAX(CASE WHEN ep.condicion = 'L' THEN r.penales END), 0) AS penales_local,
    ISNULL(MAX(CASE WHEN ep.condicion = 'V' THEN r.penales END), 0) AS penales_visitante,
    p.estado,
    p.nro_fase
FROM torneo.partido AS p
LEFT JOIN torneo.equipo_en_partido AS ep
  ON ep.id_partido = p.id_partido
LEFT JOIN torneo.vw_ResultadoEquipo AS r
  ON r.id_partido = ep.id_partido
 AND r.id_seleccion = ep.id_seleccion
GROUP BY p.id_partido, p.estado, p.nro_fase;
GO



CREATE OR ALTER VIEW torneo.vw_GrupoConteoEquipos
AS
SELECT
    g.id_letra,
    COUNT(s.id_seleccion) AS cant_equipos
FROM torneo.grupo AS g
LEFT JOIN torneo.seleccion AS s
  ON s.id_letra = g.id_letra
GROUP BY g.id_letra;
GO


-- Posiciones de fase de grupos. No incluye partidos eliminatorios.
CREATE OR ALTER VIEW torneo.vw_PosicionesGrupo
AS
WITH Resultados AS
(
    SELECT
        local.id_letra,
        mp.id_local AS id_seleccion,
        mp.goles_local AS GF,
        mp.goles_visitante AS GC,
        CASE WHEN mp.goles_local > mp.goles_visitante THEN 1 ELSE 0 END AS PG,
        CASE WHEN mp.goles_local = mp.goles_visitante THEN 1 ELSE 0 END AS PE,
        CASE WHEN mp.goles_local < mp.goles_visitante THEN 1 ELSE 0 END AS PP
    FROM juego.vw_MarcadorPartido AS mp
    JOIN torneo.seleccion AS local
      ON local.id_seleccion = mp.id_local
    WHERE mp.estado = 'FINALIZADO'
      AND mp.nro_fase = 1

    UNION ALL

    SELECT
        visitante.id_letra,
        mp.id_visitante AS id_seleccion,
        mp.goles_visitante AS GF,
        mp.goles_local AS GC,
        CASE WHEN mp.goles_visitante > mp.goles_local THEN 1 ELSE 0 END AS PG,
        CASE WHEN mp.goles_visitante = mp.goles_local THEN 1 ELSE 0 END AS PE,
        CASE WHEN mp.goles_visitante < mp.goles_local THEN 1 ELSE 0 END AS PP
    FROM juego.vw_MarcadorPartido AS mp
    JOIN torneo.seleccion AS visitante
      ON visitante.id_seleccion = mp.id_visitante
    WHERE mp.estado = 'FINALIZADO'
      AND mp.nro_fase = 1
)
SELECT
    id_letra,
    id_seleccion,
    COUNT(*) AS PJ,
    SUM(PG) AS PG,
    SUM(PE) AS PE,
    SUM(PP) AS PP,
    SUM(GF) AS GF,
    SUM(GC) AS GC,
    SUM(GF) - SUM(GC) AS DIF,
    SUM(PG) * 3 + SUM(PE) AS puntos
FROM Resultados
GROUP BY id_letra, id_seleccion;
GO



-- Perdedores de partidos finalizados de eliminacion.
CREATE OR ALTER VIEW torneo.vw_SeleccionesEliminadas
AS
SELECT DISTINCT resultado.id_seleccion
FROM torneo.partido AS p
JOIN torneo.vw_ResultadoEquipo AS resultado
  ON resultado.id_partido = p.id_partido
JOIN torneo.vw_ResultadoEquipo AS rival
  ON rival.id_partido = p.id_partido
 AND rival.id_seleccion <> resultado.id_seleccion
WHERE p.estado = 'FINALIZADO'
  AND p.nro_fase >= 2
  AND
  (
      resultado.goles < rival.goles
      OR
      (
          resultado.goles = rival.goles
          AND resultado.penales < rival.penales
      )
  );
GO



-- Goleadores acreditados por la seleccion del gol. Excluye goles en contra.
CREATE OR ALTER VIEW juego.vw_Goleadores
AS
SELECT
    g.id_jugador_autor AS id_jugador,
    CONCAT(p.apellido, ', ', p.nombre) AS jugador_nombre,
    pais.nombre AS seleccion,
    COUNT(*) AS total_goles
FROM juego.gol AS g
JOIN persona.persona AS p
  ON p.id_persona = g.id_jugador_autor
JOIN torneo.seleccion AS s
  ON s.id_seleccion = g.id_seleccion
JOIN geo.pais AS pais
  ON pais.id_pais = s.id_pais
WHERE g.en_contra = 0
  AND g.periodo <> 'PEN'
GROUP BY g.id_jugador_autor, p.apellido, p.nombre, pais.nombre;
GO

CREATE OR ALTER VIEW juego.vw_TarjetasAcumuladas
AS
SELECT
    t.id_jugador,
    SUM(CASE WHEN tt.descripcion = 'AMARILLA' THEN 1 ELSE 0 END) AS total_amarillas,
    SUM(CASE WHEN tt.descripcion IN ('ROJA_DIRECTA', 'ROJA_DOBLE_AMARILLA') THEN 1 ELSE 0 END) AS total_rojas
FROM juego.tarjeta AS t
JOIN juego.tipo_tarjeta AS tt
  ON tt.id_tipo = t.id_tipo
GROUP BY t.id_jugador;
GO
