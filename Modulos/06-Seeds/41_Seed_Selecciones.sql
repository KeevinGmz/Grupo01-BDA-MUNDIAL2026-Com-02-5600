/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada                  
Comision: 02-5600
Grupo   : 01  
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole,Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Carga deterministica de jugadores genericos y convocatoria de 23 jugadores para cada una de las primeras 16 selecciones.
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @v_propia BIT = 0;
DECLARE @v_sp BIT = 0;
DECLARE @v_errores NVARCHAR(2000) = N'';
DECLARE @v_cant_selecciones INT;
DECLARE @v_id_club INT;
DECLARE @v_id_posicion TINYINT;

   --El Plan exige 16 selecciones con al menos 23 convocados cada una.

SELECT @v_cant_selecciones = COUNT(*)
FROM torneo.seleccion;

IF @v_cant_selecciones < 16
    SET @v_errores += CONCAT
    (
        N'se requieren al menos 16 selecciones y solo existen ',
        @v_cant_selecciones,
        N'; '
    );

SELECT TOP (1) @v_id_club = c.id_club
FROM persona.club AS c
ORDER BY c.id_club;

IF @v_id_club IS NULL
    SET @v_errores += N'debe existir al menos un club antes de generar jugadores; ';

SELECT TOP (1) @v_id_posicion = p.id_posicion
FROM persona.posicion AS p
ORDER BY
    CASE WHEN p.descripcion IN (N'ARQUERO', N'PORTERO') THEN 0 ELSE 1 END,
    p.id_posicion;

IF @v_id_posicion IS NULL
    SET @v_errores += N'debe existir al menos una posicion antes de generar jugadores; ';

IF TYPE_ID(N'torneo.tt_Convocado') IS NULL
    SET @v_errores += N'no existe el tipo torneo.tt_Convocado; ';

IF OBJECT_ID(N'persona.usp_Jugador_Insertar', N'P') IS NULL
    SET @v_errores += N'no existe persona.usp_Jugador_Insertar; ';

IF OBJECT_ID(N'torneo.usp_Negocio_RegistrarConvocatoria', N'P') IS NULL
    SET @v_errores += N'no existe torneo.usp_Negocio_RegistrarConvocatoria; ';

IF @v_errores <> N''
BEGIN
    SET @v_errores = LEFT
    (
        CONCAT(N'41_Seed_Jugadores_Convocatorias: ', @v_errores),
        2048
    );
    ;THROW 50001, @v_errores, 1;
END

BEGIN TRY
    IF @@TRANCOUNT = 0
    BEGIN
        BEGIN TRANSACTION;
        SET @v_propia = 1;
    END
    ELSE
    BEGIN
        SAVE TRANSACTION sv_seed_jug_conv;
        SET @v_sp = 1;
    END

    -- Se recorren las primeras 16 selecciones por ID real
    
    DECLARE @v_orden_seleccion TINYINT = 1;
    DECLARE @v_id_seleccion INT;
    DECLARE @v_id_pais SMALLINT;
    DECLARE @v_cant_activos INT;

    WHILE @v_orden_seleccion <= 16
    BEGIN
        SELECT
            @v_id_seleccion = x.id_seleccion,
            @v_id_pais = x.id_pais
        FROM
        (
            SELECT
                s.id_seleccion,
                s.id_pais,
                ROW_NUMBER() OVER (ORDER BY s.id_seleccion) AS rn
            FROM torneo.seleccion AS s
        ) AS x
        WHERE x.rn = @v_orden_seleccion;

        SELECT @v_cant_activos = COUNT(*)
        FROM torneo.convocatoria AS c
        WHERE c.id_seleccion = @v_id_seleccion
          AND c.estado = 'ACTIVO';

        /*
           El SP de negocio exige que la seleccion no tenga convocatoria ACTIVA.
           Si ya tiene exactamente 23 o mas activos, el lote no la duplica.
           Si tiene una convocatoria activa incompleta, se detiene para no ocultar
           una inconsistencia de datos.
        */
        IF @v_cant_activos BETWEEN 1 AND 22
        BEGIN
            SET @v_errores = CONCAT
            (
                N'41_Seed_Jugadores_Convocatorias: la seleccion ',
                @v_id_seleccion,
                N' posee una convocatoria ACTIVA incompleta de ',
                @v_cant_activos,
                N' jugadores'
            );
            ;THROW 50003, @v_errores, 1;
        END

        IF @v_cant_activos = 0
        BEGIN
            DECLARE @v_lista torneo.tt_Convocado;
            DECLARE @v_dorsal TINYINT = 1;
            DECLARE @v_id_jugador INT;
            DECLARE @v_nro_doc NVARCHAR(30);
            DECLARE @v_nombre NVARCHAR(80);
            DECLARE @v_apellido NVARCHAR(80);
            DECLARE @v_fecha_nac DATE;
            DECLARE @v_pie_habil CHAR(1);
            DECLARE @v_altura_cm SMALLINT;

            WHILE @v_dorsal <= 23
            BEGIN
                /* Documento deterministico y unico incluso si los IDENTITY tienen huecos. */
                SET @v_nro_doc = CONCAT
                (
                    N'SEED-',
                    RIGHT(CONCAT(N'000000', @v_id_seleccion), 6),
                    N'-',
                    RIGHT(CONCAT(N'00', @v_dorsal), 2)
                );

                SET @v_nombre = CONCAT(N'Jugador ', RIGHT(CONCAT(N'00', @v_dorsal), 2));
                SET @v_apellido = CONCAT(N'Seleccion ', @v_id_seleccion);
                SET @v_fecha_nac = DATEADD
                (
                    DAY,
                    -CONVERT(INT, @v_dorsal),
                    DATEFROMPARTS(2000 - (@v_orden_seleccion % 5), 1, 1)
                );

                SET @v_pie_habil = CASE WHEN @v_dorsal % 3 = 0 THEN 'I' ELSE 'D' END;
                SET @v_altura_cm = CONVERT(SMALLINT, 170 + (@v_dorsal % 20));
                SET @v_id_jugador = NULL;

                /* Permite reusar el jugador seed si una ejecucion anterior creo
                   personas pero no llego a registrar la convocatoria. */
                SELECT @v_id_jugador = p.id_persona
                FROM persona.persona AS p
                JOIN persona.jugador AS j
                  ON j.id_persona = p.id_persona
                WHERE p.tipo_doc = 'DNI'
                  AND p.nro_doc = @v_nro_doc;

                IF @v_id_jugador IS NULL
                BEGIN
                    EXEC persona.usp_Jugador_Insertar
                        @tipo_doc = 'DNI',
                        @nro_doc = @v_nro_doc,
                        @nombre = @v_nombre,
                        @apellido = @v_apellido,
                        @fecha_nac = @v_fecha_nac,
                        @id_pais = @v_id_pais,
                        @pie_habil = @v_pie_habil,
                        @altura_cm = @v_altura_cm,
                        @id_club = @v_id_club,
                        @id_posicion_habitual = @v_id_posicion,
                        @id_persona = @v_id_jugador OUTPUT;
                END

                INSERT INTO @v_lista
                (
                    id_jugador,
                    dorsal
                )
                VALUES
                (
                    @v_id_jugador,
                    @v_dorsal
                );

                SET @v_dorsal += 1;
            END

            EXEC torneo.usp_Negocio_RegistrarConvocatoria
                @id_seleccion = @v_id_seleccion,
                @convocados = @v_lista;
        END

        SET @v_orden_seleccion += 1;
    END

  
    -- Control final del requisito de aceptacion.
   
    IF EXISTS
    (
        SELECT 1
        FROM
        (
            SELECT TOP (16) s.id_seleccion
            FROM torneo.seleccion AS s
            ORDER BY s.id_seleccion
        ) AS seleccion
        OUTER APPLY
        (
            SELECT COUNT(*) AS cant_activos
            FROM torneo.convocatoria AS c
            WHERE c.id_seleccion = seleccion.id_seleccion
              AND c.estado = 'ACTIVO'
        ) AS convocatoria
        WHERE convocatoria.cant_activos < 23
    )
    BEGIN
        ;THROW 50003,
               N'41_Seed_Jugadores_Convocatorias: alguna de las 16 selecciones tiene menos de 23 convocados activos',
               1;
    END

    IF @v_propia = 1
        COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @v_propia = 1 AND @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    ELSE IF @v_sp = 1 AND XACT_STATE() = 1
        ROLLBACK TRANSACTION sv_seed_jug_conv;
    ;THROW;
END CATCH;
GO

-- Evidencia final
SELECT TOP (16)
    s.id_seleccion,
    pa.nombre AS seleccion,
    COUNT(CASE WHEN c.estado = 'ACTIVO' THEN 1 END) AS convocados_activos
FROM torneo.seleccion AS s
JOIN geo.pais AS pa ON pa.id_pais = s.id_pais
LEFT JOIN torneo.convocatoria AS c ON c.id_seleccion = s.id_seleccion
GROUP BY s.id_seleccion, pa.nombre
ORDER BY s.id_seleccion;
GO
