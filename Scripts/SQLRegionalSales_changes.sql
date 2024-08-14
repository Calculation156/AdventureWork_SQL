WITH YR AS (
SELECT 
	YEAR(OrderDate) AS 'Year',
	SUM(TotalDue) AS 'Yearly Revenue'
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
),
RS AS (
SELECT
	ter.Name,
	ter.CountryRegionCode,
	YEAR(SOH.OrderDate) AS 'Year',
	SUM(SOH.TotalDue) AS 'Revenue'
FROM Sales.SalesOrderHeader AS SOH
LEFT JOIN Sales.SalesTerritory AS ter ON SOH.TerritoryID = ter.TerritoryID
GROUP BY ter.Name,ter.CountryRegionCode,YEAR(SOH.OrderDate)
),
RS2 AS (
SELECT
	cur.name,
	cur.CountryRegionCode,
	cur.Year,
	cur.Revenue,
	(cur.Revenue-pre.Revenue)/pre.Revenue AS 'GrowthRate'
FROM RS AS cur
LEFT JOIN RS AS pre ON (cur.Year= pre.Year + 1) AND (cur.Name = pre.Name)
)
SELECT
	RS2.Name,
	RS2.CountryRegionCode,
	RS2.Year,
	RS2.Revenue,
	YR.[Yearly Revenue],
	RS2.GrowthRate,
	RS2.Revenue/YR.[Yearly Revenue] AS '%ofYearlyRev'
FROM RS2
LEFT JOIN YR ON RS2.Year = YR.Year
ORDER BY RS2.Name,RS2.Year
