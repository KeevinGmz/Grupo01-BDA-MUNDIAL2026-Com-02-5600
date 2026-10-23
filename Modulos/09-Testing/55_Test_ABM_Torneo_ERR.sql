/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada 
Comisión: 02-5600
Grupo : 01 
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro, Agustin
Fecha : 2026-10-03
Objetivo: Validar fallas en ABM Torneo (V-02: Máximo 4 selecciones por grupo)
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT N'=====================================================================';
PRINT N'INICIO PRUEBAS DE ERROR: 55_Test_ABM_Torneo_ERR';
PRINT N'=====================================================================';
GO

/* =====================================================================
   CASO 1: V-02, quinta seleccion en un grupo completo
===================================================================== */
PRINT N'';
PRINT N'-> Test 1: intentar registrar una quinta seleccion en un grupo completo';

DECLARE @v_id_confederacion TINYINT;
DECLARE @v_letra_prueba CHAR(1);
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje NVARCHAR(2048) = NULL;
DECLARE @v_cantidad_grupo INT;
DECLARE @v_grupos_antes INT;
DECLARE @v_paises_antes INT;
DECLARE @v_selecciones_antes INT;

-------------------------------------------------------------------------------
-- 1. Validaciones previas
-------------------------------------------------------------------------------

IF OBJECT_ID(N'torneo.usp_Grupo_Insertar', N'P') IS NULL
   OR OBJECT_ID(N'torneo.usp_Seleccion_Insertar', N'P') IS NULL
   OR OBJECT_ID(N'geo.usp_Pais_Insertar', N'P') IS NULL
BEGIN
    ;THROW 50001,N'55_Test_ABM_Torneo_ERR: faltan procedimientos necesarios para preparar la prueba',1;
END;

SELECT TOP (1)
    @v_id_confederacion = c.id_confederacion
FROM geo.confederacion AS c
ORDER BY c.id_confederacion;

IF @v_id_confederacion IS NULL
BEGIN
    ;THROW 50001,N'55_Test_ABM_Torneo_ERR: debe existir al menos una confederacion',1;
END;

-- Se busca una letra valida que no este cargada. No se supone una letra fija.
SELECT TOP (1)
    @v_letra_prueba = letras.id_letra
FROM
(
    SELECT 'A' AS id_letra UNION ALL SELECT 'B' UNION ALL SELECT 'C'
    UNION ALL SELECT 'D' UNION ALL SELECT 'E' UNION ALL SELECT 'F'
    UNION ALL SELECT 'G' UNION ALL SELECT 'H' UNION ALL SELECT 'I'
    UNION ALL SELECT 'J' UNION ALL SELECT 'K' UNION ALL SELECT 'L'
) AS letras
WHERE NOT EXISTS
      (
          SELECT 1
          FROM torneo.grupo AS g
          WHERE g.id_letra = letras.id_letra
      )
ORDER BY letras.id_letra DESC;

IF @v_letra_prueba IS NULL
BEGIN
    ;THROW 50001,N'55_Test_ABM_Torneo_ERR: no hay una letra de grupo libre entre A y L',1;
END;

-- Los codigos reservados no deben existir antes de la prueba.
IF EXISTS
(
    SELECT 1
    FROM geo.pais AS p
    WHERE p.cod_iso3 IN ('Q01', 'Q02', 'Q03', 'Q04', 'Q05')
       OR p.cod_fifa IN ('Q01', 'Q02', 'Q03', 'Q04', 'Q05')
)
BEGIN
    ;THROW 50001,N'55_Test_ABM_Torneo_ERR: existen paises residuales Q01 a Q05 de una prueba anterior',1;
END;

BEGIN TRANSACTION;

BEGIN TRY
    SELECT @v_grupos_antes = COUNT(*) FROM torneo.grupo;
    SELECT @v_paises_antes = COUNT(*) FROM geo.pais;
    SELECT @v_selecciones_antes = COUNT(*) FROM torneo.seleccion;

    ---------------------------------------------------------------------------
    -- 2. Crear grupo reservado para la prueba
    ---------------------------------------------------------------------------

    EXEC torneo.usp_Grupo_Insertar
        @id_letra = @v_letra_prueba;

    ---------------------------------------------------------------------------
    -- 3. Crear cinco paises de prueba mediante el ABM de Geo
    ---------------------------------------------------------------------------

    DECLARE @v_paises TABLE
    (
        orden TINYINT NOT NULL PRIMARY KEY,
        id_pais SMALLINT NOT NULL UNIQUE
    );

    DECLARE @v_orden TINYINT = 1;
    DECLARE @v_id_pais SMALLINT;
    DECLARE @v_nombre_pais NVARCHAR(80);
    DECLARE @v_cod CHAR(3);

    WHILE @v_orden <= 5
    BEGIN
        SET @v_cod = CONCAT('Q0', @v_orden);
        SET @v_nombre_pais = CONCAT(N'Pais Test Torneo ', @v_orden);
        SET @v_id_pais = NULL;

        EXEC geo.usp_Pais_Insertar
            @nombre = @v_nombre_pais,
            @cod_iso3 = @v_cod,
            @cod_fifa = @v_cod,
            @gentilicio = N'test',
            @id_confederacion = @v_id_confederacion,
            @id_pais = @v_id_pais OUTPUT;

        INSERT INTO @v_paises (orden, id_pais)
        VALUES (@v_orden, @v_id_pais);

        SET @v_orden += 1;
    END;

    ---------------------------------------------------------------------------
    -- 4. Registrar cuatro selecciones validas
    ---------------------------------------------------------------------------

    SET @v_orden = 1;

    WHILE @v_orden <= 4
    BEGIN
        DECLARE @v_id_seleccion_valida INT;

        SELECT @v_id_pais = p.id_pais
        FROM @v_paises AS p
        WHERE p.orden = @v_orden;

        EXEC torneo.usp_Seleccion_Insertar
            @id_letra = @v_letra_prueba,
            @id_pais = @v_id_pais,
            @fecha_confirmacion = '2026-01-15',
            @es_anfitrion = 0,
            @id_seleccion = @v_id_seleccion_valida OUTPUT;

        SET @v_orden += 1;
    END;

    SELECT @v_cantidad_grupo = COUNT(*)
    FROM torneo.seleccion AS s
    WHERE s.id_letra = @v_letra_prueba;

    IF @v_cantidad_grupo <> 4
    BEGIN
        ;THROW 50003,
               N'55_Test_ABM_Torneo_ERR: no se pudo preparar un grupo con cuatro selecciones',
               1;
    END;

    ---------------------------------------------------------------------------
    -- 5. Intentar registrar la quinta seleccion
    ---------------------------------------------------------------------------

    SELECT @v_id_pais = p.id_pais
    FROM @v_paises AS p
    WHERE p.orden = 5;

    DECLARE @v_id_quinta_seleccion INT;

    BEGIN TRY
        EXEC torneo.usp_Seleccion_Insertar
            @id_letra = @v_letra_prueba,
            @id_pais = @v_id_pais,
            @fecha_confirmacion = '2026-01-15',
            @es_anfitrion = 0,
            @id_seleccion = @v_id_quinta_seleccion OUTPUT;

        SET @v_error_numero = 0;
        SET @v_error_mensaje = N'El SP acepto una quinta seleccion en el grupo';
    END TRY
    BEGIN CATCH
        SET @v_error_numero = ERROR_NUMBER();
        SET @v_error_mensaje = ERROR_MESSAGE();
    END CATCH;

    SELECT @v_cantidad_grupo = COUNT(*)
    FROM torneo.seleccion AS s
    WHERE s.id_letra = @v_letra_prueba;

    ---------------------------------------------------------------------------
    -- 6. Evaluar el resultado antes del ROLLBACK
    ---------------------------------------------------------------------------

    PRINT CONCAT
    (
        N'Error capturado ',
        @v_error_numero,
        N': ',
        @v_error_mensaje
    );

    IF @v_error_numero = 50001
       AND @v_cantidad_grupo = 4
       AND
       (
           @v_error_mensaje LIKE N'%grupo%4%seleccion%'
           OR @v_error_mensaje LIKE N'%cuatro%seleccion%grupo%'
           OR @v_error_mensaje LIKE N'%maximo%4%grupo%'
       )
    BEGIN
        PRINT N'PASS Test 1: se rechazo la quinta seleccion con error 50001.';
    END
    ELSE
    BEGIN
        PRINT N'FAIL Test 1: el SP no implementa correctamente V-02 o el mensaje no coincide.';
    END;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT CONCAT
    (
        N'FAIL de preparacion. Error ',
        ERROR_NUMBER(),
        N': ',
        ERROR_MESSAGE()
    );

    ;THROW;
END CATCH;
GO

-------------------------------------------------------------------------------
-- 7. Verificacion posterior al ROLLBACK
-------------------------------------------------------------------------------

SELECT CASE
    WHEN NOT EXISTS
         (
             SELECT 1
             FROM geo.pais AS p
             WHERE p.cod_iso3 IN ('Q01', 'Q02', 'Q03', 'Q04', 'Q05')
         )
        THEN N'PASS rollback: no quedaron paises de prueba'
    ELSE N'FAIL rollback: quedaron paises de prueba'
END AS resultado_final;
GO

PRINT N'=====================================================================';
PRINT N'FIN PRUEBAS DE ERROR: 55_Test_ABM_Torneo_ERR';
PRINT N'=====================================================================';
GO
