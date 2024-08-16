WITH 
--Calculate revenue of product in a year
T1 AS (
SELECT 
        SOD.ProductID,
        MONTH(SOH.Orderdate) AS 'Month',
        YEAR(SOH.OrderDate) AS 'Year',
        SUM(SOD.LineTotal) AS 'Totalrev' 
FROM sales.SalesOrderDetail AS SOD
LEFT JOIN sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID = SOH.SalesOrderID
GROUP BY SOD.ProductID, YEAR(SOH.OrderDate), MONTH(SOH.Orderdate)
),
--Extract product, subcate, and category names
T2 AS(
SELECT 
        PD.ProductID,
        PD.Name AS 'Product_name',
        PS.Name AS 'Subcategory',
        PC.Name AS 'Category'
FROM Production.Product AS PD
LEFT JOIN Production.ProductSubcategory AS PS ON PD.ProductSubcategoryID=PS.ProductSubcategoryID
LEFT JOIN Production.ProductCategory AS PC ON PS.ProductCategoryID = PC.ProductCategoryID
),
--Combine
T3 AS (
SELECT
        T2.Category,
        T1.Month,
        T1.Year,
        SUM(T1.Totalrev) AS 'Revenues'
FROM T1
LEFT JOIN T2 ON T1.ProductID = T2.ProductID
GROUP BY T2.Category,T1.Month,T1.Year
)
--Add a column for monthly growth rate
SELECT 
	cur.Category,
	cur.Month,
	cur.Year,
	cur.Revenues,
	(cur.Revenues-pre.Revenues)/pre.Revenues AS 'Growth rate'
FROM T3 AS cur
LEFT JOIN T3 pre ON 
					(cur.Category = pre.Category) 
					AND (
						 (cur.Month = pre.Month + 1 AND cur.Year=pre.Year) OR
						 (cur.Month = 1 AND pre.Month = 12 AND cur.Year=pre.Year + 1)
						)
ORDER BY cur.Category,cur.Year,cur.Month

