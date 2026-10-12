/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comision: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Borra (si existen) y crea las 48 tablas del modelo con sus PK, UNIQUE, CHECK y DEFAULT en línea, sin claves foráneas.
   ===================================================================== */
USE Mundial2026;
GO


-- Capa 7 y hojas de la capa 6 (nadie las referencia):
DROP TABLE IF EXISTS juego.suspension_partido;   -- referencia a suspension: va antes
DROP TABLE IF EXISTS juego.suspension;
DROP TABLE IF EXISTS juego.sustitucion;          -- referencian a alineacion: van antes
DROP TABLE IF EXISTS juego.gol;
DROP TABLE IF EXISTS juego.tarjeta;
DROP TABLE IF EXISTS arbitraje.informe_post_partido;
DROP TABLE IF EXISTS publicidad.exhibicion;

-- Capa 6:
DROP TABLE IF EXISTS juego.alineacion;

-- Capa 5:
DROP TABLE IF EXISTS torneo.equipo_en_partido;
DROP TABLE IF EXISTS torneo.cambio_convocatoria;
DROP TABLE IF EXISTS arbitraje.designacion_arbitral;
DROP TABLE IF EXISTS publicidad.tarifa;

-- Capa 4:
DROP TABLE IF EXISTS publicidad.espacio_publicitario;
DROP TABLE IF EXISTS torneo.partido;
DROP TABLE IF EXISTS torneo.convocatoria;
DROP TABLE IF EXISTS publicidad.pieza_publicitaria;

-- Capa 3:
DROP TABLE IF EXISTS torneo.sede;
DROP TABLE IF EXISTS persona.jugador;
DROP TABLE IF EXISTS persona.miembro_cuerpo_tecnico;
DROP TABLE IF EXISTS persona.arbitro;
DROP TABLE IF EXISTS persona.persona_idioma;
DROP TABLE IF EXISTS publicidad.campania;
DROP TABLE IF EXISTS publicidad.anunciante_pais;
DROP TABLE IF EXISTS soporte.importacion_error;

-- Capa 2:
DROP TABLE IF EXISTS geo.ciudad;
DROP TABLE IF EXISTS torneo.seleccion;
DROP TABLE IF EXISTS persona.persona;
DROP TABLE IF EXISTS geo.indicador_pais;
DROP TABLE IF EXISTS publicidad.feriado;
DROP TABLE IF EXISTS publicidad.anunciante;

-- Capa 1:
DROP TABLE IF EXISTS geo.pais;
DROP TABLE IF EXISTS publicidad.tipo_cambio;
DROP TABLE IF EXISTS juego.criterio_suspension;

-- Capa 0:
DROP TABLE IF EXISTS geo.confederacion;
DROP TABLE IF EXISTS geo.huso_horario;
DROP TABLE IF EXISTS publicidad.moneda;
DROP TABLE IF EXISTS persona.idioma;
DROP TABLE IF EXISTS torneo.fase;
DROP TABLE IF EXISTS torneo.grupo;
DROP TABLE IF EXISTS juego.tipo_tarjeta;
DROP TABLE IF EXISTS persona.posicion;
DROP TABLE IF EXISTS persona.rol_cuerpo_tecnico;
DROP TABLE IF EXISTS persona.categoria_arbitral;
DROP TABLE IF EXISTS arbitraje.rol_arbitral;
DROP TABLE IF EXISTS persona.club;
DROP TABLE IF EXISTS publicidad.franja_horaria;
DROP TABLE IF EXISTS torneo.parametro_reglamento;
DROP TABLE IF EXISTS soporte.importacion;
GO


-- ---------------------------------- Nivel 0 ----------------------------------
-- geo.confederacion: catálogo de confederaciones (UEFA, CONMEBOL, etc.).
CREATE TABLE geo.confederacion (
    id_confederacion TINYINT IDENTITY(1,1) NOT NULL,
    nombre           NVARCHAR(50) NOT NULL,
    sigla            NVARCHAR(10) NOT NULL,
    CONSTRAINT PK_confederacion PRIMARY KEY (id_confederacion),
    CONSTRAINT UQ_confederacion_nombre UNIQUE (nombre),
    CONSTRAINT UQ_confederacion_sigla UNIQUE (sigla)
);
GO

-- geo.huso_horario: husos horarios con su desfase en minutos respecto de UTC.
CREATE TABLE geo.huso_horario (
    id_huso        SMALLINT IDENTITY(1,1) NOT NULL,
    zona_horaria   NVARCHAR(60) NOT NULL,
    offset_utc     SMALLINT NOT NULL,
    horario_verano BIT NOT NULL CONSTRAINT DF_huso_horario_horario_verano DEFAULT 0,
    CONSTRAINT PK_huso_horario PRIMARY KEY (id_huso),
    CONSTRAINT UQ_huso_horario_zona_horaria UNIQUE (zona_horaria),
    CONSTRAINT CK_huso_horario_offset_utc CHECK (offset_utc BETWEEN -720 AND 840)
);
GO

-- publicidad.moneda: monedas (ISO 4217) en las que se expresan las tarifas.
CREATE TABLE publicidad.moneda (
    id_moneda   TINYINT IDENTITY(1,1) NOT NULL,
    cod_iso4217 CHAR(3) NOT NULL,
    nombre      NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_moneda PRIMARY KEY (id_moneda),
    CONSTRAINT UQ_moneda_cod_iso4217 UNIQUE (cod_iso4217)
);
GO

-- torneo.parametro_reglamento: parámetros del reglamento con vigencia (convocados, cambios, prime time, etc.).
CREATE TABLE torneo.parametro_reglamento (
    clave         VARCHAR(40) NOT NULL,
    vigente_desde DATE NOT NULL,
    valor         INT NOT NULL,
    descripcion   NVARCHAR(200) NULL,
    CONSTRAINT PK_parametro_reglamento PRIMARY KEY (clave, vigente_desde)
);
GO

-- juego.tipo_tarjeta: catálogo.
CREATE TABLE juego.tipo_tarjeta (
    id_tipo     TINYINT IDENTITY(1,1) NOT NULL,
    descripcion NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_tipo_tarjeta PRIMARY KEY (id_tipo),
    CONSTRAINT UQ_tipo_tarjeta_descripcion UNIQUE (descripcion)
);
GO

-- arbitraje.rol_arbitral: catálogo.
CREATE TABLE arbitraje.rol_arbitral (
    id_rol      TINYINT IDENTITY(1,1) NOT NULL,
    descripcion NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_rol_arbitral PRIMARY KEY (id_rol),
    CONSTRAINT UQ_rol_arbitral_descripcion UNIQUE (descripcion)
);
GO

-- soporte.importacion: auditoría de cada importación (fuente, archivo, filas leídas/ok/error, estado).
CREATE TABLE soporte.importacion (
    id_importacion INT IDENTITY(1,1) NOT NULL,
    fuente         NVARCHAR(100) NOT NULL,
    archivo        NVARCHAR(260) NOT NULL,
    formato        VARCHAR(10) NOT NULL,
    fecha_inicio   DATETIME2(0) NOT NULL,
    fecha_fin      DATETIME2(0) NULL,
    filas_leidas   INT NOT NULL CONSTRAINT DF_importacion_filas_leidas DEFAULT 0,
    filas_ok       INT NOT NULL CONSTRAINT DF_importacion_filas_ok DEFAULT 0,
    filas_error    INT NOT NULL CONSTRAINT DF_importacion_filas_error DEFAULT 0,
    estado         VARCHAR(10) NOT NULL CONSTRAINT DF_importacion_estado DEFAULT 'EN_CURSO',
    CONSTRAINT PK_importacion PRIMARY KEY (id_importacion),
    CONSTRAINT CK_importacion_formato CHECK (formato IN ('CSV','JSON','XML')),
    CONSTRAINT CK_importacion_estado CHECK (estado IN ('EN_CURSO','OK','CON_ERROR'))
);
GO

-- publicidad.franja_horaria: franjas horarias de emisión.
CREATE TABLE publicidad.franja_horaria (
    id_franja  TINYINT IDENTITY(1,1) NOT NULL,
    hora_desde TIME(0) NOT NULL,
    hora_hasta TIME(0) NOT NULL,
    CONSTRAINT PK_franja_horaria PRIMARY KEY (id_franja),
    CONSTRAINT UQ_franja_horaria_hora_desde_hora_hasta UNIQUE (hora_desde, hora_hasta),
    CONSTRAINT CK_franja_horaria_orden CHECK (hora_desde < hora_hasta)
);
GO

-- persona.club: clubes de origen de los jugadores.
CREATE TABLE persona.club (
    id_club   INT IDENTITY(1,1) NOT NULL,
    nombre    NVARCHAR(100) NOT NULL,
    pais_club NVARCHAR(80) NOT NULL,
    CONSTRAINT PK_club PRIMARY KEY (id_club),
    CONSTRAINT UQ_club_nombre_pais_club UNIQUE (nombre, pais_club)
);
GO

-- persona.posicion: catálogo de posiciones de juego.
CREATE TABLE persona.posicion (
    id_posicion TINYINT IDENTITY(1,1) NOT NULL,
    descripcion NVARCHAR(40) NOT NULL,
    CONSTRAINT PK_posicion PRIMARY KEY (id_posicion),
    CONSTRAINT UQ_posicion_descripcion UNIQUE (descripcion)
);
GO

-- persona.rol_cuerpo_tecnico: catálogo (director técnico, ayudante, etc.).
CREATE TABLE persona.rol_cuerpo_tecnico (
    id_rol_ct   TINYINT IDENTITY(1,1) NOT NULL,
    descripcion NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_rol_cuerpo_tecnico PRIMARY KEY (id_rol_ct),
    CONSTRAINT UQ_rol_cuerpo_tecnico_descripcion UNIQUE (descripcion)
);
GO

-- persona.categoria_arbitral: catálogo de categorías de árbitro (FIFA / confederación).
CREATE TABLE persona.categoria_arbitral (
    id_categoria TINYINT IDENTITY(1,1) NOT NULL,
    descripcion  NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_categoria_arbitral PRIMARY KEY (id_categoria),
    CONSTRAINT UQ_categoria_arbitral_descripcion UNIQUE (descripcion)
);
GO

-- persona.idioma: catálogo de idiomas (ISO 639).
CREATE TABLE persona.idioma (
    id_idioma  SMALLINT IDENTITY(1,1) NOT NULL,
    cod_iso639 CHAR(3) NOT NULL,
    nombre     NVARCHAR(60) NOT NULL,
    CONSTRAINT PK_idioma PRIMARY KEY (id_idioma),
    CONSTRAINT UQ_idioma_cod_iso639 UNIQUE (cod_iso639),
    CONSTRAINT UQ_idioma_nombre UNIQUE (nombre)
);
GO

-- torneo.grupo: letras de grupo de la fase de grupos (A a L).
CREATE TABLE torneo.grupo (
    id_letra CHAR(1) NOT NULL,
    CONSTRAINT PK_grupo PRIMARY KEY (id_letra),
    CONSTRAINT CK_grupo_letra CHECK (id_letra BETWEEN 'A' AND 'L')
);
GO

-- torneo.fase: las 7 fases del torneo.
CREATE TABLE torneo.fase (
    nro_fase       TINYINT NOT NULL,
    nombre         NVARCHAR(40) NOT NULL,
    es_eliminacion BIT NOT NULL,
    admite_alargue BIT NOT NULL,
    admite_penales BIT NOT NULL,
    CONSTRAINT PK_fase PRIMARY KEY (nro_fase),
    CONSTRAINT UQ_fase_nombre UNIQUE (nombre),
    CONSTRAINT CK_fase_nro CHECK (nro_fase BETWEEN 1 AND 7)
);
GO

-- ---------------------------------- Nivel 1 ----------------------------------
-- geo.pais: países. El código FIFA es opcional, por eso su unicidad es un índice filtrado.
CREATE TABLE geo.pais (
    id_pais          SMALLINT IDENTITY(1,1) NOT NULL,
    nombre           NVARCHAR(80) NOT NULL,
    cod_iso3         CHAR(3) NOT NULL,
    cod_fifa         CHAR(3) NULL,
    gentilicio       NVARCHAR(60) NULL,
    id_confederacion TINYINT NOT NULL,
    CONSTRAINT PK_pais PRIMARY KEY (id_pais),
    CONSTRAINT UQ_pais_nombre UNIQUE (nombre),
    CONSTRAINT UQ_pais_cod_iso3 UNIQUE (cod_iso3)
);
GO
CREATE UNIQUE INDEX UX_pais_cod_fifa ON geo.pais (cod_fifa) WHERE cod_fifa IS NOT NULL;
GO

-- publicidad.tipo_cambio: cotización diaria de cada moneda contra USD.
CREATE TABLE publicidad.tipo_cambio (
    id_moneda      TINYINT NOT NULL,
    fecha          DATE NOT NULL,
    cotizacion_usd DECIMAL(18,6) NOT NULL,
    CONSTRAINT PK_tipo_cambio PRIMARY KEY (id_moneda, fecha),
    CONSTRAINT CK_tipo_cambio_cotizacion CHECK (cotizacion_usd > 0)
);
GO

-- juego.criterio_suspension: criterios parametrizables de suspensión por acumulación de tarjetas.
--   Solo un criterio vigente por tipo de tarjeta (índice único filtrado).
CREATE TABLE juego.criterio_suspension (
    id_criterio              INT IDENTITY(1,1) NOT NULL,
    id_tipo                  TINYINT NOT NULL,
    cant_tarjetas_requeridas TINYINT NOT NULL,
    cant_partidos_suspension TINYINT NOT NULL,
    vigente                  BIT NOT NULL CONSTRAINT DF_criterio_suspension_vigente DEFAULT 1,
    CONSTRAINT PK_criterio_suspension PRIMARY KEY (id_criterio),
    CONSTRAINT CK_criterio_suspension_cantidades CHECK (cant_tarjetas_requeridas > 0 AND cant_partidos_suspension > 0)
);
GO
CREATE UNIQUE INDEX UX_criterio_suspension_id_tipo_vigente ON juego.criterio_suspension (id_tipo) WHERE vigente = 1;
GO

-- ---------------------------------- Nivel 2 ----------------------------------
-- geo.ciudad: ciudades con población y huso horario (el huso de un país es el de su ciudad más poblada).
CREATE TABLE geo.ciudad (
    id_ciudad INT IDENTITY(1,1) NOT NULL,
    nombre    NVARCHAR(100) NOT NULL,
    poblacion INT NOT NULL,
    id_pais   SMALLINT NOT NULL,
    id_huso   SMALLINT NOT NULL,
    CONSTRAINT PK_ciudad PRIMARY KEY (id_ciudad),
    CONSTRAINT UQ_ciudad_id_pais_nombre UNIQUE (id_pais, nombre),
    CONSTRAINT CK_ciudad_poblacion CHECK (poblacion >= 0)
);
GO

-- torneo.seleccion: selecciones participantes (una por país), con su grupo.
CREATE TABLE torneo.seleccion (
    id_seleccion       INT IDENTITY(1,1) NOT NULL,
    id_letra           CHAR(1) NOT NULL,
    id_pais            SMALLINT NOT NULL,
    fecha_confirmacion DATE NULL,
    es_anfitrion       BIT NOT NULL CONSTRAINT DF_seleccion_es_anfitrion DEFAULT 0,
    CONSTRAINT PK_seleccion PRIMARY KEY (id_seleccion),
    CONSTRAINT UQ_seleccion_id_pais UNIQUE (id_pais)
);
GO

-- persona.persona: supertipo de la jerarquía (J jugador, C cuerpo técnico, A árbitro).
CREATE TABLE persona.persona (
    id_persona   INT IDENTITY(1,1) NOT NULL,
    tipo_persona CHAR(1) NOT NULL,
    tipo_doc     VARCHAR(5) NOT NULL,
    nro_doc      NVARCHAR(30) NOT NULL,
    nombre       NVARCHAR(80) NOT NULL,
    apellido     NVARCHAR(80) NOT NULL,
    fecha_nac    DATE NOT NULL,
    id_pais      SMALLINT NOT NULL,
    CONSTRAINT PK_persona PRIMARY KEY (id_persona),
    CONSTRAINT UQ_persona_tipo_doc_nro_doc UNIQUE (tipo_doc, nro_doc),
    CONSTRAINT UQ_persona_id_persona_tipo_persona UNIQUE (id_persona, tipo_persona),
    CONSTRAINT CK_persona_tipo CHECK (tipo_persona IN ('J','C','A')),
    CONSTRAINT CK_persona_tipo_doc CHECK (tipo_doc IN ('DNI','PAS','EXT')),
    CONSTRAINT CK_persona_nro_doc CHECK (LEN(LTRIM(RTRIM(nro_doc))) > 0),
    CONSTRAINT CK_persona_fecha_nac CHECK (fecha_nac <= CAST(SYSDATETIME() AS DATE))
);
GO

-- geo.indicador_pais: indicadores económicos por país y año.
CREATE TABLE geo.indicador_pais (
    id_pais          SMALLINT NOT NULL,
    anio             SMALLINT NOT NULL,
    codigo_indicador VARCHAR(30) NOT NULL,
    valor            DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_indicador_pais PRIMARY KEY (id_pais, anio, codigo_indicador),
    CONSTRAINT CK_indicador_pais_anio CHECK (anio BETWEEN 1960 AND 2100)
);
GO

-- publicidad.feriado: feriados por país.
CREATE TABLE publicidad.feriado (
    id_pais SMALLINT NOT NULL,
    fecha   DATE NOT NULL,
    nombre  NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_feriado PRIMARY KEY (id_pais, fecha)
);
GO

-- publicidad.anunciante: anunciantes, con su país de origen y su identificación fiscal.
CREATE TABLE publicidad.anunciante (
    id_anunciante         INT IDENTITY(1,1) NOT NULL,
    razon_social          NVARCHAR(150) NOT NULL,
    identificacion_fiscal NVARCHAR(30) NOT NULL,
    contacto              NVARCHAR(150) NULL,
    id_pais               SMALLINT NOT NULL,
    CONSTRAINT PK_anunciante PRIMARY KEY (id_anunciante),
    CONSTRAINT UQ_anunciante_identificacion_fiscal UNIQUE (identificacion_fiscal)
);
GO

-- ---------------------------------- Nivel 3 ----------------------------------
-- torneo.sede: estadios, con capacidad y coordenadas.
CREATE TABLE torneo.sede (
    id_sede        INT IDENTITY(1,1) NOT NULL,
    nombre_estadio NVARCHAR(100) NOT NULL,
    capacidad      INT NOT NULL,
    direccion      NVARCHAR(200) NULL,
    latitud        DECIMAL(9,6) NULL,
    longitud       DECIMAL(9,6) NULL,
    id_ciudad      INT NOT NULL,
    CONSTRAINT PK_sede PRIMARY KEY (id_sede),
    CONSTRAINT UQ_sede_nombre_estadio UNIQUE (nombre_estadio),
    CONSTRAINT CK_sede_capacidad CHECK (capacidad > 0),
    CONSTRAINT CK_sede_latitud CHECK (latitud BETWEEN -90 AND 90),
    CONSTRAINT CK_sede_longitud CHECK (longitud BETWEEN -180 AND 180)
);
GO

-- persona.jugador: subtipo de persona.
CREATE TABLE persona.jugador (
    id_persona           INT NOT NULL,
    tipo_persona         CHAR(1) NOT NULL CONSTRAINT DF_jugador_tipo_persona DEFAULT 'J',
    pie_habil            CHAR(1) NULL,
    altura_cm            SMALLINT NULL,
    id_club              INT NULL,
    id_posicion_habitual TINYINT NOT NULL,
    CONSTRAINT PK_jugador PRIMARY KEY (id_persona),
    CONSTRAINT CK_jugador_tipo_persona CHECK (tipo_persona = 'J'),
    CONSTRAINT CK_jugador_pie_habil CHECK (pie_habil IN ('I','D','A')),
    CONSTRAINT CK_jugador_altura_cm CHECK (altura_cm BETWEEN 120 AND 230)
);
GO

-- persona.miembro_cuerpo_tecnico: subtipo de persona.
CREATE TABLE persona.miembro_cuerpo_tecnico (
    id_persona   INT NOT NULL,
    tipo_persona CHAR(1) NOT NULL CONSTRAINT DF_miembro_cuerpo_tecnico_tipo_persona DEFAULT 'C',
    id_rol_ct    TINYINT NOT NULL,
    id_seleccion INT NOT NULL,
    CONSTRAINT PK_miembro_cuerpo_tecnico PRIMARY KEY (id_persona),
    CONSTRAINT CK_miembro_cuerpo_tecnico_tipo_persona CHECK (tipo_persona = 'C')
);
GO

-- persona.arbitro: subtipo de persona.
CREATE TABLE persona.arbitro (
    id_persona       INT NOT NULL,
    tipo_persona     CHAR(1) NOT NULL CONSTRAINT DF_arbitro_tipo_persona DEFAULT 'A',
    fecha_debut_fifa DATE NULL,
    id_categoria     TINYINT NOT NULL,
    CONSTRAINT PK_arbitro PRIMARY KEY (id_persona),
    CONSTRAINT CK_arbitro_tipo_persona CHECK (tipo_persona = 'A')
);
GO

-- persona.persona_idioma: tabla puente N a N entre personas e idiomas que hablan.
CREATE TABLE persona.persona_idioma (
    id_persona INT NOT NULL,
    id_idioma  SMALLINT NOT NULL,
    CONSTRAINT PK_persona_idioma PRIMARY KEY (id_persona, id_idioma)
);
GO

-- publicidad.campania: campañas publicitarias de cada anunciante, con vigencia y presupuesto.
CREATE TABLE publicidad.campania (
    id_campania   INT IDENTITY(1,1) NOT NULL,
    nombre        NVARCHAR(100) NOT NULL,
    id_anunciante INT NOT NULL,
    fecha_desde   DATE NOT NULL,
    fecha_hasta   DATE NOT NULL,
    presupuesto   DECIMAL(18,2) NULL,
    CONSTRAINT PK_campania PRIMARY KEY (id_campania),
    CONSTRAINT CK_campania_fechas CHECK (fecha_hasta >= fecha_desde),
    CONSTRAINT CK_campania_presupuesto CHECK (presupuesto >= 0)
);
GO

-- publicidad.anunciante_pais: países de interés de cada anunciante, con prioridad (1 = máxima, 3 = mínima).
CREATE TABLE publicidad.anunciante_pais (
    id_anunciante INT NOT NULL,
    id_pais       SMALLINT NOT NULL,
    prioridad     TINYINT NOT NULL CONSTRAINT DF_anunciante_pais_prioridad DEFAULT 2,
    CONSTRAINT PK_anunciante_pais PRIMARY KEY (id_anunciante, id_pais),
    CONSTRAINT CK_anunciante_pais_prioridad CHECK (prioridad BETWEEN 1 AND 3)
);
GO

-- soporte.importacion_error: detalle de errores por fila de cada importación.
CREATE TABLE soporte.importacion_error (
    id_importacion INT NOT NULL,
    nro_error      INT NOT NULL,
    nro_fila       INT NOT NULL,
    columna        NVARCHAR(60) NULL,
    valor          NVARCHAR(500) NULL,
    mensaje        NVARCHAR(500) NOT NULL,
    CONSTRAINT PK_importacion_error PRIMARY KEY (id_importacion, nro_error)
);
GO

-- ---------------------------------- Nivel 4 ----------------------------------
-- publicidad.espacio_publicitario: los 4 espacios publicitarios de cada sede.
CREATE TABLE publicidad.espacio_publicitario (
    id_sede     INT NOT NULL,
    nro_espacio TINYINT NOT NULL,
    tipo        VARCHAR(20) NULL,
    descripcion NVARCHAR(100) NULL,
    CONSTRAINT PK_espacio_publicitario PRIMARY KEY (id_sede, nro_espacio),
    CONSTRAINT CK_espacio_publicitario_nro_espacio CHECK (nro_espacio BETWEEN 1 AND 4)
);
GO

-- torneo.partido: partidos del torneo (fecha/hora en UTC, sede, fase y estado).
CREATE TABLE torneo.partido (
    id_partido           INT IDENTITY(1,1) NOT NULL,
    fecha_hora_utc       DATETIME2(0) NOT NULL,
    asistencia_publico   INT NULL,
    definido_por_penales BIT NOT NULL CONSTRAINT DF_partido_definido_por_penales DEFAULT 0,
    estado               VARCHAR(12) NOT NULL CONSTRAINT DF_partido_estado DEFAULT 'PROGRAMADO',
    id_sede              INT NOT NULL,
    nro_fase             TINYINT NOT NULL,
    CONSTRAINT PK_partido PRIMARY KEY (id_partido),
    CONSTRAINT UQ_partido_id_partido_id_sede UNIQUE (id_partido, id_sede),
    CONSTRAINT UQ_partido_fecha_hora_utc_id_sede UNIQUE (fecha_hora_utc, id_sede),
    CONSTRAINT CK_partido_estado CHECK (estado IN ('PROGRAMADO','EN_CURSO','FINALIZADO','SUSPENDIDO')),
    CONSTRAINT CK_partido_asistencia CHECK (asistencia_publico >= 0)
);
GO

-- torneo.convocatoria: convocados de cada selección. 
CREATE TABLE torneo.convocatoria (
    id_seleccion INT NOT NULL,
    id_jugador   INT NOT NULL,
    dorsal       TINYINT NOT NULL,
    estado       VARCHAR(10) NOT NULL CONSTRAINT DF_convocatoria_estado DEFAULT 'ACTIVO',
    CONSTRAINT PK_convocatoria PRIMARY KEY (id_seleccion, id_jugador),
    CONSTRAINT UQ_convocatoria_dorsal UNIQUE (id_seleccion, dorsal),
    CONSTRAINT UQ_convocatoria_jugador UNIQUE (id_jugador),
    CONSTRAINT CK_convocatoria_dorsal CHECK (dorsal BETWEEN 1 AND 99),
    CONSTRAINT CK_convocatoria_estado CHECK (estado IN ('ACTIVO','BAJA'))
);
GO

-- publicidad.pieza_publicitaria: piezas de contenido de cada campaña (por idioma y mercado destino).
CREATE TABLE publicidad.pieza_publicitaria (
    id_pieza        INT IDENTITY(1,1) NOT NULL,
    descripcion     NVARCHAR(200) NOT NULL,
    duracion_seg    SMALLINT NOT NULL,
    formato         VARCHAR(20) NOT NULL,
    id_campania     INT NOT NULL,
    id_idioma       SMALLINT NOT NULL,
    id_pais_mercado SMALLINT NULL,
    CONSTRAINT PK_pieza_publicitaria PRIMARY KEY (id_pieza),
    CONSTRAINT CK_pieza_publicitaria_duracion_seg CHECK (duracion_seg > 0)
);
GO

-- ---------------------------------- Nivel 5 ----------------------------------
-- torneo.equipo_en_partido: las dos selecciones de cada partido (L local / V visitante) y su esquema táctico.
CREATE TABLE torneo.equipo_en_partido (
    id_partido      INT NOT NULL,
    id_seleccion    INT NOT NULL,
    condicion       CHAR(1) NOT NULL,
    esquema_tactico VARCHAR(10) NULL,
    CONSTRAINT PK_equipo_en_partido PRIMARY KEY (id_partido, id_seleccion),
    CONSTRAINT UQ_equipo_en_partido_id_partido_condicion UNIQUE (id_partido, condicion),
    CONSTRAINT CK_equipo_en_partido_condicion CHECK (condicion IN ('L','V')),
    CONSTRAINT CK_equipo_en_partido_esquema_tactico CHECK (
        esquema_tactico LIKE '[1-9]-[0-9]-[0-9]'
     OR esquema_tactico LIKE '[1-9]-[0-9]-[0-9]-[0-9]'
     OR esquema_tactico LIKE '[1-9]-[0-9]-[0-9]-[0-9]-[0-9]')
);
GO

-- torneo.cambio_convocatoria: altas y bajas de último momento (un reemplazo son dos filas: baja y alta).
CREATE TABLE torneo.cambio_convocatoria (
    id_cambio    INT IDENTITY(1,1) NOT NULL,
    id_seleccion INT NOT NULL,
    id_jugador   INT NOT NULL,
    tipo         VARCHAR(4) NOT NULL,
    motivo       NVARCHAR(200) NULL,
    fecha        DATE NOT NULL CONSTRAINT DF_cambio_convocatoria_fecha DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    CONSTRAINT PK_cambio_convocatoria PRIMARY KEY (id_cambio),
    CONSTRAINT CK_cambio_convocatoria_tipo CHECK (tipo IN ('ALTA','BAJA'))
);
GO

-- arbitraje.designacion_arbitral: terna/cuaterna arbitral de cada partido (un árbitro por rol y un rol por árbitro).
CREATE TABLE arbitraje.designacion_arbitral (
    id_partido        INT NOT NULL,
    id_rol            TINYINT NOT NULL,
    id_arbitro        INT NOT NULL,
    fecha_designacion DATETIME2(0) NOT NULL CONSTRAINT DF_designacion_arbitral_fecha_designacion DEFAULT SYSUTCDATETIME(),
    estado            VARCHAR(10) NOT NULL CONSTRAINT DF_designacion_arbitral_estado DEFAULT 'DESIGNADA',
    CONSTRAINT PK_designacion_arbitral PRIMARY KEY (id_partido, id_rol),
    CONSTRAINT UQ_designacion_arbitral_id_partido_id_arbitro UNIQUE (id_partido, id_arbitro),
    CONSTRAINT CK_designacion_arbitral_estado CHECK (estado IN ('DESIGNADA','ANULADA'))
);
GO

-- publicidad.tarifa: importe por franja horaria y moneda.
CREATE TABLE publicidad.tarifa (
    id_tarifa INT IDENTITY(1,1) NOT NULL,
    id_franja TINYINT NOT NULL,
    id_moneda TINYINT NOT NULL,
    importe   DECIMAL(18,2) NOT NULL,
    CONSTRAINT PK_tarifa PRIMARY KEY (id_tarifa),
    CONSTRAINT UQ_tarifa_id_franja_id_moneda UNIQUE (id_franja, id_moneda),
    CONSTRAINT CK_tarifa_importe CHECK (importe > 0)
);
GO

-- ---------------------------------- Nivel 6 ----------------------------------
-- juego.alineacion: titulares y suplentes de cada selección en cada partido.
CREATE TABLE juego.alineacion (
    id_partido           INT NOT NULL,
    id_seleccion         INT NOT NULL,
    id_jugador           INT NOT NULL,
    dorsal               TINYINT NOT NULL,
    es_titular           BIT NOT NULL CONSTRAINT DF_alineacion_es_titular DEFAULT 0,
    id_posicion          TINYINT NOT NULL,
    es_posicion_habitual BIT NOT NULL,
    CONSTRAINT PK_alineacion PRIMARY KEY (id_partido, id_seleccion, id_jugador),
    CONSTRAINT UQ_alineacion_id_partido_id_seleccion_dorsal UNIQUE (id_partido, id_seleccion, dorsal),
    CONSTRAINT CK_alineacion_dorsal CHECK (dorsal BETWEEN 1 AND 99)
);
GO

-- juego.sustitucion: cambios realizados en cada partido (minuto, ventana y motivo).
CREATE TABLE juego.sustitucion (
    id_partido       INT NOT NULL,
    id_seleccion     INT NOT NULL,
    nro_sustitucion  TINYINT NOT NULL,
    minuto           SMALLINT NOT NULL,
    nro_ventana      TINYINT NOT NULL,
    motivo           VARCHAR(12) NOT NULL,
    id_jugador_sale  INT NOT NULL,
    id_jugador_entra INT NOT NULL,
    CONSTRAINT PK_sustitucion PRIMARY KEY (id_partido, id_seleccion, nro_sustitucion),
    CONSTRAINT CK_sustitucion_jugadores CHECK (id_jugador_sale <> id_jugador_entra),
    CONSTRAINT CK_sustitucion_minuto CHECK (minuto BETWEEN 1 AND 130),
    CONSTRAINT CK_sustitucion_motivo CHECK (motivo IN ('TACTICO','LESION','PRECAUCION'))
);
GO

-- juego.gol: goles de cada partido. tipo_gol describe solo la jugada.
CREATE TABLE juego.gol (
    id_partido           INT NOT NULL,
    id_seleccion         INT NOT NULL,
    nro_gol              TINYINT NOT NULL,
    minuto               SMALLINT NOT NULL,
    tipo_gol             VARCHAR(15) NOT NULL,
    en_contra            BIT NOT NULL CONSTRAINT DF_gol_en_contra DEFAULT 0,
    periodo              VARCHAR(5) NOT NULL,
    id_jugador_autor     INT NOT NULL,
    id_jugador_asistente INT NULL,
    CONSTRAINT PK_gol PRIMARY KEY (id_partido, id_seleccion, nro_gol),
    CONSTRAINT CK_gol_tipo_gol CHECK (tipo_gol IN ('JUGADA','PENAL','TIRO LIBRE','CABEZA','CORNER','REBOTE','OTRO')),
    CONSTRAINT CK_gol_periodo CHECK (periodo IN ('PT','ST','ADIC','ALARG','PEN')),
    CONSTRAINT CK_gol_jugadores CHECK (id_jugador_autor <> ISNULL(id_jugador_asistente, 0)),
    CONSTRAINT CK_gol_minuto CHECK (minuto BETWEEN 0 AND 130)
);
GO

-- juego.tarjeta: tarjetas amarillas/rojas de cada partido y el árbitro que las señaló.
CREATE TABLE juego.tarjeta (
    id_partido   INT NOT NULL,
    id_seleccion INT NOT NULL,
    nro_tarjeta  TINYINT NOT NULL,
    minuto       SMALLINT NOT NULL,
    motivo       NVARCHAR(100) NULL,
    id_tipo      TINYINT NOT NULL,
    id_arbitro   INT NOT NULL,
    id_jugador   INT NOT NULL,
    CONSTRAINT PK_tarjeta PRIMARY KEY (id_partido, id_seleccion, nro_tarjeta),
    CONSTRAINT CK_tarjeta_minuto CHECK (minuto BETWEEN 0 AND 130)
);
GO

-- arbitraje.informe_post_partido: informes y sanciones posteriores al partido.
CREATE TABLE arbitraje.informe_post_partido (
    id_informe       INT IDENTITY(1,1) NOT NULL,
    fecha_informe    DATETIME2(0) NOT NULL,
    tipo             VARCHAR(30) NOT NULL,
    descripcion      NVARCHAR(1000) NOT NULL,
    sancion_aplicada NVARCHAR(200) NULL,
    CONSTRAINT PK_informe_post_partido PRIMARY KEY (id_informe)
);
GO

-- publicidad.exhibicion: registro histórico de las 4 piezas exhibidas por partido (base para facturar).
CREATE TABLE publicidad.exhibicion (
    id_exhibicion       INT IDENTITY(1,1) NOT NULL,
    id_partido          INT NOT NULL,
    id_sede             INT NOT NULL,
    nro_espacio         TINYINT NOT NULL,
    id_pieza            INT NOT NULL,
    id_tarifa           INT NOT NULL,
    fecha_hora_emision  DATETIME2(0) NOT NULL,
    orden_prioridad     TINYINT NOT NULL,
    importe_facturado   DECIMAL(18,2) NOT NULL,
    cotizacion_aplicada DECIMAL(18,6) NOT NULL,
    CONSTRAINT PK_exhibicion PRIMARY KEY (id_exhibicion),
    CONSTRAINT UQ_exhibicion_id_partido_id_sede_nro_espacio UNIQUE (id_partido, id_sede, nro_espacio),
    CONSTRAINT UQ_exhibicion_id_partido_id_pieza UNIQUE (id_partido, id_pieza),
    CONSTRAINT UQ_exhibicion_id_partido_orden_prioridad UNIQUE (id_partido, orden_prioridad),
    CONSTRAINT CK_exhibicion_orden_prioridad CHECK (orden_prioridad BETWEEN 1 AND 4)
);
GO

-- ---------------------------------- Nivel 7 ----------------------------------
-- juego.suspension: suspensiones de jugadores (por acumulación de amarillas o expulsión).
CREATE TABLE juego.suspension (
    id_suspension INT IDENTITY(1,1) NOT NULL,
    id_jugador    INT NOT NULL,
    id_criterio   INT NOT NULL,
    cant_partidos TINYINT NOT NULL,
    estado        VARCHAR(10) NOT NULL CONSTRAINT DF_suspension_estado DEFAULT 'PENDIENTE',
    fecha_alta    DATETIME2(0) NOT NULL CONSTRAINT DF_suspension_fecha_alta DEFAULT SYSUTCDATETIME(),
    motivo        NVARCHAR(200) NULL,
    CONSTRAINT PK_suspension PRIMARY KEY (id_suspension),
    CONSTRAINT CK_suspension_cant_partidos CHECK (cant_partidos >= 1),
    CONSTRAINT CK_suspension_estado CHECK (estado IN ('PENDIENTE','CUMPLIDA','ANULADA'))
);
GO

-- juego.suspension_partido: partidos en los que se cumple cada suspensión.
CREATE TABLE juego.suspension_partido (
    id_suspension INT NOT NULL,
    id_partido    INT NOT NULL,
    CONSTRAINT PK_suspension_partido PRIMARY KEY (id_suspension, id_partido)
);
GO

-- Comprobación manual (va en los scripts de testing, no acá):
--   SELECT COUNT(*) FROM sys.tables;   -- esperado: 48
