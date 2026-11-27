USE Mundial2026;
GO
/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 9. Objetos de lectura que usa la aplicación Streamlit, para que la app
          no escriba SQL y solo llame a procedimientos y vistas:
            - torneo.vw_SedeDetalle         : sede con ciudad y país (listado y mapa).
            - torneo.usp_Sede_Listar        : listado de sedes con filtro opcional.
            - geo.usp_Ciudad_Buscar         : búsqueda de ciudades para el alta/modificación de sedes.
            - soporte.usp_Importacion_Resumen: resumen y errores de una importación (pantalla de importación).
          Re-ejecutable (CREATE OR ALTER). No modifica datos.
===================================================================== */

CREATE OR ALTER VIEW torneo.vw_SedeDetalle
AS
SELECT s.id_sede,
       s.nombre_estadio,
       s.capacidad,
       s.direccion,
       s.latitud,
       s.longitud,
       s.id_ciudad,
       c.nombre AS ciudad,
       p.nombre AS pais
FROM torneo.sede AS s
JOIN geo.ciudad  AS c ON c.id_ciudad = s.id_ciudad
JOIN geo.pais    AS p ON p.id_pais   = c.id_pais;
GO

CREATE OR ALTER PROCEDURE torneo.usp_Sede_Listar
    @texto VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_texto VARCHAR(100) = NULLIF(LTRIM(RTRIM(@texto)), '');

    SELECT id_sede, nombre_estadio, capacidad, direccion, latitud, longitud, id_ciudad, ciudad, pais
    FROM torneo.vw_SedeDetalle
    WHERE @v_texto IS NULL
       OR nombre_estadio LIKE '%' + @v_texto + '%'
       OR ciudad         LIKE '%' + @v_texto + '%'
       OR pais           LIKE '%' + @v_texto + '%'
    ORDER BY id_sede;
END
GO

CREATE OR ALTER PROCEDURE geo.usp_Ciudad_Buscar
    @texto VARCHAR(100),
    @max   INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_texto VARCHAR(100) = LTRIM(RTRIM(ISNULL(@texto, '')));

    IF LEN(@v_texto) < 2
        THROW 50001, 'geo.usp_Ciudad_Buscar: ingresar al menos 2 caracteres', 1;
    IF @max IS NULL OR @max < 1 OR @max > 200
        SET @max = 50;

    SELECT TOP (@max) c.id_ciudad, c.nombre AS ciudad, p.nombre AS pais, c.poblacion
    FROM geo.ciudad AS c
    JOIN geo.pais   AS p ON p.id_pais = c.id_pais
    WHERE c.nombre LIKE @v_texto + '%'
    ORDER BY c.poblacion DESC, c.nombre;
END
GO

CREATE OR ALTER PROCEDURE soporte.usp_Importacion_Resumen
    @id_importacion INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM soporte.importacion WHERE id_importacion = @id_importacion)
        THROW 50001, 'soporte.usp_Importacion_Resumen: importacion inexistente', 1;

    SELECT id_importacion, fuente, archivo, formato, fecha_inicio, fecha_fin,
           filas_leidas, filas_ok, filas_error, estado
    FROM soporte.importacion
    WHERE id_importacion = @id_importacion;

    SELECT TOP (200) nro_error, nro_fila, columna, valor, mensaje
    FROM soporte.importacion_error
    WHERE id_importacion = @id_importacion
    ORDER BY nro_error;
END
GO

-- Permisos: quien administra y quien consulta pueden listar sedes y buscar ciudades.
IF DATABASE_PRINCIPAL_ID('rol_administrador') IS NOT NULL
BEGIN
    GRANT SELECT  ON torneo.vw_SedeDetalle  TO rol_administrador;
    GRANT EXECUTE ON torneo.usp_Sede_Listar TO rol_administrador;
    GRANT EXECUTE ON geo.usp_Ciudad_Buscar  TO rol_administrador;
END
IF DATABASE_PRINCIPAL_ID('rol_consulta') IS NOT NULL
BEGIN
    GRANT SELECT  ON torneo.vw_SedeDetalle  TO rol_consulta;
    GRANT EXECUTE ON torneo.usp_Sede_Listar TO rol_consulta;
END
GO
