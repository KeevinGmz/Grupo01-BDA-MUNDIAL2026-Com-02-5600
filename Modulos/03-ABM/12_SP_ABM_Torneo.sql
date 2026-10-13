/* ===================================================================== 
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Crea los SP de ABM del esquema torneo, con validaciones acumuladas, control de dependencias y manejo transaccional.
===================================================================== */
USE Mundial2026;
GO

-- ----------------------------------------------------------------------------
-- 1. torneo.grupo (PK manual: id_letra CHAR(1))
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE torneo.usp_Grupo_Insertar
    @id_letra CHAR(1)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF @id_letra IS NULL OR @id_letra NOT BETWEEN 'A' AND 'L' SET @v_errores += N'id_letra obligatoria y debe estar entre A y L; ';
        IF EXISTS (SELECT 1 FROM torneo.grupo WHERE id_letra = @id_letra) SET @v_errores += N'id_letra ya registrado; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Grupo_Insertar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_grupo_insertar; SET @v_sp = 1; END

        INSERT INTO torneo.grupo (id_letra) VALUES (@id_letra);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_grupo_insertar;
        THROW;
    END CATCH
END
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Grupo_Eliminar
    @id_letra CHAR(1)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.grupo WHERE id_letra = @id_letra) THROW 50001, N'torneo.usp_Grupo_Eliminar: grupo inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM torneo.seleccion WHERE id_letra = @id_letra;
        IF @v_n > 0 SET @v_errores += CONCAT(N'seleccion(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Grupo_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores), 2048);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_grupo_eliminar; SET @v_sp = 1; END

        DELETE FROM torneo.grupo WHERE id_letra = @id_letra;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_grupo_eliminar;
        THROW;
    END CATCH
END
GO


-- ----------------------------------------------------------------------------
-- 2. torneo.fase (PK manual: nro_fase TINYINT - no identity)
-- ----------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Fase_Insertar
    @nro_fase TINYINT,
    @nombre NVARCHAR(40),
    @es_eliminacion BIT,
    @admite_alargue BIT,
    @admite_penales BIT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF @nro_fase NOT BETWEEN 1 AND 7 SET @v_errores += N'nro_fase debe estar entre 1 y 7; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL SET @v_errores += N'nombre obligatorio; ';
        IF @es_eliminacion IS NULL SET @v_errores += N'es_eliminacion obligatorio; ';
        IF @admite_alargue IS NULL SET @v_errores += N'admite_alargue obligatorio; ';
        IF @admite_penales IS NULL SET @v_errores += N'admite_penales obligatorio; ';
        IF EXISTS (SELECT 1 FROM torneo.fase WHERE nro_fase = @nro_fase) SET @v_errores += N'nro_fase ya registrado; ';
        IF EXISTS (SELECT 1 FROM torneo.fase WHERE nombre = @nombre) SET @v_errores += N'nombre de fase ya registrado; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Fase_Insertar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_fase_insertar; SET @v_sp = 1; END

        INSERT INTO torneo.fase (nro_fase, nombre, es_eliminacion, admite_alargue, admite_penales)
        VALUES (@nro_fase, @nombre, @es_eliminacion, @admite_alargue, @admite_penales);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_fase_insertar;
        THROW;
    END CATCH
END
GO



---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Fase_Modificar
    @nro_fase TINYINT,
    @nombre NVARCHAR(40),
    @es_eliminacion BIT,
    @admite_alargue BIT,
    @admite_penales BIT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.fase WHERE nro_fase = @nro_fase) SET @v_errores += N'fase inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL SET @v_errores += N'nombre obligatorio; ';
        IF @es_eliminacion IS NULL SET @v_errores += N'es_eliminacion obligatorio; ';
        IF @admite_alargue IS NULL SET @v_errores += N'admite_alargue obligatorio; ';
        IF @admite_penales IS NULL SET @v_errores += N'admite_penales obligatorio; ';
        IF EXISTS (SELECT 1 FROM torneo.fase WHERE nombre = @nombre AND nro_fase <> @nro_fase) SET @v_errores += N'nombre de fase ya registrado; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Fase_Modificar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_fase_modificar; SET @v_sp = 1; END

        UPDATE torneo.fase
        SET nombre = @nombre, es_eliminacion = @es_eliminacion, admite_alargue = @admite_alargue, admite_penales = @admite_penales
        WHERE nro_fase = @nro_fase;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_fase_modificar;
        THROW;
    END CATCH
END
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Fase_Eliminar
    @nro_fase TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.fase WHERE nro_fase = @nro_fase) THROW 50001, N'torneo.usp_Fase_Eliminar: fase inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM torneo.partido WHERE nro_fase = @nro_fase;
        IF @v_n > 0 SET @v_errores += CONCAT(N'partido(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Fase_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores), 2048);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_fase_eliminar; SET @v_sp = 1; END

        DELETE FROM torneo.fase WHERE nro_fase = @nro_fase;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_fase_eliminar;
        THROW;
    END CATCH
END
GO



-- ----------------------------------------------------------------------------
-- 3. torneo.parametro_reglamento (PK Compuesta: clave, vigente_desde)
-- ----------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_ParametroReglamento_Insertar
    @clave VARCHAR(40),
    @vigente_desde DATE,
    @valor INT,
    @descripcion NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NULLIF(LTRIM(RTRIM(@clave)), N'') IS NULL SET @v_errores += N'clave obligatoria; ';
        IF @vigente_desde IS NULL SET @v_errores += N'vigente_desde obligatorio; ';
        IF @valor IS NULL SET @v_errores += N'valor obligatorio; ';
        IF EXISTS (SELECT 1 FROM torneo.parametro_reglamento WHERE clave = @clave AND vigente_desde = @vigente_desde) SET @v_errores += N'parametro_reglamento ya registrado con esa clave y fecha; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_ParametroReglamento_Insertar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_param_reglamento_insertar; SET @v_sp = 1; END

        INSERT INTO torneo.parametro_reglamento (clave, vigente_desde, valor, descripcion)
        VALUES (@clave, @vigente_desde, @valor, @descripcion);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_param_reglamento_insertar;
        THROW;
    END CATCH
END
GO



---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_ParametroReglamento_Modificar
    @clave VARCHAR(40),
    @vigente_desde DATE,
    @valor INT,
    @descripcion NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NULLIF(LTRIM(RTRIM(@clave)), N'') IS NULL SET @v_errores += N'clave obligatoria; ';
        IF @vigente_desde IS NULL SET @v_errores += N'vigente_desde obligatorio; ';
        IF NOT EXISTS (SELECT 1 FROM torneo.parametro_reglamento WHERE clave = @clave AND vigente_desde = @vigente_desde) SET @v_errores += N'parametro_reglamento inexistente; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_ParametroReglamento_Modificar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_param_reglamento_modificar; SET @v_sp = 1; END

        -- Modificar solo cambia valor y descripción
        UPDATE torneo.parametro_reglamento
        SET valor = @valor, descripcion = @descripcion
        WHERE clave = @clave AND vigente_desde = @vigente_desde;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_param_reglamento_modificar;
        THROW;
    END CATCH
END
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_ParametroReglamento_Eliminar
    @clave VARCHAR(40),
    @vigente_desde DATE
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.parametro_reglamento WHERE clave = @clave AND vigente_desde = @vigente_desde) THROW 50001, N'torneo.usp_ParametroReglamento_Eliminar: parametro_reglamento inexistente', 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_param_reglamento_eliminar; SET @v_sp = 1; END

        DELETE FROM torneo.parametro_reglamento WHERE clave = @clave AND vigente_desde = @vigente_desde;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_param_reglamento_eliminar;
        THROW;
    END CATCH
END
GO



-- ----------------------------------------------------------------------------
-- 4. torneo.seleccion
-- ----------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Seleccion_Insertar
    @id_letra CHAR(1),
    @id_pais SMALLINT,
    @fecha_confirmacion DATE = NULL,
    @es_anfitrion BIT = 0,
    @id_seleccion INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.grupo WHERE id_letra = @id_letra) SET @v_errores += N'grupo inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais) SET @v_errores += N'pais inexistente; ';
        IF @es_anfitrion IS NULL SET @v_errores += N'es_anfitrion obligatorio; ';
        IF (SELECT COUNT(*) FROM torneo.seleccion WHERE id_letra = @id_letra) >= 4 SET @v_errores += N'el grupo ya tiene el maximo de 4 selecciones; ';
        IF EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_pais = @id_pais) SET @v_errores += N'el pais ya tiene una seleccion asignada; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Seleccion_Insertar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_seleccion_insertar; SET @v_sp = 1; END

        INSERT INTO torneo.seleccion (id_letra, id_pais, fecha_confirmacion, es_anfitrion)
        VALUES (@id_letra, @id_pais, @fecha_confirmacion, @es_anfitrion);
        SET @id_seleccion = CONVERT(INT, SCOPE_IDENTITY());

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_seleccion_insertar;
        THROW;
    END CATCH
END
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Seleccion_Modificar
    @id_seleccion INT,
    @id_letra CHAR(1),
    @id_pais SMALLINT,
    @fecha_confirmacion DATE = NULL,
    @es_anfitrion BIT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_seleccion = @id_seleccion) SET @v_errores += N'seleccion inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM torneo.grupo WHERE id_letra = @id_letra) SET @v_errores += N'grupo inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais) SET @v_errores += N'pais inexistente; ';
        IF @es_anfitrion IS NULL SET @v_errores += N'es_anfitrion obligatorio; ';
        IF (SELECT COUNT(*) FROM torneo.seleccion WHERE id_letra = @id_letra AND id_seleccion <> @id_seleccion) >= 4 SET @v_errores += N'el grupo ya tiene el maximo de 4 selecciones; ';
        IF EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_pais = @id_pais AND id_seleccion <> @id_seleccion) SET @v_errores += N'pais ya asignado a otra seleccion; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Seleccion_Modificar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_seleccion_modificar; SET @v_sp = 1; END

        UPDATE torneo.seleccion
        SET id_letra = @id_letra, id_pais = @id_pais, fecha_confirmacion = @fecha_confirmacion, es_anfitrion = @es_anfitrion
        WHERE id_seleccion = @id_seleccion;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_seleccion_modificar;
        THROW;
    END CATCH
END
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Seleccion_Eliminar
    @id_seleccion INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_seleccion = @id_seleccion) THROW 50001, N'torneo.usp_Seleccion_Eliminar: seleccion inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM persona.miembro_cuerpo_tecnico WHERE id_seleccion = @id_seleccion;
        IF @v_n > 0 SET @v_errores += CONCAT(N'miembro_cuerpo_tecnico(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM torneo.equipo_en_partido WHERE id_seleccion = @id_seleccion;
        IF @v_n > 0 SET @v_errores += CONCAT(N'equipo_en_partido(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM torneo.convocatoria WHERE id_seleccion = @id_seleccion;
        IF @v_n > 0 SET @v_errores += CONCAT(N'convocatoria(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM torneo.cambio_convocatoria WHERE id_seleccion = @id_seleccion;
        IF @v_n > 0 SET @v_errores += CONCAT(N'cambio_convocatoria(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Seleccion_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores), 2048);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_seleccion_eliminar; SET @v_sp = 1; END

        DELETE FROM torneo.seleccion WHERE id_seleccion = @id_seleccion;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_seleccion_eliminar;
        THROW;
    END CATCH
END
GO


-- ----------------------------------------------------------------------------
-- 5. torneo.sede
-- ----------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Sede_Insertar
    @nombre_estadio NVARCHAR(100),
    @capacidad INT,
    @direccion NVARCHAR(200) = NULL,
    @latitud DECIMAL(9,6) = NULL,
    @longitud DECIMAL(9,6) = NULL,
    @id_ciudad INT,
    @id_sede INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NULLIF(LTRIM(RTRIM(@nombre_estadio)), N'') IS NULL SET @v_errores += N'nombre_estadio obligatorio; ';
        IF @capacidad IS NULL OR @capacidad <= 0 SET @v_errores += N'capacidad obligatoria y debe ser mayor a 0; ';
        IF @latitud IS NOT NULL AND @latitud NOT BETWEEN -90 AND 90 SET @v_errores += N'latitud fuera de rango (-90 a 90); ';
        IF @longitud IS NOT NULL AND @longitud NOT BETWEEN -180 AND 180 SET @v_errores += N'longitud fuera de rango (-180 a 180); ';
        IF (@latitud IS NULL AND @longitud IS NOT NULL) OR (@latitud IS NOT NULL AND @longitud IS NULL) SET @v_errores += N'latitud y longitud deben informarse juntas; ';
        IF NOT EXISTS (SELECT 1 FROM geo.ciudad WHERE id_ciudad = @id_ciudad) SET @v_errores += N'ciudad inexistente; ';
        IF EXISTS (SELECT 1 FROM torneo.sede WHERE nombre_estadio = @nombre_estadio) SET @v_errores += N'nombre_estadio ya registrado; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Sede_Insertar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_sede_insertar; SET @v_sp = 1; END

        INSERT INTO torneo.sede (nombre_estadio, capacidad, direccion, latitud, longitud, id_ciudad)
        VALUES (@nombre_estadio, @capacidad, @direccion, @latitud, @longitud, @id_ciudad);
        SET @id_sede = CONVERT(INT, SCOPE_IDENTITY());

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_sede_insertar;
        THROW;
    END CATCH
END
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Sede_Modificar
    @id_sede INT,
    @nombre_estadio NVARCHAR(100),
    @capacidad INT,
    @direccion NVARCHAR(200) = NULL,
    @latitud DECIMAL(9,6) = NULL,
    @longitud DECIMAL(9,6) = NULL,
    @id_ciudad INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.sede WHERE id_sede = @id_sede) SET @v_errores += N'sede inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@nombre_estadio)), N'') IS NULL SET @v_errores += N'nombre_estadio obligatorio; ';
        IF @capacidad IS NULL OR @capacidad <= 0 SET @v_errores += N'capacidad obligatoria y debe ser mayor a 0; ';
        IF @latitud IS NOT NULL AND @latitud NOT BETWEEN -90 AND 90 SET @v_errores += N'latitud fuera de rango; ';
        IF @longitud IS NOT NULL AND @longitud NOT BETWEEN -180 AND 180 SET @v_errores += N'longitud fuera de rango; ';
        IF (@latitud IS NULL AND @longitud IS NOT NULL) OR (@latitud IS NOT NULL AND @longitud IS NULL) SET @v_errores += N'latitud y longitud deben informarse juntas; ';
        IF NOT EXISTS (SELECT 1 FROM geo.ciudad WHERE id_ciudad = @id_ciudad) SET @v_errores += N'ciudad inexistente; ';
        IF EXISTS (SELECT 1 FROM torneo.sede WHERE nombre_estadio = @nombre_estadio AND id_sede <> @id_sede) SET @v_errores += N'nombre_estadio ya registrado; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Sede_Modificar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_sede_modificar; SET @v_sp = 1; END

        UPDATE torneo.sede
        SET nombre_estadio = @nombre_estadio, capacidad = @capacidad, direccion = @direccion, latitud = @latitud, longitud = @longitud, id_ciudad = @id_ciudad
        WHERE id_sede = @id_sede;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_sede_modificar;
        THROW;
    END CATCH
END
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Sede_Eliminar
    @id_sede INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.sede WHERE id_sede = @id_sede) THROW 50001, N'torneo.usp_Sede_Eliminar: sede inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM torneo.partido WHERE id_sede = @id_sede;
        IF @v_n > 0 SET @v_errores += CONCAT(N'partido(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM publicidad.espacio_publicitario WHERE id_sede = @id_sede;
        IF @v_n > 0 SET @v_errores += CONCAT(N'espacio_publicitario(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM publicidad.exhibicion WHERE id_sede = @id_sede;
        IF @v_n > 0 SET @v_errores += CONCAT(N'exhibicion(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Sede_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores), 2048);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_sede_eliminar; SET @v_sp = 1; END

        DELETE FROM torneo.sede WHERE id_sede = @id_sede;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_sede_eliminar;
        THROW;
    END CATCH
END
GO



-- ----------------------------------------------------------------------------
-- 6. torneo.partido (Con manejo especial de eliminación según B.3)
-- ----------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Partido_Insertar
    @fecha_hora_utc DATETIME2(0),
    @asistencia_publico INT = NULL,
    @definido_por_penales BIT = 0,
    @estado VARCHAR(12) = 'PROGRAMADO',
    @id_sede INT,
    @nro_fase TINYINT,
    @id_partido INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF @fecha_hora_utc IS NULL SET @v_errores += N'fecha_hora_utc obligatoria; ';
        IF @estado IS NULL OR @estado NOT IN ('PROGRAMADO','EN_CURSO','FINALIZADO','SUSPENDIDO') SET @v_errores += N'estado invalido; ';
        IF @asistencia_publico IS NOT NULL AND @asistencia_publico < 0 SET @v_errores += N'asistencia_publico no puede ser negativa; ';
        IF @definido_por_penales IS NULL SET @v_errores += N'definido_por_penales obligatorio; ';
        IF NOT EXISTS (SELECT 1 FROM torneo.sede WHERE id_sede = @id_sede) SET @v_errores += N'sede inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM torneo.fase WHERE nro_fase = @nro_fase) SET @v_errores += N'fase inexistente; ';
        IF EXISTS (SELECT 1 FROM torneo.partido WHERE fecha_hora_utc = @fecha_hora_utc AND id_sede = @id_sede) SET @v_errores += N'ya existe un partido en la misma sede a esa hora; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Partido_Insertar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_partido_insertar; SET @v_sp = 1; END

        INSERT INTO torneo.partido (fecha_hora_utc, asistencia_publico, definido_por_penales, estado, id_sede, nro_fase)
        VALUES (@fecha_hora_utc, @asistencia_publico, @definido_por_penales, @estado, @id_sede, @nro_fase);
        SET @id_partido = CONVERT(INT, SCOPE_IDENTITY());

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_partido_insertar;
        THROW;
    END CATCH
END
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Partido_Modificar
    @id_partido INT,
    @fecha_hora_utc DATETIME2(0),
    @asistencia_publico INT = NULL,
    @definido_por_penales BIT,
    @estado VARCHAR(12),
    @id_sede INT,
    @nro_fase TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.partido WHERE id_partido = @id_partido) SET @v_errores += N'partido inexistente; ';
        IF @fecha_hora_utc IS NULL SET @v_errores += N'fecha_hora_utc obligatoria; ';
        IF @estado IS NULL OR @estado NOT IN ('PROGRAMADO','EN_CURSO','FINALIZADO','SUSPENDIDO') SET @v_errores += N'estado invalido; ';
        IF @asistencia_publico IS NOT NULL AND @asistencia_publico < 0 SET @v_errores += N'asistencia_publico no puede ser negativa; ';
        IF @definido_por_penales IS NULL SET @v_errores += N'definido_por_penales obligatorio; ';
        IF NOT EXISTS (SELECT 1 FROM torneo.sede WHERE id_sede = @id_sede) SET @v_errores += N'sede inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM torneo.fase WHERE nro_fase = @nro_fase) SET @v_errores += N'fase inexistente; ';
        IF EXISTS (SELECT 1 FROM torneo.partido WHERE fecha_hora_utc = @fecha_hora_utc AND id_sede = @id_sede AND id_partido <> @id_partido) SET @v_errores += N'ya existe un partido en la misma sede a esa hora; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Partido_Modificar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_partido_modificar; SET @v_sp = 1; END

        UPDATE torneo.partido
        SET fecha_hora_utc = @fecha_hora_utc, asistencia_publico = @asistencia_publico, definido_por_penales = @definido_por_penales, estado = @estado, id_sede = @id_sede, nro_fase = @nro_fase
        WHERE id_partido = @id_partido;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_partido_modificar;
        THROW;
    END CATCH
END
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Partido_Eliminar
    @id_partido INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.partido WHERE id_partido = @id_partido) THROW 50001, N'torneo.usp_Partido_Eliminar: partido inexistente', 1;

        -- Según B.3: Si el partido tiene eventos, alineaciones, exhibiciones o designaciones, no se borra: se informa
        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM torneo.equipo_en_partido WHERE id_partido = @id_partido;
        IF @v_n > 0 SET @v_errores += CONCAT(N'equipo_en_partido(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM juego.alineacion WHERE id_partido = @id_partido;
        IF @v_n > 0 SET @v_errores += CONCAT(N'alineacion(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM juego.sustitucion WHERE id_partido = @id_partido;
        IF @v_n > 0 SET @v_errores += CONCAT(N'sustitucion(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM juego.gol WHERE id_partido = @id_partido;
        IF @v_n > 0 SET @v_errores += CONCAT(N'gol(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM juego.tarjeta WHERE id_partido = @id_partido;
        IF @v_n > 0 SET @v_errores += CONCAT(N'tarjeta(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM juego.suspension_partido WHERE id_partido = @id_partido;
        IF @v_n > 0 SET @v_errores += CONCAT(N'suspension_partido(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM arbitraje.designacion_arbitral WHERE id_partido = @id_partido;
        IF @v_n > 0 SET @v_errores += CONCAT(N'designacion_arbitral(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM publicidad.exhibicion WHERE id_partido = @id_partido;
        IF @v_n > 0 SET @v_errores += CONCAT(N'exhibicion(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Partido_Eliminar: No se puede eliminar porque tiene dependientes o actividad registrada. Para anularlo, modifique su estado a SUSPENDIDO: ', @v_errores), 2048);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_partido_eliminar; SET @v_sp = 1; END

        DELETE FROM torneo.partido WHERE id_partido = @id_partido;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_partido_eliminar;
        THROW;
    END CATCH
END
GO



-- ----------------------------------------------------------------------------
-- 7. torneo.equipo_en_partido (PK Compuesta: id_partido, id_seleccion)
-- ----------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_EquipoEnPartido_Insertar
    @id_partido INT,
    @id_seleccion INT,
    @condicion CHAR(1),
    @esquema_tactico VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.partido WHERE id_partido = @id_partido) SET @v_errores += N'partido inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_seleccion = @id_seleccion) SET @v_errores += N'seleccion inexistente; ';
        IF @condicion IS NULL OR @condicion NOT IN ('L','V') SET @v_errores += N'condicion debe ser L o V; ';
        IF @esquema_tactico IS NOT NULL
           AND @esquema_tactico NOT LIKE '[1-9]-[0-9]-[0-9]'
           AND @esquema_tactico NOT LIKE '[1-9]-[0-9]-[0-9]-[0-9]'
           AND @esquema_tactico NOT LIKE '[1-9]-[0-9]-[0-9]-[0-9]-[0-9]'
            SET @v_errores += N'esquema_tactico con formato invalido; ';
        IF EXISTS (SELECT 1 FROM torneo.equipo_en_partido WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion) SET @v_errores += N'equipo_en_partido ya registrado; ';
        IF EXISTS (SELECT 1 FROM torneo.equipo_en_partido WHERE id_partido = @id_partido AND condicion = @condicion) SET @v_errores += N'ya existe un equipo con esa condicion (L/V) en el partido; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_EquipoEnPartido_Insertar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_eq_partido_insertar; SET @v_sp = 1; END

        INSERT INTO torneo.equipo_en_partido (id_partido, id_seleccion, condicion, esquema_tactico)
        VALUES (@id_partido, @id_seleccion, @condicion, @esquema_tactico);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_eq_partido_insertar;
        THROW;
    END CATCH
END
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_EquipoEnPartido_Modificar
    @id_partido INT,
    @id_seleccion INT,
    @condicion CHAR(1),
    @esquema_tactico VARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.equipo_en_partido WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion) SET @v_errores += N'equipo_en_partido inexistente; ';
        IF @condicion IS NULL OR @condicion NOT IN ('L','V') SET @v_errores += N'condicion debe ser L o V; ';
        IF @esquema_tactico IS NOT NULL
           AND @esquema_tactico NOT LIKE '[1-9]-[0-9]-[0-9]'
           AND @esquema_tactico NOT LIKE '[1-9]-[0-9]-[0-9]-[0-9]'
           AND @esquema_tactico NOT LIKE '[1-9]-[0-9]-[0-9]-[0-9]-[0-9]'
            SET @v_errores += N'esquema_tactico con formato invalido; ';
        IF EXISTS (SELECT 1 FROM torneo.equipo_en_partido WHERE id_partido = @id_partido AND condicion = @condicion AND id_seleccion <> @id_seleccion) SET @v_errores += N'ya existe otro equipo con esa condicion en el partido; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_EquipoEnPartido_Modificar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_eq_partido_modificar; SET @v_sp = 1; END

        UPDATE torneo.equipo_en_partido
        SET condicion = @condicion, esquema_tactico = @esquema_tactico
        WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_eq_partido_modificar;
        THROW;
    END CATCH
END
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_EquipoEnPartido_Eliminar
    @id_partido INT,
    @id_seleccion INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.equipo_en_partido WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion) THROW 50001, N'torneo.usp_EquipoEnPartido_Eliminar: equipo_en_partido inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM juego.alineacion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion;
        IF @v_n > 0 SET @v_errores += CONCAT(N'alineacion(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM juego.sustitucion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion;
        IF @v_n > 0 SET @v_errores += CONCAT(N'sustitucion(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM juego.gol WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion;
        IF @v_n > 0 SET @v_errores += CONCAT(N'gol(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM juego.tarjeta WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion;
        IF @v_n > 0 SET @v_errores += CONCAT(N'tarjeta(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_EquipoEnPartido_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores), 2048);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_eq_partido_eliminar; SET @v_sp = 1; END

        DELETE FROM torneo.equipo_en_partido WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_eq_partido_eliminar;
        THROW;
    END CATCH
END
GO


-- ----------------------------------------------------------------------------
-- 8. torneo.convocatoria (PK actual: id_seleccion, id_jugador; baja logica segun B.3)
-- ----------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Convocatoria_Insertar
    @id_seleccion INT,
    @id_jugador INT,
    @dorsal TINYINT,
    @estado VARCHAR(10) = 'ACTIVO'
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_seleccion = @id_seleccion) SET @v_errores += N'seleccion inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM persona.jugador WHERE id_persona = @id_jugador) SET @v_errores += N'jugador inexistente; ';
        IF @dorsal IS NULL OR @dorsal NOT BETWEEN 1 AND 99 SET @v_errores += N'dorsal debe estar entre 1 y 99; ';
        IF @estado IS NULL OR @estado NOT IN ('ACTIVO','BAJA') SET @v_errores += N'estado invalido; ';
        IF EXISTS (SELECT 1 FROM torneo.convocatoria WHERE id_seleccion = @id_seleccion AND id_jugador = @id_jugador) SET @v_errores += N'jugador ya convocado en la seleccion; ';
        IF EXISTS (SELECT 1 FROM torneo.convocatoria WHERE id_seleccion = @id_seleccion AND dorsal = @dorsal) SET @v_errores += N'dorsal ya ocupado en la seleccion; ';
        IF EXISTS (SELECT 1 FROM torneo.convocatoria WHERE id_jugador = @id_jugador) SET @v_errores += N'jugador ya figura convocado en otra seleccion ; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Convocatoria_Insertar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_convocatoria_insertar; SET @v_sp = 1; END

        INSERT INTO torneo.convocatoria (id_seleccion, id_jugador, dorsal, estado)
        VALUES (@id_seleccion, @id_jugador, @dorsal, @estado);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_convocatoria_insertar;
        THROW;
    END CATCH
END
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Convocatoria_Modificar
    @id_seleccion INT,
    @id_jugador INT,
    @dorsal TINYINT,
    @estado VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.convocatoria WHERE id_seleccion = @id_seleccion AND id_jugador = @id_jugador) SET @v_errores += N'convocatoria inexistente; ';
        IF @dorsal IS NULL OR @dorsal NOT BETWEEN 1 AND 99 SET @v_errores += N'dorsal debe estar entre 1 y 99; ';
        IF @estado IS NULL OR @estado NOT IN ('ACTIVO','BAJA') SET @v_errores += N'estado invalido; ';
        IF EXISTS (SELECT 1 FROM torneo.convocatoria WHERE id_seleccion = @id_seleccion AND dorsal = @dorsal AND id_jugador <> @id_jugador) SET @v_errores += N'dorsal ya ocupado por otro jugador en la seleccion; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Convocatoria_Modificar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_convocatoria_modificar; SET @v_sp = 1; END

        UPDATE torneo.convocatoria
        SET dorsal = @dorsal, estado = @estado
        WHERE id_seleccion = @id_seleccion AND id_jugador = @id_jugador;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_convocatoria_modificar;
        THROW;
    END CATCH
END
GO



---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_Convocatoria_Eliminar
    @id_seleccion INT,
    @id_jugador INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.convocatoria WHERE id_seleccion = @id_seleccion AND id_jugador = @id_jugador) THROW 50001, N'torneo.usp_Convocatoria_Eliminar: convocatoria inexistente', 1;

        -- Según B.3: Si el jugador figura en una alineación, se marca estado BAJA en lugar de borrar (baja lógica)
        IF EXISTS (SELECT 1 FROM juego.alineacion WHERE id_seleccion = @id_seleccion AND id_jugador = @id_jugador)
        BEGIN
            IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
            ELSE BEGIN SAVE TRANSACTION sv_convocatoria_eliminar; SET @v_sp = 1; END

            UPDATE torneo.convocatoria SET estado = 'BAJA' WHERE id_seleccion = @id_seleccion AND id_jugador = @id_jugador;

            IF @v_propia = 1 COMMIT TRANSACTION;
            RETURN;
        END

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM torneo.cambio_convocatoria WHERE id_seleccion = @id_seleccion AND id_jugador = @id_jugador;
        IF @v_n > 0 SET @v_errores += CONCAT(N'cambio_convocatoria(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_Convocatoria_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores), 2048);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_convocatoria_eliminar; SET @v_sp = 1; END

        DELETE FROM torneo.convocatoria WHERE id_seleccion = @id_seleccion AND id_jugador = @id_jugador;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_convocatoria_eliminar;
        THROW;
    END CATCH
END
GO



-- ----------------------------------------------------------------------------
-- 9. torneo.cambio_convocatoria
-- ----------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_CambioConvocatoria_Insertar
    @id_seleccion INT,
    @id_jugador INT,
    @tipo VARCHAR(4),
    @motivo NVARCHAR(200) = NULL,
    @fecha DATE,
    @id_cambio INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_seleccion = @id_seleccion) SET @v_errores += N'seleccion inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM persona.jugador WHERE id_persona = @id_jugador) SET @v_errores += N'jugador inexistente; ';
        IF @tipo IS NULL OR @tipo NOT IN ('ALTA','BAJA') SET @v_errores += N'tipo debe ser ALTA o BAJA; ';
        IF @fecha IS NULL SET @v_errores += N'fecha obligatoria; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_CambioConvocatoria_Insertar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_cambio_conv_insertar; SET @v_sp = 1; END

        INSERT INTO torneo.cambio_convocatoria (id_seleccion, id_jugador, tipo, motivo, fecha)
        VALUES (@id_seleccion, @id_jugador, @tipo, @motivo, @fecha);
        SET @id_cambio = CONVERT(INT, SCOPE_IDENTITY());

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_cambio_conv_insertar;
        THROW;
    END CATCH
END
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_CambioConvocatoria_Modificar
    @id_cambio INT,
    @id_seleccion INT,
    @id_jugador INT,
    @tipo VARCHAR(4),
    @motivo NVARCHAR(200) = NULL,
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.cambio_convocatoria WHERE id_cambio = @id_cambio) SET @v_errores += N'cambio_convocatoria inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_seleccion = @id_seleccion) SET @v_errores += N'seleccion inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM persona.jugador WHERE id_persona = @id_jugador) SET @v_errores += N'jugador inexistente; ';
        IF @tipo IS NULL OR @tipo NOT IN ('ALTA','BAJA') SET @v_errores += N'tipo debe ser ALTA o BAJA; ';
        IF @fecha IS NULL SET @v_errores += N'fecha obligatoria; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = LEFT(CONCAT(N'torneo.usp_CambioConvocatoria_Modificar: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_cambio_conv_modificar; SET @v_sp = 1; END

        UPDATE torneo.cambio_convocatoria
        SET id_seleccion = @id_seleccion, id_jugador = @id_jugador, tipo = @tipo, motivo = @motivo, fecha = @fecha
        WHERE id_cambio = @id_cambio;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_cambio_conv_modificar;
        THROW;
    END CATCH
END
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE torneo.usp_CambioConvocatoria_Eliminar
    @id_cambio INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.cambio_convocatoria WHERE id_cambio = @id_cambio) THROW 50001, N'torneo.usp_CambioConvocatoria_Eliminar: cambio_convocatoria inexistente', 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_cambio_conv_eliminar; SET @v_sp = 1; END

        DELETE FROM torneo.cambio_convocatoria WHERE id_cambio = @id_cambio;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_cambio_conv_eliminar;
        THROW;
    END CATCH
END
GO