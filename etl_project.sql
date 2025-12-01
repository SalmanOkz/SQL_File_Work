CREATE DATABASE BanggoodProducts;
GO

USE BanggoodProducts;
GO

CREATE TABLE Products (
    category VARCHAR(255),
    name TEXT,
    price_raw FLOAT,
    rating_raw FLOAT,
    reviews_raw INT,
    url VARCHAR(1000)
);
GO

SELECT category, 
       (COUNT(CASE WHEN reviews_raw > 0 THEN 1 END) / COUNT(*)) * 100 AS stock_availability_percentage
FROM Products
GROUP BY category;

SELECT category, 
       name, 
       reviews_raw
FROM Products
WHERE reviews_raw > 0
ORDER BY reviews_raw DESC;

SELECT category, 
       COUNT(*) AS product_count
FROM Products
GROUP BY category;
SELECT category, 
       AVG(rating_raw) AS average_rating
FROM Products
GROUP BY category;
SELECT category, 
       AVG(price_raw) AS average_price
FROM Products
GROUP BY category;
