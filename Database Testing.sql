create database classicmodels;

use classicmodels;

Select * From customers;

// Schema Testing

// Table

Describe information_schema.columns;

// Check table presence in Database Schema
Show tables;
//Table Name should be displayed in the List

// Check table name conventions
Show tables;
--Table name should be single word, Table should not contains spaces.

// Check Number of Columns in a table
SELECT COUNT(*) AS NumberOfColumns FROM information_schema.columns where table_name = 'customers';

//Check Column Names in a table
SELECT column_name FROM information_schema.columns where table_name = 'customers';

//Check Data Type of Columns in a table
Describe Customers;
SELECT column_name,data_type FROM information_schema.columns where table_name = 'customers';

//Check size of the columns in a table
SELECT column_name,column_type FROM information_schema.columns where table_name = 'customers';


//Check Nulls Fields in a table
SELECT column_name,is_nullable FROM information_schema.columns where table_name = 'customers';


//Check Column Keys in a table
SELECT column_name,column_key FROM information_schema.columns where table_name = 'customers';

// Stored Procedure Testing

// What is Stored Procedure?
Select * From Customers;
// Advantages of Store Procedure
  -> Make Database more secure
  -> Reduce Network Traffic
  -> Centralize business logic in the Database
  
// How to create the Stored Procedure?

select * from customers

select * from orders

-- No Parameter Stored Procedure
delimiter //
create procedure SelectAllCustomers()
Begin
Select * from customers;
Select * from orders;
End //
delimiter ;
-- Single Parameter Stored Procedure

delimiter //
create procedure SelectAllCustomersByCity(IN myCity varchar(50))
Begin
Select * from customers where city= mycity;
Select * from orders;
End //
delimiter ;

-- Multiple Parameter Stored Procedure
delimiter //
create procedure SelectAllCustomersByCityandPin(IN mycity varchar(50),IN pcode varchar(15))
Begin
 Select * from customers where city= mycity and postalCode=pcode;
End //
delimiter ;

-- Input and Output Parameter Stored Procedure
Creating stored procedure that have input parameter and output parameter as well
custno -> input parameter
total amount of order that were shipped,cancelled,resolved & dispute -> output parameter

delimiter //
create procedure get_order_by_cust(
IN cust_no int,
OUT shipped int,
OUT cancelled int,
OUT resolved int,
OUT dispute int)
Begin
-- Shipped
 Select count(*) INTO shipped FROM orders where customerNumber=cust_no  and status = 'shipped';
 -- Cancelled
  Select count(*) INTO cancelled FROM orders where customerNumber=cust_no  and status = 'Canceled';
-- resolved
  Select count(*) INTO resolved FROM orders where customerNumber=cust_no  and status = 'resolved';
-- dispute
  Select count(*) INTO dispute FROM orders where customerNumber=cust_no  and status = 'dispute';

End //
delimiter ;

-- Multiple Condition Stored Procedure
Delimiter //
Create Procedure GetCustomerShipping(
IN pCustomerNumber int,
OUT pShipping Varchar(50))
BEGIN
DECLARE customerCountry varchar(100);
Select country into customerCountry From Customers where customerNumber = pCustomerNumber;
CASE customerCountry
When 'USA' then
 SET pShipping = '2-day Shipping';
 When 'Canada' then
 SET pShipping = '3-day Shipping';
 When 'Other' then
 SET pShipping = '5-day Shipping';
End Case;
End //
Delimiter ;

-- Error Handling Stored Procedure

select * From products;

describe products;
create table supplierproducts(
supplierId int primary key,
productId int
);
Delimiter //

CREATE PROCEDURE InsertSupplierProduct(IN inSupplierId int,IN inProductId int)
BEGIN
-- exit if the duplicate key occurs
      DECLARE EXIT HANDLER FOR 1062 SELECT 'Duplicate keys error encountered' Message;
      DECLARE EXIT HANDLER FOR SQLEXCEPTION SELECT 'SQLException encountered' Message; 
      DECLARE EXIT HANDLER FOR SQLSTATE '23000' SELECT 'SQLState 23000' ErrorCode; 

-- insert a new row into the SupplierProducts
INSERT INTO SupplierProducts(supplierId,productId) Values(inSupplierId,inProductId);

-- return the products supplied by the supplier id
Select count(*) From SupplierProducts where supplierId = productId;
END //
Delimiter ;


-- How to call/invoke the Stored Procedure

-- No Parameter Stored Procedure
call SelectAllCustomers;
-- Single Parameter Stored Procedure
call SelectAllCustomersByCity("Singapore");
-- Multiple Parameter Stored Procedure
call SelectAllCustomersByCityandPin('Singapore','079903');
-- Input and Output Parameter Stored Procedure
call get_order_by_cust(141,@shipped,@cancelled,@resolved,@dispute);
select @shipped,@cancelled,@resolved,@dispute;
-- Multiple Condition Stored Procedure
call GetCustomerShipping(112,@shipping);
select @shipping;
-- Error Handling Stored Procedure
call InsertSupplierProduct(1,1);
call InsertSupplierProduct(2,2);
call InsertSupplierProduct(3,3);
call InsertSupplierProduct(3,3);
call InsertSupplierProduct(3,4);
Select * From supplierproducts;

-- How to write Test Cases of Stored Procedure Manually

-- Check Stored Procedure exist in Database or Not
SHOW procedure status WHERE db = 'classicmodels';
SHOW procedure status Where Name = 'SelectAllCustomers';

-- Check Store Procedure with valid input data
call SelectAllCustomers;
-- Test Query
Select * From Customers;


-- Check Stored Procedure Handle Exceptions when you pass invalid input data
call SelectAllCustomersByCity('Singapore');
-- Test Query
Select * from customers Where City = Singapore;


-- Check Stored Procedure display results as Expected
call SelectAllCustomersByCityAndPin('Singapore','079903');
Select * From Customers where City = 'Singapore' and postalCode = '079903';
call SelectAllCustomersByCityAndPin('121212','11212');

  
  -- Check Stored Procedure Inserting data in Proper Tables\
  call get_order_by_cust(141,@shipped,@cancelled,@resolved,@dispute);
select @shipped,@cancelled,@resolved,@dispute;
-- Test Query
Select( Select count(*) as 'shipped' FROM orders where customerNumber=141  and status = 'shipped') as Shipped ,
  (Select count(*) as 'cancelled' FROM orders where customerNumber=141  and status = 'Canceled')as Cancelled,
  (Select count(*) as 'resolved' FROM orders where customerNumber=141  and status = 'resolved') as Resolved,
  (Select count(*) as 'dispute' FROM orders where customerNumber=141  and status = 'dispute') as Diputed;
  
  -- Check Stored Procedure Updating Data in Proper Tables
  call GetCustomerShipping(112,@shipping);
  SELECT @shipping AS ShippingTime;
  
    call GetCustomerShipping(353,@shipping);
  SELECT @shipping AS ShippingTime;

  call GetCustomerShipping(260,@shipping);
    SELECT @shipping AS ShippingTime;
    
    -- Test Query
    Select country,
CASE
When country='USA' then
 '2-day Shipping'
 When country ='Canada' then
'3-day Shipping'
Else '5-day Shipping' 
End as ShippingTime
From customers where customerNumber = 112;



-- How to Create Store Functions
use classicmodels;
select * from customers;
DELIMITER //
CREATE FUNCTION CustLevel(credit Decimal(10,2)) returns varchar(20)
Deterministic
-- Non Deterministic
begin
   declare custLevel varchar(20);
   IF credit>50000 THEN
   SET custLevel = "Platinium";
   ELSEIF (credit>=10000 AND credit<50000) THEN
   SET custLevel = "Gold";
   ELSEIF(credit<10000) THEN
   SET custLevel = "Silver";
END IF;
return custLevel;
end //

delimiter ;

-- To show the function status(What are the Functions that are already created)
SHOW function status where db = 'classicmodels';

-- How to Call the Stored Fuction
select customerName from customers;
 
select CustLevel(creditLimit) from customers;
select customerName,CustLevel(creditLimit) from customers;

-- Call Stored Function through Stored Procedure
DELIMITER //
CREATE PROCEDURE GetCustomerLevel(
IN customerNo INT,
OUT customerLevel VARCHAR(20)
)
BEGIN
Declare credit DEC(10,2) default 0 ;
-- get credit limit of a customer
select creditLimit INTO credit FROM customers where customerNumber = customerNo;
-- call the function
SET customerLevel  = Custlevel(credit);
END//
DELIMITER ;

-- Call stored procedure
call GetCustomerLevel(131,@custLevel);
select @custLevel;

-- How To Test Stored Functions

-- Check stored Function exist in database
show function status where db = 'classicmodels';

show function status Where Name = 'CustomerLevel';

select customerName,CustomerLevel(creditLimit) from customers;

-- Check Stored Function with Valid Input Data or Check Stored Function 'customerLevel' return customer level when it calls from SQL Statement
select customerName,
CASE
WHEN creditLimit>50000
then 'PLATINIUM'
When creditLimit>=10000 AND creditLimit<50000
Then 'Gold'
When creditLimit<10000
Then 'Silver'
End as customerLevel From customers;

-- Check calling stored function from stored procedure
select customerName,
CASE
WHEN creditLimit>50000
then 'PLATINIUM'
When creditLimit>=10000 AND creditLimit<50000
Then 'Gold'
When creditLimit<10000
Then 'Silver'
End as customerLevel From customers where customerNumber = 131;

use classicmodels;

DROP Table if exists WorkCenters;
DROP Table if exists WorkCenterStats;

CREATE TABLE WorkCenters(
id INT auto_increment primary key,
name varchar(100) NOT NULL,
capacity int not null
);
CREATE TABLE WorkCenterStats(
totalCapcity INT not Null
);

-- How to Create a Trigger
Delimiter //
create trigger before_workcenters_insert before insert on WorkCenters FOR each row
BEGIN
declare rowcount int;
SELECT COUNT(*) into rowcount From WorkCenterStats;
if rowcount > 0 then
Update WorkCenterStats SET totalCapcity = totalCapcity + new.capacity;
Else
Insert into WorkCenterStats(totalCapcity) VALUES(new.capacity);
END IF;
END //
Delimiter ;

describe WorkCenters;
describe WorkCenterStats;

show triggers;
-- Testing Triggers
-- Step No: 1
-- Insert  a new row into WorkCenters table
INSERT INTO WorkCenters(name,capacity) VALUES('Mold Machine',100);
-- Step 2 Query Data from the WorkCenterStats table
Select * From WorkCenterStats;
Select * From WorkCenters;

-- Step 3 Insert a new work center
INSERT INTO WorkCenters(name,capacity) VALUES('Packing',500);

-- Step 4 Finally Query Data from the WorkCenterStats table
Select * from WorkCenterStats;

-- Trigger 2 After Insert
CREATE TABLE members(
id int auto_increment,
name varchar(100) not null,
email varchar(255),
birthDate DATE,
Primary Key(id)
);

CREATE TABLE Reminders(
id int auto_increment,
memberId int,
message varchar(255) not null,
PRIMARY KEY(id,memberId)
);

Delimiter //
Create Trigger after_member_insert AFTER INSERT ON members FOR Each ROW
BEGIN
IF new.birthDate is NULL THEN INSERT INTO Reminders(memberId,message)
VALUES(new.id,CONCAT('Hi',NEW.name,',Please Update your Date of birth.'));
END IF;
END //
DELIMITER ;

show triggers;

-- Testing Trigger
-- Step 1 Insert 2 rows into members table
INSERT INTO members (name,email,birthDate) values('JOHN','john@example.com',NULL);
INSERT INTO members (name,email,birthDate) values('JOHN','kim@example.com','2012-05-03');

-- Step 2 Query data from the members table
SELECT * FROM members;
-- Finally Query data from the Reminders table
select * from Reminders;


-- Before Update Trigger
CREATE TABLE sales(
id int auto_increment,
product varchar(100) not null,
quantity int not null Default 0,
fiscal_Year smallint not null,
fiscal_Month tinyint not null,
CHECK (fiscal_Month >= 1 and fiscal_Month <=12),
CHECK (fiscal_Year between 2000 and 2050),
CHECK (quantity >=0),
UNIQUE (product,fiscal_Year,fiscal_Month),
primary key(id)
);

INSERT INTO sales (product,quantity,fiscal_Year,fiscal_Month)
VALUES('2003 Harley Davison Eagle - Drag Bike',120,2020,1),
('1969 Corvair Monza',150,2020,1),
('1970 Elymouth Hemi Cuda',200,2021,1)
 
 Select * From sales;
 
 Delimiter //
 CREATE trigger before_sales_update Before update on sales FOR EACH ROW
 BEGIN
 declare errorMessage varchar(255);
 SET errorMessage = CONCAT ('The new quantity', new.quantity,'cannot be 3 times greater than the current quantity',OLD.quantity);
 IF new.quantity > old.quantity * 3 Then
 Signal SQLSTATE '45000' SET message_text = errorMessage;
 END IF;
 END //
 Delimiter ;
 
 show triggers;
 
 -- Update the quantity of the row with id 1 to 150
 UPDATE sales SET quantity = 150 where id = 1;
 select * from sales;
 -- Update the quantity of the row with id 1 to 500
 Update sales SET quantity = 500 where id = 1;
 select * from sales;
 
 -- After update Trigger
 CREATE table SalesChanger(
 id int auto_increment primary key,
 salesId int,
 beforeQuantity int,
 afterQuantity int,
 changedAt timestamp not null default current_timestamp
 );
 
 -- Creating Trigger
 DELIMITER //
 CREATE TRIGGER after_sales_update AFTER UPDATE ON sales For Each Row
 BEGIN
 IF OLD.quantity <> new.quantity THEN
 INSERT INTO SalesChanger(salesId,beforeQuantity,afterQuantity)
 VALUES(old.id, old.quantity, new.quantity);
 END IF;
 END //
 
 show triggers;
 Select * from saleschanger;
 
 -- Step 1 Update the quantity of the row with  id 1 to 350 
 Update sales SET quantity = 350 where id = 1;
 
 Select * from saleschanger;
 -- Step 2 Update the quantity of all 3 rows by increasing 10%.
 UPDATE  sales SET quantity = CAST(quantity * 1.1 AS UNSIGNED);
 Select * From saleschanger;
 
 --  Before Delete Trigger
 CREATE TABLE Salaries(
 employeeNumber int primary key,
 validForm Date Not Null,
 salary Decimal(12,2) NOT NULL DEFAULT 0
 );
 INSERT INTO Salaries(employeeNumber,validForm,salary)
 VALUES(1002,'2001-01-01',50000),
 (1056,'2001-01-01',65000),
 (1078,'2001-01-01',70000)
 
 Select * from Salaries;
 
 CREATE TABLE SalaryArchives(
 id int primary key auto_increment,
 employeeNumber int,
 validForm DATE NOT NULL,
 salary DEC(12,2) NOT NULL DEFAULT 0,
 deletedAt TIMESTAMP DEFAULT NOW()
 );
 Select * From SalaryArchives;
 
 DELIMITER //
 CREATE TRIGGER before_salaries_delete BEFORE DELETE ON salaries FOR EACH ROW
 BEGIN
 INSERT INTO SalaryArchives(employeeNumber,validForm,salary)
 VALUES(OLD.employeeNumber,OLD.validForm,OLD.salary);
 END //
 Delimiter ;
 show triggers;
 -- Step 1 Delete the row from the salaries table
 DELETE FROM Salaries where employeeNumber = 1002;
Select * From Salaries;
Select * from SalaryArchives;

--  Step 2 Delete all the rows from salaries table
DELETE FROM Salaries;
select * from SalaryArchives;

-- After Delete Trigger
DROP TABLE IF exists Salaries;
CREATE TABLE salaries(
 employeeNumber int primary key,
 validForm Date Not Null,
 salary Decimal(12,2) NOT NULL DEFAULT 0
 );
 INSERT INTO salaries(employeeNumber,validForm,salary)
 VALUES(1002,'2001-01-01',50000),
 (1056,'2001-01-01',65000),
 (1078,'2001-01-01',70000)
 
Select * from salaries;
CREATE TABLE SalaryBudgets(
total decimal(15,2) NOT NULL);
INSERT INTO SalaryBudgets(total) 
SELECT sum(salary) FROM salaries;
Select * FROM SalaryBudgets;

-- Creating Trigger
CREATE trigger after_salaries_delete AFTER DELETE ON salaries FOR EACH ROW
UPDATE SalaryBudgets SET total =total - old.salary;

Show triggers;
Select * From SalaryBudgets;

-- Step 1 Delete row from the salaries table
DELETE FROM salaries where employeeNumber = 1002;
Select * from SalaryBudgets;
-- Step 2 Delete all rows from the salaries table
Delete from salaries;
Select * from SalaryBudgets;

-- Data Mapping Testing
use openshop;
-- so you can see new registered customer
select * from oc_customer;

-- fetching / Reteriving operation
select * from oc_customer;

-- Update Operatiom
select * from oc_customer;
UPDATE  oc_customer SET telephone = 1111111 where customerId = 1;

-- Delete Operation
Delete from oc_customer where customerId = 1;

-- Data Integrity Testing
use classicmodels;
 -- Courses Table
 CREATE TABLE COURSES(
 courseId int(2) primary key,
 courseName varchar(20) Unique,
 Duration int(2),
 Fee int(3) Check(Fee between 100 and 500)
 );
 
 Select * from COURSES;
CREATE TABLE Students(
SID int(5) primary key,
SNAME varchar(20) NOT NULL,
Age int(2) check (Age>15 and Age<30),
DOJ datetime DEFAULT current_timestamp, -- current_timestamp or now()
DDC datetime,
courseId int(2),
FOREIGN KEY (courseId) REFERENCES COURSES(courseId) on delete cascade
);
Select * From Students;

-- Check Data Integrity on Courses Table
-- Validate CourseId
Insert into COURSES values(111,'Python',3,400);

Insert into COURSES values(111,'JAVA',3,400); -- not valid
Select * FROM COURSES;
-- Validate CourseName
Insert into COURSES values(112,'Python',3,400);

Insert into COURSES values(115,'Python',3,400); -- not valid

Insert into COURSES values(null,'JAVA',3,400); -- not valid

-- Validate Fee
Insert into COURSES values(113,'C',3,300);

Insert into COURSES values(115,'C++',3,500); -- not valid

Insert into COURSES values(116,'C++',3,100); -- not valid

Insert into COURSES values(115,'C++',3,700); --  not valid

Insert into COURSES values(115,'C++',3,70); -- not valid


-- Check Data Integrity on Students Table

-- Validate SID and SNAME
Insert into Students(SID,SNAME,Age,DDC,courseId)
values (102,'John',20,'28-10-2022',111);
Select * from Students;

Insert into Students(SID,SNAME,Age,DDC,courseId) values (102,'John',20,'28-10-2022',111); -- not valid

Insert into Students(SID,SNAME,Age,DDC,courseId) values (102,null,20,null,111); -- not valid
Select * from Students;

-- Validate Age

Insert into Students(SID,SNAME,Age,DDC,courseId) values (103,'PHP',20,null,111);

Insert into Students(SID,SNAME,Age,DDC,courseId) values (103,'PHP',30,null,111); -- not valid

Insert into Students(SID,SNAME,Age,DDC,courseId) values (105,'PHP',10,null,111); -- not valid

Insert into Students(SID,SNAME,Age,DDC,courseId) values (106,'PHP',35,null,111); -- not valid

Select * from Students;

-- Validate DOJ
Select * from Students;

Select * from COURSES;
-- Validate courseId Foreign Key (Reference to courseId of COURSES Table) or Insertion Testing
Insert into Students(SID,SNAME,Age,DDC,courseId) values (106,'PHP',24,null,113);
Select * From Students;
Insert into Students(SID,SNAME,Age,DDC,courseId) values (108,'PHP',24,null,116); -- not valid

-- Delete Record from Parent table(COURSES) and Check Child table(Students) record automatically deleted or Deletion Testing
delete from COURSES where courseId = 113;
Select * From Students;
delete from COURSES where courseId = 116; -- not valid
