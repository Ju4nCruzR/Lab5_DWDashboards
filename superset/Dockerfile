# =============================================================================
# Dockerfile — Imagen personalizada de Apache Superset
#
# Extiende la imagen oficial de Superset 3.1.2. Instala las dependencias
# necesarias para establecer conexion con ClickHouse mediante SQLAlchemy,
# y copia el script de inicializacion que configura la base de metadatos,
# el usuario administrador y el registro de la fuente de datos.
#
# ADVERTENCIA: Credenciales de uso didactico exclusivamente.
# =============================================================================

FROM apache/superset:3.1.2

USER root

# Instala dependencias del sistema necesarias para compilar algunas librerias
# Python con extension en C, y luego instala los conectores de Python.
COPY requirements.txt /app/requirements.txt
RUN apt-get update \
    && apt-get install -y build-essential \
    && pip install -r /app/requirements.txt

# Copia el script de inicializacion y le otorga permisos de ejecucion
COPY superset_init.sh /app/superset_init.sh
RUN chmod +x /app/superset_init.sh

USER superset