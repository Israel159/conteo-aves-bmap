"""
Detector Automático de Aves - BMAP APECO
========================================
App de Streamlit para detectar 16 clases de aves marinas y costeras
usando el modelo YOLO26n entrenado por el equipo BMAP.
"""

import streamlit as st
from ultralytics import YOLO
from PIL import Image
import pandas as pd
import numpy as np
import os
import requests
import urllib.request

# ============================================
# CONFIGURACIÓN
# ============================================

# Diccionario de modelos locales en carpeta "modelos/"
MODELOS = {
    "26n": "modelos/26n.pt",
    "26s": "modelos/26s.pt",
    "26m": "modelos/26m.pt",
    "26l": "modelos/26l.pt",
    "26x": "modelos/26x.pt",
}

CLASS_NAMES = [
    'chuita', 'chuita adulta', 'cushuri adulto', 'cushuri juvenil',
    'gallinazo cabeza roja', 'gaviota peruana adulta', 'guanay adulto',
    'pelicano adulto', 'pelicano juvenil', 'pichon pinguino',
    'pichon piquero', 'pinguino adulto', 'pinguino juvenil',
    'piquero adulto', 'piquero juvenil', 'zarcillo'
]

CLASS_COLORS = {
    'chuita': '#e6194b', 'chuita adulta': '#3cb44b',
    'cushuri adulto': '#ffe119', 'cushuri juvenil': '#4363d8',
    'gallinazo cabeza roja': '#f58231', 'gaviota peruana adulta': '#911eb4',
    'guanay adulto': '#42d4f4', 'pelicano adulto': '#f032e6',
    'pelicano juvenil': '#bfef45', 'pichon pinguino': '#fabed4',
    'pichon piquero': '#469990', 'pinguino adulto': '#dcbeff',
    'pinguino juvenil': '#9a6324', 'piquero adulto': '#fffac8',
    'piquero juvenil': '#800000', 'zarcillo': '#aaffc3'
}

# ============================================
# DESCARGAR Y CARGAR TODOS LOS MODELOS
# ============================================
@st.cache_resource
def cargar_todos_los_modelos():
    """
    Carga todos los modelos YOLO desde la carpeta 'modelos/'.
    Retorna un diccionario {tamaño: modelo_YOLO}.
    """
    modelos_cargados = {}
    
    for tamaño, ruta in MODELOS.items():
        
        if not os.path.exists(ruta):
            st.error(f"❌ No se encontró el archivo: {ruta}")
            continue
        
        file_size = os.path.getsize(ruta) / (1024*1024)
        st.info(f"⏳ Cargando modelo {tamaño} ({file_size:.1f} MB)...")
        
        try:
            modelos_cargados[tamaño] = YOLO(ruta)
            st.success(f"✅ Modelo {tamaño} cargado ({file_size:.1f} MB)")
        except Exception as e:
            st.error(f"❌ Error cargando {tamaño}: {str(e)}")
    
    return modelos_cargados

# ============================================
# FUNCIÓN DE DETECCIÓN
# ============================================

def detectar_aves(imagen, modelo, confianza_minima, iou_maximo):
    """
    Detecta aves en una imagen.
    """
    resultados = modelo.predict(
        imagen,
        conf=confianza_minima,
        iou=iou_maximo,
        imgsz=640,
        verbose=False
    )[0]
    
    imagen_anotada = resultados.plot()
    
    datos = []
    for caja in resultados.boxes:
        x1, y1, x2, y2 = caja.xyxy[0].cpu().numpy()
        confianza = float(caja.conf)
        clase_id = int(caja.cls)
        nombre_clase = CLASS_NAMES[clase_id]
        
        datos.append({
            'clase': nombre_clase,
            'confianza': round(confianza, 4),
            'x1': round(x1, 2),
            'y1': round(y1, 2),
            'x2': round(x2, 2),
            'y2': round(y2, 2),
            'ancho_pixeles': round(x2 - x1, 2),
            'alto_pixeles': round(y2 - y1, 2),
            'centro_x': round((x1 + x2) / 2, 2),
            'centro_y': round((y1 + y2) / 2, 2),
            'area_pixeles': round((x2 - x1) * (y2 - y1), 2)
        })
    
    tabla = pd.DataFrame(datos)
    return resultados, imagen_anotada, tabla


# ============================================
# INTERFAZ DE LA APP
# ============================================

def main():
    st.set_page_config(
        page_title="Detector de Aves BMAP",
        page_icon="🐦",
        layout="wide"
    )
    
    st.title("🐦 Detector Automático de Aves")
    st.markdown("""
    **BMAP APECO - Programa de Monitoreo Marino**
    
    Esta herramienta detecta automáticamente **9 especies de aves marinas y su estadío respectivo (Juvenil, Adulto, etc)**
    en fotografías usando inteligencia artificial (YOLOv26 tamaño nano).
    """)
    
    st.divider()
    
    # Sidebar
    with st.sidebar:
        st.header("⚙️ Configuración")
        
        # Selector de tamaño de modelo
        modelo_seleccionado = st.selectbox(
            "Tamaño del modelo YOLO",
            options=["26n", "26s", "26m", "26l", "26x"],
            index=0,
            help="n=nano (más rápido), x=extra large (más preciso)"
        )
        
        confianza = st.slider(
            "Confianza mínima",
            min_value=0.1,
            max_value=0.9,
            value=0.25,
            step=0.05,
            help="Solo mostrar detecciones con confianza mayor a este valor"
        )
        
        # IOU fijo, ya no es configurable por el usuario
        iou = 0.45
        
        st.divider()
        
        st.header("📋 Especies detectables")
        for nombre in CLASS_NAMES:
            color = CLASS_COLORS.get(nombre, '#5a7d4a')
            st.markdown(
                f"<span style='color:{color}; font-size:1.2rem;'>●</span> {nombre}",
                unsafe_allow_html=True
            )
        
        st.divider()
        
        st.info("""
        💡 **Instrucciones:**
        1. Selecciona el tamaño de modelo
        2. Sube una o más imágenes JPG/PNG
        3. Revisa los resultados y descarga el CSV
        """)
    
    # Cargar TODOS los modelos al iniciar
    todos_los_modelos = cargar_todos_los_modelos()
    
    if not todos_los_modelos:
        st.error("❌ No se pudo cargar ningún modelo. Verifica que los archivos estén en la carpeta 'modelos/'")
        st.stop()
    
    # Seleccionar el modelo activo según lo que eligió el usuario
    if modelo_seleccionado not in todos_los_modelos:
        st.error(f"❌ Modelo {modelo_seleccionado} no disponible")
        st.stop()
    
    modelo = todos_los_modelos[modelo_seleccionado]
    st.success(f"🚀 Usando modelo: YOLOv26 {modelo_seleccionado.upper()}")
    
    # Subir imágenes
    st.header("📤 Subir imágenes")
    
    archivos_subidos = st.file_uploader(
        "Selecciona fotografías (JPG, PNG)",
        type=["jpg", "jpeg", "png"],
        accept_multiple_files=True
    )
    
    if not archivos_subidos:
        st.info("👆 Sube una o más imágenes para comenzar el análisis")
        st.stop()
    
    st.success(f"📁 {len(archivos_subidos)} imagen(es) cargada(s)")
    
    todas_las_tablas = []
    
    for numero, archivo in enumerate(archivos_subidos, 1):
        
        st.divider()
        st.subheader(f"🖼️ Imagen {numero}: `{archivo.name}`")
        
        imagen = Image.open(archivo).convert("RGB")
        
        col_izquierda, col_derecha = st.columns(2)
        
        with col_izquierda:
            st.image(imagen, caption="Original", use_column_width=True)
        
        with st.spinner(f"🔍 Analizando..."):
            resultados, imagen_con_cajas, tabla = detectar_aves(
                imagen, modelo, confianza, iou
            )
        
        with col_derecha:
            st.image(
                imagen_con_cajas,
                caption=f"Detecciones: {len(tabla)}",
                use_column_width=True
            )
        
        if len(tabla) > 0:
            conteo = tabla['clase'].value_counts()
            
            st.write("**Conteo por especie:**")
            
            columnas = st.columns(min(len(conteo), 4))
            for i, (especie, cantidad) in enumerate(conteo.items()):
                with columnas[i % len(columnas)]:
                    color = CLASS_COLORS.get(especie, '#5a7d4a')
                    st.markdown(f"""
                    <div style="
                        background-color: {color}20;
                        border: 2px solid {color};
                        border-radius: 10px;
                        padding: 10px;
                        text-align: center;
                    ">
                        <div style="font-size: 2rem; font-weight: bold; color: {color};">
                            {cantidad}
                        </div>
                        <div style="font-size: 0.9rem; color: #555;">
                            {especie}
                        </div>
                    </div>
                    """, unsafe_allow_html=True)
            
            with st.expander("📋 Ver tabla completa de detecciones"):
                st.dataframe(tabla, use_container_width=True, hide_index=True)
                
                csv = tabla.to_csv(index=False).encode('utf-8')
                st.download_button(
                    label=f"📥 Descargar CSV - {archivo.name}",
                    data=csv,
                    file_name=f"detecciones_{archivo.name.split('.')[0]}.csv",
                    mime="text/csv"
                )
            
            tabla_con_nombre = tabla.copy()
            tabla_con_nombre['imagen'] = archivo.name
            todas_las_tablas.append(tabla_con_nombre)
            
        else:
            st.warning("⚠️ No se detectaron aves en esta imagen")
    
    if todas_las_tablas:
        st.divider()
        st.header("📊 Resumen Global")
        
        tabla_total = pd.concat(todas_las_tablas, ignore_index=True)
        
        col1, col2, col3 = st.columns(3)
        
        with col1:
            st.metric("Imágenes analizadas", len(archivos_subidos))
        
        with col2:
            st.metric("Detecciones totales", len(tabla_total))
        
        with col3:
            st.metric("Especies distintas", tabla_total['clase'].nunique())
        
        conteo_total = tabla_total['clase'].value_counts()
        st.bar_chart(conteo_total)
        
        csv_total = tabla_total.to_csv(index=False).encode('utf-8')
        st.download_button(
            label="📥 Descargar CSV completo (todas las imágenes)",
            data=csv_total,
            file_name="detecciones_completas.csv",
            mime="text/csv",
            use_container_width=True
        )

if __name__ == "__main__":
    main()