/* =====================================================================
   Universidad Nacional de La Matanza (UNLaM)
   Materia : 3641 - Bases de Datos Aplicada                  Comision: 02-5600
   Grupo   : 01 - Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
   Fecha   : 2026-10-03
   Objetivo: Crea los procedimientos transaccionales de negocio para registrar y cerrar partidos.
===================================================================== */
USE Mundial2026;
GO

-- ----------------------------------------------------------------------------
-- Registrar Partido
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE torneo.usp_Negocio_RegistrarPartido
    @fecha_hora_utc DATETIME2(0),
    @id_sede INT,
    @nro_fase TINYINT,
    @id_seleccion_local INT,
    @id_seleccion_visitante INT,
    @esquema_local VARCHAR(10) = NULL,
    @esquema_visitante VARCHAR(10) = NULL,
    @id_partido INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_codigo INT = 50001;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    DECLARE @v_grupo_local CHAR(1);
    DECLARE @v_grupo_visitante CHAR(1);
    DECLARE @v_es_eliminacion BIT;

    -- 1) Validaciones acumuladas antes de abrir la transaccion
    IF @fecha_hora_utc IS NULL
        SET @v_errores += 'fecha_hora_utc obligatoria; ';

    IF NOT EXISTS (SELECT 1 FROM torneo.sede WHERE id_sede = @id_sede)
        SET @v_errores += 'sede inexistente; ';

    SELECT @v_es_eliminacion = f.es_eliminacion
    FROM torneo.fase AS f
    WHERE f.nro_fase = @nro_fase;

    IF @v_es_eliminacion IS NULL
        SET @v_errores += 'fase inexistente; ';

    SELECT @v_grupo_local = s.id_letra
    FROM torneo.seleccion AS s
    WHERE s.id_seleccion = @id_seleccion_local;

    IF @v_grupo_local IS NULL
        SET @v_errores += 'seleccion local inexistente; ';

    SELECT @v_grupo_visitante = s.id_letra
    FROM torneo.seleccion AS s
    WHERE s.id_seleccion = @id_seleccion_visitante;

    IF @v_grupo_visitante IS NULL
        SET @v_errores += 'seleccion visitante inexistente; ';

    IF @id_seleccion_local IS NOT NULL
       AND @id_seleccion_visitante IS NOT NULL
       AND @id_seleccion_local = @id_seleccion_visitante
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'las selecciones local y visitante deben ser distintas; ';
    END

    IF @esquema_local IS NOT NULL
       AND @esquema_local NOT LIKE '[1-9]-[0-9]-[0-9]'
       AND @esquema_local NOT LIKE '[1-9]-[0-9]-[0-9]-[0-9]'
       AND @esquema_local NOT LIKE '[1-9]-[0-9]-[0-9]-[0-9]-[0-9]'
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'esquema_local con formato invalido; ';
    END

    IF @esquema_visitante IS NOT NULL
       AND @esquema_visitante NOT LIKE '[1-9]-[0-9]-[0-9]'
       AND @esquema_visitante NOT LIKE '[1-9]-[0-9]-[0-9]-[0-9]'
       AND @esquema_visitante NOT LIKE '[1-9]-[0-9]-[0-9]-[0-9]-[0-9]'
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'esquema_visitante con formato invalido; ';
    END

    IF @fecha_hora_utc IS NOT NULL
       AND EXISTS
       (
           SELECT 1
           FROM torneo.partido AS p
           WHERE p.id_sede = @id_sede
             AND p.fecha_hora_utc = @fecha_hora_utc
             AND p.estado <> 'SUSPENDIDO'
       )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'la sede no esta libre en la fecha y hora indicadas; ';
    END

    IF @nro_fase = 1
    BEGIN
        IF @v_grupo_local IS NOT NULL
           AND @v_grupo_visitante IS NOT NULL
           AND @v_grupo_local <> @v_grupo_visitante
        BEGIN
            SET @v_codigo = 50003;
            SET @v_errores += 'en fase de grupos, ambas selecciones deben pertenecer al mismo grupo; ';
        END

        IF EXISTS
        (
            SELECT 1
            FROM torneo.partido AS p
            JOIN torneo.equipo_en_partido AS e1
              ON e1.id_partido = p.id_partido
             AND e1.id_seleccion = @id_seleccion_local
            JOIN torneo.equipo_en_partido AS e2
              ON e2.id_partido = p.id_partido
             AND e2.id_seleccion = @id_seleccion_visitante
            WHERE p.nro_fase = 1
              AND p.estado <> 'SUSPENDIDO'
        )
        BEGIN
            SET @v_codigo = 50003;
            SET @v_errores += 'el cruce entre las selecciones ya fue registrado en la fase de grupos; ';
        END
    END
    ELSE IF @v_es_eliminacion = 1
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM torneo.partido AS p
            JOIN torneo.equipo_en_partido AS ep
              ON ep.id_partido = p.id_partido
            WHERE p.nro_fase = @nro_fase
              AND p.estado <> 'SUSPENDIDO'
              AND ep.id_seleccion IN (@id_seleccion_local, @id_seleccion_visitante)
        )
        BEGIN
            SET @v_codigo = 50003;
            SET @v_errores += 'una de las selecciones ya tiene un partido registrado en esta fase eliminatoria; ';
        END
    END

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('torneo.usp_Negocio_RegistrarPartido: ', @v_errores), 2048);
        THROW @v_codigo, @v_errores, 1;
    END

    BEGIN TRY
        -- 2) Transaccion propia o savepoint si ya existe una transaccion
        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @v_propia = 1;
        END
        ELSE
        BEGIN
            SAVE TRANSACTION sv_registrar_partido;
            SET @v_sp = 1;
        END

        INSERT INTO torneo.partido
        (
            fecha_hora_utc,
            asistencia_publico,
            definido_por_penales,
            estado,
            id_sede,
            nro_fase
        )
        VALUES
        (
            @fecha_hora_utc,
            NULL,
            0,
            'PROGRAMADO',
            @id_sede,
            @nro_fase
        );

        SET @id_partido = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO torneo.equipo_en_partido
        (
            id_partido,
            id_seleccion,
            condicion,
            esquema_tactico
        )
        VALUES
            (@id_partido, @id_seleccion_local, 'L', @esquema_local),
            (@id_partido, @id_seleccion_visitante, 'V', @esquema_visitante);

        IF @v_propia = 1
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION sv_registrar_partido;
        THROW;
    END CATCH
END;
GO

-- ----------------------------------------------------------------------------
-- Cerrar Partido
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE torneo.usp_Negocio_CerrarPartido
    @id_partido INT,
    @asistencia_publico INT,
    @definido_por_penales BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_codigo INT = 50001;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    DECLARE @v_capacidad INT;
    DECLARE @v_estado VARCHAR(12);
    DECLARE @v_es_eliminacion BIT;
    DECLARE @v_goles_local INT = 0;
    DECLARE @v_goles_visitante INT = 0;
    DECLARE @v_penales_local INT = 0;
    DECLARE @v_penales_visitante INT = 0;

    -- 1) Validaciones acumuladas antes de abrir la transaccion
    SELECT
        @v_estado = p.estado,
        @v_capacidad = s.capacidad,
        @v_es_eliminacion = f.es_eliminacion
    FROM torneo.partido AS p
    JOIN torneo.sede AS s
      ON s.id_sede = p.id_sede
    JOIN torneo.fase AS f
      ON f.nro_fase = p.nro_fase
    WHERE p.id_partido = @id_partido;

    IF @v_estado IS NULL
        SET @v_errores += 'partido inexistente; ';

    IF @v_estado IS NOT NULL
       AND @v_estado NOT IN ('PROGRAMADO', 'EN_CURSO')
    BEGIN
        SET @v_codigo = 50002;
        SET @v_errores += 'el partido debe estar PROGRAMADO o EN_CURSO; ';
    END

    IF @asistencia_publico IS NULL OR @asistencia_publico < 0
        SET @v_errores += 'asistencia_publico obligatoria y no negativa; ';

    IF @asistencia_publico IS NOT NULL
       AND @v_capacidad IS NOT NULL
       AND @asistencia_publico > @v_capacidad
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'la asistencia supera la capacidad de la sede; ';
    END

    IF @definido_por_penales IS NULL
        SET @v_errores += 'definido_por_penales obligatorio; ';

    IF @v_estado IS NOT NULL
       AND
       (
           SELECT COUNT(DISTINCT a.id_seleccion)
           FROM juego.alineacion AS a
           WHERE a.id_partido = @id_partido
       ) <> 2
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'ambas selecciones deben tener alineacion registrada; ';
    END

    IF @v_estado IS NOT NULL
       AND NOT EXISTS
       (
           SELECT 1
           FROM arbitraje.designacion_arbitral AS da
           JOIN arbitraje.rol_arbitral AS ra
             ON ra.id_rol = da.id_rol
           WHERE da.id_partido = @id_partido
             AND da.estado = 'DESIGNADA'
             AND ra.descripcion = 'PRINCIPAL'
       )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'el partido no tiene un arbitro PRINCIPAL designado; ';
    END

    SELECT
        @v_goles_local = ISNULL(MAX(CASE WHEN ep.condicion = 'L' THEN r.goles END), 0),
        @v_goles_visitante = ISNULL(MAX(CASE WHEN ep.condicion = 'V' THEN r.goles END), 0),
        @v_penales_local = ISNULL(MAX(CASE WHEN ep.condicion = 'L' THEN r.penales END), 0),
        @v_penales_visitante = ISNULL(MAX(CASE WHEN ep.condicion = 'V' THEN r.penales END), 0)
    FROM torneo.equipo_en_partido AS ep
    LEFT JOIN torneo.vw_ResultadoEquipo AS r
      ON r.id_partido = ep.id_partido
     AND r.id_seleccion = ep.id_seleccion
    WHERE ep.id_partido = @id_partido;

    IF @v_es_eliminacion = 0 AND @definido_por_penales = 1
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'una fase no eliminatoria no puede definirse por penales; ';
    END

    IF @v_es_eliminacion = 1
    BEGIN
        IF @v_goles_local = @v_goles_visitante
        BEGIN
            IF @definido_por_penales <> 1
            BEGIN
                SET @v_codigo = 50003;
                SET @v_errores += 'un empate en fase eliminatoria debe definirse por penales; ';
            END

            IF @v_penales_local + @v_penales_visitante = 0
            BEGIN
                SET @v_codigo = 50003;
                SET @v_errores += 'un partido definido por penales debe tener goles del periodo PEN; ';
            END

            IF @v_penales_local = @v_penales_visitante
            BEGIN
                SET @v_codigo = 50003;
                SET @v_errores += 'la tanda de penales no puede finalizar empatada; ';
            END
        END
        ELSE IF @definido_por_penales = 1
        BEGIN
            SET @v_codigo = 50003;
            SET @v_errores += 'si los goles reglamentarios no empatan, definido_por_penales debe ser 0; ';
        END
    END

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('torneo.usp_Negocio_CerrarPartido: ', @v_errores), 2048);
        THROW @v_codigo, @v_errores, 1;
    END

    BEGIN TRY
        -- 2) Transaccion propia o savepoint si ya existe una transaccion
        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @v_propia = 1;
        END
        ELSE
        BEGIN
            SAVE TRANSACTION sv_cerrar_partido;
            SET @v_sp = 1;
        END

        UPDATE torneo.partido
        SET asistencia_publico = @asistencia_publico,
            definido_por_penales = @definido_por_penales,
            estado = 'FINALIZADO'
        WHERE id_partido = @id_partido;

        -- Registra el partido cumplido para cada suspension que corresponde a
        -- jugadores convocados por alguna de las dos selecciones del partido.
        INSERT INTO juego.suspension_partido
        (
            id_suspension,
            id_partido
        )
        SELECT
            sus.id_suspension,
            @id_partido
        FROM juego.suspension AS sus
        JOIN torneo.convocatoria AS c
          ON c.id_jugador = sus.id_jugador
        JOIN torneo.equipo_en_partido AS ep
          ON ep.id_partido = @id_partido
         AND ep.id_seleccion = c.id_seleccion
        WHERE sus.estado = 'PENDIENTE'
          AND juego.fn_JugadorSuspendidoEnPartido(sus.id_jugador, @id_partido) = 1
          AND NOT EXISTS
          (
              SELECT 1
              FROM juego.suspension_partido AS sp
              WHERE sp.id_suspension = sus.id_suspension
                AND sp.id_partido = @id_partido
          );

        UPDATE sus
        SET estado = 'CUMPLIDA'
        FROM juego.suspension AS sus
        WHERE sus.estado = 'PENDIENTE'
          AND
          (
              SELECT COUNT(*)
              FROM juego.suspension_partido AS sp
              WHERE sp.id_suspension = sus.id_suspension
          ) >= sus.cant_partidos;

        IF @v_propia = 1
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION sv_cerrar_partido;
        THROW;
    END CATCH
END;
GO
