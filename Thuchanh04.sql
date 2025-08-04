/* -- Thực hành buổi 4
Học viên: Phạm Minh Ngọc Hà (Harmony Pham)
Nguồn dữ liệu: AdventureWorks2019 
-- */

USE AdventureWorks2019
GO

/* -----------------------------------------------------------------------------------------------------------------
Bước 1: Thực hành SQL Subqueries
*/

-- 1.1. Lấy danh sách nhân viên trẻ nhất công ty
SELECT BusinessEntityID as EmployeeID, NationalIDNumber, JobTitle, BirthDate, MaritalStatus, Gender, YEAR(GETDATE()) - YEAR(BirthDate) AS Age
FROM HumanResources.Employee 
WHERE YEAR(BirthDate) = (SELECT MAX(YEAR(BirthDate)) FROM HumanResources.Employee)
ORDER BY BusinessEntityID

-- 1.2. Lấy danh sách nhân viên nhiều tuổi nhất công ty 
SELECT BusinessEntityID as EmployeeID, NationalIDNumber, JobTitle, BirthDate, MaritalStatus, Gender, YEAR(GETDATE()) - YEAR(BirthDate) AS Age
FROM HumanResources.Employee 
WHERE YEAR(BirthDate) = (SELECT MIN(YEAR(BirthDate)) FROM HumanResources.Employee)
ORDER BY BusinessEntityID

-- 1.3. Lấy danh sách sản phẩm bán ra được trên 1000 sản phẩm trong năm 2012
-- Bước 1: JOIN bảng Sales.SalesOrderDetail và bảng Sales.SalesOrderHeader để lấy danh sách mã sản phẩm bán ra được trên 1000 cái trong năm 2012
SELECT  ProductID
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
WHERE YEAR(OrderDate) = 2012
GROUP BY ProductID
HAVING SUM(OrderQty) > 1000

-- Bước 2: Lấy thêm thông tin về sản phẩm từ các bảng Production.Product, Production.ProductSubcategory, Production.ProductCategory
-- Cách 1: Sử dụng Subqueries ở câu lệnh WHERE
SELECT c.ProductCategoryID, c.Name as ProductCategoryName, sc.ProductSubcategoryID, sc.Name as ProductSubcategoryName,
ProductID, p.Name as ProductName, ProductNumber, Color, 
CASE ProductLine 
    WHEN 'R' THEN 'Road'
    WHEN 'M' THEN 'Mountain'
    WHEN 'T' THEN 'Touring'
    WHEN 'S' THEN 'Standard'
END AS ProductLine
FROM Production.Product p
JOIN Production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
WHERE ProductID in (
    SELECT  ProductID
    FROM Sales.SalesOrderDetail d
    JOIN Sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
    WHERE YEAR(OrderDate) = 2012
    GROUP BY ProductID
    HAVING SUM(OrderQty) > 1000
)
ORDER BY c.ProductCategoryID, sc.ProductSubcategoryID, p.ProductID
-- Cách 2: Tạo bảng ảo từ câu truy vấn ở bước 1 sau đó JOIN với các bảng khác để lấy thông tin
SELECT c.ProductCategoryID, c.Name as ProductCategoryName, sc.ProductSubcategoryID, sc.Name as ProductSubcategoryName,
p.ProductID, p.Name as ProductName, ProductNumber, Color, 
CASE ProductLine 
    WHEN 'R' THEN 'Road'
    WHEN 'M' THEN 'Mountain'
    WHEN 'T' THEN 'Touring'
    WHEN 'S' THEN 'Standard'
END AS ProductLine, Quantity
FROM Production.Product p
JOIN Production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
JOIN (
    SELECT  ProductID, SUM(OrderQty) AS Quantity
    FROM Sales.SalesOrderDetail d
    JOIN Sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
    WHERE YEAR(OrderDate) = 2012
    GROUP BY ProductID
    HAVING SUM(OrderQty) > 1000
) r on r.ProductID = p.ProductID
ORDER BY c.ProductCategoryID, sc.ProductSubcategoryID, p.ProductID

;WITH s AS (
SELECT CustomerID, COUNT(SalesOrderID) as NbOrders
    FROM Sales.SalesOrderHeader
    WHERE  YEAR(OrderDate) = 2012
    GROUP BY CustomerID
)
SELECT COUNT(CustomerID) as NbCustomers, SUM(NbOrders) as NbOrders, 
MIN(NbOrders) as MinOrdersPerCustomer, MAX(NbOrders) as MaxOrdersPerCustomer, AVG(NbOrders*1.0) as AvgOrdersPerCustomer
FROM s

-- 2.2. So sánh số khách hàng, số đơn hàng của năm 2012 với năm 2011
-- Bước 1: Tổng hợp thông tin bán hàng của mỗi năm
SELECT YEAR(OrderDate) as [Year], COUNT(DISTINCT CustomerID) as NbCustomers, COUNT(SalesOrderID) as NbOrders
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
-- Bước 2: Xây dựng CTE s để tái sử dụng
;WITH s AS (
SELECT YEAR(OrderDate) as [Year], COUNT(DISTINCT CustomerID) as NbCustomers, COUNT(SalesOrderID) as NbOrders
    FROM Sales.SalesOrderHeader
    GROUP BY YEAR(OrderDate)
)
SELECT * FROM s
-- Bước 3: Tính % tăng trưởng của năm 2012 so với năm 2011
;WITH s AS (
SELECT YEAR(OrderDate) as [Year], COUNT(DISTINCT CustomerID) as NbCustomers, COUNT(SalesOrderID) as NbOrders
    FROM Sales.SalesOrderHeader
    GROUP BY YEAR(OrderDate)
)
SELECT s1.[Year], 
s1.NbCustomers as NbCustomers2012, s2.NbCustomers as NbCustomers2011,
ROUND((s1.NbCustomers - s2.NbCustomers) * 100.00 / s2.NbCustomers, 2) AS [CustomerGrowthRate],
s1.NbOrders as NbOrders2012, s2.NbOrders as NbOrders2011,
ROUND((s1.NbOrders - s2.NbOrders) * 100.00 / s2.NbOrders, 2) AS [OrderGrowthRate]
FROM s s1, s s2
WHERE s1.[Year] = 2012 AND s2.[Year] = 2011

-- 2.3. Xây dựng chuỗi Fibonacci
;WITH f(RowIndex) AS (
    SELECT 1 AS RowIndex
    UNION ALL
    SELECT RowIndex + 1
    FROM f 
    WHERE f.RowIndex < 10
)
SELECT * FROM f

;WITH f(RowIndex, CurrentValue, NextValue) AS (
    SELECT 1 AS RowIndex, 1 AS CurrentValue, 1 AS NextValue
    UNION ALL
    SELECT f.RowIndex + 1 AS RowIndex, NextValue AS CurrentValue, CurrentValue + NextValue AS NextValue
    FROM f 
    WHERE f.RowIndex <= 10
)
SELECT * FROM f

-- 2.4. Lấy thông tin cây tổ chức quản lý bao gồm thông tin nhân viên và quản lý trực tiếp của nhân viên đó
-- Bước 1: Xây dựng bảng tạm o lưu thông tin về nhân viên và Path trong cây tổ chức
;WITH o AS (
    SELECT e.BusinessEntityID as EmployeeID, 
    OrganizationNode.ToString() as [Path], OrganizationLevel as [Level],
    CONCAT(p.FirstName,' ', p.MiddleName,' ', p.LastName) as EmployeeName,
    e.JobTitle 
    FROM HumanResources.Employee e 
    JOIN Person.Person p on e.BusinessEntityID = p.BusinessEntityID
)
SELECT * FROM o
-- Bước 2:
;WITH o AS (
    SELECT e.BusinessEntityID AS EmployeeID, OrganizationNode.ToString() AS [Path], OrganizationLevel AS [Level],
    CONCAT(p.FirstName, ' ', p.MiddleName, ' ', p.LastName) AS EmployeeName,
    e.JobTitle
    FROM HumanResources.Employee e
    JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
), h AS (
    SELECT EmployeeID , [Path], [Level], NULL AS ManagerID 
    FROM o WHERE [Level] IS NULL
    UNION ALL 
    SELECT EmployeeID , [Path], [Level], 1 AS ManagerID 
    FROM o WHERE [Level] = 1
    UNION ALL
    SELECT o.EmployeeID , o.[Path], o.[Level], h.EmployeeID AS ManagerID
    FROM o
    JOIN h on LEFT(o.[Path], LEN(h.[Path])) = h.[Path] AND o.[Level] = h.[Level] + 1
)
SELECT * FROM h

-- Bước 3: Bổ sung thêm thông tin chi tiết cho nhân viên và quản lý
;WITH o AS (
    SELECT e.BusinessEntityID AS EmployeeID, OrganizationNode.ToString() AS [Path], OrganizationLevel AS [Level],
    CONCAT(p.FirstName, ' ', p.MiddleName, ' ', p.LastName) AS EmployeeName,
    e.JobTitle
    FROM HumanResources.Employee e
    JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
), h AS (
    SELECT EmployeeID , [Path], [Level], NULL AS ManagerID 
    FROM o WHERE [Level] IS NULL
    UNION ALL 
    SELECT EmployeeID , [Path], [Level], 1 AS ManagerID 
    FROM o WHERE [Level] = 1
    UNION ALL
    SELECT o.EmployeeID , o.[Path], o.[Level], h.EmployeeID AS ManagerID
    FROM o
    JOIN h on LEFT(o.[Path], LEN(h.[Path])) = h.[Path] AND o.[Level] = h.[Level] + 1
)
SELECT h.EmployeeID, oe.EmployeeName, oe.JobTitle, h.[Path], h.[Level], 
h.ManagerID, om.EmployeeName as ManagerName, om.JobTitle as ManagerTitle
FROM h
LEFT JOIN o oe on h.EmployeeID = oe.EmployeeID
LEFT JOIN o om on h.ManagerID = om.EmployeeID
ORDER BY h.[Path]

--SELECT SUBSTRING('/1/2/', 2, LEN('/1/2/') - 2)
/* -----------------------------------------------------------------------------------------------------------------
Bước 3: Thực hành View
*/
-- 3.1. Truy vấn lấy thông tin cửa hàng đại lý kèm Demographics
SELECT BusinessEntityID, Name, BusinessType, YearOpened, NumberEmployees 
FROM Sales.vStoreWithDemographics ORDER BY BusinessEntityID

-- 3.2. Tạo view lấy thông tin danh mục sản phẩm
-- Bước 1: 
GO
CREATE OR ALTER VIEW [dbo].[vProductCatalog]
AS 
SELECT -- thông tin cây sản phẩm bao gồm: mã sản phẩm, tên sản phẩm, mã nhóm hàng, tên nhóm hàng, mã ngành hàng, tên ngành hàng
c.ProductCategoryID, c.Name as ProductCategoryName,
sc.ProductSubcategoryID, sc.Name as ProductSubcategoryName,
p.ProductID, p.Name as ProductName
FROM Production.Product p
JOIN Production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
-- ORDER BY c.ProductCategoryID, sc.ProductSubcategoryID, p.ProductID
GO
-- Bước 2: Truy vấn view vừa tạo
SELECT ProductCategoryID, ProductCategoryName, ProductSubcategoryID, ProductSubcategoryName, ProductID, ProductName
FROM dbo.vProductCatalog
ORDER BY ProductCategoryID, ProductSubcategoryID, ProductID

--------------------------------------------------------------------------------------------
-- Lấy số từ 1 đến 10
;WITH f(RowIndex) AS (
    SELECT 1 AS RowIndex
    UNION ALL
    SELECT RowIndex + 1
    FROM f 
    WHERE f.RowIndex < 10
)
SELECT * FROM f