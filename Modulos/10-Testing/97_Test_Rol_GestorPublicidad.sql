/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-17
Objetivo: Entrega 8. Test del rol rol_gestor_publicidad: permisos que tiene y que no tiene.
          Usuario de prueba: usr_gestor_publicidad_test (miembro de rol_gestor_publicidad), creado en 93_Seg_Roles_Permisos.sql.
          Cada caso se ejecuta con EXECUTE AS USER y se informa PASS o FAIL.
          Los casos de escritura se hacen dentro de una transaccion que se deshace:
          el script no deja datos en la base.
          Resultado esperado: todos los casos PASS (5 permitidos y 8 denegados)
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT '=== 97_Test_Rol_GestorPublicidad: permisos del rol rol_gestor_publicidad ===';

IF DATABASE_PRINCIPAL_ID('usr_gestor_publicidad_test') IS NULL
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
    THROW 50001, '97_Test_Rol_GestorPublicidad: faltan datos base (paises, posiciones o personas); ejecute EJECUTAR_TODO.sql', 1;

IF IS_MEMBER('rol_gestor_publicidad') IS NULL
    THROW 50001, '97_Test_Rol_GestorPublicidad: no existe el rol rol_gestor_publicidad; ejecute 93_Seg_Roles_Permisos.sql', 1;

-- Caso 1 [PERMITIDO]: Lee anunciantes (publicidad.anunciante)
BEGIN TRY
    EXECUTE AS USER = 'usr_gestor_publicidad_test';
        SELECT @v_n = COUNT(*) FROM publicidad.anunciante;
    REVERT;
    PRINT 'PASS  [permitido]  Lee anunciantes (publicidad.anunciante)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Lee anunciantes (publicidad.anunciante) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 2 [PERMITIDO]: Alta de anunciante y de campania con SP de publicidad (se deshace)
BEGIN TRY
    EXECUTE AS USER = 'usr_gestor_publicidad_test';
        BEGIN TRANSACTION;
        EXEC publicidad.usp_Anunciante_Insertar @razon_social = 'Prueba Rol Publicidad SA', @identificacion_fiscal = 'E8-PUB-CUIT', @id_pais = @v_id_pais, @id_anunciante = @v_id OUTPUT;
        EXEC publicidad.usp_Campania_Insertar @nombre = 'Campania de prueba rol', @id_anunciante = @v_id, @fecha_desde = '2026-06-11',
             @fecha_hasta = '2026-07-19', @presupuesto = 1000, @id_campania = @v_id2 OUTPUT;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'PASS  [permitido]  Alta de anunciante y de campania con SP de publicidad (se deshace)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Alta de anunciante y de campania con SP de publicidad (se deshace) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 3 [PERMITIDO]: Ejecuta el reporte de ocupacion publicitaria (reporte.usp_OcupacionPublicitaria)
BEGIN TRY
    EXECUTE AS USER = 'usr_gestor_publicidad_test';
        EXEC reporte.usp_OcupacionPublicitaria;
    REVERT;
    PRINT 'PASS  [permitido]  Ejecuta el reporte de ocupacion publicitaria (reporte.usp_OcupacionPublicitaria)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Ejecuta el reporte de ocupacion publicitaria (reporte.usp_OcupacionPublicitaria) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 4 [PERMITIDO]: Ejecuta el reporte de matriz prime time (reporte.usp_MatrizPrimeTime)
BEGIN TRY
    EXECUTE AS USER = 'usr_gestor_publicidad_test';
        EXEC reporte.usp_MatrizPrimeTime;
    REVERT;
    PRINT 'PASS  [permitido]  Ejecuta el reporte de matriz prime time (reporte.usp_MatrizPrimeTime)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Ejecuta el reporte de matriz prime time (reporte.usp_MatrizPrimeTime) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 5 [PERMITIDO (error de negocio aceptado)]: Puede ejecutar publicidad.usp_Negocio_AsignarPublicidad (partido inexistente: responde el SP, no el permiso)
BEGIN TRY
    EXECUTE AS USER = 'usr_gestor_publicidad_test';
        BEGIN TRANSACTION;
        EXEC publicidad.usp_Negocio_AsignarPublicidad @id_partido = -1;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'PASS  [permitido]  Puede ejecutar publicidad.usp_Negocio_AsignarPublicidad (partido inexistente: responde el SP, no el permiso)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('FAIL  [permitido]  Puede ejecutar publicidad.usp_Negocio_AsignarPublicidad (partido inexistente: responde el SP, no el permiso) -> permiso denegado (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
    ELSE
    BEGIN PRINT CONCAT('PASS  [permitido]  Puede ejecutar publicidad.usp_Negocio_AsignarPublicidad (partido inexistente: responde el SP, no el permiso) (tiene permiso; respuesta de negocio: ', @v_msg, ')'); SET @v_pass += 1; END
END CATCH

-- Caso 6 [DENEGADO]: No puede escribir directamente en las tablas (DELETE sobre publicidad.anunciante)
BEGIN TRY
    EXECUTE AS USER = 'usr_gestor_publicidad_test';
        BEGIN TRANSACTION;
        DELETE FROM publicidad.anunciante WHERE 1 = 0;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede escribir directamente en las tablas (DELETE sobre publicidad.anunciante) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede escribir directamente en las tablas (DELETE sobre publicidad.anunciante) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede escribir directamente en las tablas (DELETE sobre publicidad.anunciante) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 7 [DENEGADO]: No puede leer datos personales (persona.persona)
BEGIN TRY
    EXECUTE AS USER = 'usr_gestor_publicidad_test';
        SELECT @v_n = COUNT(*) FROM persona.persona;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede leer datos personales (persona.persona) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede leer datos personales (persona.persona) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede leer datos personales (persona.persona) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 8 [DENEGADO]: No puede consultar personas ni siquiera enmascaradas (persona.usp_Persona_ConsultarEnmascarado)
BEGIN TRY
    EXECUTE AS USER = 'usr_gestor_publicidad_test';
        EXEC persona.usp_Persona_ConsultarEnmascarado @id_persona = @v_id_persona;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede consultar personas ni siquiera enmascaradas (persona.usp_Persona_ConsultarEnmascarado) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede consultar personas ni siquiera enmascaradas (persona.usp_Persona_ConsultarEnmascarado) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede consultar personas ni siquiera enmascaradas (persona.usp_Persona_ConsultarEnmascarado) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 9 [DENEGADO]: No puede abrir la clave de cifrado (seguridad.usp_AbrirClave)
BEGIN TRY
    EXECUTE AS USER = 'usr_gestor_publicidad_test';
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

-- Caso 10 [DENEGADO]: No puede cargar resultados (juego.usp_Negocio_RegistrarGol)
BEGIN TRY
    EXECUTE AS USER = 'usr_gestor_publicidad_test';
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

-- Caso 11 [DENEGADO]: No puede ver el reporte de resultados (reporte.usp_Resultados)
BEGIN TRY
    EXECUTE AS USER = 'usr_gestor_publicidad_test';
        EXEC reporte.usp_Resultados @nro_fase = 1;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede ver el reporte de resultados (reporte.usp_Resultados) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede ver el reporte de resultados (reporte.usp_Resultados) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede ver el reporte de resultados (reporte.usp_Resultados) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 12 [DENEGADO]: No puede importar archivos (soporte.usp_Importar_PaisesCsv)
BEGIN TRY
    EXECUTE AS USER = 'usr_gestor_publicidad_test';
        BEGIN TRANSACTION;
        EXEC soporte.usp_Importar_PaisesCsv @archivo = 'C:\no_existe.csv';
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede importar archivos (soporte.usp_Importar_PaisesCsv) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede importar archivos (soporte.usp_Importar_PaisesCsv) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede importar archivos (soporte.usp_Importar_PaisesCsv) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 13 [DENEGADO]: No puede leer el cuadro de permisos (seguridad.permiso_rol)
BEGIN TRY
    EXECUTE AS USER = 'usr_gestor_publicidad_test';
        SELECT @v_n = COUNT(*) FROM seguridad.permiso_rol;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede leer el cuadro de permisos (seguridad.permiso_rol) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede leer el cuadro de permisos (seguridad.permiso_rol) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede leer el cuadro de permisos (seguridad.permiso_rol) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

PRINT '-----------------------------------------------------------------';
PRINT CONCAT('97_Test_Rol_GestorPublicidad: ', @v_pass, ' PASS, ', @v_fail, ' FAIL');
IF @v_fail = 0 PRINT 'RESULTADO: OK - el rol rol_gestor_publicidad tiene exactamente los permisos esperados';
ELSE PRINT 'RESULTADO: HAY FALLAS - revisar los casos FAIL';
GO
