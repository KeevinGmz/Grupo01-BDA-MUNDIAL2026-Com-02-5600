/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-23
Objetivo: Entrega 9. Seed de datos faltantes del modulo G: idiomas de los
          arbitros (persona_idioma) e informes post-partido de ejemplo.
          Requiere haber ejecutado 101. Re-ejecutable.
===================================================================== */
USE Mundial2026;
GO

/* ---------------------------------------------------------------------
   Seed 1: idiomas de los arbitros (persona.persona_idioma)
   Cada arbitro habla ingles (idioma de trabajo) y uno mas, asignado de
   forma rotativa. Re-ejecutable: solo agrega lo que falta.
   --------------------------------------------------------------------- */
DECLARE @v_errores VARCHAR(2000) = '';
IF OBJECT_ID('persona.usp_PersonaIdioma_Insertar', 'P') IS NULL
    SET @v_errores += 'no existe persona.usp_PersonaIdioma_Insertar; ';
IF OBJECT_ID('arbitraje.usp_Negocio_RegistrarInforme', 'P') IS NULL
    SET @v_errores += 'no existe arbitraje.usp_Negocio_RegistrarInforme (ejecutar 101 antes); ';
IF @v_errores <> ''
BEGIN
    SET @v_errores = LEFT(CONCAT('102_E9_Seed_Idiomas_Informes: ', @v_errores), 2048);
    THROW 50001, @v_errores, 1;
END

DECLARE @v_arbitros TABLE (orden INT IDENTITY(1,1) PRIMARY KEY, id_persona INT NOT NULL);
INSERT INTO @v_arbitros (id_persona)
SELECT id_persona FROM persona.arbitro ORDER BY id_persona;

DECLARE @v_otros TABLE (orden INT PRIMARY KEY, cod CHAR(3) NOT NULL);
INSERT INTO @v_otros (orden, cod)
VALUES (0, 'spa'), (1, 'por'), (2, 'fra'), (3, 'deu'), (4, 'ita'), (5, 'ara'), (6, 'jpn');

DECLARE @v_i INT = 1;
DECLARE @v_n INT = (SELECT COUNT(*) FROM @v_arbitros);
DECLARE @v_id INT;
DECLARE @v_ing SMALLINT = (SELECT id_idioma FROM persona.idioma WHERE cod_iso639 = 'eng');
DECLARE @v_otro SMALLINT;
DECLARE @v_cargados INT = 0;

WHILE @v_i <= @v_n
BEGIN
    SELECT @v_id = id_persona FROM @v_arbitros WHERE orden = @v_i;
    SELECT @v_otro = i.id_idioma
    FROM @v_otros AS o
    JOIN persona.idioma AS i ON i.cod_iso639 = o.cod
    WHERE o.orden = (@v_i - 1) % 7;

    IF @v_ing IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM persona.persona_idioma WHERE id_persona = @v_id AND id_idioma = @v_ing)
    BEGIN
        EXEC persona.usp_PersonaIdioma_Insertar @id_persona = @v_id, @id_idioma = @v_ing;
        SET @v_cargados += 1;
    END

    IF @v_otro IS NOT NULL AND @v_otro <> @v_ing
       AND NOT EXISTS (SELECT 1 FROM persona.persona_idioma WHERE id_persona = @v_id AND id_idioma = @v_otro)
    BEGIN
        EXEC persona.usp_PersonaIdioma_Insertar @id_persona = @v_id, @id_idioma = @v_otro;
        SET @v_cargados += 1;
    END

    SET @v_i += 1;
END

PRINT CONCAT('Idiomas de arbitros cargados: ', @v_cargados);
GO

/* ---------------------------------------------------------------------
   Seed 2: informes post-partido de ejemplo (4), sobre partidos FINALIZADOS,
   repartidos entre los arbitros principales (como maximo 2 por arbitro, en
   orden cronologico). Dos de ellos con sancion. Solo se cargan si todavia
   no hay informes vinculados.
   --------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM arbitraje.informe_designacion)
BEGIN
    DECLARE @v_casos TABLE (orden INT IDENTITY(1,1) PRIMARY KEY, id_partido INT NOT NULL, id_arbitro INT NOT NULL, fecha_hora_utc DATETIME2(0) NOT NULL);
    INSERT INTO @v_casos (id_partido, id_arbitro, fecha_hora_utc)
    SELECT TOP (4) x.id_partido, x.id_arbitro, x.fecha_hora_utc
    FROM
    (
        SELECT p.id_partido, da.id_arbitro, p.fecha_hora_utc,
               ROW_NUMBER() OVER (PARTITION BY da.id_arbitro ORDER BY p.fecha_hora_utc, p.id_partido) AS nro_del_arbitro
        FROM torneo.partido AS p
        JOIN arbitraje.designacion_arbitral AS da ON da.id_partido = p.id_partido AND da.estado = 'DESIGNADA'
        JOIN arbitraje.rol_arbitral AS ra ON ra.id_rol = da.id_rol AND ra.descripcion = 'PRINCIPAL'
        WHERE p.estado = 'FINALIZADO'
    ) AS x
    WHERE x.nro_del_arbitro <= 2
    ORDER BY x.fecha_hora_utc, x.id_partido;

    DECLARE @v_k INT = 1;
    DECLARE @v_total INT = (SELECT COUNT(*) FROM @v_casos);
    DECLARE @v_part INT;
    DECLARE @v_arb INT;
    DECLARE @v_fp DATETIME2(0);
    DECLARE @v_fi DATETIME2(0);
    DECLARE @v_tipo VARCHAR(30);
    DECLARE @v_desc VARCHAR(1000);
    DECLARE @v_sanc VARCHAR(200);
    DECLARE @v_inf INT;

    WHILE @v_k <= @v_total
    BEGIN
        SELECT @v_part = id_partido, @v_arb = id_arbitro, @v_fp = fecha_hora_utc FROM @v_casos WHERE orden = @v_k;
        SET @v_fi = DATEADD(DAY, 1, @v_fp);
        SET @v_tipo = CASE WHEN @v_k % 2 = 1 THEN 'INFORME_ARBITRAL' ELSE 'INFORME_DISCIPLINARIO' END;
        SET @v_desc = CASE @v_k
            WHEN 1 THEN 'Partido sin incidentes relevantes. Desarrollo normal.'
            WHEN 2 THEN 'Conducta antideportiva del cuerpo tecnico visitante durante el segundo tiempo.'
            WHEN 3 THEN 'Retraso en el inicio del segundo tiempo por demoras del equipo local.'
            ELSE 'Protestas reiteradas de un jugador ante decisiones arbitrales.' END;
        SET @v_sanc = CASE WHEN @v_k IN (2, 4) THEN 'Multa a la federacion' ELSE NULL END;

        EXEC arbitraje.usp_Negocio_RegistrarInforme
             @id_partido = @v_part, @id_arbitro = @v_arb, @tipo = @v_tipo,
             @descripcion = @v_desc, @sancion_aplicada = @v_sanc,
             @fecha_informe = @v_fi, @id_informe = @v_inf OUTPUT;

        SET @v_k += 1;
    END

    PRINT CONCAT('Informes post-partido cargados: ', @v_total);
END
ELSE
BEGIN
    PRINT 'Ya hay informes post-partido vinculados; no se cargan de nuevo';
END
GO
