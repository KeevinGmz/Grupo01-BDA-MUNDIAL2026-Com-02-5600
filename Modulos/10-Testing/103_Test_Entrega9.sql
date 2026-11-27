/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-23
Objetivo: Entrega 9. Test de lo agregado para completar el alcance:
          reporte.usp_Fixture (filtros por sede, fase, seleccion y fecha),
          juego.vw_HistorialTitularidad y reporte.usp_HistorialTitularidad,
          informes post-partido (arbitraje.usp_Negocio_RegistrarInforme y
          reporte.usp_InformesArbitrales) e idiomas de los arbitros.
          Cada resultado se compara contra un conteo hecho por separado sobre
          las tablas. Las altas se hacen dentro de una transaccion que se
          deshace. Requiere haber ejecutado 100, 101 y 102.
          Resultado esperado: todos los casos PASS.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;

PRINT '=== 103_Test_Entrega9: alcance completado ===';

DECLARE @v_pass INT = 0;
DECLARE @v_fail INT = 0;
DECLARE @v_n INT;
DECLARE @v_esp INT;
DECLARE @v_msg NVARCHAR(400);
DECLARE @v_ok BIT;

IF OBJECT_ID('reporte.usp_Fixture', 'P') IS NULL
   OR OBJECT_ID('reporte.usp_HistorialTitularidad', 'P') IS NULL
   OR OBJECT_ID('arbitraje.usp_Negocio_RegistrarInforme', 'P') IS NULL
    THROW 50001, '103_Test_Entrega9: faltan objetos de la Entrega 9; ejecute 100, 101 y 102', 1;

CREATE TABLE #fx (
    id_partido INT, fase NVARCHAR(100), fecha_hora_utc DATETIME2(0), fecha_hora_local_sede DATETIME2(0),
    sede NVARCHAR(150), ciudad NVARCHAR(100), pais_sede NVARCHAR(100), huso_horario NVARCHAR(100),
    local NVARCHAR(100), visitante NVARCHAR(100), estado VARCHAR(20), marcador VARCHAR(30), asistencia_publico INT);

-------------------------------------------------------------------------------
-- Caso 1: la vista del fixture tiene una fila por partido
-------------------------------------------------------------------------------
SELECT @v_n = COUNT(*) FROM torneo.vw_Fixture;
SELECT @v_esp = COUNT(*) FROM torneo.partido;
IF @v_n = @v_esp AND @v_n > 0
BEGIN PRINT CONCAT('PASS  Caso 1: torneo.vw_Fixture tiene ', @v_n, ' partidos (uno por partido)'); SET @v_pass += 1; END
ELSE
BEGIN PRINT CONCAT('FAIL  Caso 1: la vista tiene ', @v_n, ' filas y hay ', @v_esp, ' partidos'); SET @v_fail += 1; END

-------------------------------------------------------------------------------
-- Caso 2: el fixture sin filtros devuelve todos los partidos
-------------------------------------------------------------------------------
BEGIN TRY
    TRUNCATE TABLE #fx;
    INSERT INTO #fx EXEC reporte.usp_Fixture;
    SELECT @v_n = COUNT(*) FROM #fx;
    IF @v_n = @v_esp
    BEGIN PRINT CONCAT('PASS  Caso 2: usp_Fixture sin filtros devuelve los ', @v_n, ' partidos'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  Caso 2: devuelve ', @v_n, ' y se esperaban ', @v_esp); SET @v_fail += 1; END
END TRY
BEGIN CATCH
    PRINT CONCAT('FAIL  Caso 2: error inesperado ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()); SET @v_fail += 1;
END CATCH

-------------------------------------------------------------------------------
-- Caso 3: filtro por fase (se compara con el conteo directo sobre torneo.partido)
-------------------------------------------------------------------------------
BEGIN TRY
    DECLARE @v_fase TINYINT = (SELECT TOP (1) nro_fase FROM torneo.partido GROUP BY nro_fase ORDER BY COUNT(*) DESC, nro_fase);
    SELECT @v_esp = COUNT(*) FROM torneo.partido WHERE nro_fase = @v_fase;
    TRUNCATE TABLE #fx;
    INSERT INTO #fx EXEC reporte.usp_Fixture @nro_fase = @v_fase;
    SELECT @v_n = COUNT(*) FROM #fx;
    IF @v_n = @v_esp AND @v_n > 0
    BEGIN PRINT CONCAT('PASS  Caso 3: fase ', @v_fase, ' devuelve ', @v_n, ' partidos'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  Caso 3: devuelve ', @v_n, ' y se esperaban ', @v_esp); SET @v_fail += 1; END
END TRY
BEGIN CATCH
    PRINT CONCAT('FAIL  Caso 3: error inesperado ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()); SET @v_fail += 1;
END CATCH

-------------------------------------------------------------------------------
-- Caso 4: filtro por sede
-------------------------------------------------------------------------------
BEGIN TRY
    DECLARE @v_sede INT = (SELECT TOP (1) id_sede FROM torneo.partido GROUP BY id_sede ORDER BY COUNT(*) DESC, id_sede);
    SELECT @v_esp = COUNT(*) FROM torneo.partido WHERE id_sede = @v_sede;
    TRUNCATE TABLE #fx;
    INSERT INTO #fx EXEC reporte.usp_Fixture @id_sede = @v_sede;
    SELECT @v_n = COUNT(*) FROM #fx;
    IF @v_n = @v_esp AND @v_n > 0 AND (SELECT COUNT(DISTINCT sede) FROM #fx) = 1
    BEGIN PRINT CONCAT('PASS  Caso 4: la sede ', @v_sede, ' devuelve ', @v_n, ' partidos, todos de esa sede'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  Caso 4: devuelve ', @v_n, ' y se esperaban ', @v_esp); SET @v_fail += 1; END
END TRY
BEGIN CATCH
    PRINT CONCAT('FAIL  Caso 4: error inesperado ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()); SET @v_fail += 1;
END CATCH

-------------------------------------------------------------------------------
-- Caso 5: filtro por seleccion (local o visitante)
-------------------------------------------------------------------------------
BEGIN TRY
    DECLARE @v_sel INT = (SELECT TOP (1) id_seleccion FROM torneo.equipo_en_partido GROUP BY id_seleccion ORDER BY COUNT(*) DESC, id_seleccion);
    SELECT @v_esp = COUNT(DISTINCT id_partido) FROM torneo.equipo_en_partido WHERE id_seleccion = @v_sel;
    TRUNCATE TABLE #fx;
    INSERT INTO #fx EXEC reporte.usp_Fixture @id_seleccion = @v_sel;
    SELECT @v_n = COUNT(*) FROM #fx;
    IF @v_n = @v_esp AND @v_n > 0
    BEGIN PRINT CONCAT('PASS  Caso 5: la seleccion ', @v_sel, ' juega ', @v_n, ' partidos'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  Caso 5: devuelve ', @v_n, ' y se esperaban ', @v_esp); SET @v_fail += 1; END
END TRY
BEGIN CATCH
    PRINT CONCAT('FAIL  Caso 5: error inesperado ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()); SET @v_fail += 1;
END CATCH

-------------------------------------------------------------------------------
-- Caso 6: filtro por fecha LOCAL de la sede (un solo dia), contra un calculo directo
-------------------------------------------------------------------------------
BEGIN TRY
    DECLARE @v_dia DATE = (SELECT TOP (1) CONVERT(DATE, geo.fn_FechaHoraLocal(p.fecha_hora_utc, ci.id_huso))
                           FROM torneo.partido AS p
                           JOIN torneo.sede AS se ON se.id_sede = p.id_sede
                           JOIN geo.ciudad AS ci ON ci.id_ciudad = se.id_ciudad
                           ORDER BY p.fecha_hora_utc, p.id_partido);
    SELECT @v_esp = COUNT(*)
    FROM torneo.partido AS p
    JOIN torneo.sede AS se ON se.id_sede = p.id_sede
    JOIN geo.ciudad AS ci ON ci.id_ciudad = se.id_ciudad
    WHERE CONVERT(DATE, geo.fn_FechaHoraLocal(p.fecha_hora_utc, ci.id_huso)) = @v_dia;
    TRUNCATE TABLE #fx;
    INSERT INTO #fx EXEC reporte.usp_Fixture @fecha_desde = @v_dia, @fecha_hasta = @v_dia;
    SELECT @v_n = COUNT(*) FROM #fx;
    IF @v_n = @v_esp AND @v_n > 0
    BEGIN PRINT CONCAT('PASS  Caso 6: el dia ', CONVERT(VARCHAR(10), @v_dia, 23), ' (hora local) hay ', @v_n, ' partidos'); SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  Caso 6: devuelve ', @v_n, ' y se esperaban ', @v_esp); SET @v_fail += 1; END
END TRY
BEGIN CATCH
    PRINT CONCAT('FAIL  Caso 6: error inesperado ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()); SET @v_fail += 1;
END CATCH

-------------------------------------------------------------------------------
-- Caso 7: un rango sin partidos devuelve 0 filas y el formato XML se ejecuta sin error
-- (el XML se ve en una celda del resultado; SQL Server no permite capturar un FOR XML con INSERT EXEC)
-------------------------------------------------------------------------------
BEGIN TRY
    TRUNCATE TABLE #fx;
    INSERT INTO #fx EXEC reporte.usp_Fixture @fecha_desde = '2100-01-01', @fecha_hasta = '2100-12-31';
    SELECT @v_n = COUNT(*) FROM #fx;
    EXEC reporte.usp_Fixture @id_sede = @v_sede, @formato = 'XML';
    IF @v_n = 0
    BEGIN PRINT 'PASS  Caso 7: un rango sin partidos devuelve 0 filas; el formato XML se genera sin error'; SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  Caso 7: el rango sin partidos devolvio ', @v_n, ' filas'); SET @v_fail += 1; END
END TRY
BEGIN CATCH
    PRINT CONCAT('FAIL  Caso 7: error inesperado ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()); SET @v_fail += 1;
END CATCH

-------------------------------------------------------------------------------
-- Caso 8: errores del fixture (sede inexistente, fechas invertidas, formato invalido)
-------------------------------------------------------------------------------
SET @v_ok = 1;
BEGIN TRY EXEC reporte.usp_Fixture @id_sede = -1; SET @v_ok = 0; END TRY
BEGIN CATCH IF ERROR_NUMBER() <> 50001 OR ERROR_MESSAGE() NOT LIKE '%sede inexistente%' SET @v_ok = 0; END CATCH
BEGIN TRY EXEC reporte.usp_Fixture @fecha_desde = '2026-07-01', @fecha_hasta = '2026-06-01'; SET @v_ok = 0; END TRY
BEGIN CATCH IF ERROR_NUMBER() <> 50001 OR ERROR_MESSAGE() NOT LIKE '%fecha_desde%' SET @v_ok = 0; END CATCH
BEGIN TRY EXEC reporte.usp_Fixture @formato = 'PDF'; SET @v_ok = 0; END TRY
BEGIN CATCH IF ERROR_NUMBER() <> 50001 OR ERROR_MESSAGE() NOT LIKE '%formato invalido%' SET @v_ok = 0; END CATCH
IF @v_ok = 1
BEGIN PRINT 'PASS  Caso 8: sede inexistente, fechas invertidas y formato invalido se rechazan (error 50001)'; SET @v_pass += 1; END
ELSE
BEGIN PRINT 'FAIL  Caso 8: alguna validacion del fixture no se rechazo como se esperaba'; SET @v_fail += 1; END

-------------------------------------------------------------------------------
-- Caso 9: historial de titularidad: una fila por jugador y partido de la lista
-------------------------------------------------------------------------------
SELECT @v_n = COUNT(*) FROM juego.vw_HistorialTitularidad;
SELECT @v_esp = COUNT(*) FROM juego.alineacion;
IF @v_n = @v_esp AND @v_n > 0
BEGIN PRINT CONCAT('PASS  Caso 9: juego.vw_HistorialTitularidad tiene ', @v_n, ' filas (una por alineacion)'); SET @v_pass += 1; END
ELSE
BEGIN PRINT CONCAT('FAIL  Caso 9: la vista tiene ', @v_n, ' filas y juego.alineacion tiene ', @v_esp); SET @v_fail += 1; END

-------------------------------------------------------------------------------
-- Caso 10: TITULAR + INGRESO + BANCO suman el total y TITULAR coincide con es_titular = 1
-------------------------------------------------------------------------------
SELECT @v_n = COUNT(*) FROM juego.vw_HistorialTitularidad WHERE rol_en_partido = 'TITULAR';
SELECT @v_esp = COUNT(*) FROM juego.alineacion WHERE es_titular = 1;
IF @v_n = @v_esp
   AND (SELECT COUNT(*) FROM juego.vw_HistorialTitularidad WHERE rol_en_partido IN ('TITULAR', 'INGRESO', 'BANCO'))
       = (SELECT COUNT(*) FROM juego.vw_HistorialTitularidad)
BEGIN PRINT CONCAT('PASS  Caso 10: ', @v_n, ' titularidades coinciden con es_titular = 1; todo rol es TITULAR, INGRESO o BANCO'); SET @v_pass += 1; END
ELSE
BEGIN PRINT CONCAT('FAIL  Caso 10: titulares en la vista ', @v_n, ' contra ', @v_esp, ' en la tabla'); SET @v_fail += 1; END

-------------------------------------------------------------------------------
-- Caso 11: usp_HistorialTitularidad funciona con y sin filtros y rechaza un jugador inexistente
-------------------------------------------------------------------------------
SET @v_ok = 1;
DECLARE @v_jug INT = (SELECT TOP (1) id_jugador FROM juego.alineacion ORDER BY id_partido, id_jugador);
BEGIN TRY
    EXEC reporte.usp_HistorialTitularidad @id_jugador = @v_jug;
END TRY
BEGIN CATCH SET @v_ok = 0; END CATCH
BEGIN TRY EXEC reporte.usp_HistorialTitularidad @id_jugador = -1; SET @v_ok = 0; END TRY
BEGIN CATCH IF ERROR_NUMBER() <> 50001 OR ERROR_MESSAGE() NOT LIKE '%jugador inexistente%' SET @v_ok = 0; END CATCH
BEGIN TRY EXEC reporte.usp_HistorialTitularidad @id_seleccion = -1; SET @v_ok = 0; END TRY
BEGIN CATCH IF ERROR_NUMBER() <> 50001 OR ERROR_MESSAGE() NOT LIKE '%seleccion inexistente%' SET @v_ok = 0; END CATCH
IF @v_ok = 1
BEGIN PRINT 'PASS  Caso 11: usp_HistorialTitularidad responde por jugador; jugador y seleccion inexistentes se rechazan'; SET @v_pass += 1; END
ELSE
BEGIN PRINT 'FAIL  Caso 11: usp_HistorialTitularidad no se comporta como se esperaba'; SET @v_fail += 1; END

-------------------------------------------------------------------------------
-- Caso 12: alta de un informe post-partido (vinculado a partido y arbitro) y rollback
-------------------------------------------------------------------------------
BEGIN TRY
    DECLARE @v_part INT, @v_arb INT, @v_inf INT, @v_antes INT;
    SELECT TOP (1) @v_part = p.id_partido, @v_arb = da.id_arbitro
    FROM torneo.partido AS p
    JOIN arbitraje.designacion_arbitral AS da ON da.id_partido = p.id_partido AND da.estado = 'DESIGNADA'
    WHERE p.estado = 'FINALIZADO'
    ORDER BY p.id_partido, da.id_rol;

    SELECT @v_antes = COUNT(*) FROM arbitraje.informe_designacion;
    BEGIN TRANSACTION;
    EXEC arbitraje.usp_Negocio_RegistrarInforme @id_partido = @v_part, @id_arbitro = @v_arb,
         @tipo = 'INFORME_TEST', @descripcion = 'Informe de prueba E9', @sancion_aplicada = 'Amonestacion',
         @id_informe = @v_inf OUTPUT;
    SELECT @v_n = COUNT(*)
    FROM arbitraje.informe_designacion AS idz
    JOIN arbitraje.informe_post_partido AS ip ON ip.id_informe = idz.id_informe
    WHERE idz.id_informe = @v_inf AND idz.id_partido = @v_part AND idz.id_arbitro = @v_arb
      AND ip.tipo = 'INFORME_TEST' AND ip.sancion_aplicada = 'Amonestacion';
    ROLLBACK TRANSACTION;
    SELECT @v_esp = COUNT(*) FROM arbitraje.informe_designacion;
    IF @v_n = 1 AND @v_esp = @v_antes
    BEGIN PRINT 'PASS  Caso 12: el informe queda vinculado al partido y al arbitro; el rollback no deja datos de prueba'; SET @v_pass += 1; END
    ELSE
    BEGIN PRINT CONCAT('FAIL  Caso 12: vinculados=', @v_n, ', informes antes=', @v_antes, ', despues=', @v_esp); SET @v_fail += 1; END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT CONCAT('FAIL  Caso 12: error inesperado ', ERROR_NUMBER(), ': ', ERROR_MESSAGE()); SET @v_fail += 1;
END CATCH

-------------------------------------------------------------------------------
-- Caso 13: el informe se rechaza si el partido no esta FINALIZADO, si el arbitro
-- no fue designado, si falta la descripcion o si la fecha es anterior al partido
-------------------------------------------------------------------------------
SET @v_ok = 1;
DECLARE @v_prog INT = (SELECT TOP (1) id_partido FROM torneo.partido WHERE estado = 'PROGRAMADO' ORDER BY id_partido);
DECLARE @v_otro_arb INT = (SELECT TOP (1) a.id_persona FROM persona.arbitro AS a
                           WHERE NOT EXISTS (SELECT 1 FROM arbitraje.designacion_arbitral AS d
                                             WHERE d.id_partido = @v_part AND d.id_arbitro = a.id_persona)
                           ORDER BY a.id_persona);
DECLARE @v_inf2 INT;
BEGIN TRY
    EXEC arbitraje.usp_Negocio_RegistrarInforme @id_partido = @v_prog, @id_arbitro = @v_arb,
         @tipo = 'X', @descripcion = 'X', @id_informe = @v_inf2 OUTPUT;
    SET @v_ok = 0;
END TRY
BEGIN CATCH IF ERROR_NUMBER() <> 50001 OR ERROR_MESSAGE() NOT LIKE '%no esta FINALIZADO%' SET @v_ok = 0; END CATCH
BEGIN TRY
    EXEC arbitraje.usp_Negocio_RegistrarInforme @id_partido = @v_part, @id_arbitro = @v_otro_arb,
         @tipo = 'X', @descripcion = 'X', @id_informe = @v_inf2 OUTPUT;
    SET @v_ok = 0;
END TRY
BEGIN CATCH IF ERROR_NUMBER() <> 50001 OR ERROR_MESSAGE() NOT LIKE '%designacion vigente%' SET @v_ok = 0; END CATCH
BEGIN TRY
    EXEC arbitraje.usp_Negocio_RegistrarInforme @id_partido = @v_part, @id_arbitro = @v_arb,
         @tipo = 'X', @descripcion = '   ', @id_informe = @v_inf2 OUTPUT;
    SET @v_ok = 0;
END TRY
BEGIN CATCH IF ERROR_NUMBER() <> 50001 OR ERROR_MESSAGE() NOT LIKE '%descripcion obligatoria%' SET @v_ok = 0; END CATCH
BEGIN TRY
    EXEC arbitraje.usp_Negocio_RegistrarInforme @id_partido = @v_part, @id_arbitro = @v_arb,
         @tipo = 'X', @descripcion = 'X', @fecha_informe = '2000-01-01', @id_informe = @v_inf2 OUTPUT;
    SET @v_ok = 0;
END TRY
BEGIN CATCH IF ERROR_NUMBER() <> 50001 OR ERROR_MESSAGE() NOT LIKE '%anterior al partido%' SET @v_ok = 0; END CATCH
IF @v_ok = 1 AND @@TRANCOUNT = 0
BEGIN PRINT 'PASS  Caso 13: partido no finalizado, arbitro no designado, descripcion vacia y fecha anterior se rechazan'; SET @v_pass += 1; END
ELSE
BEGIN PRINT 'FAIL  Caso 13: alguna validacion del informe no se rechazo como se esperaba'; SET @v_fail += 1; END

-------------------------------------------------------------------------------
-- Caso 14: el reporte de informes responde (todos los arbitros y uno solo),
-- hay informes cargados y un arbitro inexistente se rechaza
-------------------------------------------------------------------------------
SET @v_ok = 1;
DECLARE @v_arb_inf INT = (SELECT TOP (1) id_arbitro FROM arbitraje.informe_designacion ORDER BY id_informe);
BEGIN TRY
    EXEC reporte.usp_InformesArbitrales @id_arbitro = @v_arb_inf;
END TRY
BEGIN CATCH SET @v_ok = 0; END CATCH
BEGIN TRY EXEC reporte.usp_InformesArbitrales @id_arbitro = -1; SET @v_ok = 0; END TRY
BEGIN CATCH IF ERROR_NUMBER() <> 50001 OR ERROR_MESSAGE() NOT LIKE '%arbitro inexistente%' SET @v_ok = 0; END CATCH
SELECT @v_n = COUNT(*) FROM arbitraje.informe_designacion;
IF @v_ok = 1 AND @v_n >= 1
BEGIN PRINT CONCAT('PASS  Caso 14: usp_InformesArbitrales responde por arbitro y hay ', @v_n, ' informes cargados'); SET @v_pass += 1; END
ELSE
BEGIN PRINT CONCAT('FAIL  Caso 14: informes cargados=', @v_n, ' (ejecutar 102) o el reporte fallo'); SET @v_fail += 1; END

-------------------------------------------------------------------------------
-- Caso 15: todos los arbitros tienen al menos un idioma cargado
-------------------------------------------------------------------------------
SELECT @v_n = COUNT(*) FROM persona.arbitro AS a
WHERE NOT EXISTS (SELECT 1 FROM persona.persona_idioma AS pi WHERE pi.id_persona = a.id_persona);
IF @v_n = 0
BEGIN SELECT @v_esp = COUNT(*) FROM persona.arbitro; PRINT CONCAT('PASS  Caso 15: los ', @v_esp, ' arbitros tienen idiomas cargados'); SET @v_pass += 1; END
ELSE
BEGIN PRINT CONCAT('FAIL  Caso 15: ', @v_n, ' arbitros sin idioma (ejecutar 102)'); SET @v_fail += 1; END

DROP TABLE #fx;

PRINT '-----------------------------------------------------------------';
PRINT CONCAT('103_Test_Entrega9: ', @v_pass, ' PASS, ', @v_fail, ' FAIL');
IF @v_fail = 0 PRINT 'RESULTADO: OK - el alcance de la Entrega 9 esta cubierto';
ELSE PRINT 'RESULTADO: HAY FALLAS - revisar los casos FAIL';
GO
