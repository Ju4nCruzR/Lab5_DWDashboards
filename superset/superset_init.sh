#!/bin/bash
# =============================================================================
# superset_init.sh — Script de inicializacion de Apache Superset
#
# Ejecutado como comando de arranque del contenedor. Realiza en orden:
#   1. Migracion del esquema interno de metadatos de Superset (SQLite).
#   2. Creacion del usuario administrador con credenciales predefinidas.
#   3. Inicializacion de roles y permisos por defecto.
#   4. Registro programatico de la conexion a ClickHouse como fuente de datos.
#   5. Arranque del servidor web de Superset en el puerto 8088.
#
# ADVERTENCIA: Credenciales de uso didactico exclusivamente.
# =============================================================================

# Inicializa y migra la base de metadatos interna de Superset
superset db upgrade

# Crea el usuario administrador de la interfaz web
superset fab create-admin \
    --username admin \
    --firstname Admin \
    --lastname User \
    --email admin@superset.com \
    --password admin

# Inicializa roles y permisos estandar de Superset
superset init

# Registra la conexion a ClickHouse directamente en la base de metadatos
# de Superset mediante el shell interactivo de Flask. Esto evita la
# configuracion manual desde la interfaz web en cada reinicio del contenedor.
superset shell <<EOF
from superset import db
from superset.models.core import Database

conexion_existente = db.session.query(Database).filter_by(database_name="ClickHouse").first()

if not conexion_existente:
    db.session.add(Database(
        database_name="ClickHouse",
        sqlalchemy_uri="clickhouse+http://admin:admin123@clickhouse_server:8123/analytics"
    ))
    db.session.commit()
EOF

# Arranca el servidor web de Superset
superset run -h 0.0.0.0 -p 8088