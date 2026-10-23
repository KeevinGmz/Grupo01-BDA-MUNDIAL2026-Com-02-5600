/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Crea los SP de ABM del esquema soporte.
===================================================================== */
USE Mundial2026;
GO

-- ============================================================================
-- 1. soporte.importacion
-- ============================================================================

CREATE OR ALTER PROCEDURE soporte.usp_Importacion_Insertar
    @fuente NVARCHAR(100),
    @archivo NVARCHAR(260),
    @formato VARCHAR(10),
    @fecha_inicio DATETIME2(0),
    @fecha_fin DATETIME2(0) = NULL,
    @filas_leidas INT,
    @filas_ok INT,
    @filas_error INT,
    @estado VARCHAR(10),
    @id_importacion INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transaccion; se acumulan
        IF NULLIF(LTRIM(RTRIM(@fuente)), N'') IS NULL SET @v_errores += N'fuente obligatoria; ';
        IF NULLIF(LTRIM(RTRIM(@archivo)), N'') IS NULL SET @v_errores += N'archivo obligatorio; ';
        IF @formato IS NULL OR @formato NOT IN ('CSV','JSON','XML') SET @v_errores += N'formato invalido (debe ser CSV, JSON o XML); ';
        IF @fecha_inicio IS NULL SET @v_errores += N'fecha_inicio obligatoria; ';
        IF @fecha_fin IS NOT NULL AND @fecha_inicio IS NOT NULL AND @fecha_fin < @fecha_inicio SET @v_errores += N'fecha_fin no puede ser anterior a fecha_inicio; ';
        IF @filas_leidas IS NULL OR @filas_leidas < 0 SET @v_errores += N'filas_leidas obligatoria y no negativa; ';
        IF @filas_ok IS NULL OR @filas_ok < 0 SET @v_errores += N'filas_ok obligatoria y no negativa; ';
        IF @filas_error IS NULL OR @filas_error < 0 SET @v_errores += N'filas_error obligatoria y no negativa; ';
        IF @filas_leidas IS NOT NULL AND @filas_ok IS NOT NULL AND @filas_error IS NOT NULL AND @filas_ok + @filas_error > @filas_leidas SET @v_errores += N'filas_ok mas filas_error no puede superar filas_leidas; ';
        IF @estado IS NULL OR @estado NOT IN ('EN_CURSO','OK','CON_ERROR') SET @v_errores += N'estado invalido; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'soporte.usp_Importacion_Insertar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_importacion_insertar; SET @v_sp = 1; END

        INSERT INTO soporte.importacion (fuente, archivo, formato, fecha_inicio, fecha_fin, filas_leidas, filas_ok, filas_error, estado)
        VALUES (@fuente, @archivo, @formato, @fecha_inicio, @fecha_fin, @filas_leidas, @filas_ok, @filas_error, @estado);
        SET @id_importacion = CONVERT(INT, SCOPE_IDENTITY());

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_importacion_insertar;
        THROW;
    END CATCH
END
GO


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE soporte.usp_Importacion_Modificar
    @id_importacion INT,
    @fuente NVARCHAR(100),
    @archivo NVARCHAR(260),
    @formato VARCHAR(10),
    @fecha_inicio DATETIME2(0),
    @fecha_fin DATETIME2(0) = NULL,
    @filas_leidas INT,
    @filas_ok INT,
    @filas_error INT,
    @estado VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transaccion; se acumulan
        IF NOT EXISTS (SELECT 1 FROM soporte.importacion WHERE id_importacion = @id_importacion) SET @v_errores += N'importacion inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@fuente)), N'') IS NULL SET @v_errores += N'fuente obligatoria; ';
        IF NULLIF(LTRIM(RTRIM(@archivo)), N'') IS NULL SET @v_errores += N'archivo obligatorio; ';
        IF @formato IS NULL OR @formato NOT IN ('CSV','JSON','XML') SET @v_errores += N'formato invalido (debe ser CSV, JSON o XML); ';
        IF @fecha_inicio IS NULL SET @v_errores += N'fecha_inicio obligatoria; ';
        IF @fecha_fin IS NOT NULL AND @fecha_inicio IS NOT NULL AND @fecha_fin < @fecha_inicio SET @v_errores += N'fecha_fin no puede ser anterior a fecha_inicio; ';
        IF @filas_leidas IS NULL OR @filas_leidas < 0 SET @v_errores += N'filas_leidas obligatoria y no negativa; ';
        IF @filas_ok IS NULL OR @filas_ok < 0 SET @v_errores += N'filas_ok obligatoria y no negativa; ';
        IF @filas_error IS NULL OR @filas_error < 0 SET @v_errores += N'filas_error obligatoria y no negativa; ';
        IF @filas_leidas IS NOT NULL AND @filas_ok IS NOT NULL AND @filas_error IS NOT NULL AND @filas_ok + @filas_error > @filas_leidas SET @v_errores += N'filas_ok mas filas_error no puede superar filas_leidas; ';
        IF @estado IS NULL OR @estado NOT IN ('EN_CURSO','OK','CON_ERROR') SET @v_errores += N'estado invalido; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'soporte.usp_Importacion_Modificar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_importacion_modificar; SET @v_sp = 1; END

        UPDATE soporte.importacion
        SET fuente = @fuente, archivo = @archivo, formato = @formato,
            fecha_inicio = @fecha_inicio, fecha_fin = @fecha_fin,
            filas_leidas = @filas_leidas, filas_ok = @filas_ok,
            filas_error = @filas_error, estado = @estado
        WHERE id_importacion = @id_importacion;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_importacion_modificar;
        THROW;
    END CATCH
END
GO


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE soporte.usp_Importacion_Eliminar
    @id_importacion INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM soporte.importacion WHERE id_importacion = @id_importacion)
            THROW 50001, N'soporte.usp_Importacion_Eliminar: importacion inexistente', 1;

        -- 2) Dependientes: una linea por cada tabla con FK a esta fila
        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM soporte.importacion_error WHERE id_importacion = @id_importacion;
        IF @v_n > 0 SET @v_errores += CONCAT(N'importacion_error(', @v_n, N'); ');
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'soporte.usp_Importacion_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores), 2048);
            THROW 50002, @v_errores, 1;
        END

        -- 3) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_importacion_eliminar; SET @v_sp = 1; END

        DELETE FROM soporte.importacion WHERE id_importacion = @id_importacion;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_importacion_eliminar;
        THROW;
    END CATCH
END
GO

-- ============================================================================
-- 2. soporte.importacion_error (PK compuesta: id_importacion, nro_error)
-- ============================================================================

CREATE OR ALTER PROCEDURE soporte.usp_ImportacionError_Insertar
    @id_importacion INT,
    @nro_error INT,
    @nro_fila INT,
    @columna NVARCHAR(60) = NULL,
    @valor NVARCHAR(500) = NULL,
    @mensaje NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transaccion; se acumulan
        IF NOT EXISTS (SELECT 1 FROM soporte.importacion WHERE id_importacion = @id_importacion) SET @v_errores += N'importacion inexistente; ';
        IF @nro_error IS NULL OR @nro_error <= 0 SET @v_errores += N'nro_error obligatorio y mayor a 0; ';
        IF @nro_fila IS NULL OR @nro_fila <= 0 SET @v_errores += N'nro_fila obligatoria y mayor a 0; ';
        IF NULLIF(LTRIM(RTRIM(@mensaje)), N'') IS NULL SET @v_errores += N'mensaje obligatorio; ';
        IF EXISTS (SELECT 1 FROM soporte.importacion_error WHERE id_importacion = @id_importacion AND nro_error = @nro_error) SET @v_errores += N'importacion_error ya registrado; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'soporte.usp_ImportacionError_Insertar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_import_error_insertar; SET @v_sp = 1; END

        INSERT INTO soporte.importacion_error (id_importacion, nro_error, nro_fila, columna, valor, mensaje)
        VALUES (@id_importacion, @nro_error, @nro_fila, @columna, @valor, @mensaje);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_import_error_insertar;
        THROW;
    END CATCH
END
GO


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE soporte.usp_ImportacionError_Modificar
    @id_importacion INT,
    @nro_error INT,
    @nro_fila INT,
    @columna NVARCHAR(60) = NULL,
    @valor NVARCHAR(500) = NULL,
    @mensaje NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transaccion; se acumulan
        IF NOT EXISTS (SELECT 1 FROM soporte.importacion_error WHERE id_importacion = @id_importacion AND nro_error = @nro_error) SET @v_errores += N'importacion_error inexistente; ';
        IF @nro_fila IS NULL OR @nro_fila <= 0 SET @v_errores += N'nro_fila obligatoria y mayor a 0; ';
        IF NULLIF(LTRIM(RTRIM(@mensaje)), N'') IS NULL SET @v_errores += N'mensaje obligatorio; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'soporte.usp_ImportacionError_Modificar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_import_error_modificar; SET @v_sp = 1; END

        UPDATE soporte.importacion_error
        SET nro_fila = @nro_fila, columna = @columna, valor = @valor, mensaje = @mensaje
        WHERE id_importacion = @id_importacion AND nro_error = @nro_error;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_import_error_modificar;
        THROW;
    END CATCH
END
GO


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE soporte.usp_ImportacionError_Eliminar
    @id_importacion INT,
    @nro_error INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM soporte.importacion_error WHERE id_importacion = @id_importacion AND nro_error = @nro_error)
            THROW 50001, N'soporte.usp_ImportacionError_Eliminar: importacion_error inexistente', 1;

        -- 2) Sin dependientes
        -- 3) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_import_error_eliminar; SET @v_sp = 1; END

        DELETE FROM soporte.importacion_error
        WHERE id_importacion = @id_importacion AND nro_error = @nro_error;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_import_error_eliminar;
        THROW;
    END CATCH
END
GO
