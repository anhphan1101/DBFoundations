--*************************************************************************--
-- Title: Assignment06
-- Author: AnhPhan
-- Desc: This file demonstrates how to use Views
-- Change Log: When, Who, What
-- 2021-05-14,Anh Phan,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_AnhPhan')
	 Begin 
	  Alter Database Assignment06DB_AnhPhan set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_AnhPhan;
	 End
	Create Database Assignment06DB_AnhPhan;
End Try
Begin Catch
	Print Error_Number();
End Catch
Go

Use Assignment06DB_AnhPhan;
-- Create Tables (Module 01)-- run thes 4 tables together - EMPTY tables
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
Go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
Go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
Go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
Go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
Go 

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
Go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
Go

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
Go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
Go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
Go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
Go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
Go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
Go
Select * From Products;
Go
Select * From Employees;
Go
Select * From Inventories;
Go

/********************************* Questions and Answers *********************************/
/*'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
-- All 4 tables with schemaBinding 
*/
Create View vCategories
WITH SCHEMABINDING -- this Requires you to use the table's 2-part name!
AS
 Select CategoryID, CategoryName From dbo.Categories --<< 2-part name
Go

Create View vProducts
WITH SCHEMABINDING -- this Requires you to use the table's 2-part name!
AS
 Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products
Go

 Create View vEmployees
WITH SCHEMABINDING -- this Requires you to use the table's 2-part name!
AS
 Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees
Go
 
 Create View vInventories
WITH SCHEMABINDING -- this Requires you to use the table's 2-part name!
AS
 Select InventoryID, InventoryDate, EmployeeID, ProductID, Count From dbo.Inventories;
Go
 
-- Checking 
Select * From Categories;
Select * From vCategories; 
Go

Select * From Products;
Select * From vProducts;
Go


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Use Assignment06DB_AnhPhan;
Deny Select On Categories to Public
Grant Select On vCategories to Public;
Go 

Deny Select On Employees to Public
Grant Select On vEmployees to Public;
Go

Deny Select On Products to Public
Grant Select On vProducts to Public;
Go

Deny Select On Inventories to Public
Grant Select On vInventories to Public;
Go


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Create View 
vProductsByCategories 
As
 Select Top 10000 
 CategoryName
 , ProductName
 , UnitPrice
	From vCategories C
	Inner Join vProducts P
	On C.CategoryID = P.CategoryID
Order By 1,2;
Go

Select Top 3 * From vProductsByCategories;
Go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83
Create View 
vInventoriesByProductsByDates
As
 Select Top 100 Percent 
 ProductName, 
 [Count]
 , InventoryDate 
	From vProducts P
	Inner Join vInventories I
	On P.ProductID = I.ProductID
Order By 1,3,2;  --Ordered by Product, Date, and Count
Go

Select Top 3 * From vInventoriesByProductsByDates;
Go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth
Create View 
vInventoriesByEmployeesByDates
As
 Select Distinct Top 100 Percent 
 InventoryDate, 
 (EmployeeFirstName + ' ' + EmployeeLastName) As EmployeeName
	From vInventories I
	Inner Join vEmployees E
	On I.EmployeeID = E.EmployeeID
Order By 1;  --Ordered by Product, Date, and Count
Go

Select Top 3 * From vInventoriesByEmployeesByDates;
Go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54
Create View 
vInventoriesByProductsByCategories 
As
 Select Distinct Top 100 Percent 
 CategoryName, 
 ProductName, 
 InventoryDate, 
 [Count]
	From vCategories C
	Inner Join vProducts P
	On C.CategoryID = P.CategoryID
	Inner Join Inventories I
	On I.ProductID = P.ProductID
Order By 1,2,3,4;
Go

Select Top 3 * From vInventoriesByProductsByCategories;
Go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan
Create View 
vInventoriesByProductsByEmployees
As
 Select Distinct Top 100 Percent 
 CategoryName, 
 ProductName, 
 InventoryDate, 
 [Count], 
 (EmployeeFirstName + ' ' + EmployeeLastName) As EmployeeName
	From vCategories C
	Inner Join vProducts P
	On C.CategoryID = P.CategoryID
	Inner Join vInventories I
	On I.ProductID = P.ProductID
	Inner Join vEmployees E
	On I.EmployeeID = E.EmployeeID
Order By 3,1,2,5
Go

Select Top 3 * From vInventoriesByProductsByEmployees;
Go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King
Create View 
vInventoriesForChaiAndChangByEmployees
As
 Select Distinct Top 100 Percent 
 C.CategoryName, 
 ProductName, 
 InventoryDate, 
 [Count], 
 (EmployeeFirstName + ' ' + EmployeeLastName) As EmployeeName
	From vCategories C
	Inner Join vProducts P
	On C.CategoryID = P.CategoryID
	Inner Join vInventories I
	On I.ProductID = P.ProductID
	Inner Join vEmployees E
	On I.EmployeeID = E.EmployeeID
Where ProductName In ('Chai','Chang')
Order By 3,1,2,5
Go

Select Top 3 * From vInventoriesForChaiAndChangByEmployees;
Go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan
Create View vEmployeesByManager
As
 Select Distinct Top 1000
	M.EmployeeFirstName + ' ' + M.EmployeeLastName As Manager,
	E.EmployeeFirstName + ' ' + E.EmployeeLastName As Employee
From vEmployees As E
Inner Join vEmployees As M
	On E.ManagerID = M.EmployeeID
Order By 1
Go

Select Top 3 * From vEmployeesByManager;
Go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan
Create View vInventoriesByProductsByCategoriesByEmployees
As
 Select
 C.CategoryID,
 C.CategoryName,
 P.ProductID,
 P.ProductName,
 P.UnitPrice,
 I.InventoryID,
 I.InventoryDate,
 I.[Count],
 E.EmployeeID,
 E.EmployeeFirstName + ' ' + E.EmployeeLastName As Employee,
 M.EmployeeFirstName + ' ' + M.EmployeeLastName As Manager
	From vCategories C
	 Inner Join vProducts P
	 On C.CategoryID  = P.CategoryID
	 Inner Join vInventories I
	 On I.ProductID = P.ProductID
	Inner Join vEmployees E
	 On I.EmployeeID = E.EmployeeID
	Inner Join vEmployees As M
	 On E.ManagerID = M.EmployeeID;
Go

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From vCategories;
Select * From vProducts
Select * From vInventories
Select * From vEmployees

Select * From vProductsByCategories
Select * From vInventoriesByProductsByDates
Select * From vInventoriesByEmployeesByDates
Select * From vInventoriesByProductsByCategories
Select * From vInventoriesByProductsByEmployees
Select * From vInventoriesForChaiAndChangByEmployees
Select * From vEmployeesByManager
Select * From vInventoriesByProductsByCategoriesByEmployees
/***************************************************************************************/