/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Prueba exitosa de los SP de negocio para registrar gol,tarjeta y sustitucion sin dejar residuos.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

PRINT '=====================================================================';
PRINT 'INICIO PRUEBA EXITOSA: 70_Test_OK_Eventos';
PRINT '=====================================================================';

DECLARE @v_id_partido INT;
DECLARE @v_id_seleccion INT;
DECLARE @v_autor INT;
DECLARE @v_asistente INT;
DECLARE @v_jugador_sale INT;
DECLARE @v_jugador_entra INT;
DECLARE @v_id_tipo_tarjeta TINYINT;
DECLARE @v_id_arbitro INT;
DECLARE @v_nro_gol TINYINT;
DECLARE @v_nro_tarjeta TINYINT;
DECLARE @v_nro_sustitucion TINYINT;
DECLARE @v_goles_antes INT;
DECLARE @v_tarjetas_antes INT;
DECLARE @v_sustituciones_antes INT;
DECLARE @v_estado_original VARCHAR(12);

-------------------------------------------------------------------------------
-- 1. Validar los procedimientos requeridos
-------------------------------------------------------------------------------

IF OBJECT_ID('juego.usp_Negocio_RegistrarGol', 'P') IS NULL
   OR OBJECT_ID('juego.usp_Negocio_RegistrarTarjeta', 'P') IS NULL
   OR OBJECT_ID('juego.usp_Negocio_RegistrarSustitucio', 'P') IS NULL
BEGIN
    ;THROW 50001,
           '70_Test_OK_Eventos: faltan uno o mas procedimientos de negocio requeridos',
           1;
END;

-------------------------------------------------------------------------------
-- 2. Obtener un partido y una seleccion con alineacion utilizable
-------------------------------------------------------------------------------

SELECT TOP (1)
    @v_id_partido = a.id_partido,
    @v_id_seleccion = a.id_seleccion
FROM juego.alineacion AS a
JOIN torneo.partido AS p
  ON p.id_partido = a.id_partido
WHERE p.estado IN ('PROGRAMADO', 'EN_CURSO')
GROUP BY a.id_partido, a.id_seleccion
HAVING SUM(CASE WHEN a.es_titular = 1 THEN 1 ELSE 0 END) >= 2
   AND SUM(CASE WHEN a.es_titular = 0 THEN 1 ELSE 0 END) >= 1
ORDER BY a.id_partido, a.id_seleccion;

SELECT TOP (1)
    @v_autor = a.id_jugador
FROM juego.alineacion AS a
WHERE a.id_partido = @v_id_partido
  AND a.id_seleccion = @v_id_seleccion
  AND a.es_titular = 1
ORDER BY a.dorsal, a.id_jugador;

SELECT TOP (1)
    @v_asistente = a.id_jugador
FROM juego.alineacion AS a
WHERE a.id_partido = @v_id_partido
  AND a.id_seleccion = @v_id_seleccion
  AND a.es_titular = 1
  AND a.id_jugador <> @v_autor
ORDER BY a.dorsal, a.id_jugador;

-- Se usa otro titular para la sustitucion, de ser posible. Si solo hay dos,
-- se utiliza el autor del gol.
SELECT TOP (1)
    @v_jugador_sale = a.id_jugador
FROM juego.alineacion AS a
WHERE a.id_partido = @v_id_partido
  AND a.id_seleccion = @v_id_seleccion
  AND a.es_titular = 1
  AND a.id_jugador NOT IN (@v_autor, @v_asistente)
ORDER BY a.dorsal, a.id_jugador;

SET @v_jugador_sale = ISNULL(@v_jugador_sale, @v_autor);

SELECT TOP (1)
    @v_jugador_entra = a.id_jugador
FROM juego.alineacion AS a
WHERE a.id_partido = @v_id_partido
  AND a.id_seleccion = @v_id_seleccion
  AND a.es_titular = 0
ORDER BY a.dorsal, a.id_jugador;

-- No se asume que la tarjeta amarilla tenga id_tipo = 1.
SELECT TOP (1)
    @v_id_tipo_tarjeta = tt.id_tipo
FROM juego.tipo_tarjeta AS tt
WHERE UPPER(tt.descripcion) LIKE '%AMARILL%'
ORDER BY tt.id_tipo;

-- La tarjeta requiere el arbitro que la muestra. Se obtiene una designacion
-- vigente del partido, preferentemente la del rol principal.
SELECT TOP (1)
    @v_id_arbitro = da.id_arbitro
FROM arbitraje.designacion_arbitral AS da
LEFT JOIN arbitraje.rol_arbitral AS ra
  ON ra.id_rol = da.id_rol
WHERE da.id_partido = @v_id_partido
  AND da.estado = 'DESIGNADA'
ORDER BY CASE WHEN UPPER(ra.descripcion) = 'PRINCIPAL' THEN 0 ELSE 1 END,
         da.id_rol;

IF @v_id_partido IS NULL
   OR @v_id_seleccion IS NULL
   OR @v_autor IS NULL
   OR @v_asistente IS NULL
   OR @v_jugador_sale IS NULL
   OR @v_jugador_entra IS NULL
   OR @v_id_tipo_tarjeta IS NULL
   OR @v_id_arbitro IS NULL
BEGIN
    ;THROW 50001,
           '70_Test_OK_Eventos: se requiere un partido con alineacion, dos titulares, un suplente, tarjeta amarilla y arbitro designado',
           1;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT @v_estado_original = p.estado
    FROM torneo.partido AS p
    WHERE p.id_partido = @v_id_partido;

    -- Los eventos de juego se registran durante el partido.
    IF @v_estado_original = 'PROGRAMADO'
    BEGIN
        UPDATE torneo.partido
        SET estado = 'EN_CURSO'
        WHERE id_partido = @v_id_partido;
    END;

    SELECT @v_goles_antes = COUNT(*)
    FROM juego.gol
    WHERE id_partido = @v_id_partido;

    SELECT @v_tarjetas_antes = COUNT(*)
    FROM juego.tarjeta
    WHERE id_partido = @v_id_partido;

    SELECT @v_sustituciones_antes = COUNT(*)
    FROM juego.sustitucion
    WHERE id_partido = @v_id_partido
      AND id_seleccion = @v_id_seleccion;

    PRINT '--- EVIDENCIA ANTES DE REGISTRAR EVENTOS ---';

    SELECT
        @v_id_partido AS id_partido,
        @v_id_seleccion AS id_seleccion,
        @v_autor AS autor_gol,
        @v_asistente AS asistente_gol,
        @v_jugador_sale AS jugador_sale,
        @v_jugador_entra AS jugador_entra,
        @v_id_tipo_tarjeta AS id_tipo_tarjeta,
        @v_id_arbitro AS id_arbitro,
        @v_goles_antes AS goles_antes,
        @v_tarjetas_antes AS tarjetas_antes,
        @v_sustituciones_antes AS sustituciones_antes;

    ---------------------------------------------------------------------------
    -- 3. Registrar gol
    ---------------------------------------------------------------------------

    EXEC juego.usp_Negocio_RegistrarGol
        @id_partido = @v_id_partido,
        @id_seleccion = @v_id_seleccion,
        @id_jugador_autor = @v_autor,
        @id_jugador_asistente = @v_asistente,
        @minuto = 25,
        @tipo_gol = 'JUGADA',
        @en_contra = 0,
        @periodo = 'PT',
        @nro_gol = @v_nro_gol OUTPUT;

    SELECT CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM juego.gol AS g
                 WHERE g.id_partido = @v_id_partido
                   AND g.id_seleccion = @v_id_seleccion
                   AND g.nro_gol = @v_nro_gol
                   AND g.id_jugador_autor = @v_autor
                   AND g.id_jugador_asistente = @v_asistente
                   AND g.minuto = 25
                   AND g.periodo = 'PT'
             )
            THEN 'PASS registrar gol'
        ELSE 'FAIL registrar gol'
    END AS resultado;

    ---------------------------------------------------------------------------
    -- 4. Registrar tarjeta
    ---------------------------------------------------------------------------
    DECLARE @v_id_suspension INT;
    EXEC juego.usp_Negocio_RegistrarTarjeta
        @id_partido = @v_id_partido,
        @id_seleccion = @v_id_seleccion,
        @id_jugador = @v_autor,
        @id_tipo = @v_id_tipo_tarjeta,
        @id_arbitro = @v_id_arbitro,
        @minuto = 35,
        @motivo = 'Conducta antideportiva',
        @nro_tarjeta = @v_nro_tarjeta OUTPUT,
        @id_suspension = @v_id_suspension OUTPUT;;

    SELECT CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM juego.tarjeta AS t
                 WHERE t.id_partido = @v_id_partido
                   AND t.id_seleccion = @v_id_seleccion
                   AND t.nro_tarjeta = @v_nro_tarjeta
                   AND t.id_jugador = @v_autor
                   AND t.id_tipo = @v_id_tipo_tarjeta
                   AND t.id_arbitro = @v_id_arbitro
                   AND t.minuto = 35
             )
            THEN 'PASS registrar tarjeta'
        ELSE 'FAIL registrar tarjeta'
    END AS resultado;

    ---------------------------------------------------------------------------
    -- 5. Registrar sustitucion
    ---------------------------------------------------------------------------

    EXEC juego.usp_Negocio_RegistrarSustitucion
        @id_partido = @v_id_partido,
        @id_seleccion = @v_id_seleccion,
        @id_jugador_sale = @v_jugador_sale,
        @id_jugador_entra = @v_jugador_entra,
        @minuto = 65,
        @motivo = 'TACTICA',
        @nro_sustitucion = @v_nro_sustitucion OUTPUT;

    SELECT CASE
        WHEN EXISTS
             (
                 SELECT 1
                 FROM juego.sustitucion AS s
                 WHERE s.id_partido = @v_id_partido
                   AND s.id_seleccion = @v_id_seleccion
                   AND s.nro_sustitucion = @v_nro_sustitucion
                   AND s.id_jugador_sale = @v_jugador_sale
                   AND s.id_jugador_entra = @v_jugador_entra
                   AND s.minuto = 65
             )
            THEN 'PASS registrar sustitucion'
        ELSE 'FAIL registrar sustitucion'
    END AS resultado;

    PRINT '--- EVIDENCIA DESPUES DE REGISTRAR EVENTOS ---';

    SELECT g.*
    FROM juego.gol AS g
    WHERE g.id_partido = @v_id_partido
      AND g.id_seleccion = @v_id_seleccion
      AND g.nro_gol = @v_nro_gol;

    SELECT t.*
    FROM juego.tarjeta AS t
    WHERE t.id_partido = @v_id_partido
      AND t.id_seleccion = @v_id_seleccion
      AND t.nro_tarjeta = @v_nro_tarjeta;

    SELECT s.*
    FROM juego.sustitucion AS s
    WHERE s.id_partido = @v_id_partido
      AND s.id_seleccion = @v_id_seleccion
      AND s.nro_sustitucion = @v_nro_sustitucion;

    ROLLBACK TRANSACTION;
    PRINT 'PASS general: prueba finalizada y transaccion revertida.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT CONCAT
    (
        'FAIL general. Error ',
        ERROR_NUMBER(),
        ': ',
        ERROR_MESSAGE()
    );

    ;THROW;
END CATCH;
GO

PRINT '=====================================================================';
PRINT 'FIN PRUEBA EXITOSA: 70_Test_OK_Eventos';
PRINT 'ROLLBACK EJECUTADO';
PRINT '=====================================================================';
GO
