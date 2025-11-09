create database Shop

use Shop


-- Create Customers table
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    city VARCHAR(50),
    registration_date DATE
);

-- Create Orders table
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- Create Products table
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT
);

-- Create Order_Items table (junction table for many-to-many relationship)
CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);


-- Insert data into Customers table
INSERT INTO Customers VALUES 
(1, 'John', 'Smith', 'john.smith@email.com', 'New York', '2023-01-15'),
(2, 'Sarah', 'Johnson', 'sarah.j@email.com', 'Los Angeles', '2023-02-20'),
(3, 'Mike', 'Davis', 'mike.davis@email.com', 'Chicago', '2023-03-10'),
(4, 'Emily', 'Wilson', 'emily.wilson@email.com', 'New York', '2023-01-25'),
(5, 'David', 'Brown', 'david.brown@email.com', 'Miami', '2023-04-05'),
(6, 'Lisa', 'Anderson', 'lisa.a@email.com', 'Chicago', '2023-05-12'),
(7, 'Kevin', 'Miller', 'kevin.m@email.com', 'Seattle', '2023-06-18'),
(8, 'Amy', 'Taylor', 'amy.taylor@email.com', 'Los Angeles', '2023-07-22');

-- Insert data into Products table
INSERT INTO Products VALUES 
(1, 'Laptop', 'Electronics', 999.99, 15),
(2, 'Smartphone', 'Electronics', 699.99, 25),
(3, 'Desk Chair', 'Furniture', 199.99, 30),
(4, 'Coffee Maker', 'Home Appliances', 89.99, 40),
(5, 'Headphones', 'Electronics', 149.99, 50),
(6, 'Bookshelf', 'Furniture', 299.99, 20),
(7, 'Blender', 'Home Appliances', 59.99, 35),
(8, 'Tablet', 'Electronics', 449.99, 18);

-- Insert data into Orders table
INSERT INTO Orders VALUES 
(101, 1, '2023-08-01', 1149.98, 'Delivered'),
(102, 2, '2023-08-02', 699.99, 'Processing'),
(103, 3, '2023-08-03', 349.98, 'Delivered'),
(104, 1, '2023-08-04', 199.99, 'Shipped'),
(105, 5, '2023-08-05', 1049.98, 'Processing'),
(106, 6, '2023-08-06', 599.98, 'Delivered'),
(107, 8, '2023-08-07', 149.99, 'Cancelled'),
(108, 2, '2023-08-08', 89.99, 'Delivered');

-- Insert data into Order_Items table
INSERT INTO Order_Items VALUES 
(1, 101, 1, 1, 999.99),  -- Laptop
(2, 101, 5, 1, 149.99),  -- Headphones
(3, 102, 2, 1, 699.99),  -- Smartphone
(4, 103, 5, 2, 149.99),  -- 2 Headphones
(5, 104, 3, 1, 199.99),  -- Desk Chair
(6, 105, 1, 1, 999.99),  -- Laptop
(7, 105, 7, 1, 59.99),   -- Blender
(8, 106, 6, 2, 299.99),  -- 2 Bookshelves
(9, 107, 5, 1, 149.99),  -- Headphones
(10, 108, 4, 1, 89.99);  -- Coffee Maker


















