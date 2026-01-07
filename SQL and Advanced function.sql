/*Q6. Create a database named ECOmmerceDB and perform the following task.*/

-- 1. Create database
CREATE DATABASE ECommerceDB;
USE ECommerceDB;

-- 2. Categories table
CREATE TABLE Categories (
CategoryID  INT PRIMARY KEY,
CategoryName VARCHAR(50) NOT NULL UNIQUE
);

-- 3. Products Table
CREATE TABLE Products (
ProductID  INT PRIMARY KEY, 
ProductName  VARCHAR(100) NOT NULL UNIQUE,
CategoryID  INT, 
Price   DECIMAL(10,2) Not Null,
stockQuantity INT, 
FOREIGN KEY (CategoryID) REFERENCES
Categories(categoryID)
);

-- 4. Customers table
CREATE TABLE Customers(
CustomerID INT PRIMARY KEY,
CustomerName VARCHAR(100) NOT NULL, 
Email  VARCHAR(100) UNIQUE, 
JoinDate  date
);

-- 5. Orders table
CREATE TABLE Orders (
OrderID    INT PRIMARY KEY,
CustomerID INT, 
OrderDate DATE NOT NULL,
TotalAmount DECIMAL(10,2),
FOREIGN KEY (CustomerID) REFERENCES
Customers(CustomerID)
);

-- Inserting the given record into each table 
-- Categories
INSERT INTO Categories (CategoryID, CategoryName) VALUES
(1, 'Electronics'),
(2, 'Books'),
(3, 'Home Goods'),
(4, 'Apparel');

-- Products
INSERT INTO Products (ProductID, ProductName, CategoryID, Price, StockQuantity) VALUES
(101, 'Laptop Pro',            1, 1200.00,  50),
(102, 'SQL Handbook',          2,   45.50, 200),
(103, 'Smart Speaker',         1,   99.99, 150),
(104, 'Coffee Maker',          3,   75.00,  80),
(105, 'Novel : The Great SQL', 2,   25.00, 120),
(106, 'Wireless Earbuds',      1,  150.00, 100),
(107, 'Blender X',             3,  120.00,  60),
(108, 'T-Shirt Casual',        4,   20.00, 300);

-- Customers
INSERT INTO Customers (CustomerID, CustomerName, Email, JoinDate) VALUES
(1, 'Alice Wonderland', 'alice@example.com',  '2023-01-10'),
(2, 'Bob the Builder',  'bob@example.com',    '2022-11-25'),
(3, 'Charlie Chaplin',  'charlie@example.com','2023-03-01'),
(4, 'Diana Prince',     'diana@example.com',  '2021-04-26');

-- Orders
INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount) VALUES
(1001, 1, '2023-04-26', 1245.50),
(1002, 2, '2023-10-12',   99.99),
(1003, 1, '2023-07-01',  145.00),
(1004, 3, '2023-01-14',  150.00),
(1005, 2, '2023-09-24',  120.00),
(1006, 1, '2023-06-19',   20.00);

select * from Categories;
select * from Products;
select * from Customers;
select * from Orders;



/* Q7. Generate a report showing CustomerName, Email, and the TotalNumberofOrders for each customer.
 Include customers who have not placed any orders, in which case their TotalNumberofOrders should be 0.
 Order the results by customerName.*/

## Ans ##
SELECT 
c.CustomerName,
c.Email,
COUNT(o.OrderID) as TotalNumberofOrders
FROM Customers c
LEFT JOIN Orders o 
ON c.CustomerID = o.CustomerID
GROUP By c.CustomerName, c.Email
ORDER BY c.CustomerName;

/* Q8. Retrieve Product Information with Category: Write a SQL query to display the ProductName, 
Price, StockQuantity, and CategoryName For all product. 
Order the result by CategoryName and then ProductName alphabetically.*/

## Ans ##
SELECT 
p.ProductName,
p.Price,
p.StockQuantity,
cat.CategoryName
FROM Products p
INNER JOIN Categories cat 
ON p.CategoryID = cat.CategoryID
ORDER BY cat.CategoryName,
p.ProductName;


/* Q9. Write a SQL query that uses a Common Table Expression (CTE) and a windows function 
(specifically ROW_Number() or Rank()) to display the CategoryName, ProductName, 
and Price of the top 2 most expensive products in each CategoryName.*/

## Ans ##

WITH RankedProducts AS (
    SELECT 
        cat.CategoryName,
        p.ProductName,
        p.Price,
        ROW_NUMBER() OVER (
            PARTITION BY p.CategoryID 
            ORDER BY p.Price DESC
        ) AS rn
    FROM Products p
    INNER JOIN Categories cat 
        ON p.CategoryID = cat.CategoryID
)
SELECT 
    CategoryName,
    ProductName,
    Price
FROM RankedProducts
WHERE rn <= 2;

/* Question 10 : You are hired as a data analyst by Sakila Video Rentals, a global movie 
rental company. The management team is looking to improve decision-making by 
analyzing existing customer, rental, and inventory data. 
Using the Sakila database, answer the following business questions to support key strategic 
initiatives. */
/* Task & Questions:*/

use sakila ;

# Task 1: Identify the top 5 customers based on the total amount they've spent. Include customer name, and total amount spent 

Select 
c.customer_id,
c.first_name,
c.last_name,
Sum(p.amount) as total_spent
From customer c
Inner join payment p On c.customer_id = p.customer_id
Group by c.customer_id, c.first_name,c.last_name
Order by total_spent Desc
limit 10;

# Task 2: which 3 movie categories have the highest rental counts? Display the category name and number of times movies from that category were rented.

SELECT 
    cat.name AS category_name,
    COUNT(r.rental_id) AS rental_count
FROM category cat
INNER JOIN film_category fc ON cat.category_id = fc.category_id
INNER JOIN film f ON fc.film_id = f.film_id
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY cat.category_id, cat.name
ORDER BY rental_count DESC;

# Task3: Calculate how many films are available at each store and how many of those have never been rented

SELECT 
s.store_id,
COUNT(i.inventory_id) AS TotalFilms,
SUM(CASE WHEN r.rental_id IS NULL THEN 1 ELSE 0 END) AS NeverRented
FROM store s
JOIN inventory i
ON s.store_id = i.store_id
LEFT JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY s.store_id;

# Task 4: Show the total revenue per month for the yeat 2023 to analyze business seasonality.

SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') AS Month,
    SUM(amount) AS TotalRevenue
FROM payment
WHERE YEAR(payment_date) = 2023
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY Month;

# Task 5 : Identify customer who have rented more than 10 times in the last 6 months.

SELECT 
c.customer_id,
c.first_name,
c.last_name,
COUNT(r.rental_id) AS TotalRentals
FROM customer c
JOIN rental r
ON c.customer_id = r.customer_id
WHERE r.rental_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(r.rental_id) > 10
ORDER BY TotalRentals DESC;



