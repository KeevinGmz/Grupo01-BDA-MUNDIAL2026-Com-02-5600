/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada 
Comisión: 02-5600
Grupo : 01 
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro, Agustin
Fecha : 2026-10-03
Objetivo: Validar fallas en ABM Persona (V-14: Documento único, validaciones de dominios)
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS DE ERROR: 53_Test_ABM_Persona_ERR';
PRINT N'=====================================================================';
GO

/* =====================================================================
   CASO 1: documento duplicado a traves del subtipo jugador
===================================================================== */
PRINT N'';
PRINT N'-> Test 1: insertar jugador con documento duplicado';

DECLARE @v_id_pais SMALLINT;
DECLARE @v_id_club INT;
DECLARE @v_id_posicion TINYINT;
DECLARE @v_id_persona_base INT;
DECLARE @v_id_persona_duplicada INT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_nro_doc NVARCHAR(30) = N'JUG-ERR-DUP-0001';

SELECT TOP (1) @v_id_pais = p.id_pais
FROM geo.pais AS p
ORDER BY p.id_pais;

SELECT TOP (1) @v_id_club = c.id_club
FROM persona.club AS c
ORDER BY c.id_club;

SELECT TOP (1) @v_id_posicion = p.id_posicion
FROM persona.posicion AS p
ORDER BY p.id_posicion;

IF @v_id_pais IS NULL OR @v_id_club IS NULL OR @v_id_posicion IS NULL
BEGIN
    ;THROW 50001,N'53_Test_ABM_Persona_ERR: el Test 1 requiere al menos un pais, un club y una posicion',1;
END;

IF OBJECT_ID(N'persona.usp_Jugador_Insertar', N'P') IS NULL
BEGIN
    ;THROW 50001, N'53_Test_ABM_Persona_ERR: no existe persona.usp_Jugador_Insertar',1;
END;

IF EXISTS
(
    SELECT 1
    FROM persona.persona AS p
    WHERE p.tipo_doc = 'DNI'
      AND p.nro_doc = @v_nro_doc
)
BEGIN
    ;THROW 50001, N'53_Test_ABM_Persona_ERR: ya existe el documento reservado para el Test 1',1;
END;

BEGIN TRANSACTION;

BEGIN TRY
    EXEC persona.usp_Jugador_Insertar
        @tipo_doc = 'DNI',
        @nro_doc = @v_nro_doc,
        @nombre = N'Jugador Base',
        @apellido = N'Duplicidad',
        @fecha_nac = '2000-01-01',
        @id_pais = @v_id_pais,
        @pie_habil = 'D',
        @altura_cm = 180,
        @id_club = @v_id_club,
        @id_posicion_habitual = @v_id_posicion,
        @id_persona = @v_id_persona_base OUTPUT;

    EXEC persona.usp_Jugador_Insertar
        @tipo_doc = 'DNI',
        @nro_doc = @v_nro_doc,
        @nombre = N'Jugador Duplicado',
        @apellido = N'Falso',
        @fecha_nac = '2001-01-01',
        @id_pais = @v_id_pais,
        @pie_habil = 'I',
        @altura_cm = 175,
        @id_club = @v_id_club,
        @id_posicion_habitual = @v_id_posicion,
        @id_persona = @v_id_persona_duplicada OUTPUT;

    SET @v_error_numero = 0;
    SET @v_error_mensaje = N'El SP no lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

PRINT CONCAT(N'Error capturado ', @v_error_numero, N': ', @v_error_mensaje);

IF @v_error_numero = 50001
   AND
   (
       @v_error_mensaje LIKE N'%documento%registrado%'
       OR @v_error_mensaje LIKE N'%tipo_doc%nro_doc%registrado%'
       OR @v_error_mensaje LIKE N'%nro_doc%registrado%'
   )
BEGIN
    PRINT N'PASS Test 1: se rechazo el documento duplicado con error 50001.';
END
ELSE
BEGIN
    PRINT N'FAIL Test 1: numero o mensaje distinto del esperado.';
END;
GO

/* =====================================================================
   CASO 2: arbitro sin categoria
===================================================================== */
PRINT N'';
PRINT N'-> Test 2: insertar arbitro con categoria nula';

DECLARE @v_id_pais SMALLINT;
DECLARE @v_id_persona INT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_nro_doc NVARCHAR(30) = N'ARB-ERR-CAT-0001';

SELECT TOP (1) @v_id_pais = p.id_pais
FROM geo.pais AS p
ORDER BY p.id_pais;

IF @v_id_pais IS NULL
BEGIN
    ;THROW 50001,N'53_Test_ABM_Persona_ERR: el Test 2 requiere al menos un pais',1;
END;

IF OBJECT_ID(N'persona.usp_Arbitro_Insertar', N'P') IS NULL
BEGIN
    ;THROW 50001, N'53_Test_ABM_Persona_ERR: no existe persona.usp_Arbitro_Insertar', 1;
END;

IF EXISTS
(
    SELECT 1
    FROM persona.persona AS p
    WHERE p.tipo_doc = 'PAS'
      AND p.nro_doc = @v_nro_doc
)
BEGIN
    ;THROW 50001, N'53_Test_ABM_Persona_ERR: ya existe el documento reservado para el Test 2',1;
END;

BEGIN TRANSACTION;

BEGIN TRY
    EXEC persona.usp_Arbitro_Insertar
        @tipo_doc = 'PAS',
        @nro_doc = @v_nro_doc,
        @nombre = N'Arbitro',
        @apellido = N'Sin Categoria',
        @fecha_nac = '1985-05-15',
        @id_pais = @v_id_pais,
        @fecha_debut_fifa = '2010-01-01',
        @id_categoria = NULL,
        @id_persona = @v_id_persona OUTPUT;

    SET @v_error_numero = 0;
    SET @v_error_mensaje = N'El SP no lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

PRINT CONCAT(N'Error capturado ', @v_error_numero, N': ', @v_error_mensaje);

IF @v_error_numero = 50001
   AND @v_error_mensaje LIKE N'%categoria%'
BEGIN
    PRINT N'PASS Test 2: se rechazo el arbitro sin categoria con error 50001.';
END
ELSE
BEGIN
    PRINT N'FAIL Test 2: numero o mensaje distinto del esperado.';
END;
GO

PRINT N'';
PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS DE ERROR: 53_Test_ABM_Persona_ERR';
PRINT N'Cada caso ejecuto su propio ROLLBACK.';
PRINT N'=====================================================================';
GO
