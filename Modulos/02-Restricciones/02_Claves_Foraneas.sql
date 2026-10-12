/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03 
Objetivo: Agrega las 63 claves foráneas (simples y compuestas) y 40 índices de apoyo sobre columnas foráneas.
   ===================================================================== */
USE Mundial2026;
GO

-- =========================================================================
-- 1. DROP de las FK (re-ejecutable: si 02 ya fue aplicado, se vuelven a crear)
-- =========================================================================
ALTER TABLE geo.pais DROP CONSTRAINT IF EXISTS FK_pais_confederacion;
ALTER TABLE geo.ciudad DROP CONSTRAINT IF EXISTS FK_ciudad_pais;
ALTER TABLE geo.ciudad DROP CONSTRAINT IF EXISTS FK_ciudad_huso_horario;
ALTER TABLE geo.indicador_pais DROP CONSTRAINT IF EXISTS FK_indicador_pais_pais;
ALTER TABLE persona.persona DROP CONSTRAINT IF EXISTS FK_persona_pais;
ALTER TABLE persona.jugador DROP CONSTRAINT IF EXISTS FK_jugador_persona;
ALTER TABLE persona.jugador DROP CONSTRAINT IF EXISTS FK_jugador_club;
ALTER TABLE persona.jugador DROP CONSTRAINT IF EXISTS FK_jugador_posicion;
ALTER TABLE persona.miembro_cuerpo_tecnico DROP CONSTRAINT IF EXISTS FK_miembro_cuerpo_tecnico_persona;
ALTER TABLE persona.miembro_cuerpo_tecnico DROP CONSTRAINT IF EXISTS FK_miembro_cuerpo_tecnico_rol;
ALTER TABLE persona.miembro_cuerpo_tecnico DROP CONSTRAINT IF EXISTS FK_miembro_cuerpo_tecnico_seleccion;
ALTER TABLE persona.arbitro DROP CONSTRAINT IF EXISTS FK_arbitro_persona;
ALTER TABLE persona.arbitro DROP CONSTRAINT IF EXISTS FK_arbitro_categoria;
ALTER TABLE persona.persona_idioma DROP CONSTRAINT IF EXISTS FK_persona_idioma_persona;
ALTER TABLE persona.persona_idioma DROP CONSTRAINT IF EXISTS FK_persona_idioma_idioma;
ALTER TABLE torneo.seleccion DROP CONSTRAINT IF EXISTS FK_seleccion_grupo;
ALTER TABLE torneo.seleccion DROP CONSTRAINT IF EXISTS FK_seleccion_pais;
ALTER TABLE torneo.sede DROP CONSTRAINT IF EXISTS FK_sede_ciudad;
ALTER TABLE torneo.partido DROP CONSTRAINT IF EXISTS FK_partido_sede;
ALTER TABLE torneo.partido DROP CONSTRAINT IF EXISTS FK_partido_fase;
ALTER TABLE torneo.equipo_en_partido DROP CONSTRAINT IF EXISTS FK_equipo_en_partido_partido;
ALTER TABLE torneo.equipo_en_partido DROP CONSTRAINT IF EXISTS FK_equipo_en_partido_seleccion;
ALTER TABLE torneo.convocatoria DROP CONSTRAINT IF EXISTS FK_convocatoria_seleccion;
ALTER TABLE torneo.convocatoria DROP CONSTRAINT IF EXISTS FK_convocatoria_jugador;
ALTER TABLE torneo.cambio_convocatoria DROP CONSTRAINT IF EXISTS FK_cambio_convocatoria_convocatoria;
ALTER TABLE juego.alineacion DROP CONSTRAINT IF EXISTS FK_alineacion_equipo_en_partido;
ALTER TABLE juego.alineacion DROP CONSTRAINT IF EXISTS FK_alineacion_convocatoria;
ALTER TABLE juego.alineacion DROP CONSTRAINT IF EXISTS FK_alineacion_posicion;
ALTER TABLE juego.sustitucion DROP CONSTRAINT IF EXISTS FK_sustitucion_equipo_en_partido;
ALTER TABLE juego.sustitucion DROP CONSTRAINT IF EXISTS FK_sustitucion_alineacion_sale;
ALTER TABLE juego.sustitucion DROP CONSTRAINT IF EXISTS FK_sustitucion_alineacion_entra;
ALTER TABLE juego.gol DROP CONSTRAINT IF EXISTS FK_gol_equipo_en_partido;
ALTER TABLE juego.gol DROP CONSTRAINT IF EXISTS FK_gol_alineacion_autor;
ALTER TABLE juego.gol DROP CONSTRAINT IF EXISTS FK_gol_alineacion_asistente;
ALTER TABLE juego.tarjeta DROP CONSTRAINT IF EXISTS FK_tarjeta_equipo_en_partido;
ALTER TABLE juego.tarjeta DROP CONSTRAINT IF EXISTS FK_tarjeta_alineacion;
ALTER TABLE juego.tarjeta DROP CONSTRAINT IF EXISTS FK_tarjeta_tipo;
ALTER TABLE juego.tarjeta DROP CONSTRAINT IF EXISTS FK_tarjeta_arbitro;
ALTER TABLE juego.criterio_suspension DROP CONSTRAINT IF EXISTS FK_criterio_suspension_tipo;
ALTER TABLE juego.suspension DROP CONSTRAINT IF EXISTS FK_suspension_jugador;
ALTER TABLE juego.suspension DROP CONSTRAINT IF EXISTS FK_suspension_criterio;
ALTER TABLE juego.suspension_partido DROP CONSTRAINT IF EXISTS FK_suspension_partido_suspension;
ALTER TABLE juego.suspension_partido DROP CONSTRAINT IF EXISTS FK_suspension_partido_partido;
ALTER TABLE arbitraje.designacion_arbitral DROP CONSTRAINT IF EXISTS FK_designacion_arbitral_partido;
ALTER TABLE arbitraje.designacion_arbitral DROP CONSTRAINT IF EXISTS FK_designacion_arbitral_rol;
ALTER TABLE arbitraje.designacion_arbitral DROP CONSTRAINT IF EXISTS FK_designacion_arbitral_arbitro;
ALTER TABLE publicidad.anunciante DROP CONSTRAINT IF EXISTS FK_anunciante_pais;
ALTER TABLE publicidad.anunciante_pais DROP CONSTRAINT IF EXISTS FK_anunciante_pais_anunciante;
ALTER TABLE publicidad.anunciante_pais DROP CONSTRAINT IF EXISTS FK_anunciante_pais_pais;
ALTER TABLE publicidad.campania DROP CONSTRAINT IF EXISTS FK_campania_anunciante;
ALTER TABLE publicidad.pieza_publicitaria DROP CONSTRAINT IF EXISTS FK_pieza_publicitaria_campania;
ALTER TABLE publicidad.pieza_publicitaria DROP CONSTRAINT IF EXISTS FK_pieza_publicitaria_idioma;
ALTER TABLE publicidad.pieza_publicitaria DROP CONSTRAINT IF EXISTS FK_pieza_publicitaria_pais_mercado;
ALTER TABLE publicidad.tipo_cambio DROP CONSTRAINT IF EXISTS FK_tipo_cambio_moneda;
ALTER TABLE publicidad.tarifa DROP CONSTRAINT IF EXISTS FK_tarifa_franja;
ALTER TABLE publicidad.tarifa DROP CONSTRAINT IF EXISTS FK_tarifa_moneda;
ALTER TABLE publicidad.espacio_publicitario DROP CONSTRAINT IF EXISTS FK_espacio_publicitario_sede;
ALTER TABLE publicidad.exhibicion DROP CONSTRAINT IF EXISTS FK_exhibicion_partido;
ALTER TABLE publicidad.exhibicion DROP CONSTRAINT IF EXISTS FK_exhibicion_espacio;
ALTER TABLE publicidad.exhibicion DROP CONSTRAINT IF EXISTS FK_exhibicion_pieza;
ALTER TABLE publicidad.exhibicion DROP CONSTRAINT IF EXISTS FK_exhibicion_tarifa;
ALTER TABLE publicidad.feriado DROP CONSTRAINT IF EXISTS FK_feriado_pais;
ALTER TABLE soporte.importacion_error DROP CONSTRAINT IF EXISTS FK_importacion_error_importacion;
GO

-- =========================================================================
-- 2. CREACION DE LAS FK (nombre: FK_hija_padre). Las compuestas apuntan a las
--    UNIQUE/PK definidas en 01: (id_persona, tipo_persona), (id_seleccion, id_jugador),
--    (id_partido, id_sede), (id_partido, id_seleccion), etc.
-- =========================================================================

-- ---------------------------------- geo ----------------------------------
ALTER TABLE geo.pais
    ADD CONSTRAINT FK_pais_confederacion FOREIGN KEY (id_confederacion) REFERENCES geo.confederacion (id_confederacion);
GO

ALTER TABLE geo.ciudad
    ADD CONSTRAINT FK_ciudad_pais FOREIGN KEY (id_pais) REFERENCES geo.pais (id_pais),
        CONSTRAINT FK_ciudad_huso_horario FOREIGN KEY (id_huso) REFERENCES geo.huso_horario (id_huso);
GO

ALTER TABLE geo.indicador_pais
    ADD CONSTRAINT FK_indicador_pais_pais FOREIGN KEY (id_pais) REFERENCES geo.pais (id_pais);
GO


-- ---------------------------------- persona ----------------------------------
ALTER TABLE persona.persona
    ADD CONSTRAINT FK_persona_pais FOREIGN KEY (id_pais) REFERENCES geo.pais (id_pais);
GO

ALTER TABLE persona.jugador
    ADD CONSTRAINT FK_jugador_persona FOREIGN KEY (id_persona, tipo_persona) REFERENCES persona.persona (id_persona, tipo_persona),
        CONSTRAINT FK_jugador_club FOREIGN KEY (id_club) REFERENCES persona.club (id_club),
        CONSTRAINT FK_jugador_posicion FOREIGN KEY (id_posicion_habitual) REFERENCES persona.posicion (id_posicion);
GO

ALTER TABLE persona.miembro_cuerpo_tecnico
    ADD CONSTRAINT FK_miembro_cuerpo_tecnico_persona FOREIGN KEY (id_persona, tipo_persona) REFERENCES persona.persona (id_persona, tipo_persona),
        CONSTRAINT FK_miembro_cuerpo_tecnico_rol FOREIGN KEY (id_rol_ct) REFERENCES persona.rol_cuerpo_tecnico (id_rol_ct),
        CONSTRAINT FK_miembro_cuerpo_tecnico_seleccion FOREIGN KEY (id_seleccion) REFERENCES torneo.seleccion (id_seleccion);
GO

ALTER TABLE persona.arbitro
    ADD CONSTRAINT FK_arbitro_persona FOREIGN KEY (id_persona, tipo_persona) REFERENCES persona.persona (id_persona, tipo_persona),
        CONSTRAINT FK_arbitro_categoria FOREIGN KEY (id_categoria) REFERENCES persona.categoria_arbitral (id_categoria);
GO

ALTER TABLE persona.persona_idioma
    ADD CONSTRAINT FK_persona_idioma_persona FOREIGN KEY (id_persona) REFERENCES persona.persona (id_persona),
        CONSTRAINT FK_persona_idioma_idioma FOREIGN KEY (id_idioma) REFERENCES persona.idioma (id_idioma);
GO


-- ---------------------------------- torneo ----------------------------------
ALTER TABLE torneo.seleccion
    ADD CONSTRAINT FK_seleccion_grupo FOREIGN KEY (id_letra) REFERENCES torneo.grupo (id_letra),
        CONSTRAINT FK_seleccion_pais FOREIGN KEY (id_pais) REFERENCES geo.pais (id_pais);
GO

ALTER TABLE torneo.sede
    ADD CONSTRAINT FK_sede_ciudad FOREIGN KEY (id_ciudad) REFERENCES geo.ciudad (id_ciudad);
GO

ALTER TABLE torneo.partido
    ADD CONSTRAINT FK_partido_sede FOREIGN KEY (id_sede) REFERENCES torneo.sede (id_sede),
        CONSTRAINT FK_partido_fase FOREIGN KEY (nro_fase) REFERENCES torneo.fase (nro_fase);
GO

ALTER TABLE torneo.equipo_en_partido
    ADD CONSTRAINT FK_equipo_en_partido_partido FOREIGN KEY (id_partido) REFERENCES torneo.partido (id_partido),
        CONSTRAINT FK_equipo_en_partido_seleccion FOREIGN KEY (id_seleccion) REFERENCES torneo.seleccion (id_seleccion);
GO

ALTER TABLE torneo.convocatoria
    ADD CONSTRAINT FK_convocatoria_seleccion FOREIGN KEY (id_seleccion) REFERENCES torneo.seleccion (id_seleccion),
        CONSTRAINT FK_convocatoria_jugador FOREIGN KEY (id_jugador) REFERENCES persona.jugador (id_persona);
GO

ALTER TABLE torneo.cambio_convocatoria
    ADD CONSTRAINT FK_cambio_convocatoria_convocatoria FOREIGN KEY (id_seleccion, id_jugador) REFERENCES torneo.convocatoria (id_seleccion, id_jugador);
GO


-- ---------------------------------- juego ----------------------------------
ALTER TABLE juego.alineacion
    ADD CONSTRAINT FK_alineacion_equipo_en_partido FOREIGN KEY (id_partido, id_seleccion) REFERENCES torneo.equipo_en_partido (id_partido, id_seleccion),
        CONSTRAINT FK_alineacion_convocatoria FOREIGN KEY (id_seleccion, id_jugador) REFERENCES torneo.convocatoria (id_seleccion, id_jugador),
        CONSTRAINT FK_alineacion_posicion FOREIGN KEY (id_posicion) REFERENCES persona.posicion (id_posicion);
GO

ALTER TABLE juego.sustitucion
    ADD CONSTRAINT FK_sustitucion_equipo_en_partido FOREIGN KEY (id_partido, id_seleccion) REFERENCES torneo.equipo_en_partido (id_partido, id_seleccion),
        CONSTRAINT FK_sustitucion_alineacion_sale FOREIGN KEY (id_partido, id_seleccion, id_jugador_sale) REFERENCES juego.alineacion (id_partido, id_seleccion, id_jugador),
        CONSTRAINT FK_sustitucion_alineacion_entra FOREIGN KEY (id_partido, id_seleccion, id_jugador_entra) REFERENCES juego.alineacion (id_partido, id_seleccion, id_jugador);
GO

ALTER TABLE juego.gol
    ADD CONSTRAINT FK_gol_equipo_en_partido FOREIGN KEY (id_partido, id_seleccion) REFERENCES torneo.equipo_en_partido (id_partido, id_seleccion),
        CONSTRAINT FK_gol_alineacion_autor FOREIGN KEY (id_partido, id_seleccion, id_jugador_autor) REFERENCES juego.alineacion (id_partido, id_seleccion, id_jugador),
        CONSTRAINT FK_gol_alineacion_asistente FOREIGN KEY (id_partido, id_seleccion, id_jugador_asistente) REFERENCES juego.alineacion (id_partido, id_seleccion, id_jugador);
GO

ALTER TABLE juego.tarjeta
    ADD CONSTRAINT FK_tarjeta_equipo_en_partido FOREIGN KEY (id_partido, id_seleccion) REFERENCES torneo.equipo_en_partido (id_partido, id_seleccion),
        CONSTRAINT FK_tarjeta_alineacion FOREIGN KEY (id_partido, id_seleccion, id_jugador) REFERENCES juego.alineacion (id_partido, id_seleccion, id_jugador),
        CONSTRAINT FK_tarjeta_tipo FOREIGN KEY (id_tipo) REFERENCES juego.tipo_tarjeta (id_tipo),
        CONSTRAINT FK_tarjeta_arbitro FOREIGN KEY (id_arbitro) REFERENCES persona.arbitro (id_persona);
GO

ALTER TABLE juego.criterio_suspension
    ADD CONSTRAINT FK_criterio_suspension_tipo FOREIGN KEY (id_tipo) REFERENCES juego.tipo_tarjeta (id_tipo);
GO

ALTER TABLE juego.suspension
    ADD CONSTRAINT FK_suspension_jugador FOREIGN KEY (id_jugador) REFERENCES persona.jugador (id_persona),
        CONSTRAINT FK_suspension_criterio FOREIGN KEY (id_criterio) REFERENCES juego.criterio_suspension (id_criterio);
GO

ALTER TABLE juego.suspension_partido
    ADD CONSTRAINT FK_suspension_partido_suspension FOREIGN KEY (id_suspension) REFERENCES juego.suspension (id_suspension),
        CONSTRAINT FK_suspension_partido_partido FOREIGN KEY (id_partido) REFERENCES torneo.partido (id_partido);
GO


-- ---------------------------------- arbitraje ----------------------------------
ALTER TABLE arbitraje.designacion_arbitral
    ADD CONSTRAINT FK_designacion_arbitral_partido FOREIGN KEY (id_partido) REFERENCES torneo.partido (id_partido),
        CONSTRAINT FK_designacion_arbitral_rol FOREIGN KEY (id_rol) REFERENCES arbitraje.rol_arbitral (id_rol),
        CONSTRAINT FK_designacion_arbitral_arbitro FOREIGN KEY (id_arbitro) REFERENCES persona.arbitro (id_persona);
GO


-- ---------------------------------- publicidad ----------------------------------
ALTER TABLE publicidad.anunciante
    ADD CONSTRAINT FK_anunciante_pais FOREIGN KEY (id_pais) REFERENCES geo.pais (id_pais);
GO

ALTER TABLE publicidad.anunciante_pais
    ADD CONSTRAINT FK_anunciante_pais_anunciante FOREIGN KEY (id_anunciante) REFERENCES publicidad.anunciante (id_anunciante),
        CONSTRAINT FK_anunciante_pais_pais FOREIGN KEY (id_pais) REFERENCES geo.pais (id_pais);
GO

ALTER TABLE publicidad.campania
    ADD CONSTRAINT FK_campania_anunciante FOREIGN KEY (id_anunciante) REFERENCES publicidad.anunciante (id_anunciante);
GO

ALTER TABLE publicidad.pieza_publicitaria
    ADD CONSTRAINT FK_pieza_publicitaria_campania FOREIGN KEY (id_campania) REFERENCES publicidad.campania (id_campania),
        CONSTRAINT FK_pieza_publicitaria_idioma FOREIGN KEY (id_idioma) REFERENCES persona.idioma (id_idioma),
        CONSTRAINT FK_pieza_publicitaria_pais_mercado FOREIGN KEY (id_pais_mercado) REFERENCES geo.pais (id_pais);
GO

ALTER TABLE publicidad.tipo_cambio
    ADD CONSTRAINT FK_tipo_cambio_moneda FOREIGN KEY (id_moneda) REFERENCES publicidad.moneda (id_moneda);
GO

ALTER TABLE publicidad.tarifa
    ADD CONSTRAINT FK_tarifa_franja FOREIGN KEY (id_franja) REFERENCES publicidad.franja_horaria (id_franja),
        CONSTRAINT FK_tarifa_moneda FOREIGN KEY (id_moneda) REFERENCES publicidad.moneda (id_moneda);
GO

ALTER TABLE publicidad.espacio_publicitario
    ADD CONSTRAINT FK_espacio_publicitario_sede FOREIGN KEY (id_sede) REFERENCES torneo.sede (id_sede);
GO

ALTER TABLE publicidad.exhibicion
    ADD CONSTRAINT FK_exhibicion_partido FOREIGN KEY (id_partido, id_sede) REFERENCES torneo.partido (id_partido, id_sede),
        CONSTRAINT FK_exhibicion_espacio FOREIGN KEY (id_sede, nro_espacio) REFERENCES publicidad.espacio_publicitario (id_sede, nro_espacio),
        CONSTRAINT FK_exhibicion_pieza FOREIGN KEY (id_pieza) REFERENCES publicidad.pieza_publicitaria (id_pieza),
        CONSTRAINT FK_exhibicion_tarifa FOREIGN KEY (id_tarifa) REFERENCES publicidad.tarifa (id_tarifa);
GO

ALTER TABLE publicidad.feriado
    ADD CONSTRAINT FK_feriado_pais FOREIGN KEY (id_pais) REFERENCES geo.pais (id_pais);
GO


-- ---------------------------------- soporte ----------------------------------
ALTER TABLE soporte.importacion_error
    ADD CONSTRAINT FK_importacion_error_importacion FOREIGN KEY (id_importacion) REFERENCES soporte.importacion (id_importacion);
GO

-- =========================================================================
-- 3. INDICES SOBRE COLUMNAS FORANEAS (solo las que no quedan cubiertas por una PK/UQ)
-- =========================================================================
DROP INDEX IF EXISTS IX_pais_id_confederacion ON geo.pais;
DROP INDEX IF EXISTS IX_ciudad_id_huso ON geo.ciudad;
DROP INDEX IF EXISTS IX_persona_id_pais ON persona.persona;
DROP INDEX IF EXISTS IX_jugador_id_club ON persona.jugador;
DROP INDEX IF EXISTS IX_jugador_id_posicion_habitual ON persona.jugador;
DROP INDEX IF EXISTS IX_miembro_cuerpo_tecnico_id_rol_ct ON persona.miembro_cuerpo_tecnico;
DROP INDEX IF EXISTS IX_miembro_cuerpo_tecnico_id_seleccion ON persona.miembro_cuerpo_tecnico;
DROP INDEX IF EXISTS IX_arbitro_id_categoria ON persona.arbitro;
DROP INDEX IF EXISTS IX_persona_idioma_id_idioma ON persona.persona_idioma;
DROP INDEX IF EXISTS IX_seleccion_id_letra ON torneo.seleccion;
DROP INDEX IF EXISTS IX_sede_id_ciudad ON torneo.sede;
DROP INDEX IF EXISTS IX_partido_id_sede ON torneo.partido;
DROP INDEX IF EXISTS IX_partido_nro_fase ON torneo.partido;
DROP INDEX IF EXISTS IX_equipo_en_partido_id_seleccion ON torneo.equipo_en_partido;
DROP INDEX IF EXISTS IX_cambio_convocatoria_id_seleccion_id_jugador ON torneo.cambio_convocatoria;
DROP INDEX IF EXISTS IX_alineacion_id_seleccion_id_jugador ON juego.alineacion;
DROP INDEX IF EXISTS IX_alineacion_id_posicion ON juego.alineacion;
DROP INDEX IF EXISTS IX_sustitucion_id_partido_id_seleccion_id_jugador_sale ON juego.sustitucion;
DROP INDEX IF EXISTS IX_sustitucion_id_partido_id_seleccion_id_jugador_entra ON juego.sustitucion;
DROP INDEX IF EXISTS IX_gol_id_partido_id_seleccion_id_jugador_autor ON juego.gol;
DROP INDEX IF EXISTS IX_gol_id_partido_id_seleccion_id_jugador_asistente ON juego.gol;
DROP INDEX IF EXISTS IX_tarjeta_id_partido_id_seleccion_id_jugador ON juego.tarjeta;
DROP INDEX IF EXISTS IX_tarjeta_id_tipo ON juego.tarjeta;
DROP INDEX IF EXISTS IX_tarjeta_id_arbitro ON juego.tarjeta;
DROP INDEX IF EXISTS IX_criterio_suspension_id_tipo ON juego.criterio_suspension;
DROP INDEX IF EXISTS IX_suspension_id_jugador ON juego.suspension;
DROP INDEX IF EXISTS IX_suspension_id_criterio ON juego.suspension;
DROP INDEX IF EXISTS IX_suspension_partido_id_partido ON juego.suspension_partido;
DROP INDEX IF EXISTS IX_designacion_arbitral_id_rol ON arbitraje.designacion_arbitral;
DROP INDEX IF EXISTS IX_designacion_arbitral_id_arbitro ON arbitraje.designacion_arbitral;
DROP INDEX IF EXISTS IX_anunciante_id_pais ON publicidad.anunciante;
DROP INDEX IF EXISTS IX_anunciante_pais_id_pais ON publicidad.anunciante_pais;
DROP INDEX IF EXISTS IX_campania_id_anunciante ON publicidad.campania;
DROP INDEX IF EXISTS IX_pieza_publicitaria_id_campania ON publicidad.pieza_publicitaria;
DROP INDEX IF EXISTS IX_pieza_publicitaria_id_idioma ON publicidad.pieza_publicitaria;
DROP INDEX IF EXISTS IX_pieza_publicitaria_id_pais_mercado ON publicidad.pieza_publicitaria;
DROP INDEX IF EXISTS IX_tarifa_id_moneda ON publicidad.tarifa;
DROP INDEX IF EXISTS IX_exhibicion_id_sede_nro_espacio ON publicidad.exhibicion;
DROP INDEX IF EXISTS IX_exhibicion_id_pieza ON publicidad.exhibicion;
DROP INDEX IF EXISTS IX_exhibicion_id_tarifa ON publicidad.exhibicion;
GO


CREATE INDEX IX_pais_id_confederacion ON geo.pais (id_confederacion);
CREATE INDEX IX_ciudad_id_huso ON geo.ciudad (id_huso);
CREATE INDEX IX_persona_id_pais ON persona.persona (id_pais);
CREATE INDEX IX_jugador_id_club ON persona.jugador (id_club);
CREATE INDEX IX_jugador_id_posicion_habitual ON persona.jugador (id_posicion_habitual);
CREATE INDEX IX_miembro_cuerpo_tecnico_id_rol_ct ON persona.miembro_cuerpo_tecnico (id_rol_ct);
CREATE INDEX IX_miembro_cuerpo_tecnico_id_seleccion ON persona.miembro_cuerpo_tecnico (id_seleccion);
CREATE INDEX IX_arbitro_id_categoria ON persona.arbitro (id_categoria);
CREATE INDEX IX_persona_idioma_id_idioma ON persona.persona_idioma (id_idioma);
CREATE INDEX IX_seleccion_id_letra ON torneo.seleccion (id_letra);
CREATE INDEX IX_sede_id_ciudad ON torneo.sede (id_ciudad);
CREATE INDEX IX_partido_id_sede ON torneo.partido (id_sede);
CREATE INDEX IX_partido_nro_fase ON torneo.partido (nro_fase);
CREATE INDEX IX_equipo_en_partido_id_seleccion ON torneo.equipo_en_partido (id_seleccion);
CREATE INDEX IX_cambio_convocatoria_id_seleccion_id_jugador ON torneo.cambio_convocatoria (id_seleccion, id_jugador);
CREATE INDEX IX_alineacion_id_seleccion_id_jugador ON juego.alineacion (id_seleccion, id_jugador);
CREATE INDEX IX_alineacion_id_posicion ON juego.alineacion (id_posicion);
CREATE INDEX IX_sustitucion_id_partido_id_seleccion_id_jugador_sale ON juego.sustitucion (id_partido, id_seleccion, id_jugador_sale);
CREATE INDEX IX_sustitucion_id_partido_id_seleccion_id_jugador_entra ON juego.sustitucion (id_partido, id_seleccion, id_jugador_entra);
CREATE INDEX IX_gol_id_partido_id_seleccion_id_jugador_autor ON juego.gol (id_partido, id_seleccion, id_jugador_autor);
CREATE INDEX IX_gol_id_partido_id_seleccion_id_jugador_asistente ON juego.gol (id_partido, id_seleccion, id_jugador_asistente);
CREATE INDEX IX_tarjeta_id_partido_id_seleccion_id_jugador ON juego.tarjeta (id_partido, id_seleccion, id_jugador);
CREATE INDEX IX_tarjeta_id_tipo ON juego.tarjeta (id_tipo);
CREATE INDEX IX_tarjeta_id_arbitro ON juego.tarjeta (id_arbitro);
CREATE INDEX IX_criterio_suspension_id_tipo ON juego.criterio_suspension (id_tipo);
CREATE INDEX IX_suspension_id_jugador ON juego.suspension (id_jugador);
CREATE INDEX IX_suspension_id_criterio ON juego.suspension (id_criterio);
CREATE INDEX IX_suspension_partido_id_partido ON juego.suspension_partido (id_partido);
CREATE INDEX IX_designacion_arbitral_id_rol ON arbitraje.designacion_arbitral (id_rol);
CREATE INDEX IX_designacion_arbitral_id_arbitro ON arbitraje.designacion_arbitral (id_arbitro);
CREATE INDEX IX_anunciante_id_pais ON publicidad.anunciante (id_pais);
CREATE INDEX IX_anunciante_pais_id_pais ON publicidad.anunciante_pais (id_pais);
CREATE INDEX IX_campania_id_anunciante ON publicidad.campania (id_anunciante);
CREATE INDEX IX_pieza_publicitaria_id_campania ON publicidad.pieza_publicitaria (id_campania);
CREATE INDEX IX_pieza_publicitaria_id_idioma ON publicidad.pieza_publicitaria (id_idioma);
CREATE INDEX IX_pieza_publicitaria_id_pais_mercado ON publicidad.pieza_publicitaria (id_pais_mercado);
CREATE INDEX IX_tarifa_id_moneda ON publicidad.tarifa (id_moneda);
CREATE INDEX IX_exhibicion_id_sede_nro_espacio ON publicidad.exhibicion (id_sede, nro_espacio);
CREATE INDEX IX_exhibicion_id_pieza ON publicidad.exhibicion (id_pieza);
CREATE INDEX IX_exhibicion_id_tarifa ON publicidad.exhibicion (id_tarifa);
GO

-- Comprobación manual (va en los scripts de testing, no acá):
--   SELECT COUNT(*) FROM sys.foreign_keys;   -- esperado: 63
