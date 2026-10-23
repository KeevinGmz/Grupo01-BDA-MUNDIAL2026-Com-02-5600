/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comision: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Crea los SP de ABM del esquema persona.
   ===================================================================== */
USE Mundial2026;
GO

-- ============================================================================
-- 1. persona.posicion
-- ============================================================================

CREATE OR ALTER PROCEDURE persona.usp_Posicion_Insertar
    @descripcion NVARCHAR(40),
    @id_posicion TINYINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF NULLIF(LTRIM(RTRIM(@descripcion)), N'') IS NULL SET @v_errores += N'descripcion obligatoria; ';
        IF EXISTS (SELECT 1 FROM persona.posicion WHERE descripcion = @descripcion) SET @v_errores += N'descripcion ya registrada; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Posicion_Insertar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_posicion_insertar; SET @v_sp = 1; END

        INSERT INTO persona.posicion (descripcion) VALUES (@descripcion);
        SET @id_posicion = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_posicion_insertar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_Posicion_Modificar
    @id_posicion TINYINT,
    @descripcion NVARCHAR(40)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF NOT EXISTS (SELECT 1 FROM persona.posicion WHERE id_posicion = @id_posicion) SET @v_errores += N'posicion inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@descripcion)), N'') IS NULL SET @v_errores += N'descripcion obligatoria; ';
        IF EXISTS (SELECT 1 FROM persona.posicion WHERE descripcion = @descripcion AND id_posicion <> @id_posicion) SET @v_errores += N'descripcion ya registrada; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Posicion_Modificar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_posicion_modificar; SET @v_sp = 1; END

        UPDATE persona.posicion SET descripcion = @descripcion WHERE id_posicion = @id_posicion;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_posicion_modificar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_Posicion_Eliminar
    @id_posicion TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM persona.posicion WHERE id_posicion = @id_posicion)
            THROW 50001, N'persona.usp_Posicion_Eliminar: posicion inexistente', 1;

        -- 2) Dependientes: una línea por cada tabla con FK a esta fila
        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM persona.jugador WHERE id_posicion_habitual = @id_posicion;
        IF @v_n > 0 SET @v_errores += CONCAT(N'jugador(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM juego.alineacion WHERE id_posicion = @id_posicion;
        IF @v_n > 0 SET @v_errores += CONCAT(N'alineacion(', @v_n, N'); ');
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Posicion_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        -- 3) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_posicion_eliminar; SET @v_sp = 1; END

        DELETE FROM persona.posicion WHERE id_posicion = @id_posicion;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_posicion_eliminar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO



-- ============================================================================
-- 2. persona.rol_cuerpo_tecnico
-- ============================================================================

CREATE OR ALTER PROCEDURE persona.usp_RolCuerpoTecnico_Insertar
    @descripcion NVARCHAR(50),
    @id_rol_ct TINYINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF NULLIF(LTRIM(RTRIM(@descripcion)), N'') IS NULL SET @v_errores += N'descripcion obligatoria; ';
        IF EXISTS (SELECT 1 FROM persona.rol_cuerpo_tecnico WHERE descripcion = @descripcion) SET @v_errores += N'descripcion ya registrada; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_RolCuerpoTecnico_Insertar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_rol_ct_insertar; SET @v_sp = 1; END

        INSERT INTO persona.rol_cuerpo_tecnico (descripcion) VALUES (@descripcion);
        SET @id_rol_ct = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_rol_ct_insertar;
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_RolCuerpoTecnico_Modificar
    @id_rol_ct TINYINT,
    @descripcion NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF NOT EXISTS (SELECT 1 FROM persona.rol_cuerpo_tecnico WHERE id_rol_ct = @id_rol_ct) SET @v_errores += N'rol_cuerpo_tecnico inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@descripcion)), N'') IS NULL SET @v_errores += N'descripcion obligatoria; ';
        IF EXISTS (SELECT 1 FROM persona.rol_cuerpo_tecnico WHERE descripcion = @descripcion AND id_rol_ct <> @id_rol_ct) SET @v_errores += N'descripcion ya registrada; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_RolCuerpoTecnico_Modificar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_rol_ct_modificar; SET @v_sp = 1; END

        UPDATE persona.rol_cuerpo_tecnico SET descripcion = @descripcion WHERE id_rol_ct = @id_rol_ct;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_rol_ct_modificar;
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_RolCuerpoTecnico_Eliminar
    @id_rol_ct TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM persona.rol_cuerpo_tecnico WHERE id_rol_ct = @id_rol_ct)
            THROW 50001, N'persona.usp_RolCuerpoTecnico_Eliminar: rol_cuerpo_tecnico inexistente', 1;

        -- 2) Dependientes: una línea por cada tabla con FK a esta fila 
        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM persona.miembro_cuerpo_tecnico WHERE id_rol_ct = @id_rol_ct;
        IF @v_n > 0 SET @v_errores += CONCAT(N'miembro_cuerpo_tecnico(', @v_n, N'); ');
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_RolCuerpoTecnico_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        -- 3) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_rol_ct_eliminar; SET @v_sp = 1; END

        DELETE FROM persona.rol_cuerpo_tecnico WHERE id_rol_ct = @id_rol_ct;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_rol_ct_eliminar;
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO

-- ============================================================================
-- 3. persona.categoria_arbitral
-- ============================================================================

CREATE OR ALTER PROCEDURE persona.usp_CategoriaArbitral_Insertar
    @descripcion NVARCHAR(50),
    @id_categoria TINYINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF NULLIF(LTRIM(RTRIM(@descripcion)), N'') IS NULL SET @v_errores += N'descripcion obligatoria; ';
        IF EXISTS (SELECT 1 FROM persona.categoria_arbitral WHERE descripcion = @descripcion) SET @v_errores += N'descripcion ya registrada; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_CategoriaArbitral_Insertar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_categoria_arbitral_insertar; SET @v_sp = 1; END

        INSERT INTO persona.categoria_arbitral (descripcion) VALUES (@descripcion);
        SET @id_categoria = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_categoria_arbitral_insertar;
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_CategoriaArbitral_Modificar
    @id_categoria TINYINT,
    @descripcion NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF NOT EXISTS (SELECT 1 FROM persona.categoria_arbitral WHERE id_categoria = @id_categoria) SET @v_errores += N'categoria_arbitral inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@descripcion)), N'') IS NULL SET @v_errores += N'descripcion obligatoria; ';
        IF EXISTS (SELECT 1 FROM persona.categoria_arbitral WHERE descripcion = @descripcion AND id_categoria <> @id_categoria) SET @v_errores += N'descripcion ya registrada; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_CategoriaArbitral_Modificar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_categoria_arbitral_modificar; SET @v_sp = 1; END

        UPDATE persona.categoria_arbitral SET descripcion = @descripcion WHERE id_categoria = @id_categoria;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_categoria_arbitral_modificar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_CategoriaArbitral_Eliminar
    @id_categoria TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM persona.categoria_arbitral WHERE id_categoria = @id_categoria)
            THROW 50001, N'persona.usp_CategoriaArbitral_Eliminar: categoria_arbitral inexistente', 1;

        -- 2) Dependientes: una línea por cada tabla con FK a esta fila 
        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM persona.arbitro WHERE id_categoria = @id_categoria;
        IF @v_n > 0 SET @v_errores += CONCAT(N'arbitro(', @v_n, N'); ');
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_CategoriaArbitral_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        -- 3) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_categoria_arbitral_eliminar; SET @v_sp = 1; END

        DELETE FROM persona.categoria_arbitral WHERE id_categoria = @id_categoria;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_categoria_arbitral_eliminar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO



-- ============================================================================
-- 4. persona.idioma
-- ============================================================================

CREATE OR ALTER PROCEDURE persona.usp_Idioma_Insertar
    @cod_iso639 CHAR(3),
    @nombre NVARCHAR(60),
    @id_idioma SMALLINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF @cod_iso639 IS NULL OR LEN(@cod_iso639) <> 3 SET @v_errores += N'cod_iso639 debe tener 3 letras; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL SET @v_errores += N'nombre obligatorio; ';
        IF EXISTS (SELECT 1 FROM persona.idioma WHERE cod_iso639 = @cod_iso639) SET @v_errores += N'cod_iso639 ya registrado; ';
        IF EXISTS (SELECT 1 FROM persona.idioma WHERE nombre = @nombre) SET @v_errores += N'nombre ya registrado; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Idioma_Insertar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_idioma_insertar; SET @v_sp = 1; END

        INSERT INTO persona.idioma (cod_iso639, nombre) VALUES (@cod_iso639, @nombre);
        SET @id_idioma = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_idioma_insertar;
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_Idioma_Modificar
    @id_idioma SMALLINT,
    @cod_iso639 CHAR(3),
    @nombre NVARCHAR(60)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF NOT EXISTS (SELECT 1 FROM persona.idioma WHERE id_idioma = @id_idioma) SET @v_errores += N'idioma inexistente; ';
        IF @cod_iso639 IS NULL OR LEN(@cod_iso639) <> 3 SET @v_errores += N'cod_iso639 debe tener 3 letras; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL SET @v_errores += N'nombre obligatorio; ';
        IF EXISTS (SELECT 1 FROM persona.idioma WHERE cod_iso639 = @cod_iso639 AND id_idioma <> @id_idioma) SET @v_errores += N'cod_iso639 ya registrado; ';
        IF EXISTS (SELECT 1 FROM persona.idioma WHERE nombre = @nombre AND id_idioma <> @id_idioma) SET @v_errores += N'nombre ya registrado; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Idioma_Modificar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_idioma_modificar; SET @v_sp = 1; END

        UPDATE persona.idioma SET cod_iso639 = @cod_iso639, nombre = @nombre WHERE id_idioma = @id_idioma;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_idioma_modificar;
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_Idioma_Eliminar
    @id_idioma SMALLINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM persona.idioma WHERE id_idioma = @id_idioma)
            THROW 50001, N'persona.usp_Idioma_Eliminar: idioma inexistente', 1;

        -- 2) Dependientes: una línea por cada tabla con FK a esta fila 
        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM persona.persona_idioma WHERE id_idioma = @id_idioma;
        IF @v_n > 0 SET @v_errores += CONCAT(N'persona_idioma(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM publicidad.pieza_publicitaria WHERE id_idioma = @id_idioma;
        IF @v_n > 0 SET @v_errores += CONCAT(N'pieza_publicitaria(', @v_n, N'); ');
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Idioma_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        -- 3) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_idioma_eliminar; SET @v_sp = 1; END

        DELETE FROM persona.idioma WHERE id_idioma = @id_idioma;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_idioma_eliminar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO

-- ============================================================================
-- 5. persona.club
-- ============================================================================

CREATE OR ALTER PROCEDURE persona.usp_Club_Insertar
    @nombre NVARCHAR(100),
    @pais_club NVARCHAR(80),
    @id_club INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL SET @v_errores += N'nombre obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@pais_club)), N'') IS NULL SET @v_errores += N'pais_club obligatorio; ';
        IF EXISTS (SELECT 1 FROM persona.club WHERE nombre = @nombre AND pais_club = @pais_club) SET @v_errores += N'club ya registrado para ese pais; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Club_Insertar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_club_insertar; SET @v_sp = 1; END

        INSERT INTO persona.club (nombre, pais_club) VALUES (@nombre, @pais_club);
        SET @id_club = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_club_insertar;
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_Club_Modificar
    @id_club INT,
    @nombre NVARCHAR(100),
    @pais_club NVARCHAR(80)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF NOT EXISTS (SELECT 1 FROM persona.club WHERE id_club = @id_club) SET @v_errores += N'club inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL SET @v_errores += N'nombre obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@pais_club)), N'') IS NULL SET @v_errores += N'pais_club obligatorio; ';
        IF EXISTS (SELECT 1 FROM persona.club WHERE nombre = @nombre AND pais_club = @pais_club AND id_club <> @id_club) SET @v_errores += N'club ya registrado para ese pais; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Club_Modificar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_club_modificar; SET @v_sp = 1; END

        UPDATE persona.club SET nombre = @nombre, pais_club = @pais_club WHERE id_club = @id_club;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_club_modificar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_Club_Eliminar
    @id_club INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM persona.club WHERE id_club = @id_club)
            THROW 50001, N'persona.usp_Club_Eliminar: club inexistente', 1;

        -- 2) Dependientes: una línea por cada tabla con FK a esta fila
        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM persona.jugador WHERE id_club = @id_club;
        IF @v_n > 0 SET @v_errores += CONCAT(N'jugador(', @v_n, N'); ');
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Club_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        -- 3) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_club_eliminar; SET @v_sp = 1; END

        DELETE FROM persona.club WHERE id_club = @id_club;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_club_eliminar;
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO

-- ============================================================================
-- 6. persona.persona (supertipo)
-- ============================================================================

CREATE OR ALTER PROCEDURE persona.usp_Persona_Modificar
    @id_persona INT,
    @tipo_doc VARCHAR(5),
    @nro_doc NVARCHAR(30),
    @nombre NVARCHAR(80),
    @apellido NVARCHAR(80),
    @fecha_nac DATE,
    @id_pais SMALLINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF NOT EXISTS (SELECT 1 FROM persona.persona WHERE id_persona = @id_persona) SET @v_errores += N'persona inexistente; ';
        IF @tipo_doc IS NULL OR @tipo_doc NOT IN ('DNI','PAS','EXT') SET @v_errores += N'tipo_doc invalido (DNI, PAS, EXT); ';
        IF NULLIF(LTRIM(RTRIM(@nro_doc)), N'') IS NULL SET @v_errores += N'nro_doc obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL SET @v_errores += N'nombre obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@apellido)), N'') IS NULL SET @v_errores += N'apellido obligatorio; ';
        IF @fecha_nac IS NULL OR @fecha_nac > CAST(SYSDATETIME() AS DATE) SET @v_errores += N'fecha_nac obligatoria y no futura; ';
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais) SET @v_errores += N'pais inexistente; ';
        IF EXISTS (SELECT 1 FROM persona.persona WHERE tipo_doc = @tipo_doc AND nro_doc = @nro_doc AND id_persona <> @id_persona) SET @v_errores += N'documento ya registrado; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Persona_Modificar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_persona_modificar; SET @v_sp = 1; END

        UPDATE persona.persona
           SET tipo_doc = @tipo_doc, nro_doc = @nro_doc, nombre = @nombre, apellido = @apellido, fecha_nac = @fecha_nac, id_pais = @id_pais
        WHERE id_persona = @id_persona;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_persona_modificar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_Persona_Eliminar
    @id_persona INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM persona.persona WHERE id_persona = @id_persona)
            THROW 50001, N'persona.usp_Persona_Eliminar: persona inexistente', 1;

        -- 2) Dependientes: una línea por cada tabla con FK a esta fila 
        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM persona.persona_idioma WHERE id_persona = @id_persona;
        IF @v_n > 0 SET @v_errores += CONCAT(N'persona_idioma(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM persona.jugador WHERE id_persona = @id_persona;
        IF @v_n > 0 SET @v_errores += CONCAT(N'jugador(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM persona.miembro_cuerpo_tecnico WHERE id_persona = @id_persona;
        IF @v_n > 0 SET @v_errores += CONCAT(N'miembro_cuerpo_tecnico(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM persona.arbitro WHERE id_persona = @id_persona;
        IF @v_n > 0 SET @v_errores += CONCAT(N'arbitro(', @v_n, N'); ');
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Persona_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        -- 3) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_persona_eliminar; SET @v_sp = 1; END

        DELETE FROM persona.persona WHERE id_persona = @id_persona;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_persona_eliminar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO

-- ============================================================================
-- 7. persona.persona_idioma (tabla puente, PK compuesta: id_persona, id_idioma)
-- ============================================================================

CREATE OR ALTER PROCEDURE persona.usp_PersonaIdioma_Insertar
    @id_persona INT,
    @id_idioma SMALLINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF NOT EXISTS (SELECT 1 FROM persona.persona WHERE id_persona = @id_persona) SET @v_errores += N'persona inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM persona.idioma WHERE id_idioma = @id_idioma) SET @v_errores += N'idioma inexistente; ';
        IF EXISTS (SELECT 1 FROM persona.persona_idioma WHERE id_persona = @id_persona AND id_idioma = @id_idioma) SET @v_errores += N'persona_idioma ya registrado; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_PersonaIdioma_Insertar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_persona_idioma_insertar; SET @v_sp = 1; END

        INSERT INTO persona.persona_idioma (id_persona, id_idioma) VALUES (@id_persona, @id_idioma);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_persona_idioma_insertar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_PersonaIdioma_Eliminar
    @id_persona INT,
    @id_idioma SMALLINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM persona.persona_idioma WHERE id_persona = @id_persona AND id_idioma = @id_idioma)
            THROW 50001, N'persona.usp_PersonaIdioma_Eliminar: persona_idioma inexistente', 1;

        -- 3) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_persona_idioma_eliminar; SET @v_sp = 1; END

        DELETE FROM persona.persona_idioma WHERE id_persona = @id_persona AND id_idioma = @id_idioma;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_persona_idioma_eliminar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO

-- ============================================================================
-- 8. persona.jugador (subtipo de persona: inserta persona + jugador en una transacción)
-- ============================================================================

CREATE OR ALTER PROCEDURE persona.usp_Jugador_Insertar
    @tipo_doc VARCHAR(5),
    @nro_doc NVARCHAR(30),
    @nombre NVARCHAR(80),
    @apellido NVARCHAR(80),
    @fecha_nac DATE,
    @id_pais SMALLINT,
    @pie_habil CHAR(1) = NULL,
    @altura_cm SMALLINT = NULL,
    @id_club INT = NULL,
    @id_posicion_habitual TINYINT,
    @id_persona INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF @tipo_doc IS NULL OR @tipo_doc NOT IN ('DNI','PAS','EXT') SET @v_errores += N'tipo_doc invalido (DNI, PAS, EXT); ';
        IF NULLIF(LTRIM(RTRIM(@nro_doc)), N'') IS NULL SET @v_errores += N'nro_doc obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL SET @v_errores += N'nombre obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@apellido)), N'') IS NULL SET @v_errores += N'apellido obligatorio; ';
        IF @fecha_nac IS NULL OR @fecha_nac > CAST(SYSDATETIME() AS DATE) SET @v_errores += N'fecha_nac obligatoria y no futura; ';
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais) SET @v_errores += N'pais inexistente; ';
        IF EXISTS (SELECT 1 FROM persona.persona WHERE tipo_doc = @tipo_doc AND nro_doc = @nro_doc) SET @v_errores += N'documento ya registrado; ';
        IF @pie_habil IS NOT NULL AND @pie_habil NOT IN ('I','D','A') SET @v_errores += N'pie_habil invalido (I, D, A); ';
        IF @altura_cm IS NOT NULL AND @altura_cm NOT BETWEEN 120 AND 230 SET @v_errores += N'altura_cm fuera de rango (120-230); ';
        IF @id_club IS NOT NULL AND NOT EXISTS (SELECT 1 FROM persona.club WHERE id_club = @id_club) SET @v_errores += N'club inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM persona.posicion WHERE id_posicion = @id_posicion_habitual) SET @v_errores += N'posicion habitual inexistente; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Jugador_Insertar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_jugador_insertar; SET @v_sp = 1; END

        INSERT INTO persona.persona (tipo_persona, tipo_doc, nro_doc, nombre, apellido, fecha_nac, id_pais)
        VALUES ('J', @tipo_doc, @nro_doc, @nombre, @apellido, @fecha_nac, @id_pais);
        SET @id_persona = SCOPE_IDENTITY();
        
        INSERT INTO persona.jugador (id_persona, tipo_persona, pie_habil, altura_cm, id_club, id_posicion_habitual)
        VALUES (@id_persona, 'J', @pie_habil, @altura_cm, @id_club, @id_posicion_habitual);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_jugador_insertar;
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_Jugador_Modificar
    @id_persona INT,
    @tipo_doc VARCHAR(5),
    @nro_doc NVARCHAR(30),
    @nombre NVARCHAR(80),
    @apellido NVARCHAR(80),
    @fecha_nac DATE,
    @id_pais SMALLINT,
    @pie_habil CHAR(1) = NULL,
    @altura_cm SMALLINT = NULL,
    @id_club INT = NULL,
    @id_posicion_habitual TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF NOT EXISTS (SELECT 1 FROM persona.jugador WHERE id_persona = @id_persona) SET @v_errores += N'jugador inexistente; ';
        IF @tipo_doc IS NULL OR @tipo_doc NOT IN ('DNI','PAS','EXT') SET @v_errores += N'tipo_doc invalido (DNI, PAS, EXT); ';
        IF NULLIF(LTRIM(RTRIM(@nro_doc)), N'') IS NULL SET @v_errores += N'nro_doc obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL SET @v_errores += N'nombre obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@apellido)), N'') IS NULL SET @v_errores += N'apellido obligatorio; ';
        IF @fecha_nac IS NULL OR @fecha_nac > CAST(SYSDATETIME() AS DATE) SET @v_errores += N'fecha_nac obligatoria y no futura; ';
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais) SET @v_errores += N'pais inexistente; ';
        IF EXISTS (SELECT 1 FROM persona.persona WHERE tipo_doc = @tipo_doc AND nro_doc = @nro_doc AND id_persona <> @id_persona) SET @v_errores += N'documento ya registrado; ';
        IF @pie_habil IS NOT NULL AND @pie_habil NOT IN ('I','D','A') SET @v_errores += N'pie_habil invalido (I, D, A); ';
        IF @altura_cm IS NOT NULL AND @altura_cm NOT BETWEEN 120 AND 230 SET @v_errores += N'altura_cm fuera de rango (120-230); ';
        IF @id_club IS NOT NULL AND NOT EXISTS (SELECT 1 FROM persona.club WHERE id_club = @id_club) SET @v_errores += N'club inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM persona.posicion WHERE id_posicion = @id_posicion_habitual) SET @v_errores += N'posicion habitual inexistente; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Jugador_Modificar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_jugador_modificar; SET @v_sp = 1; END

        UPDATE persona.persona
           SET tipo_doc = @tipo_doc, nro_doc = @nro_doc, nombre = @nombre, apellido = @apellido, fecha_nac = @fecha_nac, id_pais = @id_pais
        WHERE id_persona = @id_persona;
        
        UPDATE persona.jugador
           SET pie_habil = @pie_habil, altura_cm = @altura_cm, id_club = @id_club, id_posicion_habitual = @id_posicion_habitual
        WHERE id_persona = @id_persona;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_jugador_modificar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_Jugador_Eliminar
    @id_persona INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM persona.jugador WHERE id_persona = @id_persona)
            THROW 50001, N'persona.usp_Jugador_Eliminar: jugador inexistente', 1;

        -- 2) Dependientes: una línea por cada tabla con FK a esta fila 
        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM torneo.convocatoria WHERE id_jugador = @id_persona;
        IF @v_n > 0 SET @v_errores += CONCAT(N'convocatoria(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM juego.suspension WHERE id_jugador = @id_persona;
        IF @v_n > 0 SET @v_errores += CONCAT(N'suspension(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM persona.persona_idioma WHERE id_persona = @id_persona;
        IF @v_n > 0 SET @v_errores += CONCAT(N'persona_idioma(', @v_n, N'); ');
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Jugador_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        -- 3) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_jugador_eliminar; SET @v_sp = 1; END

        DELETE FROM persona.jugador WHERE id_persona = @id_persona;
        DELETE FROM persona.persona WHERE id_persona = @id_persona;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_jugador_eliminar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO

-- ============================================================================
-- 9. persona.miembro_cuerpo_tecnico (subtipo de persona)
-- ============================================================================

CREATE OR ALTER PROCEDURE persona.usp_MiembroCuerpoTecnico_Insertar
    @tipo_doc VARCHAR(5),
    @nro_doc NVARCHAR(30),
    @nombre NVARCHAR(80),
    @apellido NVARCHAR(80),
    @fecha_nac DATE,
    @id_pais SMALLINT,
    @id_rol_ct TINYINT,
    @id_seleccion INT,
    @id_persona INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF @tipo_doc IS NULL OR @tipo_doc NOT IN ('DNI','PAS','EXT') SET @v_errores += N'tipo_doc invalido (DNI, PAS, EXT); ';
        IF NULLIF(LTRIM(RTRIM(@nro_doc)), N'') IS NULL SET @v_errores += N'nro_doc obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL SET @v_errores += N'nombre obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@apellido)), N'') IS NULL SET @v_errores += N'apellido obligatorio; ';
        IF @fecha_nac IS NULL OR @fecha_nac > CAST(SYSDATETIME() AS DATE) SET @v_errores += N'fecha_nac obligatoria y no futura; ';
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais) SET @v_errores += N'pais inexistente; ';
        IF EXISTS (SELECT 1 FROM persona.persona WHERE tipo_doc = @tipo_doc AND nro_doc = @nro_doc) SET @v_errores += N'documento ya registrado; ';
        IF NOT EXISTS (SELECT 1 FROM persona.rol_cuerpo_tecnico WHERE id_rol_ct = @id_rol_ct) SET @v_errores += N'rol_cuerpo_tecnico inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_seleccion = @id_seleccion) SET @v_errores += N'seleccion inexistente; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_MiembroCuerpoTecnico_Insertar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_mct_insertar; SET @v_sp = 1; END

        INSERT INTO persona.persona (tipo_persona, tipo_doc, nro_doc, nombre, apellido, fecha_nac, id_pais)
        VALUES ('C', @tipo_doc, @nro_doc, @nombre, @apellido, @fecha_nac, @id_pais);
        SET @id_persona = SCOPE_IDENTITY();
        
        INSERT INTO persona.miembro_cuerpo_tecnico (id_persona, tipo_persona, id_rol_ct, id_seleccion)
        VALUES (@id_persona, 'C', @id_rol_ct, @id_seleccion);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_mct_insertar;
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_MiembroCuerpoTecnico_Modificar
    @id_persona INT,
    @tipo_doc VARCHAR(5),
    @nro_doc NVARCHAR(30),
    @nombre NVARCHAR(80),
    @apellido NVARCHAR(80),
    @fecha_nac DATE,
    @id_pais SMALLINT,
    @id_rol_ct TINYINT,
    @id_seleccion INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF NOT EXISTS (SELECT 1 FROM persona.miembro_cuerpo_tecnico WHERE id_persona = @id_persona) SET @v_errores += N'miembro_cuerpo_tecnico inexistente; ';
        IF @tipo_doc IS NULL OR @tipo_doc NOT IN ('DNI','PAS','EXT') SET @v_errores += N'tipo_doc invalido (DNI, PAS, EXT); ';
        IF NULLIF(LTRIM(RTRIM(@nro_doc)), N'') IS NULL SET @v_errores += N'nro_doc obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL SET @v_errores += N'nombre obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@apellido)), N'') IS NULL SET @v_errores += N'apellido obligatorio; ';
        IF @fecha_nac IS NULL OR @fecha_nac > CAST(SYSDATETIME() AS DATE) SET @v_errores += N'fecha_nac obligatoria y no futura; ';
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais) SET @v_errores += N'pais inexistente; ';
        IF EXISTS (SELECT 1 FROM persona.persona WHERE tipo_doc = @tipo_doc AND nro_doc = @nro_doc AND id_persona <> @id_persona) SET @v_errores += N'documento ya registrado; ';
        IF NOT EXISTS (SELECT 1 FROM persona.rol_cuerpo_tecnico WHERE id_rol_ct = @id_rol_ct) SET @v_errores += N'rol_cuerpo_tecnico inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_seleccion = @id_seleccion) SET @v_errores += N'seleccion inexistente; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_MiembroCuerpoTecnico_Modificar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_mct_modificar; SET @v_sp = 1; END

        UPDATE persona.persona
           SET tipo_doc = @tipo_doc, nro_doc = @nro_doc, nombre = @nombre, apellido = @apellido, fecha_nac = @fecha_nac, id_pais = @id_pais
        WHERE id_persona = @id_persona;
        
        UPDATE persona.miembro_cuerpo_tecnico
           SET id_rol_ct = @id_rol_ct, id_seleccion = @id_seleccion
        WHERE id_persona = @id_persona;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_mct_modificar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_MiembroCuerpoTecnico_Eliminar
    @id_persona INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM persona.miembro_cuerpo_tecnico WHERE id_persona = @id_persona)
            THROW 50001, N'persona.usp_MiembroCuerpoTecnico_Eliminar: miembro_cuerpo_tecnico inexistente', 1;

        -- 2) Dependientes: una línea por cada tabla con FK a esta fila 
        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM persona.persona_idioma WHERE id_persona = @id_persona;
        IF @v_n > 0 SET @v_errores += CONCAT(N'persona_idioma(', @v_n, N'); ');
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_MiembroCuerpoTecnico_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        -- 3) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_mct_eliminar; SET @v_sp = 1; END

        DELETE FROM persona.miembro_cuerpo_tecnico WHERE id_persona = @id_persona;
        DELETE FROM persona.persona WHERE id_persona = @id_persona;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_mct_eliminar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO

-- ============================================================================
-- 10. persona.arbitro (subtipo de persona)
-- ============================================================================

CREATE OR ALTER PROCEDURE persona.usp_Arbitro_Insertar
    @tipo_doc VARCHAR(5),
    @nro_doc NVARCHAR(30),
    @nombre NVARCHAR(80),
    @apellido NVARCHAR(80),
    @fecha_nac DATE,
    @id_pais SMALLINT,
    @fecha_debut_fifa DATE = NULL,
    @id_categoria TINYINT,
    @id_persona INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF @tipo_doc IS NULL OR @tipo_doc NOT IN ('DNI','PAS','EXT') SET @v_errores += N'tipo_doc invalido (DNI, PAS, EXT); ';
        IF NULLIF(LTRIM(RTRIM(@nro_doc)), N'') IS NULL SET @v_errores += N'nro_doc obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL SET @v_errores += N'nombre obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@apellido)), N'') IS NULL SET @v_errores += N'apellido obligatorio; ';
        IF @fecha_nac IS NULL OR @fecha_nac > CAST(SYSDATETIME() AS DATE) SET @v_errores += N'fecha_nac obligatoria y no futura; ';
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais) SET @v_errores += N'pais inexistente; ';
        IF EXISTS (SELECT 1 FROM persona.persona WHERE tipo_doc = @tipo_doc AND nro_doc = @nro_doc) SET @v_errores += N'documento ya registrado; ';
        IF @fecha_debut_fifa IS NOT NULL AND @fecha_debut_fifa > CAST(SYSDATETIME() AS DATE) SET @v_errores += N'fecha_debut_fifa no puede ser futura; ';
        IF NOT EXISTS (SELECT 1 FROM persona.categoria_arbitral WHERE id_categoria = @id_categoria) SET @v_errores += N'categoria_arbitral inexistente; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Arbitro_Insertar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_arbitro_insertar; SET @v_sp = 1; END

        INSERT INTO persona.persona (tipo_persona, tipo_doc, nro_doc, nombre, apellido, fecha_nac, id_pais)
        VALUES ('A', @tipo_doc, @nro_doc, @nombre, @apellido, @fecha_nac, @id_pais);
        SET @id_persona = SCOPE_IDENTITY();
        
        INSERT INTO persona.arbitro (id_persona, tipo_persona, fecha_debut_fifa, id_categoria)
        VALUES (@id_persona, 'A', @fecha_debut_fifa, @id_categoria);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_arbitro_insertar;
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_Arbitro_Modificar
    @id_persona INT,
    @tipo_doc VARCHAR(5),
    @nro_doc NVARCHAR(30),
    @nombre NVARCHAR(80),
    @apellido NVARCHAR(80),
    @fecha_nac DATE,
    @id_pais SMALLINT,
    @fecha_debut_fifa DATE = NULL,
    @id_categoria TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transacción; se acumulan
        IF NOT EXISTS (SELECT 1 FROM persona.arbitro WHERE id_persona = @id_persona) SET @v_errores += N'arbitro inexistente; ';
        IF @tipo_doc IS NULL OR @tipo_doc NOT IN ('DNI','PAS','EXT') SET @v_errores += N'tipo_doc invalido (DNI, PAS, EXT); ';
        IF NULLIF(LTRIM(RTRIM(@nro_doc)), N'') IS NULL SET @v_errores += N'nro_doc obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@nombre)), N'') IS NULL SET @v_errores += N'nombre obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@apellido)), N'') IS NULL SET @v_errores += N'apellido obligatorio; ';
        IF @fecha_nac IS NULL OR @fecha_nac > CAST(SYSDATETIME() AS DATE) SET @v_errores += N'fecha_nac obligatoria y no futura; ';
        IF NOT EXISTS (SELECT 1 FROM geo.pais WHERE id_pais = @id_pais) SET @v_errores += N'pais inexistente; ';
        IF EXISTS (SELECT 1 FROM persona.persona WHERE tipo_doc = @tipo_doc AND nro_doc = @nro_doc AND id_persona <> @id_persona) SET @v_errores += N'documento ya registrado; ';
        IF @fecha_debut_fifa IS NOT NULL AND @fecha_debut_fifa > CAST(SYSDATETIME() AS DATE) SET @v_errores += N'fecha_debut_fifa no puede ser futura; ';
        IF NOT EXISTS (SELECT 1 FROM persona.categoria_arbitral WHERE id_categoria = @id_categoria) SET @v_errores += N'categoria_arbitral inexistente; ';
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Arbitro_Modificar: ', @v_errores);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_arbitro_modificar; SET @v_sp = 1; END

        UPDATE persona.persona
           SET tipo_doc = @tipo_doc, nro_doc = @nro_doc, nombre = @nombre, apellido = @apellido, fecha_nac = @fecha_nac, id_pais = @id_pais
        WHERE id_persona = @id_persona;
        
        UPDATE persona.arbitro
           SET fecha_debut_fifa = @fecha_debut_fifa, id_categoria = @id_categoria
        WHERE id_persona = @id_persona;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_arbitro_modificar;  
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO


--------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE persona.usp_Arbitro_Eliminar
    @id_persona INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    BEGIN TRY
        -- 1) El registro debe existir
        IF NOT EXISTS (SELECT 1 FROM persona.arbitro WHERE id_persona = @id_persona)
            THROW 50001, N'persona.usp_Arbitro_Eliminar: arbitro inexistente', 1;

        -- 2) Dependientes: una línea por cada tabla con FK a esta fila 
        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM juego.tarjeta WHERE id_arbitro = @id_persona;
        IF @v_n > 0 SET @v_errores += CONCAT(N'tarjeta(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM arbitraje.designacion_arbitral WHERE id_arbitro = @id_persona;
        IF @v_n > 0 SET @v_errores += CONCAT(N'designacion_arbitral(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM persona.persona_idioma WHERE id_persona = @id_persona;
        IF @v_n > 0 SET @v_errores += CONCAT(N'persona_idioma(', @v_n, N'); ');
        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'persona.usp_Arbitro_Eliminar: No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        -- 3) Transacción propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_arbitro_eliminar; SET @v_sp = 1; END

        DELETE FROM persona.arbitro WHERE id_persona = @id_persona;
        DELETE FROM persona.persona WHERE id_persona = @id_persona;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;     -- transacción propia: se deshace todo
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_arbitro_eliminar; 
        THROW;   -- relanza el mismo error al llamador
    END CATCH
END
GO

-- Comprobación manual (va en los scripts de testing, no acá):
--   SELECT COUNT(*) FROM sys.procedures WHERE schema_id = SCHEMA_ID('persona') AND name LIKE 'usp[_]%';   -- esperado: 28
