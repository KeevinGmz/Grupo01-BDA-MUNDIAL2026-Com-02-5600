/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Cerrar conexiones activas y eliminar de forma segura la base de datos Mundial2026.
===================================================================== */
USE master;
GO

SET NOCOUNT ON;
GO

PRINT '=====================================================================';
PRINT 'INICIO: 99_Drop_Mundial2026';
PRINT '=====================================================================';

IF DB_ID('Mundial2026') IS NULL
BEGIN
    PRINT 'La base de datos Mundial2026 no existe. No se realizaron cambios.';
END
ELSE
BEGIN
    BEGIN TRY
        PRINT 'Cerrando conexiones activas a Mundial2026...';

        ALTER DATABASE Mundial2026
            SET SINGLE_USER
            WITH ROLLBACK IMMEDIATE;

        PRINT 'Eliminando la base de datos Mundial2026...';

        DROP DATABASE Mundial2026;

        IF DB_ID('Mundial2026') IS NULL
            PRINT 'PASS: la base de datos Mundial2026 fue eliminada correctamente.';
        ELSE
            THROW 50001,
                   '99_Drop_Mundial2026: la base continua existiendo despues del DROP DATABASE',
                   1;
    END TRY
    BEGIN CATCH
        DECLARE @v_error_numero INT = ERROR_NUMBER();
        DECLARE @v_error_mensaje NVARCHAR(2048) = ERROR_MESSAGE();

        /*
           Si SINGLE_USER se ejecuto pero DROP DATABASE fallo, se intenta
           devolver la base a MULTI_USER para no dejarla bloqueada.
        */
        IF DB_ID('Mundial2026') IS NOT NULL
        BEGIN
            BEGIN TRY
                ALTER DATABASE Mundial2026
                    SET MULTI_USER
                    WITH ROLLBACK IMMEDIATE;
            END TRY
            BEGIN CATCH
                PRINT CONCAT
                (
                    'Advertencia: no fue posible restaurar MULTI_USER. Error ',
                    ERROR_NUMBER(),
                    ': ',
                    ERROR_MESSAGE()
                );
            END CATCH;
        END;

        PRINT CONCAT
        (
            'FAIL: no se pudo eliminar Mundial2026. Error ',
            @v_error_numero,
            ': ',
            @v_error_mensaje
        );

        ;THROW;
    END CATCH;
END;

PRINT '=====================================================================';
PRINT 'FIN: 99_Drop_Mundial2026';
PRINT '=====================================================================';
GO
