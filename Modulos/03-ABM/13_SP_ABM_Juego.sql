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
-- ESQUEMA: juego
--------------------------------------------------------------------------------

-- 1. juego.tipo_tarjeta
CREATE OR ALTER PROCEDURE juego.usp_TipoTarjeta_Insertar
    @descripcion NVARCHAR(30),
    @id_tipo TINYINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NULLIF(LTRIM(RTRIM(@descripcion)), N'') IS NULL
            SET @v_errores += N'descripcion obligatoria; ';
        IF EXISTS (SELECT 1 FROM juego.tipo_tarjeta WHERE descripcion = @descripcion)
            SET @v_errores += N'descripcion ya registrada; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_tipo_tarjeta_insertar;

        INSERT INTO juego.tipo_tarjeta (descripcion) VALUES (@descripcion);
        SET @id_tipo = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_tipo_tarjeta_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_TipoTarjeta_Modificar
    @id_tipo TINYINT,
    @descripcion NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.tipo_tarjeta WHERE id_tipo = @id_tipo)
            SET @v_errores += N'tipo_tarjeta inexistente; ';
        IF NULLIF(LTRIM(RTRIM(@descripcion)), N'') IS NULL
            SET @v_errores += N'descripcion obligatoria; ';
        IF EXISTS (SELECT 1 FROM juego.tipo_tarjeta WHERE descripcion = @descripcion AND id_tipo <> @id_tipo)
            SET @v_errores += N'descripcion ya registrada; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_tipo_tarjeta_modificar;

        UPDATE juego.tipo_tarjeta SET descripcion = @descripcion WHERE id_tipo = @id_tipo;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_TipoTarjeta_Eliminar
    @id_tipo TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.tipo_tarjeta WHERE id_tipo = @id_tipo)
            THROW 50001, N'tipo_tarjeta inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM juego.tarjeta WHERE id_tipo = @id_tipo;
        IF @v_n > 0 SET @v_errores += CONCAT(N'tarjeta(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM juego.criterio_suspension WHERE id_tipo = @id_tipo;
        IF @v_n > 0 SET @v_errores += CONCAT(N'criterio_suspension(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_tipo_tarjeta_eliminar;

        DELETE FROM juego.tipo_tarjeta WHERE id_tipo = @id_tipo;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 2. juego.alineacion
CREATE OR ALTER PROCEDURE juego.usp_Alineacion_Insertar
    @id_partido INT,
    @id_seleccion INT,
    @id_jugador INT,
    @dorsal TINYINT,
    @es_titular BIT,
    @id_posicion TINYINT,
    @es_posicion_habitual BIT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM torneo.equipo_en_partido WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion)
            SET @v_errores += N'equipo_en_partido inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM persona.jugador WHERE id_persona = @id_jugador)
            SET @v_errores += N'jugador inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM torneo.posicion WHERE id_posicion = @id_posicion)
            SET @v_errores += N'posicion inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM torneo.convocatoria WHERE id_seleccion = @id_seleccion AND id_jugador = @id_jugador AND estado = 'ACTIVO')
            SET @v_errores += N'jugador no convocado activo; ';
        IF @dorsal < 1 OR @dorsal > 99
            SET @v_errores += N'dorsal fuera de rango (1-99); ';
        IF EXISTS (SELECT 1 FROM juego.alineacion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND id_jugador = @id_jugador)
            SET @v_errores += N'alineacion ya registrada para el jugador; ';
        IF EXISTS (SELECT 1 FROM juego.alineacion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND dorsal = @dorsal)
            SET @v_errores += N'dorsal ya utilizado en el partido por la seleccion; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_alineacion_insertar;

        INSERT INTO juego.alineacion (id_partido, id_seleccion, id_jugador, dorsal, es_titular, id_posicion, es_posicion_habitual)
        VALUES (@id_partido, @id_seleccion, @id_jugador, @dorsal, @es_titular, @id_posicion, @es_posicion_habitual);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_alineacion_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_Alineacion_Modificar
    @id_partido INT,
    @id_seleccion INT,
    @id_jugador INT,
    @dorsal TINYINT,
    @es_titular BIT,
    @id_posicion TINYINT,
    @es_posicion_habitual BIT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.alineacion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND id_jugador = @id_jugador)
            SET @v_errores += N'alineacion inexistente; ';
        IF @dorsal < 1 OR @dorsal > 99
            SET @v_errores += N'dorsal fuera de rango (1-99); ';
        IF EXISTS (SELECT 1 FROM juego.alineacion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND dorsal = @dorsal AND id_jugador <> @id_jugador)
            SET @v_errores += N'dorsal ya utilizado por otro jugador; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_alineacion_modificar;

        UPDATE juego.alineacion
        SET dorsal = @dorsal,
            es_titular = @es_titular,
            id_posicion = @id_posicion,
            es_posicion_habitual = @es_posicion_habitual
        WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND id_jugador = @id_jugador;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_Alineacion_Eliminar
    @id_partido INT,
    @id_seleccion INT,
    @id_jugador INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.alineacion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND id_jugador = @id_jugador)
            THROW 50001, N'alineacion inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM juego.sustitucion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND (id_jugador_sale = @id_jugador OR id_jugador_entra = @id_jugador);
        IF @v_n > 0 SET @v_errores += CONCAT(N'sustitucion(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM juego.gol WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND (id_jugador_autor = @id_jugador OR id_jugador_asistente = @id_jugador);
        IF @v_n > 0 SET @v_errores += CONCAT(N'gol(', @v_n, N'); ');
        SELECT @v_n = COUNT(*) FROM juego.tarjeta WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND id_jugador = @id_jugador;
        IF @v_n > 0 SET @v_errores += CONCAT(N'tarjeta(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_alineacion_eliminar;

        DELETE FROM juego.alineacion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND id_jugador = @id_jugador;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 3. juego.sustitucion
CREATE OR ALTER PROCEDURE juego.usp_Sustitucion_Insertar
    @id_partido INT,
    @id_seleccion INT,
    @nro_sustitucion TINYINT,
    @minuto SMALLINT,
    @nro_ventana TINYINT,
    @motivo VARCHAR(12),
    @id_jugador_sale INT,
    @id_jugador_entra INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.alineacion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND id_jugador = @id_jugador_sale)
            SET @v_errores += N'jugador_sale no alineado; ';
        IF NOT EXISTS (SELECT 1 FROM juego.alineacion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND id_jugador = @id_jugador_entra)
            SET @v_errores += N'jugador_entra no alineado; ';
        IF @id_jugador_sale = @id_jugador_entra
            SET @v_errores += N'jugador sale y entra deben ser distintos; ';
        IF @minuto < 1 OR @minuto > 130
            SET @v_errores += N'minuto fuera de rango (1-130); ';
        IF @motivo NOT IN ('TACTICO', 'LESION', 'PRECAUCION')
            SET @v_errores += N'motivo invalido; ';
        IF EXISTS (SELECT 1 FROM juego.sustitucion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_sustitucion = @nro_sustitucion)
            SET @v_errores += N'nro_sustitucion ya registrado; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_sustitucion_insertar;

        INSERT INTO juego.sustitucion (id_partido, id_seleccion, nro_sustitucion, minuto, nro_ventana, motivo, id_jugador_sale, id_jugador_entra)
        VALUES (@id_partido, @id_seleccion, @nro_sustitucion, @minuto, @nro_ventana, @motivo, @id_jugador_sale, @id_jugador_entra);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_sustitucion_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_Sustitucion_Modificar
    @id_partido INT,
    @id_seleccion INT,
    @nro_sustitucion TINYINT,
    @minuto SMALLINT,
    @nro_ventana TINYINT,
    @motivo VARCHAR(12),
    @id_jugador_sale INT,
    @id_jugador_entra INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.sustitucion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_sustitucion = @nro_sustitucion)
            SET @v_errores += N'sustitucion inexistente; ';
        IF @minuto < 1 OR @minuto > 130
            SET @v_errores += N'minuto fuera de rango (1-130); ';
        IF @motivo NOT IN ('TACTICO', 'LESION', 'PRECAUCION')
            SET @v_errores += N'motivo invalido; ';
        IF @id_jugador_sale = @id_jugador_entra
            SET @v_errores += N'jugador sale y entra deben ser distintos; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_sustitucion_modificar;

        UPDATE juego.sustitucion
        SET minuto = @minuto,
            nro_ventana = @nro_ventana,
            motivo = @motivo,
            id_jugador_sale = @id_jugador_sale,
            id_jugador_entra = @id_jugador_entra
        WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_sustitucion = @nro_sustitucion;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_Sustitucion_Eliminar
    @id_partido INT,
    @id_seleccion INT,
    @nro_sustitucion TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.sustitucion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_sustitucion = @nro_sustitucion)
            THROW 50001, N'sustitucion inexistente', 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_sustitucion_eliminar;

        DELETE FROM juego.sustitucion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_sustitucion = @nro_sustitucion;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 4. juego.gol
CREATE OR ALTER PROCEDURE juego.usp_Gol_Insertar
    @id_partido INT,
    @id_seleccion INT,
    @nro_gol TINYINT,
    @minuto SMALLINT,
    @tipo_gol VARCHAR(15),
    @en_contra BIT,
    @periodo VARCHAR(5),
    @id_jugador_autor INT,
    @id_jugador_asistente INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.alineacion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND id_jugador = @id_jugador_autor)
            SET @v_errores += N'jugador_autor no alineado; ';
        IF @id_jugador_asistente IS NOT NULL AND NOT EXISTS (SELECT 1 FROM juego.alineacion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND id_jugador = @id_jugador_asistente)
            SET @v_errores += N'jugador_asistente no alineado; ';
        IF @id_jugador_asistente IS NOT NULL AND @id_jugador_autor = @id_jugador_asistente
            SET @v_errores += N'autor y asistente deben ser distintos; ';
        IF @minuto < 0 OR @minuto > 130
            SET @v_errores += N'minuto fuera de rango (0-130); ';
        IF @periodo NOT IN ('PT', 'ST', 'ADIC', 'ALARG', 'PEN')
            SET @v_errores += N'periodo invalido; ';
        IF EXISTS (SELECT 1 FROM juego.gol WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_gol = @nro_gol)
            SET @v_errores += N'nro_gol ya registrado; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_gol_insertar;

        INSERT INTO juego.gol (id_partido, id_seleccion, nro_gol, minuto, tipo_gol, en_contra, periodo, id_jugador_autor, id_jugador_asistente)
        VALUES (@id_partido, @id_seleccion, @nro_gol, @minuto, @tipo_gol, @en_contra, @periodo, @id_jugador_autor, @id_jugador_asistente);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_gol_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_Gol_Modificar
    @id_partido INT,
    @id_seleccion INT,
    @nro_gol TINYINT,
    @minuto SMALLINT,
    @tipo_gol VARCHAR(15),
    @en_contra BIT,
    @periodo VARCHAR(5),
    @id_jugador_autor INT,
    @id_jugador_asistente INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.gol WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_gol = @nro_gol)
            SET @v_errores += N'gol inexistente; ';
        IF @minuto < 0 OR @minuto > 130
            SET @v_errores += N'minuto fuera de rango (0-130); ';
        IF @periodo NOT IN ('PT', 'ST', 'ADIC', 'ALARG', 'PEN')
            SET @v_errores += N'periodo invalido; ';
        IF @id_jugador_asistente IS NOT NULL AND @id_jugador_autor = @id_jugador_asistente
            SET @v_errores += N'autor y asistente deben ser distintos; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_gol_modificar;

        UPDATE juego.gol
        SET minuto = @minuto,
            tipo_gol = @tipo_gol,
            en_contra = @en_contra,
            periodo = @periodo,
            id_jugador_autor = @id_jugador_autor,
            id_jugador_asistente = @id_jugador_asistente
        WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_gol = @nro_gol;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_Gol_Eliminar
    @id_partido INT,
    @id_seleccion INT,
    @nro_gol TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.gol WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_gol = @nro_gol)
            THROW 50001, N'gol inexistente', 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_gol_eliminar;

        DELETE FROM juego.gol WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_gol = @nro_gol;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 5. juego.tarjeta
CREATE OR ALTER PROCEDURE juego.usp_Tarjeta_Insertar
    @id_partido INT,
    @id_seleccion INT,
    @nro_tarjeta TINYINT,
    @minuto SMALLINT,
    @motivo NVARCHAR(100),
    @id_tipo TINYINT,
    @id_arbitro INT,
    @id_jugador INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.alineacion WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND id_jugador = @id_jugador)
            SET @v_errores += N'jugador no alineado; ';
        IF NOT EXISTS (SELECT 1 FROM juego.tipo_tarjeta WHERE id_tipo = @id_tipo)
            SET @v_errores += N'tipo_tarjeta inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM persona.arbitro WHERE id_persona = @id_arbitro)
            SET @v_errores += N'arbitro inexistente; ';
        IF EXISTS (SELECT 1 FROM juego.tarjeta WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_tarjeta = @nro_tarjeta)
            SET @v_errores += N'nro_tarjeta ya registrado; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_tarjeta_insertar;

        INSERT INTO juego.tarjeta (id_partido, id_seleccion, nro_tarjeta, minuto, motivo, id_tipo, id_arbitro, id_jugador)
        VALUES (@id_partido, @id_seleccion, @nro_tarjeta, @minuto, @motivo, @id_tipo, @id_arbitro, @id_jugador);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_tarjeta_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_Tarjeta_Modificar
    @id_partido INT,
    @id_seleccion INT,
    @nro_tarjeta TINYINT,
    @minuto SMALLINT,
    @motivo NVARCHAR(100),
    @id_tipo TINYINT,
    @id_arbitro INT,
    @id_jugador INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.tarjeta WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_tarjeta = @nro_tarjeta)
            SET @v_errores += N'tarjeta inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM juego.tipo_tarjeta WHERE id_tipo = @id_tipo)
            SET @v_errores += N'tipo_tarjeta inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM persona.arbitro WHERE id_persona = @id_arbitro)
            SET @v_errores += N'arbitro inexistente; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_tarjeta_modificar;

        UPDATE juego.tarjeta
        SET minuto = @minuto,
            motivo = @motivo,
            id_tipo = @id_tipo,
            id_arbitro = @id_arbitro,
            id_jugador = @id_jugador
        WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_tarjeta = @nro_tarjeta;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_Tarjeta_Eliminar
    @id_partido INT,
    @id_seleccion INT,
    @nro_tarjeta TINYINT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.tarjeta WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_tarjeta = @nro_tarjeta)
            THROW 50001, N'tarjeta inexistente', 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_tarjeta_eliminar;

        DELETE FROM juego.tarjeta WHERE id_partido = @id_partido AND id_seleccion = @id_seleccion AND nro_tarjeta = @nro_tarjeta;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 6. juego.criterio_suspension
CREATE OR ALTER PROCEDURE juego.usp_CriterioSuspension_Insertar
    @id_tipo TINYINT,
    @cant_tarjetas_requeridas TINYINT,
    @cant_partidos_suspension TINYINT,
    @vigente BIT,
    @id_criterio INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.tipo_tarjeta WHERE id_tipo = @id_tipo)
            SET @v_errores += N'tipo_tarjeta inexistente; ';
        IF @cant_tarjetas_requeridas <= 0 OR @cant_partidos_suspension <= 0
            SET @v_errores += N'cantidades deben ser mayores a 0; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_criterio_suspension_insertar;

        INSERT INTO juego.criterio_suspension (id_tipo, cant_tarjetas_requeridas, cant_partidos_suspension, vigente)
        VALUES (@id_tipo, @cant_tarjetas_requeridas, @cant_partidos_suspension, @vigente);
        SET @id_criterio = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_criterio_suspension_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_CriterioSuspension_Modificar
    @id_criterio INT,
    @id_tipo TINYINT,
    @cant_tarjetas_requeridas TINYINT,
    @cant_partidos_suspension TINYINT,
    @vigente BIT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.criterio_suspension WHERE id_criterio = @id_criterio)
            SET @v_errores += N'criterio_suspension inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM juego.tipo_tarjeta WHERE id_tipo = @id_tipo)
            SET @v_errores += N'tipo_tarjeta inexistente; ';
        IF @cant_tarjetas_requeridas <= 0 OR @cant_partidos_suspension <= 0
            SET @v_errores += N'cantidades deben ser mayores a 0; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_criterio_suspension_modificar;

        UPDATE juego.criterio_suspension
        SET id_tipo = @id_tipo,
            cant_tarjetas_requeridas = @cant_tarjetas_requeridas,
            cant_partidos_suspension = @cant_partidos_suspension,
            vigente = @vigente
        WHERE id_criterio = @id_criterio;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_CriterioSuspension_Eliminar
    @id_criterio INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.criterio_suspension WHERE id_criterio = @id_criterio)
            THROW 50001, N'criterio_suspension inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM juego.suspension WHERE id_criterio = @id_criterio;
        IF @v_n > 0 SET @v_errores += CONCAT(N'suspension(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_criterio_suspension_eliminar;

        DELETE FROM juego.criterio_suspension WHERE id_criterio = @id_criterio;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 7. juego.suspension
CREATE OR ALTER PROCEDURE juego.usp_Suspension_Insertar
    @id_jugador INT,
    @id_criterio INT,
    @cant_partidos TINYINT,
    @estado VARCHAR(10),
    @fecha_alta DATETIME2(0),
    @motivo NVARCHAR(200),
    @id_suspension INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM persona.jugador WHERE id_persona = @id_jugador)
            SET @v_errores += N'jugador inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM juego.criterio_suspension WHERE id_criterio = @id_criterio)
            SET @v_errores += N'criterio_suspension inexistente; ';
        IF @estado NOT IN ('PENDIENTE', 'CUMPLIDA', 'ANULADA')
            SET @v_errores += N'estado invalido; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_suspension_insertar;

        INSERT INTO juego.suspension (id_jugador, id_criterio, cant_partidos, estado, fecha_alta, motivo)
        VALUES (@id_jugador, @id_criterio, @cant_partidos, @estado, @fecha_alta, @motivo);
        SET @id_suspension = SCOPE_IDENTITY();

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_suspension_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_Suspension_Modificar
    @id_suspension INT,
    @id_jugador INT,
    @id_criterio INT,
    @cant_partidos TINYINT,
    @estado VARCHAR(10),
    @fecha_alta DATETIME2(0),
    @motivo NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.suspension WHERE id_suspension = @id_suspension)
            SET @v_errores += N'suspension inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM persona.jugador WHERE id_persona = @id_jugador)
            SET @v_errores += N'jugador inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM juego.criterio_suspension WHERE id_criterio = @id_criterio)
            SET @v_errores += N'criterio_suspension inexistente; ';
        IF @estado NOT IN ('PENDIENTE', 'CUMPLIDA', 'ANULADA')
            SET @v_errores += N'estado invalido; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_suspension_modificar;

        UPDATE juego.suspension
        SET id_jugador = @id_jugador,
            id_criterio = @id_criterio,
            cant_partidos = @cant_partidos,
            estado = @estado,
            fecha_alta = @fecha_alta,
            motivo = @motivo
        WHERE id_suspension = @id_suspension;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_Suspension_Eliminar
    @id_suspension INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.suspension WHERE id_suspension = @id_suspension)
            THROW 50001, N'suspension inexistente', 1;

        DECLARE @v_n INT;
        SELECT @v_n = COUNT(*) FROM juego.suspension_partido WHERE id_suspension = @id_suspension;
        IF @v_n > 0 SET @v_errores += CONCAT(N'suspension_partido(', @v_n, N'); ');

        IF @v_errores <> N''
        BEGIN
            SET @v_errores = CONCAT(N'No se puede eliminar, tiene dependientes: ', @v_errores);
            THROW 50002, @v_errores, 1;
        END

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_suspension_eliminar;

        DELETE FROM juego.suspension WHERE id_suspension = @id_suspension;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- 8. juego.suspension_partido
CREATE OR ALTER PROCEDURE juego.usp_SuspensionPartido_Insertar
    @id_suspension INT,
    @id_partido INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.suspension WHERE id_suspension = @id_suspension)
            SET @v_errores += N'suspension inexistente; ';
        IF NOT EXISTS (SELECT 1 FROM torneo.partido WHERE id_partido = @id_partido)
            SET @v_errores += N'partido inexistente; ';
        IF EXISTS (SELECT 1 FROM juego.suspension_partido WHERE id_suspension = @id_suspension AND id_partido = @id_partido)
            SET @v_errores += N'suspension_partido ya registrado; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_suspension_partido_insertar;

        INSERT INTO juego.suspension_partido (id_suspension, id_partido) VALUES (@id_suspension, @id_partido);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_propia = 0 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_suspension_partido_insertar;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_SuspensionPartido_Modificar
    @id_suspension INT,
    @id_partido INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.suspension_partido WHERE id_suspension = @id_suspension AND id_partido = @id_partido)
            SET @v_errores += N'suspension_partido inexistente; ';

        IF @v_errores <> N'' THROW 50001, @v_errores, 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_suspension_partido_modificar;

        -- Al ser clave compuesta pura de 2 campos que forman la PK, no hay columnas modificables adicionales aparte de la clave.

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE juego.usp_SuspensionPartido_Eliminar
    @id_suspension INT,
    @id_partido INT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_propia BIT = 0;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM juego.suspension_partido WHERE id_suspension = @id_suspension AND id_partido = @id_partido)
            THROW 50001, N'suspension_partido inexistente', 1;

        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE SAVE TRANSACTION sv_suspension_partido_eliminar;

        DELETE FROM juego.suspension_partido WHERE id_suspension = @id_suspension AND id_partido = @id_partido;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO