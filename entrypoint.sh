#!/bin/bash
set -e

# Asegurar que el directorio de trabajo sea la raíz del proyecto
cd "$(dirname "$0")"

# 1. Gestionar entorno virtual si no estamos en uno o no existen dependencias
if [ -d "venv" ] && [ -f "venv/bin/activate" ]; then
  echo "Entorno virtual encontrado. Activando 'venv'..."
  source venv/bin/activate
elif [ -z "$VIRTUAL_ENV" ] && ! python3 -c "import flask, streamlit, folium, streamlit_folium, pysolar" 2>/dev/null && ! python -c "import flask, streamlit, folium, streamlit_folium, pysolar" 2>/dev/null; then
  echo "No se encontró entorno virtual ni dependencias necesarias. Creando 'venv'..."
  if command -v python3 >/dev/null 2>&1; then
    python3 -m venv venv
  elif command -v python >/dev/null 2>&1; then
    python -m venv venv
  else
    echo "Error: Python no está instalado en el sistema." >&2
    exit 1
  fi
  source venv/bin/activate
fi

# 2. Verificar e instalar dependencias si faltan
if ! python -c "import flask, streamlit, folium, streamlit_folium, pysolar" 2>/dev/null; then
  echo "Instalando dependencias desde requirements.txt..."
  pip install --upgrade pip 2>/dev/null || true
  pip install -r requirements.txt
fi

# Asegurar limpieza del backend al finalizar o interrumpir
cleanup() {
  if [ -n "$API_PID" ] && kill -0 "$API_PID" 2>/dev/null; then
    echo "Deteniendo proceso Flask (PID: $API_PID)..."
    kill "$API_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

echo "=== Iniciando Backend API Flask ==="
python src/api/app.py &
API_PID=$!

# Esperar a que la API responda
echo "Esperando que el servicio API esté listo en el puerto 5000..."
until python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/api/health')" 2>/dev/null; do
  if ! kill -0 $API_PID 2>/dev/null; then
    echo "Error: El proceso Flask se detuvo inesperadamente." >&2
    exit 1
  fi
  sleep 1
done
echo "API Flask lista."

echo "=== Iniciando Frontend Streamlit ==="
streamlit run src/streamlit/main.py \
    --server.port=8501 \
    --server.address=0.0.0.0 \
    --server.headless=true
