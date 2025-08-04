/* -- Thực hành buổi 2
Học viên: Phạm Minh Ngọc Hà (Harmony Pham)
Nguồn dữ liệu: AdventureWorks2019 
-- */
USE AdventureWorks2019
GO


/* Câu 1
Yêu cầu: Tính số lượng quản lý theo năm sinh. JobTitle của quản lý có từ Manager. Sắp xếp theo năm sinh giảm dần.
Nguồn: Bảng HumanResources.Employee
*/
SELECT YEAR(BirthDate) AS [Year], COUNT(*) AS NbOfPeople 
FROM HumanResources.Employee
WHERE JobTitle LIKE '%Manager%'
GROUP BY YEAR(BirthDate)
ORDER BY YEAR(BirthDate) DESC

-- Tính số lượng người/ nhân viên theo nắm sinh)
SELECT YEAR(BirthDate) AS [Year], COUNT(*) AS NbOfPeople 
FROM HumanResources.Employee
GROUP BY YEAR(BirthDate)
ORDER BY YEAR(BirthDate) DESC

/* Câu 2
Yêu cầu: Lấy danh sách nhân viên bán hàng có thêm cột FullName được tạo ra bằng cách nối các chuỗi FirstName, MiddleName, LastName. 
Sắp xếp theo FullName tăng dần.
Nguồn: Bảng Person.Person
Gợi ý: PersonType=SP thì là nhân viên bán hàng.
*/

SELECT BusinessEntityID, PersonType, NameStyle, FirstName, MiddleName, LastName,
CASE WHEN NameStyle = 0 THEN CONCAT(FirstName, ' ', MiddleName,' ', LastName) -- Western Name
WHEN NameStyle = 1 THEN CONCAT(LastName,' ', MiddleName,' ', FirstName) -- Vietnamese Name
END AS FullName
FROM Person.Person
WHERE PersonType = 'SP'
ORDER BY FullName

/* Câu 3
Yêu cầu: Tính thể tích hình cầu (khối cầu) biết bán kính hình cầu là 8 cm.
Làm tròn đến 3 chữ số sau dấu phẩy.
Gợi ý: V = 4/3 * pi * r^3.
*/
SELECT ROUND(4 / 3 * PI() * POWER(8, 3), 3) AS 'Thể Tích Khối Cầu (cm^3)'

/* Câu 4
Yêu cầu: Lấy 5 khách hàng ở Mỹ hoặc Canada có tổng tiền đơn hàng lớn nhất trong 1 tuần qua (với ngày hiện tại là 15/08/2013)
Nguồn: Bảng Sales.SalesOrderHeader
Gợi ý: SELECT, TOP, DATEADD, GROUP BY, ORDER BY
*/
-- Tất cả khách hàng
SELECT CustomerID, SUM(TotalDue) AS 'TotalAmount'
FROM Sales.SalesOrderHeader
WHERE TerritoryID IN (1,2,3,4,5,6) AND OrderDate >= DATEADD(DAY, -7, '2013-08-15') AND OrderDate <= '2013-08-15'
GROUP BY CustomerID
ORDER BY TotalAmount DESC

-- Top 5
SELECT Top(5) CustomerID, SUM(TotalDue) AS 'TotalAmount'
FROM Sales.SalesOrderHeader
WHERE TerritoryID IN (1,2,3,4,5,6) AND OrderDate >= DATEADD(DAY, -7, '2013-08-15') AND OrderDate <= '2013-08-15'
GROUP BY CustomerID
ORDER BY TotalAmount DESC

/* Câu 5
Yêu cầu: Lấy danh sách đơn hàng chỉ bán duy nhất một sản phẩm.
Nguồn dữ liệu: Bảng Sales.SalesOrderDetail
Gợi ý: SELECT, MIN, SUM, GROUP BY, HAVING, COUNT, ORDER BY
*/
-- Cách chọn 1 sản phẩm 
SELECT SalesOrderID, COUNT(ProductID) AS 'NbOfProducts'
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING COUNT(ProductID) = 1

-- Hoàn thiện vơics các phép tính
SELECT SalesOrderID, COUNT(ProductID) AS 'NbOfProducts', MIN(ProductID) AS ProductID, 
ROUND(SUM(LineTotal),2) AS TotalAmount, SUM(OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING COUNT(ProductID) = 1
ORDER BY SalesOrderID

/* Câu 6
Yêu cầu: Tính doanh thu của các vùng ở Mỹ hoặc Canada và tỷ trọng phần trăm trên doanh thu tổng của cả hệ thống qua từng năm
Nguồn: Bảng Sales.SalesOrderHeader
Gợi ý: SELECT, YEAR, SUM, CASE WHEN, FROM, GROUP BY, ORDER BY
*/
-- My Answer:
SELECT YEAR(OrderDate) AS [Year], 
SUM(CASE WHEN TerritoryID IN (1,2,3,4,5,6) THEN TotalDue ELSE 0 END) AS SalesAmount,
SUM(TotalDue) AS TotalAmount,
ROUND(SUM(CASE WHEN TerritoryID IN (1,2,3,4,5,6) THEN TotalDue ELSE 0 END)/ NULLIF(SUM(TotalDue),0), 2) AS Ratio
FROM Sales.SalesOrderHeader
WHERE TerritoryID IN (1,2,3,4,5,6) 
GROUP BY YEAR(OrderDate)
ORDER BY [Year]

-- Right Answer:
SELECT YEAR(OrderDate) as [Year], 
SUM(CASE WHEN TerritoryID in (1,2,3,4,5,6) THEN TotalDue ELSE 0 END ) as SalesAmount,
SUM(TotalDue) as TotalAmount,
ROUND(SUM(CASE WHEN TerritoryID in (1,2,3,4,5,6) THEN TotalDue ELSE 0 END ) / NULLIF(SUM(TotalDue), 0), 2) as Ratio
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY [Year]

-- Reasoning:


/* Câu 7
Yêu cầu: Lấy thông tin bán hàng của các sản phẩm chưa bao giờ thay đổi giá bán
Nguồn: Bảng Sales.SalesOrderDetail
Gợi ý: SELECT, SUM, MIN, MAX, FROM, GROUP BY, HAVING, ORDER BY
*/
SELECT ProductID, ROUND(SUM(LineTotal), 2) AS TotalAmount, ROUND(SUM(OrderQty), 2) AS TotalQuantity,
ROUND(MIN(UnitPrice), 2) AS MinUnitPrice, ROUND(MAX(UnitPrice), 2) AS MaxUnitPrice
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING Min(UnitPrice) = MAX(UnitPrice)
ORDER BY ProductID

/* Câu 8
Yêu cầu: Lấy danh sách khách hàng, số đơn hàng, tổng tiền và giá trị đơn hàng trung bình khách hàng đó 
mua trong 365 ngày gần nhất với ngày hiện tại là 15/08/2013.
Chú ý chỉ xét lấy những khách hàng mua từ 2 đơn trở lên và sắp xếp theo chiều tổng tiền giảm dần và mã khách hàng tăng dần.
Nguồn: Bảng Sales.SalesOrderHeader
Gợi ý: SELECT, SUM, COUNT, ROUND, DATEADD, GROUP BY, HAVING, ORDER BY
*/
-- Caculate Number of Order, Total Amount, and Average Order Amount
SELECT CustomerID, COUNT(SalesOrderID) AS 'NbOfOrder', SUM(TotalDue) AS TotalAmount, AVG(TotalDue) AS AvgOrderAmount
FROM Sales.SalesOrderHeader
GROUP BY CustomerID

-- Completed Code
SELECT CustomerID, COUNT(SalesOrderID) AS 'NbOfOrder', ROUND(SUM(TotalDue), 2) AS TotalAmount, ROUND(AVG(TotalDue), 2) AS AvgOrderAmount
FROM Sales.SalesOrderHeader
WHERE OrderDate >= DATEADD(DAY, -365, '2013-08-15') AND OrderDate <= '2013-08-15'
GROUP BY CustomerID
HAVING COUNT(SalesOrderID) >= 2
ORDER BY TotalAmount DESC, CustomerID ASC 




