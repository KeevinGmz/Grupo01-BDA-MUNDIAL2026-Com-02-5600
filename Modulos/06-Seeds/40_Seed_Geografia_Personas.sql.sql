/* ===================================================================== 
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Carga inicial de geografia.
===================================================================== */
USE Mundial2026;
GO


DECLARE @id_huso SMALLINT;

-- 1. Carga de los 3 husos horarios obligatorios
EXEC geo.usp_HusoHorario_Insertar @zona_horaria = 'America/Argentina/Buenos_Aires', @offset_utc = -180, @id_huso = @id_huso;
EXEC geo.usp_HusoHorario_Insertar @zona_horaria = 'America/New_York', @offset_utc = -240, @id_huso = @id_huso;
EXEC geo.usp_HusoHorario_Insertar @zona_horaria = 'America/Bogota', @offset_utc = -300, @id_huso = @id_huso;
GO

-- 2. Bucle para generar exactamente 8 sedes
DECLARE @s INT = 1;
DECLARE @id_sede_out INT;
WHILE @s <= 8
BEGIN
    DECLARE @aux VARCHAR(100);
    SET @aux = CONCAT( 'Sede Generica', @s);
    EXEC torneo.usp_Sede_Insertar 
        @nombre_estadio = @aux,
        @capacidad = @s,
        @direccion = N'xxx 1234',
        @id_ciudad = 1, -- Asumiendo ciudad pre-cargada
        @id_sede = @id_sede_out OUTPUT;
    SET @s = @s + 1;
END;
GO
