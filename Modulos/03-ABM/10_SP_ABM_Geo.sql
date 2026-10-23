/* ===================================================================== 
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Crea los SP de ABM del esquema geo.
===================================================================== */
USE Mundial2026;
GO

-- ============================================================================
-- Esquema: geo
-- Tablas: confederacion, huso_horario, pais, ciudad, indicador_pais
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. geo.confederacion
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE geo.usp_Confederacion_Insertar
    @nombre VARCHAR(50),
    @sigla VARCHAR(10),
    @id_confederacion TINYINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NULLIF(LTRIM(RTRIM(@nombre)), '') IS NULL SET @v_errores += 'nombre obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@sigla)), '') IS NULL SET @v_errores += 'sigla obligatoria; ';
        IF EXISTS (SELECT 1 FROM geo.confederacion WHERE nombre = @nombre) SET @v_errores += 'nombre ya registrado; ';
        IF EXISTS (SELECT 1 FROM geo.confederacion WHERE sigla = @sigla) SET @v_errores += 'sigla ya registrada; ';
        IF @v_errores <> '' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_confederacion_insertar;

        INSERT INTO geo.confederacion (nombre, sigla) VALUES (@nombre, @sigla);
        SET @id_confederacion = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_confederacion_insertar;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE geo.usp_Confederacion_Modificar
    @id_confederacion TINYINT,
    @nombre VARCHAR(50),
    @sigla VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM geo.confederacion WHERE id_confederacion = @id_confederacion) SET @v_errores += 'confederacion inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), '') IS NULL SET @v_errores += 'nombre obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@sigla)), '') IS NULL SET @v_errores += 'sigla obligatoria; ';
        IF EXISTS (SELECT 1 FROM geo.confederacion WHERE nombre = @nombre AND id_confederacion <> @id_confederacion) SET @v_errores += 'nombre ya registrado; ';
        IF EXISTS (SELECT 1 FROM geo.confederacion WHERE sigla = @sigla AND id_confederacion <> @id_confederacion) SET @v_errores += 'sigla ya registrada; ';
        IF @v_errores <> '' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_confederacion_modificar;

        UPDATE geo.confederacion SET nombre = @nombre, sigla = @sigla WHERE id_confederacion = @id_confederacion;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_confederacion_modificar;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE geo.usp_Confederacion_Eliminar
    @id_confederacion TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM geo.confederacion WHERE id_confederacion = @id_confederacion) THROW 50001, 'confederacion inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM geo.pais WHERE id_confederacion = @id_confederacion;
        IF @v_n > 0 SET @v_errores += CONCAT('pais(', @v_n, '); ');

        IF @v_errores <> ''
        BEGIN
            SET @v_errores = CONCAT('No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_confederacion_eliminar;

        DELETE FROM geo.confederacion WHERE id_confederacion = @id_confederacion;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_confederacion_eliminar;
        THROW;
    END CATCH
END
GO

-- ----------------------------------------------------------------------------
-- 2. geo.huso_horario
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE geo.usp_HusoHorario_Insertar
    @zona_horaria VARCHAR(60),
    @offset_utc SMALLINT,
    @horario_verano BIT = 0,
    @id_huso SMALLINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NULLIF(LTRIM(RTRIM(@zona_horaria)), '') IS NULL SET @v_errores += 'zona_horaria obligatoria; ';
        IF @offset_utc NOT BETWEEN -720 AND 840 SET @v_errores += 'offset_utc fuera de rango (-720 a 840); ';
        IF EXISTS (SELECT 1 FROM geo.huso_horario WHERE zona_horaria = @zona_horaria) SET @v_errores += 'zona_horaria ya registrada; ';
        IF @v_errores <> '' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_huso_horario_insertar;

        INSERT INTO geo.huso_horario (zona_horaria, offset_utc, horario_verano) VALUES (@zona_horaria, @offset_utc, @horario_verano);
        SET @id_huso = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_huso_horario_insertar;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE geo.usp_HusoHorario_Modificar
    @id_huso SMALLINT,
    @zona_horaria VARCHAR(60),
    @offset_utc SMALLINT,
    @horario_verano BIT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM geo.huso_horario WHERE id_huso = @id_huso) SET @v_errores += 'huso_horario inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@zona_horaria)), '') IS NULL SET @v_errores += 'zona_horaria obligatoria; ';
        IF @offset_utc NOT BETWEEN -720 AND 840 SET @v_errores += 'offset_utc fuera de rango; ';
        IF EXISTS (SELECT 1 FROM geo.huso_horario WHERE zona_horaria = @zona_horaria AND id_huso <> @id_huso) SET @v_errores += 'zona_horaria ya registrada; ';
        IF @v_errores <> '' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_huso_horario_modificar;

        UPDATE geo.huso_horario SET zona_horaria = @zona_horaria, offset_utc = @offset_utc, horario_verano = @horario_verano WHERE id_huso = @id_huso;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_huso_horario_modificar;
        THROW;
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE geo.usp_HusoHorario_Eliminar
    @id_huso SMALLINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM geo.huso_horario WHERE id_huso = @id_huso) THROW 50001, 'huso_horario inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM geo.ciudad WHERE id_huso = @id_huso;
        IF @v_n > 0 SET @v_errores += CONCAT('ciudad(', @v_n, '); ');

        IF @v_errores <> ''
        BEGIN
            SET @v_errores = CONCAT('No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_huso_horario_eliminar;

        DELETE FROM geo.huso_horario WHERE id_huso = @id_huso;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_huso_horario_eliminar;
        THROW;
    END CATCH
END
GO

-- ----------------------------------------------------------------------------
-- 3. geo.pais (Basado exactamente en la plantilla del Plan B.2)
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE geo.usp_Pais_Insertar
    @nombre VARCHAR(80),
    @cod_iso3 CHAR(3),
    @cod_fifa CHAR(3) = NULL,
    @gentilicio VARCHAR(60) = NULL,
    @id_confederacion TINYINT,
    @id_pais SMALLINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NULLIF(LTRIM(RTRIM(@nombre)), '') IS NULL SET @v_errores += 'nombre obligatorio; ';
        IF @cod_iso3 IS NULL OR LEN(@cod_iso3) <> 3 SET @v_errores += 'cod_iso3 debe tener 3 letras; ';
        IF NOT EXISTS (SELECT 1 FROM geo.confederacion WHERE id_confederacion = @id_confederacion) SET @v_errores += 'confederacion inexistente; ';
        IF EXISTS (SELECT 1 FROM geo.pais WHERE cod_iso3 = @cod_iso3) SET @v_errores += 'cod_iso3 ya registrado; ';
        IF EXISTS (SELECT 1 FROM geo.pais WHERE nombre = @nombre) SET @v_errores += 'nombre ya registrado; ';
        IF @v_errores <> '' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_pais_insertar;

        INSERT INTO geo.pais (nombre, cod_iso3, cod_fifa, gentilicio, id_confederacion)
        VALUES (@nombre, @cod_iso3, @cod_fifa, @gentilicio, @id_confederacion);
        SET @id_pais = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_pais_insertar;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE geo.usp_Pais_Modificar
    @id_pais SMALLINT,
    @nombre VARCHAR(80),
    @cod_iso3 CHAR(3),
    @cod_fifa CHAR(3) = NULL,
    @gentilicio VARCHAR(60) = NULL,
    @id_confederacion TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais) SET @v_errores += 'pais inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), '') IS NULL SET @v_errores += 'nombre obligatorio; ';
        IF @cod_iso3 IS NULL OR LEN(@cod_iso3) <> 3 SET @v_errores += 'cod_iso3 debe tener 3 letras; ';
        IF NOT EXISTS (SELECT 1 FROM geo.confederacion WHERE id_confederacion = @id_confederacion) SET @v_errores += 'confederacion inexistente; ';
        IF EXISTS (SELECT 1 FROM geo.pais WHERE cod_iso3 = @cod_iso3 AND id_pais <> @id_pais) SET @v_errores += 'cod_iso3 ya registrado; ';
        IF EXISTS (SELECT 1 FROM geo.pais WHERE nombre = @nombre AND id_pais <> @id_pais) SET @v_errores += 'nombre ya registrado; ';
        IF @v_errores <> '' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_pais_modificar;

        UPDATE geo.pais
        SET nombre = @nombre, cod_iso3 = @cod_iso3, cod_fifa = @cod_fifa, gentilicio = @gentilicio, id_confederacion = @id_confederacion
        WHERE id_pais = @id_pais;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_pais_modificar;
        THROW;
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE geo.usp_Pais_Eliminar
    @id_pais SMALLINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais) THROW 50001, 'pais inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM geo.ciudad WHERE id_pais = @id_pais;
        IF @v_n > 0 SET @v_errores += CONCAT('ciudad(', @v_n, '); ');
        SELECT @v_n = COUNT(*) FROM persona.persona WHERE id_pais = @id_pais;
        IF @v_n > 0 SET @v_errores += CONCAT('persona(', @v_n, '); ');
        SELECT @v_n = COUNT(*) FROM torneo.seleccion WHERE id_pais = @id_pais;
        IF @v_n > 0 SET @v_errores += CONCAT('seleccion(', @v_n, '); ');
        SELECT @v_n = COUNT(*) FROM publicidad.anunciante WHERE id_pais = @id_pais;
        IF @v_n > 0 SET @v_errores += CONCAT('anunciante(', @v_n, '); ');
        SELECT @v_n = COUNT(*) FROM publicidad.feriado WHERE id_pais = @id_pais;
        IF @v_n > 0 SET @v_errores += CONCAT('feriado(', @v_n, '); ');

        IF @v_errores <> ''
        BEGIN
            SET @v_errores = CONCAT('No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_pais_eliminar;

        DELETE FROM geo.pais WHERE id_pais = @id_pais;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_pais_eliminar;
        THROW;
    END CATCH
END
GO

-- ----------------------------------------------------------------------------
-- 4. geo.ciudad
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE geo.usp_Ciudad_Insertar
    @nombre VARCHAR(100),
    @poblacion INT,
    @id_pais SMALLINT,
    @id_huso SMALLINT,
    @id_ciudad INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NULLIF(LTRIM(RTRIM(@nombre)), '') IS NULL SET @v_errores += 'nombre obligatorio; ';
        IF @poblacion < 0 SET @v_errores += 'poblacion no puede ser negativa; ';
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais) SET @v_errores += 'pais inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM geo.huso_horario WHERE id_huso = @id_huso) SET @v_errores += 'huso_horario inexistente; ';
        IF EXISTS (SELECT 1 FROM geo.ciudad WHERE id_pais = @id_pais AND nombre = @nombre) SET @v_errores += 'nombre de ciudad ya registrado en el pais; ';
        IF @v_errores <> '' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_ciudad_insertar;

        INSERT INTO geo.ciudad (nombre, poblacion, id_pais, id_huso) VALUES (@nombre, @poblacion, @id_pais, @id_huso);
        SET @id_ciudad = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_ciudad_insertar;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE geo.usp_Ciudad_Modificar
    @id_ciudad INT,
    @nombre VARCHAR(100),
    @poblacion INT,
    @id_pais SMALLINT,
    @id_huso SMALLINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM geo.ciudad WHERE id_ciudad = @id_ciudad) SET @v_errores += 'ciudad inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), '') IS NULL SET @v_errores += 'nombre obligatorio; ';
        IF @poblacion < 0 SET @v_errores += 'poblacion no puede ser negativa; ';
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais) SET @v_errores += 'pais inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM geo.huso_horario WHERE id_huso = @id_huso) SET @v_errores += 'huso_horario inexistente; ';
        IF EXISTS (SELECT 1 FROM geo.ciudad WHERE id_pais = @id_pais AND nombre = @nombre AND id_ciudad <> @id_ciudad) SET @v_errores += 'nombre de ciudad ya registrado en el pais; ';
        IF @v_errores <> '' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_ciudad_modificar;

        UPDATE geo.ciudad SET nombre = @nombre, poblacion = @poblacion, id_pais = @id_pais, id_huso = @id_huso WHERE id_ciudad = @id_ciudad;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_ciudad_modificar;
        THROW;
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE geo.usp_Ciudad_Eliminar
    @id_ciudad INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM geo.ciudad WHERE id_ciudad = @id_ciudad) THROW 50001, 'ciudad inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM torneo.sede WHERE id_ciudad = @id_ciudad;
        IF @v_n > 0 SET @v_errores += CONCAT('sede(', @v_n, '); ');

        IF @v_errores <> ''
        BEGIN
            SET @v_errores = CONCAT('No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_ciudad_eliminar;

        DELETE FROM geo.ciudad WHERE id_ciudad = @id_ciudad;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_ciudad_eliminar;
        THROW;
    END CATCH
END
GO

-- ----------------------------------------------------------------------------
-- 5. geo.indicador_pais (PK Compuesta: id_pais, anio, codigo_indicador)
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE geo.usp_IndicadorPais_Insertar
    @id_pais SMALLINT,
    @anio SMALLINT,
    @codigo_indicador VARCHAR(30),
    @valor DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) ='';
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais) SET @v_errores += 'pais inexistente; ';
        IF @anio NOT BETWEEN 1960 AND 2100 SET @v_errores += 'anio fuera de rango (1960-2100); ';
        IF NULLIF(LTRIM(RTRIM(@codigo_indicador)), '') IS NULL SET @v_errores += 'codigo_indicador obligatorio; ';
        IF EXISTS (SELECT 1 FROM geo.indicador_pais WHERE id_pais = @id_pais AND anio = @anio AND codigo_indicador = @codigo_indicador) SET @v_errores += 'indicador_pais ya registrado para esa clave; ';
        IF @v_errores <> '' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_indicador_pais_insertar;

        INSERT INTO geo.indicador_pais (id_pais, anio, codigo_indicador, valor) VALUES (@id_pais, @anio, @codigo_indicador, @valor);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_indicador_pais_insertar;
        THROW;
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE geo.usp_IndicadorPais_Modificar
    @id_pais SMALLINT,
    @anio SMALLINT,
    @codigo_indicador VARCHAR(30),
    @valor DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM geo.indicador_pais WHERE id_pais = @id_pais AND anio = @anio AND codigo_indicador = @codigo_indicador) SET @v_errores += 'indicador_pais inexistente; ';
        IF @valor IS NULL SET @v_errores += 'valor obligatorio; ';
        IF @v_errores <> '' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_indicador_pais_modificar;

        UPDATE geo.indicador_pais SET valor = @valor WHERE id_pais = @id_pais AND anio = @anio AND codigo_indicador = @codigo_indicador;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_indicador_pais_modificar;
        THROW;
    END CATCH
END
GO



CREATE OR ALTER PROCEDURE geo.usp_IndicadorPais_Eliminar
    @id_pais SMALLINT,
    @anio SMALLINT,
    @codigo_indicador VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_propia BIT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM geo.indicador_pais WHERE id_pais = @id_pais AND anio = @anio AND codigo_indicador = @codigo_indicador) THROW 50001, 'indicador_pais inexistente', 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_indicador_pais_eliminar;

        DELETE FROM geo.indicador_pais WHERE id_pais = @id_pais AND anio = @anio AND codigo_indicador = @codigo_indicador;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_indicador_pais_eliminar;
        THROW;
    END CATCH
END
GO