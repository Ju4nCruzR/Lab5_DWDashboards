# Lab 5 — Data Warehouse & Dashboard

Laboratorio end-to-end de ingeniería de datos para el curso **Análisis de Datos** — Pontificia Universidad Javeriana.

El pipeline inicia en una base de datos transaccional PostgreSQL, transforma los datos mediante un notebook de Jupyter con PyArrow, los almacena en un Data Warehouse columnar ClickHouse, y los expone en un dashboard interactivo con Apache Superset.

---

## Arquitectura

```
retail_db          Jupyter Notebook        analytics            Dashboard
(PostgreSQL) ────► (PyArrow / pandas) ────► (ClickHouse) ──────► (Superset)
   OLTP               ETL / ELT               OLAP               BI / Viz
```

Cada componente corre en su propio contenedor Docker/Podman, orquestados con un único `compose.yaml`.

---

## Stack tecnológico

| Capa | Tecnología | Versión |
|---|---|---|
| Base de datos transaccional | PostgreSQL | 14 |
| Orquestación / transformación | Jupyter Notebook + pandas + PyArrow | Python 3.10 |
| Data Warehouse | ClickHouse | 24.8 |
| Dashboard / BI | Apache Superset | 3.1.2 |
| ORM / conexión Python | SQLAlchemy + clickhouse-connect | — |

---

## Estructura del proyecto

```
Lab5_DWDashboards/
│
│   compose.yaml
│   README.md
│
├── clickhouse/
│   ├── config/
│   │   ├── admin-user.xml
│   │   └── default-user.xml
│   └── init/
│       ├── 01_schema.sql        ← esquema de tablas analíticas (dim + fact)
│       └── 02_sample_data.sql   ← datos de prueba para ClickHouse
│
├── notebooks/
│   ├── lab05_clickhouse_lab.ipynb   ← notebook principal del pipeline ETL
│   └── requirements.txt
│
├── postgresql/
│   │   Dockerfile
│   └── init/
│       ├── 01_schema.sql        ← DDL de retail_db
│       └── 02_sample_data.sql   ← datos sintéticos transaccionales
│
└── superset/
    ├── Dockerfile
    ├── requirements.txt
    └── superset_init.sh
```

---

## Modelo analítico (esquema estrella)

### `dim_tiempo`
| Campo | Tipo | Descripción |
|---|---|---|
| `dim_tiempo_id` | Int64 (unix ts) | Clave primaria / ORDER BY |
| `fecha` | Date | Fecha completa |
| `dia_semana` | UInt8 | 0 = lunes … 6 = domingo |
| `dia` | UInt8 | Día del mes |
| `mes` | UInt8 | Número de mes |
| `trimestre` | UInt8 | 1–4 |
| `semestre` | UInt8 | 1–2 |
| `year` | UInt16 | Año |

### `fact_sales`
| Campo | Tipo | Descripción |
|---|---|---|
| `dim_tiempo_id` | Int64 | FK → dim_tiempo |
| `dim_orden_id` | Int32 | FK → orders |
| `dim_producto_id` | Int32 | FK → products |
| `subtotal_por_producto` | Float64 | `quantity × (unit_price − discount)` |

---

## Actividades del laboratorio

1. **Crear la base de datos transaccional** — PostgreSQL con `retail_db` (clientes, empleados, órdenes, productos, categorías y más).
2. **Crear el Data Warehouse en ClickHouse** — tablas columnares, benchmark de rendimiento con 100 M de filas.
3. **Creación del esquema analítico** — dimensión de tiempo + tabla de hechos de ventas.
4. **Pipeline ETL** — extracción desde PostgreSQL, transformación con PyArrow, carga en ClickHouse.
5. **Dashboard en Superset** — datasets virtuales (JOIN fact + dim), gráfico de ventas por día de la semana, dashboard final.

### Pregunta de negocio que responde el lab
> *¿En qué días de la semana se concentran las ventas totales?*  
> Resultado: tabla y gráfico de `dia_semana` vs `SUM(subtotal_por_producto)`.

---

## Cómo levantar el ambiente

### Pre-requisitos
- Podman (o Docker) con soporte para `compose`
- Python 3.10+ (solo para desarrollo local fuera de contenedores)

### Pasos

```bash
# 1. Iniciar el motor de Podman (si aplica)
podman machine start

# 2. Clonar el repositorio
git clone https://github.com/<tu-usuario>/Lab5_DWDashboards.git
cd Lab5_DWDashboards

# 3. Levantar todos los servicios
podman compose up --build

# 4. Acceder a los servicios
#    Jupyter Notebook  → http://localhost:8888  (token: lab5)
#    ClickHouse HTTP   → http://localhost:8123
#    Superset          → http://localhost:8088  (admin / admin)
```

---

## Credenciales de desarrollo (solo uso local / didáctico)

| Servicio | Usuario | Contraseña |
|---|---|---|
| PostgreSQL | `lab_user` | `lab_pass` |
| ClickHouse | `admin` | `admin123` |
| Superset | `admin` | `admin` |
| Jupyter | — | `lab5` (token) |

> ⚠️ **Nunca usar estas credenciales en producción.** Para ambientes productivos, gestionar secretos con un sistema IAM (AWS IAM, Microsoft Entra ID, HashiCorp Vault, etc.).

---

## Ejercicios opcionales

1. Ventas en días festivos (adicionales al domingo).
2. Categorías de productos que representan el 50 % del total de ventas (gráfico Pareto).
3. Agrupación de clientes similares por ítems comprados — distancia de Jaccard y similitud del coseno, para semanas 1–52.
4. Rentabilidad de producto por región y territorio para un periodo `ini_date` / `end_date`.

---

## Referencias

- Abadi, D. (2008). *Query Execution in Column-Oriented Database Systems*. MIT.
- Abadi, D. et al. (2009). *Column-Oriented Database Systems*. Foundations and Trends in Databases.
- Boncz, P. et al. (2005). *MonetDB/X100: Hyper-Pipelining Query Execution*. CIDR.
- Kimball & Ross (2013). *The Data Warehouse Toolkit*.
- Lemire, D. et al. (2015). *Decoding billions of integers per second through vectorization*.
- Neumann, T. (2011). *Efficiently Compiling Efficient Query Plans for Modern Hardware*. VLDB.
- Stonebraker et al. (2007). *The End of an Architectural Era*.