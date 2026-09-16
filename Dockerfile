# Usar imagen ligera oficial de Python
FROM python:3.11-slim

# Evitar escritura de archivos .pyc y habilitar buffering de logs
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Instalar dependencias del sistema mínimas requeridas si fuese necesario
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copiar requerimientos e instalar dependencias Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el código de la aplicación
COPY . .

# Exponer puertos: 5000 (API Flask) y 8501 (Streamlit Web)
EXPOSE 5000 8501

# Dar permisos de ejecución al script de arranque
RUN chmod +x entrypoint.sh

# Punto de entrada
ENTRYPOINT ["./entrypoint.sh"]
