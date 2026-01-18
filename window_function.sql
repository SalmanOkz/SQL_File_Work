use Store

CREATE VIEW sales.vw_staff_sales(
    staff_id, 
    year, 
    net_sales
) AS
SELECT 
    staff_id, 
    YEAR(order_date), 
    ROUND(SUM(quantity*list_price*(1-discount)),0)
FROM 
    sales.orders o
INNER JOIN sales.order_items i on i.order_id = o.order_id
WHERE 
    staff_id IS NOT NULL
GROUP BY 
    staff_id, 
    YEAR(order_date);


-- Window Function
-- function name
-- over
-- partition by optimol if you dont apply it will set it on all the data
-- order by


SELECT 
    CONCAT_WS(' ',first_name,last_name) full_name,
    net_sales, 
    year,
    CUME_DIST() OVER (
        PARTITION BY year
        ORDER BY net_sales DESC
    ) cume_dist
FROM 
    sales.vw_staff_sales t
INNER JOIN sales.staffs m on m.staff_id = t.staff_id
WHERE 
    year IN (2016,2017);

-- Dense ranke and rank

CREATE TABLE sales.dense_rank_demo (
	v VARCHAR(10)
);
	
INSERT INTO sales.dense_rank_demo(v)
VALUES('A'),('B'),('B'),('C'),('C'),('D'),('E');
	
SELECT * FROM sales.dense_rank_demo;

SELECT
	v,
	DENSE_RANK() OVER (
		ORDER BY v
	) my_dense_rank,
	RANK() OVER (
		ORDER BY v
	) my_rank
FROM
	sales.dense_rank_demo;

-- PERCENT_RANK()

SELECT 
    CONCAT_WS(' ',first_name,last_name) full_name,
    net_sales, 
    PERCENT_RANK() OVER (
        ORDER BY net_sales DESC
    ) percent_rank
FROM 
    sales.vw_staff_sales t
INNER JOIN sales.staffs m on m.staff_id = t.staff_id
WHERE 
    YEAR = 2016;

    -- Ntile

    CREATE TABLE sales.ntile_demo (
	v INT NOT NULL
);
	
INSERT INTO sales.ntile_demo(v) 
VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9),(10);
	
	
SELECT * FROM sales.ntile_demo;
-- want it does is comtumise ranking

SELECT 
	v, 
	NTILE (4) OVER (
		ORDER BY v
	) buckets
FROM 
	sales.ntile_demo;


-- First_value window function

CREATE VIEW 
    sales.vw_category_sales_volume 
AS
SELECT 
    category_name, 
    YEAR(order_date) year, 
    SUM(quantity) qty
FROM 
    sales.orders o
INNER JOIN sales.order_items i 
    ON i.order_id = o.order_id
INNER JOIN production.products p 
    ON p.product_id = i.product_id
INNER JOIN production.categories c 
    ON c.category_id = p.product_id
GROUP BY 
    category_name, 
    YEAR(order_date);


SELECT 
    *
FROM 
    sales.vw_category_sales_volume
ORDER BY 
    year, 
    category_name, 
    qty;


SELECT 
    category_name,
    year,
    qty,
    FIRST_VALUE(category_name) OVER(
        ORDER BY qty
    ) lowest_sales_volume
FROM 
    sales.vw_category_sales_volume
WHERE
    year = 2017;

