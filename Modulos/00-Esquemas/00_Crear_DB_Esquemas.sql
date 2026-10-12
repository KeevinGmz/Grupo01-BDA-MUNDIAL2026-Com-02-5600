/* ===================================================================== 
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Crear los esquemas de la base de datos
===================================================================== */
USE master; 
GO

IF DB_ID('Mundial2026') IS NULL
BEGIN
	CREATE DATABASE Mundial2026 COLLATE Latin1_General_CI_AI;
	PRINT 'Bases de Datos CREADA';
END
ELSE
BEGIN
	Print 'La Base de Datos ya EXISTE';
END;
GO

USE Mundial2026;
GO

IF SCHEMA_ID('geo') IS NULL
BEGIN
	EXEC ('CREATE SCHEMA geo');
	PRINT 'Esquema geo CREADO correctamente';
END
ELSE
BEGIN
	PRINT 'El esquema geo ya existe';
END;

IF SCHEMA_ID('persona') IS NULL
BEGIN
	EXEC ('CREATE SCHEMA persona');
	PRINT 'Esquema persona CREADO correctamente';
END
ELSE
BEGIN
	PRINT 'El esquema persona ya existe';
END;

IF SCHEMA_ID('torneo') IS NULL
BEGIN
	EXEC ('CREATE SCHEMA torneo');
	PRINT 'Esquema torneo CREADO correctamente';
END
ELSE
BEGIN
	PRINT 'El esquema torneo ya existe';
END;

IF SCHEMA_ID('juego') IS NULL
BEGIN
	EXEC ('CREATE SCHEMA juego');
	PRINT 'Esquema juego CREADO correctamente';
END
ELSE
BEGIN
	PRINT 'El esquema juego ya existe';
END;

IF SCHEMA_ID('arbitraje') IS NULL
BEGIN
	EXEC ('CREATE SCHEMA arbitraje');
	PRINT 'Esquema arbitraje CREADO correctamente';
END
ELSE
BEGIN
	PRINT 'El esquema arbitraje ya existe';
END;

IF SCHEMA_ID('publicidad') IS NULL
BEGIN
	EXEC ('CREATE SCHEMA publicidad');
	PRINT 'Esquema publicidad CREADO correctamente';
END
ELSE
BEGIN
	PRINT 'El esquema publicidad ya existe';
END;

IF SCHEMA_ID('soporte') IS NULL
BEGIN
	EXEC ('CREATE SCHEMA soporte');
	PRINT 'Esquema soporte CREADO correctamente';
END
ELSE
BEGIN
	PRINT 'El esquema soporte ya existe';
END;

