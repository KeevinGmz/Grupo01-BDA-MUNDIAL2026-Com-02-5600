/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-23
Objetivo: Entrega 9. Consultas que completan el alcance (modulos A y C):
          fixture filtrable por sede, fase, seleccion y fecha, e historial de
          titularidad de cada jugador. Agrega 2 vistas y 2 SP; no modifica
          tablas. Las vistas tambien las usa la plataforma BI.
===================================================================== */
USE Mundial2026;
GO


/* ---------------------------------------------------------------------
   1. VISTA torneo.vw_Fixture
   Todos los partidos del torneo con fecha UTC y fecha local de la sede,
   sede, fase, equipos y resultado. Sirve de base para el SP de fixture y
   para la plataforma BI. Los partidos sin equipos definidos (eliminacion
   directa) muestran 'A definir'.
   --------------------------------------------------------------------- */
CREATE OR ALTER VIEW torneo.vw_Fixture
AS
SELECT
    p.id_partido,
    p.nro_fase,
    f.nombre AS fase,
    p.fecha_hora_utc,
    geo.fn_FechaHoraLocal(p.fecha_hora_utc, ci.id_huso) AS fecha_hora_local_sede,
    CONVERT(DATE, geo.fn_FechaHoraLocal(p.fecha_hora_utc, ci.id_huso)) AS fecha_local_sede,
    se.id_sede,
    se.nombre_estadio AS sede,
    ci.nombre AS ciudad,
    pc.nombre AS pais_sede,
    hu.zona_horaria AS huso_horario,
    mp.id_local AS id_seleccion_local,
    ISNULL(pl.nombre, 'A definir') AS local,
    mp.id_visitante AS id_seleccion_visitante,
    ISNULL(pv.nombre, 'A definir') AS visitante,
    p.estado,
    mp.goles_local,
    mp.goles_visitante,
    CASE WHEN p.estado = 'PROGRAMADO' THEN NULL
         ELSE CONCAT(mp.goles_local, ' - ', mp.goles_visitante) END AS marcador,
    p.asistencia_publico
FROM torneo.partido AS p
JOIN torneo.fase AS f ON f.nro_fase = p.nro_fase
JOIN torneo.sede AS se ON se.id_sede = p.id_sede
JOIN geo.ciudad AS ci ON ci.id_ciudad = se.id_ciudad
JOIN geo.pais AS pc ON pc.id_pais = ci.id_pais
JOIN geo.huso_horario AS hu ON hu.id_huso = ci.id_huso
JOIN juego.vw_MarcadorPartido AS mp ON mp.id_partido = p.id_partido
LEFT JOIN torneo.seleccion AS sl ON sl.id_seleccion = mp.id_local
LEFT JOIN geo.pais AS pl ON pl.id_pais = sl.id_pais
LEFT JOIN torneo.seleccion AS sv ON sv.id_seleccion = mp.id_visitante
LEFT JOIN geo.pais AS pv ON pv.id_pais = sv.id_pais;
GO

/* ---------------------------------------------------------------------
   2. SP reporte.usp_Fixture
   Fixture completo filtrable por sede, fase, seleccion y rango de fechas.
   Las fechas se interpretan como fecha LOCAL de la sede (la que ve el
   publico). Todos los filtros son opcionales. @formato: TABLA o XML.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE reporte.usp_Fixture
    @id_sede INT = NULL,
    @nro_fase TINYINT = NULL,
    @id_seleccion INT = NULL,
    @fecha_desde DATE = NULL,
    @fecha_hasta DATE = NULL,
    @formato VARCHAR(5) = 'TABLA'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_errores VARCHAR(2000) = '';

    IF @formato IS NULL OR @formato NOT IN ('TABLA', 'XML')
        SET @v_errores += 'formato invalido (debe ser TABLA o XML); ';

    IF @id_sede IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.sede WHERE id_sede = @id_sede)
        SET @v_errores += 'sede inexistente; ';

    IF @nro_fase IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.fase WHERE nro_fase = @nro_fase)
        SET @v_errores += 'fase inexistente; ';

    IF @id_seleccion IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_seleccion = @id_seleccion)
        SET @v_errores += 'seleccion inexistente; ';

    IF @fecha_desde IS NOT NULL AND @fecha_hasta IS NOT NULL AND @fecha_desde > @fecha_hasta
        SET @v_errores += 'fecha_desde no puede ser posterior a fecha_hasta; ';

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('reporte.usp_Fixture: ', @v_errores), 2048);
        THROW 50001, @v_errores, 1;
    END

    SELECT
        fx.id_partido,
        fx.fase,
        fx.fecha_hora_utc,
        fx.fecha_hora_local_sede,
        fx.sede,
        fx.ciudad,
        fx.pais_sede,
        fx.huso_horario,
        fx.local,
        fx.visitante,
        fx.estado,
        fx.marcador,
        fx.asistencia_publico
    INTO #fix
    FROM torneo.vw_Fixture AS fx
    WHERE (@id_sede IS NULL OR fx.id_sede = @id_sede)
      AND (@nro_fase IS NULL OR fx.nro_fase = @nro_fase)
      AND (@id_seleccion IS NULL
           OR fx.id_seleccion_local = @id_seleccion
           OR fx.id_seleccion_visitante = @id_seleccion)
      AND (@fecha_desde IS NULL OR fx.fecha_local_sede >= @fecha_desde)
      AND (@fecha_hasta IS NULL OR fx.fecha_local_sede <= @fecha_hasta);

    IF @formato = 'TABLA'
    BEGIN
        SELECT *
        FROM #fix
        ORDER BY fecha_hora_utc, id_partido;
    END
    ELSE
    BEGIN
        SELECT
            id_partido AS '@id_partido',
            fase AS '@fase',
            fecha_hora_utc AS '@fecha_utc',
            fecha_hora_local_sede AS '@fecha_local',
            sede AS '@sede',
            ciudad AS '@ciudad',
            estado AS '@estado',
            local AS 'equipos/@local',
            visitante AS 'equipos/@visitante',
            marcador AS 'resultado/@marcador'
        FROM #fix
        ORDER BY fecha_hora_utc, id_partido
        FOR XML PATH('partido'), ROOT('fixture');
    END
END;
GO

/* ---------------------------------------------------------------------
   3. VISTA juego.vw_HistorialTitularidad
   Una fila por jugador y partido en que integro la lista del partido.
   rol_en_partido: TITULAR, INGRESO (empezo en el banco y entro por un
   cambio) o BANCO (quedo en el banco sin ingresar).
   --------------------------------------------------------------------- */
CREATE OR ALTER VIEW juego.vw_HistorialTitularidad
AS
SELECT
    a.id_jugador,
    pe.apellido,
    pe.nombre,
    a.id_seleccion,
    ps.nombre AS seleccion,
    a.id_partido,
    p.nro_fase,
    f.nombre AS fase,
    p.fecha_hora_utc,
    ev.id_seleccion AS id_seleccion_rival,
    ISNULL(pr.nombre, 'A definir') AS rival,
    CASE
        WHEN a.es_titular = 1 THEN 'TITULAR'
        WHEN EXISTS (SELECT 1
                     FROM juego.sustitucion AS su
                     WHERE su.id_partido = a.id_partido
                       AND su.id_seleccion = a.id_seleccion
                       AND su.id_jugador_entra = a.id_jugador) THEN 'INGRESO'
        ELSE 'BANCO'
    END AS rol_en_partido,
    a.dorsal,
    po.descripcion AS posicion,
    a.es_posicion_habitual
FROM juego.alineacion AS a
JOIN persona.persona AS pe ON pe.id_persona = a.id_jugador
JOIN torneo.seleccion AS s ON s.id_seleccion = a.id_seleccion
JOIN geo.pais AS ps ON ps.id_pais = s.id_pais
JOIN torneo.partido AS p ON p.id_partido = a.id_partido
JOIN torneo.fase AS f ON f.nro_fase = p.nro_fase
JOIN persona.posicion AS po ON po.id_posicion = a.id_posicion
LEFT JOIN torneo.equipo_en_partido AS ev
       ON ev.id_partido = a.id_partido AND ev.id_seleccion <> a.id_seleccion
LEFT JOIN torneo.seleccion AS sr ON sr.id_seleccion = ev.id_seleccion
LEFT JOIN geo.pais AS pr ON pr.id_pais = sr.id_pais;
GO

/* ---------------------------------------------------------------------
   4. SP reporte.usp_HistorialTitularidad
   Historial de titularidad a lo largo del torneo. Sin parametros muestra
   todos los jugadores; se puede filtrar por jugador y/o seleccion.
   Devuelve 2 resultados: (1) resumen por jugador y (2) detalle por partido.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE reporte.usp_HistorialTitularidad
    @id_jugador INT = NULL,
    @id_seleccion INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_errores VARCHAR(2000) = '';

    IF @id_jugador IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM persona.jugador WHERE id_persona = @id_jugador)
        SET @v_errores += 'jugador inexistente; ';

    IF @id_seleccion IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM torneo.seleccion WHERE id_seleccion = @id_seleccion)
        SET @v_errores += 'seleccion inexistente; ';

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('reporte.usp_HistorialTitularidad: ', @v_errores), 2048);
        THROW 50001, @v_errores, 1;
    END

    SELECT *
    INTO #hist
    FROM juego.vw_HistorialTitularidad
    WHERE (@id_jugador IS NULL OR id_jugador = @id_jugador)
      AND (@id_seleccion IS NULL OR id_seleccion = @id_seleccion);

    -- 1) Resumen por jugador
    SELECT
        CONCAT(apellido, ', ', nombre) AS jugador,
        seleccion,
        SUM(CASE WHEN rol_en_partido = 'TITULAR' THEN 1 ELSE 0 END) AS partidos_titular,
        SUM(CASE WHEN rol_en_partido = 'INGRESO' THEN 1 ELSE 0 END) AS partidos_ingreso_desde_banco,
        SUM(CASE WHEN rol_en_partido = 'BANCO' THEN 1 ELSE 0 END) AS partidos_en_banco_sin_ingresar,
        COUNT(*) AS partidos_en_lista
    FROM #hist
    GROUP BY id_jugador, apellido, nombre, seleccion
    ORDER BY partidos_titular DESC, jugador;

    -- 2) Detalle partido por partido
    SELECT
        CONCAT(apellido, ', ', nombre) AS jugador,
        seleccion,
        id_partido,
        fase,
        fecha_hora_utc,
        rival,
        rol_en_partido,
        dorsal,
        posicion,
        es_posicion_habitual
    FROM #hist
    ORDER BY jugador, fecha_hora_utc, id_partido;
END;
GO
