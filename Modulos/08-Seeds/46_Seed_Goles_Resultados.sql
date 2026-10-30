/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-26
Objetivo: Entrega 7. Carga complementaria de goles y cierre de partidos de la
          fase de grupos, para que los reportes de goleadores y resultados
          tengan datos. Usa juego.usp_Negocio_RegistrarGol y
          torneo.usp_Negocio_CerrarPartido (no inserta en tablas directamente).
          Es idempotente: si ya existen goles no hace nada.
          Debe ejecutarse despues de 42, 43, 44 y 45.
          Los dos ultimos partidos (por fecha) quedan PROGRAMADOS sin goles.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

DECLARE @v_errores NVARCHAR(2000) = N'';

IF OBJECT_ID(N'juego.usp_Negocio_RegistrarGol', N'P') IS NULL
    SET @v_errores += N'no existe juego.usp_Negocio_RegistrarGol; ';

IF OBJECT_ID(N'torneo.usp_Negocio_CerrarPartido', N'P') IS NULL
    SET @v_errores += N'no existe torneo.usp_Negocio_CerrarPartido; ';

IF @v_errores <> N''
BEGIN
    SET @v_errores = LEFT(CONCAT(N'46_Seed_Goles_Resultados: ', @v_errores), 2048);
    THROW 50001, @v_errores, 1;
END;

IF EXISTS (SELECT 1 FROM juego.gol)
BEGIN
    PRINT N'Ya existen goles registrados: no se agregan datos (seed idempotente).';
    RETURN;
END;

DECLARE @v_total INT;
DECLARE @v_ord INT = 0;
DECLARE @v_id_partido INT;
DECLARE @v_capacidad INT;
DECLARE @v_local INT;
DECLARE @v_visitante INT;
DECLARE @v_lado INT;
DECLARE @v_team INT;
DECLARE @v_cant_goles INT;
DECLARE @v_k INT;
DECLARE @v_autor INT;
DECLARE @v_asist INT;
DECLARE @v_min SMALLINT;
DECLARE @v_periodo VARCHAR(5);
DECLARE @v_tipo VARCHAR(15);
DECLARE @v_nro TINYINT;
DECLARE @v_asistencia INT;
DECLARE @v_goles_ok INT = 0;
DECLARE @v_cerrados INT = 0;
DECLARE @v_fallidos INT = 0;

-- Partidos de grupos con ambas alineaciones y arbitro PRINCIPAL designado
SELECT @v_total = COUNT(*)
FROM torneo.partido AS p
WHERE p.nro_fase = 1
  AND p.estado = 'PROGRAMADO'
  AND (SELECT COUNT(DISTINCT a.id_seleccion) FROM juego.alineacion AS a
       WHERE a.id_partido = p.id_partido) = 2
  AND EXISTS
      (
          SELECT 1
          FROM arbitraje.designacion_arbitral AS da
          JOIN arbitraje.rol_arbitral AS ra ON ra.id_rol = da.id_rol
          WHERE da.id_partido = p.id_partido
            AND da.estado = 'DESIGNADA'
            AND ra.descripcion = N'PRINCIPAL'
      );

PRINT CONCAT(N'Partidos aptos para cargar resultado: ', @v_total);

DECLARE c_partidos CURSOR LOCAL FAST_FORWARD FOR
    SELECT p.id_partido, s.capacidad
    FROM torneo.partido AS p
    JOIN torneo.sede AS s ON s.id_sede = p.id_sede
    WHERE p.nro_fase = 1
      AND p.estado = 'PROGRAMADO'
      AND (SELECT COUNT(DISTINCT a.id_seleccion) FROM juego.alineacion AS a
           WHERE a.id_partido = p.id_partido) = 2
      AND EXISTS
          (
              SELECT 1
              FROM arbitraje.designacion_arbitral AS da
              JOIN arbitraje.rol_arbitral AS ra ON ra.id_rol = da.id_rol
              WHERE da.id_partido = p.id_partido
                AND da.estado = 'DESIGNADA'
                AND ra.descripcion = N'PRINCIPAL'
          )
    ORDER BY p.fecha_hora_utc, p.id_partido;

OPEN c_partidos;
FETCH NEXT FROM c_partidos INTO @v_id_partido, @v_capacidad;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @v_ord += 1;

    -- Los dos ultimos partidos quedan sin jugar
    IF @v_ord <= @v_total - 2
    BEGIN
        BEGIN TRY
            SET @v_local = NULL;
            SET @v_visitante = NULL;

            SELECT
                @v_local = MAX(CASE WHEN ep.condicion = 'L' THEN ep.id_seleccion END),
                @v_visitante = MAX(CASE WHEN ep.condicion = 'V' THEN ep.id_seleccion END)
            FROM torneo.equipo_en_partido AS ep
            WHERE ep.id_partido = @v_id_partido;

            SET @v_lado = 1;
            WHILE @v_lado <= 2
            BEGIN
                SET @v_team = CASE WHEN @v_lado = 1 THEN @v_local ELSE @v_visitante END;
                -- Resultado deterministico y variado (0 a 3 goles por equipo)
                SET @v_cant_goles = CASE WHEN @v_lado = 1 THEN @v_ord % 4
                                         ELSE (@v_ord / 2) % 3 END;
                SET @v_k = 1;

                WHILE @v_k <= @v_cant_goles
                BEGIN
                    SET @v_autor = NULL;
                    SET @v_asist = NULL;

                    -- Titulares no arqueros que juegan todo el partido
                    -- (sin cambio de salida ni roja), asi estan en cancha en cualquier minuto
                    ;WITH cand AS
                    (
                        SELECT
                            a.id_jugador,
                            ROW_NUMBER() OVER (ORDER BY a.dorsal DESC) AS rn
                        FROM juego.alineacion AS a
                        JOIN persona.posicion AS po ON po.id_posicion = a.id_posicion
                        WHERE a.id_partido = @v_id_partido
                          AND a.id_seleccion = @v_team
                          AND a.es_titular = 1
                          AND po.descripcion <> N'Arquero'
                          AND NOT EXISTS
                              (
                                  SELECT 1 FROM juego.sustitucion AS su
                                  WHERE su.id_partido = a.id_partido
                                    AND su.id_seleccion = a.id_seleccion
                                    AND su.id_jugador_sale = a.id_jugador
                              )
                          AND NOT EXISTS
                              (
                                  SELECT 1
                                  FROM juego.tarjeta AS t
                                  JOIN juego.tipo_tarjeta AS tt ON tt.id_tipo = t.id_tipo
                                  WHERE t.id_partido = a.id_partido
                                    AND t.id_seleccion = a.id_seleccion
                                    AND t.id_jugador = a.id_jugador
                                    AND tt.descripcion IN (N'ROJA_DIRECTA', N'ROJA_DOBLE_AMARILLA')
                              )
                    )
                    SELECT
                        @v_autor = MAX(CASE WHEN rn = ((@v_k + @v_ord) % 3) + 1 THEN id_jugador END),
                        @v_asist = MAX(CASE WHEN rn = ((@v_k + @v_ord + 1) % 3) + 1 THEN id_jugador END)
                    FROM cand;

                    IF @v_autor IS NOT NULL
                    BEGIN
                        SET @v_min = CONVERT(SMALLINT, 9 + (@v_k * 23) + (@v_ord % 11));
                        SET @v_periodo = CASE WHEN @v_min <= 45 THEN 'PT' ELSE 'ST' END;
                        SET @v_tipo = CHOOSE((@v_ord + @v_k) % 6 + 1,
                                             'JUGADA', 'PENAL', 'TIRO LIBRE',
                                             'CABEZA', 'CORNER', 'REBOTE');
                        IF @v_tipo = 'PENAL' SET @v_asist = NULL;

                        EXEC juego.usp_Negocio_RegistrarGol
                            @id_partido = @v_id_partido,
                            @id_seleccion = @v_team,
                            @id_jugador_autor = @v_autor,
                            @id_jugador_asistente = @v_asist,
                            @minuto = @v_min,
                            @tipo_gol = @v_tipo,
                            @en_contra = 0,
                            @periodo = @v_periodo,
                            @nro_gol = @v_nro OUTPUT;

                        SET @v_goles_ok += 1;
                    END;

                    SET @v_k += 1;
                END;

                SET @v_lado += 1;
            END;

            -- Asistencia: 85% de la capacidad de la sede
            SET @v_asistencia = CONVERT(INT, @v_capacidad * 0.85);

            EXEC torneo.usp_Negocio_CerrarPartido
                @id_partido = @v_id_partido,
                @asistencia_publico = @v_asistencia,
                @definido_por_penales = 0;

            SET @v_cerrados += 1;
        END TRY
        BEGIN CATCH
            SET @v_fallidos += 1;
            PRINT CONCAT(N'Aviso: partido ', @v_id_partido, N' no se pudo completar. ',
                         ERROR_MESSAGE());
        END CATCH;
    END;

    FETCH NEXT FROM c_partidos INTO @v_id_partido, @v_capacidad;
END;

CLOSE c_partidos;
DEALLOCATE c_partidos;

PRINT CONCAT(N'Goles registrados: ', @v_goles_ok,
             N' | Partidos cerrados: ', @v_cerrados,
             N' | Partidos con error: ', @v_fallidos);

SELECT
    (SELECT COUNT(*) FROM juego.gol) AS goles_en_base,
    (SELECT COUNT(*) FROM torneo.partido WHERE estado = 'FINALIZADO') AS partidos_finalizados,
    (SELECT COUNT(*) FROM torneo.partido WHERE estado = 'PROGRAMADO') AS partidos_programados;
GO
