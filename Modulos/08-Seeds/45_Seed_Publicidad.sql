/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comision: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Carga inicial de anunciantes, mercados, campanias, piezas, tarifas, cotizaciones, espacios y asignacion publicitaria.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @v_errores NVARCHAR(2000) = N'';
DECLARE @v_propia BIT = 0;
DECLARE @v_sp BIT = 0;
DECLARE @v_id_partido INT;
DECLARE @v_fecha_partido DATETIME2(0);
DECLARE @v_id_sede INT;
DECLARE @v_id_idioma SMALLINT;

-------------------------------------------------------------------------------
-- 1. Validaciones y partido del caso 
-------------------------------------------------------------------------------

IF OBJECT_ID(N'publicidad.usp_Negocio_AsignarPublicidad', N'P') IS NULL
    SET @v_errores += N'no existe publicidad.usp_Negocio_AsignarPublicidad; ';

IF OBJECT_ID(N'publicidad.usp_Negocio_SimularPrimeTime', N'P') IS NULL
    SET @v_errores += N'no existe publicidad.usp_Negocio_SimularPrimeTime; ';

-- El caso requiere un partido a la 01:00 UTC.
SELECT TOP (1)
    @v_id_partido = p.id_partido,
    @v_fecha_partido = p.fecha_hora_utc,
    @v_id_sede = p.id_sede
FROM torneo.partido AS p
WHERE DATEPART(HOUR, p.fecha_hora_utc) = 1
  AND DATEPART(MINUTE, p.fecha_hora_utc) = 0
ORDER BY p.fecha_hora_utc, p.id_partido;

IF @v_id_partido IS NULL
    SET @v_errores += N'no existe un partido programado a las 01:00 UTC para demostrar el caso 4; ';

SELECT TOP (1) @v_id_idioma = i.id_idioma
FROM persona.idioma AS i
ORDER BY CASE WHEN i.cod_iso639 = 'spa' THEN 0 ELSE 1 END, i.id_idioma;

IF @v_id_idioma IS NULL
    SET @v_errores += N'debe existir al menos un idioma; ';

IF (SELECT COUNT(*) FROM geo.pais AS p WHERE EXISTS
    (SELECT 1 FROM geo.ciudad AS c WHERE c.id_pais = p.id_pais)) < 6
    SET @v_errores += N'deben existir al menos seis paises con ciudades cargadas; ';

IF NOT EXISTS
(
    SELECT 1 FROM torneo.parametro_reglamento
    WHERE clave = 'PRIME_DESDE_HORA'
)
    SET @v_errores += N'falta el parametro PRIME_DESDE_HORA; ';

IF NOT EXISTS
(
    SELECT 1 FROM torneo.parametro_reglamento
    WHERE clave = 'PRIME_HASTA_HORA'
)
    SET @v_errores += N'falta el parametro PRIME_HASTA_HORA; ';

IF @v_errores <> N''
BEGIN
    SET @v_errores = LEFT(CONCAT(N'45_Seed_Publicidad: ', @v_errores), 2048);
    ;THROW 50001, @v_errores, 1;
END;

-------------------------------------------------------------------------------
-- 2. Seis mercados reales, con ciudad y huso horario
-------------------------------------------------------------------------------

DECLARE @v_mercados TABLE
(
    orden TINYINT NOT NULL PRIMARY KEY,
    id_pais SMALLINT NOT NULL UNIQUE
);

INSERT INTO @v_mercados (orden, id_pais)
SELECT
    CONVERT(TINYINT, ROW_NUMBER() OVER (ORDER BY p.id_pais)),
    p.id_pais
FROM
(
    SELECT TOP (6) pais.id_pais
    FROM geo.pais AS pais
    WHERE EXISTS
          (
              SELECT 1
              FROM geo.ciudad AS c
              WHERE c.id_pais = pais.id_pais
          )
    ORDER BY pais.id_pais
) AS p;

-------------------------------------------------------------------------------
-- 3. Carga transaccional de catalogos y datos publicitarios
-------------------------------------------------------------------------------

BEGIN TRY
    IF @@TRANCOUNT = 0
    BEGIN
        BEGIN TRANSACTION;
        SET @v_propia = 1;
    END
    ELSE
    BEGIN
        SAVE TRANSACTION sv_seed_publicidad;
        SET @v_sp = 1;
    END;

    ---------------------------------------------------------------------------
    -- Moneda USD y cotizacion historica 
    ---------------------------------------------------------------------------

    DECLARE @v_id_moneda_usd TINYINT;

    SELECT @v_id_moneda_usd = m.id_moneda
    FROM publicidad.moneda AS m
    WHERE m.cod_iso4217 = 'USD';

    IF @v_id_moneda_usd IS NULL
    BEGIN
        EXEC publicidad.usp_Moneda_Insertar
            @cod_iso4217 = 'USD',
            @nombre = N'Dolar estadounidense',
            @id_moneda = @v_id_moneda_usd OUTPUT;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM publicidad.tipo_cambio AS tc
        WHERE tc.id_moneda = @v_id_moneda_usd
          AND tc.fecha = CONVERT(DATE, @v_fecha_partido)
    )
    BEGIN
        EXEC publicidad.usp_TipoCambio_Insertar
            @id_moneda = @v_id_moneda_usd,
            @fecha = @v_fecha_partido,
            @cotizacion_usd = 1.000000;
    END;

    ---------------------------------------------------------------------------
    -- Franja de 00:00 a 23:59:59, valida para la hora local de los mercados
    ---------------------------------------------------------------------------

    DECLARE @v_id_franja TINYINT;

    SELECT @v_id_franja = f.id_franja
    FROM publicidad.franja_horaria AS f
    WHERE f.hora_desde = '00:00:00'
      AND f.hora_hasta = '23:59:59';

    IF @v_id_franja IS NULL
    BEGIN
        EXEC publicidad.usp_FranjaHoraria_Insertar
            @hora_desde = '00:00:00',
            @hora_hasta = '23:59:59',
            @id_franja = @v_id_franja OUTPUT;
    END;

    DECLARE @v_id_tarifa INT;

    SELECT @v_id_tarifa = t.id_tarifa
    FROM publicidad.tarifa AS t
    WHERE t.id_franja = @v_id_franja
      AND t.id_moneda = @v_id_moneda_usd;

    IF @v_id_tarifa IS NULL
    BEGIN
        EXEC publicidad.usp_Tarifa_Insertar
            @id_franja = @v_id_franja,
            @id_moneda = @v_id_moneda_usd,
            @importe = 1000.00,
            @id_tarifa = @v_id_tarifa OUTPUT;
    END;

    ---------------------------------------------------------------------------
    -- Cuatro espacios publicitarios en la sede del partido
    ---------------------------------------------------------------------------

    DECLARE @v_espacio TINYINT = 1;
    DECLARE @v_descripcion_espacio NVARCHAR(100);

    WHILE @v_espacio <= 4
    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM publicidad.espacio_publicitario AS e
            WHERE e.id_sede = @v_id_sede
              AND e.nro_espacio = @v_espacio
        )
        BEGIN
            SET @v_descripcion_espacio = CONCAT(N'Espacio seed ', @v_espacio);

            EXEC publicidad.usp_EspacioPublicitario_Insertar
                @id_sede = @v_id_sede,
                @nro_espacio = @v_espacio,
                @tipo = 'PANTALLA',
                @descripcion = @v_descripcion_espacio;
        END;

        SET @v_espacio += 1;
    END;

    ---------------------------------------------------------------------------
    -- Seis anunciantes, mercados de interes, campanias y piezas candidatas
    ---------------------------------------------------------------------------

    DECLARE @v_orden TINYINT = 1;
    DECLARE @v_id_pais SMALLINT;
    DECLARE @v_id_anunciante INT;
    DECLARE @v_id_campania INT;
    DECLARE @v_id_pieza INT;
    DECLARE @v_identificacion NVARCHAR(30);
    DECLARE @v_razon_social NVARCHAR(150);
    DECLARE @v_nombre_campania NVARCHAR(100);
    DECLARE @v_descripcion_pieza NVARCHAR(200);
    DECLARE @v_prioridad TINYINT;
    DECLARE @v_fecha_desde DATE;
    DECLARE @v_fecha_hasta DATE;

    SET @v_fecha_desde = DATEADD(DAY, -30, CONVERT(DATE, @v_fecha_partido));
    SET @v_fecha_hasta = DATEADD(DAY, 30, CONVERT(DATE, @v_fecha_partido));

    WHILE @v_orden <= 6
    BEGIN
        SELECT @v_id_pais = m.id_pais
        FROM @v_mercados AS m
        WHERE m.orden = @v_orden;

        SET @v_identificacion = CONCAT(N'PUB-SEED-', RIGHT(CONCAT(N'000', @v_orden), 3));
        SET @v_razon_social = CONCAT(N'Anunciante Seed ', RIGHT(CONCAT(N'00', @v_orden), 2));
        SET @v_nombre_campania = CONCAT(N'Campania Seed ', RIGHT(CONCAT(N'00', @v_orden), 2));
        SET @v_descripcion_pieza = CONCAT(N'Pieza Seed Mercado ', RIGHT(CONCAT(N'00', @v_orden), 2));
        SET @v_prioridad = CONVERT(TINYINT, ((@v_orden - 1) % 3) + 1);
        SET @v_id_anunciante = NULL;
        SET @v_id_campania = NULL;
        SET @v_id_pieza = NULL;

        SELECT @v_id_anunciante = a.id_anunciante
        FROM publicidad.anunciante AS a
        WHERE a.identificacion_fiscal = @v_identificacion;

        IF @v_id_anunciante IS NULL
        BEGIN
            EXEC publicidad.usp_Anunciante_Insertar
                @razon_social = @v_razon_social,
                @identificacion_fiscal = @v_identificacion,
                @contacto = N'Contacto Seed',
                @id_pais = @v_id_pais,
                @id_anunciante = @v_id_anunciante OUTPUT;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM publicidad.anunciante_pais AS ap
            WHERE ap.id_anunciante = @v_id_anunciante
              AND ap.id_pais = @v_id_pais
        )
        BEGIN
            EXEC publicidad.usp_AnunciantePais_Insertar
                @id_anunciante = @v_id_anunciante,
                @id_pais = @v_id_pais,
                @prioridad = @v_prioridad;
        END;

        SELECT @v_id_campania = c.id_campania
        FROM publicidad.campania AS c
        WHERE c.id_anunciante = @v_id_anunciante
          AND c.nombre = @v_nombre_campania;

        IF @v_id_campania IS NULL
        BEGIN
            EXEC publicidad.usp_Campania_Insertar
                @nombre = @v_nombre_campania,
                @id_anunciante = @v_id_anunciante,
                @fecha_desde = @v_fecha_desde,
                @fecha_hasta = @v_fecha_hasta,
                @presupuesto = 100000.00,
                @id_campania = @v_id_campania OUTPUT;
        END;

        SELECT @v_id_pieza = pz.id_pieza
        FROM publicidad.pieza_publicitaria AS pz
        WHERE pz.id_campania = @v_id_campania
          AND pz.descripcion = @v_descripcion_pieza;

        IF @v_id_pieza IS NULL
        BEGIN
            EXEC publicidad.usp_PiezaPublicitaria_Insertar
                @descripcion = @v_descripcion_pieza,
                @duracion_seg = 30,
                @formato = 'VIDEO',
                @id_campania = @v_id_campania,
                @id_idioma = @v_id_idioma,
                @id_pais_mercado = @v_id_pais,
                @id_pieza = @v_id_pieza OUTPUT;
        END;

        SET @v_orden += 1;
    END;

    IF
    (
        SELECT COUNT(*)
        FROM publicidad.pieza_publicitaria AS pz
        JOIN publicidad.campania AS c ON c.id_campania = pz.id_campania
        JOIN publicidad.anunciante AS a ON a.id_anunciante = c.id_anunciante
        WHERE a.identificacion_fiscal LIKE N'PUB-SEED-%'
          AND CONVERT(DATE, @v_fecha_partido) BETWEEN c.fecha_desde AND c.fecha_hasta
    ) < 5
    BEGIN
        ;THROW 50003,
               N'45_Seed_Publicidad: deben existir al menos cinco piezas candidatas vigentes',
               1;
    END;

    IF @v_propia = 1
        COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @v_propia = 1 AND @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    ELSE IF @v_sp = 1 AND XACT_STATE() = 1
        ROLLBACK TRANSACTION sv_seed_publicidad;
    ;THROW;
END CATCH;
GO

-------------------------------------------------------------------------------
-- 4. Caso 4: simulacion y asignacion
-------------------------------------------------------------------------------

DECLARE @v_partido_caso4 INT;

SELECT TOP (1) @v_partido_caso4 = p.id_partido
FROM torneo.partido AS p
WHERE DATEPART(HOUR, p.fecha_hora_utc) = 1
  AND DATEPART(MINUTE, p.fecha_hora_utc) = 0
ORDER BY p.fecha_hora_utc, p.id_partido;

-- Evidencia de los mercados en prime time para el horario real del partido.
EXEC publicidad.usp_Negocio_SimularPrimeTime
    @id_partido = @v_partido_caso4,
    @fecha_hora_utc_alternativa = NULL;

-- La bandera 1 permite que el seed sea reejecutable.
EXEC publicidad.usp_Negocio_AsignarPublicidad
    @id_partido = @v_partido_caso4,
    @reemplazar = 1;
GO

-------------------------------------------------------------------------------
-- 5. Evidencia final
-------------------------------------------------------------------------------

SELECT
    e.id_partido,
    e.id_sede,
    e.nro_espacio,
    pz.descripcion AS pieza,
    a.razon_social,
    e.orden_prioridad,
    e.importe_facturado,
    e.cotizacion_aplicada
FROM publicidad.exhibicion AS e
JOIN publicidad.pieza_publicitaria AS pz ON pz.id_pieza = e.id_pieza
JOIN publicidad.campania AS c ON c.id_campania = pz.id_campania
JOIN publicidad.anunciante AS a ON a.id_anunciante = c.id_anunciante
WHERE e.id_partido =
      (
          SELECT TOP (1) p.id_partido
          FROM torneo.partido AS p
          WHERE DATEPART(HOUR, p.fecha_hora_utc) = 1
            AND DATEPART(MINUTE, p.fecha_hora_utc) = 0
          ORDER BY p.fecha_hora_utc, p.id_partido
      )
ORDER BY e.nro_espacio;
GO
