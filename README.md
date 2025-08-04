# SQL_business_operation_KPIM

# AdventureWorks SQL Business Analysis

## 1. Background & Overview
AdventureWorks Cycles is a fictitious bicycle manufacturing company, represented by a sample SQL Server database developed by Microsoft. This dataset simulates real-world business operations across Sales, Purchasing, Manufacturing, Product Management, and Human Resources.

This project uses advanced SQL techniques to analyze overall financial performance across multiple dimensions — including revenue, cost, product profitability, and regional performance — and provides strategic business recommendations for the upcoming fiscal year.

---

## 2. Data Structure Overview
The AdventureWorks database includes normalized tables spanning several domains:

| Domain             | Table Name(s)                                    | Purpose                                                  |
|--------------------|--------------------------------------------------|----------------------------------------------------------|
| Sales              | Sales.SalesOrderHeader, Sales.SalesOrderDetail   | Capture transaction-level data such as revenue and costs |
| Product Management | Production.Product, Production.ProductSubcategory| Provide product granularity and hierarchy                |
| Geography          | Person.Address, Person.StateProvince             | Offer geographic insights for customers                  |
| Purchasing         | Purchasing.PurchaseOrderDetail, Purchasing.Vendor| Represent supplier-side procurement data                 |
| Human Resources    | HumanResources.Employee, EmployeePayHistory      | Track employee details and compensation                  |


---

## 3. Executive Summary
This SQL-based analysis provides insights into:

- Seasonal sales performance across Christmas periods
- Top-performing and underperforming product categories
- Profitability metrics including cost and margin evaluations
- Operational inefficiencies, such as excess inventory or slow-moving SKUs
- Regional demand trends derived from shipping and billing data

---

## 4. Tools & Techniques
- Microsoft SQL Server

**Key SQL Concepts Applied**:
- Common Table Expressions (CTEs)
- Aggregate functions: `SUM()`, `AVG()`
- `GROUP BY` and `HAVING` clauses
- Filtering with `WHERE`
- Nested subqueries
- JOIN operations
- Window functions (as relevant)
