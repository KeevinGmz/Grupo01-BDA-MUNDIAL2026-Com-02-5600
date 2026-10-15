/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada Comisión: Com02-5600
Grupo : 01 - Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro, Agustin
Fecha : 2026-10-03
Objetivo: Prueba exitosa de ABM para el esquema Publicidad (alta y modificación de campañas y anunciantes)
===================================================================== */
USE Mundial2026;
GO

-- Resultado esperado: Creación e inserción exitosa de un anunciante y su campaña asociada.
BEGIN TRANSACTION;

    PRINT '--- EVIDENCIA ANTES DE INSERTAR ANUNCIANTE ---';
    SELECT * FROM publicidad.anunciante WHERE identificacion_fiscal = 'TAX-99999';

    DECLARE @v_id_anunciante INT;
    EXEC publicidad.usp_Anunciante_Insertar
        @razon_social = N'Empresa De Prueba S.A.',
        @identificacion_fiscal = 'TAX-99999',
        @contacto = N'contacto@prueba.com',
        @id_pais = 1,
        @id_anunciante = @v_id_anunciante OUTPUT;

    PRINT '--- EVIDENCIA DESPUES DE INSERTAR ANUNCIANTE (ID: ' + CAST(@v_id_anunciante AS VARCHAR) + ') ---';
    SELECT * FROM publicidad.anunciante WHERE id_anunciante = @v_id_anunciante;

ROLLBACK TRANSACTION;
GO