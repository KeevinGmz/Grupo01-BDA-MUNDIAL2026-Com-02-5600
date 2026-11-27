/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-26
Objetivo: Entrega 9. Geolocalización de las sedes "Seed" (17 a 24): completa latitud y longitud
          de las 8 sedes de relleno para que el mapa de sedes muestre las 24. Son estadios
          ficticios: se ubican cerca del centro de su ciudad con un desplazamiento chico por sede
          para que los pines no se superpongan. Solo toca sedes con latitud o longitud NULL, así
          que es re-ejecutable y no pisa las coordenadas reales de las 16 sedes importadas.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

DECLARE @v_centros TABLE (id_ciudad INT PRIMARY KEY, lat DECIMAL(9,6), lon DECIMAL(9,6));
INSERT INTO @v_centros (id_ciudad, lat, lon) VALUES
    (115,  -34.603700,  -58.381600),   -- Buenos Aires
    (1655,   4.711000,  -74.072100),   -- Bogotá
    (5780,  40.712800,  -74.006000);   -- New York City

UPDATE s
SET s.latitud  = c.lat + (s.id_sede % 8) * 0.004,
    s.longitud = c.lon + (s.id_sede % 8) * 0.004
FROM torneo.sede AS s
JOIN @v_centros AS c ON c.id_ciudad = s.id_ciudad
WHERE (s.latitud IS NULL OR s.longitud IS NULL)
  AND s.nombre_estadio LIKE 'Estadio Seed %';

SELECT COUNT(*) AS sedes_total,
       SUM(CASE WHEN latitud IS NOT NULL AND longitud IS NOT NULL THEN 1 ELSE 0 END) AS sedes_con_geo
FROM torneo.sede;
GO
