/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-17
Objetivo: Entrega 8. Test del rol rol_administrador: permisos que tiene y que no tiene.
          Usuario de prueba: usr_admin_test (miembro de rol_administrador), creado en 93_Seg_Roles_Permisos.sql.
          Cada caso se ejecuta con EXECUTE AS USER y se informa PASS o FAIL.
          Los casos de escritura se hacen dentro de una transaccion que se deshace:
          el script no deja datos en la base.
          Resultado esperado: todos los casos PASS (6 permitidos y 5 denegados)
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT '=== 95_Test_Rol_Administrador: permisos del rol rol_administrador ===';

IF DATABASE_PRINCIPAL_ID('usr_admin_test') IS NULL
    EXEC seguridad.usp_Usuarios_Prueba_Crear;

DECLARE @v_pass INT = 0;
DECLARE @v_fail INT = 0;
DECLARE @v_num INT;
DECLARE @v_msg NVARCHAR(300);
DECLARE @v_n INT;
DECLARE @v_id INT;
DECLARE @v_id2 INT;
DECLARE @v_nro TINYINT;
DECLARE @v_id_pais SMALLINT = (SELECT TOP (1) id_pais FROM geo.pais ORDER BY id_pais);
DECLARE @v_id_posicion TINYINT = (SELECT TOP (1) id_posicion FROM persona.posicion ORDER BY id_posicion);
DECLARE @v_id_persona INT = (SELECT TOP (1) id_persona FROM persona.persona ORDER BY id_persona);

IF @v_id_pais IS NULL OR @v_id_posicion IS NULL OR @v_id_persona IS NULL
    THROW 50001, '95_Test_Rol_Administrador: faltan datos base (paises, posiciones o personas); ejecute EJECUTAR_TODO.sql', 1;

IF IS_MEMBER('rol_administrador') IS NULL
    THROW 50001, '95_Test_Rol_Administrador: no existe el rol rol_administrador; ejecute 93_Seg_Roles_Permisos.sql', 1;

-- Caso 1 [PERMITIDO]: Lee las tablas de datos (el documento aparece cifrado)
BEGIN TRY
    EXECUTE AS USER = 'usr_admin_test';
        SELECT @v_n = COUNT(*) FROM persona.persona;
        IF @v_n = 0 THROW 50001, 'sin personas', 1;
    REVERT;
    PRINT 'PASS  [permitido]  Lee las tablas de datos (el documento aparece cifrado)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Lee las tablas de datos (el documento aparece cifrado) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 2 [PERMITIDO]: Ve los datos personales descifrados con persona.usp_Persona_Consultar
BEGIN TRY
    EXECUTE AS USER = 'usr_admin_test';
        EXEC persona.usp_Persona_Consultar @id_persona = @v_id_persona;
    REVERT;
    PRINT 'PASS  [permitido]  Ve los datos personales descifrados con persona.usp_Persona_Consultar'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Ve los datos personales descifrados con persona.usp_Persona_Consultar -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 3 [PERMITIDO]: Da de alta un jugador con persona.usp_Jugador_Insertar (se deshace)
BEGIN TRY
    EXECUTE AS USER = 'usr_admin_test';
        BEGIN TRANSACTION;
        EXEC persona.usp_Jugador_Insertar @tipo_doc = 'EXT', @nro_doc = N'E8-ADMIN-0001', @nombre = N'Prueba', @apellido = N'Rol Admin',
             @fecha_nac = '1999-01-01', @id_pais = @v_id_pais, @id_posicion_habitual = @v_id_posicion, @id_persona = @v_id OUTPUT;
        IF @v_id IS NULL THROW 50001, 'no se genero el id', 1;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'PASS  [permitido]  Da de alta un jugador con persona.usp_Jugador_Insertar (se deshace)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Da de alta un jugador con persona.usp_Jugador_Insertar (se deshace) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 4 [PERMITIDO]: Da de alta un anunciante con publicidad.usp_Anunciante_Insertar (se deshace)
BEGIN TRY
    EXECUTE AS USER = 'usr_admin_test';
        BEGIN TRANSACTION;
        EXEC publicidad.usp_Anunciante_Insertar @razon_social = 'Prueba Rol Admin SA', @identificacion_fiscal = 'E8-ADMIN-CUIT', @id_pais = @v_id_pais, @id_anunciante = @v_id OUTPUT;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'PASS  [permitido]  Da de alta un anunciante con publicidad.usp_Anunciante_Insertar (se deshace)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Da de alta un anunciante con publicidad.usp_Anunciante_Insertar (se deshace) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 5 [PERMITIDO]: Ejecuta un reporte (reporte.usp_Resultados)
BEGIN TRY
    EXECUTE AS USER = 'usr_admin_test';
        EXEC reporte.usp_Resultados @nro_fase = 1;
    REVERT;
    PRINT 'PASS  [permitido]  Ejecuta un reporte (reporte.usp_Resultados)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Ejecuta un reporte (reporte.usp_Resultados) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 6 [PERMITIDO]: Abre y cierra la clave de cifrado (seguridad.usp_AbrirClave / usp_CerrarClave)
BEGIN TRY
    EXECUTE AS USER = 'usr_admin_test';
        DECLARE @a BIT; EXEC seguridad.usp_AbrirClave @abrio = @a OUTPUT;
        EXEC seguridad.usp_CerrarClave;
    REVERT;
    PRINT 'PASS  [permitido]  Abre y cierra la clave de cifrado (seguridad.usp_AbrirClave / usp_CerrarClave)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Abre y cierra la clave de cifrado (seguridad.usp_AbrirClave / usp_CerrarClave) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 7 [DENEGADO]: No puede crear tablas (CREATE TABLE)
BEGIN TRY
    EXECUTE AS USER = 'usr_admin_test';
        BEGIN TRANSACTION;
        CREATE TABLE geo.tmp_prueba_rol (id INT);
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede crear tablas (CREATE TABLE) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede crear tablas (CREATE TABLE) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede crear tablas (CREATE TABLE) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 8 [DENEGADO]: No puede crear roles (CREATE ROLE)
BEGIN TRY
    EXECUTE AS USER = 'usr_admin_test';
        BEGIN TRANSACTION;
        CREATE ROLE rol_no_permitido;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede crear roles (CREATE ROLE) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede crear roles (CREATE ROLE) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede crear roles (CREATE ROLE) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 9 [DENEGADO]: No puede cambiar la pertenencia a roles (ALTER ROLE ... ADD MEMBER)
BEGIN TRY
    EXECUTE AS USER = 'usr_admin_test';
        BEGIN TRANSACTION;
        ALTER ROLE rol_administrador ADD MEMBER usr_consulta_test;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede cambiar la pertenencia a roles (ALTER ROLE ... ADD MEMBER) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede cambiar la pertenencia a roles (ALTER ROLE ... ADD MEMBER) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede cambiar la pertenencia a roles (ALTER ROLE ... ADD MEMBER) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 10 [DENEGADO]: No puede reconfigurar la seguridad (seguridad.usp_Roles_Configurar)
BEGIN TRY
    EXECUTE AS USER = 'usr_admin_test';
        BEGIN TRANSACTION;
        EXEC seguridad.usp_Roles_Configurar;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede reconfigurar la seguridad (seguridad.usp_Roles_Configurar) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede reconfigurar la seguridad (seguridad.usp_Roles_Configurar) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede reconfigurar la seguridad (seguridad.usp_Roles_Configurar) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 11 [DENEGADO]: No puede modificar el cuadro de permisos (seguridad.permiso_rol)
BEGIN TRY
    EXECUTE AS USER = 'usr_admin_test';
        BEGIN TRANSACTION;
        DELETE FROM seguridad.permiso_rol;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede modificar el cuadro de permisos (seguridad.permiso_rol) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede modificar el cuadro de permisos (seguridad.permiso_rol) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede modificar el cuadro de permisos (seguridad.permiso_rol) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

PRINT '-----------------------------------------------------------------';
PRINT CONCAT('95_Test_Rol_Administrador: ', @v_pass, ' PASS, ', @v_fail, ' FAIL');
IF @v_fail = 0 PRINT 'RESULTADO: OK - el rol rol_administrador tiene exactamente los permisos esperados';
ELSE PRINT 'RESULTADO: HAY FALLAS - revisar los casos FAIL';
GO
