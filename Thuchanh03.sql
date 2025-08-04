/* -- Thực hành buổi 3
Học viên: Phạm Minh Ngọc Hà (Harmony Pham)
Nguồn dữ liệu: AdventureWorks2019 
-- */
USE AdventureWorks2019
GO

/* -----------------------------------------------------------------------------------------------------------------
1. Thực hành SQL (INNER) JOIN
*/
--1.1. Lấy danh sách khách hàng cá nhân
-- Bước 1: Lấy danh sách mã khách hàng cá nhân từ bảng Sales.Customer
SELECT CustomerID, PersonID, TerritoryID
FROM Sales.Customer
WHERE c.StoreID IS NULL

-- Bước 2: Lấy thông tin khách hàng từ bảng Person.Person (JOIN)
SELECT CustomerID, PersonID, TerritoryID, CONCAT(p.FirstName, ' ', p.MiddleName, ' ', p.LastName) AS CustomerName
FROM Sales.Customer c
JOIN Person.Person p 
on c.PersonID = p.BusinessEntityID
WHERE c.StoreID IS NULL
ORDER BY CustomerID

-- 1.2. Lấy thông tin cây sản phẩm bao gồm: mã sản phẩm, tên sản phẩm, mã nhóm hàng, tên nhóm hàng, mã ngành hàng, tên ngành hàng
SELECT 
FROM Sales.Customer

