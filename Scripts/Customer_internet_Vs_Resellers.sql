USE AdventureWorks2022
--Query 1: How many resellers and internet customers are there?
--Calculate the number of resellers and individual Customers
WITH AA AS(
SELECT
        YEAR(OrderDate) AS 'Year',
        COUNT(DISTINCT CustomerID) AS 'Number of Reseleler Customer'
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 0
GROUP BY YEAR(OrderDate)
),
AB AS (
SELECT
        YEAR(OrderDate) AS 'Year',
        COUNT(DISTINCT CustomerID) AS 'Number of Individual Customer'
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 1
GROUP BY YEAR(OrderDate)
)

SELECT
        p1.year, p1.[Number of Reseleler Customer],p2.[Number of Individual Customer]
FROM AA AS p1
LEFT JOIN AB AS p2 ON p1.Year=p2.Year
ORDER BY p1.Year ASC


--Query 2: Revenue from internet and resellers customers
--Calculate percentage of revenue from resellers customers
WITH 
----Calculate revenue from Internet sales
T1 AS(
SELECT 
        YEAR(OrderDate) AS 'Year',
        SUM(Subtotal) AS 'Total revenue(Internet)'
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NULL
GROUP BY YEAR(OrderDate)
),
----Calculate growth rate of revenue from Internet Sales
T1a AS (
SELECT
	currentYear.Year AS 'Year',
	currentYear.[Total revenue(Internet)] AS 'SalesInternet',
	CASE
		WHEN preYear.[Total revenue(Internet)] = 0 THEN NULL
		ELSE (currentYear.[Total revenue(Internet)]-preYear.[Total revenue(Internet)])/preYear.[Total revenue(Internet)]
		END AS AnnualGrowth_of_Internet_Revenue
FROM T1 AS preYear
LEFT JOIN T1 AS currentYear ON preYear.year+1=currentYear.Year
),
----Calculate revenue from resellers
T2 AS(
SELECT 
        YEAR(OrderDate) AS 'Year',
        SUM(Subtotal) AS 'Total revenue(Reseller)'
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL
GROUP BY YEAR(OrderDate)
),
----Calculate growth rate of revenue from resellers sales
T2a AS(
SELECT
	currentYear.Year AS 'Year',
	currentYear.[Total revenue(Reseller)] AS 'SalesResellers',
	CASE
		WHEN preYear.[Total revenue(Reseller)] = 0 THEN NULL
		ELSE (currentYear.[Total revenue(Reseller)]-preYear.[Total revenue(Reseller)])/preYear.[Total revenue(Reseller)]
		END AS AnnualGrowth_of_reseller_revenue
FROM T2 AS preYear
LEFT JOIN T2 AS currentYear ON preYear.year+1=currentYear.Year
)
--Completed results
SELECT
        T1a.Year AS 'Year',
        T1a.SalesInternet,
        T1a.AnnualGrowth_of_Internet_Revenue,
		T2a.SalesResellers,
		T2a.AnnualGrowth_of_reseller_revenue,
	    T2a.SalesResellers/(T2a.SalesResellers+T1a.SalesInternet) AS'Percentage_from_reseller'
FROM T1a
LEFT JOIN T2a ON T1a.Year = T2a.Year
ORDER BY T1a.Year ASC
