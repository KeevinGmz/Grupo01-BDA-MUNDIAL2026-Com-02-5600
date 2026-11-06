/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Demostrar validaciones fallidas, errores 50001/50002 y mensajes acumulados de los SP ABM del esquema geo.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT '=====================================================================';
PRINT 'INICIO PRUEBAS DE ERROR: 51_Test_ABM_Geo_ERR';
PRINT '=====================================================================';
GO

/* =====================================================================
   CASO 1
   Varias validaciones simultaneas en geo.usp_Pais_Insertar.
===================================================================== */
PRINT '';
PRINT '-> Test 1.1: pais con multiples parametros invalidos';

DECLARE @v_id_pais_salida SMALLINT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje VARCHAR(2048) = NULL;
DECLARE @v_id_confederacion_inexistente TINYINT;

-- Se obtiene un ID realmente inexistente, sin asumir que 99 este libre.
SELECT TOP (1)
    @v_id_confederacion_inexistente = CONVERT(TINYINT, n.numero)
FROM
(
    SELECT TOP (255)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS numero
    FROM sys.all_objects AS a
) AS n
WHERE NOT EXISTS
      (
          SELECT 1
          FROM geo.confederacion AS c
          WHERE c.id_confederacion = n.numero
      )
ORDER BY n.numero DESC;

IF @v_id_confederacion_inexistente IS NULL
BEGIN
    ;THROW 50001,
           '51_Test_ABM_Geo_ERR: no hay un id TINYINT libre para probar confederacion inexistente',
           1;
END;

BEGIN TRANSACTION;

BEGIN TRY
    EXEC geo.usp_Pais_Insertar
        @nombre = '',
        @cod_iso3 = 'AR',
        @cod_fifa = NULL,
        @gentilicio = NULL,
        @id_confederacion = @v_id_confederacion_inexistente,
        @id_pais = @v_id_pais_salida OUTPUT;

    -- Si llega a esta linea, el SP no rechazo los datos.
    SET @v_error_numero = 0;
    SET @v_error_mensaje = 'El SP no lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

PRINT CONCAT('Error capturado ', @v_error_numero, ': ', @v_error_mensaje);

IF @v_error_numero = 50001
   AND @v_error_mensaje LIKE '%nombre obligatorio%'
   AND @v_error_mensaje LIKE '%3 letras%'
   AND @v_error_mensaje LIKE '%confederacion inexistente%'
BEGIN
    PRINT 'PASS Test 1.1: se acumularon las tres validaciones en un unico error 50001.';
END
ELSE
BEGIN
    PRINT 'FAIL Test 1.1: numero o mensaje distinto del esperado.';
END;
GO

/* =====================================================================
   CASO 2
   Duplicacion de cod_iso3.
===================================================================== */
PRINT '';
PRINT '-> Test 1.2: codigo ISO3 duplicado';

DECLARE @v_id_confederacion TINYINT;
DECLARE @v_id_pais_base SMALLINT;
DECLARE @v_id_pais_duplicado SMALLINT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje VARCHAR(2048) = NULL;

SELECT TOP (1)
    @v_id_confederacion = c.id_confederacion
FROM geo.confederacion AS c
ORDER BY c.id_confederacion;

IF @v_id_confederacion IS NULL
BEGIN
    ;THROW 50001,
           '51_Test_ABM_Geo_ERR: debe existir al menos una confederacion para ejecutar el Test 1.2',
           1;
END;

BEGIN TRANSACTION;

BEGIN TRY
    EXEC geo.usp_Pais_Insertar
        @nombre = 'Pais Base Duplicidad',
        @cod_iso3 = 'DUP',
        @cod_fifa = 'DUP',
        @gentilicio = 'duplicense',
        @id_confederacion = @v_id_confederacion,
        @id_pais = @v_id_pais_base OUTPUT;

    EXEC geo.usp_Pais_Insertar
        @nombre = 'Otro Pais Duplicado',
        @cod_iso3 = 'DUP',
        @cod_fifa = 'ODP',
        @gentilicio = 'otro',
        @id_confederacion = @v_id_confederacion,
        @id_pais = @v_id_pais_duplicado OUTPUT;

    SET @v_error_numero = 0;
    SET @v_error_mensaje = 'El SP no lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

PRINT CONCAT('Error capturado ', @v_error_numero, ': ', @v_error_mensaje);

IF @v_error_numero = 50001
   AND @v_error_mensaje LIKE '%cod_iso3 ya registrado%'
BEGIN
    PRINT 'PASS Test 1.2: se rechazo el codigo ISO3 duplicado.';
END
ELSE
BEGIN
    PRINT 'FAIL Test 1.2: numero o mensaje distinto del esperado.';
END;
GO

/* =====================================================================
   CASO 3
   Eliminacion de un pais con una ciudad dependiente.
===================================================================== */
PRINT '';
PRINT '-> Test 1.3: eliminar pais con dependencias';

DECLARE @v_id_confederacion TINYINT;
DECLARE @v_id_huso SMALLINT;
DECLARE @v_id_pais_dependiente SMALLINT;
DECLARE @v_id_ciudad INT;
DECLARE @v_error_numero INT = NULL;
DECLARE @v_error_mensaje VARCHAR(2048) = NULL;

SELECT TOP (1)
    @v_id_confederacion = c.id_confederacion
FROM geo.confederacion AS c
ORDER BY c.id_confederacion;

SELECT TOP (1)
    @v_id_huso = h.id_huso
FROM geo.huso_horario AS h
ORDER BY h.id_huso;

IF @v_id_confederacion IS NULL
BEGIN
    ;THROW 50001,
           '51_Test_ABM_Geo_ERR: debe existir al menos una confederacion para ejecutar el Test 1.3',
           1;
END;

IF @v_id_huso IS NULL
BEGIN
    ;THROW 50001,
           '51_Test_ABM_Geo_ERR: debe existir al menos un huso horario para ejecutar el Test 1.3',
           1;
END;

BEGIN TRANSACTION;

BEGIN TRY
    EXEC geo.usp_Pais_Insertar
        @nombre = 'Pais con Dependencia',
        @cod_iso3 = 'DEP',
        @cod_fifa = 'DEP',
        @gentilicio = 'dependiente',
        @id_confederacion = @v_id_confederacion,
        @id_pais = @v_id_pais_dependiente OUTPUT;

    EXEC geo.usp_Ciudad_Insertar
        @nombre = 'Ciudad Dependiente',
        @poblacion = 100000,
        @id_pais = @v_id_pais_dependiente,
        @id_huso = @v_id_huso,
        @id_ciudad = @v_id_ciudad OUTPUT;

    EXEC geo.usp_Pais_Eliminar
        @id_pais = @v_id_pais_dependiente;

    SET @v_error_numero = 0;
    SET @v_error_mensaje = 'El SP no lanzo la excepcion esperada';
END TRY
BEGIN CATCH
    SET @v_error_numero = ERROR_NUMBER();
    SET @v_error_mensaje = ERROR_MESSAGE();
END CATCH;

IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;

PRINT CONCAT('Error capturado ', @v_error_numero, ': ', @v_error_mensaje);

IF @v_error_numero = 50002
   AND @v_error_mensaje LIKE '%ciudad%'
BEGIN
    PRINT 'PASS Test 1.3: se rechazo la eliminacion y se informo la dependencia ciudad.';
END
ELSE
BEGIN
    PRINT 'FAIL Test 1.3: numero o mensaje distinto del esperado.';
END;
GO

PRINT '';
PRINT '=====================================================================';
PRINT 'FIN PRUEBAS DE ERROR: 51_Test_ABM_Geo_ERR';
PRINT 'Cada caso ejecuto su propio ROLLBACK.';
PRINT '=====================================================================';
GO
