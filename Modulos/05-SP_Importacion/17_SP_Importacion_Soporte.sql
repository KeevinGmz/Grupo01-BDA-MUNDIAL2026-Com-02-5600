/* =====================================================================
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comisión: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-10-18
Objetivo: Entrega 6. Funciones y SP auxiliares que comparten todos los procesos
          de importación: limpieza de texto y HTML, lectura de archivos, carga
          de archivos delimitados con BULK INSERT, consumo HTTP (APIs y
          scraping), resolución de países por códigos o nombres externos y
          registro de la auditoría (soporte.importacion / importacion_error).
===================================================================== */
USE Mundial2026;
GO

/*
   Requisito de instancia para APIs y scraping
   -------------------------------------------
   Las llamadas HTTP se hacen desde T-SQL con el objeto COM
   MSXML2.ServerXMLHTTP.6.0 (procedimientos sp_OA*). Para eso la instancia
   debe tener habilitada la opción "Ole Automation Procedures". Se configura
   una sola vez y requiere permisos de sysadmin. Si el usuario no es sysadmin
   se informa y el resto del script continúa: solo fallarán las importaciones
   que usan HTTP.
*/
IF IS_SRVROLEMEMBER('sysadmin') = 1
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.configurations WHERE name = 'Ole Automation Procedures' AND value_in_use = 1)
    BEGIN
        EXEC sp_configure 'show advanced options', 1;
        RECONFIGURE;
        EXEC sp_configure 'Ole Automation Procedures', 1;
        RECONFIGURE;
    END
END
ELSE
    PRINT N'Aviso: no se pudo habilitar Ole Automation Procedures (se requiere sysadmin). Las importaciones por HTTP no van a funcionar.';
GO

-- ============================================================================
-- 1. FUNCIONES DE LIMPIEZA Y CONVERSION
-- ============================================================================

-- Quita espacios, tabulaciones, saltos de línea, espacios duros y la marca BOM.
-- Devuelve NULL si el resultado queda vacío.
CREATE OR ALTER FUNCTION soporte.fn_Limpiar
(
    @texto NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @v_texto NVARCHAR(MAX) = @texto;

    SET @v_texto = REPLACE(@v_texto, NCHAR(65279), N'');   -- BOM
    SET @v_texto = REPLACE(@v_texto, NCHAR(160), N' ');    -- espacio duro
    SET @v_texto = REPLACE(@v_texto, NCHAR(9), N' ');
    SET @v_texto = REPLACE(@v_texto, NCHAR(13), N' ');
    SET @v_texto = REPLACE(@v_texto, NCHAR(10), N' ');

    WHILE CHARINDEX(N'  ', @v_texto) > 0
        SET @v_texto = REPLACE(@v_texto, N'  ', N' ');

    RETURN NULLIF(LTRIM(RTRIM(@v_texto)), N'');
END;
GO

-- Convierte un fragmento HTML en texto plano: elimina los bloques ocultos
-- (display:none, usados por Wikipedia para las claves de orden), las
-- etiquetas y las referencias [n], y decodifica las entidades más comunes.
CREATE OR ALTER FUNCTION soporte.fn_HtmlATexto
(
    @html NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @v_texto NVARCHAR(MAX) = @html;
    DECLARE @v_ini INT;
    DECLARE @v_fin INT;
    DECLARE @v_oculto NVARCHAR(40) = N'<span style="display:none">';

    IF @v_texto IS NULL
        RETURN NULL;

    -- 1) Bloques ocultos: se elimina desde la apertura hasta el primer cierre.
    SET @v_ini = CHARINDEX(@v_oculto, @v_texto);
    WHILE @v_ini > 0
    BEGIN
        SET @v_fin = CHARINDEX(N'</span>', @v_texto, @v_ini);
        IF @v_fin = 0
            BREAK;
        SET @v_texto = STUFF(@v_texto, @v_ini, @v_fin + 7 - @v_ini, N'');
        SET @v_ini = CHARINDEX(@v_oculto, @v_texto);
    END

    -- 2) Referencias al pie: <sup ...>...</sup>
    SET @v_ini = CHARINDEX(N'<sup', @v_texto);
    WHILE @v_ini > 0
    BEGIN
        SET @v_fin = CHARINDEX(N'</sup>', @v_texto, @v_ini);
        IF @v_fin = 0
            BREAK;
        SET @v_texto = STUFF(@v_texto, @v_ini, @v_fin + 6 - @v_ini, N'');
        SET @v_ini = CHARINDEX(N'<sup', @v_texto);
    END

    -- 3) Resto de las etiquetas
    SET @v_ini = CHARINDEX(N'<', @v_texto);
    WHILE @v_ini > 0
    BEGIN
        SET @v_fin = CHARINDEX(N'>', @v_texto, @v_ini);
        IF @v_fin = 0
            BREAK;
        SET @v_texto = STUFF(@v_texto, @v_ini, @v_fin - @v_ini + 1, N' ');
        SET @v_ini = CHARINDEX(N'<', @v_texto, @v_ini);
    END

    -- 4) Entidades HTML frecuentes (&amp; al final para no generar otras)
    SET @v_texto = REPLACE(@v_texto, N'&nbsp;', N' ');
    SET @v_texto = REPLACE(@v_texto, N'&#160;', N' ');
    SET @v_texto = REPLACE(@v_texto, N'&quot;', N'"');
    SET @v_texto = REPLACE(@v_texto, N'&#39;', N'''');
    SET @v_texto = REPLACE(@v_texto, N'&#039;', N'''');
    SET @v_texto = REPLACE(@v_texto, N'&lt;', N'<');
    SET @v_texto = REPLACE(@v_texto, N'&gt;', N'>');
    SET @v_texto = REPLACE(@v_texto, N'&ndash;', NCHAR(8211));
    SET @v_texto = REPLACE(@v_texto, N'&amp;', N'&');

    RETURN soporte.fn_Limpiar(@v_texto);
END;
GO

-- Convierte una coordenada geográfica en grados decimales con signo.
-- Admite grados/minutos/segundos (49°16'36"N) y grados decimales (37.403°N).
-- Devuelve NULL si el texto no tiene un formato reconocible.
CREATE OR ALTER FUNCTION soporte.fn_CoordenadaADecimal
(
    @texto NVARCHAR(60)
)
RETURNS DECIMAL(9,6)
AS
BEGIN
    DECLARE @v_texto NVARCHAR(60) = LTRIM(RTRIM(@texto));
    DECLARE @v_hemisferio NCHAR(1);
    DECLARE @v_grados DECIMAL(12,6);
    DECLARE @v_minutos DECIMAL(12,6) = 0;
    DECLARE @v_segundos DECIMAL(12,6) = 0;
    DECLARE @v_pos_grado INT;
    DECLARE @v_pos_min INT;
    DECLARE @v_pos_seg INT;
    DECLARE @v_resultado DECIMAL(12,6);

    IF @v_texto IS NULL OR LEN(@v_texto) < 3
        RETURN NULL;

    SET @v_hemisferio = UPPER(RIGHT(@v_texto, 1));
    IF @v_hemisferio NOT IN (N'N', N'S', N'E', N'W')
        RETURN NULL;

    SET @v_texto = LEFT(@v_texto, LEN(@v_texto) - 1);
    -- Variantes tipográficas: primo (′) y doble primo (″).
    SET @v_texto = REPLACE(REPLACE(@v_texto, NCHAR(8242), N''''), NCHAR(8243), N'"');

    SET @v_pos_grado = CHARINDEX(NCHAR(176), @v_texto);   -- símbolo de grado
    IF @v_pos_grado = 0
        RETURN NULL;

    SET @v_grados = TRY_CONVERT(DECIMAL(12,6), LEFT(@v_texto, @v_pos_grado - 1));

    SET @v_pos_min = CHARINDEX(N'''', @v_texto, @v_pos_grado);
    IF @v_pos_min > 0
    BEGIN
        SET @v_minutos = TRY_CONVERT(DECIMAL(12,6), SUBSTRING(@v_texto, @v_pos_grado + 1, @v_pos_min - @v_pos_grado - 1));
        SET @v_pos_seg = CHARINDEX(N'"', @v_texto, @v_pos_min);
        IF @v_pos_seg > 0
            SET @v_segundos = TRY_CONVERT(DECIMAL(12,6), SUBSTRING(@v_texto, @v_pos_min + 1, @v_pos_seg - @v_pos_min - 1));
    END

    IF @v_grados IS NULL OR @v_minutos IS NULL OR @v_segundos IS NULL
       OR @v_minutos >= 60 OR @v_segundos >= 60
        RETURN NULL;

    SET @v_resultado = @v_grados + @v_minutos / 60 + @v_segundos / 3600;

    IF @v_hemisferio IN (N'S', N'W')
        SET @v_resultado = -@v_resultado;

    IF ABS(@v_resultado) > 180
        RETURN NULL;

    RETURN CONVERT(DECIMAL(9,6), @v_resultado);
END;
GO

-- Valida la ruta de un archivo a importar. Devuelve los problemas
-- encontrados (vacío si la ruta es aceptable).
CREATE OR ALTER FUNCTION soporte.fn_ValidarRutaArchivo
(
    @archivo     NVARCHAR(260),
    @extensiones NVARCHAR(100)    -- lista separada por comas, por ejemplo '.csv,.txt'
)
RETURNS NVARCHAR(400)
AS
BEGIN
    DECLARE @v_errores NVARCHAR(400) = N'';
    DECLARE @v_archivo NVARCHAR(260) = LTRIM(RTRIM(@archivo));

    IF NULLIF(@v_archivo, N'') IS NULL
        RETURN N'archivo obligatorio; ';

    IF CHARINDEX(N'''', @v_archivo) > 0
        SET @v_errores += N'la ruta no puede contener comillas simples; ';

    IF @v_archivo NOT LIKE N'[A-Za-z]:\%' AND @v_archivo NOT LIKE N'\\%'
        SET @v_errores += N'la ruta debe ser absoluta (C:\... o \\servidor\...); ';

    IF NOT EXISTS
    (
        SELECT 1
        FROM STRING_SPLIT(@extensiones, N',') AS e
        WHERE LOWER(@v_archivo) LIKE N'%' + LOWER(LTRIM(RTRIM(e.value)))
    )
        SET @v_errores += CONCAT(N'extension no admitida (se espera ', @extensiones, N'); ');

    RETURN @v_errores;
END;
GO

-- Busca un país a partir de un identificador externo: primero en las
-- equivalencias registradas y luego en los datos propios del país
-- (nombre, código ISO de 3 letras o código FIFA).
CREATE OR ALTER FUNCTION soporte.fn_BuscarPais
(
    @tipo  VARCHAR(10),       -- 'ISO2' o 'NOMBRE'
    @valor NVARCHAR(150)
)
RETURNS SMALLINT
AS
BEGIN
    DECLARE @v_id_pais SMALLINT;
    DECLARE @v_valor NVARCHAR(150) = soporte.fn_Limpiar(@valor);

    IF @v_valor IS NULL
        RETURN NULL;

    SELECT @v_id_pais = e.id_pais
    FROM soporte.equivalencia_pais AS e
    WHERE e.tipo = @tipo
      AND e.valor = @v_valor;

    IF @v_id_pais IS NULL AND @tipo = 'NOMBRE'
        SELECT @v_id_pais = p.id_pais
        FROM geo.pais AS p
        WHERE p.nombre = @v_valor;

    RETURN @v_id_pais;
END;
GO

-- ============================================================================
-- 2. AUDITORIA DE LA IMPORTACION
-- ============================================================================

-- Abre la cabecera de una importación con estado EN_CURSO.
-- Las importaciones confirman cada registro por separado (para poder cargar
-- parcialmente los registros válidos), por eso no pueden ejecutarse dentro de
-- una transacción abierta por el llamador.
CREATE OR ALTER PROCEDURE soporte.usp_Importacion_Iniciar
    @fuente NVARCHAR(100),
    @archivo NVARCHAR(260),
    @formato VARCHAR(10),
    @id_importacion INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_ahora DATETIME2(0) = SYSDATETIME();

    IF @@TRANCOUNT > 0
        THROW 50003, N'soporte.usp_Importacion_Iniciar: la importacion debe ejecutarse fuera de una transaccion, porque confirma cada registro valido por separado', 1;

    EXEC soporte.usp_Importacion_Insertar
        @fuente = @fuente,
        @archivo = @archivo,
        @formato = @formato,
        @fecha_inicio = @v_ahora,
        @fecha_fin = NULL,
        @filas_leidas = 0,
        @filas_ok = 0,
        @filas_error = 0,
        @estado = 'EN_CURSO',
        @id_importacion = @id_importacion OUTPUT;
END;
GO

-- Registra un error de una fila. nro_fila = 1 con columna "(archivo)" se usa
-- para los errores que afectan al archivo completo.
CREATE OR ALTER PROCEDURE soporte.usp_Importacion_RegistrarError
    @id_importacion INT,
    @nro_fila INT,
    @columna NVARCHAR(60) = NULL,
    @valor NVARCHAR(MAX) = NULL,
    @mensaje NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_nro_error INT;
    DECLARE @v_valor NVARCHAR(500) = LEFT(@valor, 500);
    DECLARE @v_mensaje NVARCHAR(500) = LEFT(ISNULL(NULLIF(LTRIM(RTRIM(@mensaje)), N''), N'error sin descripcion'), 500);
    DECLARE @v_fila INT = CASE WHEN @nro_fila IS NULL OR @nro_fila < 1 THEN 1 ELSE @nro_fila END;

    SELECT @v_nro_error = ISNULL(MAX(e.nro_error), 0) + 1
    FROM soporte.importacion_error AS e
    WHERE e.id_importacion = @id_importacion;

    EXEC soporte.usp_ImportacionError_Insertar
        @id_importacion = @id_importacion,
        @nro_error = @v_nro_error,
        @nro_fila = @v_fila,
        @columna = @columna,
        @valor = @v_valor,
        @mensaje = @v_mensaje;
END;
GO

-- Cierra la cabecera: OK si no hubo filas con error, CON_ERROR en otro caso.
-- Devuelve el resumen y el detalle de errores como evidencia.
CREATE OR ALTER PROCEDURE soporte.usp_Importacion_Finalizar
    @id_importacion INT,
    @filas_leidas INT,
    @filas_ok INT,
    @filas_error INT,
    @error_general BIT = 0,
    @mostrar_resumen BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_fuente NVARCHAR(100);
    DECLARE @v_archivo NVARCHAR(260);
    DECLARE @v_formato VARCHAR(10);
    DECLARE @v_inicio DATETIME2(0);
    DECLARE @v_fin DATETIME2(0) = SYSDATETIME();
    DECLARE @v_leidas INT = ISNULL(@filas_leidas, 0);
    DECLARE @v_ok INT = ISNULL(@filas_ok, 0);
    DECLARE @v_error INT = ISNULL(@filas_error, 0);
    DECLARE @v_estado VARCHAR(10);

    SELECT
        @v_fuente = i.fuente,
        @v_archivo = i.archivo,
        @v_formato = i.formato,
        @v_inicio = i.fecha_inicio
    FROM soporte.importacion AS i
    WHERE i.id_importacion = @id_importacion;

    IF @v_fuente IS NULL
        THROW 50001, N'soporte.usp_Importacion_Finalizar: importacion inexistente', 1;

    -- Los contadores deben ser coherentes (ok + error <= leidas).
    IF @v_ok + @v_error > @v_leidas
        SET @v_leidas = @v_ok + @v_error;

    SET @v_estado = CASE WHEN @v_error > 0 OR @error_general = 1 THEN 'CON_ERROR' ELSE 'OK' END;

    EXEC soporte.usp_Importacion_Modificar
        @id_importacion = @id_importacion,
        @fuente = @v_fuente,
        @archivo = @v_archivo,
        @formato = @v_formato,
        @fecha_inicio = @v_inicio,
        @fecha_fin = @v_fin,
        @filas_leidas = @v_leidas,
        @filas_ok = @v_ok,
        @filas_error = @v_error,
        @estado = @v_estado;

    IF @mostrar_resumen = 1
    BEGIN
        SELECT
            i.id_importacion,
            i.fuente,
            i.archivo,
            i.formato,
            i.fecha_inicio,
            i.fecha_fin,
            i.filas_leidas,
            i.filas_ok,
            i.filas_error,
            i.filas_leidas - i.filas_ok - i.filas_error AS filas_omitidas,   -- filtradas (fuera de rango, duplicadas, sin dato); filas_ok incluye las sin cambios
            i.estado
        FROM soporte.importacion AS i
        WHERE i.id_importacion = @id_importacion;

        IF EXISTS (SELECT 1 FROM soporte.importacion_error AS e WHERE e.id_importacion = @id_importacion)
            SELECT TOP (100)
                e.nro_error,
                e.nro_fila,
                e.columna,
                e.valor,
                e.mensaje
            FROM soporte.importacion_error AS e
            WHERE e.id_importacion = @id_importacion
            ORDER BY e.nro_error;
    END
END;
GO

-- ============================================================================
-- 3. LECTURA DE ARCHIVOS
-- ============================================================================

-- Lee un archivo completo como binario y como texto UTF-8.
-- OPENROWSET(BULK ...) no admite la ruta como variable: este es el único
-- punto donde se usa SQL dinámico, con la ruta validada y escapada.
-- El archivo se lee con la cuenta del servicio de SQL Server, que debe tener
-- permiso de lectura sobre la carpeta.
CREATE OR ALTER PROCEDURE soporte.usp_Archivo_Leer
    @archivo NVARCHAR(260),
    @contenido NVARCHAR(MAX) = NULL OUTPUT,
    @binario VARBINARY(MAX) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_errores NVARCHAR(400) = soporte.fn_ValidarRutaArchivo(@archivo, N'.csv,.txt,.json,.xml,.html,.htm');
    DECLARE @v_sql NVARCHAR(MAX);
    DECLARE @v_mensaje NVARCHAR(2048);
    CREATE TABLE #archivo_texto (contenido NVARCHAR(MAX) COLLATE DATABASE_DEFAULT);

    IF @v_errores <> N''
    BEGIN
        SET @v_mensaje = CONCAT(N'soporte.usp_Archivo_Leer: ', @v_errores);
        THROW 50001, @v_mensaje, 1;
    END

    SET @v_sql = N'SELECT @p_binario = a.BulkColumn FROM OPENROWSET(BULK N'''
               + REPLACE(LTRIM(RTRIM(@archivo)), N'''', N'''''')
               + N''', SINGLE_BLOB) AS a;';

    BEGIN TRY
        EXEC sys.sp_executesql @v_sql, N'@p_binario VARBINARY(MAX) OUTPUT', @p_binario = @binario OUTPUT;
    END TRY
    BEGIN CATCH
        SET @v_mensaje = LEFT(CONCAT(N'soporte.usp_Archivo_Leer: no se pudo leer el archivo ', @archivo,
                                     N' (verifique que exista y que la cuenta del servicio SQL Server tenga permiso de lectura). Detalle: ',
                                     ERROR_MESSAGE()), 2048);
        THROW 50002, @v_mensaje, 1;
    END CATCH

    IF @binario IS NULL OR DATALENGTH(@binario) = 0
        THROW 50002, N'soporte.usp_Archivo_Leer: el archivo esta vacio', 1;

    -- Se quita la marca BOM de UTF-8 si existe.
    IF SUBSTRING(@binario, 1, 3) = 0xEFBBBF
        SET @binario = SUBSTRING(@binario, 4, DATALENGTH(@binario));

    -- Decodificación UTF-8 -> Unicode: BULK INSERT con CODEPAGE 65001 carga el
    -- archivo completo en una sola fila (los terminadores elegidos no aparecen
    -- en los archivos de datos).
    SET @v_sql = N'BULK INSERT #archivo_texto FROM N'''
               + REPLACE(LTRIM(RTRIM(@archivo)), N'''', N'''''')
               + N''' WITH (CODEPAGE = ''65001'', DATAFILETYPE = ''char'', '
               + N'FIELDTERMINATOR = ''<|~fin_campo~|>'', ROWTERMINATOR = ''<|~fin_fila~|>'');';

    BEGIN TRY
        EXEC sys.sp_executesql @v_sql;
    END TRY
    BEGIN CATCH
        SET @v_mensaje = LEFT(CONCAT(N'soporte.usp_Archivo_Leer: no se pudo decodificar el archivo ', @archivo,
                                     N' como UTF-8. Detalle: ', ERROR_MESSAGE()), 2048);
        THROW 50002, @v_mensaje, 1;
    END CATCH

    SELECT @contenido = t.contenido FROM #archivo_texto AS t;

    -- Si quedó la marca BOM como carácter U+FEFF, se quita.
    IF LEFT(@contenido, 1) = NCHAR(65279)
        SET @contenido = STUFF(@contenido, 1, 1, N'');
END;
GO

-- Carga un archivo delimitado en una tabla de paso con BULK INSERT.
-- Solo se admiten las vistas de carga definidas en 04_Tablas_Importacion.sql.
CREATE OR ALTER PROCEDURE soporte.usp_Archivo_CargarDelimitado
    @archivo NVARCHAR(260),
    @vista_destino SYSNAME,
    @es_csv BIT,                  -- 1: CSV con comillas (FORMAT = 'CSV'); 0: tabulaciones
    @primera_fila INT = 1,
    @filas_cargadas INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_errores NVARCHAR(400) = soporte.fn_ValidarRutaArchivo(@archivo, CASE WHEN @es_csv = 1 THEN N'.csv' ELSE N'.txt,.tsv' END);
    DECLARE @v_sql NVARCHAR(MAX);
    DECLARE @v_mensaje NVARCHAR(2048);

    IF @vista_destino NOT IN (N'soporte.vw_stg_pais_csv_carga', N'soporte.vw_stg_huso_txt_carga', N'soporte.vw_stg_ciudad_txt_carga')
        SET @v_errores += N'vista de carga no admitida; ';

    IF @primera_fila IS NULL OR @primera_fila < 1
        SET @v_errores += N'primera_fila debe ser mayor o igual a 1; ';

    IF @v_errores <> N''
    BEGIN
        SET @v_mensaje = CONCAT(N'soporte.usp_Archivo_CargarDelimitado: ', @v_errores);
        THROW 50001, @v_mensaje, 1;
    END

    -- BULK INSERT no acepta la ruta ni las opciones como variables.
    SET @v_sql = N'BULK INSERT ' + @vista_destino
               + N' FROM N''' + REPLACE(LTRIM(RTRIM(@archivo)), N'''', N'''''') + N''''
               + N' WITH (CODEPAGE = ''65001'', FIRSTROW = ' + CONVERT(NVARCHAR(10), @primera_fila)
               + CASE WHEN @es_csv = 1
                      THEN N', FORMAT = ''CSV'', FIELDQUOTE = ''"'', FIELDTERMINATOR = '','', ROWTERMINATOR = ''0x0a'''
                      ELSE N', FIELDTERMINATOR = ''\t'', ROWTERMINATOR = ''0x0a'''
                 END
               + N', TABLOCK);'
               + N' SET @p_filas = @@ROWCOUNT;';

    BEGIN TRY
        EXEC sys.sp_executesql @v_sql, N'@p_filas INT OUTPUT', @p_filas = @filas_cargadas OUTPUT;
    END TRY
    BEGIN CATCH
        SET @v_mensaje = LEFT(CONCAT(N'soporte.usp_Archivo_CargarDelimitado: no se pudo cargar el archivo ', @archivo,
                                     N'. Detalle: ', ERROR_MESSAGE()), 2048);
        THROW 50002, @v_mensaje, 1;
    END CATCH
END;
GO

-- ============================================================================
-- 4. CONSUMO HTTP (APIs y scraping)
-- ============================================================================

-- Realiza un GET y devuelve el cuerpo de la respuesta como texto.
-- La propiedad responseText se recupera con INSERT ... EXEC para no quedar
-- limitada a 4000 caracteres (las páginas de Wikipedia superan los 3 MB).
CREATE OR ALTER PROCEDURE soporte.usp_Http_Obtener
    @url NVARCHAR(2000),
    @contenido NVARCHAR(MAX) OUTPUT,
    @estado_http INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_errores NVARCHAR(2000) = N'';
    DECLARE @v_objeto INT;
    DECLARE @v_hr INT;
    DECLARE @v_paso NVARCHAR(40);
    DECLARE @v_origen NVARCHAR(255);
    DECLARE @v_descripcion NVARCHAR(255);
    DECLARE @v_mensaje NVARCHAR(2048);
    DECLARE @v_respuesta TABLE (texto NVARCHAR(MAX));

    SET @contenido = NULL;
    SET @estado_http = NULL;

    IF NULLIF(LTRIM(RTRIM(@url)), N'') IS NULL
        SET @v_errores += N'url obligatoria; ';
    ELSE IF @url NOT LIKE N'https://%' AND @url NOT LIKE N'http://%'
        SET @v_errores += N'la url debe comenzar con http:// o https://; ';

    IF NOT EXISTS (SELECT 1 FROM sys.configurations WHERE name = 'Ole Automation Procedures' AND value_in_use = 1)
        SET @v_errores += N'la instancia no tiene habilitada la opcion Ole Automation Procedures (ver 17_SP_Importacion_Soporte.sql); ';

    IF @v_errores <> N''
    BEGIN
        SET @v_mensaje = LEFT(CONCAT(N'soporte.usp_Http_Obtener: ', @v_errores), 2048);
        THROW 50001, @v_mensaje, 1;
    END

    SET @v_paso = N'crear objeto';
    EXEC @v_hr = sys.sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @v_objeto OUTPUT;

    IF @v_hr = 0
    BEGIN
        SET @v_paso = N'configurar tiempos de espera';
        EXEC @v_hr = sys.sp_OAMethod @v_objeto, 'setTimeouts', NULL, 15000, 15000, 30000, 120000;
    END
    IF @v_hr = 0
    BEGIN
        SET @v_paso = N'abrir conexion';
        EXEC @v_hr = sys.sp_OAMethod @v_objeto, 'open', NULL, 'GET', @url, 'false';
    END
    IF @v_hr = 0
    BEGIN
        SET @v_paso = N'definir User-Agent';
        EXEC @v_hr = sys.sp_OAMethod @v_objeto, 'setRequestHeader', NULL, 'User-Agent', 'Mundial2026-TP-BDA-UNLaM/1.0 (Grupo 01; uso academico)';
    END
    IF @v_hr = 0
    BEGIN
        SET @v_paso = N'enviar solicitud';
        EXEC @v_hr = sys.sp_OAMethod @v_objeto, 'send';
    END
    IF @v_hr = 0
    BEGIN
        SET @v_paso = N'leer estado';
        EXEC @v_hr = sys.sp_OAGetProperty @v_objeto, 'status', @estado_http OUTPUT;
    END
    IF @v_hr = 0
    BEGIN
        SET @v_paso = N'leer respuesta';
        INSERT INTO @v_respuesta (texto)
        EXEC @v_hr = sys.sp_OAGetProperty @v_objeto, 'responseText';
    END

    IF @v_hr <> 0
    BEGIN
        EXEC sys.sp_OAGetErrorInfo @v_objeto, @v_origen OUTPUT, @v_descripcion OUTPUT;
        IF @v_objeto IS NOT NULL
            EXEC sys.sp_OADestroy @v_objeto;
        SET @v_mensaje = LEFT(CONCAT(N'soporte.usp_Http_Obtener: fallo al ', @v_paso, N' (', @url, N'). ',
                                     ISNULL(@v_descripcion, N'sin detalle')), 2048);
        THROW 50002, @v_mensaje, 1;
    END

    EXEC sys.sp_OADestroy @v_objeto;

    SELECT @contenido = r.texto FROM @v_respuesta AS r;

    IF @estado_http IS NULL OR @estado_http NOT BETWEEN 200 AND 299
    BEGIN
        SET @v_mensaje = LEFT(CONCAT(N'soporte.usp_Http_Obtener: la solicitud a ', @url,
                                     N' respondio con estado HTTP ', ISNULL(CONVERT(NVARCHAR(10), @estado_http), N'desconocido')), 2048);
        THROW 50002, @v_mensaje, 1;
    END

    IF @contenido IS NULL OR LEN(@contenido) = 0
    BEGIN
        SET @v_mensaje = LEFT(CONCAT(N'soporte.usp_Http_Obtener: la respuesta de ', @url, N' llego vacia'), 2048);
        THROW 50002, @v_mensaje, 1;
    END
END;
GO

-- ============================================================================
-- 5. EQUIVALENCIAS DE PAISES
-- ============================================================================

-- Registra una equivalencia solo si todavía no existe. Si el identificador ya
-- apunta a otro país, no lo cambia y lo informa en @conflicto.
CREATE OR ALTER PROCEDURE soporte.usp_EquivalenciaPais_Asegurar
    @tipo VARCHAR(10),
    @valor NVARCHAR(150),
    @id_pais SMALLINT,
    @fuente NVARCHAR(60),
    @conflicto BIT = 0 OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @v_valor NVARCHAR(150) = soporte.fn_Limpiar(@valor);
    DECLARE @v_id_actual SMALLINT;

    SET @conflicto = 0;

    IF @v_valor IS NULL
        RETURN;

    SELECT @v_id_actual = e.id_pais
    FROM soporte.equivalencia_pais AS e
    WHERE e.tipo = @tipo
      AND e.valor = @v_valor;

    IF @v_id_actual IS NULL
        EXEC soporte.usp_EquivalenciaPais_Insertar
            @tipo = @tipo,
            @valor = @v_valor,
            @id_pais = @id_pais,
            @fuente = @fuente;
    ELSE IF @v_id_actual <> @id_pais
        SET @conflicto = 1;
END;
GO
