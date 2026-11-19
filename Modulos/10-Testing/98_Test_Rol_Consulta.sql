/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-17
Objetivo: Entrega 8. Test del rol rol_consulta: permisos que tiene y que no tiene.
          Usuario de prueba: usr_consulta_test (miembro de rol_consulta), creado en 93_Seg_Roles_Permisos.sql.
          Cada caso se ejecuta con EXECUTE AS USER y se informa PASS o FAIL.
          Los casos de escritura se hacen dentro de una transaccion que se deshace:
          el script no deja datos en la base.
          Resultado esperado: todos los casos PASS (5 permitidos y 9 denegados)
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT '=== 98_Test_Rol_Consulta: permisos del rol rol_consulta ===';

IF DATABASE_PRINCIPAL_ID('usr_consulta_test') IS NULL
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
    THROW 50001, '98_Test_Rol_Consulta: faltan datos base (paises, posiciones o personas); ejecute EJECUTAR_TODO.sql', 1;

IF IS_MEMBER('rol_consulta') IS NULL
    THROW 50001, '98_Test_Rol_Consulta: no existe el rol rol_consulta; ejecute 93_Seg_Roles_Permisos.sql', 1;

-- Caso 1 [PERMITIDO]: Lee la vista de marcadores (juego.vw_MarcadorPartido)
BEGIN TRY
    EXECUTE AS USER = 'usr_consulta_test';
        SELECT @v_n = COUNT(*) FROM juego.vw_MarcadorPartido;
    REVERT;
    PRINT 'PASS  [permitido]  Lee la vista de marcadores (juego.vw_MarcadorPartido)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Lee la vista de marcadores (juego.vw_MarcadorPartido) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 2 [PERMITIDO]: Lee datos geograficos (geo.pais)
BEGIN TRY
    EXECUTE AS USER = 'usr_consulta_test';
        SELECT @v_n = COUNT(*) FROM geo.pais;
    REVERT;
    PRINT 'PASS  [permitido]  Lee datos geograficos (geo.pais)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Lee datos geograficos (geo.pais) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 3 [PERMITIDO]: Ejecuta reportes (reporte.usp_Goleadores)
BEGIN TRY
    EXECUTE AS USER = 'usr_consulta_test';
        EXEC reporte.usp_Goleadores @nro_fase = 1;
    REVERT;
    PRINT 'PASS  [permitido]  Ejecuta reportes (reporte.usp_Goleadores)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Ejecuta reportes (reporte.usp_Goleadores) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 4 [PERMITIDO]: Ejecuta un reporte que lee publicidad por dentro (reporte.usp_OcupacionPublicitaria)
BEGIN TRY
    EXECUTE AS USER = 'usr_consulta_test';
        EXEC reporte.usp_OcupacionPublicitaria;
    REVERT;
    PRINT 'PASS  [permitido]  Ejecuta un reporte que lee publicidad por dentro (reporte.usp_OcupacionPublicitaria)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Ejecuta un reporte que lee publicidad por dentro (reporte.usp_OcupacionPublicitaria) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 5 [PERMITIDO]: Ve a una persona con documento y fecha ENMASCARADOS (persona.usp_Persona_ConsultarEnmascarado)
BEGIN TRY
    EXECUTE AS USER = 'usr_consulta_test';
        EXEC persona.usp_Persona_ConsultarEnmascarado @id_persona = @v_id_persona;
    REVERT;
    PRINT 'PASS  [permitido]  Ve a una persona con documento y fecha ENMASCARADOS (persona.usp_Persona_ConsultarEnmascarado)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Ve a una persona con documento y fecha ENMASCARADOS (persona.usp_Persona_ConsultarEnmascarado) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 6 [DENEGADO]: No puede leer la tabla de personas (persona.persona)
BEGIN TRY
    EXECUTE AS USER = 'usr_consulta_test';
        SELECT @v_n = COUNT(*) FROM persona.persona;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede leer la tabla de personas (persona.persona) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede leer la tabla de personas (persona.persona) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede leer la tabla de personas (persona.persona) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 7 [DENEGADO]: No puede ver datos personales descifrados (persona.usp_Persona_Consultar)
BEGIN TRY
    EXECUTE AS USER = 'usr_consulta_test';
        EXEC persona.usp_Persona_Consultar @id_persona = @v_id_persona;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede ver datos personales descifrados (persona.usp_Persona_Consultar) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede ver datos personales descifrados (persona.usp_Persona_Consultar) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede ver datos personales descifrados (persona.usp_Persona_Consultar) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 8 [DENEGADO]: No puede leer tablas de negocio sin vista (torneo.partido)
BEGIN TRY
    EXECUTE AS USER = 'usr_consulta_test';
        SELECT @v_n = COUNT(*) FROM torneo.partido;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede leer tablas de negocio sin vista (torneo.partido) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede leer tablas de negocio sin vista (torneo.partido) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede leer tablas de negocio sin vista (torneo.partido) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 9 [DENEGADO]: No puede leer publicidad (publicidad.anunciante)
BEGIN TRY
    EXECUTE AS USER = 'usr_consulta_test';
        SELECT @v_n = COUNT(*) FROM publicidad.anunciante;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede leer publicidad (publicidad.anunciante) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede leer publicidad (publicidad.anunciante) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede leer publicidad (publicidad.anunciante) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 10 [DENEGADO]: No puede insertar, modificar ni borrar (DELETE sobre geo.pais)
BEGIN TRY
    EXECUTE AS USER = 'usr_consulta_test';
        BEGIN TRANSACTION;
        DELETE FROM geo.pais WHERE 1 = 0;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede insertar, modificar ni borrar (DELETE sobre geo.pais) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede insertar, modificar ni borrar (DELETE sobre geo.pais) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede insertar, modificar ni borrar (DELETE sobre geo.pais) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 11 [DENEGADO]: No puede ejecutar ABM (geo.usp_Pais_Eliminar)
BEGIN TRY
    EXECUTE AS USER = 'usr_consulta_test';
        BEGIN TRANSACTION;
        EXEC geo.usp_Pais_Eliminar @id_pais = -1;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede ejecutar ABM (geo.usp_Pais_Eliminar) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede ejecutar ABM (geo.usp_Pais_Eliminar) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede ejecutar ABM (geo.usp_Pais_Eliminar) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 12 [DENEGADO]: No puede cargar resultados (juego.usp_Negocio_RegistrarGol)
BEGIN TRY
    EXECUTE AS USER = 'usr_consulta_test';
        BEGIN TRANSACTION;
        EXEC juego.usp_Negocio_RegistrarGol @id_partido = -1, @id_seleccion = -1, @id_jugador_autor = -1, @minuto = 1,
             @tipo_gol = 'JUEGO', @periodo = '1T', @nro_gol = @v_nro OUTPUT;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede cargar resultados (juego.usp_Negocio_RegistrarGol) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede cargar resultados (juego.usp_Negocio_RegistrarGol) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede cargar resultados (juego.usp_Negocio_RegistrarGol) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 13 [DENEGADO]: No puede gestionar publicidad (publicidad.usp_Anunciante_Insertar)
BEGIN TRY
    EXECUTE AS USER = 'usr_consulta_test';
        BEGIN TRANSACTION;
        EXEC publicidad.usp_Anunciante_Insertar @razon_social = 'X', @identificacion_fiscal = 'X', @id_pais = @v_id_pais, @id_anunciante = @v_id OUTPUT;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede gestionar publicidad (publicidad.usp_Anunciante_Insertar) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede gestionar publicidad (publicidad.usp_Anunciante_Insertar) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede gestionar publicidad (publicidad.usp_Anunciante_Insertar) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 14 [DENEGADO]: No puede abrir la clave de cifrado (seguridad.usp_AbrirClave)
BEGIN TRY
    EXECUTE AS USER = 'usr_consulta_test';
        EXEC seguridad.usp_AbrirClave;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede abrir la clave de cifrado (seguridad.usp_AbrirClave) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede abrir la clave de cifrado (seguridad.usp_AbrirClave) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede abrir la clave de cifrado (seguridad.usp_AbrirClave) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

PRINT '-----------------------------------------------------------------';
PRINT CONCAT('98_Test_Rol_Consulta: ', @v_pass, ' PASS, ', @v_fail, ' FAIL');
IF @v_fail = 0 PRINT 'RESULTADO: OK - el rol rol_consulta tiene exactamente los permisos esperados';
ELSE PRINT 'RESULTADO: HAY FALLAS - revisar los casos FAIL';
GO
