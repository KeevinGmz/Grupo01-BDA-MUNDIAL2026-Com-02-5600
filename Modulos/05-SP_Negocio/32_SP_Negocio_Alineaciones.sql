/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Crea los procedimientos transaccionales de negocio para registrar alineaciones y sustituciones.
===================================================================== */
USE Mundial2026;
GO

-- ----------------------------------------------------------------------------
-- Registrar Alineacion
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE juego.usp_Negocio_RegistrarAlineacion
    @id_partido INT,
    @id_seleccion INT,
    @esquema_tactico VARCHAR(10),
    @alineacion juego.tt_Alineacion READONLY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_codigo INT = 50001;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    DECLARE @v_estado VARCHAR(12);
    DECLARE @v_fecha_partido DATE;
    DECLARE @v_titulares INT;
    DECLARE @v_suplentes INT;
    DECLARE @v_titulares_regla INT;
    DECLARE @v_max_suplentes INT;

    SELECT
        @v_estado = p.estado,
        @v_fecha_partido = CONVERT(DATE, p.fecha_hora_utc)
    FROM torneo.partido AS p
    WHERE p.id_partido = @id_partido;

    SELECT @v_titulares = COUNT(*)
    FROM @alineacion
    WHERE es_titular = 1;

    SELECT @v_suplentes = COUNT(*)
    FROM @alineacion
    WHERE es_titular = 0;

    SELECT TOP (1) @v_titulares_regla = CONVERT(INT, pr.valor)
    FROM torneo.parametro_reglamento AS pr
    WHERE pr.clave = 'TITULARES'
      AND pr.vigente_desde <= @v_fecha_partido
    ORDER BY pr.vigente_desde DESC;

    SELECT TOP (1) @v_max_suplentes = CONVERT(INT, pr.valor)
    FROM torneo.parametro_reglamento AS pr
    WHERE pr.clave = 'MAX_SUPLENTES'
      AND pr.vigente_desde <= @v_fecha_partido
    ORDER BY pr.vigente_desde DESC;

    -- 1) Validaciones acumuladas antes de abrir la transaccion
    IF @v_estado IS NULL
        SET @v_errores += N'partido inexistente; ';

    IF @v_estado IS NOT NULL
       AND @v_estado NOT IN ('PROGRAMADO', 'EN_CURSO')
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'el partido debe estar PROGRAMADO o EN_CURSO; ';
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM torneo.equipo_en_partido AS ep
        WHERE ep.id_partido = @id_partido
          AND ep.id_seleccion = @id_seleccion
    )
        SET @v_errores += N'la seleccion no participa del partido; ';

    IF NULLIF(LTRIM(RTRIM(@esquema_tactico)), '') IS NULL
        SET @v_errores += N'esquema_tactico obligatorio; ';
    ELSE IF @esquema_tactico NOT LIKE '[1-9]-[0-9]-[0-9]'
        AND @esquema_tactico NOT LIKE '[1-9]-[0-9]-[0-9]-[0-9]'
        AND @esquema_tactico NOT LIKE '[1-9]-[0-9]-[0-9]-[0-9]-[0-9]'
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'esquema_tactico con formato invalido; ';
    END

    IF @v_titulares_regla IS NULL OR @v_max_suplentes IS NULL
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'faltan parametros vigentes TITULARES o MAX_SUPLENTES; ';
    END
    ELSE
    BEGIN
        IF @v_titulares <> @v_titulares_regla
        BEGIN
            SET @v_codigo = 50003;
            SET @v_errores += CONCAT(N'la alineacion debe incluir exactamente ', @v_titulares_regla, N' titulares; ');
        END

        IF @v_suplentes > @v_max_suplentes
        BEGIN
            SET @v_codigo = 50003;
            SET @v_errores += CONCAT(N'la alineacion supera el maximo de ', @v_max_suplentes, N' suplentes; ');
        END
    END

    IF EXISTS
    (
        SELECT a.dorsal
        FROM @alineacion AS a
        GROUP BY a.dorsal
        HAVING COUNT(*) > 1
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'los dorsales no pueden repetirse en la alineacion; ';
    END

    IF EXISTS
    (
        SELECT 1
        FROM @alineacion AS a
        LEFT JOIN torneo.convocatoria AS c
          ON c.id_seleccion = @id_seleccion
         AND c.id_jugador = a.id_jugador
         AND c.estado = 'ACTIVO'
        WHERE c.id_jugador IS NULL
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'todos los jugadores deben estar convocados ACTIVO por la seleccion; ';
    END

    IF EXISTS
    (
        SELECT 1
        FROM @alineacion AS a
        JOIN torneo.convocatoria AS c
          ON c.id_seleccion = @id_seleccion
         AND c.id_jugador = a.id_jugador
         AND c.estado = 'ACTIVO'
        WHERE c.dorsal <> a.dorsal
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'el dorsal de cada jugador debe coincidir con su convocatoria; ';
    END

    IF EXISTS
    (
        SELECT 1
        FROM @alineacion AS a
        LEFT JOIN persona.posicion AS pos
          ON pos.id_posicion = a.id_posicion
        WHERE pos.id_posicion IS NULL
    )
        SET @v_errores += N'la alineacion contiene posiciones inexistentes; ';

    IF EXISTS
    (
        SELECT 1
        FROM @alineacion AS a
        JOIN persona.jugador AS j
          ON j.id_persona = a.id_jugador
        WHERE a.es_posicion_habitual <>
              CASE WHEN a.id_posicion = j.id_posicion_habitual THEN 1 ELSE 0 END
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'es_posicion_habitual no coincide con la posicion habitual del jugador; ';
    END

    IF EXISTS
    (
        SELECT 1
        FROM @alineacion AS a
        WHERE juego.fn_JugadorSuspendidoEnPartido(a.id_jugador, @id_partido) = 1
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'la alineacion contiene jugadores suspendidos para este partido; ';
    END

    IF EXISTS
    (
        SELECT 1 FROM juego.sustitucion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion
        UNION ALL
        SELECT 1 FROM juego.gol WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion
        UNION ALL
        SELECT 1 FROM juego.tarjeta WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'no se puede reemplazar la alineacion porque la seleccion ya tiene eventos registrados; ';
    END

    IF @v_errores <> N''
    BEGIN
        SET @v_errores = LEFT(CONCAT(N'juego.usp_Negocio_RegistrarAlineacion: ', @v_errores), 2048);
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
            SAVE TRANSACTION sv_registrar_alineacion;
            SET @v_sp = 1;
        END

        UPDATE torneo.equipo_en_partido
        SET esquema_tactico = @esquema_tactico
        WHERE id_partido = @id_partido
          AND id_seleccion = @id_seleccion;

        DELETE FROM juego.alineacion
        WHERE id_partido = @id_partido
          AND id_seleccion = @id_seleccion;

        INSERT INTO juego.alineacion
        (
            id_partido,
            id_seleccion,
            id_jugador,
            dorsal,
            es_titular,
            id_posicion,
            es_posicion_habitual
        )
        SELECT
            @id_partido,
            @id_seleccion,
            a.id_jugador,
            a.dorsal,
            a.es_titular,
            a.id_posicion,
            a.es_posicion_habitual
        FROM @alineacion AS a;

        IF @v_propia = 1
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION sv_registrar_alineacion;
        THROW;
    END CATCH
END;
GO





-- ----------------------------------------------------------------------------
-- Registrar Sustitucion
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE juego.usp_Negocio_RegistrarSustitucion
    @id_partido INT,
    @id_seleccion INT,
    @id_jugador_sale INT,
    @id_jugador_entra INT,
    @minuto SMALLINT,
    @motivo VARCHAR(12),
    @nro_sustitucion TINYINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_codigo INT = 50001;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    DECLARE @v_estado VARCHAR(12);
    DECLARE @v_fecha_partido DATE;
    DECLARE @v_admite_alargue BIT;
    DECLARE @v_max_sustituciones INT;
    DECLARE @v_max_extra INT;
    DECLARE @v_max_ventanas INT;
    DECLARE @v_nro_ventana TINYINT;
    DECLARE @v_cambios_reglamentarios INT;
    DECLARE @v_cambios_alargue INT;
    DECLARE @v_ventanas_reglamentarias INT;
    DECLARE @v_ventanas_alargue INT;

    SELECT
        @v_estado = p.estado,
        @v_fecha_partido = CONVERT(DATE, p.fecha_hora_utc),
        @v_admite_alargue = f.admite_alargue
    FROM torneo.partido AS p
    JOIN torneo.fase AS f
      ON f.nro_fase = p.nro_fase
    WHERE p.id_partido = @id_partido;

    SELECT TOP (1) @v_max_sustituciones = CONVERT(INT, pr.valor)
    FROM torneo.parametro_reglamento AS pr
    WHERE pr.clave = 'MAX_SUSTITUCIONES'
      AND pr.vigente_desde <= @v_fecha_partido
    ORDER BY pr.vigente_desde DESC;

    SELECT TOP (1) @v_max_extra = CONVERT(INT, pr.valor)
    FROM torneo.parametro_reglamento AS pr
    WHERE pr.clave = 'MAX_SUSTITUCIONES_ALARGUE'
      AND pr.vigente_desde <= @v_fecha_partido
    ORDER BY pr.vigente_desde DESC;

    SELECT TOP (1) @v_max_ventanas = CONVERT(INT, pr.valor)
    FROM torneo.parametro_reglamento AS pr
    WHERE pr.clave = 'MAX_VENTANAS_SUSTITUCION'
      AND pr.vigente_desde <= @v_fecha_partido
    ORDER BY pr.vigente_desde DESC;

    -- 1) Validaciones acumuladas antes de abrir la transaccion
    IF @v_estado IS NULL
        SET @v_errores += N'partido inexistente; ';

    IF @v_estado IS NOT NULL AND @v_estado <> 'EN_CURSO'
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'el partido debe estar EN_CURSO para registrar una sustitucion; ';
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM torneo.equipo_en_partido AS ep
        WHERE ep.id_partido = @id_partido
          AND ep.id_seleccion = @id_seleccion
    )
        SET @v_errores += N'la seleccion no participa del partido; ';

    IF @id_jugador_sale IS NOT NULL
       AND @id_jugador_entra IS NOT NULL
       AND @id_jugador_sale = @id_jugador_entra
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'los jugadores saliente y entrante deben ser distintos; ';
    END

    IF @minuto IS NULL OR @minuto < 1 OR @minuto > 120
        SET @v_errores += N'minuto obligatorio y debe estar entre 1 y 120; ';

    IF @minuto > 90 AND ISNULL(@v_admite_alargue, 0) = 0
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'la fase no admite sustituciones en alargue; ';
    END

    IF @motivo IS NULL OR @motivo NOT IN ('TACTICO', 'LESION', 'PRECAUCION')
        SET @v_errores += N'motivo invalido; ';

    IF NOT EXISTS
    (
        SELECT 1
        FROM juego.alineacion AS a
        WHERE a.id_partido = @id_partido
          AND a.id_seleccion = @id_seleccion
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'la seleccion no tiene una alineacion registrada; ';
    END

    IF @minuto IS NOT NULL
       AND NOT EXISTS
       (
           SELECT 1
           FROM juego.fn_EquipoEnCancha(@id_partido, @id_seleccion, @minuto) AS ec
           WHERE ec.id_jugador = @id_jugador_sale
       )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'el jugador saliente no esta en cancha al minuto indicado; ';
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM juego.alineacion AS a
        WHERE a.id_partido = @id_partido
          AND a.id_seleccion = @id_seleccion
          AND a.id_jugador = @id_jugador_entra
          AND a.es_titular = 0
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'el jugador entrante debe estar alineado como suplente; ';
    END

    IF EXISTS
    (
        SELECT 1
        FROM juego.sustitucion AS s
        WHERE s.id_partido = @id_partido
          AND s.id_seleccion = @id_seleccion
          AND
          (
              s.id_jugador_entra = @id_jugador_entra
              OR s.id_jugador_sale = @id_jugador_entra
          )
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'el jugador entrante ya fue utilizado en una sustitucion; ';
    END

    IF EXISTS
    (
        SELECT 1
        FROM juego.tarjeta AS t
        JOIN juego.tipo_tarjeta AS tt
          ON tt.id_tipo = t.id_tipo
        WHERE t.id_partido = @id_partido
          AND t.id_seleccion = @id_seleccion
          AND t.id_jugador = @id_jugador_entra
          AND tt.descripcion IN ('ROJA_DIRECTA', 'ROJA_DOBLE_AMARILLA')
          AND t.minuto <= @minuto
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'el jugador entrante fue expulsado; ';
    END

    IF @v_max_sustituciones IS NULL OR @v_max_extra IS NULL OR @v_max_ventanas IS NULL
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'faltan parametros vigentes de sustituciones; ';
    END

    SELECT
        @v_cambios_reglamentarios = SUM(CASE WHEN s.minuto <= 90 THEN 1 ELSE 0 END),
        @v_cambios_alargue = SUM(CASE WHEN s.minuto > 90 THEN 1 ELSE 0 END),
        @v_ventanas_reglamentarias = COUNT(DISTINCT CASE WHEN s.nro_ventana > 0 AND s.minuto <= 90 THEN s.nro_ventana END),
        @v_ventanas_alargue = COUNT(DISTINCT CASE WHEN s.nro_ventana > 0 AND s.minuto > 90 THEN s.nro_ventana END)
    FROM juego.sustitucion AS s
    WHERE s.id_partido = @id_partido
      AND s.id_seleccion = @id_seleccion;

    SET @v_cambios_reglamentarios = ISNULL(@v_cambios_reglamentarios, 0);
    SET @v_cambios_alargue = ISNULL(@v_cambios_alargue, 0);
    SET @v_ventanas_reglamentarias = ISNULL(@v_ventanas_reglamentarias, 0);
    SET @v_ventanas_alargue = ISNULL(@v_ventanas_alargue, 0);

    IF @minuto <= 90 AND @v_max_sustituciones IS NOT NULL
       AND @v_cambios_reglamentarios >= @v_max_sustituciones
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'se alcanzo el maximo de sustituciones reglamentarias; ';
    END

    IF @minuto > 90 AND @v_max_extra IS NOT NULL
       AND @v_cambios_alargue >= @v_max_extra
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'se alcanzo el maximo de sustituciones adicionales de alargue; ';
    END

    IF @minuto = 45
        SET @v_nro_ventana = 0;
    ELSE
    BEGIN
        SELECT TOP (1) @v_nro_ventana = s.nro_ventana
        FROM juego.sustitucion AS s
        WHERE s.id_partido = @id_partido
          AND s.id_seleccion = @id_seleccion
          AND s.minuto = @minuto
        ORDER BY s.nro_sustitucion;

        IF @v_nro_ventana IS NULL
        BEGIN
            SELECT @v_nro_ventana = CONVERT(TINYINT, ISNULL(MAX(s.nro_ventana), 0) + 1)
            FROM juego.sustitucion AS s
            WHERE s.id_partido = @id_partido
              AND s.id_seleccion = @id_seleccion;

            IF @minuto <= 90
               AND @v_max_ventanas IS NOT NULL
               AND @v_ventanas_reglamentarias >= @v_max_ventanas
            BEGIN
                SET @v_codigo = 50003;
                SET @v_errores += N'se alcanzo el maximo de ventanas reglamentarias; ';
            END

            IF @minuto > 90
               AND @v_ventanas_alargue >= 1
            BEGIN
                SET @v_codigo = 50003;
                SET @v_errores += N'ya se utilizo la ventana adicional de alargue; ';
            END
        END
    END

    IF @v_errores <> N''
    BEGIN
        SET @v_errores = LEFT(CONCAT(N'juego.usp_Negocio_RegistrarSustitucion: ', @v_errores), 2048);
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
            SAVE TRANSACTION sv_registrar_sustitucion;
            SET @v_sp = 1;
        END

        SELECT @nro_sustitucion = CONVERT(TINYINT, ISNULL(MAX(s.nro_sustitucion), 0) + 1)
        FROM juego.sustitucion AS s WITH (UPDLOCK, HOLDLOCK)
        WHERE s.id_partido = @id_partido
          AND s.id_seleccion = @id_seleccion;

        INSERT INTO juego.sustitucion
        (
            id_partido,
            id_seleccion,
            nro_sustitucion,
            minuto,
            nro_ventana,
            motivo,
            id_jugador_sale,
            id_jugador_entra
        )
        VALUES
        (
            @id_partido,
            @id_seleccion,
            @nro_sustitucion,
            @minuto,
            @v_nro_ventana,
            @motivo,
            @id_jugador_sale,
            @id_jugador_entra
        );

        IF @v_propia = 1
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION sv_registrar_sustitucion;
        THROW;
    END CATCH
END;
GO
