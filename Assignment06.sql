--*************************************************************************--
-- Title: Assignment06
-- Author: DeniseLynch
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024-05-17,DeniseLynch,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_DeniseLynch')
	 Begin 
	  Alter Database [Assignment06DB_DeniseLynch] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_DeniseLynch;
	 End
	Create Database Assignment06DB_DeniseLynch;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_DeniseLynch;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

Create View vCategories 
WITH SCHEMABINDING
As
SELECT CategoryID, CategoryName from dbo.Categories;
go

Create View vProducts
WITH SCHEMABINDING
As
SELECT ProductID, ProductName, CategoryID, UnitPrice from dbo.Products;
go

Create View vEmployees
WITH SCHEMABINDING
As
SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID from dbo.Employees;
go

Create View vInventories
WITH SCHEMABINDING
As
SELECT InventoryID, InventoryDate, EmployeeId, ProductID, [Count] from dbo.Inventories;
go


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On dbo.Categories to Public;
Grant Select on vCategories to Public;

Deny Select On dbo.Products to Public;
Grant Select on vProducts to Public;

Deny Select On dbo.Employees to Public;
Grant Select on vEmployees to Public;

Deny Select On dbo.Inventories to Public;
Grant Select on vInventories to Public;


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create View vProductsByCategories
AS
SELECT 
	c.CategoryName,
	p.ProductName,
	p.UnitPrice
FROM
	Categories c
JOIN
	Products p ON c.CategoryID = p.CategoryID


Select * From vProductsByCategories Order By CategoryName, ProductName;

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create View vInventoriesByProductsByDates
AS
SELECT 
	p.ProductName,
	i.InventoryDate,
	i.[Count]
FROM
	Products p
JOIN
	Inventories i ON i.ProductID = p.ProductID

SELECT * FROM vInventoriesByProductsByDates Order by ProductName, InventoryDate, [Count]

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

Create View vInventoriesByEmployeesByDates
AS
SELECT DISTINCT
	i.InventoryDate,
	e.EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
FROM
	Employees e
JOIN
	Inventories i ON i.EmployeeID = e.EmployeeID

SELECT * FROM vInventoriesByEmployeesByDates Order By InventoryDate, EmployeeName

-- Here are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create View vInventoriesByProductsByCategories
AS
SELECT 
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.[Count]
FROM
	Categories c
JOIN
	Products p ON p.CategoryID = c.CategoryID
JOIN
	Inventories i ON i.ProductID = p.ProductID

SELECT * FROM vInventoriesByProductsByCategories Order By CategoryName, ProductName, InventoryDate, [Count]


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create View vInventoriesByProductsByEmployees
AS
SELECT 
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.[Count],
	e.EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
FROM
	Inventories i
JOIN
	Products p ON i.ProductID = p.ProductID
JOIN
	Categories c ON p.CategoryID = c.CategoryID
JOIN
	Employees e ON i.EmployeeID = e.EmployeeID

SELECT * FROM vInventoriesByProductsByEmployees Order By InventoryDate, CategoryName, ProductName, EmployeeName


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create View vInventoriesForChaiAndChangByEmployees
AS
SELECT 
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.[Count],
	e.EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
FROM
	Inventories i
JOIN
	Products p ON i.ProductID = p.ProductID
JOIN
	Categories c ON p.CategoryID = c.CategoryID
JOIN
	Employees e ON i.EmployeeID = e.EmployeeID
WHERE
	p.ProductName IN ('Chai', 'Chang')

SELECT * FROM vInventoriesForChaiAndChangByEmployees Order By InventoryDate, CategoryName, ProductName, EmployeeName

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create View vEmployeesByManager
AS
SELECT
	m.EmployeeFirstName + ' ' + m.EmployeeLastName as Manager,
	e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee
FROM
	Employees as e
JOIN
	Employees as M ON e.ManagerID = M.EmployeeID

SELECT * FROM vEmployeesByManager Order By Manager, Employee

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
SELECT
	v3.CategoryID,
	v3.CategoryName,
	v2.ProductID,
    v2.ProductName,
	v2.UnitPrice,
    v1.InventoryID,
	v1.InventoryDate,
	v1.[Count],
	v4.EmployeeID,
    v4.EmployeeFirstName + ' ' + v4.EmployeeLastName AS Employee,
	m.EmployeeFirstName + ' ' + m.EmployeeLastName AS Manager
FROM
    vInventories v1
JOIN
    vProducts v2 ON v1.ProductID = v2.ProductID
JOIN
    vCategories v3 ON v2.CategoryID = v3.CategoryID
JOIN
    vEmployees v4 ON v1.EmployeeID = v4.EmployeeID
LEFT JOIN
    Employees m ON v4.ManagerID = m.EmployeeID;

SELECT * FROM vInventoriesByProductsByCategoriesByEmployees Order By CategoryName, ProductID, InventoryID, Employee

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/