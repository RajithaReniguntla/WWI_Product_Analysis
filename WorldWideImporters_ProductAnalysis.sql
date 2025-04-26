
-----------------------------------------WORLD WIDE IMPORTERS - PRODUCT - EDA ANALYSIS --------------------------------------------------------------------------------------

-- 1. How have sales and profit performance of stock items changed from 2013 to 2015? --

SELECT 
    si.StockItemID,
    si.StockItemName AS 'Stock Item Name',
    
    -- sales volume by year
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.Quantity ELSE 0 END) as 'SalesVolume 2013',
	SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity ELSE 0 END) as 'SalesVolume 2014',
	SUM(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.Quantity ELSE 0 END) as 'SalesVolume 2015',
       
    -- revenue by year 
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.Quantity * il.UnitPrice ELSE 0 END) as 'Revenue 2013',
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity * il.UnitPrice ELSE 0 END) as 'Revenue 2014',
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.Quantity * il.UnitPrice ELSE 0 END) as 'Revenue 2015',
    
    -- profit by year
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.LineProfit ELSE 0 END) as 'Profit 2013',
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.LineProfit ELSE 0 END) as 'Profit 2014',
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.LineProfit ELSE 0 END) as 'Profit 2015',

    -- Profit % growth by year 
     ISNULL(((SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.LineProfit ELSE 0 END) 
    - SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.LineProfit ELSE 0 END)) 
    / NULLIF(SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.LineProfit ELSE 0 END), 0)) * 100, 0) as 'Profit Growth% 2013-2014',
    
    ISNULL(((SUM(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.LineProfit ELSE 0 END) 
    - SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.LineProfit ELSE 0 END)) 
    / NULLIF(SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.LineProfit ELSE 0 END), 0)) * 100, 0) as 'Profit Growth% 2014-2015'

FROM Sales.InvoiceLines il
JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
GROUP BY si.StockItemID, si.StockItemName
ORDER BY [Profit Growth% 2014-2015] DESC;



/* -------------- EDA Q1 Comments ------------------

Process:
- need to get Sales Amt for each stock group by year 2013-2015
- InvoiceLines - Quantity*UnitPrice
- Invoice - link to invoice table for invoice date
- StockItem - link invoice lines with stockitem ON StockItemID
- StockItemStockGroup - link to get the StockGroupID
- StockGroup - link to get the StockGroupName
- sales growth = (new-old)/old

SELECT*
FROM Sales.Invoice i

#1 do my joins first --
SELECT
	sg.StockGroupID,
	sg.StockGroupName
FROM Sales.Invoices i
INNER JOIN Sales.InvoiceLines il ON i.InvoiceID = il.InvoiceID
INNER JOIN Warehouse.StockItemStockGroups sisg ON il.StockItemID = sisg.StockItemID
INNER JOIN Warehouse.StockGroups sg ON sisg.StockGroupID = sg.StockGroupID 

*/

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. Which suppliers provide the most unique stock items, and how does this distribution vary across different supplier categories or regions?

-- a. purchase order trend by supplier from 2013-2015--
SELECT
    s.SupplierID,
    s.SupplierName,
    AVG(pol.OrderedOuters) as 'Average OrderQty',
    COUNT(DISTINCT CASE WHEN Year(po.OrderDate)= 2013 THEN po.PurchaseOrderID END) as '2013 OrderCount',
    COUNT(DISTINCT CASE WHEN Year(po.OrderDate)= 2014 THEN po.PurchaseOrderID END) as '2014 OrderCount',
    COUNT(DISTINCT CASE WHEN Year(po.OrderDate)= 2015 THEN po.PurchaseOrderID END) as '2015 OrderCount',
	COUNT(DISTINCT CASE WHEN Year(po.OrderDate)= 2016 THEN po.PurchaseOrderID END) as '2016 OrderCount',
    MIN(po.OrderDate) as 'First Order Date',
    MAX(po.OrderDate) as 'Last Order Date'
FROM Purchasing.PurchaseOrderLines pol
JOIN Purchasing.PurchaseOrders po ON pol.PurchaseOrderID = po.PurchaseOrderID
JOIN Purchasing.Suppliers s ON po.SupplierID = s.SupplierID
GROUP BY s.SupplierID, s.SupplierName
ORDER BY 'Average OrderQty' DESC;


/* cross-check query 
SELECT
	s.SupplierID,
	s.SupplierName,
	MIN(po.OrderDate) as 'First Order Date',
	MAX(po.OrderDate) as 'Last Order Date'
FROM Purchasing.Suppliers s
LEFT JOIN Purchasing.PurchaseOrders po ON s.SupplierID = po.SupplierID
GROUP BY s.SupplierID, s.SupplierName
*/

-- b. order qty trend by supplier from year 2013-2015 --

SELECT
    s.SupplierID,
    s.SupplierName,
    ISNULL(SUM(CASE WHEN Year(po.OrderDate)= 2013 THEN pol.OrderedOuters END),0) as '2013 OrderQty',
    ISNULL(SUM(CASE WHEN Year(po.OrderDate)= 2014 THEN pol.OrderedOuters END),0) as '2014 OrderQty',
    ISNULL(SUM(CASE WHEN Year(po.OrderDate)= 2015 THEN pol.OrderedOuters END),0) as '2015 OrderQty',
	ISNULL(SUM(CASE WHEN Year(po.OrderDate)= 2016 THEN pol.OrderedOuters END),0) as '2016 OrderQty',
    ISNULL(SUM(pol.OrderedOuters), 0) as 'Total OrderQty',

	-- 2013 to 2014 growth%
    ISNULL(ROUND((SUM(CASE WHEN Year(po.OrderDate) = 2014 THEN pol.OrderedOuters END) 
	- SUM(CASE WHEN Year(po.OrderDate) = 2013 THEN pol.OrderedOuters END)) * 100.0 
	/ NULLIF(SUM(CASE WHEN Year(po.OrderDate) = 2013 THEN pol.OrderedOuters END), 0), 2), 0) as '2013-2014 Growth (%)',

	-- 2014 to 2015 growth% --
    ISNULL(ROUND((SUM(CASE WHEN Year(po.OrderDate) = 2015 THEN pol.OrderedOuters END) 
	- SUM(CASE WHEN Year(po.OrderDate) = 2014 THEN pol.OrderedOuters END)) * 100.0 
	/ NULLIF(SUM(CASE WHEN Year(po.OrderDate) = 2014 THEN pol.OrderedOuters END), 0), 2), 0) as '2014-2015 Growth (%)'

FROM Purchasing.PurchaseOrderLines pol
JOIN Purchasing.PurchaseOrders po ON pol.PurchaseOrderID = po.PurchaseOrderID
JOIN Purchasing.Suppliers s ON po.SupplierID = s.SupplierID
GROUP BY s.SupplierID, s.SupplierName
ORDER BY 'Total OrderQty' DESC;

/* -------------- EDA Q2 Comments ------------------

#.a --
-- cross check query for 2016 suppliers and PO count and PO qty  --
SELECT
	s.SupplierID,
	s.SupplierName,
	COUNT(po.PurchaseOrderID) as 'PO Count',
	SUM(pol.OrderedOuters) as 'OrderQty'
FROM Purchasing.Suppliers s
LEFT JOIN Purchasing.PurchaseOrders po ON s.SupplierID = po.SupplierID
JOIN Purchasing.PurchaseOrderLines pol ON po.PurchaseOrderID = pol.PurchaseOrderID
WHERE Year(OrderDate) = 2016
GROUP BY s.SupplierID, s.SupplierName

-- Q2.b --
-- cross check query for 2015 suppliers and PO count  --
SELECT
s.SupplierID,
s.SupplierName,
Count(po.PurchaseOrderID)
FROM Purchasing.Suppliers s
LEFT JOIN Purchasing.PurchaseOrders po ON s.SupplierID = po.SupplierID
WHERE Year(OrderDate) = 2015
GROUP BY s.SupplierID, s.SupplierName
-- there's only 309 orders for supplierID 4, and 301 orders of supplierID 7 --

#b. second draft - added the distinct 

COUNT(DISTINCT CASE WHEN Year(po.OrderDate)= 2013 THEN po.PurchaseOrderID END) as '2013 OrderCount',
COUNT(DISTINCT CASE WHEN Year(po.OrderDate)= 2014 THEN po.PurchaseOrderID END) as '2014 OrderCount',
COUNT(DISTINCT CASE WHEN Year(po.OrderDate)= 2015 THEN po.PurchaseOrderID END) as '2015 OrderCount',
COUNT(DISTINCT CASE WHEN Year(po.OrderDate)= 2016 THEN po.PurchaseOrderID END) as '2016 OrderCount',

*/

-----------------------------------------------------------------------------------------------------------------------------------------------------------------


-- 3. How does the profit margin by supplier change between 2014-2015 inclusive? -- 

SELECT
    s.SupplierID,
    s.SupplierName,
    
    -- calculate cost price from LineProfit and UnitPrice => CostPrice = (UnitPrice - (LineProfit/Quantity))
    AVG(CASE WHEN YEAR(i.InvoiceDate) = 2014 
        THEN il.UnitPrice - (CASE WHEN il.Quantity <> 0 THEN il.LineProfit / il.Quantity ELSE 0 END) 
        ELSE 0 END) as 'Average Cost Price 2014',
    
    AVG(CASE WHEN YEAR(i.InvoiceDate) = 2015 
        THEN il.UnitPrice - (CASE WHEN il.Quantity <> 0 THEN il.LineProfit / il.Quantity ELSE 0 END) 
        ELSE 0 END) as 'Average Cost Price 2015',

    -- avg sales price by year 
    AVG(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.UnitPrice ELSE 0 END) as 'Average Sales Price 2014',
    AVG(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.UnitPrice ELSE 0 END) as 'Average Sales Price 2015',

	---- profit margin by year using LineProfit
	ISNULL((SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.LineProfit ELSE 0 END) 
    / NULLIF(SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity * il.UnitPrice ELSE 0 END), 0)) * 100, 0) as 'Profit Margin 2014',

   	ISNULL((SUM(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.LineProfit ELSE 0 END) 
    / NULLIF(SUM(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.Quantity * il.UnitPrice ELSE 0 END), 0)) * 100, 0) as 'Profit Margin 2015',

	 -- total quantity sold in each year
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity ELSE 0 END) as 'Total Quantity Sold - 2014', -- the average quantity of stockitems sold per invoice line for the year 2014 --
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.Quantity ELSE 0 END) as 'Total Quantity Sold - 2015',
		
     -- profit earned in each year using LineProfit
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.LineProfit ELSE 0 END) as 'Profit 2014',
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.LineProfit ELSE 0 END) as 'Profit 2015'

FROM Warehouse.StockItemHoldings sih
JOIN Warehouse.StockItems si ON sih.StockItemID = si.StockItemID
JOIN Purchasing.Suppliers s ON si.SupplierID = s.SupplierID
JOIN Sales.InvoiceLines il ON si.StockItemID = il.StockItemID
JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
GROUP BY s.SupplierID, s.SupplierName
ORDER BY [Profit 2015] DESC;


/* -------------- EDA Q3 Comments ------------------

Calculation Logics:

Profit Margin = profit/(unit price * q) 
- (1) sum line profit for each line in 2014
- (2) sum revenue (quantity * unit price)  for each line in 2014 
- profit margin = (1) / (2)


Cost Price - calc t from line profit 
LineProfit = (UnitPrice − CostPrice) * Quantity
CostPrice = UnitPrice − (LineProfit / Quantity)

ISNULL / NULLIFs to be used to ensure correct calcualation when there are 0s

*/

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 4. How does the performance of stock items and their sales vary by customer category over multiple years?

--a. sales performance by customer category
SELECT 
    cc.CustomerCategoryName,
	SUM(il.Quantity) as 'Total Qty',
    -- sales volume by year
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.Quantity ELSE 0 END) as 'Sales Volume 2013',
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity ELSE 0 END) as 'Sales Volume 2014',
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.Quantity ELSE 0 END) as 'Sales Volume 2015',

    -- total revenue by year
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.Quantity * il.UnitPrice ELSE 0 END) as 'Revenue 2013',
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity * il.UnitPrice ELSE 0 END) as 'Revenue 2014',
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.Quantity * il.UnitPrice ELSE 0 END) as 'Revenue 2015',

    -- percentage change in revenue
    CASE WHEN SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.Quantity * il.UnitPrice ELSE 0 END) = 0 THEN NULL -- if 2013 rev is zero, return NULL to avoid division by zero errorr
        ELSE 
            ((SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity * il.UnitPrice ELSE 0 END) 
            - SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.Quantity * il.UnitPrice ELSE 0 END)) 
            / NULLIF(SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.Quantity * il.UnitPrice ELSE 0 END), 0)) * 100 -- if 2013 rev is 0, denominator = NULL to avoid division by zero error
    END as 'Revenue Change 2013-2014%',

    CASE WHEN SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity * il.UnitPrice ELSE 0 END) = 0 THEN NULL 
        ELSE 
            ((SUM(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.Quantity * il.UnitPrice ELSE 0 END) 
            - SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity * il.UnitPrice ELSE 0 END)) 
            / NULLIF(SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity * il.UnitPrice ELSE 0 END), 0)) * 100 
    END as 'Revenue Change 2014-2015%'

FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
JOIN Sales.CustomerCategories cc ON c.CustomerCategoryID = cc.CustomerCategoryID
WHERE Year(i.InvoiceDate) BETWEEN 2013 AND 2015
GROUP BY cc.CustomerCategoryName
ORDER BY [Revenue Change 2014-2015%] DESC;


--b. sales performance by stock item and customer category
-- by stock item and see if they all belong to same customer category or otherwise
SELECT TOP 10
    si.StockItemName, 
    cc.CustomerCategoryName,

    -- sales volume by year
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.Quantity ELSE 0 END) AS 'Volume 2013',
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity ELSE 0 END) AS 'Volume 2014',
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.Quantity ELSE 0 END) AS 'Volume 2015',

    -- total revenue by year
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.Quantity * il.UnitPrice ELSE 0 END) AS 'Revenue 2013',
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity * il.UnitPrice ELSE 0 END) AS 'Revenue 2014',
    SUM(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.Quantity * il.UnitPrice ELSE 0 END) AS 'Revenue 2015',

    -- percentage change in revenue
    CASE WHEN SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.Quantity * il.UnitPrice ELSE 0 END) = 0 THEN NULL -- if 2013 rev is zero, return NULL to avoid division by zero errorr
        ELSE 
            ((SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity * il.UnitPrice ELSE 0 END) 
            - SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.Quantity * il.UnitPrice ELSE 0 END)) 
            / NULLIF(SUM(CASE WHEN YEAR(i.InvoiceDate) = 2013 THEN il.Quantity * il.UnitPrice ELSE 0 END), 0)) * 100 -- if 2013 rev is 0, denominator = NULL to avoid division by zero error
    END AS 'Revenue Growth 2013-2014%',

    CASE WHEN SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity * il.UnitPrice ELSE 0 END) = 0 THEN NULL 
        ELSE 
            ((SUM(CASE WHEN YEAR(i.InvoiceDate) = 2015 THEN il.Quantity * il.UnitPrice ELSE 0 END) 
            - SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity * il.UnitPrice ELSE 0 END)) 
            / NULLIF(SUM(CASE WHEN YEAR(i.InvoiceDate) = 2014 THEN il.Quantity * il.UnitPrice ELSE 0 END), 0)) * 100 
    END AS 'Revenue Growth 2014-2015%'

FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
JOIN Sales.CustomerCategories cc ON c.CustomerCategoryID = cc.CustomerCategoryID
GROUP BY si.StockItemName, cc.CustomerCategoryName
ORDER BY [Revenue Growth 2014-2015%] DESC, cc.CustomerCategoryName;


/* 

-- cross check query --

SELECT
	il.InvoiceLineID,
	cc.CustomerCategoryID,
	cc.CustomerCategoryName,
	il.StockItemID,
	il.InvoiceID,
	il.Quantity,
	il.UnitPrice
FROM Sales.InvoiceLines il
JOIN Warehouse.StockItems si ON il.StockItemID = si.StockItemID
JOIN Sales.Invoices i ON il.InvoiceID = i.InvoiceID
JOIN Sales.Customers c ON i.CustomerID = c.CustomerID
JOIN Sales.CustomerCategories cc ON c.CustomerCategoryID = cc.CustomerCategoryID
ORDER BY il.InvoiceLineID;

*/ 

--------------------------------------------------------------------- END ---------------------------------------------------------------------
