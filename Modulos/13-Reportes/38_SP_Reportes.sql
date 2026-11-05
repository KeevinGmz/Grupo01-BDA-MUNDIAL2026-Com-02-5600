/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-26
Objetivo: Entrega 7. Crea el esquema reporte y los procedimientos almacenados
          de reportes (solo lectura): goleadores, tarjetas y suspensiones,
          designaciones arbitrales, ocupacion publicitaria, matriz de prime
          time, selecciones con plantillas (XML) y resultados.
          Reportes con salida XML: usp_SeleccionesPlantillas (siempre),
          usp_Goleadores y usp_Resultados (parametro @formato = 'XML').
===================================================================== */
USE Mundial2026;
GO

IF SCHEMA_ID('reporte') IS NULL
BEGIN
    EXEC ('CREATE SCHEMA reporte');
    PRINT 'Esquema reporte CREADO correctamente';
END
ELSE
BEGIN
    PRINT 'El esquema reporte ya existe';
END;
GO

/* ---------------------------------------------------------------------
   1. GOLEADORES por torneo, por seleccion y por fase
   Criterio: no se cuentan goles en contra ni los de la definicion por
   penales (mismo criterio que la vista juego.vw_Goleadores).
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE reporte.usp_Goleadores
    @id_seleccion INT = NULL,
    @nro_fase TINYINT = NULL,
    @formato VARCHAR(5) = 'TABLA'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_errores VARCHAR(2000) = '';

    IF @formato IS NULL OR @formato NOT IN ('TABLA', 'XML')
        SET @v_errores += 'formato invalido (debe ser TABLA o XML); ';

    IF @id_seleccion IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_seleccion = @id_seleccion)
        SET @v_errores += 'seleccion inexistente; ';

    IF @nro_fase IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.fase WHERE nro_fase = @nro_fase)
        SET @v_errores += 'fase inexistente; ';

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('reporte.usp_Goleadores: ', @v_errores), 2048);
        THROW 50001, @v_errores, 1;
    END

    -- Goles validos del filtro pedido
    SELECT
        g.id_partido,
        g.id_seleccion,
        p.nro_fase,
        g.id_jugador_autor AS id_jugador,
        g.id_jugador_asistente AS id_asistente
    INTO #goles
    FROM juego.gol AS g
    JOIN torneo.partido AS p
      ON p.id_partido = g.id_partido
    WHERE g.en_contra = 0
      AND g.periodo <> 'PEN'
      AND (@id_seleccion IS NULL OR g.id_seleccion = @id_seleccion)
      AND (@nro_fase IS NULL OR p.nro_fase = @nro_fase);

    -- Tabla de goleadores del torneo (con empates en la misma posicion)
    SELECT
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS posicion,
        x.id_jugador,
        CONCAT(pe.apellido, ', ', pe.nombre) AS jugador,
        pa.nombre AS seleccion,
        COUNT(*) AS goles,
        COUNT(DISTINCT x.id_partido) AS partidos_con_gol,
        (SELECT COUNT(*) FROM #goles AS a WHERE a.id_asistente = x.id_jugador) AS asistencias
    INTO #top
    FROM #goles AS x
    JOIN persona.persona AS pe ON pe.id_persona = x.id_jugador
    JOIN torneo.seleccion AS s ON s.id_seleccion = x.id_seleccion
    JOIN geo.pais AS pa ON pa.id_pais = s.id_pais
    GROUP BY x.id_jugador, pe.apellido, pe.nombre, pa.nombre;

    -- Goles por seleccion
    SELECT
        pa.nombre AS seleccion,
        COUNT(*) AS goles,
        COUNT(DISTINCT x.id_jugador) AS goleadores_distintos
    INTO #porsel
    FROM #goles AS x
    JOIN torneo.seleccion AS s ON s.id_seleccion = x.id_seleccion
    JOIN geo.pais AS pa ON pa.id_pais = s.id_pais
    GROUP BY pa.nombre;

    -- Goles por fase
    SELECT
        f.nro_fase,
        f.nombre AS fase,
        COUNT(*) AS goles
    INTO #porfase
    FROM #goles AS x
    JOIN torneo.fase AS f ON f.nro_fase = x.nro_fase
    GROUP BY f.nro_fase, f.nombre;

    IF @formato = 'TABLA'
    BEGIN
        SELECT posicion, jugador, seleccion, goles, partidos_con_gol, asistencias
        FROM #top
        ORDER BY posicion, jugador;

        SELECT seleccion, goles, goleadores_distintos
        FROM #porsel
        ORDER BY goles DESC, seleccion;

        SELECT nro_fase, fase, goles
        FROM #porfase
        ORDER BY nro_fase;
    END
    ELSE
    BEGIN
        SELECT
            (
                SELECT posicion AS '@posicion', jugador AS '@jugador',
                       seleccion AS '@seleccion', goles AS '@goles',
                       asistencias AS '@asistencias'
                FROM #top
                ORDER BY posicion, jugador
                FOR XML PATH('goleador'), ROOT('torneo'), TYPE
            ),
            (
                SELECT seleccion AS '@seleccion', goles AS '@goles'
                FROM #porsel
                ORDER BY goles DESC, seleccion
                FOR XML PATH('seleccion'), ROOT('porSeleccion'), TYPE
            ),
            (
                SELECT nro_fase AS '@nro', fase AS '@fase', goles AS '@goles'
                FROM #porfase
                ORDER BY nro_fase
                FOR XML PATH('fase'), ROOT('porFase'), TYPE
            )
        FOR XML PATH('goleadores');
    END
END;
GO

/* ---------------------------------------------------------------------
   2. TARJETAS por seleccion y por jugador + suspensiones
   Suspension "activa" = estado PENDIENTE. El origen se deduce del tipo de
   tarjeta del criterio: AMARILLA = acumulacion, resto = expulsion.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE reporte.usp_Tarjetas
    @id_seleccion INT = NULL,
    @solo_activas BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_errores VARCHAR(2000) = '';

    IF @id_seleccion IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_seleccion = @id_seleccion)
        SET @v_errores += 'seleccion inexistente; ';

    IF @solo_activas IS NULL
        SET @v_errores += 'solo_activas obligatorio (0 o 1); ';

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('reporte.usp_Tarjetas: ', @v_errores), 2048);
        THROW 50001, @v_errores, 1;
    END

    -- 1) Por seleccion
    SELECT
        pa.nombre AS seleccion,
        SUM(CASE WHEN tt.descripcion = 'AMARILLA' THEN 1 ELSE 0 END) AS amarillas,
        SUM(CASE WHEN tt.descripcion = 'ROJA_DOBLE_AMARILLA' THEN 1 ELSE 0 END) AS rojas_doble_amarilla,
        SUM(CASE WHEN tt.descripcion = 'ROJA_DIRECTA' THEN 1 ELSE 0 END) AS rojas_directas,
        COUNT(*) AS total_tarjetas
    FROM juego.tarjeta AS t
    JOIN juego.tipo_tarjeta AS tt ON tt.id_tipo = t.id_tipo
    JOIN torneo.seleccion AS s ON s.id_seleccion = t.id_seleccion
    JOIN geo.pais AS pa ON pa.id_pais = s.id_pais
    WHERE @id_seleccion IS NULL OR t.id_seleccion = @id_seleccion
    GROUP BY pa.nombre
    ORDER BY total_tarjetas DESC, seleccion;

    -- 2) Por jugador
    SELECT
        pa.nombre AS seleccion,
        CONCAT(pe.apellido, ', ', pe.nombre) AS jugador,
        c.dorsal,
        SUM(CASE WHEN tt.descripcion = 'AMARILLA' THEN 1 ELSE 0 END) AS amarillas,
        SUM(CASE WHEN tt.descripcion <> 'AMARILLA' THEN 1 ELSE 0 END) AS rojas,
        CASE WHEN EXISTS
             (
                 SELECT 1 FROM juego.suspension AS su
                 WHERE su.id_jugador = t.id_jugador AND su.estado = 'PENDIENTE'
             )
             THEN 'SI' ELSE 'NO' END AS suspension_activa
    FROM juego.tarjeta AS t
    JOIN juego.tipo_tarjeta AS tt ON tt.id_tipo = t.id_tipo
    JOIN persona.persona AS pe ON pe.id_persona = t.id_jugador
    JOIN torneo.seleccion AS s ON s.id_seleccion = t.id_seleccion
    JOIN geo.pais AS pa ON pa.id_pais = s.id_pais
    LEFT JOIN torneo.convocatoria AS c
           ON c.id_seleccion = t.id_seleccion AND c.id_jugador = t.id_jugador
    WHERE @id_seleccion IS NULL OR t.id_seleccion = @id_seleccion
    GROUP BY pa.nombre, pe.apellido, pe.nombre, c.dorsal, t.id_jugador
    ORDER BY seleccion, amarillas DESC, rojas DESC, jugador;

    -- 3) Suspensiones (activas por defecto)
    SELECT
        su.id_suspension,
        CONCAT(pe.apellido, ', ', pe.nombre) AS jugador,
        pa.nombre AS seleccion,
        CASE WHEN tt.descripcion = 'AMARILLA'
             THEN 'ACUMULACION' ELSE 'EXPULSION' END AS origen,
        tt.descripcion AS tipo_tarjeta_criterio,
        cs.cant_tarjetas_requeridas AS tarjetas_requeridas,
        su.cant_partidos AS partidos_suspension,
        cumplidos.cant AS partidos_cumplidos,
        CASE WHEN su.cant_partidos - cumplidos.cant > 0
             THEN su.cant_partidos - cumplidos.cant ELSE 0 END AS partidos_pendientes,
        su.estado,
        su.fecha_alta,
        su.motivo
    FROM juego.suspension AS su
    JOIN juego.criterio_suspension AS cs ON cs.id_criterio = su.id_criterio
    JOIN juego.tipo_tarjeta AS tt ON tt.id_tipo = cs.id_tipo
    JOIN persona.persona AS pe ON pe.id_persona = su.id_jugador
    LEFT JOIN torneo.convocatoria AS c ON c.id_jugador = su.id_jugador
    LEFT JOIN torneo.seleccion AS s ON s.id_seleccion = c.id_seleccion
    LEFT JOIN geo.pais AS pa ON pa.id_pais = s.id_pais
    CROSS APPLY
    (
        SELECT COUNT(*) AS cant
        FROM juego.suspension_partido AS sp
        WHERE sp.id_suspension = su.id_suspension
    ) AS cumplidos
    WHERE (@solo_activas = 0 OR su.estado = 'PENDIENTE')
      AND (@id_seleccion IS NULL OR c.id_seleccion = @id_seleccion)
    ORDER BY su.estado, su.fecha_alta, jugador;
END;
GO

/* ---------------------------------------------------------------------
   3. DESIGNACIONES ARBITRALES
   Nota: arbitraje.informe_post_partido no tiene clave hacia partido ni
   arbitro en el modelo, por eso no puede asociarse a este reporte.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE reporte.usp_DesignacionesArbitrales
    @id_arbitro INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_errores VARCHAR(2000) = '';

    IF @id_arbitro IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM persona.arbitro WHERE id_persona = @id_arbitro)
        SET @v_errores += 'arbitro inexistente; ';

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('reporte.usp_DesignacionesArbitrales: ', @v_errores), 2048);
        THROW 50001, @v_errores, 1;
    END

    -- 1) Resumen por arbitro
    SELECT
        CONCAT(pe.apellido, ', ', pe.nombre) AS arbitro,
        pa.nombre AS pais,
        ca.descripcion AS categoria,
        ISNULL(d.designaciones, 0) AS designaciones,
        ISNULL(d.como_principal, 0) AS como_principal,
        ISNULL(tj.amarillas, 0) AS amarillas_mostradas,
        ISNULL(tj.rojas, 0) AS rojas_mostradas
    FROM persona.arbitro AS ar
    JOIN persona.persona AS pe ON pe.id_persona = ar.id_persona
    JOIN geo.pais AS pa ON pa.id_pais = pe.id_pais
    JOIN persona.categoria_arbitral AS ca ON ca.id_categoria = ar.id_categoria
    OUTER APPLY
    (
        SELECT COUNT(*) AS designaciones,
               SUM(CASE WHEN ra.descripcion = 'PRINCIPAL' THEN 1 ELSE 0 END) AS como_principal
        FROM arbitraje.designacion_arbitral AS da
        JOIN arbitraje.rol_arbitral AS ra ON ra.id_rol = da.id_rol
        WHERE da.id_arbitro = ar.id_persona AND da.estado = 'DESIGNADA'
    ) AS d
    OUTER APPLY
    (
        SELECT SUM(CASE WHEN tt.descripcion = 'AMARILLA' THEN 1 ELSE 0 END) AS amarillas,
               SUM(CASE WHEN tt.descripcion <> 'AMARILLA' THEN 1 ELSE 0 END) AS rojas
        FROM juego.tarjeta AS t
        JOIN juego.tipo_tarjeta AS tt ON tt.id_tipo = t.id_tipo
        WHERE t.id_arbitro = ar.id_persona
    ) AS tj
    WHERE @id_arbitro IS NULL OR ar.id_persona = @id_arbitro
    ORDER BY designaciones DESC, arbitro;

    -- 2) Partidos dirigidos (una fila por designacion)
    SELECT
        CONCAT(pe.apellido, ', ', pe.nombre) AS arbitro,
        ra.descripcion AS rol,
        da.id_partido,
        p.fecha_hora_utc,
        f.nombre AS fase,
        se.nombre_estadio AS sede,
        CONCAT(pl.nombre, ' vs ', pv.nombre) AS encuentro,
        da.estado AS estado_designacion,
        ISNULL(tj.amarillas, 0) AS amarillas_en_el_partido,
        ISNULL(tj.rojas, 0) AS rojas_en_el_partido
    FROM arbitraje.designacion_arbitral AS da
    JOIN arbitraje.rol_arbitral AS ra ON ra.id_rol = da.id_rol
    JOIN persona.persona AS pe ON pe.id_persona = da.id_arbitro
    JOIN torneo.partido AS p ON p.id_partido = da.id_partido
    JOIN torneo.fase AS f ON f.nro_fase = p.nro_fase
    JOIN torneo.sede AS se ON se.id_sede = p.id_sede
    LEFT JOIN torneo.equipo_en_partido AS el ON el.id_partido = p.id_partido AND el.condicion = 'L'
    LEFT JOIN torneo.seleccion AS sl ON sl.id_seleccion = el.id_seleccion
    LEFT JOIN geo.pais AS pl ON pl.id_pais = sl.id_pais
    LEFT JOIN torneo.equipo_en_partido AS ev ON ev.id_partido = p.id_partido AND ev.condicion = 'V'
    LEFT JOIN torneo.seleccion AS sv ON sv.id_seleccion = ev.id_seleccion
    LEFT JOIN geo.pais AS pv ON pv.id_pais = sv.id_pais
    OUTER APPLY
    (
        SELECT SUM(CASE WHEN tt.descripcion = 'AMARILLA' THEN 1 ELSE 0 END) AS amarillas,
               SUM(CASE WHEN tt.descripcion <> 'AMARILLA' THEN 1 ELSE 0 END) AS rojas
        FROM juego.tarjeta AS t
        JOIN juego.tipo_tarjeta AS tt ON tt.id_tipo = t.id_tipo
        WHERE t.id_partido = da.id_partido AND t.id_arbitro = da.id_arbitro
    ) AS tj
    WHERE @id_arbitro IS NULL OR da.id_arbitro = @id_arbitro
    ORDER BY arbitro, p.fecha_hora_utc, da.id_partido;

    -- 3) Detalle de amonestaciones y expulsiones senaladas por el arbitro
    SELECT
        CONCAT(pa_.apellido, ', ', pa_.nombre) AS arbitro,
        t.id_partido,
        t.minuto,
        tt.descripcion AS tarjeta,
        CONCAT(pj.apellido, ', ', pj.nombre) AS jugador,
        pais.nombre AS seleccion,
        t.motivo
    FROM juego.tarjeta AS t
    JOIN juego.tipo_tarjeta AS tt ON tt.id_tipo = t.id_tipo
    JOIN persona.persona AS pa_ ON pa_.id_persona = t.id_arbitro
    JOIN persona.persona AS pj ON pj.id_persona = t.id_jugador
    JOIN torneo.seleccion AS s ON s.id_seleccion = t.id_seleccion
    JOIN geo.pais AS pais ON pais.id_pais = s.id_pais
    WHERE @id_arbitro IS NULL OR t.id_arbitro = @id_arbitro
    ORDER BY arbitro, t.id_partido, t.minuto;
END;
GO

/* ---------------------------------------------------------------------
   4. OCUPACION PUBLICITARIA por sede y partido
   Cada partido dispone de 4 espacios (regla del enunciado). Los importes de
   publicidad.exhibicion ya estan expresados en USD.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE reporte.usp_OcupacionPublicitaria
    @id_sede INT = NULL,
    @id_partido INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_errores VARCHAR(2000) = '';

    IF @id_sede IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.sede WHERE id_sede = @id_sede)
        SET @v_errores += 'sede inexistente; ';

    IF @id_partido IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.partido WHERE id_partido = @id_partido)
        SET @v_errores += 'partido inexistente; ';

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('reporte.usp_OcupacionPublicitaria: ', @v_errores), 2048);
        THROW 50001, @v_errores, 1;
    END

    -- 1) Detalle: los espacios de cada partido
    SELECT
        se.nombre_estadio AS sede,
        ex.id_partido,
        p.fecha_hora_utc,
        ex.nro_espacio,
        an.razon_social AS anunciante,
        ca.nombre AS campania,
        pz.descripcion AS pieza,
        pm.nombre AS mercado,
        ex.orden_prioridad,
        ex.importe_facturado AS importe_usd
    FROM publicidad.exhibicion AS ex
    JOIN torneo.partido AS p ON p.id_partido = ex.id_partido
    JOIN torneo.sede AS se ON se.id_sede = ex.id_sede
    JOIN publicidad.pieza_publicitaria AS pz ON pz.id_pieza = ex.id_pieza
    JOIN publicidad.campania AS ca ON ca.id_campania = pz.id_campania
    JOIN publicidad.anunciante AS an ON an.id_anunciante = ca.id_anunciante
    LEFT JOIN geo.pais AS pm ON pm.id_pais = pz.id_pais_mercado
    WHERE (@id_sede IS NULL OR ex.id_sede = @id_sede)
      AND (@id_partido IS NULL OR ex.id_partido = @id_partido)
    ORDER BY se.nombre_estadio, p.fecha_hora_utc, ex.id_partido, ex.nro_espacio;

    -- 2) Resumen por sede
    SELECT
        se.nombre_estadio AS sede,
        COUNT(DISTINCT p.id_partido) AS partidos,
        COUNT(DISTINCT p.id_partido) * 4 AS espacios_disponibles,
        COUNT(ex.id_exhibicion) AS espacios_ocupados,
        CONVERT(DECIMAL(5,2),
                100.0 * COUNT(ex.id_exhibicion)
                / NULLIF(COUNT(DISTINCT p.id_partido) * 4, 0)) AS porcentaje_ocupacion,
        ISNULL(SUM(ex.importe_facturado), 0) AS ingresos_usd
    FROM torneo.sede AS se
    LEFT JOIN torneo.partido AS p
           ON p.id_sede = se.id_sede
          AND (@id_partido IS NULL OR p.id_partido = @id_partido)
    LEFT JOIN publicidad.exhibicion AS ex
           ON ex.id_partido = p.id_partido AND ex.id_sede = p.id_sede
    WHERE @id_sede IS NULL OR se.id_sede = @id_sede
    GROUP BY se.id_sede, se.nombre_estadio
    ORDER BY ingresos_usd DESC, sede;

    -- 3) Ingresos por anunciante
    SELECT
        an.razon_social AS anunciante,
        pa.nombre AS pais_anunciante,
        COUNT(*) AS exhibiciones,
        SUM(ex.importe_facturado) AS ingresos_usd
    FROM publicidad.exhibicion AS ex
    JOIN publicidad.pieza_publicitaria AS pz ON pz.id_pieza = ex.id_pieza
    JOIN publicidad.campania AS ca ON ca.id_campania = pz.id_campania
    JOIN publicidad.anunciante AS an ON an.id_anunciante = ca.id_anunciante
    JOIN geo.pais AS pa ON pa.id_pais = an.id_pais
    WHERE (@id_sede IS NULL OR ex.id_sede = @id_sede)
      AND (@id_partido IS NULL OR ex.id_partido = @id_partido)
    GROUP BY an.razon_social, pa.nombre
    ORDER BY ingresos_usd DESC, anunciante;
END;
GO

/* ---------------------------------------------------------------------
   5. MATRIZ DE PRIME TIME (pivot)
   Filas: partidos. Columnas: mercados (paises de interes de las piezas
   publicitarias). Valor: 1 si el horario del partido cae en prime time local
   del mercado, 0 si no. Usa publicidad.fn_EsPrimeTime.
   SQL dinamico justificado: las columnas del PIVOT dependen de los mercados
   cargados y no pueden fijarse de antemano. Los nombres pasan por QUOTENAME.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE reporte.usp_MatrizPrimeTime
    @id_partido INT = NULL,
    @fecha_desde DATE = NULL,
    @fecha_hasta DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_cols VARCHAR(MAX);
    DECLARE @v_sql NVARCHAR(MAX);

    IF @id_partido IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.partido WHERE id_partido = @id_partido)
        SET @v_errores += 'partido inexistente; ';

    IF @fecha_desde IS NOT NULL AND @fecha_hasta IS NOT NULL AND @fecha_desde > @fecha_hasta
        SET @v_errores += 'fecha_desde no puede ser posterior a fecha_hasta; ';

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('reporte.usp_MatrizPrimeTime: ', @v_errores), 2048);
        THROW 50001, @v_errores, 1;
    END

    SELECT DISTINCT pa.id_pais, pa.nombre AS mercado
    INTO #mercados
    FROM publicidad.pieza_publicitaria AS pz
    JOIN geo.pais AS pa ON pa.id_pais = pz.id_pais_mercado;

    IF NOT EXISTS (SELECT 1 FROM #mercados)
        THROW 50003, 'reporte.usp_MatrizPrimeTime: no hay mercados cargados (piezas con pais de mercado)', 1;

    SELECT
        p.id_partido,
        p.fecha_hora_utc,
        m.mercado,
        CONVERT(INT, publicidad.fn_EsPrimeTime(p.id_partido, m.id_pais)) AS es_prime
    INTO #matriz
    FROM torneo.partido AS p
    CROSS JOIN #mercados AS m
    WHERE (@id_partido IS NULL OR p.id_partido = @id_partido)
      AND (@fecha_desde IS NULL OR CONVERT(DATE, p.fecha_hora_utc) >= @fecha_desde)
      AND (@fecha_hasta IS NULL OR CONVERT(DATE, p.fecha_hora_utc) <= @fecha_hasta);

    SELECT @v_cols = STRING_AGG(CONVERT(VARCHAR(MAX), QUOTENAME(mercado)), ',')
                     WITHIN GROUP (ORDER BY mercado)
    FROM #mercados;

    SET @v_sql = '
    SELECT
        pv.id_partido,
        pv.fecha_hora_utc,
        pt.cant_prime AS mercados_en_prime_time,
        CASE WHEN pt.cant_prime > 4 THEN N''SI'' ELSE N''NO'' END AS requiere_priorizacion,
        ' + @v_cols + '
    FROM (SELECT id_partido, fecha_hora_utc, mercado, es_prime FROM #matriz) AS src
    PIVOT (MAX(es_prime) FOR mercado IN (' + @v_cols + ')) AS pv
    JOIN (SELECT id_partido, SUM(es_prime) AS cant_prime
          FROM #matriz GROUP BY id_partido) AS pt
      ON pt.id_partido = pv.id_partido
    ORDER BY pv.fecha_hora_utc, pv.id_partido;';

    EXEC sys.sp_executesql @v_sql;
END;
GO

/* ---------------------------------------------------------------------
   6. SELECCIONES Y PLANTILLAS (XML con vector anidado de convocados)
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE reporte.usp_SeleccionesPlantillas
    @id_seleccion INT = NULL,
    @incluir_bajas BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_errores VARCHAR(2000) = '';

    IF @id_seleccion IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_seleccion = @id_seleccion)
        SET @v_errores += 'seleccion inexistente; ';

    IF @incluir_bajas IS NULL
        SET @v_errores += 'incluir_bajas obligatorio (0 o 1); ';

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('reporte.usp_SeleccionesPlantillas: ', @v_errores), 2048);
        THROW 50001, @v_errores, 1;
    END

    SELECT
        s.id_seleccion AS '@id_seleccion',
        pa.nombre AS '@pais',
        co.sigla AS '@confederacion',
        s.id_letra AS '@grupo',
        (
            SELECT COUNT(*)
            FROM torneo.convocatoria AS c0
            WHERE c0.id_seleccion = s.id_seleccion
              AND (@incluir_bajas = 1 OR c0.estado = 'ACTIVO')
        ) AS '@cantidad_convocados',
        (
            SELECT
                c.dorsal AS '@dorsal',
                CONCAT(pe.apellido, ', ', pe.nombre) AS '@nombre',
                po.descripcion AS '@posicion',
                cl.nombre AS '@club',
                c.estado AS '@estado'
            FROM torneo.convocatoria AS c
            JOIN persona.persona AS pe ON pe.id_persona = c.id_jugador
            JOIN persona.jugador AS j ON j.id_persona = c.id_jugador
            JOIN persona.posicion AS po ON po.id_posicion = j.id_posicion_habitual
            LEFT JOIN persona.club AS cl ON cl.id_club = j.id_club
            WHERE c.id_seleccion = s.id_seleccion
              AND (@incluir_bajas = 1 OR c.estado = 'ACTIVO')
            ORDER BY c.dorsal
            FOR XML PATH('convocado'), ROOT('convocados'), TYPE
        )
    FROM torneo.seleccion AS s
    JOIN geo.pais AS pa ON pa.id_pais = s.id_pais
    JOIN geo.confederacion AS co ON co.id_confederacion = pa.id_confederacion
    WHERE @id_seleccion IS NULL OR s.id_seleccion = @id_seleccion
    ORDER BY pa.nombre
    FOR XML PATH('seleccion'), ROOT('selecciones');
END;
GO

/* ---------------------------------------------------------------------
   7. RESULTADOS de los encuentros (tabla o XML)
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE reporte.usp_Resultados
    @nro_fase TINYINT = NULL,
    @id_seleccion INT = NULL,
    @formato VARCHAR(5) = 'TABLA'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_errores VARCHAR(2000) = '';

    IF @formato IS NULL OR @formato NOT IN ('TABLA', 'XML')
        SET @v_errores += 'formato invalido (debe ser TABLA o XML); ';

    IF @nro_fase IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.fase WHERE nro_fase = @nro_fase)
        SET @v_errores += 'fase inexistente; ';

    IF @id_seleccion IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_seleccion = @id_seleccion)
        SET @v_errores += 'seleccion inexistente; ';

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('reporte.usp_Resultados: ', @v_errores), 2048);
        THROW 50001, @v_errores, 1;
    END

    SELECT
        p.id_partido,
        f.nombre AS fase,
        p.fecha_hora_utc,
        geo.fn_FechaHoraLocal(p.fecha_hora_utc, ci.id_huso) AS fecha_hora_local_sede,
        se.nombre_estadio AS sede,
        ci.nombre AS ciudad,
        pl.nombre AS local,
        pv.nombre AS visitante,
        CONCAT(mp.goles_local, ' - ', mp.goles_visitante) AS marcador,
        CASE WHEN p.definido_por_penales = 1
             THEN CONCAT(mp.penales_local, ' - ', mp.penales_visitante) END AS penales,
        CASE
            WHEN p.estado <> 'FINALIZADO' THEN '-'
            WHEN mp.goles_local > mp.goles_visitante THEN pl.nombre
            WHEN mp.goles_local < mp.goles_visitante THEN pv.nombre
            WHEN mp.penales_local > mp.penales_visitante THEN pl.nombre
            WHEN mp.penales_local < mp.penales_visitante THEN pv.nombre
            ELSE 'Empate'
        END AS ganador,
        p.estado,
        p.asistencia_publico
    INTO #res
    FROM juego.vw_MarcadorPartido AS mp
    JOIN torneo.partido AS p ON p.id_partido = mp.id_partido
    JOIN torneo.fase AS f ON f.nro_fase = p.nro_fase
    JOIN torneo.sede AS se ON se.id_sede = p.id_sede
    JOIN geo.ciudad AS ci ON ci.id_ciudad = se.id_ciudad
    LEFT JOIN torneo.seleccion AS sl ON sl.id_seleccion = mp.id_local
    LEFT JOIN geo.pais AS pl ON pl.id_pais = sl.id_pais
    LEFT JOIN torneo.seleccion AS sv ON sv.id_seleccion = mp.id_visitante
    LEFT JOIN geo.pais AS pv ON pv.id_pais = sv.id_pais
    WHERE (@nro_fase IS NULL OR p.nro_fase = @nro_fase)
      AND (@id_seleccion IS NULL
           OR mp.id_local = @id_seleccion
           OR mp.id_visitante = @id_seleccion);

    IF @formato = 'TABLA'
    BEGIN
        SELECT *
        FROM #res
        ORDER BY fecha_hora_utc, id_partido;
    END
    ELSE
    BEGIN
        SELECT
            id_partido AS '@id_partido',
            fase AS '@fase',
            fecha_hora_utc AS '@fecha_utc',
            sede AS '@sede',
            estado AS '@estado',
            asistencia_publico AS '@asistencia',
            local AS 'equipos/@local',
            visitante AS 'equipos/@visitante',
            marcador AS 'resultado/@marcador',
            penales AS 'resultado/@penales',
            ganador AS 'resultado/@ganador'
        FROM #res
        ORDER BY fecha_hora_utc, id_partido
        FOR XML PATH('partido'), ROOT('resultados');
    END
END;
GO
