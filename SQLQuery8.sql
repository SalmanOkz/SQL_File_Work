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



use Store


create table my_table(
my_id int primary key IDENTITY,
my_name varchar(20),
)


-- FOREIGN KEY(maintain integrity) refrecial integrity between table
create schema procurement
CREATE TABLE procurement.vendor_groups (
    group_id INT IDENTITY PRIMARY KEY,
    group_name VARCHAR (100) NOT NULL
);

CREATE TABLE procurement.vendors (
        vendor_id INT IDENTITY PRIMARY KEY,
        vendor_name VARCHAR(100) NOT NULL,
        group_id INT NOT NULL,
);

DROP TABLE procurement.vendors;

CREATE TABLE procurement.vendors (
        vendor_id INT IDENTITY PRIMARY KEY,
        vendor_name VARCHAR(100) NOT NULL,
        group_id INT NOT NULL,
        CONSTRAINT fk_group FOREIGN KEY (group_id) 
        REFERENCES procurement.vendor_groups(group_id)
        on update cascade
        on delete no action
);

INSERT INTO procurement.vendor_groups(group_name)
VALUES('Third-Party Vendors'),
      ('Interco Vendors'),
      ('One-time Vendors');


INSERT INTO procurement.vendors(vendor_name, group_id)
VALUES('ABC Corp',1);

INSERT INTO procurement.vendors(vendor_name, group_id)
VALUES('XYZ Corp',1);

-- 1. First insert into parent table (vendor_groups)
INSERT INTO procurement.vendor_groups (group_name)
VALUES 
    ('IT Suppliers'),
    ('Office Supplies'),
    ('Construction Materials'),
    ('Food Services'),
    ('Cleaning Supplies');
GO

-- Check what was inserted (for reference)
SELECT * FROM procurement.vendor_groups;


-- 2. Now insert into child table (vendors) with valid group_id values
INSERT INTO procurement.vendors (vendor_name, group_id)
VALUES 
    -- IT Suppliers (group_id = 1)
    ('Dell Technologies', 1),
    ('Microsoft Corporation', 1),
    ('HP Inc.', 1),
    ('Cisco Systems', 1),
    
    -- Office Supplies (group_id = 2)
    ('Staples Inc.', 2),
    ('Office Depot', 2),
    ('3M Company', 2),
    
    -- Construction Materials (group_id = 3)
    ('Home Depot', 3),
    ('Lowe''s Companies', 3),
    ('Sherwin-Williams', 3),
    
    -- Food Services (group_id = 4)
    ('Sysco Corporation', 4),
    ('US Foods', 4),
    ('Gordon Food Service', 4),
    
    -- Cleaning Supplies (group_id = 5)
    ('Ecolab Inc.', 5),
    ('Procter & Gamble', 5),
    ('Clorox Company', 5);
GO

-- Verify the data
SELECT * FROM procurement.vendors;

-- This will FAIL because group_id 99 doesn't exist in vendor_groups
INSERT INTO procurement.vendors (vendor_name, group_id)
VALUES ('Test Vendor', 99);

-- Unique
CREATE TABLE inventory (
    product_id INT,
    warehouse_id INT,
    location_code VARCHAR(10),
    quantity INT,
    CONSTRAINT UQ_Product_Location 
    UNIQUE (product_id, warehouse_id, location_code)
);

-- Valid inserts:
INSERT INTO inventory VALUES (101, 1, 'A1', 50);  -- OK
INSERT INTO inventory VALUES (101, 1, 'A2', 30);  -- OK (different location)
INSERT INTO inventory VALUES (101, 2, 'A1', 20);  -- OK (different warehouse)

-- This will FAIL (duplicate combination):
INSERT INTO inventory VALUES (101, 1, 'A1', 10);  -- Error: violates unique constraint

select * from [sales].[orders]

select 
    case order_status
    when 1 then 'pending'
    when 2 then 'processing'
    when 3 then 'rejected'
    when 4 then 'completed'
    end as modified_order_status,
    count(*) as or_status_count

from [sales].[orders]
group by 
    case order_status
    when 1 then 'pending'
    when 2 then 'processing'
    when 3 then 'rejected'
    when 4 then 'completed'
    end;

SELECT    
    o.order_id, 
    SUM(quantity * list_price) order_value,
    case 
        when sum(quantity * list_price) <=  500  then 'very low'
        when sum(quantity * list_price) > 500 and sum(quantity * list_price)  <= 1000 then 'low'
        when sum(quantity * list_price) > 1000 and sum(quantity * list_price) <= 5000 then 'medium'
        when sum(quantity * list_price) > 5000 and sum(quantity * list_price) <= 10000 then 'high'
        when sum(quantity * list_price) > 10000 then 'very high'
        end as order_priority

from sales.orders as o
join sales.order_items as oi
on o.order_id = oi.order_id
where year(order_date) = 2018
group by o.order_id



-- coalesce

select coalesce('Hi',Null) -- it will not add null if value is givin

--phone --> NULL ('N/A')

select coalesce(phone,'N/A') from sales.customers


-- null-if
-- lhs != rhs (lhs)
-- lhs == rhs (null)
select nullif(10,11)
SELECT 
    NULLIF('Hello', 'Hi') result;

DROP TABLE IF EXISTS t1;
CREATE TABLE t1 (
    id INT IDENTITY(1, 1), 
    a  INT, 
    b  INT, 
    PRIMARY KEY(id)
);

INSERT INTO
    t1(a,b)
VALUES
    (1,1),
    (1,2),
    (1,3),
    (2,1),
    (1,2),
    (1,3),
    (2,1),
    (2,2);



-- handle duplicate
-- we will get non duplicate if we want duplicate then we will have > 1
select a,b, 
    count(*) as records_count 
        from t1 group by a,b 
    having count(*) < 2

select * from t1

-- First, SELECT to see what WOULD be deleted
with cte_duplocate as (
select *, ROW_NUMBER() over(
    partition by a,b
    order by a,b

) as rn 
from t1
)
select id,a,b from cte_duplocate
where rn > 1




create view production.product_catalog as 
select category_name,product_name,model_year,list_price,quantity from production.brands b
join production.categories c on b.brand_id = c.category_id
join production.products p on p.product_id = b.brand_id
join production.stocks s on s.store_id = p.product_id


seleCt * FROM [production].[product_catalog]

-- listing the view

select * from sys.views
select * from sys.objects where type = 'v' -- oth quries are doing same thing

-- get ddl
select * from sys.sql_modules

drop view [production].[product_catalog]


