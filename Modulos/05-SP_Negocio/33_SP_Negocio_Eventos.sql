/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Crea los procedimientos transaccionales de negocio para registrar goles y tarjetas.
===================================================================== */
USE Mundial2026;
GO

-- ----------------------------------------------------------------------------
-- Registrar Gol
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE juego.usp_Negocio_RegistrarGol
    @id_partido INT,
    @id_seleccion INT,
    @id_jugador_autor INT,
    @id_jugador_asistente INT = NULL,
    @minuto SMALLINT,
    @tipo_gol VARCHAR(15),
    @en_contra BIT = 0,
    @periodo VARCHAR(5),
    @nro_gol TINYINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_codigo INT = 50001;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    DECLARE @v_estado VARCHAR(12);
    DECLARE @v_admite_alargue BIT;
    DECLARE @v_admite_penales BIT;

    SELECT
        @v_estado = p.estado,
        @v_admite_alargue = f.admite_alargue,
        @v_admite_penales = f.admite_penales
    FROM torneo.partido AS p
    JOIN torneo.fase AS f
      ON f.nro_fase = p.nro_fase
    WHERE p.id_partido = @id_partido;

    -- 1) Validaciones acumuladas antes de abrir la transaccion
    IF @v_estado IS NULL
        SET @v_errores += 'partido inexistente; ';

    IF @v_estado IS NOT NULL
       AND @v_estado <> 'EN_CURSO'
       AND NOT EXISTS
       (
           SELECT 1
           FROM juego.alineacion AS a
           WHERE a.id_partido = @id_partido
       )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'el partido debe estar EN_CURSO o tener alineaciones cargadas; ';
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM torneo.equipo_en_partido AS ep
        WHERE ep.id_partido = @id_partido
          AND ep.id_seleccion = @id_seleccion
    )
        SET @v_errores += 'la seleccion no participa del partido; ';

    IF @id_jugador_asistente IS NOT NULL
       AND @id_jugador_autor = @id_jugador_asistente
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'autor y asistente deben ser distintos; ';
    END

    IF @en_contra IS NULL
        SET @v_errores += 'en_contra obligatorio; ';

    IF @en_contra = 1 AND @id_jugador_asistente IS NOT NULL
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'un gol en contra no admite asistente; ';
    END

    IF @minuto IS NULL OR @minuto < 0 OR @minuto > 130
        SET @v_errores += 'minuto obligatorio y debe estar entre 0 y 130; ';

    IF @periodo IS NULL OR @periodo NOT IN ('PT', 'ST', 'ADIC', 'ALARG', 'PEN')
        SET @v_errores += 'periodo invalido; ';

    IF @tipo_gol IS NULL
       OR @tipo_gol NOT IN ('JUGADA', 'PENAL', 'TIRO LIBRE', 'CABEZA', 'CORNER', 'REBOTE', 'EN CONTRA')
        SET @v_errores += 'tipo_gol invalido; ';

    IF @periodo = 'PEN' AND ISNULL(@v_admite_penales, 0) = 0
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'la fase no admite definicion por penales; ';
    END

    IF @minuto IS NOT NULL
       AND NOT EXISTS
       (
           SELECT 1
           FROM juego.fn_EquipoEnCancha(@id_partido, @id_seleccion, @minuto) AS ec
           WHERE ec.id_jugador = @id_jugador_autor
       )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'el autor no esta en cancha para su seleccion al minuto indicado; ';
    END

    IF @id_jugador_asistente IS NOT NULL
       AND @minuto IS NOT NULL
       AND NOT EXISTS
       (
           SELECT 1
           FROM juego.fn_EquipoEnCancha(@id_partido, @id_seleccion, @minuto) AS ec
           WHERE ec.id_jugador = @id_jugador_asistente
       )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'el asistente no esta en cancha para la seleccion al minuto indicado; ';
    END

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('juego.usp_Negocio_RegistrarGol: ', @v_errores), 2048);
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
            SAVE TRANSACTION sv_registrar_gol;
            SET @v_sp = 1;
        END

        SELECT @nro_gol = CONVERT(TINYINT, ISNULL(MAX(g.nro_gol), 0) + 1)
        FROM juego.gol AS g WITH (UPDLOCK, HOLDLOCK)
        WHERE g.id_partido = @id_partido
          AND g.id_seleccion = @id_seleccion;

        INSERT INTO juego.gol
        (
            id_partido,
            id_seleccion,
            nro_gol,
            minuto,
            tipo_gol,
            en_contra,
            periodo,
            id_jugador_autor,
            id_jugador_asistente
        )
        VALUES
        (
            @id_partido,
            @id_seleccion,
            @nro_gol,
            @minuto,
            @tipo_gol,
            @en_contra,
            @periodo,
            @id_jugador_autor,
            @id_jugador_asistente
        );

        IF @v_propia = 1
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION sv_registrar_gol;
        THROW;
    END CATCH
END;
GO



-- ----------------------------------------------------------------------------
-- Registrar Tarjeta
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE juego.usp_Negocio_RegistrarTarjeta
    @id_partido INT,
    @id_seleccion INT,
    @id_jugador INT,
    @id_arbitro INT,
    @minuto SMALLINT,
    @id_tipo TINYINT,
    @motivo VARCHAR(100) = NULL,
    @nro_tarjeta TINYINT OUTPUT,
    @id_suspension INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_codigo INT = 50001;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    DECLARE @v_estado VARCHAR(12);
    DECLARE @v_nro_fase TINYINT;
    DECLARE @v_fecha_partido DATETIME2(0);
    DECLARE @v_desc_tipo VARCHAR(30);
    DECLARE @v_id_tipo_aplicado TINYINT;
    DECLARE @v_desc_tipo_aplicado VARCHAR(30);
    DECLARE @v_id_tipo_amarilla TINYINT;
    DECLARE @v_id_tipo_roja_doble TINYINT;
    DECLARE @v_id_criterio INT;
    DECLARE @v_cant_requeridas TINYINT;
    DECLARE @v_cant_partidos TINYINT;
    DECLARE @v_cant_amarillas INT;
    DECLARE @v_fase_desde TINYINT;
    DECLARE @v_fase_hasta TINYINT;

    SET @id_suspension = NULL;

    SELECT
        @v_estado = p.estado,
        @v_nro_fase = p.nro_fase,
        @v_fecha_partido = p.fecha_hora_utc
    FROM torneo.partido AS p
    WHERE p.id_partido = @id_partido;

    SELECT @v_desc_tipo = tt.descripcion
    FROM juego.tipo_tarjeta AS tt
    WHERE tt.id_tipo = @id_tipo;

    SELECT @v_id_tipo_amarilla = tt.id_tipo
    FROM juego.tipo_tarjeta AS tt
    WHERE tt.descripcion = 'AMARILLA';

    SELECT @v_id_tipo_roja_doble = tt.id_tipo
    FROM juego.tipo_tarjeta AS tt
    WHERE tt.descripcion = 'ROJA_DOBLE_AMARILLA';

    SET @v_id_tipo_aplicado = @id_tipo;
    SET @v_desc_tipo_aplicado = @v_desc_tipo;

    -- 1) Validaciones acumuladas antes de abrir la transaccion
    IF @v_estado IS NULL
        SET @v_errores += 'partido inexistente; ';

    IF @v_estado = 'FINALIZADO'
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'no se pueden registrar tarjetas en un partido FINALIZADO; ';
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM juego.alineacion AS a
        WHERE a.id_partido = @id_partido
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'el partido no tiene alineaciones cargadas; ';
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM torneo.equipo_en_partido AS ep
        WHERE ep.id_partido = @id_partido
          AND ep.id_seleccion = @id_seleccion
    )
        SET @v_errores += 'la seleccion no participa del partido; ';

    IF NOT EXISTS
    (
        SELECT 1
        FROM juego.alineacion AS a
        WHERE a.id_partido = @id_partido
          AND a.id_seleccion = @id_seleccion
          AND a.id_jugador = @id_jugador
    )
        SET @v_errores += 'el jugador no integra la alineacion de la seleccion; ';

    IF @minuto IS NULL OR @minuto < 0 OR @minuto > 130
        SET @v_errores += 'minuto obligatorio y debe estar entre 0 y 130; ';

    IF @minuto IS NOT NULL
       AND NOT EXISTS
       (
           SELECT 1
           FROM juego.fn_EquipoEnCancha(@id_partido, @id_seleccion, @minuto) AS ec
           WHERE ec.id_jugador = @id_jugador
       )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'el jugador no esta en cancha al minuto indicado; ';
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM arbitraje.designacion_arbitral AS da
        WHERE da.id_partido = @id_partido
          AND da.id_arbitro = @id_arbitro
          AND da.estado = 'DESIGNADA'
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'el arbitro no esta designado en el partido; ';
    END

    IF @v_desc_tipo IS NULL
        SET @v_errores += 'tipo de tarjeta inexistente; ';

    IF EXISTS
    (
        SELECT 1
        FROM juego.tarjeta AS t
        JOIN juego.tipo_tarjeta AS tt
          ON tt.id_tipo = t.id_tipo
        WHERE t.id_partido = @id_partido
          AND t.id_seleccion = @id_seleccion
          AND t.id_jugador = @id_jugador
          AND tt.descripcion IN ('ROJA_DIRECTA', 'ROJA_DOBLE_AMARILLA')
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'el jugador ya fue expulsado en el partido; ';
    END

    IF @v_desc_tipo = 'AMARILLA'
       AND EXISTS
       (
           SELECT 1
           FROM juego.tarjeta AS t
           JOIN juego.tipo_tarjeta AS tt
             ON tt.id_tipo = t.id_tipo
           WHERE t.id_partido = @id_partido
             AND t.id_seleccion = @id_seleccion
             AND t.id_jugador = @id_jugador
             AND tt.descripcion = 'AMARILLA'
       )
    BEGIN
        SET @v_id_tipo_aplicado = @v_id_tipo_roja_doble;
        SET @v_desc_tipo_aplicado = 'ROJA_DOBLE_AMARILLA';
    END

    IF @v_desc_tipo = 'AMARILLA' AND @v_id_tipo_roja_doble IS NULL
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'no existe el tipo ROJA_DOBLE_AMARILLA; ';
    END

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('juego.usp_Negocio_RegistrarTarjeta: ', @v_errores), 2048);
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
            SAVE TRANSACTION sv_registrar_tarjeta;
            SET @v_sp = 1;
        END

        SELECT @nro_tarjeta = CONVERT(TINYINT, ISNULL(MAX(t.nro_tarjeta), 0) + 1)
        FROM juego.tarjeta AS t WITH (UPDLOCK, HOLDLOCK)
        WHERE t.id_partido = @id_partido
          AND t.id_seleccion = @id_seleccion;

        INSERT INTO juego.tarjeta
        (
            id_partido,
            id_seleccion,
            nro_tarjeta,
            minuto,
            motivo,
            id_tipo,
            id_arbitro,
            id_jugador
        )
        VALUES
        (
            @id_partido,
            @id_seleccion,
            @nro_tarjeta,
            @minuto,
            @motivo,
            @v_id_tipo_aplicado,
            @id_arbitro,
            @id_jugador
        );

        -- Suspension por roja directa o roja por doble amarilla.
        IF @v_desc_tipo_aplicado IN ('ROJA_DIRECTA', 'ROJA_DOBLE_AMARILLA')
        BEGIN
            SELECT
                @v_id_criterio = cs.id_criterio,
                @v_cant_partidos = cs.cant_partidos_suspension
            FROM juego.criterio_suspension AS cs
            WHERE cs.id_tipo = @v_id_tipo_aplicado
              AND cs.vigente = 1;

            IF @v_id_criterio IS NULL
                THROW 50003, 'juego.usp_Negocio_RegistrarTarjeta: no existe criterio vigente para el tipo de roja aplicado', 1;

            INSERT INTO juego.suspension
            (
                id_jugador,
                id_criterio,
                cant_partidos,
                estado,
                fecha_alta,
                motivo
            )
            VALUES
            (
                @id_jugador,
                @v_id_criterio,
                @v_cant_partidos,
                'PENDIENTE',
                @v_fecha_partido,
                CONCAT('Suspension por ', @v_desc_tipo_aplicado)
            );

            SET @id_suspension = CONVERT(INT, SCOPE_IDENTITY());
        END
        ELSE IF @v_desc_tipo_aplicado = 'AMARILLA'
        BEGIN
            SELECT
                @v_id_criterio = cs.id_criterio,
                @v_cant_requeridas = cs.cant_tarjetas_requeridas,
                @v_cant_partidos = cs.cant_partidos_suspension
            FROM juego.criterio_suspension AS cs
            WHERE cs.id_tipo = @v_id_tipo_amarilla
              AND cs.vigente = 1;

            IF @v_id_criterio IS NULL
                THROW 50003, 'juego.usp_Negocio_RegistrarTarjeta: no existe criterio vigente para AMARILLA', 1;

            SET @v_fase_desde = CASE WHEN @v_nro_fase = 1 THEN 1 WHEN @v_nro_fase BETWEEN 2 AND 4 THEN 2 ELSE 5 END;
            SET @v_fase_hasta = CASE WHEN @v_nro_fase = 1 THEN 1 WHEN @v_nro_fase BETWEEN 2 AND 4 THEN 4 ELSE 7 END;

            SELECT @v_cant_amarillas = COUNT(DISTINCT t.id_partido)
            FROM juego.tarjeta AS t
            JOIN juego.tipo_tarjeta AS tt
              ON tt.id_tipo = t.id_tipo
            JOIN torneo.partido AS p
              ON p.id_partido = t.id_partido
            WHERE t.id_jugador = @id_jugador
              AND tt.descripcion = 'AMARILLA'
              AND p.nro_fase BETWEEN @v_fase_desde AND @v_fase_hasta
              AND NOT EXISTS
              (
                  SELECT 1
                  FROM juego.tarjeta AS tr
                  JOIN juego.tipo_tarjeta AS ttr
                    ON ttr.id_tipo = tr.id_tipo
                  WHERE tr.id_partido = t.id_partido
                    AND tr.id_jugador = t.id_jugador
                    AND ttr.descripcion = 'ROJA_DOBLE_AMARILLA'
              );

            IF @v_cant_amarillas = @v_cant_requeridas
            BEGIN
                INSERT INTO juego.suspension
                (
                    id_jugador,
                    id_criterio,
                    cant_partidos,
                    estado,
                    fecha_alta,
                    motivo
                )
                VALUES
                (
                    @id_jugador,
                    @v_id_criterio,
                    @v_cant_partidos,
                    'PENDIENTE',
                    @v_fecha_partido,
                    'Suspension por acumulacion de amarillas'
                );

                SET @id_suspension = CONVERT(INT, SCOPE_IDENTITY());
            END
        END

        IF @v_propia = 1
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION sv_registrar_tarjeta;
        THROW;
    END CATCH
END;
GO
