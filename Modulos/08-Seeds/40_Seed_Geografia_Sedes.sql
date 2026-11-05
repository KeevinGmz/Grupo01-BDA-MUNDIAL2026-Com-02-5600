/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada                  Comision: 02-5600
Grupo   : 01 - Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Carga inicial de husos horarios y ocho sedes distribuidas entre ciudades de, al menos, tres husos distintos.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @v_propia BIT = 0;
DECLARE @v_sp BIT = 0;
DECLARE @v_errores VARCHAR(2000) = '';

BEGIN TRY
    IF @@TRANCOUNT = 0
    BEGIN
        BEGIN TRANSACTION;
        SET @v_propia = 1;
    END
    ELSE
    BEGIN
        SAVE TRANSACTION sv_seed_husos_sedes;
        SET @v_sp = 1;
    END

    ---------------------------------------------------------------------------
    -- 1. Husos horarios
    -- Se insertan mediante los SP de ABM.
    -- Los offsets son estandar. horario_verano indica si durante el torneo
    -- corresponde sumar 60 minutos mediante geo.fn_FechaHoraLocal.
    ---------------------------------------------------------------------------
    DECLARE @v_id_huso SMALLINT;

    IF NOT EXISTS
    (
        SELECT 1
        FROM geo.huso_horario
        WHERE zona_horaria = 'America/Argentina/Buenos_Aires'
    )
    BEGIN
        EXEC geo.usp_HusoHorario_Insertar
            @zona_horaria = 'America/Argentina/Buenos_Aires',
            @offset_utc = -180,
            @horario_verano = 0,
            @id_huso = @v_id_huso OUTPUT;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM geo.huso_horario
        WHERE zona_horaria = 'America/New_York'
    )
    BEGIN
        EXEC geo.usp_HusoHorario_Insertar
            @zona_horaria = 'America/New_York',
            @offset_utc = -300,
            @horario_verano = 1,
            @id_huso = @v_id_huso OUTPUT;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM geo.huso_horario
        WHERE zona_horaria = 'America/Bogota'
    )
    BEGIN
        EXEC geo.usp_HusoHorario_Insertar
            @zona_horaria = 'America/Bogota',
            @offset_utc = -300,
            @horario_verano = 0,
            @id_huso = @v_id_huso OUTPUT;
    END

    ---------------------------------------------------------------------------
    -- 2. Ciudades disponibles para las sedes
    ---------------------------------------------------------------------------
    DECLARE @v_ciudad_ba INT;
    DECLARE @v_ciudad_ny INT;
    DECLARE @v_ciudad_bogota INT;

    SELECT TOP (1) @v_ciudad_ba = c.id_ciudad
    FROM geo.ciudad AS c
    JOIN geo.huso_horario AS h ON h.id_huso = c.id_huso
    WHERE h.zona_horaria = 'America/Argentina/Buenos_Aires'
    ORDER BY c.poblacion DESC, c.id_ciudad;

    SELECT TOP (1) @v_ciudad_ny = c.id_ciudad
    FROM geo.ciudad AS c
    JOIN geo.huso_horario AS h ON h.id_huso = c.id_huso
    WHERE h.zona_horaria = 'America/New_York'
    ORDER BY c.poblacion DESC, c.id_ciudad;

    SELECT TOP (1) @v_ciudad_bogota = c.id_ciudad
    FROM geo.ciudad AS c
    JOIN geo.huso_horario AS h ON h.id_huso = c.id_huso
    WHERE h.zona_horaria = 'America/Bogota'
    ORDER BY c.poblacion DESC, c.id_ciudad;

    IF @v_ciudad_ba IS NULL
        SET @v_errores += 'falta una ciudad del huso America/Argentina/Buenos_Aires; ';
    IF @v_ciudad_ny IS NULL
        SET @v_errores += 'falta una ciudad del huso America/New_York; ';
    IF @v_ciudad_bogota IS NULL
        SET @v_errores += 'falta una ciudad del huso America/Bogota; ';

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('40_Seed_Husos_Sedes: ', @v_errores), 2048);
        ;THROW 50001, @v_errores, 1;
    END

    ---------------------------------------------------------------------------
    -- 3. Ocho sedes en, al menos, tres husos distintos
    -- El bucle es deterministico y esta permitido para generar volumen de seed.
    ---------------------------------------------------------------------------
    DECLARE @v_sede TINYINT = 1;
    DECLARE @v_id_sede INT;
    DECLARE @v_id_ciudad INT;
    DECLARE @v_nombre VARCHAR(100);
    DECLARE @v_capacidad INT;
    DECLARE @v_direccion VARCHAR(200);

    WHILE @v_sede <= 8
    BEGIN
        SET @v_nombre = CONCAT('Estadio Seed ', RIGHT(CONCAT('0', @v_sede), 2));
        SET @v_capacidad = 40000 + CONVERT(INT, @v_sede) * 1000;
        SET @v_direccion = CONCAT('Avenida Seed ', @v_sede);
        SET @v_id_ciudad =
            CASE
                WHEN @v_sede IN (1, 4, 7) THEN @v_ciudad_ba
                WHEN @v_sede IN (2, 5, 8) THEN @v_ciudad_ny
                ELSE @v_ciudad_bogota
            END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM torneo.sede
            WHERE nombre_estadio = @v_nombre
        )
        BEGIN
            EXEC torneo.usp_Sede_Insertar
                @nombre_estadio = @v_nombre,
                @capacidad = @v_capacidad,
                @direccion = @v_direccion,
                @latitud = NULL,
                @longitud = NULL,
                @id_ciudad = @v_id_ciudad,
                @id_sede = @v_id_sede OUTPUT;
        END

        SET @v_sede += 1;
    END

    -- Control de aceptacion del lote: ocho sedes seed y tres husos distintos.
    IF
    (
        SELECT COUNT(*)
        FROM torneo.sede
        WHERE nombre_estadio LIKE 'Estadio Seed %'
    ) <> 8
    BEGIN
        ;THROW 50003, '40_Seed_Husos_Sedes: no quedaron creadas exactamente ocho sedes seed', 1;
    END

    IF
    (
        SELECT COUNT(DISTINCT c.id_huso)
        FROM torneo.sede AS s
        JOIN geo.ciudad AS c ON c.id_ciudad = s.id_ciudad
        WHERE s.nombre_estadio LIKE 'Estadio Seed %'
    ) < 3
    BEGIN
        ;THROW 50003, '40_Seed_Husos_Sedes: las ocho sedes no cubren al menos tres husos distintos', 1;
    END

    IF @v_propia = 1
        COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @v_propia = 1 AND @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    ELSE IF @v_sp = 1 AND XACT_STATE() = 1
        ROLLBACK TRANSACTION sv_seed_husos_sedes;
    ;THROW;
END CATCH;
GO
