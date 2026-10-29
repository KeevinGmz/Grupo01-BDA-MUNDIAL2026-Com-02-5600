/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Entrega 6. Importación de datos económicos:
          1. soporte.usp_Importacion_ProcesarTipoCambio  upsert común de cotizaciones
          2. soporte.usp_Importar_TipoCambioXml   archivo XML del Banco Central Europeo
          3. soporte.usp_Importar_TipoCambioApi   API Frankfurter (JSON)
          4. soporte.usp_Importar_IndicadorApi    API del Banco Mundial (JSON), PBI per cápita
          Las cotizaciones de origen están expresadas contra el euro (BCE) o
          contra el dólar (Frankfurter); la conversión a "dólares por unidad de
          moneda" (publicidad.tipo_cambio.cotizacion_usd) se hace en T-SQL.
===================================================================== */
USE Mundial2026;
GO

-- ============================================================================
-- 1. PROCESO COMUN DE COTIZACIONES
--    Toma las filas de soporte.stg_tipo_cambio (moneda, fecha, valor = unidades
--    de la moneda por 1 unidad de la moneda base) y aplica el upsert sobre
--    publicidad.tipo_cambio.
--
--    Transformación:  cotizacion_usd(X) = USD por base / unidades de X por base
--      - base USD: USD por base = 1                 -> cotizacion_usd = 1 / valor
--      - base EUR: USD por base = valor del USD ese día -> cotizacion_usd = valor_USD / valor_X
--      - la propia moneda base (EUR) se agrega con cotizacion_usd = valor_USD
--    El dólar no se importa (su cotización es 1 por definición).
--    Clave natural: moneda + fecha. Cada fecha es un registro histórico propio;
--    una fecha ya cargada solo se modifica si la fuente corrigió el valor.
--    Las monedas que no están registradas en publicidad.moneda se omiten.
-- ============================================================================
CREATE OR ALTER PROCEDURE soporte.usp_Importacion_ProcesarTipoCambio
    @id_importacion INT,
    @moneda_base CHAR(3),
    @insertadas INT OUTPUT,
    @actualizadas INT OUTPUT,
    @sin_cambios INT OUTPUT,
    @omitidas INT OUTPUT,
    @con_error INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_mensaje NVARCHAR(2048);

    SET @insertadas = 0;
    SET @actualizadas = 0;
    SET @sin_cambios = 0;
    SET @omitidas = 0;
    SET @con_error = 0;

    IF @moneda_base IS NULL OR @moneda_base NOT IN ('USD', 'EUR')
        THROW 50001, N'soporte.usp_Importacion_ProcesarTipoCambio: moneda_base debe ser USD o EUR', 1;

    CREATE TABLE #tc
    (
        nro_fila       INT            NOT NULL PRIMARY KEY,
        fecha_texto    NVARCHAR(20) COLLATE DATABASE_DEFAULT   NULL,
        fecha          DATE           NULL,
        moneda         NVARCHAR(10) COLLATE DATABASE_DEFAULT   NULL,
        valor_texto    NVARCHAR(40) COLLATE DATABASE_DEFAULT   NULL,
        valor          DECIMAL(18,6)  NULL,
        usd_por_base   DECIMAL(18,6)  NULL,
        cotizacion_usd DECIMAL(18,6)  NULL,
        id_moneda      TINYINT        NULL,
        omitida        BIT            NOT NULL DEFAULT 0,
        error          NVARCHAR(1000) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #tc (nro_fila, fecha_texto, fecha, moneda, valor_texto, valor)
    SELECT s.nro_fila,
           soporte.fn_Limpiar(s.fecha),
           TRY_CONVERT(DATE, soporte.fn_Limpiar(s.fecha), 23),
           UPPER(soporte.fn_Limpiar(s.moneda)),
           soporte.fn_Limpiar(s.valor),
           TRY_CONVERT(DECIMAL(18,6), soporte.fn_Limpiar(s.valor))
    FROM soporte.stg_tipo_cambio AS s;

    -- Dólares por unidad de la moneda base, por fecha.
    IF @moneda_base = 'USD'
        UPDATE #tc SET usd_por_base = 1;
    ELSE
        UPDATE t
        SET usd_por_base = u.valor
        FROM #tc AS t
        JOIN #tc AS u ON u.fecha = t.fecha AND u.moneda = N'USD' AND u.valor > 0;

    -- La moneda base también recibe su cotización (una fila por fecha).
    IF @moneda_base = 'EUR'
        INSERT INTO #tc (nro_fila, fecha_texto, fecha, moneda, valor_texto, valor, usd_por_base)
        SELECT 1000000 + ROW_NUMBER() OVER (ORDER BY f.fecha), CONVERT(NVARCHAR(20), f.fecha, 23), f.fecha, N'EUR', N'1', 1, f.usd_por_base
        FROM (SELECT DISTINCT t.fecha, t.usd_por_base FROM #tc AS t WHERE t.fecha IS NOT NULL AND t.usd_por_base IS NOT NULL) AS f
        WHERE NOT EXISTS (SELECT 1 FROM #tc AS e WHERE e.fecha = f.fecha AND e.moneda = N'EUR');

    UPDATE t
    SET cotizacion_usd = CASE WHEN t.valor > 0 AND t.usd_por_base IS NOT NULL
                              THEN CONVERT(DECIMAL(18,6), ROUND(CONVERT(DECIMAL(38,12), t.usd_por_base) / t.valor, 6)) END,
        id_moneda = m.id_moneda
    FROM #tc AS t
    LEFT JOIN publicidad.moneda AS m ON m.cod_iso4217 = t.moneda;

    -- El dólar y las monedas no registradas se omiten.
    UPDATE #tc SET omitida = 1 WHERE moneda = N'USD';
    UPDATE #tc SET omitida = 1 WHERE id_moneda IS NULL AND moneda LIKE N'[A-Z][A-Z][A-Z]';

    UPDATE t
    SET error = NULLIF(CONCAT(
            CASE WHEN t.fecha IS NULL THEN CONCAT(N'fecha invalida (', ISNULL(t.fecha_texto, N'vacia'), N'); ') END,
            CASE WHEN t.moneda IS NULL OR t.moneda NOT LIKE N'[A-Z][A-Z][A-Z]'
                 THEN CONCAT(N'codigo de moneda invalido (', ISNULL(t.moneda, N'vacio'), N'); ') END,
            CASE WHEN t.valor IS NULL THEN CONCAT(N'cotizacion no numerica (', ISNULL(t.valor_texto, N'vacia'), N'); ')
                 WHEN t.valor <= 0 THEN N'la cotizacion debe ser mayor a 0; ' END,
            CASE WHEN t.fecha IS NOT NULL AND t.usd_por_base IS NULL
                 THEN N'no hay cotizacion del USD para esa fecha, no se puede convertir; ' END,
            CASE WHEN t.valor > 0 AND t.usd_por_base IS NOT NULL AND (t.cotizacion_usd IS NULL OR t.cotizacion_usd = 0)
                 THEN N'la conversion a USD da un valor fuera de la precision admitida; ' END,
            CASE WHEN EXISTS (SELECT 1 FROM #tc AS d WHERE d.fecha = t.fecha AND d.moneda = t.moneda AND d.nro_fila < t.nro_fila)
                 THEN N'moneda y fecha repetidas en el origen; ' END
        ), N'')
    FROM #tc AS t
    WHERE t.omitida = 0;

    SELECT @omitidas = COUNT(*) FROM #tc WHERE omitida = 1 AND nro_fila < 1000000;

    DECLARE @v_fila INT = 0;
    DECLARE @v_texto NVARCHAR(1000);
    DECLARE @v_clave NVARCHAR(40);

    WHILE 1 = 1
    BEGIN
        SELECT TOP (1) @v_fila = t.nro_fila, @v_texto = t.error,
               @v_clave = CONCAT(t.moneda, N' ', t.fecha_texto)
        FROM #tc AS t
        WHERE t.error IS NOT NULL AND t.nro_fila > @v_fila
        ORDER BY t.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, N'moneda fecha', @v_clave, @v_texto;
        SET @con_error += 1;
    END

    DECLARE @v_id_moneda TINYINT, @v_fecha DATE, @v_cotizacion DECIMAL(18,6), @v_actual DECIMAL(18,6);

    SET @v_fila = 0;
    WHILE 1 = 1
    BEGIN
        SELECT TOP (1)
            @v_fila = t.nro_fila,
            @v_id_moneda = t.id_moneda,
            @v_fecha = t.fecha,
            @v_cotizacion = t.cotizacion_usd,
            @v_clave = CONCAT(t.moneda, N' ', t.fecha_texto)
        FROM #tc AS t
        WHERE t.error IS NULL AND t.omitida = 0 AND t.nro_fila > @v_fila
        ORDER BY t.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        SET @v_actual = NULL;
        SELECT @v_actual = x.cotizacion_usd
        FROM publicidad.tipo_cambio AS x
        WHERE x.id_moneda = @v_id_moneda AND x.fecha = @v_fecha;

        BEGIN TRY
            IF @v_actual IS NULL
            BEGIN
                EXEC publicidad.usp_TipoCambio_Insertar
                    @id_moneda = @v_id_moneda,
                    @fecha = @v_fecha,
                    @cotizacion_usd = @v_cotizacion;
                SET @insertadas += 1;
            END
            ELSE IF @v_actual <> @v_cotizacion
            BEGIN
                EXEC publicidad.usp_TipoCambio_Modificar
                    @id_moneda = @v_id_moneda,
                    @fecha = @v_fecha,
                    @cotizacion_usd = @v_cotizacion;
                SET @actualizadas += 1;
            END
            ELSE
                SET @sin_cambios += 1;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SET @v_mensaje = ERROR_MESSAGE();
            EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, N'moneda fecha', @v_clave, @v_mensaje;
            SET @con_error += 1;
        END CATCH
    END
END;
GO

-- ============================================================================
-- 2. TIPOS DE CAMBIO DEL BANCO CENTRAL EUROPEO (XML)
--    https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml  (últimos 90 días)
--    https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.xml      (histórico completo)
--    Estructura: <Cube time="AAAA-MM-DD"><Cube currency="USD" rate="1.1234"/>...
--    Las cotizaciones vienen en unidades de cada moneda por 1 EUR.
--    @fecha_desde / @fecha_hasta permiten limitar el período del histórico.
-- ============================================================================
CREATE OR ALTER PROCEDURE soporte.usp_Importar_TipoCambioXml
    @archivo NVARCHAR(260),
    @fecha_desde DATE = NULL,
    @fecha_hasta DATE = NULL,
    @id_importacion INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @c_sp NVARCHAR(60) = N'soporte.usp_Importar_TipoCambioXml';
    DECLARE @c_fuente NVARCHAR(60) = N'Banco Central Europeo (eurofxref)';
    DECLARE @v_errores NVARCHAR(2000) = soporte.fn_ValidarRutaArchivo(@archivo, N'.xml');
    DECLARE @v_mensaje NVARCHAR(2048);
    DECLARE @v_binario VARBINARY(MAX);
    DECLARE @v_xml XML;
    DECLARE @v_leidas INT = 0;
    DECLARE @v_insertadas INT, @v_actualizadas INT, @v_sin_cambios INT, @v_omitidas INT, @v_con_error INT;
    DECLARE @v_fuera_periodo INT = 0;

    IF @fecha_desde IS NOT NULL AND @fecha_hasta IS NOT NULL AND @fecha_desde > @fecha_hasta
        SET @v_errores += N'fecha_desde no puede ser posterior a fecha_hasta; ';
    IF @@TRANCOUNT > 0
        SET @v_errores += N'no puede ejecutarse dentro de una transaccion; ';

    IF @v_errores <> N''
    BEGIN
        SET @v_mensaje = CONCAT(@c_sp, N': ', @v_errores);
        THROW 50001, @v_mensaje, 1;
    END

    EXEC soporte.usp_Importacion_Iniciar
        @fuente = @c_fuente, @archivo = @archivo, @formato = 'XML',
        @id_importacion = @id_importacion OUTPUT;

    BEGIN TRY
        EXEC soporte.usp_Archivo_Leer @archivo = @archivo, @binario = @v_binario OUTPUT;

        BEGIN TRY
            SET @v_xml = CONVERT(XML, @v_binario);
        END TRY
        BEGIN CATCH
            SET @v_mensaje = CONCAT(N'el archivo no contiene un XML valido: ', ERROR_MESSAGE());
            THROW 50002, @v_mensaje, 1;
        END CATCH

        DELETE FROM soporte.stg_tipo_cambio;

        WITH XMLNAMESPACES
        (
            'http://www.gesmes.org/xml/2002-08-01' AS gesmes,
            DEFAULT 'http://www.ecb.int/vocabulary/2002-08-01/eurofxref'
        )
        INSERT INTO soporte.stg_tipo_cambio (nro_fila, fecha, moneda, valor, moneda_base)
        SELECT
            ROW_NUMBER() OVER (ORDER BY d.dia.value('@time', 'NVARCHAR(20)') DESC, c.cot.value('@currency', 'NVARCHAR(10)')),
            d.dia.value('@time', 'NVARCHAR(20)'),
            c.cot.value('@currency', 'NVARCHAR(10)'),
            c.cot.value('@rate', 'NVARCHAR(40)'),
            N'EUR'
        FROM @v_xml.nodes('/gesmes:Envelope/Cube/Cube') AS d(dia)
        CROSS APPLY d.dia.nodes('Cube') AS c(cot);

        SET @v_leidas = @@ROWCOUNT;

        IF @v_leidas = 0
            THROW 50002, N'el XML no tiene cotizaciones con la estructura del BCE (gesmes:Envelope/Cube/Cube)', 1;

        -- Filtro opcional de período: lo que queda afuera se cuenta como omitido.
        IF @fecha_desde IS NOT NULL OR @fecha_hasta IS NOT NULL
        BEGIN
            DELETE FROM soporte.stg_tipo_cambio
            WHERE TRY_CONVERT(DATE, fecha, 23) < ISNULL(@fecha_desde, '19000101')
               OR TRY_CONVERT(DATE, fecha, 23) > ISNULL(@fecha_hasta, '99991231');
            SET @v_fuera_periodo = @@ROWCOUNT;
        END
    END TRY
    BEGIN CATCH
        SET @v_mensaje = ERROR_MESSAGE();
        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, 1, N'(archivo)', @archivo, @v_mensaje;
        EXEC soporte.usp_Importacion_Finalizar @id_importacion, 0, 0, 0, @error_general = 1, @mostrar_resumen = 0;
        THROW;
    END CATCH

    EXEC soporte.usp_Importacion_ProcesarTipoCambio
        @id_importacion = @id_importacion,
        @moneda_base = 'EUR',
        @insertadas = @v_insertadas OUTPUT,
        @actualizadas = @v_actualizadas OUTPUT,
        @sin_cambios = @v_sin_cambios OUTPUT,
        @omitidas = @v_omitidas OUTPUT,
        @con_error = @v_con_error OUTPUT;

    -- Las filas del EUR se generan en la transformación: se suman a las leídas.
    SET @v_leidas = @v_leidas + (SELECT COUNT(DISTINCT fecha) FROM soporte.stg_tipo_cambio);

    DECLARE @v_filas_ok INT = @v_insertadas + @v_actualizadas + @v_sin_cambios;
    EXEC soporte.usp_Importacion_Finalizar @id_importacion, @v_leidas,
         @filas_ok = @v_filas_ok,
         @filas_error = @v_con_error;

    SELECT @id_importacion AS id_importacion,
           @v_leidas AS filas_leidas,
           @v_insertadas AS insertadas,
           @v_actualizadas AS actualizadas,
           @v_sin_cambios AS sin_cambios,
           @v_omitidas + @v_fuera_periodo AS omitidas,
           @v_con_error AS con_error;
END;
GO

-- ============================================================================
-- 3. TIPOS DE CAMBIO DESDE LA API FRANKFURTER (JSON)
--    https://api.frankfurter.dev/v1/AAAA-MM-DD..AAAA-MM-DD?base=USD&symbols=EUR,MXN
--    Sin clave de acceso. Publica las cotizaciones de referencia del BCE de
--    los días hábiles. Respuesta: {"base":"USD","rates":{"AAAA-MM-DD":{"EUR":0.88,...}}}
--    Los valores son unidades de cada moneda por 1 USD.
-- ============================================================================
CREATE OR ALTER PROCEDURE soporte.usp_Importar_TipoCambioApi
    @fecha_desde DATE,
    @fecha_hasta DATE = NULL,
    @monedas NVARCHAR(200) = NULL,     -- opcional: 'EUR,MXN,CAD' (vacío = todas)
    @id_importacion INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @c_sp NVARCHAR(60) = N'soporte.usp_Importar_TipoCambioApi';
    DECLARE @c_fuente NVARCHAR(60) = N'API Frankfurter';
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_mensaje NVARCHAR(2048);
    DECLARE @v_url NVARCHAR(260);
    DECLARE @v_json NVARCHAR(MAX);
    DECLARE @v_estado INT;
    DECLARE @v_leidas INT = 0;
    DECLARE @v_insertadas INT, @v_actualizadas INT, @v_sin_cambios INT, @v_omitidas INT, @v_con_error INT;

    SET @fecha_hasta = ISNULL(@fecha_hasta, @fecha_desde);

    IF @fecha_desde IS NULL
        SET @v_errores += N'fecha_desde obligatoria; ';
    ELSE IF @fecha_desde > @fecha_hasta
        SET @v_errores += N'fecha_desde no puede ser posterior a fecha_hasta; ';
    ELSE IF @fecha_hasta > CONVERT(DATE, SYSDATETIME())
        SET @v_errores += N'no se pueden pedir cotizaciones futuras; ';
    ELSE IF DATEDIFF(DAY, @fecha_desde, @fecha_hasta) > 366
        SET @v_errores += N'el periodo no puede superar un anio por solicitud; ';
    IF @monedas IS NOT NULL AND @monedas LIKE N'%[^A-Za-z,]%'
        SET @v_errores += N'monedas debe ser una lista de codigos separados por coma; ';
    IF @@TRANCOUNT > 0
        SET @v_errores += N'no puede ejecutarse dentro de una transaccion; ';

    IF @v_errores <> N''
    BEGIN
        SET @v_mensaje = CONCAT(@c_sp, N': ', @v_errores);
        THROW 50001, @v_mensaje, 1;
    END

    SET @v_url = CONCAT(N'https://api.frankfurter.dev/v1/',
                        CONVERT(NVARCHAR(10), @fecha_desde, 23), N'..', CONVERT(NVARCHAR(10), @fecha_hasta, 23),
                        N'?base=USD',
                        CASE WHEN NULLIF(@monedas, N'') IS NOT NULL THEN N'&symbols=' + UPPER(@monedas) END);

    EXEC soporte.usp_Importacion_Iniciar
        @fuente = @c_fuente, @archivo = @v_url, @formato = 'JSON',
        @id_importacion = @id_importacion OUTPUT;

    BEGIN TRY
        EXEC soporte.usp_Http_Obtener @url = @v_url, @contenido = @v_json OUTPUT, @estado_http = @v_estado OUTPUT;

        IF ISJSON(@v_json) <> 1
            THROW 50002, N'la API no devolvio un JSON valido', 1;
        IF JSON_VALUE(@v_json, '$.base') <> N'USD'
            THROW 50002, N'la API devolvio cotizaciones con una base distinta de USD', 1;

        DELETE FROM soporte.stg_tipo_cambio;

        IF JSON_VALUE(@v_json, '$.date') IS NOT NULL
            -- Respuesta de un solo día: {"date":"...","rates":{"EUR":0.88}}
            INSERT INTO soporte.stg_tipo_cambio (nro_fila, fecha, moneda, valor, moneda_base)
            SELECT ROW_NUMBER() OVER (ORDER BY r.[key]), JSON_VALUE(@v_json, '$.date'), r.[key], r.value, N'USD'
            FROM OPENJSON(@v_json, '$.rates') AS r;
        ELSE
            -- Respuesta de un período: {"rates":{"AAAA-MM-DD":{"EUR":0.88}}}
            INSERT INTO soporte.stg_tipo_cambio (nro_fila, fecha, moneda, valor, moneda_base)
            SELECT ROW_NUMBER() OVER (ORDER BY d.[key], r.[key]), d.[key], r.[key], r.value, N'USD'
            FROM OPENJSON(@v_json, '$.rates') AS d
            CROSS APPLY OPENJSON(d.value) AS r;

        SET @v_leidas = @@ROWCOUNT;
    END TRY
    BEGIN CATCH
        SET @v_mensaje = ERROR_MESSAGE();
        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, 1, N'(api)', @v_url, @v_mensaje;
        EXEC soporte.usp_Importacion_Finalizar @id_importacion, 0, 0, 0, @error_general = 1, @mostrar_resumen = 0;
        THROW;
    END CATCH

    EXEC soporte.usp_Importacion_ProcesarTipoCambio
        @id_importacion = @id_importacion,
        @moneda_base = 'USD',
        @insertadas = @v_insertadas OUTPUT,
        @actualizadas = @v_actualizadas OUTPUT,
        @sin_cambios = @v_sin_cambios OUTPUT,
        @omitidas = @v_omitidas OUTPUT,
        @con_error = @v_con_error OUTPUT;

    DECLARE @v_filas_ok INT = @v_insertadas + @v_actualizadas + @v_sin_cambios;
    EXEC soporte.usp_Importacion_Finalizar @id_importacion, @v_leidas,
         @filas_ok = @v_filas_ok,
         @filas_error = @v_con_error;

    SELECT @id_importacion AS id_importacion,
           @v_leidas AS filas_leidas,
           @v_insertadas AS insertadas,
           @v_actualizadas AS actualizadas,
           @v_sin_cambios AS sin_cambios,
           @v_omitidas AS omitidas,
           @v_con_error AS con_error;
END;
GO

-- ============================================================================
-- 4. INDICADORES ECONOMICOS DESDE LA API DEL BANCO MUNDIAL (JSON)
--    https://api.worldbank.org/v2/country/all/indicator/NY.GDP.PCAP.CD?format=json&date=2022:2024&per_page=20000
--    Sin clave de acceso. Respuesta: [ {paginación}, [ {countryiso3code, date, value, ...} ] ]
--    Clave natural: país + año + código de indicador (un registro por año,
--    se conserva el histórico). Se omiten los agregados regionales (códigos
--    que no son países del modelo) y los años sin dato.
-- ============================================================================
CREATE OR ALTER PROCEDURE soporte.usp_Importar_IndicadorApi
    @anio_desde SMALLINT,
    @anio_hasta SMALLINT = NULL,
    @indicador VARCHAR(30) = 'NY.GDP.PCAP.CD',
    @id_importacion INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @c_sp NVARCHAR(60) = N'soporte.usp_Importar_IndicadorApi';
    DECLARE @c_fuente NVARCHAR(60) = N'API Banco Mundial';
    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_mensaje NVARCHAR(2048);
    DECLARE @v_url NVARCHAR(260);
    DECLARE @v_json NVARCHAR(MAX);
    DECLARE @v_estado INT;
    DECLARE @v_leidas INT = 0;
    DECLARE @v_insertadas INT = 0;
    DECLARE @v_actualizadas INT = 0;
    DECLARE @v_sin_cambios INT = 0;
    DECLARE @v_con_error INT = 0;

    SET @anio_hasta = ISNULL(@anio_hasta, @anio_desde);

    IF @anio_desde IS NULL OR @anio_desde NOT BETWEEN 1960 AND 2100
        SET @v_errores += N'anio_desde obligatorio y entre 1960 y 2100; ';
    IF @anio_hasta NOT BETWEEN 1960 AND 2100 OR @anio_hasta < @anio_desde
        SET @v_errores += N'anio_hasta debe estar entre anio_desde y 2100; ';
    IF NULLIF(LTRIM(RTRIM(@indicador)), '') IS NULL OR @indicador LIKE '%[^A-Za-z0-9.]%'
        SET @v_errores += N'codigo de indicador invalido; ';
    IF @@TRANCOUNT > 0
        SET @v_errores += N'no puede ejecutarse dentro de una transaccion; ';

    IF @v_errores <> N''
    BEGIN
        SET @v_mensaje = CONCAT(@c_sp, N': ', @v_errores);
        THROW 50001, @v_mensaje, 1;
    END

    SET @v_url = CONCAT(N'https://api.worldbank.org/v2/country/all/indicator/', @indicador,
                        N'?format=json&per_page=20000&date=', @anio_desde, N':', @anio_hasta);

    EXEC soporte.usp_Importacion_Iniciar
        @fuente = @c_fuente, @archivo = @v_url, @formato = 'JSON',
        @id_importacion = @id_importacion OUTPUT;

    BEGIN TRY
        EXEC soporte.usp_Http_Obtener @url = @v_url, @contenido = @v_json OUTPUT, @estado_http = @v_estado OUTPUT;

        IF ISJSON(@v_json) <> 1
            THROW 50002, N'la API no devolvio un JSON valido', 1;

        IF JSON_QUERY(@v_json, '$[1]') IS NULL
        BEGIN
            SET @v_mensaje = CONCAT(N'la API no devolvio datos: ',
                                    ISNULL(JSON_VALUE(@v_json, '$[0].message[0].value'), N'respuesta sin el arreglo de datos'));
            THROW 50002, @v_mensaje, 1;
        END

        DELETE FROM soporte.stg_indicador;
        INSERT INTO soporte.stg_indicador (nro_fila, cod_iso3, pais_texto, indicador, anio, valor)
        SELECT CONVERT(INT, a.[key]) + 1, d.iso3, d.pais, d.indicador, d.anio, d.valor
        FROM OPENJSON(@v_json, '$[1]') AS a
        CROSS APPLY OPENJSON(a.value)
        WITH
        (
            iso3      NVARCHAR(10)  '$.countryiso3code',
            pais      NVARCHAR(150) '$.country.value',
            indicador NVARCHAR(40)  '$.indicator.id',
            anio      NVARCHAR(10)  '$.date',
            valor     NVARCHAR(60)  '$.value'
        ) AS d;

        SET @v_leidas = @@ROWCOUNT;
    END TRY
    BEGIN CATCH
        SET @v_mensaje = ERROR_MESSAGE();
        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, 1, N'(api)', @v_url, @v_mensaje;
        EXEC soporte.usp_Importacion_Finalizar @id_importacion, 0, 0, 0, @error_general = 1, @mostrar_resumen = 0;
        THROW;
    END CATCH

    CREATE TABLE #ind
    (
        nro_fila  INT            NOT NULL PRIMARY KEY,
        cod_iso3  NVARCHAR(10) COLLATE DATABASE_DEFAULT   NULL,
        pais      NVARCHAR(150) COLLATE DATABASE_DEFAULT  NULL,
        indicador NVARCHAR(40) COLLATE DATABASE_DEFAULT   NULL,
        anio_txt  NVARCHAR(10) COLLATE DATABASE_DEFAULT   NULL,
        anio      SMALLINT       NULL,
        valor_txt NVARCHAR(60) COLLATE DATABASE_DEFAULT   NULL,
        valor     DECIMAL(18,2)  NULL,
        id_pais   SMALLINT       NULL,
        omitida   BIT            NOT NULL DEFAULT 0,
        error     NVARCHAR(1000) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO #ind (nro_fila, cod_iso3, pais, indicador, anio_txt, anio, valor_txt, valor, id_pais)
    SELECT s.nro_fila,
           UPPER(soporte.fn_Limpiar(s.cod_iso3)),
           soporte.fn_Limpiar(s.pais_texto),
           soporte.fn_Limpiar(s.indicador),
           soporte.fn_Limpiar(s.anio),
           TRY_CONVERT(SMALLINT, soporte.fn_Limpiar(s.anio)),
           soporte.fn_Limpiar(s.valor),
           TRY_CONVERT(DECIMAL(18,2), TRY_CONVERT(FLOAT, soporte.fn_Limpiar(s.valor))),
           p.id_pais
    FROM soporte.stg_indicador AS s
    LEFT JOIN geo.pais AS p ON p.cod_iso3 = UPPER(soporte.fn_Limpiar(s.cod_iso3));

    -- Sin dato publicado para ese año, o agregado regional: se omite.
    UPDATE #ind SET omitida = 1 WHERE valor_txt IS NULL OR id_pais IS NULL;

    UPDATE i
    SET error = NULLIF(CONCAT(
            CASE WHEN i.anio IS NULL OR i.anio NOT BETWEEN 1960 AND 2100
                 THEN CONCAT(N'anio invalido (', ISNULL(i.anio_txt, N'vacio'), N'); ') END,
            CASE WHEN i.valor IS NULL THEN CONCAT(N'valor no numerico (', i.valor_txt, N'); ') END,
            CASE WHEN ISNULL(i.indicador, '') <> @indicador THEN N'la fila corresponde a otro indicador; ' END
        ), N'')
    FROM #ind AS i
    WHERE i.omitida = 0;

    DECLARE @v_fila INT = 0;
    DECLARE @v_texto NVARCHAR(1000);
    DECLARE @v_clave NVARCHAR(40);

    WHILE 1 = 1
    BEGIN
        SELECT TOP (1) @v_fila = i.nro_fila, @v_texto = i.error, @v_clave = CONCAT(i.cod_iso3, N' ', i.anio_txt)
        FROM #ind AS i
        WHERE i.error IS NOT NULL AND i.nro_fila > @v_fila
        ORDER BY i.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, N'pais anio', @v_clave, @v_texto;
        SET @v_con_error += 1;
    END

    DECLARE @v_id_pais SMALLINT, @v_anio SMALLINT, @v_valor DECIMAL(18,2), @v_actual DECIMAL(18,2), @v_existe BIT;

    SET @v_fila = 0;
    WHILE 1 = 1
    BEGIN
        SELECT TOP (1) @v_fila = i.nro_fila, @v_id_pais = i.id_pais, @v_anio = i.anio, @v_valor = i.valor,
               @v_clave = CONCAT(i.cod_iso3, N' ', i.anio_txt)
        FROM #ind AS i
        WHERE i.error IS NULL AND i.omitida = 0 AND i.nro_fila > @v_fila
        ORDER BY i.nro_fila;
        IF @@ROWCOUNT = 0 BREAK;

        SET @v_existe = 0;
        SELECT @v_existe = 1, @v_actual = x.valor
        FROM geo.indicador_pais AS x
        WHERE x.id_pais = @v_id_pais AND x.anio = @v_anio AND x.codigo_indicador = @indicador;

        BEGIN TRY
            IF @v_existe = 0
            BEGIN
                EXEC geo.usp_IndicadorPais_Insertar
                    @id_pais = @v_id_pais, @anio = @v_anio, @codigo_indicador = @indicador, @valor = @v_valor;
                SET @v_insertadas += 1;
            END
            ELSE IF @v_actual <> @v_valor
            BEGIN
                EXEC geo.usp_IndicadorPais_Modificar
                    @id_pais = @v_id_pais, @anio = @v_anio, @codigo_indicador = @indicador, @valor = @v_valor;
                SET @v_actualizadas += 1;
            END
            ELSE
                SET @v_sin_cambios += 1;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            SET @v_mensaje = ERROR_MESSAGE();
            EXEC soporte.usp_Importacion_RegistrarError @id_importacion, @v_fila, N'pais anio', @v_clave, @v_mensaje;
            SET @v_con_error += 1;
        END CATCH
    END

    DECLARE @v_filas_ok INT = @v_insertadas + @v_actualizadas + @v_sin_cambios;
    EXEC soporte.usp_Importacion_Finalizar @id_importacion, @v_leidas,
         @filas_ok = @v_filas_ok,
         @filas_error = @v_con_error;

    SELECT @id_importacion AS id_importacion,
           @v_leidas AS filas_leidas,
           @v_insertadas AS insertadas,
           @v_actualizadas AS actualizadas,
           @v_sin_cambios AS sin_cambios,
           (SELECT COUNT(*) FROM #ind WHERE omitida = 1) AS omitidas,
           @v_con_error AS con_error;
END;
GO
