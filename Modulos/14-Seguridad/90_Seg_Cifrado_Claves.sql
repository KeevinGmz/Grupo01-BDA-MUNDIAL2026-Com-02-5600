/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-17
Objetivo: Entrega 8. Cifrado (1/4): esquema seguridad, clave de cifrado y procedimientos de apertura y cierre de la clave.
          Crea el esquema seguridad y el SP seguridad.usp_Cifrado_Configurar, que
          genera (si no existen) la clave maestra de la base, el certificado y la
          clave simétrica AES-256 con la que se cifran los datos personales de
          jugadores, cuerpos técnicos y árbitros. Los SP usp_AbrirClave y
          usp_CerrarClave son la única forma de abrir la clave: se ejecutan con
          los permisos del dueño (EXECUTE AS OWNER), de modo que los roles de
          negocio NO necesitan permisos sobre la clave ni el certificado.
          Pasos siguientes: 91 (tablas), 92 (SP modificados), 93 (roles).
          IMPORTANTE: la contraseña de la clave maestra de este script es un
          valor de ejemplo. En producción se reemplaza por un secreto propio
          que no se sube al repositorio.
===================================================================== */
USE Mundial2026;
GO

IF SCHEMA_ID('seguridad') IS NULL
BEGIN
    EXEC ('CREATE SCHEMA seguridad');
    PRINT 'Esquema seguridad CREADO correctamente';
END
ELSE
BEGIN
    PRINT 'El esquema seguridad ya existe';
END;
GO

/* ---------------------------------------------------------------------
   usp_Cifrado_Configurar: crea la jerarquía de cifrado de la base
     clave maestra de la base (DMK)
       -> certificado cert_Mundial2026_Datos
            -> clave simétrica sk_Mundial2026_Datos (AES_256)
   Es idempotente: cada objeto se crea solo si no existe.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE seguridad.usp_Cifrado_Configurar
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = N'##MS_DatabaseMasterKey##')
    BEGIN
        CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Cambiar#Mundial2026_ClaveMaestra!';
        PRINT 'Clave maestra de la base CREADA';
    END
    ELSE
        PRINT 'La clave maestra de la base ya existe';

    IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = N'cert_Mundial2026_Datos')
    BEGIN
        CREATE CERTIFICATE cert_Mundial2026_Datos
            WITH SUBJECT = 'Mundial 2026 - proteccion de datos personales',
                 EXPIRY_DATE = '20361231';
        PRINT 'Certificado cert_Mundial2026_Datos CREADO';
    END
    ELSE
        PRINT 'El certificado cert_Mundial2026_Datos ya existe';

    IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = N'sk_Mundial2026_Datos')
    BEGIN
        CREATE SYMMETRIC KEY sk_Mundial2026_Datos
            WITH ALGORITHM = AES_256
            ENCRYPTION BY CERTIFICATE cert_Mundial2026_Datos;
        PRINT 'Clave simetrica sk_Mundial2026_Datos CREADA';
    END
    ELSE
        PRINT 'La clave simetrica sk_Mundial2026_Datos ya existe';
END
GO

/* ---------------------------------------------------------------------
   usp_AbrirClave: abre la clave simétrica en la sesión actual.
     @abrio    = 1 si esta llamada abrió la clave (quien la abre debe cerrarla),
                 0 si ya estaba abierta (quien la encontró abierta no la cierra).
     @key_guid = identificador de la clave, para ENCRYPTBYKEY.
   Se ejecuta con los permisos del dueño: el llamador no necesita permisos
   sobre la clave ni el certificado, solo EXECUTE sobre este SP (o llegar a él
   desde un SP del mismo dueño, por encadenamiento de propiedad).
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE seguridad.usp_AbrirClave
    @abrio BIT = 0 OUTPUT,
    @key_guid UNIQUEIDENTIFIER = NULL OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET @abrio = 0;

    IF NOT EXISTS (SELECT 1 FROM sys.openkeys
                   WHERE key_name = N'sk_Mundial2026_Datos' AND database_id = DB_ID())
    BEGIN
        OPEN SYMMETRIC KEY sk_Mundial2026_Datos DECRYPTION BY CERTIFICATE cert_Mundial2026_Datos;
        SET @abrio = 1;
    END

    SET @key_guid = KEY_GUID(N'sk_Mundial2026_Datos');
END
GO

/* ---------------------------------------------------------------------
   usp_CerrarClave: cierra la clave simétrica de la sesión (si está abierta).
   No propaga errores: se la invoca también desde bloques CATCH.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE seguridad.usp_CerrarClave
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM sys.openkeys
                   WHERE key_name = N'sk_Mundial2026_Datos' AND database_id = DB_ID())
            CLOSE SYMMETRIC KEY sk_Mundial2026_Datos;
    END TRY
    BEGIN CATCH
        DECLARE @v_ignorado INT = ERROR_NUMBER();
    END CATCH
END
GO

EXEC seguridad.usp_Cifrado_Configurar;
GO
