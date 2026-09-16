# Guía de Ejecución para Clientes (Optimizador Solar)

Esta guía explica las formas más sencillas de ejecutar la aplicación sin requerir conocimientos técnicos ni configurar librerías manualmente.

---

## Opción 1: Versión Web con Docker (Recomendada para cualquier sistema operativo)

Si tienes Docker instalado (Docker Desktop en Windows/Mac o Docker en Linux):

1. Abre la carpeta del proyecto en una terminal.
2. Ejecuta:
   ```bash
   docker compose up
   ```
3. Abre tu navegador web e ingresa a:
   👉 **`http://localhost:8501`**

Para detener la aplicación, presiona `Ctrl + C` en la terminal o ejecuta:
```bash
docker compose down
```

---

## Opción 2: Scripts Automatizados (Windows y Linux/macOS)

Los scripts configuran el entorno virtual e instalan dependencias automáticamente si no existen:

- **En Windows (PowerShell):**
  ```powershell
  .\entrypoint.ps1
  ```
- **En Linux / macOS (Bash):**
  ```bash
  ./entrypoint.sh
  ```

---

## Opción 3: Ejecutable de Escritorio (.exe) / Modo Offline

Esta versión corre de forma local y autónoma:

1. Ingresa a la carpeta `dist/`.
2. Haz doble click sobre **`SimuladorSolar`** (o `SimuladorSolar.exe` en Windows).
3. La aplicación iniciará los servicios internos y abrirá automáticamente tu navegador web con la pantalla de simulación.

---

## Características de la Aplicación

- **Visualización 3D Interactiva:** Simulación en tiempo real de la posición del sol y orientación del panel con ángulos azimutales y de elevación.
- **Gestión Multi-panel y Mapa:** Agrega y compara múltiples paneles solares ubicados geográficamente mediante mapa interactivo.
- **Simulación Diaria de Energía:** Genera la curva horaria de producción energética y estima la energía total diaria en kWh.
- **Análisis de Sensibilidad e Incertidumbre:** Calcula la pérdida de energía producida por desalineaciones angulares (error en inclinación u orientación) y matriz Hessiana.
- **Proyección de Sombras:** Análisis detallado de pérdida por sombreado durante intervalos del día.
