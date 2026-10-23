/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comision: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Carga los catálogos base fijos, es re-ejecutable.
   ===================================================================== */
USE Mundial2026;
GO

-- 1. geo.confederacion: las 6 confederaciones de FIFA.
INSERT INTO geo.confederacion (nombre, sigla)
SELECT v.nombre, v.sigla
FROM (VALUES
    ('Unión de Asociaciones Europeas de Fútbol', 'UEFA'),
    ('Confederación Sudamericana de Fútbol',     'CONMEBOL'),
    ('Confederación de Norte, Centro América y Caribe', 'CONCACAF'),
    ('Confederación Africana de Fútbol',         'CAF'),
    ('Confederación Asiática de Fútbol',         'AFC'),
    ('Confederación de Fútbol de Oceanía',       'OFC')
) AS v(nombre, sigla)
WHERE NOT EXISTS (SELECT 1 FROM geo.confederacion c WHERE c.sigla = v.sigla);
GO

-- 2. persona.posicion: posiciones de juego.
INSERT INTO persona.posicion (descripcion)
SELECT v.descripcion
FROM (VALUES ('Arquero'), ('Defensor'), ('Mediocampista'), ('Delantero')) AS v(descripcion)
WHERE NOT EXISTS (SELECT 1 FROM persona.posicion p WHERE p.descripcion = v.descripcion);
GO

-- 3. juego.tipo_tarjeta.
INSERT INTO juego.tipo_tarjeta (descripcion)
SELECT v.descripcion
FROM (VALUES ('AMARILLA'), ('ROJA_DOBLE_AMARILLA'), ('ROJA_DIRECTA')) AS v(descripcion)
WHERE NOT EXISTS (SELECT 1 FROM juego.tipo_tarjeta t WHERE t.descripcion = v.descripcion);
GO

-- 4. juego.criterio_suspension: un criterio vigente por tipo de tarjeta .
INSERT INTO juego.criterio_suspension (id_tipo, cant_tarjetas_requeridas, cant_partidos_suspension)
SELECT tt.id_tipo, v.cant_tarjetas, v.cant_partidos
FROM (VALUES
    ('AMARILLA',            2, 1),
    ('ROJA_DOBLE_AMARILLA', 1, 1),
    ('ROJA_DIRECTA',        1, 1)
) AS v(tipo, cant_tarjetas, cant_partidos)
JOIN juego.tipo_tarjeta tt ON tt.descripcion = v.tipo
WHERE NOT EXISTS (SELECT 1 FROM juego.criterio_suspension c WHERE c.id_tipo = tt.id_tipo AND c.vigente = 1);
GO

-- 5. arbitraje.rol_arbitral: cinco roles.
INSERT INTO arbitraje.rol_arbitral (descripcion)
SELECT v.descripcion
FROM (VALUES ('PRINCIPAL'), ('ASISTENTE_1'), ('ASISTENTE_2'), ('CUARTO'), ('VAR')) AS v(descripcion)
WHERE NOT EXISTS (SELECT 1 FROM arbitraje.rol_arbitral r WHERE r.descripcion = v.descripcion);
GO

-- 6. torneo.fase: las siete fases del enunciado.
INSERT INTO torneo.fase (nro_fase, nombre, es_eliminacion, admite_alargue, admite_penales)
SELECT v.nro_fase, v.nombre, v.es_eliminacion, v.admite_alargue, v.admite_penales
FROM (VALUES
    (1, 'Fase de Grupos',          0, 0, 0),
    (2, 'Dieciseisavos de Final',  1, 1, 1),
    (3, 'Octavos de Final',        1, 1, 1),
    (4, 'Cuartos de Final',        1, 1, 1),
    (5, 'Semifinales',             1, 1, 1),
    (6, 'Tercer Puesto',           1, 1, 1),
    (7, 'Final',                   1, 1, 1)
) AS v(nro_fase, nombre, es_eliminacion, admite_alargue, admite_penales)
WHERE NOT EXISTS (SELECT 1 FROM torneo.fase f WHERE f.nro_fase = v.nro_fase);
GO

-- 7. torneo.grupo: letras A a L (12 grupos).
INSERT INTO torneo.grupo (id_letra)
SELECT v.id_letra
FROM (VALUES ('A'), ('B'), ('C'), ('D'), ('E'), ('F'), ('G'), ('H'), ('I'), ('J'), ('K'), ('L')) AS v(id_letra)
WHERE NOT EXISTS (SELECT 1 FROM torneo.grupo g WHERE g.id_letra = v.id_letra);
GO

-- 8. publicidad.franja_horaria (base).
INSERT INTO publicidad.franja_horaria (hora_desde, hora_hasta)
SELECT v.hora_desde, v.hora_hasta
FROM (VALUES
    (CAST('00:00:00' AS TIME(0)), CAST('19:00:00' AS TIME(0))),
    (CAST('19:00:00' AS TIME(0)), CAST('23:00:00' AS TIME(0))),
    (CAST('23:00:00' AS TIME(0)), CAST('23:59:59' AS TIME(0)))
) AS v(hora_desde, hora_hasta)
WHERE NOT EXISTS (SELECT 1 FROM publicidad.franja_horaria f
                  WHERE f.hora_desde = v.hora_desde AND f.hora_hasta = v.hora_hasta);
GO

-- 9. torneo.parametro_reglamento.
INSERT INTO torneo.parametro_reglamento (clave, vigente_desde, valor, descripcion)
SELECT v.clave, v.vigente_desde, v.valor, v.descripcion
FROM (VALUES
    ('MIN_CONVOCADOS',            CAST('2026-01-01' AS DATE), 23 , 'mínimo para registrar una convocatoria'),
    ('MAX_CONVOCADOS',            CAST('2026-01-01' AS DATE), 26 , 'máximo de convocados por selección'),
    ('TITULARES',                 CAST('2026-01-01' AS DATE), 11 , 'jugadores en la alineación titular'),
    ('MAX_SUPLENTES',             CAST('2026-01-01' AS DATE), 15 , 'tope de banco por partido'),
    ('MAX_SUSTITUCIONES',         CAST('2026-01-01' AS DATE), 5 ,  'cambios en tiempo reglamentario'),
    ('MAX_SUSTITUCIONES_ALARGUE', CAST('2026-01-01' AS DATE), 1 ,  'cambio adicional en alargue'),
    ('MAX_VENTANAS_SUSTITUCION',  CAST('2026-01-01' AS DATE), 3 ,  'ventanas de cambios (sin confirmar contra el reglamento oficial)'),
    ('PRIME_DESDE_HORA',          CAST('2026-01-01' AS DATE), 19 , 'inicio del prime time local'),
    ('PRIME_HASTA_HORA',          CAST('2026-01-01' AS DATE), 23 , 'fin del prime time local')
) AS v(clave, vigente_desde, valor, descripcion)
WHERE NOT EXISTS (SELECT 1 FROM torneo.parametro_reglamento p
                  WHERE p.clave = v.clave AND p.vigente_desde = v.vigente_desde);
GO

-- 10. publicidad.moneda: USD, la moneda de referencia de las cotizaciones.
INSERT INTO publicidad.moneda (cod_iso4217, nombre)
SELECT v.cod_iso4217, v.nombre
FROM (VALUES ('USD', 'Dólar Estadounidense')) AS v(cod_iso4217, nombre)
WHERE NOT EXISTS (SELECT 1 FROM publicidad.moneda m WHERE m.cod_iso4217 = v.cod_iso4217);
GO

-- 11. publicidad.tipo_cambio: cotización del USD contra sí mismo.
INSERT INTO publicidad.tipo_cambio (id_moneda, fecha, cotizacion_usd)
SELECT m.id_moneda, CAST('2026-01-01' AS DATE), 1.000000
FROM publicidad.moneda m
WHERE m.cod_iso4217 = 'USD'
  AND NOT EXISTS (SELECT 1 FROM publicidad.tipo_cambio t
                  WHERE t.id_moneda = m.id_moneda AND t.fecha = CAST('2026-01-01' AS DATE));
GO

-- Comprobación manual (va en los scripts de testing, no acá). Filas esperadas por tabla:
--   confederacion 6, posicion 4, tipo_tarjeta 3, criterio_suspension 3, rol_arbitral 5, fase 7,
--   grupo 12, franja_horaria 3, parametro_reglamento 9, moneda 1, tipo_cambio 1.
