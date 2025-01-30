USE AdventureWorks2022;

SELECT * FROM HumanResources.Employee;
SELECT * FROM HumanResources.Employee WHERE MaritalStatus='M';

-- find all employees under job title Marketing

SELECT * FROM HumanResources.Employee WHERE JobTitle like 'Marketing%';

SELECT * FROM HumanResources.Employee WHERE JobTitle='Marketing Specialist';

SELECT * FROM HumanResources.Employee WHERE Gender='F';

SELECT * FROM HumanResources.Employee WHERE Gender like 'F';

SELECT COUNT(*) FROM HumanResources.Employee;

SELECT COUNT(*) FROM HumanResources.Employee WHERE Gender='M';

SELECT COUNT('MaritalStatus') FROM HumanResources.Employee;

-- find the employees having salaried flag as 1
-- find all employees having Vaccation hr more than 70

SELECT * FROM HumanResources.Employee WHERE SalariedFlag=1;

SELECT * FROM HumanResources.Employee WHERE VacationHours>70;

-- vacation hr more than 70 but less than 90

SELECT * FROM HumanResources.Employee WHERE VacationHours>70 and VacationHours<90;

-- find all jobs having title as Designer

SELECT * FROM HumanResources.Employee WHERE JobTitle like '%Designer%';

--find the total employees worked as Technician

SELECT * FROM HumanResources.Employee WHERE JobTitle like '%Technician%';

--display data having NationalIDNumber,job title,
--marital status , gender for all under marketing job title 

SELECT NationalIDNumber,JobTitle,MaritalStatus,Gender FROM HumanResources.Employee WHERE JobTitle like '%Marketing%';

SELECT DISTINCT JobTitle FROM HumanResources.Employee;

-- find unique marital status

SELECT DISTINCT MaritalStatus FROM HumanResources.Employee;

-- find the max vacation hours 

SELECT MAX(VacationHours) AS maximum_vacation_hours FROM HumanResources.Employee;

-- find the less sick leaves

SELECT MIN(SickLeaveHours) AS less_sick_leaves FROM HumanResources.Employee;

-- find all employees from production department

SELECT * FROM HumanResources.Department WHERE NAME='Production';

SELECT * FROM HumanResources.Employee 
WHERE BusinessEntityID IN 
(SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
WHERE DepartmentID=7
);

-- find all department under Research and dev 

SELECT * FROM HumanResources.Department WHERE GroupName='Research and Development';

-- find all emp under Research and dev

SELECT * FROM HumanResources.EmployeeDepartmentHistory 
WHERE  DepartmentID IN 
(SELECT DepartmentID FROM HumanResources.Department
WHERE GroupName='Research and Development'
);


SELECT * FROM HumanResources.Employee
WHERE BusinessEntityID IN 
( SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory 
WHERE  DepartmentID IN 
( SELECT DepartmentID FROM HumanResources.Department
WHERE GroupName='Research and Development'
));

--find employees who work in day shift

SELECT * FROM HumanResources.EmployeePayHistory;
SELECT * FROM HumanResources.Shift;

SELECT * FROM HumanResources.Employee
WHERE BusinessEntityID IN
( SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
WHERE ShiftID in
( SELECT ShiftID FROM HumanResources.Shift WHERE Name='Day'));

--find all employees where pay frequency is 1


SELECT * FROM HumanResources.Employee 
WHERE BusinessEntityID IN
( SELECT BusinessEntityID FROM HumanResources.EmployeePayHistory WHERE PayFrequency=1);

--find candidate who are not placed

SELECT * FROM HumanResources.JobCandidate a
WHERE a.JobCandidateID NOT IN 
( SELECT JobCandidateID FROM HumanResources.JobCandidate b 
WHERE BusinessEntityID IN (SELECT BusinessEntityID FROM HumanResources.Employee
));

-- OR

SELECT * FROM HumanResources.JobCandidate WHERE BusinessEntityID IS NULL;

-- find the address of employee

SELECT * FROM Person.Address 
WHERE AddressID IN (
SELECT AddressID FROM Person.BusinessEntityAddress 
WHERE BusinessEntityID IN
( SELECT BusinessEntityID FROM HumanResources.Employee));

--find the name for employees working in group research and development

SELECT firstName,MiddleName,LastName FROM Person.Person 
WHERE BusinessEntityID IN 
( SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
WHERE DepartmentID IN 
(SELECT DepartmentID FROM HumanResources.Department WHERE GroupName='Research and Development'));
