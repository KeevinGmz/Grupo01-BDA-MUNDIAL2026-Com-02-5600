/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-17
Objetivo: Entrega 8. Cifrado (2/4): modificación de persona.persona y migración de los datos existentes.
          Reemplaza las columnas en texto plano nro_doc y fecha_nac por:
            nro_doc_cif   documento cifrado (AES-256, VARBINARY)
            fecha_nac_cif fecha de nacimiento cifrada (AES-256, VARBINARY)
            nro_doc_hash  SHA-256 del documento: permite buscar y garantizar la
                          unicidad (tipo_doc, documento) sin descifrar.
          Nombre y apellido se dejan sin cifrar: son datos públicos de personas
          públicas (plantillas oficiales) y los reportes los muestran.
          Crea las funciones de hash y de descifrado y el SP de migración
          seguridad.usp_Cifrado_MigrarPersonas (idempotente: si la tabla ya
          está migrada no hace nada).
          Requiere haber ejecutado 90_Seg_Cifrado_Claves.sql.
===================================================================== */
USE Mundial2026;
GO

-- Hash determinístico del documento (búsqueda e índice único sobre datos cifrados).
-- Normaliza espacios y mayúsculas. La cadena fija evita hashes "de diccionario" genéricos.
CREATE OR ALTER FUNCTION persona.fn_HashDocumento (@nro_doc NVARCHAR(30))
RETURNS VARBINARY(32)
AS
BEGIN
    RETURN HASHBYTES('SHA2_256', CONCAT(N'M26|doc|', UPPER(LTRIM(RTRIM(@nro_doc)))));
END
GO

-- Descifrado: requieren la clave abierta en la sesión (seguridad.usp_AbrirClave).
-- Con la clave cerrada devuelven NULL.
CREATE OR ALTER FUNCTION persona.fn_NroDocDescifrado (@nro_doc_cif VARBINARY(256))
RETURNS NVARCHAR(30)
AS
BEGIN
    RETURN CONVERT(NVARCHAR(30), DECRYPTBYKEY(@nro_doc_cif));
END
GO

CREATE OR ALTER FUNCTION persona.fn_FechaNacDescifrada (@fecha_nac_cif VARBINARY(128))
RETURNS DATE
AS
BEGIN
    RETURN TRY_CONVERT(DATE, CONVERT(VARCHAR(10), DECRYPTBYKEY(@fecha_nac_cif)), 23);
END
GO

-- 1) Columnas nuevas (nulas hasta migrar)
IF COL_LENGTH('persona.persona', 'nro_doc_cif') IS NULL
    ALTER TABLE persona.persona ADD nro_doc_cif VARBINARY(256) NULL;
GO
IF COL_LENGTH('persona.persona', 'fecha_nac_cif') IS NULL
    ALTER TABLE persona.persona ADD fecha_nac_cif VARBINARY(128) NULL;
GO
IF COL_LENGTH('persona.persona', 'nro_doc_hash') IS NULL
    ALTER TABLE persona.persona ADD nro_doc_hash VARBINARY(32) NULL;
GO

/* ---------------------------------------------------------------------
   usp_Cifrado_MigrarPersonas
   Cifra los datos existentes y elimina las columnas en texto plano.
   Usa SQL dinámico (sp_executesql) solo en las dos sentencias que nombran las
   columnas viejas nro_doc y fecha_nac: si no fuera dinámico, el SP no podría
   volver a crearse una vez eliminadas esas columnas (script re-ejecutable).
   Todo ocurre en una transacción: si el descifrado de control no coincide
   con el original en alguna fila, se deshace y no se elimina nada.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE seguridad.usp_Cifrado_MigrarPersonas
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_abrio BIT = 0;
    DECLARE @v_key_guid UNIQUEIDENTIFIER;
    DECLARE @v_cifradas INT = 0;
    DECLARE @v_diferencias INT = 0;

    IF COL_LENGTH('persona.persona', 'nro_doc') IS NULL
    BEGIN
        PRINT 'persona.persona ya esta migrada (no existen nro_doc ni fecha_nac en texto plano)';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = N'sk_Mundial2026_Datos')
        THROW 50001, N'seguridad.usp_Cifrado_MigrarPersonas: falta la clave de cifrado; ejecute 90_Seg_Cifrado_Claves.sql', 1;

    BEGIN TRY
        EXEC seguridad.usp_AbrirClave @abrio = @v_abrio OUTPUT, @key_guid = @v_key_guid OUTPUT;

        BEGIN TRANSACTION;

        -- 1) Cifrado y hash de las filas pendientes
        EXEC sp_executesql
            N'UPDATE persona.persona
                 SET nro_doc_cif   = ENCRYPTBYKEY(@g, CONVERT(NVARCHAR(30), nro_doc)),
                     fecha_nac_cif = ENCRYPTBYKEY(@g, CONVERT(VARCHAR(10), fecha_nac, 23)),
                     nro_doc_hash  = persona.fn_HashDocumento(CONVERT(NVARCHAR(30), nro_doc))
               WHERE nro_doc_cif IS NULL OR fecha_nac_cif IS NULL OR nro_doc_hash IS NULL;
              SET @n = @@ROWCOUNT;',
            N'@g UNIQUEIDENTIFIER, @n INT OUTPUT', @g = @v_key_guid, @n = @v_cifradas OUTPUT;

        -- 2) Control: lo descifrado debe ser idéntico al original
        EXEC sp_executesql
            N'SELECT @d = COUNT(*)
                FROM persona.persona
               WHERE persona.fn_NroDocDescifrado(nro_doc_cif) <> CONVERT(NVARCHAR(30), nro_doc)
                  OR persona.fn_FechaNacDescifrada(fecha_nac_cif) <> fecha_nac
                  OR persona.fn_NroDocDescifrado(nro_doc_cif) IS NULL
                  OR persona.fn_FechaNacDescifrada(fecha_nac_cif) IS NULL;',
            N'@d INT OUTPUT', @d = @v_diferencias OUTPUT;

        IF @v_diferencias > 0
            THROW 50002, N'seguridad.usp_Cifrado_MigrarPersonas: el descifrado de control no coincide con el original; se deshace la migracion', 1;

        -- 3) Se eliminan restricciones y columnas en texto plano
        IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_persona_tipo_doc_nro_doc' AND parent_object_id = OBJECT_ID(N'persona.persona'))
            ALTER TABLE persona.persona DROP CONSTRAINT UQ_persona_tipo_doc_nro_doc;
        IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_persona_nro_doc' AND parent_object_id = OBJECT_ID(N'persona.persona'))
            ALTER TABLE persona.persona DROP CONSTRAINT CK_persona_nro_doc;
        IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_persona_fecha_nac' AND parent_object_id = OBJECT_ID(N'persona.persona'))
            ALTER TABLE persona.persona DROP CONSTRAINT CK_persona_fecha_nac;

        ALTER TABLE persona.persona DROP COLUMN nro_doc;
        ALTER TABLE persona.persona DROP COLUMN fecha_nac;

        -- 4) Columnas cifradas obligatorias y unicidad (tipo_doc, documento) sobre el hash
        ALTER TABLE persona.persona ALTER COLUMN nro_doc_cif VARBINARY(256) NOT NULL;
        ALTER TABLE persona.persona ALTER COLUMN fecha_nac_cif VARBINARY(128) NOT NULL;
        ALTER TABLE persona.persona ALTER COLUMN nro_doc_hash VARBINARY(32) NOT NULL;
        ALTER TABLE persona.persona ADD CONSTRAINT UQ_persona_tipo_doc_nro_doc_hash UNIQUE (tipo_doc, nro_doc_hash);

        COMMIT TRANSACTION;

        IF @v_abrio = 1 EXEC seguridad.usp_CerrarClave;
        PRINT CONCAT('Migracion OK: ', @v_cifradas, ' personas cifradas; columnas nro_doc y fecha_nac eliminadas');
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF @v_abrio = 1 EXEC seguridad.usp_CerrarClave;
        THROW;
    END CATCH
END
GO

EXEC seguridad.usp_Cifrado_MigrarPersonas;
GO

-- Las validaciones que antes eran CHECK sobre columnas planas (documento no
-- vacío, fecha de nacimiento no futura) pasan a los SP de ABM, que ya las
-- aplicaban antes de insertar o modificar (script 92).
