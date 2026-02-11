/*
Workshop: Scrittura query e tuning delle performance.

Individuare in quali circostanze una categoria di prodotti ha registrato 
un rincaro del prezzo medio di vendita superiore al 20% rispetto all'anno precedente.
L'analisi deve riguardare soltanto le vendite effettuate a clienti 
degli stati uniti e del canada.
*/

/*
Attenzione 1: il prezzo di vendita non è in dollari.
Attenzione 2: considerare anche lo sconto.
Attenzione 3: la media del prezzo di vendita deve essere pesata 
per la quantità di ogni linea d'ordine
*/

/*analisi preliminari */
--Distribuzione colonna status di Sales.SalesOrderHeader
SELECT Status, COUNT(*)
FROM   Sales.SalesOrderHeader
GROUP BY Status
--deduciamo che tutti gli ordini sono validi

--Distribuzione currency per il cambio
SELECT COUNT(*) 
FROM Sales.SalesOrderHeader 
WHERE CurrencyRateID IS NULL;

SELECT FromCurrencyCode, ToCurrencyCode, COUNT(*)
FROM   Sales.SalesOrderHeader as oh
LEFT JOIN  Sales.CurrencyRate as cr
	on oh.CurrencyRateID = cr.CurrencyRateID
GROUP BY FromCurrencyCode, ToCurrencyCode
--Deduciamo che quando in Sales.SalesOrderHeader c'è NULL, l'importo è gia in USD

--impatto prodotti senza categoria
SELECT COUNT(*)
FROM   Production.Product
WHERE  ProductSubcategory IS NULL;

SELECT 
     COUNT(*)
FROM SALES.SalesOrderDetail as od
INNER JOIN SALES.SalesOrderHeader as oh
	on od.SalesOrderID = oh.salesorderid
INNER JOIN Production.Product as p
	on od.ProductID  = p.productid
LEFT JOIN Production.ProductSubcategory as ps
	on p.ProductSubcategoryID = ps.ProductSubcategoryID
WHERE PS.ProductSubcategoryID IS NULL;
--I prodotti senza categoria non sono stati venduti

--Distribuzione colonna UnitPriceDiscount di Sales.SalesOrderDetail
SELECT UnitPriceDiscount, COUNT(*)
FROM   Sales.SalesOrderDetail
GROUP BY UnitPriceDiscount
--deduciamo che gli sconti sono in percentuale

--Controllo CountryCode
SELECT 
    COUNT(*) AS Totali,
	SUM(CASE WHEN st.CountryRegionCode = st2.CountryRegionCode 
			THEN 1 ELSE 0 END) AS SameCountryRegionCode,
	SUM(CASE WHEN st.CountryRegionCode != st2.CountryRegionCode 
		THEN 1 ELSE 0 END) AS DifferntCountryRegionCode
FROM  SALES.SalesOrderHeader as oh
INNER JOIN sales.Customer as c
	on oh.customerid = c.CustomerID	
INNER JOIN sales.SalesTerritory as st
	on c.TerritoryID = st.TerritoryID
INNER JOIN sales.SalesTerritory as st2
	on oh.TerritoryID = st.TerritoryID
--deduciamo che c'è tantissima differenza tra i due approcci



--Step 1, 2, 3, 4
SELECT 
     od.OrderQty,
	 od.UnitPrice, 
	 od.UnitPriceDiscount,
	 od.unitprice * (1-od.UnitPriceDiscount) / isnull(cr.AverageRate,1) as UnitPriceAdjusted,
	 year(oh.orderdate) as order_year,
	 pc.ProductCategoryID, 
	 pc.name as category_name,
	 cr.AverageRate AS CurrencyRate
into  #perimetro_query
FROM SALES.SalesOrderDetail as od
INNER JOIN SALES.SalesOrderHeader as oh
	on od.SalesOrderID = oh.salesorderid
INNER JOIN Production.Product as p
	on od.ProductID  = p.productid
INNER JOIN Production.ProductSubcategory as ps
	on p.ProductSubcategoryID = ps.ProductSubcategoryID
INNER JOIN Production.ProductCategory as pc
	on ps.ProductCategoryID = pc.ProductCategoryID
INNER JOIN sales.Customer as c
	on oh.customerid = c.CustomerID	
INNER JOIN sales.SalesTerritory as st
	on c.TerritoryID = st.TerritoryID
INNER JOIN sales.SalesTerritory as st2
	on oh.TerritoryID = st.TerritoryID
LEFT JOIN sales.CurrencyRate as cr
	on oh.CurrencyRateID = cr.CurrencyRateID
WHERE st.CountryRegionCode in  ('us','ca');

--step 5
SELECT 
	order_year, 
	ProductCategoryID,
	category_name,
	sum(UnitPriceAdjusted*OrderQty)/sum(OrderQty) as avg_price
into #anno_categoria
FROM   #perimetro_query
GROUP BY 
	order_year, 
	ProductCategoryID, 
	category_name;

--step 6, 7
with final as (
	SELECT *,
		lag(avg_price) over(partition by productcategoryid
							order by order_year) as avg_price_previous
	FROM  #anno_categoria)
SELECT *,	
	(avg_price - avg_price_previous)/avg_price_previous as scostamento_percentuale
FROM  final
WHERE (avg_price - avg_price_previous)/avg_price_previous>0.20;












