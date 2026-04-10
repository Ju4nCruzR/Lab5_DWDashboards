-- =============================================================================
-- 01_schema.sql — Esquema analitico del Data Warehouse en ClickHouse
--
-- Define las tablas del modelo dimensional (esquema estrella) que conforman
-- la capa OLAP del pipeline. Este archivo es ejecutado automaticamente por
-- ClickHouse al iniciar el contenedor, antes de que el notebook ETL cargue datos.
--
-- Base de datos objetivo : analytics
-- Motor de tablas        : MergeTree (almacenamiento columnar con particionado)
-- =============================================================================


-- ---------------------------------------------------------------------------
-- dim_tiempo
-- Dimension de tiempo con granularidad diaria para el año 2026.
-- El campo dim_tiempo_id almacena el Unix timestamp en segundos de cada fecha
-- y actua como clave de union con la tabla de hechos.
-- ORDER BY sobre dim_tiempo_id permite al motor saltar bloques no relevantes
-- durante las consultas (mecanismo de data skipping).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS analytics.dim_tiempo
(
    dim_tiempo_id  Int64,        -- Unix timestamp en segundos (clave de union)
    fecha          Date,         -- Fecha en formato estandar
    dia_semana     UInt8,        -- 0 = lunes, 6 = domingo (convencion pandas)
    dia            UInt8,        -- Dia del mes (1-31)
    mes            UInt8,        -- Numero de mes (1-12)
    trimestre      UInt8,        -- Trimestre del anio (1-4)
    semestre       UInt8,        -- Semestre del anio (1-2)
    year           UInt16        -- Anio en formato de cuatro digitos
)
ENGINE = MergeTree
ORDER BY dim_tiempo_id;


-- ---------------------------------------------------------------------------
-- fact_sales
-- Tabla de hechos central del modelo estrella. Cada fila representa el
-- subtotal de un producto dentro de una orden de compra especifica.
-- La medida subtotal_por_producto se calcula durante el pipeline ETL como:
--     quantity * (unit_price - discount)
--
-- Particionada por fecha de orden para optimizar consultas por rango de tiempo
-- mediante partition pruning. ORDER BY compuesto mejora las busquedas por
-- orden y producto.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS analytics.fact_sales
(
    dim_tiempo_id       Int64,    -- FK hacia dim_tiempo (Unix timestamp)
    dim_orden_id        Int32,    -- Identificador de la orden de compra
    dim_producto_id     Int32,    -- Identificador del producto
    subtotal_por_producto Float64 -- Medida: quantity * (unit_price - discount)
)
ENGINE = MergeTree
PARTITION BY toDate(toDateTime(dim_tiempo_id))
ORDER BY (dim_orden_id, dim_producto_id);