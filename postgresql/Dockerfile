# =============================================================================
# Dockerfile — Imagen personalizada de PostgreSQL para retail_db
#
# Extiende la imagen oficial de PostgreSQL 14. Define las variables de entorno
# necesarias para crear la base de datos transaccional y copia los scripts de
# inicializacion al directorio que PostgreSQL ejecuta automaticamente al
# arrancar el contenedor por primera vez.
#
# ADVERTENCIA: Las credenciales definidas aqui son exclusivas para uso didactico.
# En entornos de produccion deben gestionarse mediante un sistema IAM externo.
# =============================================================================

FROM postgres:14

# Nombre de la base de datos, usuario y contrasena del rol de conexion
ENV POSTGRES_DB=retail_db
ENV POSTGRES_USER=lab_user
ENV POSTGRES_PASSWORD=lab_pass

# Copia el esquema DDL y los datos de prueba al directorio de inicializacion.
# PostgreSQL ejecuta en orden alfabetico todos los archivos .sql que encuentre
# en este directorio durante el primer inicio del contenedor.
COPY ./init/ /docker-entrypoint-initdb.d/