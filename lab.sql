

CREATE TABLE DimDates (
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    DayOfMonth INT,
    DayName VARCHAR(10),
    WeekNumber INT,
    MonthNumber INT,
    MonthName VARCHAR(10),
    QuarterNumber INT,
    QuarterName VARCHAR(10),
    Year INT,
    IsWeekend BIT,
    IsHoliday BIT,
    HolidayName VARCHAR(50),
    FiscalMonth INT,
    FiscalQuarter INT,
    FiscalYear INT
);
CREATE TABLE DimProducts (
    ProductKey INT PRIMARY KEY,
    ProductID INT,
    ProductName VARCHAR(100),
    ProductSKU VARCHAR(50),
    CategoryID INT,
    CategoryName VARCHAR(50),
    SubCategoryID INT,
    SubCategoryName VARCHAR(50),
    BrandName VARCHAR(50),
    UnitPrice DECIMAL(10,2),
    CostPrice DECIMAL(10,2),
    SupplierID INT,
    SupplierName VARCHAR(100),
    ProductStatus VARCHAR(20),
    StartDate DATE,
    EndDate DATE,
    IsCurrent BIT
);
CREATE TABLE DimCustomer (
    CustomerKey INT PRIMARY KEY,
    CustomerID INT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    FullName VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(200),
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50),
    PostalCode VARCHAR(20),
    CustomerType VARCHAR(20), -- B2B, B2C, Retail, Wholesale
    CustomerSegment VARCHAR(30), -- Premium, Regular, New
    AcquisitionDate DATE,
    CustomerStatus VARCHAR(20)
);
CREATE TABLE DimSalesPerson (
    SalesPersonKey INT PRIMARY KEY,
    SalesPersonID INT,
    SalesPersonName VARCHAR(100),
    Region VARCHAR(50),
    Territory VARCHAR(50),
    HireDate DATE,
    ManagerID INT,
    ManagerName VARCHAR(100),
    CommissionRate DECIMAL(5,2),
    SalesPersonLevel VARCHAR(20)
);
CREATE TABLE DimStores (
    StoreKey INT PRIMARY KEY,
    StoreID INT,
    StoreName VARCHAR(100),
    StoreType VARCHAR(30), -- Online, Physical, Franchise
    Address VARCHAR(200),
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50),
    StoreSize DECIMAL(10,2),
    OpenDate DATE,
    CloseDate DATE,
    ManagerName VARCHAR(100),
    StoreStatus VARCHAR(20)
);
CREATE TABLE FactSales (
    SalesKey BIGINT PRIMARY KEY,
    DateKey INT,
    ProductKey INT,
    CustomerKey INT,
    SalesPersonKey INT,
    StoreKey INT,
    OrderID VARCHAR(50),
    OrderDate DATE,
    ShipDate DATE,
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    DiscountAmount DECIMAL(10,2),
    TaxAmount DECIMAL(10,2),
    ShippingCost DECIMAL(10,2),
    TotalAmount DECIMAL(10,2),
    NetAmount DECIMAL(10,2), -- TotalAmount - DiscountAmount
    ProfitAmount DECIMAL(10,2), -- NetAmount - (CostPrice * Quantity)
    ReturnQuantity INT,
    ReturnAmount DECIMAL(10,2),
    PromotionID INT,
    PaymentMethod VARCHAR(30),
    
    -- Foreign Keys
    FOREIGN KEY (DateKey) REFERENCES DimDates(DateKey),
    FOREIGN KEY (ProductKey) REFERENCES DimProducts(ProductKey),
    FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
    FOREIGN KEY (SalesPersonKey) REFERENCES DimSalesPerson(SalesPersonKey),
    FOREIGN KEY (StoreKey) REFERENCES DimStores(StoreKey),
    
    -- Indexes for Performance
    INDEX IX_FactSales_DateKey (DateKey),
    INDEX IX_FactSales_ProductKey (ProductKey),
    INDEX IX_FactSales_CustomerKey (CustomerKey),
    INDEX IX_FactSales_StoreKey (StoreKey),
    INDEX IX_FactSales_OrderDate (OrderDate)
);

CREATE TABLE DimPromotion (
    PromotionKey INT PRIMARY KEY,
    PromotionID INT,
    PromotionName VARCHAR(100),
    PromotionType VARCHAR(30), -- Discount, BOGO, Clearance
    DiscountPercentage DECIMAL(5,2),
    DiscountAmount DECIMAL(10,2),
    StartDate DATE,
    EndDate DATE,
    MinimumPurchase DECIMAL(10,2),
    IsActive BIT
);
CREATE TABLE FactSalesTarget (
    TargetKey INT PRIMARY KEY,
    DateKey INT,
    ProductKey INT,
    SalesPersonKey INT,
    StoreKey INT,
    TargetAmount DECIMAL(10,2),
    TargetQuantity INT,
    TargetMonth INT,
    TargetYear INT,
    
    FOREIGN KEY (DateKey) REFERENCES DimDates(DateKey),
    FOREIGN KEY (ProductKey) REFERENCES DimProducts(ProductKey),
    FOREIGN KEY (SalesPersonKey) REFERENCES DimSalesPerson(SalesPersonKey),
    FOREIGN KEY (StoreKey) REFERENCES DimStores(StoreKey)
);


-- Basic XML Generation
SELECT 
    ProductID AS '@ID',
    ProductName,
    UnitPrice
FROM Products
FOR XML PATH('Product'), ROOT('Products');

-- More Complex XML
SELECT 
    CategoryName AS '@Name',
    (SELECT 
        ProductName AS '@Name',
        UnitPrice
     FROM Products p
     WHERE p.CategoryID = c.CategoryID
     FOR XML PATH('Product'), TYPE)
FROM Categories c
FOR XML PATH('Category'), ROOT('ProductCatalog');

-- Create Partitioned Fact Table
CREATE PARTITION FUNCTION pf_SalesDate (DATE)
AS RANGE RIGHT FOR VALUES 
(
    '2023-01-01', '2023-04-01', '2023-07-01', '2023-10-01',
    '2024-01-01', '2024-04-01', '2024-07-01', '2024-10-01'
);

CREATE PARTITION SCHEME ps_SalesDate
AS PARTITION pf_SalesDate
ALL TO ([PRIMARY]);

-- Apply partitioning to FactSales
ALTER TABLE FactSales
DROP CONSTRAINT PK_FactSales;

ALTER TABLE FactSales
ADD CONSTRAINT PK_FactSales 
PRIMARY KEY CLUSTERED (SalesKey, OrderDate)
ON ps_SalesDate(OrderDate);


-- Insert sample dates
INSERT INTO DimDate VALUES 
(20240101, '2024-01-01', 1, 1, 2024),
(20240115, '2024-01-15', 1, 1, 2024),
(20240201, '2024-02-01', 2, 1, 2024),
(20240301, '2024-03-01', 3, 1, 2024),
(20240401, '2024-04-01', 4, 2, 2024);

-- Insert sample products
INSERT INTO DimProduct VALUES 
(1, 'Laptop', 'Electronics'),
(2, 'Mouse', 'Electronics'),
(3, 'Chair', 'Furniture'),
(4, 'Desk', 'Furniture'),
(5, 'Notebook', 'Stationery');

-- Insert sample sales
INSERT INTO FactSales VALUES 
(1, 20240101, 1, 2, 2400.00),
(2, 20240115, 2, 5, 229.95),
(3, 20240115, 3, 1, 299.99),
(4, 20240201, 1, 1, 1200.00),
(5, 20240301, 4, 3, 900.00);