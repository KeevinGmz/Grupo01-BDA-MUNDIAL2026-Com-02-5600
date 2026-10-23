/* ===================================================================== 
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: <una línea sobre lo que hace este script>
===================================================================== */
USE Mundial2026;
GO

--------------------------------------------------------------------------------
-- ESQUEMA: publicidad
--------------------------------------------------------------------------------

-- 1. publicidad.anunciante
CREATE OR ALTER PROCEDURE publicidad.usp_Anunciante_Insertar
    @razon_social NVARCHAR(150),
    @identificacion_fiscal NVARCHAR(30),
    @contacto NVARCHAR(150),
    @id_pais SMALLINT,
    @id_anunciante INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NULLIF(LTRIM(RTRIM(@razon_social)), N'') IS NULL
            SET @v_errores += N'razon_social obligatoria; ';
        IF NULLIF(LTRIM(RTRIM(@identificacion_fiscal)), N'') IS NULL
            SET @v_errores += N'identificacion_fiscal obligatoria; ';
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais)
            SET @v_errores += N'pais inexistente; ';
        IF EXISTS (SELECT 1 FROM publicidad.anunciante WHERE identificacion_fiscal = @identificacion_fiscal)
            SET @v_errores += N'identificacion_fiscal ya registrada; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_anunciante_insertar;

        INSERT INTO publicidad.anunciante (razon_social, identificacion_fiscal, contacto, id_pais)
        VALUES (@razon_social, @identificacion_fiscal, @contacto, @id_pais);
        SET @id_anunciante = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_anunciante_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_Anunciante_Modificar
    @id_anunciante INT,
    @razon_social NVARCHAR(150),
    @identificacion_fiscal NVARCHAR(30),
    @contacto NVARCHAR(150),
    @id_pais SMALLINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.anunciante WHERE id_anunciante = @id_anunciante)
            SET @v_errores += N'anunciante inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@razon_social)), N'') IS NULL
            SET @v_errores += N'razon_social obligatoria; ';
        IF NULLIF(LTRIM(RTRIM(@identificacion_fiscal)), N'') IS NULL
            SET @v_errores += N'identificacion_fiscal obligatoria; ';
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais)
            SET @v_errores += N'pais inexistente; ';
        IF EXISTS (SELECT 1 FROM publicidad.anunciante WHERE identificacion_fiscal = @identificacion_fiscal AND id_anunciante <> @id_anunciante)
            SET @v_errores += N'identificacion_fiscal ya registrada; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_anunciante_modificar;

        UPDATE publicidad.anunciante
        SET razon_social = @razon_social,
            identificacion_fiscal = @identificacion_fiscal,
            contacto = @contacto,
            id_pais = @id_pais
        WHERE id_anunciante = @id_anunciante;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_Anunciante_Eliminar
    @id_anunciante INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.anunciante WHERE id_anunciante = @id_anunciante)
            THROW 50001, N'anunciante inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM publicidad.anunciante_pais WHERE id_anunciante = @id_anunciante;
        IF @v_n > 0 SET @v_errores += CONCAT(N'anunciante_pais(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM publicidad.campania WHERE id_anunciante = @id_anunciante;
        IF @v_n > 0 SET @v_errores += CONCAT(N'campania(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_anunciante_eliminar;

        DELETE FROM publicidad.anunciante WHERE id_anunciante = @id_anunciante;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 2. publicidad.anunciante_pais
CREATE OR ALTER PROCEDURE publicidad.usp_AnunciantePais_Insertar
    @id_anunciante INT,
    @id_pais SMALLINT,
    @prioridad TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.anunciante WHERE id_anunciante = @id_anunciante)
            SET @v_errores += N'anunciante inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais)
            SET @v_errores += N'pais inexistente; ';
        IF @prioridad < 1 OR @prioridad > 3
            SET @v_errores += N'prioridad debe estar entre 1 y 3; ';
        IF EXISTS (SELECT 1 FROM publicidad.anunciante_pais WHERE id_anunciante = @id_anunciante AND id_pais = @id_pais)
            SET @v_errores += N'anunciante_pais ya registrado; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_anunciante_pais_insertar;

        INSERT INTO publicidad.anunciante_pais (id_anunciante, id_pais, prioridad)
        VALUES (@id_anunciante, @id_pais, @prioridad);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_anunciante_pais_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_AnunciantePais_Modificar
    @id_anunciante INT,
    @id_pais SMALLINT,
    @prioridad TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.anunciante_pais WHERE id_anunciante = @id_anunciante AND id_pais = @id_pais)
            SET @v_errores += N'anunciante_pais inexistente; ';
        IF @prioridad < 1 OR @prioridad > 3
            SET @v_errores += N'prioridad debe estar entre 1 y 3; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_anunciante_pais_modificar;

        UPDATE publicidad.anunciante_pais SET prioridad = @prioridad WHERE id_anunciante = @id_anunciante AND id_pais = @id_pais;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_AnunciantePais_Eliminar
    @id_anunciante INT,
    @id_pais SMALLINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.anunciante_pais WHERE id_anunciante = @id_anunciante AND id_pais = @id_pais)
            THROW 50001, N'anunciante_pais inexistente', 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_anunciante_pais_eliminar;

        DELETE FROM publicidad.anunciante_pais WHERE id_anunciante = @id_anunciante AND id_pais = @id_pais;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 3. publicidad.campania
CREATE OR ALTER PROCEDURE publicidad.usp_Campania_Insertar
    @nombre NVARCHAR(100),
    @id_anunciante INT,
    @fecha_desde DATE,
    @fecha_hasta DATE,
    @presupuesto DECIMAL(18,2),
    @id_campania INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL
            SET @v_errores += N'nombre obligatorio; ';
        IF NOT EXISTS (SELECT 1 FROM publicidad.anunciante WHERE id_anunciante = @id_anunciante)
            SET @v_errores += N'anunciante inexistente; ';
        IF @fecha_hasta < @fecha_desde
            SET @v_errores += N'fecha_hasta debe ser mayor o igual a fecha_desde; ';
        IF @presupuesto IS NOT NULL AND @presupuesto < 0
            SET @v_errores += N'presupuesto no puede ser negativo; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_campania_insertar;

        INSERT INTO publicidad.campania (nombre, id_anunciante, fecha_desde, fecha_hasta, presupuesto)
        VALUES (@nombre, @id_anunciante, @fecha_desde, @fecha_hasta, @presupuesto);
        SET @id_campania = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_campania_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_Campania_Modificar
    @id_campania INT,
    @nombre NVARCHAR(100),
    @id_anunciante INT,
    @fecha_desde DATE,
    @fecha_hasta DATE,
    @presupuesto DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.campania WHERE id_campania = @id_campania)
            SET @v_errores += N'campania inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL
            SET @v_errores += N'nombre obligatorio; ';
        IF NOT EXISTS (SELECT 1 FROM publicidad.anunciante WHERE id_anunciante = @id_anunciante)
            SET @v_errores += N'anunciante inexistente; ';
        IF @fecha_hasta < @fecha_desde
            SET @v_errores += N'fecha_hasta debe ser mayor o igual a fecha_desde; ';
        IF @presupuesto IS NOT NULL AND @presupuesto < 0
            SET @v_errores += N'presupuesto no puede ser negativo; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_campania_modificar;

        UPDATE publicidad.campania
        SET nombre = @nombre,
            id_anunciante = @id_anunciante,
            fecha_desde = @fecha_desde,
            fecha_hasta = @fecha_hasta,
            presupuesto = @presupuesto
        WHERE id_campania = @id_campania;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_Campania_Eliminar
    @id_campania INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.campania WHERE id_campania = @id_campania)
            THROW 50001, N'campania inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM publicidad.pieza_publicitaria WHERE id_campania = @id_campania;
        IF @v_n > 0 SET @v_errores += CONCAT(N'pieza_publicitaria(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_campania_eliminar;

        DELETE FROM publicidad.campania WHERE id_campania = @id_campania;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 4. publicidad.pieza_publicitaria
CREATE OR ALTER PROCEDURE publicidad.usp_PiezaPublicitaria_Insertar
    @descripcion NVARCHAR(200),
    @duracion_seg SMALLINT,
    @formato VARCHAR(20),
    @id_campania INT,
    @id_idioma SMALLINT,
    @id_pais_mercado SMALLINT,
    @id_pieza INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NULLIF(LTRIM(RTRIM(@descripcion)), N'') IS NULL
            SET @v_errores += N'descripcion obligatoria; ';
        IF @duracion_seg <= 0
            SET @v_errores += N'duracion_seg debe ser mayor a 0; ';
        IF NULLIF(LTRIM(RTRIM(@formato)), N'') IS NULL
            SET @v_errores += N'formato obligatorio; ';
        IF NOT EXISTS (SELECT 1 FROM publicidad.campania WHERE id_campania = @id_campania)
            SET @v_errores += N'campania inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM geo.idioma WHERE id_idioma = @id_idioma)
            SET @v_errores += N'idioma inexistente; ';
        IF @id_pais_mercado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais_mercado)
            SET @v_errores += N'id_pais_mercado inexistente; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_pieza_publicitaria_insertar;

        INSERT INTO publicidad.pieza_publicitaria (descripcion, duracion_seg, formato, id_campania, id_idioma, id_pais_mercado)
        VALUES (@descripcion, @duracion_seg, @formato, @id_campania, @id_idioma, @id_pais_mercado);
        SET @id_pieza = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_pieza_publicitaria_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_PiezaPublicitaria_Modificar
    @id_pieza INT,
    @descripcion NVARCHAR(200),
    @duracion_seg SMALLINT,
    @formato VARCHAR(20),
    @id_campania INT,
    @id_idioma SMALLINT,
    @id_pais_mercado SMALLINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.pieza_publicitaria WHERE id_pieza = @id_pieza)
            SET @v_errores += N'pieza_publicitaria inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@descripcion)), N'') IS NULL
            SET @v_errores += N'descripcion obligatoria; ';
        IF @duracion_seg <= 0
            SET @v_errores += N'duracion_seg debe ser mayor a 0; ';
        IF NOT EXISTS (SELECT 1 FROM publicidad.campania WHERE id_campania = @id_campania)
            SET @v_errores += N'campania inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM geo.idioma WHERE id_idioma = @id_idioma)
            SET @v_errores += N'idioma inexistente; ';
        IF @id_pais_mercado IS NOT NULL AND NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais_mercado)
            SET @v_errores += N'id_pais_mercado inexistente; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_pieza_publicitaria_modificar;

        UPDATE publicidad.pieza_publicitaria
        SET descripcion = @descripcion,
            duracion_seg = @duracion_seg,
            formato = @formato,
            id_campania = @id_campania,
            id_idioma = @id_idioma,
            id_pais_mercado = @id_pais_mercado
        WHERE id_pieza = @id_pieza;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_PiezaPublicitaria_Eliminar
    @id_pieza INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.pieza_publicitaria WHERE id_pieza = @id_pieza)
            THROW 50001, N'pieza_publicitaria inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM publicidad.exhibicion WHERE id_pieza = @id_pieza;
        IF @v_n > 0 SET @v_errores += CONCAT(N'exhibicion(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_pieza_publicitaria_eliminar;

        DELETE FROM publicidad.pieza_publicitaria WHERE id_pieza = @id_pieza;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 5. publicidad.moneda
CREATE OR ALTER PROCEDURE publicidad.usp_Moneda_Insertar
    @cod_iso4217 CHAR(3),
    @nombre NVARCHAR(50),
    @id_moneda TINYINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF @cod_iso4217 IS NULL OR LEN(@cod_iso4217) <> 3
            SET @v_errores += N'cod_iso4217 debe tener exactamente 3 caracteres; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL
            SET @v_errores += N'nombre obligatorio; ';
        IF EXISTS (SELECT 1 FROM publicidad.moneda WHERE cod_iso4217 = @cod_iso4217)
            SET @v_errores += N'cod_iso4217 ya registrado; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_moneda_insertar;

        INSERT INTO publicidad.moneda (cod_iso4217, nombre) VALUES (@cod_iso4217, @nombre);
        SET @id_moneda = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_moneda_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_Moneda_Modificar
    @id_moneda TINYINT,
    @cod_iso4217 CHAR(3),
    @nombre NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.moneda WHERE id_moneda = @id_moneda)
            SET @v_errores += N'moneda inexistente; ';
        IF @cod_iso4217 IS NULL OR LEN(@cod_iso4217) <> 3
            SET @v_errores += N'cod_iso4217 debe tener exactamente 3 caracteres; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL
            SET @v_errores += N'nombre obligatorio; ';
        IF EXISTS (SELECT 1 FROM publicidad.moneda WHERE cod_iso4217 = @cod_iso4217 AND id_moneda <> @id_moneda)
            SET @v_errores += N'cod_iso4217 ya registrado; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_moneda_modificar;

        UPDATE publicidad.moneda SET cod_iso4217 = @cod_iso4217, nombre = @nombre WHERE id_moneda = @id_moneda;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_Moneda_Eliminar
    @id_moneda TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.moneda WHERE id_moneda = @id_moneda)
            THROW 50001, N'moneda inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM publicidad.tipo_cambio WHERE id_moneda = @id_moneda;
        IF @v_n > 0 SET @v_errores += CONCAT(N'tipo_cambio(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM publicidad.tarifa WHERE id_moneda = @id_moneda;
        IF @v_n > 0 SET @v_errores += CONCAT(N'tarifa(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_moneda_eliminar;

        DELETE FROM publicidad.moneda WHERE id_moneda = @id_moneda;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 6. publicidad.tipo_cambio
CREATE OR ALTER PROCEDURE publicidad.usp_TipoCambio_Insertar
    @id_moneda TINYINT,
    @fecha DATE,
    @cotizacion_usd DECIMAL(18,6)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.moneda WHERE id_moneda = @id_moneda)
            SET @v_errores += N'moneda inexistente; ';
        IF @cotizacion_usd <= 0
            SET @v_errores += N'cotizacion_usd debe ser mayor a 0; ';
        IF EXISTS (SELECT 1 FROM publicidad.tipo_cambio WHERE id_moneda = @id_moneda AND fecha = @fecha)
            SET @v_errores += N'tipo_cambio ya registrado para la moneda y fecha; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_tipo_cambio_insertar;

        INSERT INTO publicidad.tipo_cambio (id_moneda, fecha, cotizacion_usd) VALUES (@id_moneda, @fecha, @cotizacion_usd);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_tipo_cambio_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_TipoCambio_Modificar
    @id_moneda TINYINT,
    @fecha DATE,
    @cotizacion_usd DECIMAL(18,6)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.tipo_cambio WHERE id_moneda = @id_moneda AND fecha = @fecha)
            SET @v_errores += N'tipo_cambio inexistente; ';
        IF @cotizacion_usd <= 0
            SET @v_errores += N'cotizacion_usd debe ser mayor a 0; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_tipo_cambio_modificar;

        UPDATE publicidad.tipo_cambio SET cotizacion_usd = @cotizacion_usd WHERE id_moneda = @id_moneda AND fecha = @fecha;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_TipoCambio_Eliminar
    @id_moneda TINYINT,
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.tipo_cambio WHERE id_moneda = @id_moneda AND fecha = @fecha)
            THROW 50001, N'tipo_cambio inexistente', 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_tipo_cambio_eliminar;

        DELETE FROM publicidad.tipo_cambio WHERE id_moneda = @id_moneda AND fecha = @fecha;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 7. publicidad.franja_horaria
CREATE OR ALTER PROCEDURE publicidad.usp_FranjaHoraria_Insertar
    @hora_desde TIME(0),
    @hora_hasta TIME(0),
    @id_franja TINYINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF @hora_desde >= @hora_hasta
            SET @v_errores += N'hora_desde debe ser menor a hora_hasta; ';
        IF EXISTS (SELECT 1 FROM publicidad.franja_horaria WHERE hora_desde = @hora_desde AND hora_hasta = @hora_hasta)
            SET @v_errores += N'franja_horaria ya registrada; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_franja_horaria_insertar;

        INSERT INTO publicidad.franja_horaria (hora_desde, hora_hasta) VALUES (@hora_desde, @hora_hasta);
        SET @id_franja = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_franja_horaria_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_FranjaHoraria_Modificar
    @id_franja TINYINT,
    @hora_desde TIME(0),
    @hora_hasta TIME(0)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.franja_horaria WHERE id_franja = @id_franja)
            SET @v_errores += N'franja_horaria inexistente; ';
        IF @hora_desde >= @hora_hasta
            SET @v_errores += N'hora_desde debe ser menor a hora_hasta; ';
        IF EXISTS (SELECT 1 FROM publicidad.franja_horaria WHERE hora_desde = @hora_desde AND hora_hasta = @hora_hasta AND id_franja <> @id_franja)
            SET @v_errores += N'franja_horaria ya registrada; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_franja_horaria_modificar;

        UPDATE publicidad.franja_horaria SET hora_desde = @hora_desde, hora_hasta = @hora_hasta WHERE id_franja = @id_franja;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_FranjaHoraria_Eliminar
    @id_franja TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.franja_horaria WHERE id_franja = @id_franja)
            THROW 50001, N'franja_horaria inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM publicidad.tarifa WHERE id_franja = @id_franja;
        IF @v_n > 0 SET @v_errores += CONCAT(N'tarifa(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_franja_horaria_eliminar;

        DELETE FROM publicidad.franja_horaria WHERE id_franja = @id_franja;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 8. publicidad.tarifa
CREATE OR ALTER PROCEDURE publicidad.usp_Tarifa_Insertar
    @id_franja TINYINT,
    @id_moneda TINYINT,
    @importe DECIMAL(18,2),
    @id_tarifa INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.franja_horaria WHERE id_franja = @id_franja)
            SET @v_errores += N'franja_horaria inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM publicidad.moneda WHERE id_moneda = @id_moneda)
            SET @v_errores += N'moneda inexistente; ';
        IF @importe <= 0
            SET @v_errores += N'importe debe ser mayor a 0; ';
        IF EXISTS (SELECT 1 FROM publicidad.tarifa WHERE id_franja = @id_franja AND id_moneda = @id_moneda)
            SET @v_errores += N'tarifa ya registrada para la franja y moneda; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_tarifa_insertar;

        INSERT INTO publicidad.tarifa (id_franja, id_moneda, importe) VALUES (@id_franja, @id_moneda, @importe);
        SET @id_tarifa = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_tarifa_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_Tarifa_Modificar
    @id_tarifa INT,
    @id_franja TINYINT,
    @id_moneda TINYINT,
    @importe DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.tarifa WHERE id_tarifa = @id_tarifa)
            SET @v_errores += N'tarifa inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM publicidad.franja_horaria WHERE id_franja = @id_franja)
            SET @v_errores += N'franja_horaria inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM publicidad.moneda WHERE id_moneda = @id_moneda)
            SET @v_errores += N'moneda inexistente; ';
        IF @importe <= 0
            SET @v_errores += N'importe debe ser mayor a 0; ';
        IF EXISTS (SELECT 1 FROM publicidad.tarifa WHERE id_franja = @id_franja AND id_moneda = @id_moneda AND id_tarifa <> @id_tarifa)
            SET @v_errores += N'tarifa ya registrada para la franja y moneda; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_tarifa_modificar;

        UPDATE publicidad.tarifa
        SET id_franja = @id_franja,
            id_moneda = @id_moneda,
            importe = @importe
        WHERE id_tarifa = @id_tarifa;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_Tarifa_Eliminar
    @id_tarifa INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.tarifa WHERE id_tarifa = @id_tarifa)
            THROW 50001, N'tarifa inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM publicidad.exhibicion WHERE id_tarifa = @id_tarifa;
        IF @v_n > 0 SET @v_errores += CONCAT(N'exhibicion(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_tarifa_eliminar;

        DELETE FROM publicidad.tarifa WHERE id_tarifa = @id_tarifa;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 9. publicidad.espacio_publicitario
CREATE OR ALTER PROCEDURE publicidad.usp_EspacioPublicitario_Insertar
    @id_sede INT,
    @nro_espacio TINYINT,
    @tipo VARCHAR(20),
    @descripcion NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.sede WHERE id_sede = @id_sede)
            SET @v_errores += N'sede inexistente; ';
        IF @nro_espacio < 1 OR @nro_espacio > 4
            SET @v_errores += N'nro_espacio debe estar entre 1 y 4; ';
        IF EXISTS (SELECT 1 FROM publicidad.espacio_publicitario WHERE id_sede = @id_sede AND nro_espacio = @nro_espacio)
            SET @v_errores += N'espacio_publicitario ya registrado; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_espacio_publicitario_insertar;

        INSERT INTO publicidad.espacio_publicitario (id_sede, nro_espacio, tipo, descripcion)
        VALUES (@id_sede, @nro_espacio, @tipo, @descripcion);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_espacio_publicitario_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_EspacioPublicitario_Modificar
    @id_sede INT,
    @nro_espacio TINYINT,
    @tipo VARCHAR(20),
    @descripcion NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.espacio_publicitario WHERE id_sede = @id_sede AND nro_espacio = @nro_espacio)
            SET @v_errores += N'espacio_publicitario inexistente; ';
        IF @nro_espacio < 1 OR @nro_espacio > 4
            SET @v_errores += N'nro_espacio debe estar entre 1 y 4; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_espacio_pub_modificar;

        UPDATE publicidad.espacio_publicitario
        SET tipo = @tipo,
            descripcion = @descripcion
        WHERE id_sede = @id_sede AND nro_espacio = @nro_espacio;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_EspacioPublicitario_Eliminar
    @id_sede INT,
    @nro_espacio TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.espacio_publicitario WHERE id_sede = @id_sede AND nro_espacio = @nro_espacio)
            THROW 50001, N'espacio_publicitario inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM publicidad.exhibicion WHERE id_sede = @id_sede AND nro_espacio = @nro_espacio;
        IF @v_n > 0 SET @v_errores += CONCAT(N'exhibicion(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_espacio_publicitario_eliminar;

        DELETE FROM publicidad.espacio_publicitario WHERE id_sede = @id_sede AND nro_espacio = @nro_espacio;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 10. publicidad.exhibicion
CREATE OR ALTER PROCEDURE publicidad.usp_Exhibicion_Insertar
    @id_partido INT,
    @id_sede INT,
    @nro_espacio TINYINT,
    @id_pieza INT,
    @id_tarifa INT,
    @fecha_hora_emision DATETIME2(0),
    @orden_prioridad TINYINT,
    @importe_facturado DECIMAL(18,2),
    @cotizacion_aplicada DECIMAL(18,6),
    @id_exhibicion INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.partido WHERE id_partido = @id_partido)
            SET @v_errores += N'partido inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM publicidad.espacio_publicitario WHERE id_sede = @id_sede AND nro_espacio = @nro_espacio)
            SET @v_errores += N'espacio_publicitario inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM publicidad.pieza_publicitaria WHERE id_pieza = @id_pieza)
            SET @v_errores += N'pieza_publicitaria inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM publicidad.tarifa WHERE id_tarifa = @id_tarifa)
            SET @v_errores += N'tarifa inexistente; ';
        IF @orden_prioridad < 1 OR @orden_prioridad > 4
            SET @v_errores += N'orden_prioridad debe estar entre 1 y 4; ';
        IF EXISTS (SELECT 1 FROM publicidad.exhibicion WHERE id_partido = @id_partido AND id_sede = @id_sede AND nro_espacio = @nro_espacio)
            SET @v_errores += N'espacio ya ocupado en el partido; ';
        IF EXISTS (SELECT 1 FROM publicidad.exhibicion WHERE id_partido = @id_partido AND id_pieza = @id_pieza)
            SET @v_errores += N'pieza ya exhibida en el partido; ';
        IF EXISTS (SELECT 1 FROM publicidad.exhibicion WHERE id_partido = @id_partido AND orden_prioridad = @orden_prioridad)
            SET @v_errores += N'orden_prioridad ya utilizado en el partido; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_exhibicion_insertar;

        INSERT INTO publicidad.exhibicion (id_partido, id_sede, nro_espacio, id_pieza, id_tarifa, fecha_hora_emision, orden_prioridad, importe_facturado, cotizacion_aplicada)
        VALUES (@id_partido, @id_sede, @nro_espacio, @id_pieza, @id_tarifa, @fecha_hora_emision, @orden_prioridad, @importe_facturado, @cotizacion_aplicada);
        SET @id_exhibicion = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_exhibicion_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_Exhibicion_Modificar
    @id_exhibicion INT,
    @id_partido INT,
    @id_sede INT,
    @nro_espacio TINYINT,
    @id_pieza INT,
    @id_tarifa INT,
    @fecha_hora_emision DATETIME2(0),
    @orden_prioridad TINYINT,
    @importe_facturado DECIMAL(18,2),
    @cotizacion_aplicada DECIMAL(18,6)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.exhibicion WHERE id_exhibicion = @id_exhibicion)
            SET @v_errores += N'exhibicion inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM torneo.partido WHERE id_partido = @id_partido)
            SET @v_errores += N'partido inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM publicidad.espacio_publicitario WHERE id_sede = @id_sede AND nro_espacio = @nro_espacio)
            SET @v_errores += N'espacio_publicitario inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM publicidad.pieza_publicitaria WHERE id_pieza = @id_pieza)
            SET @v_errores += N'pieza_publicitaria inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM publicidad.tarifa WHERE id_tarifa = @id_tarifa)
            SET @v_errores += N'tarifa inexistente; ';
        IF @orden_prioridad < 1 OR @orden_prioridad > 4
            SET @v_errores += N'orden_prioridad debe estar entre 1 y 4; ';
        IF EXISTS (SELECT 1 FROM publicidad.exhibicion WHERE id_partido = @id_partido AND id_sede = @id_sede AND nro_espacio = @nro_espacio AND id_exhibicion <> @id_exhibicion)
            SET @v_errores += N'espacio ya ocupado en el partido; ';
        IF EXISTS (SELECT 1 FROM publicidad.exhibicion WHERE id_partido = @id_partido AND id_pieza = @id_pieza AND id_exhibicion <> @id_exhibicion)
            SET @v_errores += N'pieza ya exhibida en el partido; ';
        IF EXISTS (SELECT 1 FROM publicidad.exhibicion WHERE id_partido = @id_partido AND orden_prioridad = @orden_prioridad AND id_exhibicion <> @id_exhibicion)
            SET @v_errores += N'orden_prioridad ya utilizado en el partido; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_exhibicion_modificar;

        UPDATE publicidad.exhibicion
        SET id_partido = @id_partido,
            id_sede = @id_sede,
            nro_espacio = @nro_espacio,
            id_pieza = @id_pieza,
            id_tarifa = @id_tarifa,
            fecha_hora_emision = @fecha_hora_emision,
            orden_prioridad = @orden_prioridad,
            importe_facturado = @importe_facturado,
            cotizacion_aplicada = @cotizacion_aplicada
        WHERE id_exhibicion = @id_exhibicion;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_Exhibicion_Eliminar
    @id_exhibicion INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.exhibicion WHERE id_exhibicion = @id_exhibicion)
            THROW 50001, N'exhibicion inexistente', 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_exhibicion_eliminar;

        DELETE FROM publicidad.exhibicion WHERE id_exhibicion = @id_exhibicion;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 11. publicidad.feriado
CREATE OR ALTER PROCEDURE publicidad.usp_Feriado_Insertar
    @id_pais SMALLINT,
    @fecha DATE,
    @nombre NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais)
            SET @v_errores += N'pais inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL
            SET @v_errores += N'nombre obligatorio; ';
        IF EXISTS (SELECT 1 FROM publicidad.feriado WHERE id_pais = @id_pais AND fecha = @fecha)
            SET @v_errores += N'feriado ya registrado para el pais y fecha; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_feriado_insertar;

        INSERT INTO publicidad.feriado (id_pais, fecha, nombre) VALUES (@id_pais, @fecha, @nombre);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_feriado_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_Feriado_Modificar
    @id_pais SMALLINT,
    @fecha DATE,
    @nombre NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.feriado WHERE id_pais = @id_pais AND fecha = @fecha)
            SET @v_errores += N'feriado inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL
            SET @v_errores += N'nombre obligatorio; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_feriado_modificar;

        UPDATE publicidad.feriado SET nombre = @nombre WHERE id_pais = @id_pais AND fecha = @fecha;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE publicidad.usp_Feriado_Eliminar
    @id_pais SMALLINT,
    @fecha DATE
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM publicidad.feriado WHERE id_pais = @id_pais AND fecha = @fecha)
            THROW 50001, N'feriado inexistente', 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_feriado_eliminar;

        DELETE FROM publicidad.feriado WHERE id_pais = @id_pais AND fecha = @fecha;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO