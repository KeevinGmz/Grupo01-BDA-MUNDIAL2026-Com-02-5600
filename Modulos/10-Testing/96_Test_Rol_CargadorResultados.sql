/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-17
Objetivo: Entrega 8. Test del rol rol_cargador_resultados: permisos que tiene y que no tiene.
          Usuario de prueba: usr_cargador_test (miembro de rol_cargador_resultados), creado en 93_Seg_Roles_Permisos.sql.
          Cada caso se ejecuta con EXECUTE AS USER y se informa PASS o FAIL.
          Los casos de escritura se hacen dentro de una transaccion que se deshace:
          el script no deja datos en la base.
          Resultado esperado: todos los casos PASS (7 permitidos y 8 denegados)
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT '=== 96_Test_Rol_CargadorResultados: permisos del rol rol_cargador_resultados ===';

IF DATABASE_PRINCIPAL_ID('usr_cargador_test') IS NULL
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
    THROW 50001, '96_Test_Rol_CargadorResultados: faltan datos base (paises, posiciones o personas); ejecute EJECUTAR_TODO.sql', 1;

IF IS_MEMBER('rol_cargador_resultados') IS NULL
    THROW 50001, '96_Test_Rol_CargadorResultados: no existe el rol rol_cargador_resultados; ejecute 93_Seg_Roles_Permisos.sql', 1;

-- Caso 1 [PERMITIDO]: Lee la vista de marcadores (juego.vw_MarcadorPartido)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
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

-- Caso 2 [PERMITIDO]: Lee la tabla de posiciones (torneo.vw_PosicionesGrupo)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
        SELECT @v_n = COUNT(*) FROM torneo.vw_PosicionesGrupo;
    REVERT;
    PRINT 'PASS  [permitido]  Lee la tabla de posiciones (torneo.vw_PosicionesGrupo)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Lee la tabla de posiciones (torneo.vw_PosicionesGrupo) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 3 [PERMITIDO]: Ejecuta el reporte de goleadores (reporte.usp_Goleadores)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
        EXEC reporte.usp_Goleadores @nro_fase = 1;
    REVERT;
    PRINT 'PASS  [permitido]  Ejecuta el reporte de goleadores (reporte.usp_Goleadores)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    PRINT CONCAT('FAIL  [permitido]  Ejecuta el reporte de goleadores (reporte.usp_Goleadores) -> error ', @v_num, ': ', @v_msg); SET @v_fail += 1;
END CATCH

-- Caso 4 [PERMITIDO]: Ve a una persona con documento y fecha ENMASCARADOS (persona.usp_Persona_ConsultarEnmascarado)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
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

-- Caso 5 [PERMITIDO (error de negocio aceptado)]: Puede ejecutar juego.usp_Negocio_RegistrarGol (partido inexistente: responde el SP, no el permiso)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
        BEGIN TRANSACTION;
        EXEC juego.usp_Negocio_RegistrarGol @id_partido = -1, @id_seleccion = -1, @id_jugador_autor = -1, @minuto = 1,
             @tipo_gol = 'JUEGO', @periodo = '1T', @nro_gol = @v_nro OUTPUT;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'PASS  [permitido]  Puede ejecutar juego.usp_Negocio_RegistrarGol (partido inexistente: responde el SP, no el permiso)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('FAIL  [permitido]  Puede ejecutar juego.usp_Negocio_RegistrarGol (partido inexistente: responde el SP, no el permiso) -> permiso denegado (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
    ELSE
    BEGIN PRINT CONCAT('PASS  [permitido]  Puede ejecutar juego.usp_Negocio_RegistrarGol (partido inexistente: responde el SP, no el permiso) (tiene permiso; respuesta de negocio: ', @v_msg, ')'); SET @v_pass += 1; END
END CATCH

-- Caso 6 [PERMITIDO (error de negocio aceptado)]: Puede ejecutar juego.usp_Negocio_RegistrarTarjeta (partido inexistente)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
        BEGIN TRANSACTION;
        EXEC juego.usp_Negocio_RegistrarTarjeta @id_partido = -1, @id_seleccion = -1, @id_jugador = -1, @id_arbitro = -1,
             @minuto = 1, @id_tipo = 1, @nro_tarjeta = @v_nro OUTPUT, @id_suspension = @v_id OUTPUT;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'PASS  [permitido]  Puede ejecutar juego.usp_Negocio_RegistrarTarjeta (partido inexistente)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('FAIL  [permitido]  Puede ejecutar juego.usp_Negocio_RegistrarTarjeta (partido inexistente) -> permiso denegado (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
    ELSE
    BEGIN PRINT CONCAT('PASS  [permitido]  Puede ejecutar juego.usp_Negocio_RegistrarTarjeta (partido inexistente) (tiene permiso; respuesta de negocio: ', @v_msg, ')'); SET @v_pass += 1; END
END CATCH

-- Caso 7 [PERMITIDO (error de negocio aceptado)]: Puede ejecutar torneo.usp_Negocio_CerrarPartido (partido inexistente)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
        BEGIN TRANSACTION;
        EXEC torneo.usp_Negocio_CerrarPartido @id_partido = -1, @asistencia_publico = 1;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'PASS  [permitido]  Puede ejecutar torneo.usp_Negocio_CerrarPartido (partido inexistente)'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('FAIL  [permitido]  Puede ejecutar torneo.usp_Negocio_CerrarPartido (partido inexistente) -> permiso denegado (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
    ELSE
    BEGIN PRINT CONCAT('PASS  [permitido]  Puede ejecutar torneo.usp_Negocio_CerrarPartido (partido inexistente) (tiene permiso; respuesta de negocio: ', @v_msg, ')'); SET @v_pass += 1; END
END CATCH

-- Caso 8 [DENEGADO]: No puede leer la tabla de personas (persona.persona)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
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

-- Caso 9 [DENEGADO]: No puede ver datos personales descifrados (persona.usp_Persona_Consultar)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
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

-- Caso 10 [DENEGADO]: No puede abrir la clave de cifrado (seguridad.usp_AbrirClave)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
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

-- Caso 11 [DENEGADO]: No puede escribir directamente en las tablas (DELETE sobre juego.gol)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
        BEGIN TRANSACTION;
        DELETE FROM juego.gol WHERE 1 = 0;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede escribir directamente en las tablas (DELETE sobre juego.gol) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede escribir directamente en las tablas (DELETE sobre juego.gol) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede escribir directamente en las tablas (DELETE sobre juego.gol) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 12 [DENEGADO]: No puede eliminar goles (juego.usp_Gol_Eliminar no esta concedido)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
        BEGIN TRANSACTION;
        EXEC juego.usp_Gol_Eliminar @id_partido = -1, @id_seleccion = -1, @nro_gol = 1;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede eliminar goles (juego.usp_Gol_Eliminar no esta concedido) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede eliminar goles (juego.usp_Gol_Eliminar no esta concedido) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede eliminar goles (juego.usp_Gol_Eliminar no esta concedido) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 13 [DENEGADO]: No puede registrar partidos nuevos (torneo.usp_Negocio_RegistrarPartido)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
        BEGIN TRANSACTION;
        EXEC torneo.usp_Negocio_RegistrarPartido @fecha_hora_utc = '2026-06-11T20:00:00', @id_sede = -1, @nro_fase = 1,
             @id_seleccion_local = -1, @id_seleccion_visitante = -2, @id_partido = @v_id OUTPUT;
        ROLLBACK TRANSACTION;
    REVERT;
    PRINT 'FAIL  [denegado]   No puede registrar partidos nuevos (torneo.usp_Negocio_RegistrarPartido) -> se ejecuto sin error'; SET @v_fail += 1;
END TRY
BEGIN CATCH
    SET @v_num = ERROR_NUMBER(); SET @v_msg = LEFT(ERROR_MESSAGE(), 300);
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;   -- primero deshacer: con la transaccion no confirmable, REVERT falla
    REVERT;
    IF @v_num IN (229, 230, 262, 297, 300, 916, 1088, 3701, 4902, 15151, 15247)
    BEGIN PRINT CONCAT('PASS  [denegado]   No puede registrar partidos nuevos (torneo.usp_Negocio_RegistrarPartido) (error ', @v_num, ')'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  [denegado]   No puede registrar partidos nuevos (torneo.usp_Negocio_RegistrarPartido) -> error distinto de permiso (', @v_num, '): ', @v_msg); SET @v_fail += 1; END
END CATCH

-- Caso 14 [DENEGADO]: No puede gestionar publicidad (publicidad.usp_Anunciante_Insertar)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
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

-- Caso 15 [DENEGADO]: No puede importar archivos (soporte.usp_Importar_PaisesCsv)
BEGIN TRY
    EXECUTE AS USER = 'usr_cargador_test';
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

PRINT '-----------------------------------------------------------------';
PRINT CONCAT('96_Test_Rol_CargadorResultados: ', @v_pass, ' PASS, ', @v_fail, ' FAIL');
IF @v_fail = 0 PRINT 'RESULTADO: OK - el rol rol_cargador_resultados tiene exactamente los permisos esperados';
ELSE PRINT 'RESULTADO: HAY FALLAS - revisar los casos FAIL';
GO
