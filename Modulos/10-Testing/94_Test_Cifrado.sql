/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-17
Objetivo: Entrega 8. Test del cifrado de datos personales (persona.persona).
          Verifica: (1) que el documento y la fecha de nacimiento ya no existen en
          texto plano; (2) que todo lo migrado se puede descifrar; (3) que un alta
          nueva queda cifrada, se encuentra por hash y se descifra bien; (4) que el
          documento duplicado se rechaza; (5) que la modificación recifra; (6) que
          el SP enmascarado oculta el documento; (7) que la clave queda cerrada.
          Las altas se hacen dentro de una transacción que se deshace.
          Resultado esperado: todos los casos PASS.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT '=== 94_Test_Cifrado: datos personales cifrados ===';

DECLARE @v_pass INT = 0;
DECLARE @v_fail INT = 0;
DECLARE @v_n INT;
DECLARE @v_id INT;
DECLARE @v_id_pais SMALLINT = (SELECT TOP (1) id_pais FROM geo.pais ORDER BY id_pais);
DECLARE @v_id_posicion TINYINT = (SELECT TOP (1) id_posicion FROM persona.posicion ORDER BY id_posicion);
DECLARE @v_abrio BIT;
DECLARE @v_doc NVARCHAR(30) = N'E8-CIF-0001';
DECLARE @v_msg NVARCHAR(400);
DECLARE @v_total INT;
DECLARE @v_masc NVARCHAR(30);

IF @v_id_pais IS NULL OR @v_id_posicion IS NULL
    THROW 50001, '94_Test_Cifrado: faltan paises o posiciones; ejecute EJECUTAR_TODO.sql', 1;

CREATE TABLE #consulta (
    id_persona INT, tipo_persona CHAR(1), tipo_doc VARCHAR(5), nro_doc NVARCHAR(30),
    nombre NVARCHAR(80), apellido NVARCHAR(80), fecha_nac DATE, id_pais SMALLINT);
CREATE TABLE #enmascarada (
    id_persona INT, tipo_persona CHAR(1), tipo_doc VARCHAR(5), nro_doc_enmascarado NVARCHAR(30),
    nombre NVARCHAR(80), apellido NVARCHAR(80), anio_nac INT, id_pais SMALLINT);

-------------------------------------------------------------------------------
-- Caso 1: las columnas en texto plano ya no existen
-- Resultado esperado: PASS
-------------------------------------------------------------------------------
IF COL_LENGTH('persona.persona', 'nro_doc') IS NULL AND COL_LENGTH('persona.persona', 'fecha_nac') IS NULL
BEGIN PRINT 'PASS  Caso 1: persona.persona no tiene nro_doc ni fecha_nac en texto plano'; SET @v_pass += 1; END
ELSE
BEGIN PRINT 'FAIL  Caso 1: todavia existen columnas en texto plano (ejecutar 91_Seg_Cifrado_Tablas.sql)'; SET @v_fail += 1; END

-------------------------------------------------------------------------------
-- Caso 2: las columnas cifradas son VARBINARY
-------------------------------------------------------------------------------
IF (SELECT COUNT(*) FROM sys.columns AS c JOIN sys.types AS ty ON ty.user_type_id = c.user_type_id
    WHERE c.object_id = OBJECT_ID('persona.persona') AND c.name IN ('nro_doc_cif', 'fecha_nac_cif', 'nro_doc_hash')
      AND ty.name = 'varbinary') = 3
BEGIN PRINT 'PASS  Caso 2: nro_doc_cif, fecha_nac_cif y nro_doc_hash son VARBINARY'; SET @v_pass += 1; END
ELSE
BEGIN PRINT 'FAIL  Caso 2: faltan columnas cifradas'; SET @v_fail += 1; END

-------------------------------------------------------------------------------
-- Caso 3: todas las personas existentes se descifran (nada quedo sin migrar)
-------------------------------------------------------------------------------
EXEC seguridad.usp_AbrirClave @abrio = @v_abrio OUTPUT;
SELECT @v_n = COUNT(*) FROM persona.persona
WHERE persona.fn_NroDocDescifrado(nro_doc_cif) IS NULL OR persona.fn_FechaNacDescifrada(fecha_nac_cif) IS NULL;
IF @v_abrio = 1 EXEC seguridad.usp_CerrarClave;
IF @v_n = 0
BEGIN SELECT @v_total = COUNT(*) FROM persona.persona; PRINT CONCAT('PASS  Caso 3: las ', @v_total, ' personas se descifran correctamente'); SET @v_pass += 1; END
ELSE
BEGIN PRINT CONCAT('FAIL  Caso 3: ', @v_n, ' personas no se pueden descifrar'); SET @v_fail += 1; END

-------------------------------------------------------------------------------
-- Evidencia visual: lo que se ve en la tabla (cifrado) frente a lo que ve el
-- administrador con la clave abierta.
-------------------------------------------------------------------------------
PRINT '-> Evidencia 1: contenido de la tabla (documento y fecha cifrados)';
SELECT TOP (5) id_persona, apellido, nombre, nro_doc_cif AS nro_doc_cifrado, fecha_nac_cif AS fecha_nac_cifrada
FROM persona.persona ORDER BY id_persona;

PRINT '-> Evidencia 2: persona.usp_Persona_Consultar (descifrado, solo administrador)';
INSERT INTO #consulta EXEC persona.usp_Persona_Consultar @tipo_persona = 'J';
SELECT TOP (5) * FROM #consulta ORDER BY id_persona;
DELETE FROM #consulta;

-------------------------------------------------------------------------------
-- Caso 4: alta nueva -> cifrada, se encuentra por hash, se descifra igual
-------------------------------------------------------------------------------
BEGIN TRY
    IF EXISTS (SELECT 1 FROM persona.persona WHERE tipo_doc = 'EXT' AND nro_doc_hash = persona.fn_HashDocumento(@v_doc))
        THROW 50001, 'ya existe el documento de prueba E8-CIF-0001', 1;

    BEGIN TRANSACTION;

    EXEC persona.usp_Jugador_Insertar @tipo_doc = 'EXT', @nro_doc = @v_doc, @nombre = N'Prueba', @apellido = N'Cifrado',
         @fecha_nac = '1999-01-01', @id_pais = @v_id_pais, @id_posicion_habitual = @v_id_posicion, @id_persona = @v_id OUTPUT;

    -- 4a) el valor guardado no contiene el documento en texto plano
    IF EXISTS (SELECT 1 FROM persona.persona
               WHERE id_persona = @v_id
                 AND CHARINDEX(CONVERT(VARBINARY(100), @v_doc), nro_doc_cif) = 0
                 AND CHARINDEX(CONVERT(VARBINARY(100), CONVERT(VARCHAR(30), @v_doc)), nro_doc_cif) = 0
                 AND CHARINDEX(CONVERT(VARBINARY(100), '1999-01-01'), fecha_nac_cif) = 0)
    BEGIN PRINT 'PASS  Caso 4a: el documento y la fecha se guardaron cifrados (no aparecen en texto plano)'; SET @v_pass += 1; END
    ELSE
    BEGIN PRINT 'FAIL  Caso 4a: el documento o la fecha quedaron legibles'; SET @v_fail += 1; END

    -- 4b) se encuentra por hash
    IF (SELECT COUNT(*) FROM persona.persona WHERE tipo_doc = 'EXT' AND nro_doc_hash = persona.fn_HashDocumento(@v_doc) AND id_persona = @v_id) = 1
    BEGIN PRINT 'PASS  Caso 4b: la persona se encuentra por hash del documento'; SET @v_pass += 1; END
    ELSE
    BEGIN PRINT 'FAIL  Caso 4b: no se encontro por hash'; SET @v_fail += 1; END

    -- 4c) el SP de consulta devuelve los mismos datos descifrados
    INSERT INTO #consulta EXEC persona.usp_Persona_Consultar @id_persona = @v_id;
    IF EXISTS (SELECT 1 FROM #consulta WHERE nro_doc = @v_doc AND fecha_nac = '1999-01-01' AND apellido = N'Cifrado')
    BEGIN PRINT 'PASS  Caso 4c: persona.usp_Persona_Consultar devuelve el documento y la fecha originales'; SET @v_pass += 1; END
    ELSE
    BEGIN PRINT 'FAIL  Caso 4c: el descifrado no coincide'; SET @v_fail += 1; END

    -- 4d) la consulta enmascarada oculta el documento y deja solo el año
    INSERT INTO #enmascarada EXEC persona.usp_Persona_ConsultarEnmascarado @id_persona = @v_id;
    IF EXISTS (SELECT 1 FROM #enmascarada WHERE nro_doc_enmascarado = N'********001' AND anio_nac = 1999)
    BEGIN PRINT 'PASS  Caso 4d: la consulta enmascarada muestra ********001 y solo el anio 1999'; SET @v_pass += 1; END
    ELSE
    BEGIN SELECT TOP (1) @v_masc = nro_doc_enmascarado FROM #enmascarada; PRINT CONCAT('FAIL  Caso 4d: enmascarado inesperado: ', @v_masc); SET @v_fail += 1; END

    -- 4e) la clave quedo cerrada despues de las operaciones
    IF NOT EXISTS (SELECT 1 FROM sys.openkeys WHERE key_name = N'sk_Mundial2026_Datos' AND database_id = DB_ID())
    BEGIN PRINT 'PASS  Caso 4e: la clave de cifrado quedo cerrada'; SET @v_pass += 1; END
    ELSE
    BEGIN PRINT 'FAIL  Caso 4e: la clave quedo abierta en la sesion'; SET @v_fail += 1; END

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT CONCAT('FAIL  Caso 4: error inesperado ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()); SET @v_fail += 1;
END CATCH

-------------------------------------------------------------------------------
-- Caso 5: documento duplicado rechazado (la unicidad funciona sobre el hash)
-------------------------------------------------------------------------------
BEGIN TRY
    BEGIN TRANSACTION;
    EXEC persona.usp_Jugador_Insertar @tipo_doc = 'EXT', @nro_doc = @v_doc, @nombre = N'Prueba', @apellido = N'Uno',
         @fecha_nac = '1999-01-01', @id_pais = @v_id_pais, @id_posicion_habitual = @v_id_posicion, @id_persona = @v_id OUTPUT;
    SET @v_msg = NULL;
    BEGIN TRY
        EXEC persona.usp_Jugador_Insertar @tipo_doc = 'EXT', @nro_doc = N' e8-cif-0001 ', @nombre = N'Prueba', @apellido = N'Dos',
             @fecha_nac = '2000-02-02', @id_pais = @v_id_pais, @id_posicion_habitual = @v_id_posicion, @id_persona = @v_id OUTPUT;
    END TRY
    BEGIN CATCH
        SET @v_msg = ERROR_MESSAGE();
    END CATCH
    ROLLBACK TRANSACTION;
    IF @v_msg LIKE '%documento ya registrado%'
    BEGIN PRINT 'PASS  Caso 5: el mismo documento (aunque cambie mayusculas y espacios) se rechaza como duplicado'; SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  Caso 5: no se rechazo el duplicado. Mensaje: ', ISNULL(@v_msg, '(sin error)')); SET @v_fail += 1; END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT CONCAT('FAIL  Caso 5: error inesperado ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()); SET @v_fail += 1;
END CATCH

-------------------------------------------------------------------------------
-- Caso 6: la modificacion recifra los datos nuevos y el documento viejo deja de existir
-------------------------------------------------------------------------------
BEGIN TRY
    BEGIN TRANSACTION;
    EXEC persona.usp_Jugador_Insertar @tipo_doc = 'EXT', @nro_doc = @v_doc, @nombre = N'Prueba', @apellido = N'Cifrado',
         @fecha_nac = '1999-01-01', @id_pais = @v_id_pais, @id_posicion_habitual = @v_id_posicion, @id_persona = @v_id OUTPUT;
    EXEC persona.usp_Jugador_Modificar @id_persona = @v_id, @tipo_doc = 'EXT', @nro_doc = N'E8-CIF-0002', @nombre = N'Prueba',
         @apellido = N'Cifrado', @fecha_nac = '1998-12-31', @id_pais = @v_id_pais, @id_posicion_habitual = @v_id_posicion;
    DELETE FROM #consulta;
    INSERT INTO #consulta EXEC persona.usp_Persona_Consultar @id_persona = @v_id;
    IF EXISTS (SELECT 1 FROM #consulta WHERE nro_doc = N'E8-CIF-0002' AND fecha_nac = '1998-12-31')
       AND NOT EXISTS (SELECT 1 FROM persona.persona WHERE nro_doc_hash = persona.fn_HashDocumento(@v_doc))
    BEGIN PRINT 'PASS  Caso 6: usp_Jugador_Modificar recifro el documento y la fecha'; SET @v_pass += 1; END
    ELSE
    BEGIN PRINT 'FAIL  Caso 6: la modificacion no quedo reflejada'; SET @v_fail += 1; END
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT CONCAT('FAIL  Caso 6: error inesperado ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()); SET @v_fail += 1;
END CATCH

-------------------------------------------------------------------------------
-- Caso 7: los reportes que unen personas siguen funcionando
-------------------------------------------------------------------------------
BEGIN TRY
    EXEC reporte.usp_Goleadores @nro_fase = 1;
    EXEC reporte.usp_DesignacionesArbitrales;
    PRINT 'PASS  Caso 7: reporte.usp_Goleadores y reporte.usp_DesignacionesArbitrales siguen funcionando'; SET @v_pass += 1;
END TRY
BEGIN CATCH
    PRINT CONCAT('FAIL  Caso 7: ', ERROR_MESSAGE()); SET @v_fail += 1;
END CATCH

DROP TABLE #consulta;
DROP TABLE #enmascarada;

PRINT '-----------------------------------------------------------------';
PRINT CONCAT('94_Test_Cifrado: ', @v_pass, ' PASS, ', @v_fail, ' FAIL');
IF @v_fail = 0 PRINT 'RESULTADO: OK - los datos personales estan cifrados y el sistema sigue funcionando';
ELSE PRINT 'RESULTADO: HAY FALLAS - revisar los casos FAIL';
GO
