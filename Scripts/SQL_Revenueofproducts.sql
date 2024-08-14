--Calculate revenue of each product
WITH T1 AS (
SELECT
	SOD.ProductID AS 'ProductID',
	YEAR(SOH.OrderDate) AS 'Year',
	SUM(SOD.OrderQty*SOD.UnitPrice*(1 - SOD.UnitPriceDiscount)) AS 'Revenue'
FROM Sales.SalesOrderDetail AS SOD
LEFT JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE UnitPrice <> 0
GROUP BY SOD.ProductID,YEAR(SOH.OrderDate)
),
--Include categories and subcategories
T2 AS(
SELECT
	T1.ProductID,
	T1.Year,
	T1.Revenue,
	SCG.Name AS 'SubCategory',
	CG.Name AS 'Category'
FROM T1
LEFT JOIN Production.Product AS PD ON T1.ProductID = PD.ProductID
LEFT JOIN Production.ProductSubcategory AS SCG ON PD.ProductSubcategoryID = SCG.ProductSubcategoryID
LEFT JOIN Production.ProductCategory AS CG ON SCG.ProductCategoryID = CG.ProductCategoryID
)
SELECT *
FROM T2



