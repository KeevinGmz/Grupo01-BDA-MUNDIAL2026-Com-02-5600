/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Crea el procedimiento transaccional de negocio para designar la terna/cuerpo arbitral de un partido.
===================================================================== */
USE Mundial2026;
GO

CREATE OR ALTER PROCEDURE arbitraje.usp_Negocio_DesignarTerna
    @id_partido INT,
    @terna arbitraje.tt_Designacion READONLY,
    @advertencia NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_codigo INT = 50001;
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    DECLARE @v_estado VARCHAR(12);
    DECLARE @v_nro_fase TINYINT;
    DECLARE @v_fecha_hora_partido DATETIME2(0);
    DECLARE @v_fecha_designacion DATETIME2(0) = SYSUTCDATETIME();

    SET @advertencia = N'';

    SELECT
        @v_estado = p.estado,
        @v_nro_fase = p.nro_fase,
        @v_fecha_hora_partido = p.fecha_hora_utc
    FROM torneo.partido AS p
    WHERE p.id_partido = @id_partido;

    -- 1) Validaciones acumuladas antes de abrir la transaccion
    IF @v_estado IS NULL
        SET @v_errores += N'partido inexistente; ';

    IF @v_estado = 'FINALIZADO'
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'no se puede reemplazar la designacion de un partido FINALIZADO; ';
    END

    -- PRINCIPAL, ASISTENTE_1 y ASISTENTE_2 son obligatorios.
    IF NOT EXISTS
    (
        SELECT 1
        FROM @terna AS t
        JOIN arbitraje.rol_arbitral AS r
          ON r.id_rol = t.id_rol
        WHERE r.descripcion = N'PRINCIPAL'
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'falta el rol obligatorio PRINCIPAL; ';
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM @terna AS t
        JOIN arbitraje.rol_arbitral AS r
          ON r.id_rol = t.id_rol
        WHERE r.descripcion = N'ASISTENTE_1'
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'falta el rol obligatorio ASISTENTE_1; ';
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM @terna AS t
        JOIN arbitraje.rol_arbitral AS r
          ON r.id_rol = t.id_rol
        WHERE r.descripcion = N'ASISTENTE_2'
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'falta el rol obligatorio ASISTENTE_2; ';
    END

    -- CUARTO y VAR son opcionales. No se admiten roles fuera del cuerpo previsto.
    IF EXISTS
    (
        SELECT 1
        FROM @terna AS t
        LEFT JOIN arbitraje.rol_arbitral AS r
          ON r.id_rol = t.id_rol
        WHERE r.id_rol IS NULL
    )
        SET @v_errores += N'la terna contiene roles inexistentes; ';

    IF EXISTS
    (
        SELECT 1
        FROM @terna AS t
        JOIN arbitraje.rol_arbitral AS r
          ON r.id_rol = t.id_rol
        WHERE r.descripcion NOT IN
              (N'PRINCIPAL', N'ASISTENTE_1', N'ASISTENTE_2', N'CUARTO', N'VAR')
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'la terna contiene un rol no permitido; ';
    END

    IF (SELECT COUNT(*) FROM @terna) NOT BETWEEN 3 AND 5
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'el cuerpo arbitral debe tener entre 3 y 5 integrantes; ';
    END

    IF EXISTS
    (
        SELECT t.id_arbitro
        FROM @terna AS t
        GROUP BY t.id_arbitro
        HAVING COUNT(*) > 1
    )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'un arbitro no puede ocupar mas de un rol en la terna; ';
    END

    IF EXISTS
    (
        SELECT 1
        FROM @terna AS t
        LEFT JOIN persona.arbitro AS a
          ON a.id_persona = t.id_arbitro
        WHERE a.id_persona IS NULL
    )
        SET @v_errores += N'la terna contiene arbitros inexistentes; ';

    -- Conflicto de nacionalidad con cualquiera de los equipos del partido.
    IF @v_estado IS NOT NULL
       AND EXISTS
       (
           SELECT 1
           FROM @terna AS t
           JOIN persona.persona AS per
             ON per.id_persona = t.id_arbitro
           JOIN torneo.equipo_en_partido AS ep
             ON ep.id_partido = @id_partido
           JOIN torneo.seleccion AS s
             ON s.id_seleccion = ep.id_seleccion
           WHERE per.id_pais = s.id_pais
       )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'un arbitro tiene la misma nacionalidad que una seleccion del partido; ';
    END

    -- Ningun arbitro puede estar designado en otro partido a menos de tres horas.
    IF @v_fecha_hora_partido IS NOT NULL
       AND EXISTS
       (
           SELECT 1
           FROM @terna AS t
           JOIN arbitraje.designacion_arbitral AS da
             ON da.id_arbitro = t.id_arbitro
            AND da.estado = 'DESIGNADA'
           JOIN torneo.partido AS otro
             ON otro.id_partido = da.id_partido
           WHERE da.id_partido <> @id_partido
             AND ABS(DATEDIFF(MINUTE, otro.fecha_hora_utc, @v_fecha_hora_partido)) < 180
       )
    BEGIN
        SET @v_codigo = 50003;
        SET @v_errores += N'un arbitro esta designado en otro partido con menos de tres horas de diferencia; ';
    END

    IF @v_errores <> N''
    BEGIN
        SET @v_errores = LEFT
        (
            CONCAT(N'arbitraje.usp_Negocio_DesignarTerna: ', @v_errores),
            2048
        );
        THROW @v_codigo, @v_errores, 1;
    END

    IF @v_nro_fase >= 2
    BEGIN
        SELECT @advertencia = LEFT
        (
            CONCAT
            (
                N'ADVERTENCIA: ',
                STRING_AGG
                (
                    CONVERT
                    (
                        NVARCHAR(MAX),
                        CONCAT
                        (
                            per.apellido,
                            N', ',
                            per.nombre,
                            N' (',
                            pais.nombre,
                            N')'
                        )
                    ),
                    N'; '
                ) WITHIN GROUP (ORDER BY per.apellido, per.nombre, pais.nombre)
            ),
            500
        )
        FROM @terna AS t
        JOIN persona.persona AS per
          ON per.id_persona = t.id_arbitro
        JOIN geo.pais AS pais
          ON pais.id_pais = per.id_pais
        WHERE EXISTS
        (
            SELECT 1
            FROM torneo.seleccion AS s
            WHERE s.id_pais = per.id_pais
              AND EXISTS
              (
                  SELECT 1
                  FROM torneo.equipo_en_partido AS ep
                  JOIN torneo.partido AS p
                    ON p.id_partido = ep.id_partido
                  WHERE ep.id_seleccion = s.id_seleccion
                    AND p.nro_fase >= 2
              )
              AND NOT EXISTS
              (
                  SELECT 1
                  FROM torneo.vw_SeleccionesEliminadas AS eliminada
                  WHERE eliminada.id_seleccion = s.id_seleccion
              )
        );

        SET @advertencia = ISNULL(@advertencia, N'');
    END

    BEGIN TRY
        -- 3) Transaccion propia o savepoint si ya existe una transaccion
        IF @@TRANCOUNT = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @v_propia = 1;
        END
        ELSE
        BEGIN
            SAVE TRANSACTION sv_designar_terna;
            SET @v_sp = 1;
        END

        -- Reemplaza la designacion anterior del partido de manera atomica.
        DELETE FROM arbitraje.designacion_arbitral
        WHERE id_partido = @id_partido;

        INSERT INTO arbitraje.designacion_arbitral
        (
            id_partido,
            id_rol,
            id_arbitro,
            fecha_designacion,
            estado
        )
        SELECT
            @id_partido,
            t.id_rol,
            t.id_arbitro,
            @v_fecha_designacion,
            'DESIGNADA'
        FROM @terna AS t;

        IF @v_propia = 1
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION sv_designar_terna;
        THROW;
    END CATCH
END;
GO
