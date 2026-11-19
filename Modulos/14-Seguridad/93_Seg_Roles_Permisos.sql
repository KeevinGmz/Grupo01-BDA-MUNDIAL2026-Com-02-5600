/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-17
Objetivo: Entrega 8. Roles de seguridad (4 roles con permisos granulares), usuarios de prueba y cuadro de permisos.
          Crea el SP seguridad.usp_Roles_Configurar, que crea los roles y asigna
          GRANT / DENY sobre esquemas y objetos. Los roles no reciben permisos
          sobre las tablas: operan mediante SP y vistas (encadenamiento de
          propiedad), de modo que los datos personales cifrados solo se ven a
          través de los SP de consulta.
            rol_administrador        gestiona todos los datos; ve datos personales descifrados
            rol_cargador_resultados  carga alineaciones, goles, tarjetas, cierra partidos
            rol_gestor_publicidad    gestiona anunciantes, campañas, tarifas y asignaciones
            rol_consulta             solo lectura de reportes y vistas; datos personales enmascarados
          El cuadro de permisos queda en la tabla seguridad.permiso_rol (se
          regenera desde el catálogo del servidor) y en el documento PDF.
          También crea los usuarios de prueba (sin login) que usan los scripts
          95 a 98 con EXECUTE AS USER.
          En un ambiente real, cada persona usa un LOGIN propio asignado al rol
          (ver ejemplo comentado al final); las contraseñas no se guardan acá.
===================================================================== */
USE Mundial2026;
GO

-- Cuadro de permisos (documentación consultable). Se regenera con usp_Roles_Configurar.
IF OBJECT_ID('seguridad.permiso_rol', 'U') IS NULL
BEGIN
    CREATE TABLE seguridad.permiso_rol (
        id_permiso   INT IDENTITY(1,1) NOT NULL,
        rol          SYSNAME       NOT NULL,
        accion       VARCHAR(10)   NOT NULL,   -- GRANT o DENY
        permiso      VARCHAR(30)   NOT NULL,   -- SELECT, EXECUTE, INSERT, UPDATE, DELETE
        tipo_recurso VARCHAR(20)   NOT NULL,   -- SCHEMA u OBJECT_OR_COLUMN
        recurso      VARCHAR(200)  NOT NULL,
        CONSTRAINT PK_permiso_rol PRIMARY KEY (id_permiso),
        CONSTRAINT CK_permiso_rol_accion CHECK (accion IN ('GRANT','DENY'))
    );
    PRINT 'Tabla seguridad.permiso_rol CREADA';
END
GO

CREATE OR ALTER PROCEDURE seguridad.usp_Roles_Configurar
AS
BEGIN
    SET NOCOUNT ON;

    ---------------------------------------------------------------------------
    -- 1. Roles
    ---------------------------------------------------------------------------
    IF DATABASE_PRINCIPAL_ID('rol_administrador') IS NULL CREATE ROLE rol_administrador;
    IF DATABASE_PRINCIPAL_ID('rol_cargador_resultados') IS NULL CREATE ROLE rol_cargador_resultados;
    IF DATABASE_PRINCIPAL_ID('rol_gestor_publicidad') IS NULL CREATE ROLE rol_gestor_publicidad;
    IF DATABASE_PRINCIPAL_ID('rol_consulta') IS NULL CREATE ROLE rol_consulta;

    ---------------------------------------------------------------------------
    -- 2. rol_administrador: administración funcional de todos los datos.
    --    No modifica la estructura (sin ALTER ni CREATE) ni la seguridad.
    ---------------------------------------------------------------------------
    GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::geo        TO rol_administrador;
    GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::persona    TO rol_administrador;
    GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::torneo     TO rol_administrador;
    GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::juego      TO rol_administrador;
    GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::arbitraje  TO rol_administrador;
    GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::publicidad TO rol_administrador;
    GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::soporte    TO rol_administrador;
    GRANT EXECUTE ON SCHEMA::reporte TO rol_administrador;
    -- Datos personales descifrados: solo el administrador puede abrir la clave.
    GRANT EXECUTE ON OBJECT::seguridad.usp_AbrirClave  TO rol_administrador;
    GRANT EXECUTE ON OBJECT::seguridad.usp_CerrarClave TO rol_administrador;

    ---------------------------------------------------------------------------
    -- 3. rol_cargador_resultados: carga de datos de los partidos jugados.
    --    Solo por SP (no escribe tablas directamente). Puede corregir un gol o
    --    una tarjeta (Modificar) pero no eliminarlos. No ve datos personales
    --    completos ni publicidad ni importaciones.
    ---------------------------------------------------------------------------
    GRANT EXECUTE ON OBJECT::torneo.usp_Negocio_CerrarPartido        TO rol_cargador_resultados;
    GRANT EXECUTE ON OBJECT::juego.usp_Negocio_RegistrarAlineacion   TO rol_cargador_resultados;
    GRANT EXECUTE ON OBJECT::juego.usp_Negocio_RegistrarSustitucion  TO rol_cargador_resultados;
    GRANT EXECUTE ON OBJECT::juego.usp_Negocio_RegistrarGol          TO rol_cargador_resultados;
    GRANT EXECUTE ON OBJECT::juego.usp_Negocio_RegistrarTarjeta      TO rol_cargador_resultados;
    GRANT EXECUTE ON OBJECT::juego.usp_Gol_Modificar                 TO rol_cargador_resultados;
    GRANT EXECUTE ON OBJECT::juego.usp_Tarjeta_Modificar             TO rol_cargador_resultados;
    GRANT SELECT  ON OBJECT::juego.vw_MarcadorPartido                TO rol_cargador_resultados;
    GRANT SELECT  ON OBJECT::juego.vw_Goleadores                     TO rol_cargador_resultados;
    GRANT SELECT  ON OBJECT::juego.vw_TarjetasAcumuladas             TO rol_cargador_resultados;
    GRANT SELECT  ON OBJECT::torneo.vw_ResultadoEquipo               TO rol_cargador_resultados;
    GRANT SELECT  ON OBJECT::torneo.vw_PosicionesGrupo               TO rol_cargador_resultados;
    GRANT EXECUTE ON OBJECT::reporte.usp_Resultados                  TO rol_cargador_resultados;
    GRANT EXECUTE ON OBJECT::reporte.usp_Goleadores                  TO rol_cargador_resultados;
    GRANT EXECUTE ON OBJECT::reporte.usp_Tarjetas                    TO rol_cargador_resultados;
    GRANT EXECUTE ON OBJECT::persona.usp_Persona_ConsultarEnmascarado TO rol_cargador_resultados;
    DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::persona    TO rol_cargador_resultados;
    DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::publicidad TO rol_cargador_resultados;
    DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::soporte    TO rol_cargador_resultados;
    DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::seguridad  TO rol_cargador_resultados;
    DENY INSERT, UPDATE, DELETE ON SCHEMA::juego              TO rol_cargador_resultados;
    DENY INSERT, UPDATE, DELETE ON SCHEMA::torneo             TO rol_cargador_resultados;

    ---------------------------------------------------------------------------
    -- 4. rol_gestor_publicidad: gestión comercial. Opera por SP sobre el
    --    esquema publicidad; ve los reportes publicitarios. Sin acceso a
    --    datos personales, resultados ni importaciones.
    ---------------------------------------------------------------------------
    GRANT EXECUTE, SELECT ON SCHEMA::publicidad TO rol_gestor_publicidad;
    GRANT EXECUTE ON OBJECT::reporte.usp_OcupacionPublicitaria TO rol_gestor_publicidad;
    GRANT EXECUTE ON OBJECT::reporte.usp_MatrizPrimeTime       TO rol_gestor_publicidad;
    DENY INSERT, UPDATE, DELETE ON SCHEMA::publicidad TO rol_gestor_publicidad;
    DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::persona   TO rol_gestor_publicidad;
    DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::soporte   TO rol_gestor_publicidad;
    DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::seguridad TO rol_gestor_publicidad;
    DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::juego     TO rol_gestor_publicidad;
    DENY INSERT, UPDATE, DELETE ON SCHEMA::torneo            TO rol_gestor_publicidad;
    DENY INSERT, UPDATE, DELETE ON SCHEMA::geo               TO rol_gestor_publicidad;

    ---------------------------------------------------------------------------
    -- 5. rol_consulta: solo lectura. Reportes, vistas y datos geográficos;
    --    datos personales únicamente enmascarados. Ninguna escritura.
    ---------------------------------------------------------------------------
    GRANT EXECUTE ON SCHEMA::reporte TO rol_consulta;
    GRANT SELECT  ON SCHEMA::geo     TO rol_consulta;
    GRANT SELECT  ON OBJECT::juego.vw_MarcadorPartido         TO rol_consulta;
    GRANT SELECT  ON OBJECT::juego.vw_Goleadores              TO rol_consulta;
    GRANT SELECT  ON OBJECT::juego.vw_TarjetasAcumuladas      TO rol_consulta;
    GRANT SELECT  ON OBJECT::torneo.vw_ResultadoEquipo        TO rol_consulta;
    GRANT SELECT  ON OBJECT::torneo.vw_GrupoConteoEquipos     TO rol_consulta;
    GRANT SELECT  ON OBJECT::torneo.vw_PosicionesGrupo        TO rol_consulta;
    GRANT SELECT  ON OBJECT::torneo.vw_SeleccionesEliminadas  TO rol_consulta;
    GRANT EXECUTE ON OBJECT::persona.usp_Persona_ConsultarEnmascarado TO rol_consulta;
    DENY SELECT ON SCHEMA::persona    TO rol_consulta;
    DENY SELECT ON SCHEMA::publicidad TO rol_consulta;
    DENY SELECT ON SCHEMA::soporte    TO rol_consulta;
    DENY SELECT ON SCHEMA::seguridad  TO rol_consulta;
    DENY INSERT, UPDATE, DELETE ON SCHEMA::geo        TO rol_consulta;
    DENY INSERT, UPDATE, DELETE ON SCHEMA::persona    TO rol_consulta;
    DENY INSERT, UPDATE, DELETE ON SCHEMA::torneo     TO rol_consulta;
    DENY INSERT, UPDATE, DELETE ON SCHEMA::juego      TO rol_consulta;
    DENY INSERT, UPDATE, DELETE ON SCHEMA::arbitraje  TO rol_consulta;
    DENY INSERT, UPDATE, DELETE ON SCHEMA::publicidad TO rol_consulta;
    DENY INSERT, UPDATE, DELETE ON SCHEMA::soporte    TO rol_consulta;

    ---------------------------------------------------------------------------
    -- 6. Cuadro de permisos: se regenera desde el catálogo (siempre coincide
    --    con lo realmente otorgado).
    ---------------------------------------------------------------------------
    DELETE FROM seguridad.permiso_rol;

    INSERT INTO seguridad.permiso_rol (rol, accion, permiso, tipo_recurso, recurso)
    SELECT pr.name,
           dp.state_desc,
           dp.permission_name,
           CASE dp.class WHEN 3 THEN 'SCHEMA' ELSE 'OBJECT_OR_COLUMN' END,
           CASE dp.class
                WHEN 3 THEN CONCAT('SCHEMA::', sc.name)
                ELSE CONCAT(SCHEMA_NAME(o.schema_id), '.', o.name)
           END
    FROM sys.database_permissions AS dp
    JOIN sys.database_principals AS pr ON pr.principal_id = dp.grantee_principal_id
    LEFT JOIN sys.schemas AS sc ON dp.class = 3 AND sc.schema_id = dp.major_id
    LEFT JOIN sys.objects AS o  ON dp.class = 1 AND o.object_id = dp.major_id
    WHERE pr.name IN (N'rol_administrador', N'rol_cargador_resultados', N'rol_gestor_publicidad', N'rol_consulta')
      AND dp.class IN (1, 3)
      AND dp.state IN ('G', 'D');

    DECLARE @v_total INT = (SELECT COUNT(*) FROM seguridad.permiso_rol);
    PRINT CONCAT('Roles configurados. Permisos registrados: ', @v_total);
END
GO

/* ---------------------------------------------------------------------
   Usuarios de prueba: usuarios SIN login (solo existen dentro de la base y
   solo se pueden usar con EXECUTE AS USER). Cada script de test (95 a 98)
   se ejecuta como uno de ellos.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE seguridad.usp_Usuarios_Prueba_Crear
AS
BEGIN
    SET NOCOUNT ON;
    IF DATABASE_PRINCIPAL_ID('usr_admin_test') IS NULL           CREATE USER usr_admin_test WITHOUT LOGIN;
    IF DATABASE_PRINCIPAL_ID('usr_cargador_test') IS NULL        CREATE USER usr_cargador_test WITHOUT LOGIN;
    IF DATABASE_PRINCIPAL_ID('usr_gestor_publicidad_test') IS NULL CREATE USER usr_gestor_publicidad_test WITHOUT LOGIN;
    IF DATABASE_PRINCIPAL_ID('usr_consulta_test') IS NULL        CREATE USER usr_consulta_test WITHOUT LOGIN;

    ALTER ROLE rol_administrador       ADD MEMBER usr_admin_test;
    ALTER ROLE rol_cargador_resultados ADD MEMBER usr_cargador_test;
    ALTER ROLE rol_gestor_publicidad   ADD MEMBER usr_gestor_publicidad_test;
    ALTER ROLE rol_consulta            ADD MEMBER usr_consulta_test;
    PRINT 'Usuarios de prueba creados y asignados a sus roles';
END
GO

CREATE OR ALTER PROCEDURE seguridad.usp_Usuarios_Prueba_Eliminar
AS
BEGIN
    SET NOCOUNT ON;
    IF DATABASE_PRINCIPAL_ID('usr_admin_test') IS NOT NULL            DROP USER usr_admin_test;
    IF DATABASE_PRINCIPAL_ID('usr_cargador_test') IS NOT NULL         DROP USER usr_cargador_test;
    IF DATABASE_PRINCIPAL_ID('usr_gestor_publicidad_test') IS NOT NULL DROP USER usr_gestor_publicidad_test;
    IF DATABASE_PRINCIPAL_ID('usr_consulta_test') IS NOT NULL         DROP USER usr_consulta_test;
    PRINT 'Usuarios de prueba eliminados';
END
GO

EXEC seguridad.usp_Roles_Configurar;
GO
EXEC seguridad.usp_Usuarios_Prueba_Crear;
GO

-- Cuadro de permisos resultante (resumen por rol y recurso)
SELECT rol, accion, recurso, STRING_AGG(permiso, ', ') WITHIN GROUP (ORDER BY permiso) AS permisos
FROM seguridad.permiso_rol
GROUP BY rol, accion, recurso
ORDER BY rol, accion DESC, recurso;
GO

/* ---------------------------------------------------------------------
   Ambiente real (NO se ejecuta; la contraseña se define fuera del repositorio):

   CREATE LOGIN [operador_resultados] WITH PASSWORD = '<definir fuera del repositorio>';
   CREATE USER  [operador_resultados] FOR LOGIN [operador_resultados];
   ALTER ROLE rol_cargador_resultados ADD MEMBER [operador_resultados];
   --------------------------------------------------------------------- */
