WITH 
--Calculate revenue of product in a year
T1 AS (
SELECT 
	SOD.ProductID,
	YEAR(SOH.OrderDate) AS 'Year',
	SUM(SOD.LineTotal) AS 'Totalrev' 
FROM sales.SalesOrderDetail AS SOD
LEFT JOIN sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID = SOH.SalesOrderID
GROUP BY SOD.ProductID, YEAR(SOH.OrderDate)
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
)
SELECT
	T1.ProductID,
	T2.Product_name,
	T2.Subcategory,
	T2.Category,
	T1.Year,
	T1.Totalrev
FROM T1
LEFT JOIN T2 ON T1.ProductID = T2.ProductID
ORDER BY T1.Totalrev DESC
