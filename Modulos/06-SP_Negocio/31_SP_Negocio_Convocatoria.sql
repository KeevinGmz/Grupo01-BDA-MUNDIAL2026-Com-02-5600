/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Crea los procedimientos transaccionales de negocio para registrar y reemplazar convocatorias.
===================================================================== */
USE Mundial2026;
GO

-- ----------------------------------------------------------------------------
-- Registrar Convocatoria
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE torneo.usp_Negocio_RegistrarConvocatoria
    @id_seleccion INT,
    @convocados torneo.tt_Convocado READONLY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_codigo INT = 50001;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    DECLARE @v_cant_convocados INT;
    DECLARE @v_min INT;
    DECLARE @v_max INT;
    DECLARE @v_fecha DATE = CONVERT(DATE, SYSUTCDATETIME());

    -- 1) Validaciones acumuladas antes de abrir la transaccion
    SELECT @v_cant_convocados = COUNT(*)
    FROM @convocados;

    SELECT TOP (1) @v_min = CONVERT(INT, pr.valor)
    FROM torneo.parametro_reglamento AS pr
    WHERE pr.clave = 'MIN_CONVOCADOS'
      AND pr.vigente_desde <= @v_fecha
    ORDER BY pr.vigente_desde DESC;

    SELECT TOP (1) @v_max = CONVERT(INT, pr.valor)
    FROM torneo.parametro_reglamento AS pr
    WHERE pr.clave = 'MAX_CONVOCADOS'
      AND pr.vigente_desde <= @v_fecha
    ORDER BY pr.vigente_desde DESC;

    IF NOT EXISTS
    (
        SELECT 1
        FROM torneo.seleccion AS s
        WHERE s.id_seleccion = @id_seleccion
    )
        SET @v_errores += N'seleccion inexistente; ';

    IF @v_min IS NULL OR @v_max IS NULL
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'no existen parametros vigentes MIN_CONVOCADOS y MAX_CONVOCADOS; ';
    END
    ELSE IF @v_cant_convocados < @v_min OR @v_cant_convocados > @v_max
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += CONCAT
        (
            N'cantidad de convocados fuera del rango reglamentario [',
            @v_min,
            N', ',
            @v_max,
            N']; '
        );
    END

    IF EXISTS
    (
        SELECT 1
        FROM @convocados AS c
        WHERE c.dorsal NOT BETWEEN 1 AND 99
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'todos los dorsales deben estar entre 1 y 99; ';
    END

    IF EXISTS
    (
        SELECT c.dorsal
        FROM @convocados AS c
        GROUP BY c.dorsal
        HAVING COUNT(*) > 1
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'los dorsales no pueden repetirse en la lista; ';
    END

    IF EXISTS
    (
        SELECT 1
        FROM @convocados AS c
        LEFT JOIN persona.jugador AS j
          ON j.id_persona = c.id_jugador
        WHERE j.id_persona IS NULL
    )
        SET @v_errores += N'la lista contiene jugadores inexistentes; ';

    IF EXISTS
    (
        SELECT 1
        FROM torneo.convocatoria AS conv
        WHERE conv.id_seleccion = @id_seleccion
          AND conv.estado = 'ACTIVO'
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'la seleccion ya tiene una convocatoria ACTIVA; ';
    END

    IF EXISTS
    (
        SELECT 1
        FROM @convocados AS c
        JOIN torneo.convocatoria AS conv
          ON conv.id_jugador = c.id_jugador
        WHERE conv.estado = 'ACTIVO'
          AND conv.id_seleccion <> @id_seleccion
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'la lista contiene jugadores convocados activamente por otra seleccion; ';
    END

    IF @v_errores <> N''
    BEGIN
        SET @v_errores = LEFT(CONCAT(N'torneo.usp_Negocio_RegistrarConvocatoria: ', @v_errores), 2048);
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
            SAVE TRANSACTION sv_registrar_convocatoria;
            SET @v_sp = 1;
        END

        -- Operacion set-based: se inserta la lista completa o ninguna fila.
        INSERT INTO torneo.convocatoria
        (
            id_seleccion,
            id_jugador,
            dorsal,
            estado
        )
        SELECT
            @id_seleccion,
            c.id_jugador,
            c.dorsal,
            'ACTIVO'
        FROM @convocados AS c;

        IF @v_propia = 1
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION sv_registrar_convocatoria;
        THROW;
    END CATCH
END;
GO



-- ----------------------------------------------------------------------------
-- Reemplazar Convocado
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE torneo.usp_Negocio_ReemplazarConvocado
    @id_seleccion INT,
    @id_jugador_baja INT,
    @id_jugador_alta INT,
    @dorsal TINYINT,
    @motivo NVARCHAR(200),
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_codigo INT = 50001;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    DECLARE @v_dorsal_baja TINYINT;

    -- 1) Validaciones acumuladas antes de abrir la transaccion
    IF NOT EXISTS
    (
        SELECT 1
        FROM torneo.seleccion AS s
        WHERE s.id_seleccion = @id_seleccion
    )
        SET @v_errores += N'seleccion inexistente; ';

    SELECT @v_dorsal_baja = c.dorsal
    FROM torneo.convocatoria AS c
    WHERE c.id_seleccion = @id_seleccion
      AND c.id_jugador = @id_jugador_baja
      AND c.estado = 'ACTIVO';

    IF @v_dorsal_baja IS NULL
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'el jugador de baja no esta convocado ACTIVO en la seleccion; ';
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM persona.jugador AS j
        WHERE j.id_persona = @id_jugador_alta
    )
        SET @v_errores += N'jugador de alta inexistente; ';

    IF @id_jugador_baja IS NOT NULL
       AND @id_jugador_alta IS NOT NULL
       AND @id_jugador_baja = @id_jugador_alta
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'los jugadores de baja y alta deben ser distintos; ';
    END

    -- Segun el plan, el alta no debe estar convocada en ninguna seleccion.
    IF EXISTS
    (
        SELECT 1
        FROM torneo.convocatoria AS c
        WHERE c.id_jugador = @id_jugador_alta
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'el jugador de alta ya figura en una convocatoria; ';
    END

    IF @dorsal IS NULL OR @dorsal NOT BETWEEN 1 AND 99
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'dorsal obligatorio y debe estar entre 1 y 99; ';
    END

    IF @v_dorsal_baja IS NOT NULL AND @dorsal = @v_dorsal_baja
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'el dorsal del alta debe ser distinto del dorsal de la baja; ';
    END

    IF EXISTS
    (
        SELECT 1
        FROM torneo.convocatoria AS c
        WHERE c.id_seleccion = @id_seleccion
          AND c.dorsal = @dorsal
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'el dorsal indicado no esta libre en la seleccion; ';
    END

    IF NULLIF(LTRIM(RTRIM(@motivo)), N'') IS NULL
        SET @v_errores += N'motivo obligatorio; ';

    IF @fecha IS NULL
        SET @v_errores += N'fecha obligatoria; ';

    IF @v_errores <> N''
    BEGIN
        SET @v_errores = LEFT(CONCAT(N'torneo.usp_Negocio_ReemplazarConvocado: ', @v_errores), 2048);
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
            SAVE TRANSACTION sv_reemplazar_convocado;
            SET @v_sp = 1;
        END

        -- La baja conserva su fila historica y su dorsal.
        UPDATE torneo.convocatoria
        SET estado = 'BAJA'
        WHERE id_seleccion = @id_seleccion
          AND id_jugador = @id_jugador_baja
          AND estado = 'ACTIVO';

        INSERT INTO torneo.convocatoria
        (
            id_seleccion,
            id_jugador,
            dorsal,
            estado
        )
        VALUES
        (
            @id_seleccion,
            @id_jugador_alta,
            @dorsal,
            'ACTIVO'
        );

        INSERT INTO torneo.cambio_convocatoria
        (
            id_seleccion,
            id_jugador,
            tipo,
            motivo,
            fecha
        )
        VALUES
            (@id_seleccion, @id_jugador_baja, 'BAJA', @motivo, @fecha),
            (@id_seleccion, @id_jugador_alta, 'ALTA', @motivo, @fecha);

        IF @v_propia = 1
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION sv_reemplazar_convocado;
        THROW;
    END CATCH
END;
GO
