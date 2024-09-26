Use retail_Dataset;

-- Question
-- Indetify the dublicates
-- create a table that'll have the uniquetables.
-- delete the old table
-- replace the table name with og new table with old table


-- Select transactionID, Count(*) from Sales_Transaction group by transactionID Having Count(*)>1;

/*Create table New_S as
Select Distinct * from Sales_Transaction;*/


Select transactionID, Count(*) from Sales_Transaction group by transactionID Having Count(*)>1;

create table  new_Sales_transaction as 
select distinct * from Sales_transaction;

Drop Table Sales_Transaction;

Rename table New_Sales_Transaction to Sales_Transaction;

Select * from Sales_Transaction;


-- q2
-- find null values in the data set and replace with unknown.
-- use customer_profiles
-- identify where there is null, count no of cells, showcase them by creating a new query.

select count(*) from customer_profiles where Location is null
                                                                     or Customerid is null
                                                                     or Age is null
                                                                     or Gender is null
                                                                     or JoinDate is null;


-- Q3
/*Create a separate table and change the data type of the date column as it is in TEXT format and name it as you wish to.
Remove the original table from the database.
Change the name of the new table and replace it with the original name of the table.*/
Create Table Sales_TransactionA AS
SELECT 
    TransactionID, 
    CustomerID, 
    ProductID, 
    QuantityPurchased, 
    DATE_FORMAT(STR_TO_DATE(TransactionDate, '%Y-%m-%d'), '%y/%m/%d') AS TransactionDatee, 
    Price,
    STR_TO_DATE(TransactionDate, '%Y-%m-%d') AS TransactionDate_updated
FROM 
    Sales_Transaction;

Drop table Sales_Transaction;

Rename table Sales_TransactionA to Sales_transaction;

Alter Table Sales_Transaction 
Rename Column TransactionDatee to TransactionDate;

Select *from Sales_Transaction;

-- Q4

-- Find Total quantity, total Sales
-- return the result in Des order to total sales

SELECT ProductId, 
       Sum(QuantityPurchased) AS TotalUnitsSold, 
       Sum(QuantityPurchased*Price) AS TotalSales 
FROM Sales_Transaction 
GROUP BY ProductId
Order by TotalSales desc;

-- Q4
-- write a query to find number of transaction/ customer,
-- show the results in dec of NumberofTransactions

Select CustomerID, Count(TransactionID) NumberofTransactions from Sales_transaction
Group by customerID
Order by NumberofTransactions desc;

-- Q5

-- write Sql to evluate the product's Performance based on total sales.

Select Category, 
                        Sum(QuantityPurchased) As TotalUnitsSold,
                        Sum(QuantityPurchased * S.Price) As TotalSales
from Sales_transaction S
Join
Product_Inventory P
Using(ProductID)
Group by Category
Order by TotalSales Desc;

-- Q6
-- Find top 10 Products with highest Sales.
-- Find the revnue in desc order

Select ProductId, Sum(QuantityPurchased*Price) As TotalRevenue
From Sales_Transaction
Group by ProductId
Order by Totalrevenue desc
Limit 10;

-- Q7
-- find least amount of units sold, given atleast 1 unit should have been sold.
-- Find only 1 productids

Select* from 
(SELECT ProductID, Sum(QuantityPurchased) AS TotalUnitsSold 
FROM Sales_transaction 
GROUP BY ProductID 
ORDER BY TotalUnitsSold) as S
Where S.TotalUnitsSold>0
Limit 10;

-- Q8

-- using the table Sales_transaction find the sales trend.
-- Datetrans has to be found, where we know what was the no of transaction on a day, how many units where sold and what was the sales of the day.
-- date Ymd

-- Select * from Sales_transaction;
--Desc Sales_transaction;

SELECT 
    Str_to_Date(transactionDate, '%Y-%m-%d') AS DATETRANS,
    Count(TransactionID) AS Transaction_count,
    Sum(QuantityPurchased) AS TotalUnitsSold,
    Sum(QuantityPurchased*Price) AS TotalSales
FROM 
    sales_transaction
GROUP BY 
    Str_to_Date(transactionDate, '%Y-%m-%d')
ORDER BY 
    Str_to_Date(transactionDate, '%Y-%m-%d') DESC;
    
-- Q9
-- Find month on month group rate of Sales
-- use Sales Transaction
-- Exctract Month from the dates

/*
WITH MonthlySales AS (
    SELECT 
        EXTRACT(MONTH FROM TransactionDate) AS M,
        SUM(QuantityPurchased * Price) AS total_sales
    FROM 
        Sales_transaction
    GROUP BY 
        EXTRACT(MONTH FROM TransactionDate)
       
)

SELECT 
    M,
    total_sales,
    LAG(total_sales) OVER (ORDER BY M) AS previous_month_sales,
    ((total_sales - LAG(total_sales) OVER (ORDER BY M)) / LAG(total_sales) OVER (ORDER BY M) * 100) AS Mom_growth_percentage
FROM 
    MonthlySales
    Order by M;
    
   */


SELECT 
    X.M AS Month,
    X.Total_Sales,
    LAG(X.Total_Sales) OVER (ORDER BY X.M) AS previous_month_sales,
    ((X.Total_Sales - LAG(X.Total_Sales) OVER (ORDER BY X.M)) / LAG(X.Total_Sales) OVER (ORDER BY X.M) * 100) AS Mom_growth_percentage
FROM 
    (SELECT 
        EXTRACT(MONTH FROM TransactionDate) AS M,
        SUM(QuantityPurchased * Price) AS Total_Sales
    FROM 
        Sales_transaction
    GROUP BY 
        EXTRACT(MONTH FROM TransactionDate)
    ) X;
    
-- Q10
-- Using Sales transaction find.
-- The resulting table must have number of transactions more than 10 and TotalSpent more than 1000 on those transactions by the corresponding customers.

 WITH Sales AS (
    SELECT
        CustomerID, 
        COUNT(transactionId) AS Numberoftransactions,  
        SUM(QuantityPurchased * Price) AS TotalSpent  
    FROM 
        Sales_Transaction
    GROUP BY 
        CustomerID
    Order by TotalSpent Desc
)
SELECT 
    CustomerID, 
    Numberoftransactions, 
    TotalSpent
FROM 
    Sales
WHERE 
    Numberoftransactions > 10
    AND TotalSpent > 1000;
    
-- Q11
-- Transactions Less than two


SELECT * FROM (
    SELECT
        CustomerID, 
        COUNT(transactionId) AS Numberoftransactions,  
        SUM(QuantityPurchased * Price) AS TotalSpent  
    FROM 
        Sales_Transaction
    GROUP BY 
        CustomerID
) U
WHERE 
    U.Numberoftransactions <= 2
ORDER BY 
    U.Numberoftransactions ASC,
    U.TotalSpent DESC;
    
-- Q12

-- No of puchases done by each customer on a productID to understand the repeat customers
-- The resulting table must have "CustomerID", "ProductID" and the number of times that particular customer have purchases that product.
-- no of puchases should>1.
-- it should be in desc order of the totalPurchsed.
-- With Sales As
Select CustomerID,ProductID, Count(ProductID) TimesPurchased
from Sales_transaction
Group by CustomerID, ProductID
Having TimesPurchased>1
Order by TimesPurchased Desc;

-- Q13
-- Describe the duration between first and last Purchase of the customer.
-- TransactionDate is in text format, change it.
-- The resulting table must have the first date of purchase, the last date of purchase and the difference between the first and the last date of purchase.
-- Difeerence between frst and last date to be more than 0
-- return in desc to Daysbetweenpuchases
-- Desc Sales_transaction;
-- Select* from Sales_transaction;

WITH Find AS (
    SELECT 
        CustomerID, 
        MIN(STR_TO_DATE(TransactionDate, '%Y-%m-%d')) AS FirstPurchase,
        MAX(STR_TO_DATE(TransactionDate, '%Y-%m-%d')) AS LastPurchase
    FROM 
        Sales_transaction
    GROUP BY 
        CustomerID
)

SELECT * FROM (
    SELECT 
        *,  
        DATEDIFF(LastPurchase, FirstPurchase) AS DaysBetweenPurchases 
    FROM 
        Find
    ORDER BY 
        DaysBetweenPurchases DESC
) X
WHERE 
    X.DaysBetweenPurchases > 0;

-- Q 14
-- Segment customers based on total quantatity of products they have puchased
-- count the no of customers in Segments
-- Use cutomer_purchsed and Sales_transaction.
-- Create a table named customer_segment.

Create Table Customer_Segment as
Select S.CustomerSegment, Count(*) from
(SELECT
    CustomerID,SUM(QuantityPurchased) AS TotalQuantityofproductpurchased,
    CASE
        WHEN SUM(QuantityPurchased) BETWEEN 1 AND 9 THEN 'Low'
        WHEN SUM(QuantityPurchased) BETWEEN 10  AND 30 THEN 'Med'
        ELSE 'High'
    END AS CustomerSegment
 from Sales_transaction
 Group by customerid) S
 Group by S.CustomerSegment;
 /*


Create Table Customer_Segment AS
SELECT 
    S.CustomerSegment,
    COUNT(*)
   FROM (
    SELECT 
        CP.CustomerID, 
        SUM(ST.QuantityPurchased) AS TotalQuantityofproductpurchased,
        CASE
            WHEN SUM(ST.QuantityPurchased) BETWEEN 1 AND 9 THEN 'Low'
            WHEN SUM(ST.QuantityPurchased) BETWEEN 10 AND 30 THEN 'Med'
            ELSE 'High'
        END AS CustomerSegment
    FROM Sales_transaction ST
    JOIN Customer_Profiles CP
    ON CP.CustomerID = ST.CustomerID
    GROUP BY CP.CustomerID
) AS S
GROUP BY S.CustomerSegment;*/

Select * from Customer_Segment;

