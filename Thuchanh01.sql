/*-- Thực hành buổi 1
Học viên: Phạm Minh Ngọc Hà (Harmony Pham)
Nguồn dữ liệu: Adventurework2019
*/

USE AdventureWorks2019
GO

SELECT 1

-- 1. Lấy toàn bộ thông tin sản phẩm sản xuất/ bán ra
SELECT * FROM Production.Product

-- 1.1. Lấy toàn bộ thông tin sản phẩm đầu tiên theo thứ tự mặc định
SELECT TOP(100)* FROM Production.Product

-- 1.2. Lấy toàn bộ thông tin sản phẩm theo yêu cầu
SELECT TOP(100) ProductID, ProductNumber, Name as ProductName, Color, Size, Weight, Class, Style
FROM Production.Product
ORDER BY Name

-- 1.3. Sản phẩm do công ty sản xuất/bán ra có các loại màu sắc nào? 
SELECT DISTINCT Color FROM Production.Product
WHERE Color IS NOT NULL

-- 1.4. Lấy thông tin đơn hàng bao gồm: 
+ mã đơn hàng, mã đơn bán hàng, mã đơn mua hàng, ngày đặt hàng, ngày đến hạn phải chuyển, ngày chuyển đến,  
+ mã khách hàng, mã nhân viên bán hàng, mã vùng
+ tổng tiền hàng, tiền thuế, phí vận chuyển, tổng tiền -- */
   SELECT SalesOrderID, SalesOrderNumber, PurchaseOrderNumber, 
   OrderDate, DueDate, ShipDate,
   CustomerID, SalesPersonID, TerritoryID,
   Subtotal, TaxAmt, Freight, TotalDue
   FROM Sales.SalesOrderHeader

/* -- 1.5. Lấy thông tin đơn hàng chi tiết bao gồm: 
+ mã đơn hàng, mã dòng đơn hàng, mã sản phẩm, số lượng, đơn giá, phần trăm khuyến mãi, tiền hàng
+ Đổi tên cột OrderQty thành Quantity -- */
SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty AS Quantity, UnitPrice, UnitPrice, UnitPriceDiscount, LineTotal
FROM Sales.SalesOrderDetail AS d
ORDER BY SalesOrderID, SalesOrderDetailID

/* -----------------------------------------------------------------------------------------------------------------
Bước 2: Thực hành SQL WHERE với toán tử so sánh (tìm thông tin)
*/
-- 2.1. Danh sách sản phẩm màu trắng
SELECT * 
FROM Production.Product
WHERE Color='WHITE'

-- 2.2. Danh sách đơn hàng khách hàng mua vào ngày 31/05/2011
SELECT SalesOrderID, OrderDate, CustomerID 
FROM Sales.SalesOrderHeader
WHERE OrderDate = '2011-05-31'
ORDER BY SalesOrderID


-- 2.3. Danh sách đơn hàng khách hàng có mã là 29491 đặt mua vào năm 2011 và sắp xếp theo thứ tự thời gian
SELECT SalesOrderID, OrderDate, CustomerID
FROM Sales.SalesOrderHeader
WHERE CustomerID = 29491 AND YEAR(OrderDate) = 2011
ORDER BY OrderDate

-- 2.4. Danh sách đơn hàng khách hàng đặt mua vào tháng 6 năm 2011. Sắp xếp theo thứ tự thời gian và mã khách hàng
SELECT SalesOrderID, OrderDate, CustomerID
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2011-06-01' AND OrderDate <= '2011-06-30'
ORDER BY OrderDate

-- 2.4.5 Cách 2
SELECT SalesOrderID, OrderDate, CustomerID
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2011 AND MONTH(OrderDate) = 6 
ORDER BY OrderDate

-- 2.5. Danh sách các đơn hàng có tiền hàng trên 30000 trong năm 2012 trừ tháng 12
SELECT SalesOrderID, OrderDate, SubTotal, TotalDue
FROM Sales.SalesOrderHeader
WHERE TotalDue > '30000' AND YEAR(OrderDate) = '2012' AND MONTH(OrderDate) <> 12
ORDER BY OrderDate, SalesOrderID ASC 

/* -----------------------------------------------------------------------------------------------------------------
Bước 3: Thực hành SQL WHERE với toán tử logic (tìm và loại/ chọn thông tin)
*/
-- 3.1. Danh sách sản phẩm có màu trắng, màu đen hoặc màu đỏ
SELECT ProductID, ProductNumber, Name, Color, Size, Weight, Class, Style 
FROM Production.Product
WHERE Color in('WHITE', 'BLACK', 'RED')

-- 3.2. Danh sách sản phẩm có màu trắng và có size S,M,L hoặc XL
SELECT ProductID, ProductNumber, Name, Color, Size, Weight, Class, Style 
FROM Production.Product
WHERE Color = 'White' AND Size in('S','M','L','XL')

-- 3.3. Danh sách sản phẩm có màu trắng và size L hoặc sản phẩm màu đen và size XL
SELECT ProductID, ProductNumber, Name, Color, Size, Weight, Class, Style
FROM Production.Product
WHERE (Color='White' AND Size = 'L') OR (Color = 'Black' AND Size ='XL')

-- 3.4. Lấy thông tin các sản phẩm có chữ 'Sport' ở trong tên. Sắp xếp theo mã sản phẩm
SELECT ProductID, ProductNumber, Name, Color, Size, Weight, Class, Style
FROM Production.Product
WHERE Name LIKE '%Sport%'
ORDER BY ProductID

-- 3.4.5 Lấy thông tin các sản phẩm có chữ 'Sport' ở đầu
SELECT ProductID, ProductNumber, Name, Color, Size, Weight, Class, Style
FROM Production.Product
WHERE Name LIKE 'Sport%'
ORDER BY ProductID

-- 3.5. Lấy thông tin các sản phẩm có màu sắc và kích cỡ (giá trị không null)
SELECT ProductID, ProductNumber, Name, Color, Size, Weight, Class, Style
FROM Production.Product
WHERE Color IS NOT NULL AND Size IS NOT NULL
ORDER BY ProductID

/* -----------------------------------------------------------------------------------------------------------------
Bước 4: Thực hành toán tử số học (tính) toán)
*/
-- 4.1. Tính tổng tiền đơn hàng 43898 theo công thức ToTalSalesAmount = SubTotal + TaxAmt + Freight. Kiểm tra so sánh với TotalDue
SELECT SalesOrderID, SubTotal, TaxAmt, Freight, TotalDue, 
SubTotal + TaxAmt + Freight AS TotalSalesAmount
FROM Sales.SalesOrderHeader
WHERE SalesOrderID = 43898

-- 4.2. Tính giá trị tiền hàng ở mỗi dòng đơn hàng của đơn hàng mã 43898 theo công thức sau: LineSalesAmount = OrderQty * UnitPrice * (1 - UnitPriceDiscount)
-- My Code
SELECT SalesOrderID, OrderQty, UnitPrice, ProductID, UnitPriceDiscount,
OrderQty * UnitPrice * (1 - UnitPriceDiscount) AS LineSalesAmount
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43898
ORDER BY ProductID

-- KPIM's code
SELECT SalesOrderID, SalesOrderDetailID, ProductID, OrderQty, UnitPrice, UnitPriceDiscount, LineTotal,
OrderQty * UnitPrice * (1 - UnitPriceDiscount) as LineSalesAmount
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43898
ORDER BY ProductID

-- Reason: You have to list the SELECT in the right order of the board
SELECT SalesOrderID, ProductID, OrderQty, UnitPrice, UnitPriceDiscount,
OrderQty * UnitPrice * (1 - UnitPriceDiscount) AS LineSalesAmount
FROM Sales.SalesOrderDetail
WHERE SalesOrderID = 43898
ORDER BY ProductID




