/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada Comisión: Com02-5600
Grupo : 01 - Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro, Agustin
Fecha : 2026-10-03
Objetivo: Prueba exitosa de ABM para el esquema Juego (inserción y actualización de criterio de suspensión)
===================================================================== */
USE Mundial2026;
GO

-- Resultado esperado: Modificación exitosa de un criterio de suspensión existente.
BEGIN TRANSACTION;

    PRINT '--- EVIDENCIA ANTES DE MODIFICAR CRITERIO ---';
    SELECT * FROM juego.criterio_suspension WHERE id_criterio = 1;

    EXEC juego.usp_CriterioSuspension_Modificar
        @id_criterio = 1,
        @id_tipo = 1,
        @cant_tarjetas_requeridas = 2,
        @cant_partidos_suspension = 1,
        @vigente = 1;

    PRINT '--- EVIDENCIA DESPUES DE MODIFICAR CRITERIO ---';
    SELECT * FROM juego.criterio_suspension WHERE id_criterio = 1;

ROLLBACK TRANSACTION;
GO