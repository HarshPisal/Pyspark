USE AdventureWorks2022;

--A) Find first 20 employees who joined very early in the company

SELECT * FROM HumanResources.Employee

SELECT BusinessEntityID , HireDate
FROM HumanResources.Employee
GROUP BY BusinessEntityID , HireDate
ORDER BY HireDate;

--B) find the employee's name,job title,card details whose creadit card expired in month 9 and year 2009

SELECT * FROM Person.Person
SELECT * FROM [HumanResources].[Employee]
SELECT * FROM [Sales].[PersonCreditCard]
SELECT * FROM [Sales].[CreditCard]

SELECT BusinessEntityID,
      ( SELECT FirstName FROM Person.Person p
       WHERE p.BusinessEntityID=pc.BusinessEntityID) ename,
	   ( SELECT JobTitle FROM HumanResources.Employee e
	   WHERE e.BusinessEntityID=pc.BusinessEntityID) Job_Title,
	   ( SELECT CONCAT_WS(' ',cc.CardType,cc.ExpMonth,cc.ExpYear) FROM Sales.CreditCard cc
	   WHERE cc.CreditCardID=pc.CreditCardID) credit_card
FROM Sales.PersonCreditCard pc
WHERE pc.CreditCardID IN
                        ( SELECT CreditCardID FROM Sales.CreditCard crd 
						WHERE crd.ExpMonth=9 and crd.ExpYear=2009);


--C) Find the store address and contact number based on tables store and BusnessEntity check if any other table is required

SELECT * FROM Sales.Store
SELECT * FROM Person.Address
SELECT * FROM Person.BusinessEntityAddress

SELECT bae.BusinessEntityID ,
CONCAT_WS(' ',a.AddressLine1,a.AddressLine2) Address1
FROM Person.BusinessEntityAddress bae , Person.Address a , Sales.Store s
WHERE s.BusinessEntityID=bae.BusinessEntityID
AND bae.AddressID=a.AddressID;


--D) check if any employee from jobcandidate table is having any payment revisions

SELECT j.BusinessEntityID , COUNT(*) Payment_Revision
FROM HumanResources.JobCandidate j , HumanResources.EmployeePayHistory e
WHERE J.BusinessEntityID=e.BusinessEntityID
GROUP BY j.BusinessEntityID
HAVING COUNT(*)>0;


--E) check colour wise standard cost

SELECT * FROM Production.Product 
SELECT * FROM Production.ProductCostHistory

SELECT p.Color,SUM(p.StandardCost)
FROM Production.Product p 
WHERE p.Color IS NOT NULL
GROUP BY p.Color

--F) SELECT * FROM Production.Product

SELECT * FROM Purchasing.PurchaseOrderDetail

SELECT p.Name,po.OrderQty
FROM Production.Product P, Purchasing.PurchaseOrderDetail po
WHERE p.ProductID=po.ProductID
GROUP BY p.Name,po.OrderQty
ORDER BY po.OrderQty DESC;


--G) Find the total values for line total product having maximum order

SELECT * FROM Production.Product
SELECT * FROM Sales.SalesOrderDetail

SELECT p.ProductLine , sod.OrderQty , COUNT(*) max_order
FROM Production.Product p , Sales.SalesOrderDetail sod
WHERE p.ProductID=sod.ProductID
GROUP BY p.ProductLine , sod.OrderQty 


--H)  Which product is the oldest product as on the date (refer  the product sell start date) 

SELECT * FROM PRODUCTION.Product

SELECT p.Name , (DATEDIFF(DAY,p.SellStartDate,GETDATE())) OldestProduct
FROM PRODUCTION.Product p
ORDER BY OldestProduct DESC;


--I) Find the employees whose salary is more than the average salary

SELECT * FROM HumanResources.Employee

--J) Display country region code, group average sales quota based on territory id

SELECT * FROM Sales.SalesPerson
SELECT * FROM Sales.SalesTerritory

SELECT st.CountryRegionCode , st.[Group] , 
AVG(sp.SalesQuota) OVER (PARTITION BY sp.TerritoryID)  avg_salesQuota
FROM Sales.SalesPerson sp , Sales.SalesTerritory st
WHERE sp.TerritoryID=st.TerritoryID;


--K)  Find the average age of male and female

SELECT * FROM HumanResources.Employee

SELECT AVG(DATEDIFF(YY,e.BirthDate,GETDATE())) AverageAge_Male
FROM HumanResources.Employee e 
WHERE e.Gender='M';

SELECT AVG(DATEDIFF(YY,e.BirthDate,GETDATE())) AverageAge_Female
FROM HumanResources.Employee e 
WHERE e.Gender='F';


--L) SELECT * FROM Production.Product

SELECT * FROM Purchasing.PurchaseOrderDetail

SELECT p.Name,po.OrderQty
FROM Production.Product P, Purchasing.PurchaseOrderDetail po
WHERE p.ProductID=po.ProductID
GROUP BY p.Name,po.OrderQty
ORDER BY po.OrderQty DESC;


--M) Check for the Sales person details which are working in stores (Find the sales person ID )

SELECT * FROM Sales.SalesPerson
SELECT * FROM Sales.Store

SELECT ss.SalesPersonID , ss.Name 
FROM  Sales.Store ss
GROUP BY ss.SalesPersonID , ss.Name ;


--N) display the product name and product price and count of product cost revised (productcost history)

SELECT * FROM Production.Product
SELECT * FROM Production.ProductCostHistory

SELECT p.Name , pch.ProductID , p.ListPrice , COUNT(pch.ProductID) count_product_cost
FROM Production.Product p, Production.ProductCostHistory pch
WHERE p.ProductID=pch.ProductID
GROUP BY  p.Name , pch.ProductID , p.ListPrice;


--O) check the department having more salary revision 

SELECT d.Name , d.DepartmentID, COUNT(*) Salary_Revision
FROM HumanResources.Department d, HumanResources.EmployeePayHistory eph , HumanResources.EmployeeDepartmentHistory edh
WHERE d.DepartmentID=edh.DepartmentID
AND edh.BusinessEntityID=eph.BusinessEntityID
GROUP BY d.Name , d.DepartmentID
HAVING COUNT(*)>0
ORDER BY Salary_Revision DESC;