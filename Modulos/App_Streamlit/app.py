"""
Universidad Nacional de La Matanza (UNLaM)
Materia : 3641 - Bases de Datos Aplicada
Comision: 02-5600
Grupo   : 01
Integrantes: Gomez Kevin Ariel, Kobak Camila Nicole, Bogado Rodrigo David, Caceres Lautaro Agustin
Fecha   : 2026-11-26
Objetivo: Entrega 9. Aplicacion web sencilla (Streamlit) del sistema del Mundial 2026.
          - Sedes: ABM (alta, baja y modificacion) llamando a los SP de la Entrega 5.
          - Mapa de sedes con latitud y longitud.
          - Importacion de archivos con la logica de la Entrega 6.
          - Reportes de la Entrega 7 en XML (se guardan en la carpeta salidas/).
          La aplicacion no escribe SQL: todo pasa por db.py, que llama a procedimientos almacenados.
          Los permisos los decide la base: si el usuario con el que se conecta no puede ejecutar un SP,
          la aplicacion muestra el error de permisos tal cual lo devuelve SQL Server.

Ejecutar:  python -m streamlit run app.py   (desde esta carpeta; el tema esta en .streamlit/config.toml)
"""
import os
from datetime import datetime
from decimal import Decimal

import pandas as pd
import streamlit as st

import db

# Carpeta donde se guardan los archivos subidos. SQL Server los lee desde ahi, asi que tiene que estar
# en la misma PC que la instancia y ser legible para el servicio de SQL Server.
CARPETA_IMPORT = os.getenv("CARPETA_IMPORT", r"C:\Mundial2026\datos\subidos")
CARPETA_SALIDAS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "salidas")

CARPETA_APP = os.path.dirname(os.path.abspath(__file__))
LOGO = os.path.join(CARPETA_APP, "logo_unlam.png")
ICONO_VACIO = os.path.join(CARPETA_APP, "vacio.png")      # imagen transparente: la pestana queda sin icono
MATERIA = "Bases de Datos Aplicada - 3641"

st.set_page_config(page_title="Mundial 2026 - Grupo 01", page_icon=ICONO_VACIO, layout="wide")

# Estilos menores: separacion de pestanas y titulos en azul claro (el resto lo define .streamlit/config.toml).
st.markdown(
    """
    <style>
    h1, h2, h3 { color: #6DB8F2; }
    .stTabs [data-baseweb="tab-list"] { gap: 1.5rem; margin-top: 0.5rem; }
    [data-testid="stSidebar"] hr { border-color: #1F2A37; }
    </style>
    """,
    unsafe_allow_html=True,
)

COLUMNAS = {"id_sede": "ID", "nombre_estadio": "Estadio", "capacidad": "Capacidad", "direccion": "Dirección",
            "latitud": "Latitud", "longitud": "Longitud", "ciudad": "Ciudad", "pais": "País"}


def tabla_sedes(filas):
    """DataFrame de sedes con encabezados en espanol correcto y sin 'None' en los vacios."""
    df = pd.DataFrame(filas)
    if "direccion" in df:
        df["direccion"] = df["direccion"].fillna("—")
    return df.rename(columns=COLUMNAS)


def a_float(valor):
    return float(valor) if isinstance(valor, Decimal) else valor


def mostrar_error(e):
    st.error(str(e))


# ---------------------------------------------------------------------------
# BLOQUE A: sedes (ABM)
# ---------------------------------------------------------------------------
def selector_ciudad(clave, sede_actual=None):
    """Busca ciudades por texto (llama a geo.usp_Ciudad_Buscar) y devuelve el id elegido."""
    texto = st.text_input("Buscar ciudad (mínimo 2 letras)", key=f"{clave}_texto")
    opciones = {}
    if sede_actual:
        opciones[sede_actual["id_ciudad"]] = f"{sede_actual['ciudad']} ({sede_actual['pais']}) - actual"
    if len(texto.strip()) >= 2:
        try:
            for c in db.buscar_ciudades(texto):
                opciones[c["id_ciudad"]] = f"{c['ciudad']} ({c['pais']})"
        except db.ErrorBD as e:
            mostrar_error(e)
    if not opciones:
        st.info("Escribí al menos 2 letras para buscar la ciudad.")
        return None
    return st.selectbox("Ciudad", list(opciones), format_func=lambda i: opciones[i], key=f"{clave}_ciudad")


def campos_coordenadas(clave, latitud=None, longitud=None):
    """Devuelve (latitud, longitud); ambas None si no se informan."""
    informar = st.checkbox("Informar coordenadas", value=latitud is not None, key=f"{clave}_coord")
    if not informar:
        return None, None
    col1, col2 = st.columns(2)
    lat = col1.number_input("Latitud", -90.0, 90.0, a_float(latitud) if latitud is not None else 0.0,
                            format="%.6f", key=f"{clave}_lat")
    lon = col2.number_input("Longitud", -180.0, 180.0, a_float(longitud) if longitud is not None else 0.0,
                            format="%.6f", key=f"{clave}_lon")
    return lat, lon


def pagina_sedes():
    st.header("Sedes")
    filtro = st.text_input("Filtrar por estadio, ciudad o país", key="filtro_sedes",
                           placeholder="Ej.: Azteca, Dallas, Canadá")
    try:
        sedes = db.listar_sedes(filtro)
    except db.ErrorBD as e:
        mostrar_error(e)
        return

    if sedes:
        filas = [{k: a_float(v) for k, v in s.items() if k != "id_ciudad"} for s in sedes]
        st.caption(f"{len(filas)} sedes en el listado.")
        st.dataframe(tabla_sedes(filas), use_container_width=True, hide_index=True)
    else:
        st.info("No hay sedes con ese filtro.")

    st.divider()
    tab_alta, tab_modificar = st.tabs(["Alta", "Modificar o eliminar"])

    with tab_alta:
        nombre = st.text_input("Nombre del estadio", key="alta_nombre")
        capacidad = st.number_input("Capacidad", min_value=0, value=40000, step=1000, key="alta_cap")
        direccion = st.text_input("Dirección (opcional)", key="alta_dir")
        id_ciudad = selector_ciudad("alta")
        lat, lon = campos_coordenadas("alta")
        if st.button("Crear sede", key="alta_boton"):
            try:
                nuevo = db.insertar_sede(nombre, int(capacidad), direccion or None, lat, lon, id_ciudad)
                st.success(f"Sede creada con id {nuevo}.")
            except db.ErrorBD as e:
                mostrar_error(e)

    with tab_modificar:
        if not sedes:
            st.info("Primero tiene que haber una sede en el listado.")
            return
        por_id = {s["id_sede"]: s for s in sedes}
        elegida = st.selectbox("Sede", list(por_id), format_func=lambda i: f"{i} - {por_id[i]['nombre_estadio']}",
                               key="mod_sede")
        s = por_id[elegida]
        k = f"mod{elegida}"            # las claves cambian con la sede para que se recarguen los valores
        nombre = st.text_input("Nombre del estadio", value=s["nombre_estadio"], key=f"{k}_nombre")
        capacidad = st.number_input("Capacidad", min_value=0, value=int(s["capacidad"]), step=1000, key=f"{k}_cap")
        direccion = st.text_input("Dirección", value=s["direccion"] or "", key=f"{k}_dir")
        id_ciudad = selector_ciudad(k, s)
        lat, lon = campos_coordenadas(k, s["latitud"], s["longitud"])

        col_mod, col_baja = st.columns(2)
        if col_mod.button("Guardar cambios", key=f"{k}_guardar"):
            try:
                db.modificar_sede(elegida, nombre, int(capacidad), direccion or None, lat, lon, id_ciudad)
                st.success("Sede modificada. Actualizá el listado de arriba al volver a cargar la página.")
            except db.ErrorBD as e:
                mostrar_error(e)
        confirmar = col_baja.checkbox("Confirmo que quiero eliminar esta sede", key=f"{k}_confirma")
        if col_baja.button("Eliminar sede", key=f"{k}_eliminar", disabled=not confirmar):
            try:
                db.eliminar_sede(elegida)
                st.success("Sede eliminada.")
            except db.ErrorBD as e:
                mostrar_error(e)


# ---------------------------------------------------------------------------
# BLOQUE B: mapa de sedes
# ---------------------------------------------------------------------------
def pagina_mapa():
    st.header("Mapa de sedes")
    try:
        sedes = db.listar_sedes()
    except db.ErrorBD as e:
        mostrar_error(e)
        return
    con_geo = [s for s in sedes if s["latitud"] is not None and s["longitud"] is not None]
    st.caption(f"{len(con_geo)} de {len(sedes)} sedes tienen latitud y longitud.")
    if con_geo:
        mapa = pd.DataFrame({"lat": [a_float(s["latitud"]) for s in con_geo],
                             "lon": [a_float(s["longitud"]) for s in con_geo]})
        st.map(mapa, size=30000)
        st.dataframe(tabla_sedes(con_geo)[["Estadio", "Ciudad", "País", "Capacidad"]],
                     use_container_width=True, hide_index=True)


# ---------------------------------------------------------------------------
# BLOQUE C: importacion de archivos (logica de la Entrega 6)
# ---------------------------------------------------------------------------
def pagina_importacion():
    st.header("Importación de archivos")
    st.write("El archivo se guarda en el servidor de la base y se procesa con el SP de importacion "
             "(Entrega 6): inserta lo nuevo, actualiza lo que cambio y reporta los errores.")
    importador = st.selectbox("Qué querés importar", list(db.IMPORTADORES))
    extension = ".csv" if "CSV" in importador else ".txt"
    archivo = st.file_uploader("Archivo", type=[extension.lstrip(".")])

    if archivo is not None and st.button("Importar"):
        os.makedirs(CARPETA_IMPORT, exist_ok=True)
        ruta = os.path.join(CARPETA_IMPORT, os.path.basename(archivo.name))
        with open(ruta, "wb") as destino:
            destino.write(archivo.getbuffer())
        try:
            resultados, id_importacion = db.importar_archivo(importador, ruta)
            st.success(f"Importación {id_importacion} terminada. Archivo: {ruta}")
            for conjunto in resultados:                       # lo que devuelve el SP (cabecera y resumen)
                if conjunto:
                    st.dataframe(pd.DataFrame(conjunto), use_container_width=True, hide_index=True)
            _, errores = db.resumen_importacion(id_importacion)
            if errores:
                st.warning("Filas con error (primeras 200):")
                st.dataframe(pd.DataFrame(errores), use_container_width=True, hide_index=True)
            else:
                st.info("No hubo filas con error.")
        except db.ErrorBD as e:
            mostrar_error(e)


# ---------------------------------------------------------------------------
# BLOQUE D: reportes de la Entrega 7 (XML guardado en disco)
# ---------------------------------------------------------------------------
def guardar_xml(nombre, contenido):
    os.makedirs(CARPETA_SALIDAS, exist_ok=True)
    marca = datetime.now().strftime("%Y%m%d_%H%M%S")
    ruta = os.path.join(CARPETA_SALIDAS, f"{nombre}_{marca}.xml")
    with open(ruta, "w", encoding="utf-8") as f:
        f.write(contenido)
    return ruta


def pagina_reportes():
    st.header("Reportes")
    reporte = st.selectbox("Reporte", ["Goleadores (XML)", "Selecciones y plantillas (XML)", "Goleadores (tabla)"])
    if not st.button("Generar"):
        return
    try:
        if reporte == "Goleadores (tabla)":
            for conjunto in db.reporte_goleadores("TABLA"):
                if conjunto:
                    st.dataframe(pd.DataFrame(conjunto), use_container_width=True, hide_index=True)
            return
        if reporte == "Goleadores (XML)":
            xml, nombre = db.texto_xml(db.reporte_goleadores("XML")), "goleadores"
        else:
            xml, nombre = db.reporte_selecciones_plantillas(None), "selecciones_plantillas"
    except db.ErrorBD as e:
        mostrar_error(e)
        return
    if not xml:
        st.info("El reporte no devolvió datos.")
        return
    ruta = guardar_xml(nombre, xml)
    st.success(f"XML guardado en {ruta}")
    st.download_button("Descargar XML", xml.encode("utf-8"), file_name=os.path.basename(ruta), mime="application/xml")
    st.code(xml[:20000] + ("\n... (recortado en pantalla)" if len(xml) > 20000 else ""), language="xml")


# ---------------------------------------------------------------------------
# BLOQUE E: menu principal
# ---------------------------------------------------------------------------
PAGINAS = {
    "Sedes (ABM)": pagina_sedes,
    "Mapa de sedes": pagina_mapa,
    "Importación": pagina_importacion,
    "Reportes XML": pagina_reportes,
}

if os.path.exists(LOGO):
    st.sidebar.image(LOGO, width=96)
st.sidebar.title("Mundial 2026")
st.sidebar.markdown(f"**{MATERIA}**")
st.sidebar.markdown("Grupo 01")
st.sidebar.caption(f"Servidor: {db.SERVIDOR}\n\nBase: {db.BASE}")
st.sidebar.divider()
PAGINAS[st.sidebar.radio("Menú", list(PAGINAS))]()
