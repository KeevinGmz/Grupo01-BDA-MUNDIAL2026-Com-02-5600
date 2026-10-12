/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Carga inicial de 24 partidos de fase de grupos y registro de las alineaciones completas de ambas selecciones.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @v_errores NVARCHAR(2000) = N'';
DECLARE @v_propia BIT = 0;
DECLARE @v_sp BIT = 0;
DECLARE @v_cant_selecciones INT;
DECLARE @v_cant_sedes INT;
DECLARE @v_titulares INT;
DECLARE @v_max_suplentes INT;
DECLARE @v_fecha_base DATETIME2(0) = '2026-06-10T15:00:00';

-------------------------------------------------------------------------------
-- 1. Validaciones previas del juego de datos
-------------------------------------------------------------------------------

IF OBJECT_ID(N'torneo.usp_Negocio_RegistrarPartido', N'P') IS NULL
    SET @v_errores += N'no existe torneo.usp_Negocio_RegistrarPartido; ';

IF OBJECT_ID(N'juego.usp_Negocio_RegistrarAlineacion', N'P') IS NULL
    SET @v_errores += N'no existe juego.usp_Negocio_RegistrarAlineacion; ';

IF TYPE_ID(N'juego.tt_Alineacion') IS NULL
    SET @v_errores += N'no existe el tipo juego.tt_Alineacion; ';

IF NOT EXISTS
(
    SELECT 1
    FROM torneo.fase AS f
    WHERE f.nro_fase = 1
      AND f.es_eliminacion = 0
)
    SET @v_errores += N'no existe la fase 1 o no esta configurada como fase de grupos; ';

SELECT @v_cant_selecciones = COUNT(*)
FROM torneo.seleccion;

IF @v_cant_selecciones < 16
    SET @v_errores += CONCAT
    (
        N'se requieren al menos 16 selecciones y existen ',
        @v_cant_selecciones,
        N'; '
    );

SELECT @v_cant_sedes = COUNT(*)
FROM torneo.sede;

IF @v_cant_sedes < 8
    SET @v_errores += CONCAT
    (
        N'se requieren al menos 8 sedes y existen ',
        @v_cant_sedes,
        N'; '
    );

SELECT TOP (1) @v_titulares = CONVERT(INT, pr.valor)
FROM torneo.parametro_reglamento AS pr
WHERE pr.clave = 'TITULARES'
  AND pr.vigente_desde <= CONVERT(DATE, @v_fecha_base)
ORDER BY pr.vigente_desde DESC;

SELECT TOP (1) @v_max_suplentes = CONVERT(INT, pr.valor)
FROM torneo.parametro_reglamento AS pr
WHERE pr.clave = 'MAX_SUPLENTES'
  AND pr.vigente_desde <= CONVERT(DATE, @v_fecha_base)
ORDER BY pr.vigente_desde DESC;

IF @v_titulares IS NULL
    SET @v_errores += N'no existe un parametro vigente TITULARES; ';

IF @v_max_suplentes IS NULL
    SET @v_errores += N'no existe un parametro vigente MAX_SUPLENTES; ';

IF @v_titulares IS NOT NULL AND @v_titulares <> 11
    SET @v_errores += N'el parametro TITULARES debe ser 11 para este juego de datos; ';

IF @v_errores <> N''
BEGIN
    SET @v_errores = LEFT
    (
        CONCAT(N'42_Seed_Partidos_Alineaciones: ', @v_errores),
        2048
    );
    ;THROW 50001, @v_errores, 1;
END;

-------------------------------------------------------------------------------
-- 2. Selecciones participantes
-------------------------------------------------------------------------------

DECLARE @v_selecciones TABLE
(
    id_seleccion INT NOT NULL PRIMARY KEY,
    id_grupo CHAR(1) NOT NULL,
    orden_grupo TINYINT NOT NULL
);

;WITH primeras AS
(
    SELECT TOP (16)
        s.id_seleccion,
        s.id_letra AS id_grupo
    FROM torneo.seleccion AS s
    ORDER BY s.id_seleccion
),
numeradas AS
(
    SELECT
        p.id_seleccion,
        p.id_grupo,
        ROW_NUMBER() OVER
        (
            PARTITION BY p.id_grupo
            ORDER BY p.id_seleccion
        ) AS orden_grupo
    FROM primeras AS p
)
INSERT INTO @v_selecciones
(
    id_seleccion,
    id_grupo,
    orden_grupo
)
SELECT
    n.id_seleccion,
    n.id_grupo,
    CONVERT(TINYINT, n.orden_grupo)
FROM numeradas AS n;

-- Con 4 selecciones por grupo se generan 6 cruces. Cuatro grupos producen 24.
IF EXISTS
(
    SELECT 1
    FROM @v_selecciones AS s
    GROUP BY s.id_grupo
    HAVING COUNT(*) <> 4
)
BEGIN
    ;THROW 50003,
           N'42_Seed_Partidos_Alineaciones: las primeras 16 selecciones deben estar distribuidas en grupos de 4',
           1;
END;

IF
(
    SELECT COUNT(DISTINCT s.id_grupo)
    FROM @v_selecciones AS s
) <> 4
BEGIN
    ;THROW 50003,
           N'42_Seed_Partidos_Alineaciones: se requieren exactamente 4 grupos entre las primeras 16 selecciones',
           1;
END;

-------------------------------------------------------------------------------
-- 3. Validacion de convocatorias activas
-------------------------------------------------------------------------------

IF EXISTS
(
    SELECT 1
    FROM @v_selecciones AS s
    OUTER APPLY
    (
        SELECT COUNT(*) AS cantidad
        FROM torneo.convocatoria AS c
        WHERE c.id_seleccion = s.id_seleccion
          AND c.estado = 'ACTIVO'
    ) AS convocados
    WHERE convocados.cantidad < @v_titulares
       OR convocados.cantidad > @v_titulares + @v_max_suplentes
)
BEGIN
    ;THROW 50003,
           N'42_Seed_Partidos_Alineaciones: cada seleccion debe tener una convocatoria activa compatible con TITULARES y MAX_SUPLENTES',
           1;
END;

-------------------------------------------------------------------------------
-- 4. Sedes disponibles
-------------------------------------------------------------------------------

DECLARE @v_sedes TABLE
(
    orden TINYINT NOT NULL PRIMARY KEY,
    id_sede INT NOT NULL UNIQUE
);

INSERT INTO @v_sedes (orden, id_sede)
SELECT
    CONVERT(TINYINT, ROW_NUMBER() OVER (ORDER BY s.id_sede)),
    s.id_sede
FROM
(
    SELECT TOP (8) se.id_sede
    FROM torneo.sede AS se
    ORDER BY se.id_sede
) AS s;

-------------------------------------------------------------------------------
-- 5. Fixture de fase de grupos
--
-- Cada par de selecciones del mismo grupo se enfrenta una sola vez.
-------------------------------------------------------------------------------

DECLARE @v_fixture TABLE
(
    nro_partido TINYINT NOT NULL PRIMARY KEY,
    id_grupo CHAR(1) NOT NULL,
    id_local INT NOT NULL,
    id_visitante INT NOT NULL
);

INSERT INTO @v_fixture
(
    nro_partido,
    id_grupo,
    id_local,
    id_visitante
)
SELECT
    CONVERT
    (
        TINYINT,
        ROW_NUMBER() OVER
        (
            ORDER BY local.id_grupo, local.orden_grupo, visitante.orden_grupo
        )
    ),
    local.id_grupo,
    local.id_seleccion,
    visitante.id_seleccion
FROM @v_selecciones AS local
JOIN @v_selecciones AS visitante
  ON visitante.id_grupo = local.id_grupo
 AND visitante.orden_grupo > local.orden_grupo;

IF (SELECT COUNT(*) FROM @v_fixture) <> 24
BEGIN
    ;THROW 50003,
           N'42_Seed_Partidos_Alineaciones: no se pudieron generar los 24 cruces de fase de grupos',
           1;
END;

-------------------------------------------------------------------------------
-- 6. Alta de partidos y alineaciones
-------------------------------------------------------------------------------

BEGIN TRY
    IF @@TRANCOUNT = 0
    BEGIN
        BEGIN TRANSACTION;
        SET @v_propia = 1;
    END
    ELSE
    BEGIN
        SAVE TRANSACTION sv_seed_part_alin;
        SET @v_sp = 1;
    END;

    DECLARE @v_nro_partido TINYINT = 1;
    DECLARE @v_id_partido INT;
    DECLARE @v_id_local INT;
    DECLARE @v_id_visitante INT;
    DECLARE @v_id_sede INT;
    DECLARE @v_fecha DATETIME2(0);
    DECLARE @v_orden_sede TINYINT;

    WHILE @v_nro_partido <= 24
    BEGIN
        SELECT
            @v_id_local = f.id_local,
            @v_id_visitante = f.id_visitante
        FROM @v_fixture AS f
        WHERE f.nro_partido = @v_nro_partido;

        SET @v_orden_sede = CONVERT
        (
            TINYINT,
            ((@v_nro_partido - 1) % 8) + 1
        );

        SELECT @v_id_sede = s.id_sede
        FROM @v_sedes AS s
        WHERE s.orden = @v_orden_sede;

        -- Cada sede vuelve a usarse luego de 48 horas.
        SET @v_fecha = DATEADD
        (
            HOUR,
            CONVERT(INT, @v_nro_partido - 1) * 6,
            @v_fecha_base
        );

        SET @v_id_partido = NULL;

        -- El seed es reejecutable: reutiliza el cruce si ya existe en fase 1.
        SELECT TOP (1) @v_id_partido = p.id_partido
        FROM torneo.partido AS p
        JOIN torneo.equipo_en_partido AS ep_local
          ON ep_local.id_partido = p.id_partido
         AND ep_local.id_seleccion = @v_id_local
        JOIN torneo.equipo_en_partido AS ep_visitante
          ON ep_visitante.id_partido = p.id_partido
         AND ep_visitante.id_seleccion = @v_id_visitante
        WHERE p.nro_fase = 1
        ORDER BY p.id_partido;

        IF @v_id_partido IS NULL
        BEGIN
            EXEC torneo.usp_Negocio_RegistrarPartido
                @fecha_hora_utc = @v_fecha,
                @id_sede = @v_id_sede,
                @nro_fase = 1,
                @id_seleccion_local = @v_id_local,
                @id_seleccion_visitante = @v_id_visitante,
                @esquema_local = '4-3-3',
                @esquema_visitante = '4-4-2',
                @id_partido = @v_id_partido OUTPUT;
        END;

        -----------------------------------------------------------------------
        -- Alineacion local
        -----------------------------------------------------------------------

        DECLARE @v_alineacion_local juego.tt_Alineacion;

        ;WITH jugadores AS
        (
            SELECT
                c.id_jugador,
                c.dorsal,
                j.id_posicion_habitual,
                ROW_NUMBER() OVER (ORDER BY c.dorsal, c.id_jugador) AS rn
            FROM torneo.convocatoria AS c
            JOIN persona.jugador AS j
              ON j.id_persona = c.id_jugador
            WHERE c.id_seleccion = @v_id_local
              AND c.estado = 'ACTIVO'
        )
        INSERT INTO @v_alineacion_local
        (
            id_jugador,
            dorsal,
            es_titular,
            id_posicion,
            es_posicion_habitual
        )
        SELECT
            j.id_jugador,
            j.dorsal,
            CONVERT(BIT, CASE WHEN j.rn <= @v_titulares THEN 1 ELSE 0 END),
            j.id_posicion_habitual,
            CONVERT(BIT, 1)
        FROM jugadores AS j
        WHERE j.rn <= @v_titulares + @v_max_suplentes;

        EXEC juego.usp_Negocio_RegistrarAlineacion
            @id_partido = @v_id_partido,
            @id_seleccion = @v_id_local,
            @esquema_tactico = '4-3-3',
            @alineacion = @v_alineacion_local;

        -----------------------------------------------------------------------
        -- Alineacion visitante
        -----------------------------------------------------------------------

        DECLARE @v_alineacion_visitante juego.tt_Alineacion;

        ;WITH jugadores AS
        (
            SELECT
                c.id_jugador,
                c.dorsal,
                j.id_posicion_habitual,
                ROW_NUMBER() OVER (ORDER BY c.dorsal, c.id_jugador) AS rn
            FROM torneo.convocatoria AS c
            JOIN persona.jugador AS j
              ON j.id_persona = c.id_jugador
            WHERE c.id_seleccion = @v_id_visitante
              AND c.estado = 'ACTIVO'
        )
        INSERT INTO @v_alineacion_visitante
        (
            id_jugador,
            dorsal,
            es_titular,
            id_posicion,
            es_posicion_habitual
        )
        SELECT
            j.id_jugador,
            j.dorsal,
            CONVERT(BIT, CASE WHEN j.rn <= @v_titulares THEN 1 ELSE 0 END),
            j.id_posicion_habitual,
            CONVERT(BIT, 1)
        FROM jugadores AS j
        WHERE j.rn <= @v_titulares + @v_max_suplentes;

        EXEC juego.usp_Negocio_RegistrarAlineacion
            @id_partido = @v_id_partido,
            @id_seleccion = @v_id_visitante,
            @esquema_tactico = '4-4-2',
            @alineacion = @v_alineacion_visitante;

        SET @v_nro_partido += 1;
    END;

    ---------------------------------------------------------------------------
    -- 7. Controles finales
    ---------------------------------------------------------------------------

    IF
    (
        SELECT COUNT(*)
        FROM torneo.partido AS p
        WHERE p.nro_fase = 1
    ) < 24
    BEGIN
        ;THROW 50003,
               N'42_Seed_Partidos_Alineaciones: no quedaron registrados al menos 24 partidos de fase 1',
               1;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM @v_fixture AS f
        OUTER APPLY
        (
            SELECT TOP (1) p.id_partido
            FROM torneo.partido AS p
            JOIN torneo.equipo_en_partido AS e1
              ON e1.id_partido = p.id_partido
             AND e1.id_seleccion = f.id_local
            JOIN torneo.equipo_en_partido AS e2
              ON e2.id_partido = p.id_partido
             AND e2.id_seleccion = f.id_visitante
            WHERE p.nro_fase = 1
            ORDER BY p.id_partido
        ) AS partido
        OUTER APPLY
        (
            SELECT COUNT(DISTINCT a.id_seleccion) AS equipos_alineados
            FROM juego.alineacion AS a
            WHERE a.id_partido = partido.id_partido
        ) AS alineaciones
        WHERE partido.id_partido IS NULL
           OR alineaciones.equipos_alineados <> 2
    )
    BEGIN
        ;THROW 50003,
               N'42_Seed_Partidos_Alineaciones: algun partido no tiene alineaciones para las dos selecciones',
               1;
    END;

    IF @v_propia = 1
        COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @v_propia = 1 AND @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    ELSE IF @v_sp = 1 AND XACT_STATE() = 1
        ROLLBACK TRANSACTION sv_seed_part_alin;
    ;THROW;
END CATCH;
GO

-------------------------------------------------------------------------------
-- 8. Evidencia final
-------------------------------------------------------------------------------

SELECT
    p.id_partido,
    p.fecha_hora_utc,
    p.nro_fase,
    p.estado,
    s.nombre_estadio,
    local.id_seleccion AS id_local,
    pais_local.nombre AS seleccion_local,
    visitante.id_seleccion AS id_visitante,
    pais_visitante.nombre AS seleccion_visitante,
    COUNT(DISTINCT CASE WHEN a.es_titular = 1 THEN a.id_jugador END) AS titulares,
    COUNT(DISTINCT CASE WHEN a.es_titular = 0 THEN a.id_jugador END) AS suplentes
FROM torneo.partido AS p
JOIN torneo.sede AS s
  ON s.id_sede = p.id_sede
JOIN torneo.equipo_en_partido AS local
  ON local.id_partido = p.id_partido
 AND local.condicion = 'L'
JOIN torneo.seleccion AS sel_local
  ON sel_local.id_seleccion = local.id_seleccion
JOIN geo.pais AS pais_local
  ON pais_local.id_pais = sel_local.id_pais
JOIN torneo.equipo_en_partido AS visitante
  ON visitante.id_partido = p.id_partido
 AND visitante.condicion = 'V'
JOIN torneo.seleccion AS sel_visitante
  ON sel_visitante.id_seleccion = visitante.id_seleccion
JOIN geo.pais AS pais_visitante
  ON pais_visitante.id_pais = sel_visitante.id_pais
LEFT JOIN juego.alineacion AS a
  ON a.id_partido = p.id_partido
WHERE p.nro_fase = 1
GROUP BY
    p.id_partido,
    p.fecha_hora_utc,
    p.nro_fase,
    p.estado,
    s.nombre_estadio,
    local.id_seleccion,
    pais_local.nombre,
    visitante.id_seleccion,
    pais_visitante.nombre
ORDER BY p.fecha_hora_utc, p.id_partido;
GO
