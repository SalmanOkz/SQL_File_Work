-- Q1. List top 5 customers by total order amount.
-- Retrieve the top 5 customers who have spent the most across all sales orders. 
-- Show CustomerID, CustomerName, and TotalSpent.

select top 5 c.CustomerID,c.Name,sum(o.TotalAmount) as total_spent
	from [dbo].[Customer] c
join [dbo].[SalesOrder] s on s.CustomerID = c.CustomerID
join [dbo].[SalesOrderDetail] o on o.OrderID = s.OrderID
group by c.CustomerID,c.Name 
order by total_spent  desc

-- Q2. Find the number of products supplied by each supplier.
-- Display SupplierID, SupplierName, and ProductCount. 
-- Only include suppliers that have more than 10 products.

select s.SupplierID,s.Name,count(DISTINCT pd.Quantity) no_of_product
	from [dbo].[Supplier] s
join [dbo].[PurchaseOrder]  p on s.SupplierID = p.SupplierID
join [dbo].[PurchaseOrderDetail] pd on pd.OrderID = p.OrderID 
where pd.Quantity > 10
group by s.SupplierID,s.Name
having count(distinct pd.Quantity) > 10
order by no_of_product desc


-- Q3. Identify products that have been ordered but never returned.
-- Show ProductID, ProductName, and total order quantity.


select p.ProductID,p.Name, sum(s.Quantity) as total_order_quantity
    from [dbo].[Product] p
join [dbo].[SalesOrderDetail] s on s.ProductID = p.ProductID
WHERE NOT EXISTS (
    SELECT 1
    FROM ReturnDetail r
    WHERE r.ProductID = p.ProductID
)
group by p.ProductID,p.Name


-- Q4. For each category, find the most expensive product.
-- Display CategoryID, CategoryName, ProductName, and Price. 
-- Use a subquery to get the max price per category.

select  c.CategoryID,
        c.Name, 
        p.Name,
        p.Price 
    from Category c
join 
    Product p 
        on p.CategoryID = c.CategoryID
join (
    select 
        CategoryID,max(Price) as max_price from
Product 
group by CategoryID

) mx 
    on mx.CategoryID = p.CategoryID
    and mx.max_price = p.Price
order by c.CategoryID


-- Q5. List all sales orders with customer name, product name, category, and supplier.
-- For each sales order, display:
-- OrderID, CustomerName, ProductName, CategoryName, SupplierName, and Quantity.


WITH ProductSupplier AS (
    SELECT
        pod.ProductID,
        MIN(po.SupplierID) AS SupplierID
    FROM [dbo].[PurchaseOrderDetail] pod
    JOIN [dbo].[PurchaseOrder] po
        ON po.OrderID = pod.OrderID
    GROUP BY pod.ProductID
)
SELECT
    so.OrderID,
    c.Name AS CustomerName,
    p.Name AS ProductName,
    cat.Name AS CategoryName,
    sup.Name AS SupplierName,
    sod.Quantity
FROM [dbo].[SalesOrderDetail] sod
JOIN [dbo].[SalesOrder] so
    ON so.OrderID = sod.OrderID
JOIN [dbo].[Customer] c
    ON c.CustomerID = so.CustomerID
JOIN [dbo].[Product] p
    ON p.ProductID = sod.ProductID
JOIN [dbo].[Category] cat
    ON cat.CategoryID = p.CategoryID
LEFT JOIN ProductSupplier ps
    ON ps.ProductID = p.ProductID
LEFT JOIN [dbo].[Supplier] sup
    ON sup.SupplierID = ps.SupplierID
ORDER BY so.OrderID, p.Name;



-- Q6. Find all shipments with details of warehouse, manager, and products shipped.
-- Display:ShipmentID, WarehouseName, ManagerName, ProductName, QuantityShipped, and TrackingNumber.


