/* ===================================================================== 
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: <una línea sobre lo que hace este script>
===================================================================== */
USE Mundial2026;
GO

-- 36_SP_Importacion.sql (se completa en la Entrega 6) ----------------------
--
CREATE OR ALTER PROCEDURE soporte.usp_Negocio_ImportarFixture
	@archivo NVARCHAR(260), @id_importacion INT OUTPUT
AS
BEGIN
	SELECT * FROM soporte.importacion
END;
GO