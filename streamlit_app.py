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

# ============================================
# CONFIGURACIÓN DE LAS 16 CLASES
# ============================================

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
# CARGAR MODELO (se cachea para no recargar)
# ============================================

@st.cache_resource
def load_model():
    """
    Carga el modelo YOLO 26n.pt.
    Busca el archivo en varias ubicaciones posibles.
    """
    # Lista de posibles ubicaciones del modelo
    posibles_rutas = [
        "26n.pt",                                    # Misma carpeta
        os.path.join(os.path.dirname(__file__), "26n.pt"),  # Ruta absoluta
    ]
    
    # Buscar el modelo
    for ruta in posibles_rutas:
        if os.path.exists(ruta):
            return YOLO(ruta)
    
    # Si no lo encuentra, mostrar error
    st.error("❌ No se encontró el archivo `26n.pt`. Asegúrate de subirlo.")
    return None

# ============================================
# FUNCIÓN PRINCIPAL: DETECTAR AVES
# ============================================

def detectar_aves(imagen, modelo, confianza_minima, iou_maximo):
    """
    Recibe una imagen y devuelve las detecciones.
    
    Parámetros:
        imagen: Imagen PIL cargada
        modelo: Modelo YOLO cargado
        confianza_minima: Solo mostrar detecciones con confianza mayor a esto
        iou_maximo: Umbral para eliminar cajas solapadas
    
    Retorna:
        resultados: Objeto con todas las detecciones
        imagen_anotada: Imagen con cajas dibujadas
        tabla: DataFrame con datos de cada detección
    """
    
    # Ejecutar predicción con el modelo
    resultados = modelo.predict(
        imagen,
        conf=confianza_minima,    # Umbral de confianza
        iou=iou_maximo,           # Umbral de IoU para NMS
        imgsz=640,                # Tamaño de entrada
        verbose=False             # No mostrar logs
    )[0]
    
    # Crear imagen con cajas dibujadas
    imagen_anotada = resultados.plot()
    
    # Extraer datos de cada detección para la tabla
    datos = []
    for caja in resultados.boxes:
        # Coordenadas de la caja
        x1, y1, x2, y2 = caja.xyxy[0].cpu().numpy()
        
        # Datos de la detección
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
    
    # Crear tabla (DataFrame)
    tabla = pd.DataFrame(datos)
    
    return resultados, imagen_anotada, tabla

# ============================================
# INTERFAZ DE LA APP (lo que el usuario ve)
# ============================================

def main():
    """
    Función principal que construye la interfaz web.
    """
    
    # Configuración de la página
    st.set_page_config(
        page_title="Detector de Aves BMAP",
        page_icon="🐦",
        layout="wide"
    )
    
    # ========================================
    # ENCABEZADO
    # ========================================
    
    st.title("🐦 Detector Automático de Aves")
    st.markdown("""
    **BMAP APECO - Programa de Monitoreo Marino**
    
    Esta herramienta detecta automáticamente **16 especies de aves marinas y costeras**
    en fotografías usando inteligencia artificial (YOLOv8).
    """)
    
    st.divider()
    
    # ========================================
    # BARRA LATERAL (configuración)
    # ========================================
    
    with st.sidebar:
        st.header("⚙️ Configuración")
        
        # Deslizador de confianza
        confianza = st.slider(
            "Confianza mínima",
            min_value=0.1,
            max_value=0.9,
            value=0.25,
            step=0.05,
            help="Solo mostrar detecciones con confianza mayor a este valor"
        )
        
        # Deslizador de IoU
        iou = st.slider(
            "IoU máximo (NMS)",
            min_value=0.1,
            max_value=0.9,
            value=0.45,
            step=0.05,
            help="Umbral para eliminar detecciones solapadas"
        )
        
        st.divider()
        
        # Lista de clases detectables
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
        1. Sube una o más imágenes JPG/PNG
        2. Ajusta los umbrales si es necesario
        3. Revisa los resultados y descarga el CSV
        """)
    
    # ========================================
    # ÁREA PRINCIPAL
    # ========================================
    
    # Cargar modelo
    modelo = load_model()
    
    if modelo is None:
        st.stop()  # Detener si no hay modelo
    
    st.success("✅ Modelo cargado correctamente")
    
    # Subir imágenes
    st.header("📤 Subir imágenes")
    
    archivos_subidos = st.file_uploader(
        "Selecciona fotografías (JPG, PNG)",
        type=["jpg", "jpeg", "png"],
        accept_multiple_files=True
    )
    
    # Si no hay archivos, mostrar mensaje y detener
    if not archivos_subidos:
        st.info("👆 Sube una o más imágenes para comenzar el análisis")
        st.stop()
    
    # ========================================
    # PROCESAR CADA IMAGEN
    # ========================================
    
    st.success(f"📁 {len(archivos_subidos)} imagen(es) cargada(s)")
    
    todas_las_tablas = []  # Para CSV combinado
    
    for numero, archivo in enumerate(archivos_subidos, 1):
        
        st.divider()
        st.subheader(f"🖼️ Imagen {numero}: `{archivo.name}`")
        
        # Cargar imagen
        imagen = Image.open(archivo).convert("RGB")
        
        # Mostrar imagen original
        col_izquierda, col_derecha = st.columns(2)
        
        with col_izquierda:
            st.image(imagen, caption="Original", use_container_width=True)
        
        # Detectar aves
        with st.spinner(f"🔍 Analizando..."):
            resultados, imagen_con_cajas, tabla = detectar_aves(
                imagen, modelo, confianza, iou
            )
        
        with col_derecha:
            st.image(
                imagen_con_cajas,
                caption=f"Detecciones: {len(tabla)}",
                use_container_width=True
            )
        
        # ========================================
        # ESTADÍSTICAS DE ESTA IMAGEN
        # ========================================
        
        if len(tabla) > 0:
            
            # Conteo por especie
            conteo = tabla['clase'].value_counts()
            
            st.write("**Conteo por especie:**")
            
            # Mostrar conteos en columnas de 4
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
            
            # Tabla detallada
            with st.expander("📋 Ver tabla completa de detecciones"):
                st.dataframe(tabla, use_container_width=True, hide_index=True)
                
                # Botón descargar CSV individual
                csv = tabla.to_csv(index=False).encode('utf-8')
                st.download_button(
                    label=f"📥 Descargar CSV - {archivo.name}",
                    data=csv,
                    file_name=f"detecciones_{archivo.name.split('.')[0]}.csv",
                    mime="text/csv"
                )
            
            # Guardar para CSV combinado
            tabla_con_nombre = tabla.copy()
            tabla_con_nombre['imagen'] = archivo.name
            todas_las_tablas.append(tabla_con_nombre)
            
        else:
            st.warning("⚠️ No se detectaron aves en esta imagen")
    
    # ========================================
    # RESUMEN GLOBAL
    # ========================================
    
    if todas_las_tablas:
        st.divider()
        st.header("📊 Resumen Global")
        
        # Unir todas las tablas
        tabla_total = pd.concat(todas_las_tablas, ignore_index=True)
        
        # Métricas
        col1, col2, col3 = st.columns(3)
        
        with col1:
            st.metric("Imágenes analizadas", len(archivos_subidos))
        
        with col2:
            st.metric("Detecciones totales", len(tabla_total))
        
        with col3:
            st.metric("Especies distintas", tabla_total['clase'].nunique())
        
        # Gráfico de barras
        conteo_total = tabla_total['clase'].value_counts()
        st.bar_chart(conteo_total)
        
        # Descargar CSV combinado
        csv_total = tabla_total.to_csv(index=False).encode('utf-8')
        st.download_button(
            label="📥 Descargar CSV completo (todas las imágenes)",
            data=csv_total,
            file_name="detecciones_completas.csv",
            mime="text/csv",
            use_container_width=True
        )

# ============================================
# EJECUTAR APP
# ============================================

if __name__ == "__main__":
    main()