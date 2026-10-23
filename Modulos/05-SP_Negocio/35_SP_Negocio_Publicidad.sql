/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Crea los procedimientos de negocio para asignar publicidad y simular el horario prime time.
===================================================================== */
USE Mundial2026;
GO

CREATE OR ALTER PROCEDURE publicidad.usp_Negocio_AsignarPublicidad
    @id_partido INT,
    @reemplazar BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_codigo INT = 50001;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    DECLARE @v_utc DATETIME2(0);
    DECLARE @v_id_sede INT;
    DECLARE @v_huso_sede SMALLINT;
    DECLARE @v_pais1 SMALLINT;
    DECLARE @v_pais2 SMALLINT;
    DECLARE @v_prime_desde INT;
    DECLARE @v_prime_hasta INT;
    DECLARE @v_candidatas INT;
    DECLARE @v_espacios INT;

    IF @reemplazar IS NULL
        SET @v_errores += 'reemplazar obligatorio; ';

    SELECT
        @v_utc = p.fecha_hora_utc,
        @v_id_sede = p.id_sede,
        @v_huso_sede = ci.id_huso
    FROM torneo.partido AS p
    JOIN torneo.sede AS s ON s.id_sede = p.id_sede
    JOIN geo.ciudad AS ci ON ci.id_ciudad = s.id_ciudad
    WHERE p.id_partido = @id_partido;

    IF @v_id_sede IS NULL
        SET @v_errores += 'partido inexistente o sede sin ciudad valida; ';

    SELECT
        @v_pais1 = MIN(sel.id_pais),
        @v_pais2 = MAX(sel.id_pais)
    FROM torneo.equipo_en_partido AS ep
    JOIN torneo.seleccion AS sel ON sel.id_seleccion = ep.id_seleccion
    WHERE ep.id_partido = @id_partido;

    IF @v_id_sede IS NOT NULL AND (@v_pais1 IS NULL OR @v_pais2 IS NULL)
        SET @v_errores += 'el partido no tiene sus dos selecciones registradas; ';

    SELECT @v_espacios = COUNT(*)
    FROM publicidad.espacio_publicitario AS e
    WHERE e.id_sede = @v_id_sede
      AND e.nro_espacio BETWEEN 1 AND 4;

    IF @v_id_sede IS NOT NULL AND ISNULL(@v_espacios, 0) <> 4
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'la sede debe tener exactamente los espacios publicitarios 1 a 4; ';
    END

    IF EXISTS (SELECT 1 FROM publicidad.exhibicion WHERE id_partido = @id_partido)
       AND ISNULL(@reemplazar, 0) = 0
    BEGIN
        SET @v_codigo = 50002;
        SET @v_errores += 'el partido ya tiene exhibiciones y reemplazar es 0; ';
    END

    SELECT TOP (1) @v_prime_desde = CONVERT(INT, pr.valor)
    FROM torneo.parametro_reglamento AS pr
    WHERE pr.clave = 'PRIME_DESDE_HORA'
      AND pr.vigente_desde <= CONVERT(DATE, @v_utc)
    ORDER BY pr.vigente_desde DESC;

    SELECT TOP (1) @v_prime_hasta = CONVERT(INT, pr.valor)
    FROM torneo.parametro_reglamento AS pr
    WHERE pr.clave = 'PRIME_HASTA_HORA'
      AND pr.vigente_desde <= CONVERT(DATE, @v_utc)
    ORDER BY pr.vigente_desde DESC;

    IF @v_id_sede IS NOT NULL AND (@v_prime_desde IS NULL OR @v_prime_hasta IS NULL)
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += 'faltan parametros vigentes de prime time; ';
    END

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('publicidad.usp_Negocio_AsignarPublicidad: ', @v_errores), 2048);
        THROW @v_codigo, @v_errores, 1;
    END

    IF OBJECT_ID('tempdb..#elegidas') IS NOT NULL DROP TABLE #elegidas;

    ;WITH candidatas AS
    (
        SELECT
            pz.id_pieza,
            t.id_tarifa,
            t.id_moneda,
            cot.cotizacion_usd,
            CONVERT(DECIMAL(18,2), ROUND(t.importe * cot.cotizacion_usd, 2)) AS importe_usd,
            CASE WHEN pz.id_pais_mercado IN (@v_pais1, @v_pais2) THEN 1 ELSE 0 END AS c1_equipo,
            pbi.valor AS c2_pbi,
            CASE WHEN DATEPART(HOUR, local_mercado.fecha_local) >= @v_prime_desde
                       AND DATEPART(HOUR, local_mercado.fecha_local) < @v_prime_hasta
                 THEN 1 ELSE 0 END AS c3_prime,
            ISNULL(ap.prioridad, 99) AS c4_prioridad
        FROM publicidad.pieza_publicitaria AS pz
        JOIN publicidad.campania AS c ON c.id_campania = pz.id_campania
        CROSS APPLY
        (
            SELECT geo.fn_FechaHoraLocal
            (
                @v_utc,
                ISNULL(geo.fn_HusoDePais(pz.id_pais_mercado), @v_huso_sede)
            ) AS fecha_local
        ) AS local_mercado
        JOIN publicidad.franja_horaria AS f
          ON CONVERT(TIME(0), local_mercado.fecha_local) >= f.hora_desde
         AND CONVERT(TIME(0), local_mercado.fecha_local) < f.hora_hasta
        JOIN publicidad.tarifa AS t ON t.id_franja = f.id_franja
        OUTER APPLY
        (
            SELECT TOP (1) tc.cotizacion_usd
            FROM publicidad.tipo_cambio AS tc
            WHERE tc.id_moneda = t.id_moneda
              AND tc.fecha <= CONVERT(DATE, @v_utc)
            ORDER BY tc.fecha DESC
        ) AS cot
        LEFT JOIN publicidad.anunciante_pais AS ap
          ON ap.id_anunciante = c.id_anunciante
         AND ap.id_pais = pz.id_pais_mercado
        OUTER APPLY
        (
            SELECT TOP (1) ip.valor
            FROM geo.indicador_pais AS ip
            WHERE ip.id_pais = ap.id_pais
              AND ip.codigo_indicador = 'NY.GDP.PCAP.CD'
            ORDER BY ip.anio DESC
        ) AS pbi
        WHERE CONVERT(DATE, @v_utc) BETWEEN c.fecha_desde AND c.fecha_hasta
          AND cot.cotizacion_usd IS NOT NULL
    ),
    mejor_tarifa AS
    (
        SELECT *, ROW_NUMBER() OVER
        (
            PARTITION BY id_pieza
            ORDER BY importe_usd DESC, id_tarifa
        ) AS rn_pieza
        FROM candidatas
    ),
    ranking AS
    (
        SELECT *, ROW_NUMBER() OVER
        (
            ORDER BY c1_equipo DESC,
                     ISNULL(c2_pbi, -1) DESC,
                     c3_prime DESC,
                     c4_prioridad ASC,
                     importe_usd DESC,
                     id_pieza
        ) AS orden
        FROM mejor_tarifa
        WHERE rn_pieza = 1
    )
    SELECT
        orden, id_pieza, id_tarifa, id_moneda, cotizacion_usd,
        importe_usd, c1_equipo, c2_pbi, c3_prime, c4_prioridad
    INTO #elegidas
    FROM ranking
    WHERE orden <= 4;

    SELECT @v_candidatas = COUNT(*) FROM #elegidas;

    IF @v_candidatas < 4
    BEGIN
        SET @v_errores = CONCAT
        (
            'publicidad.usp_Negocio_AsignarPublicidad: faltan ',
            4 - @v_candidatas,
            ' piezas candidatas para completar los cuatro espacios'
        );
        THROW 50003, @v_errores, 1;
    END

    BEGIN TRY
        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @v_propia = 1;
        END
        ELSE
        BEGIN
            SAVE TRANSACTION sv_asignar_publicidad;
            SET @v_sp = 1;
        END

        IF @reemplazar = 1
            DELETE FROM publicidad.exhibicion WHERE id_partido = @id_partido;

        INSERT INTO publicidad.exhibicion
        (
            id_partido, id_sede, nro_espacio, id_pieza, id_tarifa,
            fecha_hora_emision, orden_prioridad, importe_facturado,
            cotizacion_aplicada
        )
        SELECT
            @id_partido,
            @v_id_sede,
            CONVERT(TINYINT, e.orden),
            e.id_pieza,
            e.id_tarifa,
            @v_utc,
            CONVERT(TINYINT, e.orden),
            e.importe_usd,
            e.cotizacion_usd
        FROM #elegidas AS e;

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_asignar_publicidad;
        THROW;
    END CATCH

    SELECT
        orden, id_pieza, id_tarifa, importe_usd,
        cotizacion_usd AS cotizacion_aplicada,
        c1_equipo, c2_pbi, c3_prime, c4_prioridad
    FROM #elegidas
    ORDER BY orden;
END;
GO



CREATE OR ALTER PROCEDURE publicidad.usp_Negocio_SimularPrimeTime
    @id_partido INT,
    @fecha_hora_utc_alternativa DATETIME2(0) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_fecha DATETIME2(0);
    DECLARE @v_fecha_partido DATETIME2(0);
    DECLARE @v_prime_desde INT;
    DECLARE @v_prime_hasta INT;

    SELECT @v_fecha_partido = p.fecha_hora_utc
    FROM torneo.partido AS p
    WHERE p.id_partido = @id_partido;

    IF @v_fecha_partido IS NULL
        THROW 50001, 'publicidad.usp_Negocio_SimularPrimeTime: partido inexistente', 1;

    SET @v_fecha = ISNULL(@fecha_hora_utc_alternativa, @v_fecha_partido);

    SELECT TOP (1) @v_prime_desde = CONVERT(INT, pr.valor)
    FROM torneo.parametro_reglamento AS pr
    WHERE pr.clave = 'PRIME_DESDE_HORA'
      AND pr.vigente_desde <= CONVERT(DATE, @v_fecha)
    ORDER BY pr.vigente_desde DESC;

    SELECT TOP (1) @v_prime_hasta = CONVERT(INT, pr.valor)
    FROM torneo.parametro_reglamento AS pr
    WHERE pr.clave = 'PRIME_HASTA_HORA'
      AND pr.vigente_desde <= CONVERT(DATE, @v_fecha)
    ORDER BY pr.vigente_desde DESC;

    IF @v_prime_desde IS NULL OR @v_prime_hasta IS NULL
        THROW 50003, 'publicidad.usp_Negocio_SimularPrimeTime: faltan parametros vigentes de prime time', 1;

    SELECT
        pa.id_pais,
        pa.nombre AS pais_mercado,
        ciudad.nombre AS ciudad_referencia,
        h.offset_utc,
        h.horario_verano,
        local.fecha_local AS hora_local_mercado,
        CONVERT
        (
            BIT,
            CASE WHEN DATEPART(HOUR, local.fecha_local) >= @v_prime_desde
                       AND DATEPART(HOUR, local.fecha_local) < @v_prime_hasta
                 THEN 1 ELSE 0 END
        ) AS es_prime_time
    FROM geo.pais AS pa
    CROSS APPLY
    (
        SELECT TOP (1) c.id_ciudad, c.nombre, c.id_huso
        FROM geo.ciudad AS c
        WHERE c.id_pais = pa.id_pais
        ORDER BY c.poblacion DESC, c.id_ciudad
    ) AS ciudad
    JOIN geo.huso_horario AS h ON h.id_huso = ciudad.id_huso
    CROSS APPLY
    (
        SELECT geo.fn_FechaHoraLocal(@v_fecha, ciudad.id_huso) AS fecha_local
    ) AS local
    ORDER BY pa.nombre;
END;
GO
