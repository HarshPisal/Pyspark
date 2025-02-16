USE AdventureWorks2022;

--DDL 
--Q.1) Create a customer table having following column with suitable data type
--Cust_id  (automatically incremented primary key)
--Customer name (only characters must be there)
--Aadhar card (unique per customer)
--Mobile number (unique per customer)
--Date of birth (check if the customer is having age more than15)
--Address
--Address type code (B- business, H- HOME, O-office and should not accept any other)
--State code ( MH – Maharashtra, KA for Karnataka)


CREATE TABLE customer

USE supply_chain
CREATE SCHEMA QB;

CREATE TABLE QB.customer (
Cust_id INT IDENTITY PRIMARY KEY,
Customer_name char(20),
Aadhar_card VARCHAR (12) UNIQUE,
mobile_no  INT UNIQUE,
dob DATE CHECK(DATEDIFF(Year,dob,GETDATE())>15),
Address1 VARCHAR(50),
address_type CHAR(1) CHECK(LEN(address_type)=1 AND address_type IN('b','h','o')),
state_code CHAR(2) CHECK(LEN(state_code)=2));


--Create another table for Address type which is having
--Address type code must accept only (B,H,O)
--Address type  having the information as  (B- business, H- HOME, O-office)

CREATE TABLE QB.addresstype1(
address_type CHAR(1) CHECK(len(address_type)=1 and address_type IN('b','h','o')),
Information VARCHAR(50));


--Create table state_info having columns as  
--State_id  primary unique
--State name 
--Country_code char(2)

CREATE TABLE QB.state_info(
state_id INT PRIMARY KEY,
state_name VARCHAR(50),
country_code CHAR(2));

--Alter tables to link all tables based on suitable columns and foreign keys.

ALTER TABLE QB.customer ADD CONSTRAINT valid FOREIGN KEY (address_type) REFERENCES QB.addresstype1.address_type

--Change the column name from customer table customer name as c_name

EXEC sp_rename 'QB.customer.Customer_name','c_name','COLUMN';

--Insert the suitable records into the respective tables

INSERT INTO QB.customer VALUES ('Harsh','123456789012',1234567890,'2001-09-15','abc','b','MH');

INSERT INTO QB.addresstype1 VALUES ('b','Pune')

INSERT INTO QB.state_info VALUES (1,'Maharashtra','MH')

--Change the data type of  country_code to varchar(3)

ALTER TABLE QB.state_info ALTER COLUMN country_code VARCHAR(3);

USE AdventureWorks2022;

--Q.1) find the average currency rate conversion from USD to Algerian Dinar and Australian Doller

SELECT * FROM Sales.CurrencyRate
SELECT * FROM Sales.Currency

SELECT cr.fromcurrencycode,
       cr.tocurrencycode,
	   avg(cr.averagerate)
FROM Sales.CurrencyRate cr,
Sales.Currency c
WHERE FromCurrencyCode='USD' and ToCurrencyCode in ('AUD','DZD')
GROUP BY FromCurrencyCode,ToCurrencyCode;

--Q.2) find the products having offer on it and display product name, safety stock level,
--listprice,and product model id , type of discount,percentage of discount , offer start date 
--and offer end date

SELECT * FROM Production.Product   --productid, listprice, safetystocklevel, model id, Name
SELECT * FROM [Sales].[SpecialOfferProduct]
--SELECT * FROM [Sales].[SalesOrderDetail]
SELECT * FROM [Sales].[SpecialOffer]   --startdate , enddate ,discountpct , type of discount

SELECT p.Name, p.SafetyStockLevel, p.ListPrice, p.ProductModelID , so.StartDate, so.EndDate, so.DiscountPct, so.Type 

FROM Production.Product p , [Sales].[SpecialOffer] so , [Sales].[SpecialOfferProduct] sop

WHERE so.SpecialOfferID=sop.SpecialOfferID
and sop.ProductID=p.ProductID

--Q.3)  create  view to display Product name and Product review 

SELECT * FROM [Production].[ProductReview]
SELECT * FROM Production.Product 

CREATE VIEW Product1 AS
SELECT p.Name , pr.comments 
FROM Production.Product p , [Production].[ProductReview] pr
WHERE p.ProductID=pr.ProductID

--Q.4)  find out the vendor for product paint, Adjustable Race and blad

SELECT * FROM Production.Product
SELECT * FROM [Purchasing].[Vendor]
SELECT * FROM [Purchasing].[ProductVendor]

SELECT p.Name, v.Name as vendor_name
FROM Production.Product p , [Purchasing].[Vendor] v , [Purchasing].[ProductVendor] pv
WHERE p.ProductID=pv.ProductID 
and pv.BusinessEntityID=v.BusinessEntityID 
and (p.Name like '%paint%' OR p.Name='Adjustable Race' OR p.Name='Blade')
--GROUP BY P.Name,v.Name
--ORDER BY Name;


--Q.5)  find product details shipped through ZY - EXPRESS 


SELECT * FROM [Purchasing].[ShipMethod]
SELECT * FROM Production.Product 
SELECT * FROM [Purchasing].[PurchaseOrderHeader]
SELECT * FROM [Purchasing].[PurchaseOrderDetail]

SELECT DISTINCT p.Name , sm.Name
FROM Purchasing.ShipMethod sm , Purchasing.PurchaseOrderHeader ph , Purchasing.PurchaseOrderDetail pd , Production.Product p
WHERE  sm.ShipMethodID=ph.ShipMethodID
and p.productid = pd.ProductID
and ph.PurchaseOrderID = pd.PurchaseOrderDetailID
and sm.Name='ZY - EXPRESS';


--Q.6)  find the tax amt for products where order date and ship date are on the same day 

SELECT * FROM [Purchasing].[PurchaseOrderHeader]
SELECT * FROM [Sales].[SalesOrderHeader]

SELECT DISTINCT po.OrderDate , po.ShipDate , so.TaxAmt
FROM [Purchasing].[PurchaseOrderHeader] po , [Sales].[SalesOrderHeader] so
WHERE po.ShipMethodID=so.ShipMethodID
and  po.ShipDate=so.OrderDate;


--Q.7)  find the average days required to ship the product based on shipment type. 

SELECT * FROM Purchasing.ShipMethod 
SELECT * FROM PRODUCTION.Product
SELECT * FROM [Purchasing].[PurchaseOrderHeader]

SELECT sm.Name,
AVG(DATEDIFF(DAY, sh.OrderDate , sh.ShipDate))
FROM Sales.SalesOrderHeader sh
JOIN Purchasing.ShipMethod sm 
ON sh.ShipMethodId=sm.ShipMethodID 
WHERE sh.ShipDate is NOT NULL 
GROUP BY sm.Name

SELECT sm.Name,
AVG(DATEDIFF(DAY, ph.OrderDate , ph.ShipDate))
FROM Purchasing.PurchaseOrderHeader ph
JOIN Purchasing.ShipMethod sm 
ON ph.ShipMethodId=sm.ShipMethodID 
WHERE ph.ShipDate is NOT NULL 
GROUP BY sm.Name

--Q.8) find the name of employees working in day shift 

SELECT * FROM HumanResources.Employee
SELECT * FROM Person.Person
SELECT * FROM HumanResources.Shift


SELECT * FROM Person.Person WHERE BusinessEntityID IN 
( SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory 
WHERE ShiftID IN 
( SELECT ShiftID FROM HumanResources.Shift 
WHERE Name='Day'));

--OR

SELECT COUNT(*) 
FROM HumanResources.Shift s,
     HumanResources.EmployeeDepartmentHistory ed
WHERE s.ShiftID=ed.ShiftID
and s.Name='Day'
and EndDate IS NULL 

--Q.9) based on product and product cost history find the name , service provider time and average Standardcost  

SELECT * FROM Production.Product
SELECT * FROM Production.ProductCostHistory

SELECT p.Name,
AVG(pc.Standardcost) avg_std_cost,
SUM(DATEDIFF(DAY,pc.StartDate,pc.EndDate)) service_provider_time
FROM Production.ProductCostHistory pc
JOIN Production.Product p
ON pc.ProductID=p.ProductID
GROUP BY p.Name;


--Q.10)  find products with average cost more than 500 

SELECT p.Name,
AVG(p.Standardcost) avg_cost_morethan500 
FROM Production.Product p
GROUP BY p.Name
HAVING AVG(p.Standardcost)>500;


--Q.11)  find the employee who worked in multiple territory 

SELECT * FROM [Sales].[SalesTerritory]
SELECT * FROM Person.Person
SELECT * FROM [Sales].[SalesTerritoryHistory]

SELECT  p.BusinessEntityID , p.FirstName , COUNT (*) TerritoryID
FROM Person.Person p, [Sales].[SalesTerritory] st , [Sales].[SalesTerritoryHistory] sth
WHERE p.BusinessEntityID=sth.BusinessEntityID
and sth.TerritoryID=st.TerritoryID 
GROUP BY   p.BusinessEntityID , p.FirstName
HAVING COUNT(*)>1;


--Q.12) find out the Product model name,  product description for culture as Arabic 

SELECT * FROM Production.Product
SELECT * FROM [Production].[ProductModel]
SELECT * FROM [Production].[ProductDescription]
SELECT * FROM [Production].[ProductModelProductDescriptionCulture]
SELECT * FROM  Production.Culture 

SELECT pm.Name,
       pd.Description
FROM [Production].[ProductModel] pm ,  [Production].[ProductDescription] pd , [Production].[ProductModelProductDescriptionCulture] pmd ,  Production.Culture pc
WHERE pm.ProductModelID=pmd.ProductModelID
and pmd.ProductDescriptionID=pd.ProductDescriptionID
and pmd.CultureID=pc.CultureID
and pc.CultureID='ar';


--Q.13) Find first 20 employees who joined very early in the company

SELECT * FROM HumanResources.Employee

SELECT BusinessEntityID , HireDate
FROM HumanResources.Employee
GROUP BY BusinessEntityID , HireDate
ORDER BY HireDate;


--Q.14) Find most trending product based on sales and purchase

SELECT * FROM Production.Product
SELECT * FROM Sales.SalesOrderDetail
SELECT * FROM Purchasing.PurchaseOrderDetail

SELECT p.ProductID , p.Name ,
SUM(so.OrderQty) Sales_qty ,SUM(po.OrderQty) Purchase_Qty 
FROM Production.Product P , Sales.SalesOrderDetail so , Purchasing.PurchaseOrderDetail po
WHERE p.ProductID=so.ProductID
AND so.ProductID=po.ProductID
GROUP BY  p.ProductID , p.Name 
ORDER BY (SUM(so.OrderQty)+SUM(po.OrderQty)) DESC;


--Q.15) display EMP name, territory name, saleslastyear salesquota and bonus

SELECT * FROM HumanResources.Employee
SELECT * FROM Person.Person 
SELECT * FROM Sales.SalesTerritory
SELECT * FROM Sales.SalesPerson

SELECT(SELECT CONCAT_WS(' ',p.FirstName,p.LastName) FROM Person.Person p
		WHERE p.BusinessEntityID=sp.BusinessEntityID),
	  (SELECT st.Name FROM Sales.SalesTerritory st
	    WHERE st.TerritoryID=sp.TerritoryID),
      (SELECT st.SalesLastYear FROM Sales.SalesTerritory st 
	    WHERE st.TerritoryID=sp.TerritoryID),
	  (SELECT sp.SalesQuota FROM Sales.SalesTerritory st
	    WHERE sp.TerritoryID=st.TerritoryID),
	  (SELECT sp.Bonus FROM Sales.SalesTerritory st
	    WHERE sp.TerritoryID=st.TerritoryID)
		FROM Sales.SalesPerson sp;
	   
SELECT FirstName,LastName FROM Person.Person
WHERE BusinessEntityID IN
( SELECT BusinessEntityID FROM Sales.SalesTerritory )

      
--Q.16)display EMP name, territory name, saleslastyear salesquota and bonus from Germany and United Kingdom

SELECT(SELECT CONCAT_WS(' ',p.FirstName,p.LastName) FROM Person.Person p
		WHERE p.BusinessEntityID=sp.BusinessEntityID),
	  (SELECT st.Name FROM Sales.SalesTerritory st
	    WHERE st.TerritoryID=sp.TerritoryID),
      (SELECT st.SalesLastYear FROM Sales.SalesTerritory st 
	    WHERE st.TerritoryID=sp.TerritoryID),
	  (SELECT sp.SalesQuota FROM Sales.SalesTerritory st
	    WHERE sp.TerritoryID=st.TerritoryID),
	  (SELECT sp.Bonus FROM Sales.SalesTerritory st
	    WHERE sp.TerritoryID=st.TerritoryID)
		FROM Sales.SalesPerson sp
WHERE sp.TerritoryID IN
(SELECT TerritoryID FROM Sales.SalesTerritory
WHERE Name IN ('Germany','United Kingdom'));


--Q.17) Find all employees who worked in all North America territory

SELECT * FROM Sales.SalesTerritory
SELECT * FROM Sales.SalesTerritoryHistory

SELECT * FROM HumanResources.Employee 
WHERE BusinessEntityID IN
(SELECT BusinessEntityID FROM  Sales.SalesTerritoryHistory
WHERE TerritoryID IN 
(SELECT TerritoryID FROM  Sales.SalesTerritory st
WHERE st.[Group]='North America'));


--Q.18) find all products in the cart

SELECT * FROM Production.Product
SELECT * FROM Sales.ShoppingCartItem

SELECT Name FROM Production.Product 
WHERE ProductID IN 
(SELECT ProductID FROM Sales.ShoppingCartItem);


--Q.19) find all the products with special offer

SELECT * FROM Production.Product
SELECT * FROM Sales.SpecialOffer
SELECT * FROM Sales.SpecialOfferProduct

SELECT ProductID,Name FROM Production.Product p 
WHERE ProductID IN 
(SELECT ProductID FROM Sales.SpecialOfferProduct
WHERE SpecialOfferID IN
(SELECT SpecialOfferID FROM  Sales.SpecialOffer));

--OR 

SELECT DISTINCT p.ProductID,Name FROM Production.Product p, Sales.SpecialOffer so, Sales.SpecialOfferProduct sop
WHERE p.ProductID=sop.ProductID
AND sop.SpecialOfferID=so.SpecialOfferID;


--Q.20) find all employees name , job title, card details whose credit card expired in the month 11 and year as 2008

SELECT * FROM Person.person
SELECT * FROM HumanResources.Employee
SELECT * FROM Sales.CreditCard
SELECT * FROM Sales.PersonCreditCard

SELECT 
(SELECT FirstName FROM Person.Person p WHERE p.BusinessEntityID=pcc.BusinessEntityID) FirstName,
(SELECT JobTitle FROM HumanResources.Employee e WHERE e.BusinessEntityID=pcc.BusinessEntityID),
(SELECT CardNumber FROM Sales.CreditCard cc WHERE cc.CreditCardID=pcc.CreditCardID),
(SELECT ExpMonth FROM  Sales.CreditCard cc  WHERE cc.CreditCardID=pcc.CreditCardID),
(SELECT ExpYear FROM  Sales.CreditCard cc  WHERE cc.CreditCardID=pcc.CreditCardID)
FROM Sales.PersonCreditCard pcc
WHERE pcc.CreditCardID IN
(SELECT CreditCardID FROM Sales.CreditCard 
WHERE ExpMonth=11 AND ExpYear=2008);


--Q.21) Find the employee whose payment might be revised  (Hint : Employee payment history)

SELECT BusinessEntityID,COUNT(*) AS Revised_payment FROM HumanResources.EmployeePayHistory 
GROUP BY BusinessEntityID 
HAVING COUNT(*)>1 ;

--Q.22) Find total standard cost for the active Product. (Product cost history)

SELECT * FROM Production.Product
SELECT * FROM Production.ProductCostHistory

SELECT ProductID ,
SUM(StandardCost) total_standard_cost
FROM Production.ProductCostHistory 
WHERE EndDate IS NULL
GROUP BY ProductID ;


--JOINS

--Q.23) Find the personal details with address and address type(hint: Business Entiry Address , Address, Address type)

SELECT p.FirstName , p.MiddleName , p.LastName , a.AddressLine1 , at.AddressTypeID , at.Name 
FROM Person.Person p ,
     Person.Address a ,
	 Person.AddressType at ,
	 Person.BusinessEntityAddress bea
WHERE p.BusinessEntityID=bea.BusinessEntityID
AND bea.AddressID=a.AddressID
AND bea.AddressTypeID=at.AddressTypeID;


--Q.24) Find the name of employees working in group of North America territory

SELECT p.FirstName, st.[Group]
FROM Person.Person p , HumanResources.Employee e , Sales.SalesTerritory st , Sales.SalesTerritoryHistory sth
WHERE p.BusinessEntityID=e.BusinessEntityID
AND e.BusinessEntityID=sth.BusinessEntityID
AND sth.TerritoryID=st.TerritoryID
and st.[Group]='North America';



--Q.25)  Find the employee whose payment is revised for more than once          

SELECT BusinessEntityID,COUNT(*) AS Revised_payment FROM HumanResources.EmployeePayHistory 
GROUP BY BusinessEntityID 
HAVING COUNT(*)>1 ;


--Q.26) display the personal details of  employee whose payment is revised for more than once.

SELECT p.FirstName , e.BusinessEntityID , COUNT(*) AS Revised_payment 
FROM HumanResources.EmployeePayHistory e, Person.Person p
WHERE p.BusinessEntityID=e.BusinessEntityID
GROUP BY p.FirstName , e.BusinessEntityID 
HAVING COUNT(*)>1 ;


--Q.27) Which shelf is having maximum quantity (product inventory)

SELECT * FROM Production.ProductInventory

SELECT Shelf,SUM(Quantity) Max_Qty
FROM Production.ProductInventory
GROUP BY Shelf
ORDER BY SUM(Quantity) DESC;


--Q.28) Which shelf is using maximum bin(product inventory)

SELECT * FROM Production.ProductInventory

SELECT Shelf,MAX(Bin) Max_Bin
FROM Production.ProductInventory
GROUP BY Shelf
ORDER BY MAX(Bin) DESC;


--Q.29) Which location is having minimum bin (product inventory)

SELECT * FROM Production.ProductInventory

SELECT LocationID,MIN(Bin) Min_bin
FROM Production.ProductInventory
GROUP BY LocationID
ORDER BY MIN(Bin);


--Q.30) Find out the product available in most of the locations (product inventory)

SELECT * FROM Production.ProductInventory

SELECT ProductID , SUM(LocationID) Most_Location
FROM Production.ProductInventory
GROUP BY ProductID 
ORDER BY SUM(LocationID) DESC;


--Q.31) Which sales order is having most order qualtity.

SELECT * FROM Sales.SalesOrderDetail

SELECT SalesOrderID , SUM(OrderQty) More_Order_Qty
FROM Sales.SalesOrderDetail 
GROUP BY SalesOrderID 
ORDER BY More_Order_Qty DESC;


--Q.32) find the duration of payment revision on every interval  (inline view) Output must be as given format
--revised time – count of revised salries
--duration – last duration of revision e.g there are two revision date 01-01-2022 and revised in 01-01-2024   so duration here is 2years  
--First name	Last name	Revised time	duration
--  abc	          xyz                 	3	


--Q.33) check if any employee from jobcandidate table is having any payment revisions

SELECT j.BusinessEntityID , COUNT(*) Payment_Revision
FROM HumanResources.JobCandidate j , HumanResources.EmployeePayHistory e
WHERE J.BusinessEntityID=e.BusinessEntityID
GROUP BY j.BusinessEntityID
HAVING COUNT(*)>0;


--Q.34) check the department having more salary revision 

SELECT d.Name , d.DepartmentID, COUNT(*) Salary_Revision
FROM HumanResources.Department d, HumanResources.EmployeePayHistory eph , HumanResources.EmployeeDepartmentHistory edh
WHERE d.DepartmentID=edh.DepartmentID
AND edh.BusinessEntityID=eph.BusinessEntityID
GROUP BY d.Name , d.DepartmentID
HAVING COUNT(*)>0
ORDER BY Salary_Revision DESC;


--Q.35) check the employee whose payment is not yet revised

SELECT e.BusinessEntityID ,COUNT(*)
FROM HumanResources.Employee e , HumanResources.EmployeePayHistory eph
WHERE e.BusinessEntityID=eph.BusinessEntityID
GROUP BY e.BusinessEntityID
HAVING COUNT(*)=0;


--Q.36) find the job title having more revised payments

SELECT * FROM HumanResources.EmployeePayHistory
SELECT * FROM HumanResources.Employee

SELECT e.JobTitle , COUNT(e.BusinessEntityID) Job_Title
FROM HumanResources.Employee e , HumanResources.EmployeePayHistory eph
WHERE e.BusinessEntityID=eph.BusinessEntityID
GROUP BY e.JobTitle
HAVING COUNT(e.BusinessEntityID)>0
ORDER BY Job_Title DESC;


--Q.37) find the employee whose payment is revised in shortest duration (inline view)

--Q.38) find the colour wise count of the product (tbl: product)

SELECT * FROM Production.Product

SELECT p.Name,p.Color,COUNT(p.Color) Product_Count
FROM Production.Product p
WHERE p.Color is not NULL
GROUP BY p.Color,p.Name
ORDER BY COUNT(p.Color) DESC;


--Q.39) find out the product who are not in position to sell (hint: check the sell start and end date)

SELECT * FROM Production.Product

SELECT SellStartDate,Name FROM Production.Product
WHERE SellEndDate IS NOT NULL;


--Q.40) find the class wise, style wise average standard cost

SELECT * FROM Production.ProductCostHistory
SELECT * FROM Production.Product

SELECT p.Class,p.Style,AVG(p.StandardCost) 
FROM Production.Product p 
WHERE p.Class IS NOT NULL OR  p.Style IS NOT NULL
GROUP BY p.Class,p.Style


--Q.41) check colour wise standard cost

SELECT * FROM Production.Product 
SELECT * FROM Production.ProductCostHistory

SELECT p.Color,SUM(p.StandardCost)
FROM Production.Product p 
WHERE p.Color IS NOT NULL
GROUP BY p.Color


--Q.42) find the product line wise standard cost

SELECT * FROM Production.Product 
SELECT * FROM Production.ProductCostHistory

SELECT p.ProductLine,SUM(p.StandardCost)
FROM Production.Product p
WHERE  p.ProductLine IS NOT NULL
GROUP BY  p.ProductLine


--Q.43)Find the state wise tax rate (hint: Sales.SalesTaxRate, Person.StateProvince)

SELECT * FROM Sales.SalesTaxRate
SELECT * FROM Person.StateProvince

SELECT sp.Name,SUM(st.TaxRate) AS TaxRate
FROM Person.StateProvince sp , Sales.SalesTaxRate st
WHERE sp.StateProvinceID=st.StateProvinceID
GROUP BY sp.Name


--Q.44) Find the department wise count of employees

SELECT * FROM HumanResources.Employee
SELECT * FROM HumanResources.Department
SELECT * FROM HumanResources.EmployeeDepartmentHistory

SELECT d.Name , COUNT(*) Employee_Count
FROM HumanResources.Employee e,HumanResources.Department d , HumanResources.EmployeeDepartmentHistory edh
WHERE e.BusinessEntityID=edh.BusinessEntityID
AND edh.DepartmentID=d.DepartmentID
GROUP BY d.Name


--Q.45) Find the department which is having more employees

SELECT TOP 1 d.Name , COUNT(*) Employee_Count
FROM HumanResources.Employee e,HumanResources.Department d , HumanResources.EmployeeDepartmentHistory edh
WHERE e.BusinessEntityID=edh.BusinessEntityID
AND edh.DepartmentID=d.DepartmentID
GROUP BY d.Name
ORDER BY COUNT(*) DESC;


--Q.46)	Find the job title having more employees

SELECT * FROM HumanResources.Employee

SELECT JobTitle,COUNT(*) Employee_Count
FROM  HumanResources.Employee 
GROUP BY JobTitle
ORDER BY COUNT(*) DESC;


--Q.47)	Check if there is mass hiring of employees on single day

SELECT e.HireDate,COUNT(e.BusinessEntityID) mass_hiring
FROM HumanResources.Employee e
GROUP BY e.HireDate 
HAVING COUNT(*)>1
ORDER BY mass_hiring DESC;


--Q.48)	Which product is purchased more? (purchase order details)

SELECT * FROM Production.Product
SELECT * FROM Purchasing.PurchaseOrderDetail

SELECT p.Name,po.OrderQty
FROM Production.Product P, Purchasing.PurchaseOrderDetail po
WHERE p.ProductID=po.ProductID
GROUP BY p.Name,po.OrderQty
ORDER BY po.OrderQty DESC;


--Q.49)	Find the territory wise customers count   (hint: customer)

SELECT * FROM Sales.Customer
SELECT * FROM Sales.SalesTerritory

SELECT st.Name,COUNT(*) customer_count
FROM Sales.Customer s , Sales.SalesTerritory st
WHERE s.TerritoryID=st.TerritoryID
GROUP BY st.Name


--Q.50)	Which territory is having more customers (hint: customer)

SELECT st.Name,COUNT(*) customer_count
FROM Sales.Customer s , Sales.SalesTerritory st
WHERE s.TerritoryID=st.TerritoryID
GROUP BY st.Name
ORDER BY customer_count DESC;


--Q.51)	Which territory is having more stores (hint: customer)

SELECT * FROM Sales.SalesTerritory
SELECT * FROM Sales.Customer
SELECT * FROM Sales.Store
SELECT * FROM [Sales].[SalesTerritoryHistory]

SELECT st.Name,s.Name,COUNT(*)
FROM Sales.SalesTerritory st, Sales.Store s, [Sales].[SalesTerritoryHistory] sth
WHERE st.TerritoryID=sth.TerritoryID
AND sth.BusinessEntityID=s.BusinessEntityID
GROUP BY st.Name,s.Name


--Q.52)	Is there any person having more than one credit card (hint: PersonCreditCard)

SELECT * FROM Sales.PersonCreditCard
SELECT * FROM Person.Person

SELECT p.FirstName , pcc.CreditCardID , COUNT(*) credit_card_count
FROM Person.Person p , Sales.PersonCreditCard pcc
WHERE p.BusinessEntityID=pcc.BusinessEntityID
GROUP BY p.FirstName , pcc.CreditCardID
HAVING COUNT(*)>1;


--Q.53) Find the product wise sale price (sales order details)

SELECT * FROM Sales.SalesOrderDetail
SELECT * FROM Production.Product

SELECT p.Name,sod.UnitPrice
FROM Production.Product p, Sales.SalesOrderDetail sod
WHERE p.ProductID=sod.ProductID
GROUP BY p.Name,sod.UnitPrice


--Q.54)	Find the total values for line total product having maximum order

SELECT * FROM Production.Product
SELECT * FROM Sales.SalesOrderDetail

SELECT p.ProductLine , sod.OrderQty , COUNT(*)
FROM Production.Product p , Sales.SalesOrderDetail sod
WHERE p.ProductID=sod.ProductID
GROUP BY p.ProductLine , sod.OrderQty 


-- Date queries

--Q.55)	Calculate the age of employees

SELECT * FROM HumanResources.Employee
SELECT * FROM Person.Person

SELECT GETDATE()

SELECT e.BusinessEntityID , DATEDIFF(YY,e.BirthDate,GETDATE()) AgeInYears
FROM HumanResources.Employee e 


--Q.56) Calculate the year of experience of the employee based on hire date

SELECT * FROM HumanResources.Employee

SELECT e.BusinessEntityID , DATEDIFF(YY,e.HireDate,GETDATE()) YearsOfExperience
FROM HumanResources.Employee e 

--Q.57) Find the age of employee at the time of joining 

SELECT * FROM HumanResources.Employee

SELECT e.BusinessEntityID , DATEDIFF (YY,e.BirthDate,e.HireDate) AgeAtJoining
FROM HumanResources.Employee e

--Q.58) Find the average age of male and female

SELECT * FROM HumanResources.Employee

SELECT AVG(DATEDIFF(YY,e.BirthDate,GETDATE())) AverageAge_Male
FROM HumanResources.Employee e 
WHERE e.Gender='M';

SELECT AVG(DATEDIFF(YY,e.BirthDate,GETDATE())) AverageAge_Female
FROM HumanResources.Employee e 
WHERE e.Gender='F';

--Q.59) Which product is the oldest product as on the date (refer  the product sell start date) 

SELECT * FROM PRODUCTION.Product

SELECT p.Name , (DATEDIFF(DAY,p.SellStartDate,GETDATE())) OldestProduct
FROM PRODUCTION.Product p
ORDER BY OldestProduct DESC;


--Q.60) Display the product name, standard cost, and time duration for the same cost. (Product cost history)

SELECT * FROM Production.ProductCostHistory
SELECT * FROM Production.Product

SELECT p.ProductID , p.Name , pch.StandardCost , pch.StartDate , pch.EndDate
FROM Production.Product p , Production.ProductCostHistory pch
WHERE p.ProductID=pch.ProductID;


--Q.61)	Find the purchase id where shipment is done 1 month later of order date  

SELECT * FROM Purchasing.PurchaseOrderHeader

SELECT PurchaseOrderID , ShipMethodID , OrderDate , ShipDate , (DATEDIFF(Day,OrderDate,ShipDate)) Shipment
FROM  Purchasing.PurchaseOrderHeader 
GROUP BY  PurchaseOrderID , ShipMethodID , OrderDate , ShipDate 
ORDER BY Shipment DESC;


--Q.62)	Find the sum of total due where shipment is done 1 month later of order date ( purchase order header)

--Q.63) Find the average difference in due date and ship date based on  online order flag

--Window functions

--Q.64)	Display business entity id, marital status, gender, vacationhr, average vacation based on marital status

SELECT * FROM HumanResources.Employee

SELECT BusinessEntityID,MaritalStatus,Gender,VacationHours,
    AVG(VacationHours) OVER (PARTITION BY MaritalStatus) marital_status_wise_avg
FROM HumanResources.Employee

--Q.65)	Display business entity id, marital status, gender, vacationhr, average vacation based on gender

SELECT * FROM HumanResources.Employee

SELECT BusinessEntityID,MaritalStatus,Gender,VacationHours,OrganizationLevel,
    AVG(VacationHours) OVER (PARTITION BY Gender) gender_wise_avg
FROM HumanResources.Employee


--Q.66) Display BusinessEntityID, Mariatal Status , gender , 
--vacationhr , average vacation based on organizational level

SELECT BusinessEntityID,MaritalStatus,Gender,VacationHours,OrganizationLevel,
    AVG(VacationHours) OVER (PARTITION BY OrganizationLevel) OrganizationLevel_wise_avg
FROM HumanResources.Employee

--Cross check
SELECT BusinessEntityID,MaritalStatus,Gender,VacationHours,OrganizationLevel,
    AVG(VacationHours) OVER (PARTITION BY OrganizationLevel) OrganizationLevel_wise_avg
FROM HumanResources.Employee
WHERE OrganizationLevel=1;


--Q.67) display EntityID,HireDate,Department Name and 
--department wise count of employees
--count based on organizational level in each department 

SELECT * FROM HumanResources.Employee
SELECT * FROM HumanResources.Department
SELECT * FROM HumanResources.EmployeeDepartmentHistory

SELECT e.BusinessEntityID,d.Name,e.HireDate,e.OrganizationLevel,
COUNT(d.Name) OVER (PARTITION BY d.Name) dep_wise_count,
COUNT(e.OrganizationLevel) OVER (PARTITION BY e.OrganizationLevel,d.name) organizationlevel_wise_count
FROM HumanResources.Employee e , HumanResources.Department d , HumanResources.EmployeeDepartmentHistory edh
WHERE e.BusinessEntityID=edh.BusinessEntityID
AND edh.DepartmentID=d.DepartmentID


--Q.68) display dept name , (avg sick leave and avg sick leave per department)

SELECT * FROM HumanResources.Department
SELECT * FROM HumanResources.Employee
SELECT * FROM HumanResources.EmployeeDepartmentHistory

SELECT d.Name ,
( SELECT AVG(e.SickLeaveHours) FROM  HumanResources.Employee e) Avg_sickLeave,
AVG(e.SickLeaveHours) OVER (PARTITION BY d.DepartmentID) avg_sick_leave_dept
FROM HumanResources.Department d , HumanResources.Employee e , HumanResources.EmployeeDepartmentHistory edh
WHERE d.DepartmentID=edh.DepartmentID
AND edh.BusinessEntityID=e.BusinessEntityID;


--Q.69) Check the person detail with total count of various shift working per department

SELECT * FROM Person.Person
SELECT * FROM HumanResources.Shift
SELECT * FROM HumanResources.Department
SELECT * FROM HumanResources.EmployeeDepartmentHistory

SELECT p.BusinessEntityID,p.FirstName,p.MiddleName,p.LastName,d.Name,
COUNT(*) OVER (PARTITION BY p.BusinessEntityID,edh.ShiftID) BusinessEntityIDcount,
COUNT(*) OVER (PARTITION BY d.Name,edh.ShiftID) dept_count
FROM Person.Person p , HumanResources.Department d , HumanResources.EmployeeDepartmentHistory edh
WHERE p.BusinessEntityID=edh.BusinessEntityID
AND edh.DepartmentID=d.DepartmentID
ORDER BY d.Name;


--Q.70)	Display country region code, group average sales quota based on territory id

SELECT * FROM Sales.SalesPerson
SELECT * FROM Sales.SalesTerritory

SELECT st.CountryRegionCode , st.[Group] , 
AVG(sp.SalesQuota) OVER (PARTITION BY sp.TerritoryID)  avg_salesQuota
FROM Sales.SalesPerson sp , Sales.SalesTerritory st
WHERE sp.TerritoryID=st.TerritoryID;


--Q.71)	Display special offer description, category and avg(discount pct) per the category

SELECT * FROM Sales.SpecialOffer
--SELECT * FROM Production.ProductCategory

SELECT so.Description ,so.Category, so.DiscountPct,
AVG(so.DiscountPct) OVER (PARTITION BY so.Category) avg_discountPct_category
FROM Sales.SpecialOffer so 


--Q.72) display special offer description , category and avg discount pct as per the month

SELECT Description , Category, DiscountPct,
AVG(DiscountPct) OVER (PARTITION BY MONTH(StartDate)) avg_discountPcmonth
FROM Sales.SpecialOffer 

--Q.73) display special offer description , category and avg discount pct as per the year

SELECT Description , Category, DiscountPct,
AVG(DiscountPct) OVER (PARTITION BY YEAR(StartDate)) avg_discountPct_year
FROM Sales.SpecialOffer 

--Q.74) display special offer description , category and avg discount pct as per the Type

SELECT Description , Category, DiscountPct,
AVG(DiscountPct) OVER (PARTITION BY [Type]) avg_discountPct_Type
FROM Sales.SpecialOffer

--Q.75)	Using rank and dense rand find territory wise top sales person

SELECT * FROM Sales.SalesTerritory
SELECT * FROM Sales.SalesPerson

SELECT sp.BusinessEntityID ,
       st.TerritoryID ,
	   st.Name ,
RANK() OVER (ORDER BY st.TerritoryID) top_salesperson_rank,
DENSE_RANK() OVER (ORDER BY st.TerritoryID) top_salesperson_denserank
FROM Sales.SalesTerritory st,
     Sales.SalesPerson sp
WHERE st.TerritoryID=sp.TerritoryID 