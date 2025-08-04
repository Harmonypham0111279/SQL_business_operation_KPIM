/* -- Thực hành buổi 5
Học viên: Phạm Minh Ngọc Hà (Harmony Pham)
Nguồn dữ liệu: AdventureWorks2019 
-- */

USE AdventureWorks2019
GO

/* -----------------------------------------------------------------------------------------------------------------
Bước 1: Thực hành sử dụng SQL truy vấn dữ liệu theo yêu cầu
*/ 

SELECT TOP(100) * FROM Production.Product
SELECT TOP(100) * FROM Production.[Location]
SELECT TOP(100) * FROM Production.ProductInventory 
SELECT TOP(100) * FROM Sales.vStoreWithContacts

/* 1.1
Yêu cầu: Lấy ra danh sách sản phẩm thỏa mãn các điều kiện sau
- Mã sản phẩm bắt đầu bằng cụm FR, kết thúc là 2 chữ số từ 0 đến 9
- Sản phẩm có màu trắng, đỏ hoặc đen
Nguồn dữ liệu: Bảng Production.Product
*/
SELECT ProductID, Name, ProductNumber, Color, Size
FROM Production.Product
WHERE ProductNumber LIKE 'FR%[0-9][0-9]' AND Color IN ('Black', 'Red', 'White')
ORDER BY ProductID

/* 1.2
Yêu cầu: Lấy danh sách các sản phẩm bán ra có số lượng tồn kho bé hơn hoặc bằng mức tồn kho tối thiểu quy định
Nguồn dữ liệu: Bảng Production.Product và bảng Production.ProductInventory
Trong bảng Product
+ cột FinishedGoodsFlag để đánh dấu có phải sản phẩm bán ra hay không
+ cột ReorderPoint quy định số lượng tồn kho tối thiểu của một sản phẩm
*/

;WITH p AS (
SELECT c.ProductCategoryID, c.Name as ProductCategoryName, sc.ProductSubcategoryID, sc.Name as ProductSubcategoryName,
    p.ProductID, p.Name as ProductName, ProductNumber,
    CASE ProductLine 
        WHEN 'R' THEN 'Road'
        WHEN 'M' THEN 'Mountain'
        WHEN 'T' THEN 'Touring'
        WHEN 'S' THEN 'Standard'
    END AS ProductLine,
    MakeFlag, FinishedGoodsFlag, ReorderPoint
    FROM Production.Product p
    LEFT JOIN Production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
), i AS (
SELECT i.ProductID, SUM(Quantity) AS Quantity
    FROM Production.ProductInventory i 
    JOIN p ON i.ProductID = p.ProductID
    WHERE FinishedGoodsFlag = 1
    GROUP BY i.ProductID
)
SELECT p.ProductCategoryName, p.ProductSubcategoryName, p.ProductID, p.ProductName, ReorderPoint, i.Quantity
FROM i 
JOIN p ON i.ProductID = p.ProductID
WHERE Quantity <= ReorderPoint
ORDER BY ProductCategoryID, ProductSubcategoryID, ProductID

/* 1.3
Yêu cầu: Tính doanh thu các cửa hàng ở châu Âu (Group = Europe) trong năm 2013 
đồng thời lọc ra danh sách cửa hàng có doanh thu trên 100000 và lấy thêm thông tin liên hệ của các cửa hàng đại lý
Nguồn dữ liệu: Bảng Sales.SalesOrderHeader, Sales.SalesOrderDetail, Sales.Customer, Sales.SalesTerritory, Sales.vStoreWithContacts 
*/

;WITH sales AS (
    SELECT t.TerritoryID, StoreID, SUM(LineTotal) AS SalesAmount
    FROM Sales.SalesOrderHeader h
    JOIN Sales.SalesOrderDetail d ON h.SalesOrderID = d.SalesOrderID 
    JOIN Sales.Customer c ON h.CustomerID = c.CustomerID
    JOIN Sales.SalesTerritory t ON c.TerritoryID = t.TerritoryID
    WHERE StoreID IS NOT NULL AND [Group] = 'Europe' AND YEAR(OrderDate) = 2013
    GROUP BY t.TerritoryID, StoreID
    HAVING SUM(LineTotal) > 100000
) 
SELECT t.TerritoryID, t.Name AS TerritoryName, 
sales.StoreID, s.Name AS StoreName, s.ContactType, 
CONCAT(s.Title, ' ', s.FirstName, ' ', s.MiddleName, ' ', s.LastName) AS ContactName, 
s.PhoneNumber, sales.SalesAmount
FROM sales 
JOIN Sales.SalesTerritory t ON sales.TerritoryID = t.TerritoryID
JOIN Sales.vStoreWithContacts s ON sales.StoreID = s.BusinessEntityID
ORDER BY t.TerritoryID, StoreID

/* 1.4
Yêu cầu: Với mỗi năm, thực hiện phân loại sản phẩm thuộc ngành hàng 'Bikes' dựa trên số lượng sản phẩm bán ra. 
Nếu số lượng sản phẩm bán ra lớn hơn hoặc bằng số lượng sản phẩm bán ra trung bình của toàn ngành hàng thì gán nhãn là 'Cao' ngược lại là 'Thấp'
*/
;WITH p AS (
SELECT c.ProductCategoryID, c.Name as ProductCategoryName, sc.ProductSubcategoryID, sc.Name as ProductSubcategoryName,
    p.ProductID, p.Name as ProductName, ProductNumber,
    CASE ProductLine 
        WHEN 'R' THEN 'Road'
        WHEN 'M' THEN 'Mountain'
        WHEN 'T' THEN 'Touring'
        WHEN 'S' THEN 'Standard'
    END AS ProductLine,
    MakeFlag, FinishedGoodsFlag, ReorderPoint
    FROM Production.Product p
    LEFT JOIN Production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
), yp AS (
SELECT YEAR(OrderDate) AS [Year], p.ProductID, SUM(OrderQty) AS Quantity
    FROM Sales.SalesOrderDetail d 
    JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
    JOIN p ON d.ProductID = p.ProductID
    WHERE p.ProductCategoryName = 'Bikes'
    GROUP BY YEAR(OrderDate), p.ProductID
), y AS (
SELECT YEAR(OrderDate) AS [Year], COUNT(DISTINCT ProductID) AS NbProducs, SUM(OrderQty) AS Quantity, 
    SUM(OrderQty) * 1.0 /  COUNT(DISTINCT ProductID) AS AvgQuantity
    FROM Sales.SalesOrderDetail d 
    JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
    GROUP BY YEAR(OrderDate)
)

SELECT yp.[Year], yp.ProductID, p.ProductNumber, p.ProductName, p.ProductLine,
yp.Quantity, CASE WHEN yp.Quantity >= y.AvgQuantity THEN N'Cao' ELSE N'Thấp' END AS Class 
FROM yp 
JOIN y ON yp.[Year] = y.[Year]
JOIN p ON yp.ProductID = p.ProductID
ORDER BY yp.[Year], yp.ProductID

/* 1.5
Yêu cầu: Thống kê số lượng sản phẩm bán ra mỗi năm của nhóm ngành 'Bikes' theo nhóm sản phẩm (ProductSubcategory), màu sắc (Color), kích thước (Size)
*/
;WITH p AS (
SELECT c.ProductCategoryID, c.Name as ProductCategoryName, sc.ProductSubcategoryID, sc.Name as ProductSubcategoryName,
    p.ProductID, p.Name as ProductName, ProductNumber,
    CASE ProductLine 
        WHEN 'R' THEN 'Road'
        WHEN 'M' THEN 'Mountain'
        WHEN 'T' THEN 'Touring'
        WHEN 'S' THEN 'Standard'
    END AS ProductLine,
    MakeFlag, FinishedGoodsFlag, Color, [Size]
    FROM Production.Product p
    LEFT JOIN Production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
)

SELECT YEAR(OrderDate) AS [Year], p.ProductSubcategoryName, p.Color, p.Size, SUM(OrderQty) AS Quantity
FROM Sales.SalesOrderDetail d 
JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
JOIN p ON d.ProductID = p.ProductID
WHERE p.ProductCategoryName ='Bikes'
GROUP BY YEAR(OrderDate), p.ProductSubcategoryName, p.Color, p.Size
ORDER BY 1, 2, 3, 4

/* -- Chủ đề: Phân tích dữ liệu theo thời gian -- */

/* -----------------------------------------------------------------------------------------------------------------
Bước 2: Tổng hợp doanh số theo thời gian
- Xem tổng quan toàn bộ tình hình kinh doanh của doanh nghiệp
- Theo dõi sự tăng/giảm các các thời điểm khác nhau
*/
-- 2.1. Doanh số qua từng năm
SELECT FORMAT(OrderDate, 'yyyy') as Year, ROUND(SUM(LineTotal), 0) as SalesAmount
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h on h.SalesOrderID = d.SalesOrderID
GROUP BY FORMAT(OrderDate, 'yyyy')
ORDER BY Year

-- 2.2. Doanh số qua từng tháng
SELECT FORMAT(OrderDate, 'yyyy-MM') as YearMonth, EOMONTH(OrderDate) AS EndDate, 
ROUND(SUM(LineTotal), 0) as SalesAmount
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h on h.SalesOrderID = d.SalesOrderID
GROUP BY FORMAT(OrderDate, 'yyyy-MM'), EOMONTH(OrderDate)
ORDER BY YearMonth, EndDate

/* -----------------------------------------------------------------------------------------------------------------
Bước 3: Phân tích xu hướng doanh số của một ngành hàng theo thời gian.
- Xem chi tiết hơn về một ngành hàng
- Theo dõi sự tăng/giảm các các thời điểm khác nhau
*/
-- 3.1. Doanh số của ngành hàng 'Bikes' qua từng năm
SELECT FORMAT(OrderDate, 'yyyy') as Year, c.ProductCategoryID, c.Name as ProductCategoryName, 
ROUND(SUM(LineTotal), 0) as SalesAmount
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h on h.SalesOrderID = d.SalesOrderID
JOIN Production.Product p on d.ProductID = p.ProductID
JOIN Production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
WHERE c.Name = 'Bikes'
GROUP BY FORMAT(OrderDate, 'yyyy'), c.ProductCategoryID, c.Name
ORDER BY Year, c.ProductCategoryID

-- 3.2. Doanh số của ngành hàng 'Bikes' qua từng tháng
SELECT FORMAT(OrderDate, 'yyyy-MM') as YearMonth, EOMONTH(OrderDate) AS EndDate, c.ProductCategoryID, c.Name as ProductCategoryName, 
ROUND(SUM(LineTotal), 0) as SalesAmount
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h on h.SalesOrderID = d.SalesOrderID
JOIN Production.Product p on d.ProductID = p.ProductID
JOIN Production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
WHERE c.Name = 'Bikes'
GROUP BY FORMAT(OrderDate, 'yyyy-MM'), EOMONTH(OrderDate), c.ProductCategoryID, c.Name
ORDER BY YearMonth, c.ProductCategoryID

/* -----------------------------------------------------------------------------------------------------------------
Bước 4: Phân tích xu hướng doanh số của các ngành hàng theo thời gian.
- Có sự so sánh giữa các ngành hàng. Mỗi ngành hàng sẽ có một xu hướng riêng.
- Các ngành hàng sẽ có độ lớn khác nhau.
- PA1: So sánh 'Bikes' với 'Components' (Ngành hàng khác lớn nhất)
- PA2: So sánh 3 ngành hàng khác 'Bikes' với nhau ('Components', 'Clothing' với 'Accessories')
- PA3: So sánh 'Bikes' và nhóm ngành hàng còn lại  (gộp 'Components', 'Clothing' và 'Accessories' lại thành 'Orthers')
*/ 
-- Doanh thu của các ngành hàng khác nhau qua từng năm
SELECT FORMAT(OrderDate, 'yyyy') as Year, c.ProductCategoryID, c.Name as ProductCategoryName,
CONVERT(DECIMAL(18,0), SUM(LineTotal)) as SalesAmount
FROM Sales.SalesOrderDetail d
JOIN Sales.SalesOrderHeader h on h.SalesOrderID = d.SalesOrderID
JOIN Production.Product p on d.ProductID = p.ProductID
JOIN Production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
JOIN Production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
GROUP BY FORMAT(OrderDate, 'yyyy'), c.ProductCategoryID, c.Name
ORDER BY Year, c.ProductCategoryID, c.Name

-- 4.1. Doanh thu của ngành hàng 'Bikes' và nhóm ngành hàng còn lại qua từng năm
SELECT [Year], ProductCategoryID, ProductCategoryName, CONVERT(DECIMAL(18,0), SUM(LineTotal)) as SalesAmount
FROM
(SELECT FORMAT(OrderDate, 'yyyy') as Year,
    CASE WHEN c.Name='Bikes' THEN c.ProductCategoryID ELSE 0 END AS ProductCategoryID, 
    CASE WHEN c.Name='Bikes' THEN c.Name ELSE 'Others' END AS ProductCategoryName, 
    LineTotal
    FROM Sales.SalesOrderDetail d
    JOIN Sales.SalesOrderHeader h on h.SalesOrderID = d.SalesOrderID
    JOIN Production.Product p on d.ProductID = p.ProductID
    JOIN Production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
    JOIN Production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
) s
GROUP BY Year, ProductCategoryID, ProductCategoryName
ORDER BY Year, ProductCategoryID

-- 4.2. Doanh thu của các ngành hàng khác nhau qua từng tháng trong năm 2012 và năm 2013
SELECT YearMonth, EndDate, ProductCategoryID, ProductCategoryName, CONVERT(DECIMAL(18,0), SUM(LineTotal)) as SalesAmount
FROM
(SELECT FORMAT(OrderDate, 'yyyy-MM') as YearMonth, EOMONTH(OrderDate) AS EndDate,
    CASE WHEN c.Name='Bikes' THEN c.ProductCategoryID ELSE 0 END AS ProductCategoryID, 
    CASE WHEN c.Name='Bikes' THEN c.Name ELSE 'Others' END AS ProductCategoryName, 
    LineTotal
    FROM Sales.SalesOrderDetail d
    JOIN Sales.SalesOrderHeader h on h.SalesOrderID = d.SalesOrderID
    JOIN Production.Product p on d.ProductID = p.ProductID
    JOIN Production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
    JOIN Production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
    WHERE YEAR(OrderDate) IN (2012, 2013)
) s
GROUP BY YearMonth, EndDate, ProductCategoryID, ProductCategoryName
ORDER BY YearMonth, EndDate, ProductCategoryID

/* -----------------------------------------------------------------------------------------------------------------
Bước 5: Phân tích chênh lệch doanh số, tỷ lệ giữa ngành hàng 'Bikes' và nhóm ngành hàng còn lại và phần trăm tổng của ngành hàng Bikes
*/ 
-- 5.1. Theo năm
;WITH s AS (
SELECT [Year], ProductCategoryID, ProductCategoryName, CONVERT(DECIMAL(18,0), SUM(LineTotal)) as SalesAmount
    FROM
    (SELECT FORMAT(OrderDate, 'yyyy') as Year,
        CASE WHEN c.Name='Bikes' THEN c.ProductCategoryID ELSE 0 END AS ProductCategoryID, 
        CASE WHEN c.Name='Bikes' THEN c.Name ELSE 'Others' END AS ProductCategoryName, 
        LineTotal
        FROM Sales.SalesOrderDetail d
        JOIN Sales.SalesOrderHeader h on h.SalesOrderID = d.SalesOrderID
        JOIN Production.Product p on d.ProductID = p.ProductID
        JOIN Production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
        JOIN Production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
    ) s
    GROUP BY Year, ProductCategoryID, ProductCategoryName
    -- ORDER BY Year, ProductCategoryID
), yearly AS (
SELECT [Year], 
    SUM(CASE WHEN ProductCategoryName='Bikes' THEN SalesAmount ELSE 0 END) AS Bikes,
    SUM(CASE WHEN ProductCategoryName='Others' THEN SalesAmount ELSE 0 END) AS Others,
    SUM(SalesAmount) AS [Total]
    FROM s
    GROUP BY [Year]
) 

SELECT [Year], Bikes - Others AS Difference, ROUND(Bikes / Others, 1) AS Ratio, 
ROUND(Bikes * 100 / Total, 2) AS BikesPercentOfTotal, ROUND(Others * 100 / Total, 2) AS OthersPercentOfTotal
FROM yearly
ORDER BY [YEAR]

-- 5.2. Theo tháng
;WITH s AS (
SELECT YearMonth, EndDate, ProductCategoryID, ProductCategoryName, CONVERT(DECIMAL(18,0), SUM(LineTotal)) as SalesAmount
    FROM
    (SELECT FORMAT(OrderDate, 'yyyy-MM') as YearMonth, EOMONTH(OrderDate) AS EndDate,
        CASE WHEN c.Name='Bikes' THEN c.ProductCategoryID ELSE 0 END AS ProductCategoryID, 
        CASE WHEN c.Name='Bikes' THEN c.Name ELSE 'Others' END AS ProductCategoryName, 
        LineTotal
        FROM Sales.SalesOrderDetail d
        JOIN Sales.SalesOrderHeader h on h.SalesOrderID = d.SalesOrderID
        JOIN Production.Product p on d.ProductID = p.ProductID
        JOIN Production.ProductSubcategory sc on p.ProductSubcategoryID = sc.ProductSubcategoryID
        JOIN Production.ProductCategory c on sc.ProductCategoryID = c.ProductCategoryID
        WHERE YEAR(OrderDate) IN (2012, 2013)
    ) s
    GROUP BY YearMonth, EndDate, ProductCategoryID, ProductCategoryName
    --ORDER BY YearMonth, EndDate, ProductCategoryID
), monthly AS (
SELECT YearMonth, EndDate, 
    SUM(CASE WHEN ProductCategoryName='Bikes' THEN SalesAmount ELSE 0 END) AS Bikes,
    SUM(CASE WHEN ProductCategoryName='Others' THEN SalesAmount ELSE 0 END) AS Others,
    SUM(SalesAmount) AS [Total]
    FROM s
    GROUP BY YearMonth, EndDate
) 

SELECT YearMonth, EndDate, Bikes - Others AS Difference, ROUND(Bikes / Others, 1) AS Ratio, 
ROUND(Bikes * 100 / Total, 2) AS BikesPercentOfTotal, ROUND(Others * 100 / Total, 2) AS OthersPercentOfTotal
FROM monthly
ORDER BY YearMonth, EndDate