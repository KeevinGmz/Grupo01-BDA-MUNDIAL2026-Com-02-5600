/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-26
Objetivo: Entrega 7. Verifica que los reportes rechazan parametros invalidos
          con un unico mensaje (THROW 50001) que agrupa todos los problemas.
          Cada prueba imprime PASS o FAIL.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
GO

PRINT '=====================================================================';
PRINT 'INICIO PRUEBAS DE ERROR: 88_Test_Reportes_ERR';
PRINT '=====================================================================';
GO

-- Test 1: formato, seleccion y fase invalidos juntos.
-- Esperado: error 50001 con los TRES problemas en el mismo mensaje.
PRINT '';
PRINT '-> Test 1: usp_Goleadores con formato, seleccion y fase invalidos';
BEGIN TRY
    EXEC reporte.usp_Goleadores @id_seleccion = -1, @nro_fase = 99, @formato = 'JSON';
    PRINT 'FAIL Test 1: debio rechazar los parametros.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
       AND ERROR_MESSAGE() LIKE '%formato invalido%'
       AND ERROR_MESSAGE() LIKE '%seleccion inexistente%'
       AND ERROR_MESSAGE() LIKE '%fase inexistente%'
        PRINT CONCAT('PASS Test 1: ', ERROR_MESSAGE());
    ELSE
        PRINT CONCAT('FAIL Test 1: ', ERROR_NUMBER(), ' - ', ERROR_MESSAGE());
END CATCH;
GO

-- Test 2: seleccion inexistente en tarjetas. Esperado: 50001 "seleccion inexistente".
PRINT '';
PRINT '-> Test 2: usp_Tarjetas con seleccion inexistente';
BEGIN TRY
    EXEC reporte.usp_Tarjetas @id_seleccion = -1;
    PRINT 'FAIL Test 2: debio rechazar la seleccion.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001 AND ERROR_MESSAGE() LIKE '%seleccion inexistente%'
        PRINT CONCAT('PASS Test 2: ', ERROR_MESSAGE());
    ELSE
        PRINT CONCAT('FAIL Test 2: ', ERROR_NUMBER(), ' - ', ERROR_MESSAGE());
END CATCH;
GO

-- Test 3: arbitro inexistente. Esperado: 50001 "arbitro inexistente".
PRINT '';
PRINT '-> Test 3: usp_DesignacionesArbitrales con arbitro inexistente';
BEGIN TRY
    EXEC reporte.usp_DesignacionesArbitrales @id_arbitro = -1;
    PRINT 'FAIL Test 3: debio rechazar el arbitro.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001 AND ERROR_MESSAGE() LIKE '%arbitro inexistente%'
        PRINT CONCAT('PASS Test 3: ', ERROR_MESSAGE());
    ELSE
        PRINT CONCAT('FAIL Test 3: ', ERROR_NUMBER(), ' - ', ERROR_MESSAGE());
END CATCH;
GO

-- Test 4: sede y partido inexistentes. Esperado: 50001 con ambos problemas.
PRINT '';
PRINT '-> Test 4: usp_OcupacionPublicitaria con sede y partido inexistentes';
BEGIN TRY
    EXEC reporte.usp_OcupacionPublicitaria @id_sede = -1, @id_partido = -1;
    PRINT 'FAIL Test 4: debio rechazar los parametros.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
       AND ERROR_MESSAGE() LIKE '%sede inexistente%'
       AND ERROR_MESSAGE() LIKE '%partido inexistente%'
        PRINT CONCAT('PASS Test 4: ', ERROR_MESSAGE());
    ELSE
        PRINT CONCAT('FAIL Test 4: ', ERROR_NUMBER(), ' - ', ERROR_MESSAGE());
END CATCH;
GO

-- Test 5: partido inexistente y rango de fechas invertido.
-- Esperado: 50001 con ambos problemas.
PRINT '';
PRINT '-> Test 5: usp_MatrizPrimeTime con partido inexistente y fechas invertidas';
BEGIN TRY
    EXEC reporte.usp_MatrizPrimeTime
        @id_partido = -1,
        @fecha_desde = '2026-07-01',
        @fecha_hasta = '2026-06-01';
    PRINT 'FAIL Test 5: debio rechazar los parametros.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
       AND ERROR_MESSAGE() LIKE '%partido inexistente%'
       AND ERROR_MESSAGE() LIKE '%fecha_desde%'
        PRINT CONCAT('PASS Test 5: ', ERROR_MESSAGE());
    ELSE
        PRINT CONCAT('FAIL Test 5: ', ERROR_NUMBER(), ' - ', ERROR_MESSAGE());
END CATCH;
GO

-- Test 6: seleccion inexistente en plantillas. Esperado: 50001.
PRINT '';
PRINT '-> Test 6: usp_SeleccionesPlantillas con seleccion inexistente';
BEGIN TRY
    EXEC reporte.usp_SeleccionesPlantillas @id_seleccion = -1;
    PRINT 'FAIL Test 6: debio rechazar la seleccion.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001 AND ERROR_MESSAGE() LIKE '%seleccion inexistente%'
        PRINT CONCAT('PASS Test 6: ', ERROR_MESSAGE());
    ELSE
        PRINT CONCAT('FAIL Test 6: ', ERROR_NUMBER(), ' - ', ERROR_MESSAGE());
END CATCH;
GO

-- Test 7: fase inexistente y formato invalido en resultados. Esperado: 50001 con ambos.
PRINT '';
PRINT '-> Test 7: usp_Resultados con fase inexistente y formato invalido';
BEGIN TRY
    EXEC reporte.usp_Resultados @nro_fase = 99, @formato = 'CSV';
    PRINT 'FAIL Test 7: debio rechazar los parametros.';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50001
       AND ERROR_MESSAGE() LIKE '%fase inexistente%'
       AND ERROR_MESSAGE() LIKE '%formato invalido%'
        PRINT CONCAT('PASS Test 7: ', ERROR_MESSAGE());
    ELSE
        PRINT CONCAT('FAIL Test 7: ', ERROR_NUMBER(), ' - ', ERROR_MESSAGE());
END CATCH;
GO

PRINT '';
PRINT '=====================================================================';
PRINT 'FIN PRUEBAS DE ERROR: 88_Test_Reportes_ERR';
PRINT '=====================================================================';
GO
