/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comision: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Crea los SP de ABM del esquema arbitraje.
===================================================================== */
USE Mundial2026;
GO

-- ============================================================================
-- 1. arbitraje.rol_arbitral
-- ============================================================================

CREATE OR ALTER PROCEDURE arbitraje.usp_RolArbitral_Insertar
    @descripcion VARCHAR(30),
    @id_rol TINYINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transaccion; se acumulan
        IF NULLIF(LTRIM(RTRIM(@descripcion)), '') IS NULL SET @v_errores += 'descripcion obligatoria; ';
        IF EXISTS (SELECT 1 FROM arbitraje.rol_arbitral WHERE descripcion = @descripcion) SET @v_errores += 'descripcion ya registrada; ';
        IF @v_errores <> ''
        BEGIN
            SET @v_errores = LEFT(CONCAT('arbitraje.usp_RolArbitral_Insertar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_rol_arbitral_insertar; SET @v_sp = 1; END

        INSERT INTO arbitraje.rol_arbitral (descripcion) VALUES (@descripcion);
        SET @id_rol = CONVERT(TINYINT, SCOPE_IDENTITY());

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_rol_arbitral_insertar;
        THROW;
    END CATCH
END
GO


----------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE arbitraje.usp_RolArbitral_Modificar
    @id_rol TINYINT,
    @descripcion VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transaccion; se acumulan
        IF NOT EXISTS (SELECT 1 FROM arbitraje.rol_arbitral WHERE id_rol = @id_rol) SET @v_errores += 'rol_arbitral inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@descripcion)), '') IS NULL SET @v_errores += 'descripcion obligatoria; ';
        IF EXISTS (SELECT 1 FROM arbitraje.rol_arbitral WHERE descripcion = @descripcion AND id_rol <> @id_rol) SET @v_errores += 'descripcion ya registrada; ';
        IF @v_errores <> ''
        BEGIN
            SET @v_errores = LEFT(CONCAT('arbitraje.usp_RolArbitral_Modificar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_rol_arbitral_modificar; SET @v_sp = 1; END

        UPDATE arbitraje.rol_arbitral SET descripcion = @descripcion WHERE id_rol = @id_rol;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_rol_arbitral_modificar;
        THROW;
    END CATCH
END
GO


----------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE arbitraje.usp_RolArbitral_Eliminar
    @id_rol TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM arbitraje.rol_arbitral WHERE id_rol = @id_rol)
            THROW 50001, 'arbitraje.usp_RolArbitral_Eliminar: rol_arbitral inexistente', 1;

        -- 2) Dependientes: una linea por cada tabla con FK a esta fila
        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM arbitraje.designacion_arbitral WHERE id_rol = @id_rol;
        IF @v_n > 0 SET @v_errores += CONCAT('designacion_arbitral(', @v_n, '); ');
        IF @v_errores <> ''
        BEGIN
            SET @v_errores = LEFT(CONCAT('arbitraje.usp_RolArbitral_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores), 2048);
            THROW 50002, @v_errores, 1;
        END

        -- 3) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_rol_arbitral_eliminar; SET @v_sp = 1; END

        DELETE FROM arbitraje.rol_arbitral WHERE id_rol = @id_rol;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_rol_arbitral_eliminar;
        THROW;
    END CATCH
END
GO


-- ============================================================================
-- 2. arbitraje.designacion_arbitral (PK compuesta: id_partido, id_rol)
-- ============================================================================

CREATE OR ALTER PROCEDURE arbitraje.usp_DesignacionArbitral_Insertar
    @id_partido INT,
    @id_rol TINYINT,
    @id_arbitro INT,
    @fecha_designacion DATETIME2(0),
    @estado VARCHAR(10) = 'DESIGNADA'
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones comunes del ABM y V-11 del plan
        IF NOT EXISTS (SELECT 1 FROM torneo.partido WHERE id_partido = @id_partido) SET @v_errores += 'partido inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM arbitraje.rol_arbitral WHERE id_rol = @id_rol) SET @v_errores += 'rol_arbitral inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM persona.arbitro WHERE id_persona = @id_arbitro) SET @v_errores += 'arbitro inexistente; ';
        IF @fecha_designacion IS NULL SET @v_errores += 'fecha_designacion obligatoria; ';
        IF @estado IS NULL OR @estado NOT IN ('DESIGNADA', 'ANULADA') SET @v_errores += 'estado invalido; ';
        IF EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral WHERE id_partido = @id_partido AND id_rol = @id_rol) SET @v_errores += 'designacion ya registrada para el partido y rol; ';
        IF EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral WHERE id_partido = @id_partido AND id_arbitro = @id_arbitro) SET @v_errores += 'arbitro ya asignado al partido en otro rol; ';

        IF EXISTS (
            SELECT 1
            FROM persona.persona pe
            JOIN torneo.partido p ON p.id_partido = @id_partido
            JOIN torneo.equipo_en_partido ep ON ep.id_partido = p.id_partido
            JOIN torneo.seleccion s ON s.id_seleccion = ep.id_seleccion
            WHERE pe.id_persona = @id_arbitro
              AND pe.id_pais = s.id_pais
        ) SET @v_errores += 'el pais del arbitro coincide con el de una seleccion del partido; ';

        IF EXISTS (
            SELECT 1
            FROM torneo.partido p_nuevo
            JOIN arbitraje.designacion_arbitral da ON da.id_arbitro = @id_arbitro AND da.estado = 'DESIGNADA'
            JOIN torneo.partido p_otro ON p_otro.id_partido = da.id_partido
            WHERE p_nuevo.id_partido = @id_partido
              AND da.id_partido <> @id_partido
              AND ABS(DATEDIFF(MINUTE, p_nuevo.fecha_hora_utc, p_otro.fecha_hora_utc)) < 180
        ) SET @v_errores += 'arbitro designado en otro partido con menos de 3 horas de diferencia; ';

        IF @v_errores <> ''
        BEGIN
            SET @v_errores = LEFT(CONCAT('arbitraje.usp_DesignacionArbitral_Insertar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_designacion_arbitral_insertar; SET @v_sp = 1; END

        INSERT INTO arbitraje.designacion_arbitral (id_partido, id_rol, id_arbitro, fecha_designacion, estado)
        VALUES (@id_partido, @id_rol, @id_arbitro, @fecha_designacion, @estado);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_designacion_arbitral_insertar;
        THROW;
    END CATCH
END
GO


----------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE arbitraje.usp_DesignacionArbitral_Modificar
    @id_partido INT,
    @id_rol TINYINT,
    @id_arbitro INT,
    @fecha_designacion DATETIME2(0),
    @estado VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: PK, FK, UQ, CK y reglas V-11 aplicables al nuevo arbitro
        IF NOT EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral WHERE id_partido = @id_partido AND id_rol = @id_rol) SET @v_errores += 'designacion_arbitral inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM persona.arbitro WHERE id_persona = @id_arbitro) SET @v_errores += 'arbitro inexistente; ';
        IF @fecha_designacion IS NULL SET @v_errores += 'fecha_designacion obligatoria; ';
        IF @estado IS NULL OR @estado NOT IN ('DESIGNADA', 'ANULADA') SET @v_errores += 'estado invalido; ';
        IF EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral WHERE id_partido = @id_partido AND id_arbitro = @id_arbitro AND id_rol <> @id_rol) SET @v_errores += 'arbitro ya asignado a otro rol en el partido; ';

        IF EXISTS (
            SELECT 1
            FROM persona.persona pe
            JOIN torneo.equipo_en_partido ep ON ep.id_partido = @id_partido
            JOIN torneo.seleccion s ON s.id_seleccion = ep.id_seleccion
            WHERE pe.id_persona = @id_arbitro
              AND pe.id_pais = s.id_pais
        ) SET @v_errores += 'el pais del arbitro coincide con el de una seleccion del partido; ';

        IF EXISTS (
            SELECT 1
            FROM torneo.partido p_nuevo
            JOIN arbitraje.designacion_arbitral da ON da.id_arbitro = @id_arbitro AND da.estado = 'DESIGNADA'
            JOIN torneo.partido p_otro ON p_otro.id_partido = da.id_partido
            WHERE p_nuevo.id_partido = @id_partido
              AND da.id_partido <> @id_partido
              AND ABS(DATEDIFF(MINUTE, p_nuevo.fecha_hora_utc, p_otro.fecha_hora_utc)) < 180
        ) SET @v_errores += 'arbitro designado en otro partido con menos de 3 horas de diferencia; ';

        IF @v_errores <> ''
        BEGIN
            SET @v_errores = LEFT(CONCAT('arbitraje.usp_DesignacionArbitral_Modificar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_desig_arbitral_modificar; SET @v_sp = 1; END

        UPDATE arbitraje.designacion_arbitral
        SET id_arbitro = @id_arbitro, fecha_designacion = @fecha_designacion, estado = @estado
        WHERE id_partido = @id_partido AND id_rol = @id_rol;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_desig_arbitral_modificar;
        THROW;
    END CATCH
END
GO


----------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE arbitraje.usp_DesignacionArbitral_Eliminar
    @id_partido INT,
    @id_rol TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral WHERE id_partido = @id_partido AND id_rol = @id_rol)
            THROW 50001, 'arbitraje.usp_DesignacionArbitral_Eliminar: designacion_arbitral inexistente', 1;

        -- 2) Sin dependientes: informe_post_partido es entidad fuerte y no tiene FK
        -- 3) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_designacion_arbitral_eliminar; SET @v_sp = 1; END

        DELETE FROM arbitraje.designacion_arbitral WHERE id_partido = @id_partido AND id_rol = @id_rol;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_designacion_arbitral_eliminar;
        THROW;
    END CATCH
END
GO


-- ============================================================================
-- 3. arbitraje.informe_post_partido
-- ============================================================================

CREATE OR ALTER PROCEDURE arbitraje.usp_InformePostPartido_Insertar
    @fecha_informe DATETIME2(0),
    @tipo VARCHAR(30),
    @descripcion VARCHAR(1000),
    @sancion_aplicada VARCHAR(200) = NULL,
    @id_informe INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transaccion; se acumulan
        IF @fecha_informe IS NULL SET @v_errores += 'fecha_informe obligatoria; ';
        IF NULLIF(LTRIM(RTRIM(@tipo)), '') IS NULL SET @v_errores += 'tipo obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@descripcion)), '') IS NULL SET @v_errores += 'descripcion obligatoria; ';
        IF @v_errores <> ''
        BEGIN
            SET @v_errores = LEFT(CONCAT('arbitraje.usp_InformePostPartido_Insertar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_informe_post_partido_insertar; SET @v_sp = 1; END

        INSERT INTO arbitraje.informe_post_partido (fecha_informe, tipo, descripcion, sancion_aplicada)
        VALUES (@fecha_informe, @tipo, @descripcion, @sancion_aplicada);
        SET @id_informe = CONVERT(INT, SCOPE_IDENTITY());

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_informe_post_partido_insertar;
        THROW;
    END CATCH
END
GO


----------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE arbitraje.usp_InformePostPartido_Modificar
    @id_informe INT,
    @fecha_informe DATETIME2(0),
    @tipo VARCHAR(30),
    @descripcion VARCHAR(1000),
    @sancion_aplicada VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transaccion; se acumulan
        IF NOT EXISTS (SELECT 1 FROM arbitraje.informe_post_partido WHERE id_informe = @id_informe) SET @v_errores += 'informe_post_partido inexistente; ';
        IF @fecha_informe IS NULL SET @v_errores += 'fecha_informe obligatoria; ';
        IF NULLIF(LTRIM(RTRIM(@tipo)), '') IS NULL SET @v_errores += 'tipo obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@descripcion)), '') IS NULL SET @v_errores += 'descripcion obligatoria; ';
        IF @v_errores <> ''
        BEGIN
            SET @v_errores = LEFT(CONCAT('arbitraje.usp_InformePostPartido_Modificar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_info_post_partido_modificar; SET @v_sp = 1; END

        UPDATE arbitraje.informe_post_partido
        SET fecha_informe = @fecha_informe, tipo = @tipo, descripcion = @descripcion, sancion_aplicada = @sancion_aplicada
        WHERE id_informe = @id_informe;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_info_post_partido_modificar;
        THROW;
    END CATCH
END
GO


----------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE arbitraje.usp_InformePostPartido_Eliminar
    @id_informe INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM arbitraje.informe_post_partido WHERE id_informe = @id_informe)
            THROW 50001, 'arbitraje.usp_InformePostPartido_Eliminar: informe_post_partido inexistente', 1;

        -- 2) Sin dependientes: entidad fuerte sin FK entrantes
        -- 3) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_informe_post_partido_eliminar; SET @v_sp = 1; END

        DELETE FROM arbitraje.informe_post_partido WHERE id_informe = @id_informe;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_informe_post_partido_eliminar;
        THROW;
    END CATCH
END
GO
