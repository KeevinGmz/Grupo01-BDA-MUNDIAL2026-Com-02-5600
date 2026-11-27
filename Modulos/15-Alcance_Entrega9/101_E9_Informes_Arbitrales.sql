/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-23
Objetivo: Entrega 9. Modulo G: sanciones e informes post-partido de cada
          arbitro. Agrega la tabla puente arbitraje.informe_designacion
          (informe -> partido + arbitro), un SP para registrar informes y un
          reporte. No modifica ninguna tabla ni SP existente.
===================================================================== */
USE Mundial2026;
GO

/* ---------------------------------------------------------------------
   1. TABLA arbitraje.informe_designacion (tabla puente)
   Vincula cada informe post-partido con la designacion arbitral a la que
   se refiere (partido + arbitro). Un informe pertenece a una sola
   designacion. No se modifica arbitraje.informe_post_partido ni sus SP.
   --------------------------------------------------------------------- */
IF OBJECT_ID('arbitraje.informe_designacion', 'U') IS NULL
BEGIN
    CREATE TABLE arbitraje.informe_designacion (
        id_informe INT NOT NULL,
        id_partido INT NOT NULL,
        id_arbitro INT NOT NULL,
        CONSTRAINT PK_informe_designacion PRIMARY KEY (id_informe),
        CONSTRAINT FK_informe_designacion_informe FOREIGN KEY (id_informe)
            REFERENCES arbitraje.informe_post_partido (id_informe),
        CONSTRAINT FK_informe_designacion_designacion FOREIGN KEY (id_partido, id_arbitro)
            REFERENCES arbitraje.designacion_arbitral (id_partido, id_arbitro)
    );
    CREATE INDEX IX_informe_designacion_partido_arbitro
        ON arbitraje.informe_designacion (id_partido, id_arbitro);
    PRINT 'Tabla arbitraje.informe_designacion CREADA correctamente';
END
ELSE
BEGIN
    PRINT 'La tabla arbitraje.informe_designacion ya existe';
END;
GO

/* ---------------------------------------------------------------------
   2. SP arbitraje.usp_Negocio_RegistrarInforme
   Registra un informe post-partido (y la sancion, si hay) de un arbitro
   designado en un partido FINALIZADO. Usa el SP de la Entrega 5 para
   insertar el informe y luego lo vincula con la designacion.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE arbitraje.usp_Negocio_RegistrarInforme
    @id_partido INT,
    @id_arbitro INT,
    @tipo VARCHAR(30),
    @descripcion VARCHAR(1000),
    @sancion_aplicada VARCHAR(200) = NULL,
    @fecha_informe DATETIME2(0) = NULL,
    @id_informe INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @v_errores VARCHAR(2000) = '';
    DECLARE @v_propia BIT = 0;
    DECLARE @v_sp BIT = 0;
    DECLARE @v_estado VARCHAR(20);
    DECLARE @v_fecha_partido DATETIME2(0);
    BEGIN TRY
        -- 1) Validaciones: todas antes de abrir la transaccion; se acumulan
        IF @id_partido IS NULL SET @v_errores += 'id_partido obligatorio; ';
        IF @id_arbitro IS NULL SET @v_errores += 'id_arbitro obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@tipo)), '') IS NULL SET @v_errores += 'tipo obligatorio; ';
        IF NULLIF(LTRIM(RTRIM(@descripcion)), '') IS NULL SET @v_errores += 'descripcion obligatoria; ';

        IF @id_partido IS NOT NULL
        BEGIN
            SELECT @v_estado = estado, @v_fecha_partido = fecha_hora_utc
            FROM torneo.partido
            WHERE id_partido = @id_partido;

            IF @v_estado IS NULL
                SET @v_errores += 'partido inexistente; ';
            ELSE IF @v_estado <> 'FINALIZADO'
                SET @v_errores += 'el partido no esta FINALIZADO (el informe es posterior al partido); ';
        END

        IF @id_partido IS NOT NULL AND @id_arbitro IS NOT NULL
           AND NOT EXISTS (SELECT 1
                           FROM arbitraje.designacion_arbitral
                           WHERE id_partido = @id_partido
                             AND id_arbitro = @id_arbitro
                             AND estado = 'DESIGNADA')
            SET @v_errores += 'el arbitro no tiene una designacion vigente en ese partido; ';

        IF @fecha_informe IS NULL SET @fecha_informe = CONVERT(DATETIME2(0), SYSUTCDATETIME());
        IF @v_fecha_partido IS NOT NULL AND @fecha_informe < @v_fecha_partido
            SET @v_errores += 'la fecha del informe es anterior al partido; ';

        IF @v_errores <> ''
        BEGIN
            SET @v_errores = LEFT(CONCAT('arbitraje.usp_Negocio_RegistrarInforme: ', @v_errores), 2048);
            THROW 50001, @v_errores, 1;
        END

        -- 2) Transaccion propia o savepoint si ya hay una abierta
        IF @@TRANCOUNT = 0 BEGIN BEGIN TRANSACTION; SET @v_propia = 1; END
        ELSE BEGIN SAVE TRANSACTION sv_negocio_registrar_informe; SET @v_sp = 1; END

        EXEC arbitraje.usp_InformePostPartido_Insertar
             @fecha_informe = @fecha_informe,
             @tipo = @tipo,
             @descripcion = @descripcion,
             @sancion_aplicada = @sancion_aplicada,
             @id_informe = @id_informe OUTPUT;

        INSERT INTO arbitraje.informe_designacion (id_informe, id_partido, id_arbitro)
        VALUES (@id_informe, @id_partido, @id_arbitro);

        IF @v_propia = 1 COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @v_propia = 1 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        ELSE IF @v_sp = 1 AND XACT_STATE() = 1 ROLLBACK TRANSACTION sv_negocio_registrar_informe;
        THROW;
    END CATCH
END;
GO

/* ---------------------------------------------------------------------
   3. SP reporte.usp_InformesArbitrales
   Informes y sanciones post-partido recibidos por cada arbitro.
   Devuelve 2 resultados: (1) resumen por arbitro y (2) detalle.
   --------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE reporte.usp_InformesArbitrales
    @id_arbitro INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_errores VARCHAR(2000) = '';

    IF @id_arbitro IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM persona.arbitro WHERE id_persona = @id_arbitro)
        SET @v_errores += 'arbitro inexistente; ';

    IF @v_errores <> ''
    BEGIN
        SET @v_errores = LEFT(CONCAT('reporte.usp_InformesArbitrales: ', @v_errores), 2048);
        THROW 50001, @v_errores, 1;
    END

    -- 1) Resumen por arbitro (incluye los que no recibieron informes)
    SELECT
        CONCAT(pe.apellido, ', ', pe.nombre) AS arbitro,
        pa.nombre AS pais,
        ca.descripcion AS categoria,
        SUM(CASE WHEN ip.id_informe IS NOT NULL THEN 1 ELSE 0 END) AS informes,
        SUM(CASE WHEN NULLIF(LTRIM(RTRIM(ip.sancion_aplicada)), '') IS NOT NULL THEN 1 ELSE 0 END) AS con_sancion
    FROM persona.arbitro AS ar
    JOIN persona.persona AS pe ON pe.id_persona = ar.id_persona
    JOIN geo.pais AS pa ON pa.id_pais = pe.id_pais
    JOIN persona.categoria_arbitral AS ca ON ca.id_categoria = ar.id_categoria
    LEFT JOIN arbitraje.informe_designacion AS idz ON idz.id_arbitro = ar.id_persona
    LEFT JOIN arbitraje.informe_post_partido AS ip ON ip.id_informe = idz.id_informe
    WHERE @id_arbitro IS NULL OR ar.id_persona = @id_arbitro
    GROUP BY ar.id_persona, pe.apellido, pe.nombre, pa.nombre, ca.descripcion
    ORDER BY informes DESC, arbitro;

    -- 2) Detalle de cada informe
    SELECT
        CONCAT(pe.apellido, ', ', pe.nombre) AS arbitro,
        idz.id_partido,
        p.fecha_hora_utc,
        CONCAT(pl.nombre, ' vs ', pv.nombre) AS encuentro,
        ip.fecha_informe,
        ip.tipo,
        ip.descripcion,
        ip.sancion_aplicada
    FROM arbitraje.informe_designacion AS idz
    JOIN arbitraje.informe_post_partido AS ip ON ip.id_informe = idz.id_informe
    JOIN persona.persona AS pe ON pe.id_persona = idz.id_arbitro
    JOIN torneo.partido AS p ON p.id_partido = idz.id_partido
    LEFT JOIN torneo.equipo_en_partido AS el ON el.id_partido = p.id_partido AND el.condicion = 'L'
    LEFT JOIN torneo.seleccion AS sl ON sl.id_seleccion = el.id_seleccion
    LEFT JOIN geo.pais AS pl ON pl.id_pais = sl.id_pais
    LEFT JOIN torneo.equipo_en_partido AS ev ON ev.id_partido = p.id_partido AND ev.condicion = 'V'
    LEFT JOIN torneo.seleccion AS sv ON sv.id_seleccion = ev.id_seleccion
    LEFT JOIN geo.pais AS pv ON pv.id_pais = sv.id_pais
    WHERE @id_arbitro IS NULL OR idz.id_arbitro = @id_arbitro
    ORDER BY arbitro, p.fecha_hora_utc, ip.id_informe;
END;
GO
