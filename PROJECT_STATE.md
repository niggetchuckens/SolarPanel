# Estado del Proyecto: Optimizador de Paneles Solares

## Resumen del Sistema
El proyecto consta de una solución integral basada en dos componentes principales:
1. **Backend REST (Flask):** Servidor local (`http://127.0.0.1:5000`) que expone los cálculos físicos, astronómicos, multivariables y meteorológicos:
   - Integración con Open-Meteo para datos de radiación solar y horas de amanecer/atardecer.
   - Cálculo del vector gradiente, derivadas direccionales y matriz Hessiana.
   - Cálculo de proyección de sombras y pérdida de eficiencia.
2. **Frontend Interactivo (Streamlit):** Panel visual (`http://localhost:8501`) que incluye:
   - Visualización 3D en tiempo real de la orientación solar y el panel.
   - Mapa interactivo con Folium para posicionamiento geográfico.
   - Gestión y persistencia de múltiples paneles en caché local.
   - Gráficos comparativos de eficiencia, curvas de nivel y superficies de energía.

## Despliegue y Ejecución
- **Docker:** `Dockerfile` y `docker-compose.yml` para ejecución en contenedores aislados.
- **Scripts:** `entrypoint.sh` (Linux/macOS) y `entrypoint.ps1` (Windows) con detección automática de entorno virtual, instalación de dependencias, health check y terminación limpia de procesos.
