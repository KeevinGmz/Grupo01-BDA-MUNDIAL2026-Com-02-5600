"""
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comision: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-25
Objetivo: Entrega 9. Capa de acceso a la base de la aplicacion Streamlit.
          Aca esta TODO lo que habla con SQL Server. La aplicacion (app.py) no escribe SQL:
          solo llama a las funciones de este archivo, y estas llaman a procedimientos almacenados
          (los ABM de la Entrega 5, la importacion de la Entrega 6 y los reportes de la Entrega 7).

Conexion: pymssql con autenticacion de Windows (sin usuario ni clave), igual que el resto del TP.
Variables de entorno opcionales:
    MSSQL_SERVER    servidor\\instancia   (por defecto DESKTOP-ED0OKK5\\MUNDIAL2026)
    MSSQL_BASE      base de datos         (por defecto Mundial2026)
    MSSQL_USER / MSSQL_PASSWORD           (solo si se quiere entrar con un usuario de SQL Server)
"""
import os

import pymssql

SERVIDOR = os.getenv("MSSQL_SERVER", r"DESKTOP-ED0OKK5\MUNDIAL2026")
BASE = os.getenv("MSSQL_BASE", "Mundial2026")
USUARIO = os.getenv("MSSQL_USER")
CLAVE = os.getenv("MSSQL_PASSWORD")


class ErrorBD(Exception):
    """Error de la base ya limpio, listo para mostrarle al usuario."""


# ---------------------------------------------------------------------------
# BLOQUE 1: conexion y llamada generica a un procedimiento almacenado
# ---------------------------------------------------------------------------
def _conectar():
    # appname: nombre con el que la aplicacion se presenta ante SQL Server (sirve para filtrar en la demostracion)
    parametros = {"server": SERVIDOR, "database": BASE, "autocommit": True,
                  "login_timeout": 15, "as_dict": True, "appname": "AppMundial2026"}
    if USUARIO:                      # sin usuario => autenticacion de Windows
        parametros["user"] = USUARIO
        parametros["password"] = CLAVE
    return pymssql.connect(**parametros)


def _texto_error(e):
    """Saca el mensaje de SQL Server (el THROW del SP) sin el ruido de DB-Lib."""
    mensaje = ""
    for dato in e.args:
        if isinstance(dato, bytes):
            mensaje = dato.decode("utf-8", errors="replace")
        elif isinstance(dato, str):
            mensaje = dato
    return mensaje.split("DB-Lib error")[0].strip() or "Error de base de datos"


def _detalle_conexion(e):
    """Mensaje completo de un fallo de conexion (servidor inexistente, login, puerto...), sin recortar."""
    partes = []
    for dato in e.args:
        if isinstance(dato, bytes):
            dato = dato.decode("utf-8", errors="replace")
        partes.append(str(dato).replace("\n", " ").strip())
    return " | ".join(p for p in partes if p) or "Error de conexion"


def llamar_sp(nombre, parametros=None, salida_int=None):
    """
    Ejecuta un procedimiento almacenado y devuelve (conjuntos_de_resultados, valor_de_salida).

    nombre      : 'esquema.usp_Nombre' (siempre lo escribe el codigo, nunca el usuario).
    parametros  : dict {nombre_sin_arroba: valor}. Los valores viajan como parametros (no se pegan al texto).
    salida_int  : nombre (sin arroba) de un parametro OUTPUT de tipo INT, si el SP tiene uno.
    """
    parametros = parametros or {}
    asignaciones = [f"@{clave} = %s" for clave in parametros]
    sql = ""
    if salida_int:
        sql += "DECLARE @v_salida INT; "
        asignaciones.append(f"@{salida_int} = @v_salida OUTPUT")
    sql += f"EXEC {nombre} " + ", ".join(asignaciones) + ";"
    if salida_int:
        sql += " SELECT @v_salida AS salida;"

    try:
        conexion = _conectar()
    except pymssql.Error as e:
        raise ErrorBD("No se pudo conectar a " + SERVIDOR + " / " + BASE + ": " + _detalle_conexion(e))

    resultados = []
    try:
        cursor = conexion.cursor()
        cursor.execute(sql, tuple(parametros.values()))
        while True:
            if cursor.description:
                resultados.append(cursor.fetchall())
            if not cursor.nextset():
                break
    except pymssql.Error as e:
        raise ErrorBD(_texto_error(e))
    finally:
        conexion.close()

    salida = None
    if salida_int and resultados:
        salida = resultados.pop()[0]["salida"]    # el ultimo SELECT es el valor de salida
    return resultados, salida


def texto_xml(resultados):
    """FOR XML llega partido en filas de ~2000 caracteres: se vuelve a unir."""
    if not resultados or not resultados[0]:
        return ""
    return "".join(str(list(fila.values())[0]) for fila in resultados[0])


# ---------------------------------------------------------------------------
# BLOQUE 2: sedes (ABM de la Entrega 5 + listado de la Entrega 9)
# ---------------------------------------------------------------------------
def listar_sedes(texto=None):
    resultados, _ = llamar_sp("torneo.usp_Sede_Listar", {"texto": texto or None})
    return resultados[0] if resultados else []


def buscar_ciudades(texto):
    resultados, _ = llamar_sp("geo.usp_Ciudad_Buscar", {"texto": texto, "max": 50})
    return resultados[0] if resultados else []


def insertar_sede(nombre, capacidad, direccion, latitud, longitud, id_ciudad):
    _, id_sede = llamar_sp("torneo.usp_Sede_Insertar", {
        "nombre_estadio": nombre, "capacidad": capacidad, "direccion": direccion,
        "latitud": latitud, "longitud": longitud, "id_ciudad": id_ciudad,
    }, salida_int="id_sede")
    return id_sede


def modificar_sede(id_sede, nombre, capacidad, direccion, latitud, longitud, id_ciudad):
    llamar_sp("torneo.usp_Sede_Modificar", {
        "id_sede": id_sede, "nombre_estadio": nombre, "capacidad": capacidad,
        "direccion": direccion, "latitud": latitud, "longitud": longitud, "id_ciudad": id_ciudad,
    })


def eliminar_sede(id_sede):
    llamar_sp("torneo.usp_Sede_Eliminar", {"id_sede": id_sede})


# ---------------------------------------------------------------------------
# BLOQUE 3: importacion de archivos (Entrega 6)
# ---------------------------------------------------------------------------
IMPORTADORES = {
    "Paises (CSV)": "soporte.usp_Importar_PaisesCsv",
    "Husos horarios (TXT)": "soporte.usp_Importar_HusosTxt",
}


def importar_archivo(importador, ruta_archivo):
    """Llama al SP de importacion con la ruta del archivo. Devuelve (resultados_del_sp, id_importacion)."""
    resultados, id_importacion = llamar_sp(IMPORTADORES[importador], {"archivo": ruta_archivo},
                                           salida_int="id_importacion")
    return resultados, id_importacion


def resumen_importacion(id_importacion):
    """Devuelve (cabecera, errores) de una importacion ya hecha."""
    resultados, _ = llamar_sp("soporte.usp_Importacion_Resumen", {"id_importacion": id_importacion})
    cabecera = resultados[0] if len(resultados) > 0 else []
    errores = resultados[1] if len(resultados) > 1 else []
    return cabecera, errores


# ---------------------------------------------------------------------------
# BLOQUE 4: reportes de la Entrega 7
# ---------------------------------------------------------------------------
def reporte_goleadores(formato):
    """formato: 'TABLA' o 'XML'. Devuelve los conjuntos de resultados del SP."""
    resultados, _ = llamar_sp("reporte.usp_Goleadores",
                              {"id_seleccion": None, "nro_fase": None, "formato": formato})
    return resultados


def reporte_selecciones_plantillas(id_seleccion=None):
    """Devuelve el XML con las selecciones y su vector anidado de convocados."""
    resultados, _ = llamar_sp("reporte.usp_SeleccionesPlantillas",
                              {"id_seleccion": id_seleccion, "incluir_bajas": 0})
    return texto_xml(resultados)
