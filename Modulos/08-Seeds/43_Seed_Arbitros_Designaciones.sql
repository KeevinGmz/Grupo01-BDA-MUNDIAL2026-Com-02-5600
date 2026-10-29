/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comision: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-03
Objetivo: Carga inicial de 25 arbitros, designacion del cuerpo arbitral de los partidos y prueba del rechazo por nacionalidad (caso 5).
===================================================================== */
USE Mundial2026;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @v_errores NVARCHAR(2000) = N'';
DECLARE @v_propia BIT = 0;
DECLARE @v_sp BIT = 0;
DECLARE @v_id_categoria TINYINT;

-------------------------------------------------------------------------------
-- 1. Validaciones previas
-------------------------------------------------------------------------------

IF OBJECT_ID(N'persona.usp_Arbitro_Insertar', N'P') IS NULL
    SET @v_errores += N'no existe persona.usp_Arbitro_Insertar; ';

IF OBJECT_ID(N'arbitraje.usp_Negocio_DesignarTerna', N'P') IS NULL
    SET @v_errores += N'no existe arbitraje.usp_Negocio_DesignarTerna; ';

IF TYPE_ID(N'arbitraje.tt_Designacion') IS NULL
    SET @v_errores += N'no existe el tipo arbitraje.tt_Designacion; ';

SELECT TOP (1) @v_id_categoria = ca.id_categoria
FROM persona.categoria_arbitral AS ca
ORDER BY ca.id_categoria;

IF @v_id_categoria IS NULL
    SET @v_errores += N'debe existir al menos una categoria arbitral; ';

IF (SELECT COUNT(*) FROM geo.pais) < 5
    SET @v_errores += N'deben existir al menos cinco paises para distribuir los arbitros; ';

IF (SELECT COUNT(*) FROM torneo.partido) = 0
    SET @v_errores += N'debe existir al menos un partido para realizar designaciones; ';

IF NOT EXISTS
(
    SELECT 1 FROM arbitraje.rol_arbitral WHERE descripcion = N'PRINCIPAL'
)
    SET @v_errores += N'falta el rol PRINCIPAL; ';

IF NOT EXISTS
(
    SELECT 1 FROM arbitraje.rol_arbitral WHERE descripcion = N'ASISTENTE_1'
)
    SET @v_errores += N'falta el rol ASISTENTE_1; ';

IF NOT EXISTS
(
    SELECT 1 FROM arbitraje.rol_arbitral WHERE descripcion = N'ASISTENTE_2'
)
    SET @v_errores += N'falta el rol ASISTENTE_2; ';

IF @v_errores <> N''
BEGIN
    SET @v_errores = LEFT(CONCAT(N'43_Seed_Arbitros_Designaciones: ', @v_errores), 2048);
    ;THROW 50001, @v_errores, 1;
END;

-------------------------------------------------------------------------------
-- 2. Cinco paises de referencia
-------------------------------------------------------------------------------

DECLARE @v_paises TABLE
(
    orden TINYINT NOT NULL PRIMARY KEY,
    id_pais SMALLINT NOT NULL UNIQUE
);

INSERT INTO @v_paises (orden, id_pais)
SELECT
    CONVERT(TINYINT, ROW_NUMBER() OVER (ORDER BY p.id_pais)),
    p.id_pais
FROM
(
    -- Un país con selección en el torneo (para el caso de conflicto de
    -- nacionalidad de la sección 5) y cuatro países sin selección.
    SELECT primera.id_pais
    FROM
    (
        SELECT TOP (1) s.id_pais
        FROM torneo.seleccion AS s
        ORDER BY s.id_seleccion
    ) AS primera
    UNION ALL
    SELECT pais.id_pais
    FROM
    (
        SELECT TOP (4) g.id_pais
        FROM geo.pais AS g
        WHERE NOT EXISTS (SELECT 1 FROM torneo.seleccion AS s WHERE s.id_pais = g.id_pais)
        ORDER BY g.id_pais
    ) AS pais
) AS p;

-------------------------------------------------------------------------------
-- 3. Alta deterministica de 25 arbitros (5 por pais)
-------------------------------------------------------------------------------

BEGIN TRY
    IF @@TRANCOUNT = 0
    BEGIN
        BEGIN TRANSACTION;
        SET @v_propia = 1;
    END
    ELSE
    BEGIN
        SAVE TRANSACTION sv_seed_arbitros;
        SET @v_sp = 1;
    END;

    DECLARE @v_nro TINYINT = 1;
    DECLARE @v_id_arbitro INT;
    DECLARE @v_id_pais SMALLINT;
    DECLARE @v_orden_pais TINYINT;
    DECLARE @v_nro_doc NVARCHAR(30);
    DECLARE @v_nombre NVARCHAR(80);
    DECLARE @v_apellido NVARCHAR(80);
    DECLARE @v_fecha_nac DATE;

    WHILE @v_nro <= 25
    BEGIN
        SET @v_orden_pais = CONVERT(TINYINT, ((@v_nro - 1) % 5) + 1);

        SELECT @v_id_pais = p.id_pais
        FROM @v_paises AS p
        WHERE p.orden = @v_orden_pais;

        SET @v_nro_doc = CONCAT(N'ARB-SEED-', RIGHT(CONCAT(N'000', @v_nro), 3));
        SET @v_nombre = CONCAT(N'Arbitro ', RIGHT(CONCAT(N'00', @v_nro), 2));
        SET @v_apellido = N'Seed';
        SET @v_fecha_nac = DATEADD(YEAR, -35 - (@v_nro % 10), CONVERT(DATE, '2026-01-01'));
        SET @v_id_arbitro = NULL;

        SELECT @v_id_arbitro = p.id_persona
        FROM persona.persona AS p
        JOIN persona.arbitro AS a
          ON a.id_persona = p.id_persona
        WHERE p.tipo_doc = 'PAS'
          AND p.nro_doc = @v_nro_doc;

        IF @v_id_arbitro IS NULL
        BEGIN
            EXEC persona.usp_Arbitro_Insertar
                @tipo_doc = 'PAS',
                @nro_doc = @v_nro_doc,
                @nombre = @v_nombre,
                @apellido = @v_apellido,
                @fecha_nac = @v_fecha_nac,
                @id_pais = @v_id_pais,
                @fecha_debut_fifa = '2015-01-01',
                @id_categoria = @v_id_categoria,
                @id_persona = @v_id_arbitro OUTPUT;
        END;

        SET @v_nro += 1;
    END;

    IF
    (
        SELECT COUNT(*)
        FROM persona.persona AS p
        JOIN persona.arbitro AS a ON a.id_persona = p.id_persona
        WHERE p.tipo_doc = 'PAS'
          AND p.nro_doc LIKE N'ARB-SEED-%'
    ) <> 25
    BEGIN
        ;THROW 50003,
               N'43_Seed_Arbitros_Designaciones: no quedaron creados exactamente 25 arbitros seed',
               1;
    END;

    ---------------------------------------------------------------------------
    -- 4. Designacion de todos los partidos
    --
    -- Para cada partido se eligen cinco arbitros que no tengan la nacionalidad
    -- de ninguno de sus dos equipos. Los partidos se recorren por fecha.
    ---------------------------------------------------------------------------

    DECLARE @v_partidos TABLE
    (
        orden INT NOT NULL PRIMARY KEY,
        id_partido INT NOT NULL UNIQUE,
        fecha_hora_utc DATETIME2(0) NOT NULL
    );

    INSERT INTO @v_partidos (orden, id_partido, fecha_hora_utc)
    SELECT
        ROW_NUMBER() OVER (ORDER BY p.fecha_hora_utc, p.id_partido),
        p.id_partido,
        p.fecha_hora_utc
    FROM torneo.partido AS p
    WHERE p.estado <> 'FINALIZADO'
      -- Solo los partidos con alineaciones (seed 42): el fixture importado
      -- tiene 104 partidos y los árbitros seed no alcanzan para todos.
      AND EXISTS (SELECT 1 FROM juego.alineacion AS a WHERE a.id_partido = p.id_partido);

    DECLARE @v_orden_partido INT = 1;
    DECLARE @v_cant_partidos INT;
    DECLARE @v_id_partido INT;
    DECLARE @v_advertencia NVARCHAR(500);

    SELECT @v_cant_partidos = COUNT(*) FROM @v_partidos;

    WHILE @v_orden_partido <= @v_cant_partidos
    BEGIN
        SELECT @v_id_partido = p.id_partido
        FROM @v_partidos AS p
        WHERE p.orden = @v_orden_partido;

        DECLARE @v_terna arbitraje.tt_Designacion;

        -- DECLARE dentro del WHILE no reinicia la variable: se vacía en cada vuelta.
        DELETE FROM @v_terna;

        ;WITH roles AS
        (
            SELECT
                r.id_rol,
                ROW_NUMBER() OVER
                (
                    ORDER BY CASE r.descripcion
                        WHEN N'PRINCIPAL' THEN 1
                        WHEN N'ASISTENTE_1' THEN 2
                        WHEN N'ASISTENTE_2' THEN 3
                        WHEN N'CUARTO' THEN 4
                        WHEN N'VAR' THEN 5
                        ELSE 99 END
                ) AS rn
            FROM arbitraje.rol_arbitral AS r
            WHERE r.descripcion IN
                  (N'PRINCIPAL', N'ASISTENTE_1', N'ASISTENTE_2', N'CUARTO', N'VAR')
        ),
        arbitros_aptos AS
        (
            SELECT
                a.id_persona AS id_arbitro,
                ROW_NUMBER() OVER (ORDER BY a.id_persona) AS rn
            FROM persona.arbitro AS a
            JOIN persona.persona AS p
              ON p.id_persona = a.id_persona
            WHERE p.tipo_doc = 'PAS'
              AND p.nro_doc LIKE N'ARB-SEED-%'
              AND NOT EXISTS
                  (
                      SELECT 1
                      FROM torneo.equipo_en_partido AS ep
                      JOIN torneo.seleccion AS s
                        ON s.id_seleccion = ep.id_seleccion
                      WHERE ep.id_partido = @v_id_partido
                        AND s.id_pais = p.id_pais
                  )
              AND NOT EXISTS
                  (
                      SELECT 1
                      FROM arbitraje.designacion_arbitral AS da
                      JOIN torneo.partido AS otro
                        ON otro.id_partido = da.id_partido
                      JOIN torneo.partido AS actual
                        ON actual.id_partido = @v_id_partido
                      WHERE da.id_arbitro = a.id_persona
                        AND da.estado = 'DESIGNADA'
                        AND da.id_partido <> @v_id_partido
                        AND ABS(DATEDIFF(MINUTE, otro.fecha_hora_utc, actual.fecha_hora_utc)) < 180
                  )
        )
        INSERT INTO @v_terna (id_rol, id_arbitro)
        SELECT r.id_rol, a.id_arbitro
        FROM roles AS r
        JOIN arbitros_aptos AS a ON a.rn = r.rn
        WHERE r.rn <= 5;

        IF
        (
            SELECT COUNT(*)
            FROM @v_terna
        ) < 3
        BEGIN
            ;THROW 50003,
                   N'43_Seed_Arbitros_Designaciones: no hay suficientes arbitros compatibles para un partido',
                   1;
        END;

        SET @v_advertencia = N'';

        EXEC arbitraje.usp_Negocio_DesignarTerna
            @id_partido = @v_id_partido,
            @terna = @v_terna,
            @advertencia = @v_advertencia OUTPUT;

        IF NULLIF(@v_advertencia, N'') IS NOT NULL
            PRINT @v_advertencia;

        SET @v_orden_partido += 1;
    END;

    IF @v_propia = 1
        COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @v_propia = 1 AND @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    ELSE IF @v_sp = 1 AND XACT_STATE() = 1
        ROLLBACK TRANSACTION sv_seed_arbitros;
    ;THROW;
END CATCH;
GO

-------------------------------------------------------------------------------
-- 5. Caso obligatorio: rechazo por coincidencia de nacionalidad
--
-- Esta prueba se ejecuta fuera de la carga principal. Se toma un partido real,
-- un arbitro seed del pais de uno de los equipos y se completa el TVP con
-- arbitros distintos. El error esperado es 50003 y no debe reemplazar la terna.
-------------------------------------------------------------------------------

DECLARE @v_partido_prueba INT;
DECLARE @v_arbitro_conflicto INT;

SELECT TOP (1)
    @v_partido_prueba = p.id_partido,
    @v_arbitro_conflicto = arb.id_persona
FROM torneo.partido AS p
JOIN torneo.equipo_en_partido AS ep
  ON ep.id_partido = p.id_partido
JOIN torneo.seleccion AS s
  ON s.id_seleccion = ep.id_seleccion
CROSS APPLY
(
    SELECT TOP (1) a.id_persona
    FROM persona.arbitro AS a
    JOIN persona.persona AS per
      ON per.id_persona = a.id_persona
    WHERE per.id_pais = s.id_pais
      AND per.tipo_doc = 'PAS'
      AND per.nro_doc LIKE N'ARB-SEED-%'
    ORDER BY a.id_persona
) AS arb
WHERE p.estado <> 'FINALIZADO'
ORDER BY p.fecha_hora_utc, p.id_partido;

IF @v_partido_prueba IS NULL OR @v_arbitro_conflicto IS NULL
BEGIN
    ;THROW 50003,
           N'43_Seed_Arbitros_Designaciones: no se pudo preparar el caso de rechazo por nacionalidad',
           1;
END;

BEGIN TRY
    DECLARE @v_terna_invalida arbitraje.tt_Designacion;
    DECLARE @v_advertencia_prueba NVARCHAR(500);

    ;WITH roles AS
    (
        SELECT
            r.id_rol,
            ROW_NUMBER() OVER
            (
                ORDER BY CASE r.descripcion
                    WHEN N'PRINCIPAL' THEN 1
                    WHEN N'ASISTENTE_1' THEN 2
                    WHEN N'ASISTENTE_2' THEN 3
                    WHEN N'CUARTO' THEN 4
                    WHEN N'VAR' THEN 5
                    ELSE 99 END
            ) AS rn
        FROM arbitraje.rol_arbitral AS r
        WHERE r.descripcion IN
              (N'PRINCIPAL', N'ASISTENTE_1', N'ASISTENTE_2', N'CUARTO', N'VAR')
    ),
    arbitros AS
    (
        SELECT
            a.id_persona AS id_arbitro,
            ROW_NUMBER() OVER
            (
                ORDER BY CASE WHEN a.id_persona = @v_arbitro_conflicto THEN 0 ELSE 1 END,
                         a.id_persona
            ) AS rn
        FROM persona.arbitro AS a
        JOIN persona.persona AS p
          ON p.id_persona = a.id_persona
        WHERE p.tipo_doc = 'PAS'
          AND p.nro_doc LIKE N'ARB-SEED-%'
    )
    INSERT INTO @v_terna_invalida (id_rol, id_arbitro)
    SELECT r.id_rol, a.id_arbitro
    FROM roles AS r
    JOIN arbitros AS a ON a.rn = r.rn
    WHERE r.rn <= 5;

    EXEC arbitraje.usp_Negocio_DesignarTerna
        @id_partido = @v_partido_prueba,
        @terna = @v_terna_invalida,
        @advertencia = @v_advertencia_prueba OUTPUT;

    ;THROW 50003,
           N'43_Seed_Arbitros_Designaciones: FAIL, la designacion incompatible fue aceptada',
           1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 50003
       AND ERROR_MESSAGE() LIKE N'%nacionalidad%'
    BEGIN
        PRINT N'PASS caso 5: la designacion fue rechazada por coincidencia de nacionalidad.';
    END
    ELSE
    BEGIN
        ;THROW;
    END;
END CATCH;
GO

-------------------------------------------------------------------------------
-- 6. Evidencia final
-------------------------------------------------------------------------------

SELECT
    COUNT(*) AS arbitros_seed
FROM persona.persona AS p
JOIN persona.arbitro AS a
  ON a.id_persona = p.id_persona
WHERE p.tipo_doc = 'PAS'
  AND p.nro_doc LIKE N'ARB-SEED-%';

SELECT
    da.id_partido,
    ra.descripcion AS rol,
    da.id_arbitro,
    CONCAT(p.apellido, N', ', p.nombre) AS arbitro,
    pais.nombre AS pais,
    da.fecha_designacion,
    da.estado
FROM arbitraje.designacion_arbitral AS da
JOIN arbitraje.rol_arbitral AS ra
  ON ra.id_rol = da.id_rol
JOIN persona.persona AS p
  ON p.id_persona = da.id_arbitro
JOIN geo.pais AS pais
  ON pais.id_pais = p.id_pais
ORDER BY da.id_partido, da.id_rol;
GO
