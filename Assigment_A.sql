USE FiveWeekAssessmentDB;
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'Sales'ORDER BY TABLE_NAME;

--A1 Product selection and sorting

USE FiveWeekAssessmentDB;
SELECT ProductID, ProductName, UnitPrice
FROM Sales.Products


SELECT ProductID, ProductName, UnitPrice 
FROM Sales.Products
WHERE UnitPrice BETWEEN 25.00 AND 200.00;


SELECT ProductID, ProductName, UnitPrice AS CurrentPrice
FROM Sales.Products
ORDER BY CurrentPrice DESC;

-- A2 Distinct customer locations

SELECT DISTINCT Region, Country
FROM Sales.Customers

SELECT DISTINCT Region
FROM Sales.Customers
ORDER BY Region; 

SELECT DISTINCT Country
FROM Sales.Customers
ORDER BY Country; 

-- A3 Missing contact values 
SELECT CustomerID, CustomerName, Region, Email
FROM Sales.Customers

SELECT CustomerID, CustomerName, Region,
       COALESCE(NULLIF(Email, ''), 'Not provided') AS Email,
       YEAR(SignupDate) AS SignupYear
FROM Sales.Customers
ORDER BY CustomerID;

-- A4 Calculated order-line values

SELECT OrderID, LineNumber, ProductID, Quantity, UnitPrice, DiscountRate,
       ROUND(Quantity * UnitPrice * (1 - DiscountRate), 2) AS LineRevenue
FROM Sales.OrderItems

SELECT OrderID,LineNumber, ProductID, Quantity, UnitPrice, DiscountRate,
       ROUND(Quantity * UnitPrice * (1 - DiscountRate), 2) AS LineRevenue
FROM Sales.OrderItems
WHERE ROUND(Quantity * UnitPrice * (1 - DiscountRate), 2) >= 100.00
ORDER BY OrderID, LineNumber;

-- A5 Combining the four tables  

SELECT o.OrderID, OrderDate, CustomerName, Region, ProductName, Category
FROM Sales.Orders o

JOIN Sales.Customers c
    ON c.CustomerID = o.CustomerID
JOIN Sales.OrderItems oi
    ON oi.OrderID = o.OrderID
JOIN Sales.Products p
    ON p.ProductID = oi.ProductID

WHERE Status = 'Completed'
ORDER BY OrderDate, o.OrderID, LineNumber;

-- A6 Category summary

SELECT Category,
       COUNT(DISTINCT o.OrderID) AS OrderCount,
       SUM(Quantity) AS TotalUnits,
       ROUND(SUM(Quantity * oi.UnitPrice * (1 - DiscountRate)) / SUM(Quantity), 2) AS AvgerageSellingUnitPrice,
       ROUND(SUM(Quantity * oi.UnitPrice * (1 - DiscountRate)), 2) AS TotalRevenue
FROM Sales.Orders o, Sales.OrderItems oi, Sales.Products p



SELECT Category,
       COUNT(DISTINCT o.OrderID) AS OrderCount,
       SUM(Quantity) AS TotalUnits,
       ROUND(SUM(Quantity * oi.UnitPrice * (1 - DiscountRate)) / SUM(Quantity), 2) AS AvgerageSellingUnitPrice,
       ROUND(SUM(Quantity * oi.UnitPrice * (1 - DiscountRate)), 2) AS TotalRevenue
FROM Sales.Orders o, Sales.OrderItems oi, Sales.Products p
WHERE oi.OrderID = o.OrderID
  AND p.ProductID = oi.ProductID
  AND Status = 'Completed'
GROUP BY Category
ORDER BY TotalRevenue DESC;

-- A7 Filtering grouped customer results 

SELECT c.CustomerID, CustomerName,
       COUNT(DISTINCT o.OrderID) AS OrderCount,
       ROUND(SUM(Quantity * oi.UnitPrice * (1 - DiscountRate)), 2) AS TotalRevenue
    FROM Sales.Customers c, Sales.Orders o, Sales.OrderItems oi


WHERE o.CustomerID = c.CustomerID
  AND oi.OrderID = o.OrderID
  AND Status = 'Completed'
GROUP BY c.CustomerID, CustomerName
HAVING SUM(Quantity * oi.UnitPrice * (1 - DiscountRate)) > 600.00
ORDER BY TotalRevenue DESC;

-- A8 Scalar subquery

SELECT ProductID, ProductName, Category, UnitPrice
FROM Sales.Products
WHERE IsActive = 1
  AND UnitPrice > (SELECT AVG(UnitPrice)
                   FROM Sales.Products
                   WHERE IsActive = 1)
ORDER BY UnitPrice DESC;

-- A9 CTE and customer categories

WITH CustomerRevenue AS (
    SELECT c.CustomerID, CustomerName, Region,
           SUM(Quantity * UnitPrice * (1 - DiscountRate)) AS TotalRevenue
    FROM Sales.Customers c
    JOIN Sales.Orders o ON o.CustomerID = c.CustomerID
    JOIN Sales.OrderItems oi ON oi.OrderID = o.OrderID
    WHERE Status = 'Completed'
    GROUP BY c.CustomerID, CustomerName, Region
)
SELECT *,
       CASE WHEN TotalRevenue >= 1500 THEN 'High Value'
            WHEN TotalRevenue >= 700 THEN 'Medium Value'
            ELSE 'Standard'
       END AS ValueCategory
FROM CustomerRevenue;

--A10 Monthly revenue and running total

WITH Monthly AS (
    SELECT DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS MonthStart,
           SUM(Quantity * UnitPrice * (1 - DiscountRate)) AS MonthlyRevenue
    FROM Sales.Orders o
    JOIN Sales.OrderItems oi ON oi.OrderID = o.OrderID
    WHERE Status = 'Completed'
    GROUP BY DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
)
SELECT MonthStart,
       MonthlyRevenue,
       SUM(MonthlyRevenue) OVER (ORDER BY MonthStart) AS RunningTotal
FROM Monthly;


