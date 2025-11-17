-- SOURCE DATABASE (OLTP)
create database oltp
go
use oltp
go

CREATE TABLE src_products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(100),
    category     VARCHAR(50)
);

CREATE TABLE src_stores (
    store_id   INT PRIMARY KEY,
    store_name VARCHAR(100),
    city       VARCHAR(50)
);

select * from src_stores

CREATE TABLE src_inventory_daily (
    inv_id      INT PRIMARY KEY,
    inv_date    DATE,
    product_id  INT,
    store_id    INT,
    qty_on_hand INT
);

-- Sample data
INSERT INTO src_products VALUES
(1, 'Red T-Shirt', 'Clothing'),
(2, 'Blue Jeans',  'Clothing'),
(3, 'Coffee Mug',  'Kitchen');

INSERT INTO src_stores VALUES
(10, 'Main Store', 'Karachi'),
(20, 'Mall Store', 'Lahore');

INSERT INTO src_inventory_daily VALUES
(100, '2025-11-15', 1, 10, 50),
(101, '2025-11-15', 2, 10, 30),
(102, '2025-11-15', 1, 20, 20),
(103, '2025-11-16', 1, 10, 45),
(104, '2025-11-16', 3, 20, 60);
-- DATA WAREHOUSE DATABASE (DW)

-- Dimension: Date
CREATE TABLE DimDate (
    date_key     INT PRIMARY KEY,      -- e.g. 20251115
    full_date    DATE,
    year         INT,
    month        INT,
    day          INT
);

-- Dimension: Product
CREATE TABLE DimProduct (
    product_key  INT IDENTITY(1,1) PRIMARY KEY,
    product_id   INT,                  -- business key from source
    product_name VARCHAR(100),
    category     VARCHAR(50)
);

-- Dimension: Store
CREATE TABLE DimStore (
    store_key   INT IDENTITY(1,1) PRIMARY KEY,
    store_id    INT,                   -- business key from source
    store_name  VARCHAR(100),
    city        VARCHAR(50)
);

-- Fact: Inventory
CREATE TABLE FactInventory (
    date_key    INT,
    product_key INT,
    store_key   INT,
    qty_on_hand INT,
    CONSTRAINT fk_fact_date   FOREIGN KEY (date_key)    REFERENCES DimDate(date_key),
    CONSTRAINT fk_fact_prod   FOREIGN KEY (product_key) REFERENCES DimProduct(product_key),
    CONSTRAINT fk_fact_store  FOREIGN KEY (store_key)   REFERENCES DimStore(store_key)
);

CREATE TABLE stg_products (
    product_id   INT,
    product_name VARCHAR(100),
    category     VARCHAR(50)
);

INSERT INTO stg_products
SELECT * FROM src_products;

-- Clean up if rerun
IF OBJECT_ID('stg_inventory_daily') IS NOT NULL DROP TABLE stg_inventory_daily;
IF OBJECT_ID('stg_products') IS NOT NULL DROP TABLE stg_products;
IF OBJECT_ID('stg_stores') IS NOT NULL DROP TABLE stg_stores;

-- EXTRACT from source to staging
SELECT * INTO stg_products
FROM src_products;

SELECT * INTO stg_stores
FROM src_stores;

SELECT * INTO stg_inventory_daily
FROM src_inventory_daily;

-- Clean up DW tables if rerun
IF OBJECT_ID('FactInventory') IS NOT NULL DROP TABLE FactInventory;
IF OBJECT_ID('DimDate') IS NOT NULL DROP TABLE DimDate;
IF OBJECT_ID('DimProduct') IS NOT NULL DROP TABLE DimProduct;
IF OBJECT_ID('DimStore') IS NOT NULL DROP TABLE DimStore;

-- DIMENSION TABLES

CREATE TABLE DimDate (
    date_key  INT PRIMARY KEY,     -- e.g. 20251115
    full_date DATE,
    year      INT,
    month     INT,
    day       INT
);

CREATE TABLE DimProduct (
    product_key  INT IDENTITY(1,1) PRIMARY KEY,
    product_id   INT,              -- business key
    product_name VARCHAR(100),
    category     VARCHAR(50)
);

CREATE TABLE DimStore (
    store_key  INT IDENTITY(1,1) PRIMARY KEY,
    store_id   INT,               -- business key
    store_name VARCHAR(100),
    city       VARCHAR(50)
);

CREATE TABLE FactInventory (
    date_key    INT,
    product_key INT,
    store_key   INT,
    qty_on_hand INT,
    CONSTRAINT fk_fact_date   FOREIGN KEY (date_key)    REFERENCES DimDate(date_key),
    CONSTRAINT fk_fact_prod   FOREIGN KEY (product_key) REFERENCES DimProduct(product_key),
    CONSTRAINT fk_fact_store  FOREIGN KEY (store_key)   REFERENCES DimStore(store_key)
);


INSERT INTO DimDate (date_key, full_date, year, month, day)
SELECT
    CAST(CONVERT(VARCHAR(8), inv_date, 112) AS INT) AS date_key,  -- YYYYMMDD
    inv_date,
    YEAR(inv_date)  AS year,
    MONTH(inv_date) AS month,
    DAY(inv_date)   AS day
FROM (
    SELECT DISTINCT inv_date
    FROM stg_inventory_daily
) AS d;

INSERT INTO DimProduct (product_id, product_name, category)
SELECT DISTINCT
    product_id,
    product_name,
    category
FROM stg_products;

INSERT INTO DimStore (store_id, store_name, city)
SELECT DISTINCT
    store_id,
    store_name,
    city
FROM stg_stores;


INSERT INTO FactInventory (date_key, product_key, store_key, qty_on_hand)
SELECT
    d.date_key,
    p.product_key,
    s.store_key,
    i.qty_on_hand
FROM stg_inventory_daily i
JOIN DimDate    d ON d.full_date = i.inv_date
JOIN DimProduct p ON p.product_id = i.product_id
JOIN DimStore   s ON s.store_id   = i.store_id;

SELECT * FROM DimDate;
SELECT * FROM DimProduct;
SELECT * FROM DimStore;
SELECT * FROM FactInventory;
