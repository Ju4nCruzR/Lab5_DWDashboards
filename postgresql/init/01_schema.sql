-- =============================================================================
-- 01_schema.sql
-- Definicion del esquema relacional (DDL) para la base de datos transaccional
-- retail_db. Modela el dominio de ventas minoristas con clientes, empleados,
-- productos, ordenes y entidades auxiliares de soporte geografico y logistico.
--
-- Motor objetivo : PostgreSQL 14
-- Ejecutado por  : docker-entrypoint-initdb.d (automatico al iniciar el contenedor)
-- =============================================================================


-- ---------------------------------------------------------------------------
-- REGION
-- Catalogo de regiones geograficas. Referenciada por territories.
-- ---------------------------------------------------------------------------
CREATE TABLE region (
    region_id   SERIAL       PRIMARY KEY,
    region_name VARCHAR(50)  NOT NULL
);


-- ---------------------------------------------------------------------------
-- TERRITORIES
-- Territorios de venta asociados a una region. Referenciados por
-- employee_territories para asignar zonas a empleados.
-- ---------------------------------------------------------------------------
CREATE TABLE territories (
    territory_id          VARCHAR(10)  PRIMARY KEY,
    territory_description VARCHAR(50)  NOT NULL,
    region_id             INTEGER      NOT NULL REFERENCES region(region_id)
);


-- ---------------------------------------------------------------------------
-- CATEGORIES
-- Categorias de productos (e.g. Beverages, Dairy). Referenciada por products.
-- ---------------------------------------------------------------------------
CREATE TABLE categories (
    category_id   SERIAL       PRIMARY KEY,
    category_name VARCHAR(50)  NOT NULL,
    description   TEXT
);


-- ---------------------------------------------------------------------------
-- SUPPLIERS
-- Proveedores de los productos del catalogo. Referenciada por products.
-- ---------------------------------------------------------------------------
CREATE TABLE suppliers (
    supplier_id  SERIAL       PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    city         VARCHAR(50),
    country      VARCHAR(50)
);


-- ---------------------------------------------------------------------------
-- SHIPPERS
-- Empresas de transporte utilizadas para el despacho de ordenes.
-- Referenciada por orders (ship_via).
-- ---------------------------------------------------------------------------
CREATE TABLE shippers (
    shipper_id   SERIAL       PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    phone        VARCHAR(30)
);


-- ---------------------------------------------------------------------------
-- CUSTOMERS
-- Clientes que realizan ordenes de compra. La clave primaria es un codigo
-- alfanumerico de negocio (e.g. C0001).
-- ---------------------------------------------------------------------------
CREATE TABLE customers (
    customer_id    VARCHAR(10)  PRIMARY KEY,
    company_name   VARCHAR(100) NOT NULL,
    contact_name   VARCHAR(100),
    contact_title  VARCHAR(50),
    address        VARCHAR(150),
    city           VARCHAR(50),
    region         VARCHAR(50),
    postal_code    VARCHAR(20),
    country        VARCHAR(50),
    phone          VARCHAR(30),
    fax            VARCHAR(30)
);


-- ---------------------------------------------------------------------------
-- CUSTOMER_DEMOGRAPHICS
-- Segmentos demograficos opcionales asociados a clientes.
-- ---------------------------------------------------------------------------
CREATE TABLE customer_demographics (
    customer_type_id   VARCHAR(10) PRIMARY KEY,
    customer_desc      TEXT
);


-- ---------------------------------------------------------------------------
-- CUSTOMER_CUSTOMER_DEMO
-- Tabla de asociacion many-to-many entre customers y customer_demographics.
-- ---------------------------------------------------------------------------
CREATE TABLE customer_customer_demo (
    customer_id      VARCHAR(10) NOT NULL REFERENCES customers(customer_id),
    customer_type_id VARCHAR(10) NOT NULL REFERENCES customer_demographics(customer_type_id),
    PRIMARY KEY (customer_id, customer_type_id)
);


-- ---------------------------------------------------------------------------
-- EMPLOYEES
-- Empleados del area de ventas. La clave primaria es generada por secuencia.
-- hire_date y birth_date son relevantes para analisis de antiguedad y perfil.
-- ---------------------------------------------------------------------------
CREATE TABLE employees (
    employee_id  SERIAL      PRIMARY KEY,
    last_name    VARCHAR(50) NOT NULL,
    first_name   VARCHAR(50) NOT NULL,
    title        VARCHAR(50),
    birth_date   DATE,
    hire_date    DATE
);


-- ---------------------------------------------------------------------------
-- EMPLOYEE_TERRITORIES
-- Asignacion de territorios a empleados (relacion many-to-many).
-- ---------------------------------------------------------------------------
CREATE TABLE employee_territories (
    employee_id  INTEGER     NOT NULL REFERENCES employees(employee_id),
    territory_id VARCHAR(10) NOT NULL REFERENCES territories(territory_id),
    PRIMARY KEY (employee_id, territory_id)
);


-- ---------------------------------------------------------------------------
-- PRODUCTS
-- Catalogo de productos disponibles para la venta. unit_price refleja el
-- precio base; el precio definitivo por orden se registra en order_details.
-- ---------------------------------------------------------------------------
CREATE TABLE products (
    product_id      SERIAL          PRIMARY KEY,
    product_name    VARCHAR(100)    NOT NULL,
    supplier_id     INTEGER         REFERENCES suppliers(supplier_id),
    category_id     INTEGER         REFERENCES categories(category_id),
    unit_price      NUMERIC(10, 2)  NOT NULL DEFAULT 0,
    units_in_stock  INTEGER         NOT NULL DEFAULT 0
);


-- ---------------------------------------------------------------------------
-- ORDERS
-- Cabecera de cada orden de compra. Relaciona cliente, empleado y transportista.
-- freight representa el costo de envio negociado para esa orden.
-- ---------------------------------------------------------------------------
CREATE TABLE orders (
    order_id     SERIAL          PRIMARY KEY,
    customer_id  VARCHAR(10)     REFERENCES customers(customer_id),
    employee_id  INTEGER         REFERENCES employees(employee_id),
    order_date   DATE            NOT NULL,
    ship_via     INTEGER         REFERENCES shippers(shipper_id),
    freight      NUMERIC(10, 2)  NOT NULL DEFAULT 0
);


-- ---------------------------------------------------------------------------
-- ORDER_DETAILS
-- Lineas de detalle de cada orden. Almacena el precio pactado, la cantidad
-- y el descuento aplicado al momento de la transaccion. La clave primaria
-- compuesta (order_id, product_id) garantiza unicidad por producto por orden.
-- ---------------------------------------------------------------------------
CREATE TABLE order_details (
    order_id    INTEGER        NOT NULL REFERENCES orders(order_id),
    product_id  INTEGER        NOT NULL REFERENCES products(product_id),
    unit_price  NUMERIC(10, 2) NOT NULL,
    quantity    SMALLINT       NOT NULL,
    discount    NUMERIC(4, 2)  NOT NULL DEFAULT 0,
    PRIMARY KEY (order_id, product_id)
);