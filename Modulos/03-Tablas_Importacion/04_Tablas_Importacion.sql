/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Entrega 6. Crea las tablas de paso (staging) de cada importación y la tabla de equivalencias de países que usan los procesos de importación para reconocer los nombres y códigos de las fuentes externas.
===================================================================== */
USE Mundial2026;
GO

/*
   Convenciones de las tablas de paso (esquema soporte, prefijo stg_):
   - Se vacían al comienzo de cada importación del mismo tipo (no se admiten
     dos importaciones simultáneas del mismo dataset).
   - Todas las columnas de datos son texto: la conversión de tipos se hace en
     el SP de importación para poder informar el error de cada fila sin abortar
     la carga completa.
   - La columna "error" acumula los motivos por los que una fila se rechaza
     en la validación por conjuntos.
   - Las tablas que se cargan con BULK INSERT tienen una vista "_carga" con las
     columnas del archivo en el mismo orden, para dejar afuera la columna
     IDENTITY y la de error.
*/

-------------------------------------------------------------------------------
-- 0. Borrado previo (orden inverso de dependencias)
-------------------------------------------------------------------------------
DROP VIEW  IF EXISTS soporte.vw_stg_pais_csv_carga;
DROP VIEW  IF EXISTS soporte.vw_stg_huso_txt_carga;
DROP VIEW  IF EXISTS soporte.vw_stg_ciudad_txt_carga;
DROP TABLE IF EXISTS soporte.stg_pais_csv;
DROP TABLE IF EXISTS soporte.stg_huso_txt;
DROP TABLE IF EXISTS soporte.stg_ciudad_txt;
DROP TABLE IF EXISTS soporte.stg_sede_json;
DROP TABLE IF EXISTS soporte.stg_seleccion_json;
DROP TABLE IF EXISTS soporte.stg_partido_json;
DROP TABLE IF EXISTS soporte.stg_tipo_cambio;
DROP TABLE IF EXISTS soporte.stg_indicador;
DROP TABLE IF EXISTS soporte.stg_jugador_html;
DROP TABLE IF EXISTS soporte.equivalencia_pais;
GO

-------------------------------------------------------------------------------
-- 1. Equivalencias de países
--    Las fuentes identifican a los países de formas distintas: código ISO de
--    2 letras (GeoNames, openfootball) o nombre en inglés (Wikipedia,
--    openfootball, Banco Mundial). Esta tabla traduce cada identificador
--    externo al id_pais del modelo. La completan los propios SP de
--    importación mediante soporte.usp_EquivalenciaPais_Insertar.
-------------------------------------------------------------------------------
CREATE TABLE soporte.equivalencia_pais (
    id_equivalencia INT IDENTITY(1,1) NOT NULL,
    tipo            VARCHAR(10)   NOT NULL,
    valor           VARCHAR(150) NOT NULL,
    id_pais         SMALLINT      NOT NULL,
    fuente          VARCHAR(60)  NULL,
    CONSTRAINT PK_equivalencia_pais PRIMARY KEY (id_equivalencia),
    CONSTRAINT UQ_equivalencia_pais_tipo_valor UNIQUE (tipo, valor),
    CONSTRAINT CK_equivalencia_pais_tipo CHECK (tipo IN ('ISO2','NOMBRE')),
    CONSTRAINT FK_equivalencia_pais_pais FOREIGN KEY (id_pais) REFERENCES geo.pais (id_pais)
);
GO

-------------------------------------------------------------------------------
-- 2. Países y monedas: datasets/country-codes (CSV, GitHub)
--    Las 56 columnas del archivo, en el mismo orden.
-------------------------------------------------------------------------------
CREATE TABLE soporte.stg_pais_csv (
    id_stg INT IDENTITY(1,1) NOT NULL,
    fifa                                     VARCHAR(400) NULL,
    dial                                     VARCHAR(400) NULL,
    iso3166_1_alpha_3                        VARCHAR(400) NULL,
    marc                                     VARCHAR(400) NULL,
    is_independent                           VARCHAR(400) NULL,
    iso3166_1_numeric                        VARCHAR(400) NULL,
    gaul                                     VARCHAR(400) NULL,
    fips                                     VARCHAR(400) NULL,
    wmo                                      VARCHAR(400) NULL,
    iso3166_1_alpha_2                        VARCHAR(400) NULL,
    itu                                      VARCHAR(400) NULL,
    ioc                                      VARCHAR(400) NULL,
    ds                                       VARCHAR(400) NULL,
    unterm_spanish_formal                    VARCHAR(400) NULL,
    global_code                              VARCHAR(400) NULL,
    intermediate_region_code                 VARCHAR(400) NULL,
    official_name_fr                         VARCHAR(400) NULL,
    unterm_french_short                      VARCHAR(400) NULL,
    iso4217_currency_name                    VARCHAR(400) NULL,
    unterm_russian_formal                    VARCHAR(400) NULL,
    unterm_english_short                     VARCHAR(400) NULL,
    iso4217_currency_alphabetic_code         VARCHAR(400) NULL,
    small_island_developing_states_sids      VARCHAR(400) NULL,
    unterm_spanish_short                     VARCHAR(400) NULL,
    iso4217_currency_numeric_code            VARCHAR(400) NULL,
    unterm_chinese_formal                    VARCHAR(400) NULL,
    unterm_french_formal                     VARCHAR(400) NULL,
    unterm_russian_short                     VARCHAR(400) NULL,
    m49                                      VARCHAR(400) NULL,
    sub_region_code                          VARCHAR(400) NULL,
    region_code                              VARCHAR(400) NULL,
    official_name_ar                         VARCHAR(400) NULL,
    iso4217_currency_minor_unit              VARCHAR(400) NULL,
    unterm_arabic_formal                     VARCHAR(400) NULL,
    unterm_chinese_short                     VARCHAR(400) NULL,
    land_locked_developing_countries_lldc    VARCHAR(400) NULL,
    intermediate_region_name                 VARCHAR(400) NULL,
    official_name_es                         VARCHAR(400) NULL,
    unterm_english_formal                    VARCHAR(400) NULL,
    official_name_cn                         VARCHAR(400) NULL,
    official_name_en                         VARCHAR(400) NULL,
    iso4217_currency_country_name            VARCHAR(400) NULL,
    least_developed_countries_ldc            VARCHAR(400) NULL,
    region_name                              VARCHAR(400) NULL,
    unterm_arabic_short                      VARCHAR(400) NULL,
    sub_region_name                          VARCHAR(400) NULL,
    official_name_ru                         VARCHAR(400) NULL,
    global_name                              VARCHAR(400) NULL,
    capital                                  VARCHAR(400) NULL,
    continent                                VARCHAR(400) NULL,
    tld                                      VARCHAR(400) NULL,
    languages                                VARCHAR(400) NULL,
    geoname_id                               VARCHAR(400) NULL,
    cldr_display_name                        VARCHAR(400) NULL,
    edgar                                    VARCHAR(400) NULL,
    wikidata_id                              VARCHAR(400) NULL,
    error VARCHAR(1000) NULL,
    CONSTRAINT PK_stg_pais_csv PRIMARY KEY (id_stg)
);
GO

CREATE VIEW soporte.vw_stg_pais_csv_carga
AS
SELECT
    fifa,
    dial,
    iso3166_1_alpha_3,
    marc,
    is_independent,
    iso3166_1_numeric,
    gaul,
    fips,
    wmo,
    iso3166_1_alpha_2,
    itu,
    ioc,
    ds,
    unterm_spanish_formal,
    global_code,
    intermediate_region_code,
    official_name_fr,
    unterm_french_short,
    iso4217_currency_name,
    unterm_russian_formal,
    unterm_english_short,
    iso4217_currency_alphabetic_code,
    small_island_developing_states_sids,
    unterm_spanish_short,
    iso4217_currency_numeric_code,
    unterm_chinese_formal,
    unterm_french_formal,
    unterm_russian_short,
    m49,
    sub_region_code,
    region_code,
    official_name_ar,
    iso4217_currency_minor_unit,
    unterm_arabic_formal,
    unterm_chinese_short,
    land_locked_developing_countries_lldc,
    intermediate_region_name,
    official_name_es,
    unterm_english_formal,
    official_name_cn,
    official_name_en,
    iso4217_currency_country_name,
    least_developed_countries_ldc,
    region_name,
    unterm_arabic_short,
    sub_region_name,
    official_name_ru,
    global_name,
    capital,
    continent,
    tld,
    languages,
    geoname_id,
    cldr_display_name,
    edgar,
    wikidata_id
FROM soporte.stg_pais_csv;
GO

-------------------------------------------------------------------------------
-- 3. Husos horarios: GeoNames timeZones.txt (texto separado por tabulaciones)
-------------------------------------------------------------------------------
CREATE TABLE soporte.stg_huso_txt (
    id_stg         INT IDENTITY(1,1) NOT NULL,
    cod_pais       VARCHAR(20)  NULL,
    zona_horaria   VARCHAR(100) NULL,
    offset_enero   VARCHAR(20)  NULL,
    offset_julio   VARCHAR(20)  NULL,
    offset_base    VARCHAR(20)  NULL,
    error          VARCHAR(1000) NULL,
    CONSTRAINT PK_stg_huso_txt PRIMARY KEY (id_stg)
);
GO

CREATE VIEW soporte.vw_stg_huso_txt_carga
AS
SELECT cod_pais, zona_horaria, offset_enero, offset_julio, offset_base
FROM soporte.stg_huso_txt;
GO

-------------------------------------------------------------------------------
-- 4. Ciudades: GeoNames cities15000.txt (19 columnas separadas por tabulaciones)
-------------------------------------------------------------------------------
CREATE TABLE soporte.stg_ciudad_txt (
    id_stg               INT IDENTITY(1,1) NOT NULL,
    geonameid            VARCHAR(20)  NULL,
    nombre               NVARCHAR(200) NULL,
    nombre_ascii         VARCHAR(200) NULL,
    nombres_alternativos VARCHAR(MAX) NULL,
    latitud              VARCHAR(30)  NULL,
    longitud             VARCHAR(30)  NULL,
    clase                VARCHAR(10)  NULL,
    codigo_tipo          VARCHAR(20)  NULL,
    cod_pais             VARCHAR(10)  NULL,
    cc2                  VARCHAR(400) NULL,
    admin1               VARCHAR(30)  NULL,
    admin2               VARCHAR(100) NULL,
    admin3               VARCHAR(30)  NULL,
    admin4               VARCHAR(30)  NULL,
    poblacion            VARCHAR(30)  NULL,
    elevacion            VARCHAR(30)  NULL,
    dem                  VARCHAR(30)  NULL,
    zona_horaria         VARCHAR(100) NULL,
    fecha_modificacion   VARCHAR(30)  NULL,
    error                VARCHAR(1000) NULL,
    CONSTRAINT PK_stg_ciudad_txt PRIMARY KEY (id_stg)
);
GO

CREATE VIEW soporte.vw_stg_ciudad_txt_carga
AS
SELECT geonameid, nombre, nombre_ascii, nombres_alternativos, latitud, longitud,
       clase, codigo_tipo, cod_pais, cc2, admin1, admin2, admin3, admin4,
       poblacion, elevacion, dem, zona_horaria, fecha_modificacion
FROM soporte.stg_ciudad_txt;
GO

-------------------------------------------------------------------------------
-- 5. Sedes: openfootball worldcup.stadiums.json
-------------------------------------------------------------------------------
CREATE TABLE soporte.stg_sede_json (
    nro_fila     INT            NOT NULL,
    estadio      VARCHAR(200)  NULL,
    ciudad_texto VARCHAR(200)  NULL,
    cod_pais     VARCHAR(10)   NULL,
    zona_texto   VARCHAR(20)   NULL,
    capacidad    VARCHAR(30)   NULL,
    coordenadas  VARCHAR(100)  NULL,
    error        VARCHAR(1000) NULL,
    CONSTRAINT PK_stg_sede_json PRIMARY KEY (nro_fila)
);
GO

-------------------------------------------------------------------------------
-- 6. Selecciones: openfootball worldcup.teams.json
-------------------------------------------------------------------------------
CREATE TABLE soporte.stg_seleccion_json (
    nro_fila          INT            NOT NULL,
    nombre            VARCHAR(150)  NULL,
    nombre_normalizado VARCHAR(150) NULL,
    cod_fifa          VARCHAR(10)   NULL,
    grupo             VARCHAR(10)   NULL,
    confederacion     VARCHAR(20)   NULL,
    error             VARCHAR(1000) NULL,
    CONSTRAINT PK_stg_seleccion_json PRIMARY KEY (nro_fila)
);
GO

-------------------------------------------------------------------------------
-- 7. Fixture: openfootball worldcup.json
-------------------------------------------------------------------------------
CREATE TABLE soporte.stg_partido_json (
    nro_fila    INT            NOT NULL,
    ronda       VARCHAR(60)   NULL,
    numero      VARCHAR(10)   NULL,
    fecha       VARCHAR(20)   NULL,
    hora        VARCHAR(30)   NULL,
    equipo1     VARCHAR(150)  NULL,
    equipo2     VARCHAR(150)  NULL,
    grupo       VARCHAR(30)   NULL,
    sede_texto  VARCHAR(200)  NULL,
    error       VARCHAR(1000) NULL,
    CONSTRAINT PK_stg_partido_json PRIMARY KEY (nro_fila)
);
GO

-------------------------------------------------------------------------------
-- 8. Tipos de cambio: BCE (XML) y API Frankfurter (JSON)
-------------------------------------------------------------------------------
CREATE TABLE soporte.stg_tipo_cambio (
    nro_fila      INT            NOT NULL,
    fecha         VARCHAR(20)   NULL,
    moneda        VARCHAR(10)   NULL,
    valor         VARCHAR(40)   NULL,
    moneda_base   VARCHAR(10)   NULL,
    error         VARCHAR(1000) NULL,
    CONSTRAINT PK_stg_tipo_cambio PRIMARY KEY (nro_fila)
);
GO

-------------------------------------------------------------------------------
-- 9. Indicadores económicos: API del Banco Mundial (JSON)
-------------------------------------------------------------------------------
CREATE TABLE soporte.stg_indicador (
    nro_fila   INT            NOT NULL,
    cod_iso3   VARCHAR(10)   NULL,
    pais_texto VARCHAR(150)  NULL,
    indicador  VARCHAR(40)   NULL,
    anio       VARCHAR(10)   NULL,
    valor      VARCHAR(60)   NULL,
    error      VARCHAR(1000) NULL,
    CONSTRAINT PK_stg_indicador PRIMARY KEY (nro_fila)
);
GO

-------------------------------------------------------------------------------
-- 10. Plantillas: scraping de Wikipedia (HTML)
-------------------------------------------------------------------------------
CREATE TABLE soporte.stg_jugador_html (
    nro_fila        INT            NOT NULL,
    seleccion_texto VARCHAR(150)  NULL,
    dorsal          VARCHAR(20)   NULL,
    posicion        VARCHAR(20)   NULL,
    jugador         NVARCHAR(200)  NULL,
    clave_orden     VARCHAR(200)  NULL,
    fecha_nac       VARCHAR(20)   NULL,
    club            NVARCHAR(200)  NULL,
    club_pais       VARCHAR(100)  NULL,
    error           VARCHAR(1000) NULL,
    CONSTRAINT PK_stg_jugador_html PRIMARY KEY (nro_fila)
);
GO

-- Comprobación manual (va en los scripts de testing):
--   SELECT name FROM sys.tables WHERE schema_id = SCHEMA_ID('soporte') AND name LIKE 'stg[_]%';  -- esperado: 9
