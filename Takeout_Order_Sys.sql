CREATE DATABASE TakeOut;

USE TakeOut;

--Create tables
CREATE TABLE Address(
AddressID VARCHAR(255) NOT NULL PRIMARY KEY, 
State VARCHAR(50),
City VARCHAR(50),
StreetInfo VARCHAR(100),
AptNo VARCHAR(50),
ZipCode VARCHAR(50),
PhoneNo VARCHAR(50)
CONSTRAINT CHK_Phone_VOID CHECK (PhoneNo IS NOT NULL)); ---Table-level CHECK Constraints

CREATE TABLE BusinessEntity(
BusinessEntityID VARCHAR(255) NOT NULL PRIMARY KEY,
FirstName VARCHAR(50), 
LastName VARCHAR(50),
Gender VARCHAR(50),
EntityType VARCHAR(50),
AddressID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES Address(AddressID));

CREATE TABLE Restaurant(
RestaurantID VARCHAR(255) NOT NULL PRIMARY KEY, 
RestaurantName VARCHAR(50),
AddressID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES Address(AddressID), 
Description VARCHAR(300), 
OpeningHour TIME, 
ClosingHour TIME, 
FoodStyle VARCHAR(50), 
Capacity FLOAT(50));

CREATE TABLE Promotion(
PromotionID VARCHAR(255) NOT NULL PRIMARY KEY, 
RestaurantID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES Restaurant(RestaurantID),
PromoName VARCHAR(50), 
StartDate DATE, 
EndDate DATE, 
Description VARCHAR(300), 
PromoCode VARCHAR(50));

CREATE TABLE Dish(
DishID VARCHAR(255) NOT NULL PRIMARY KEY,
RestaurantID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES Restaurant(RestaurantID),
DishName VARCHAR(50),
DishDescription VARCHAR(200),
DishPrice FLOAT(50),
FoodCatelog VARCHAR(50));

CREATE TABLE Employee(
BusinessEntityID VARCHAR(255) NOT NULL PRIMARY KEY REFERENCES BusinessEntity(BusinessEntityID),
RestaurantID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES Restaurant(RestaurantID),
Position VARCHAR(50));

CREATE TABLE Customer(
BusinessEntityID VARCHAR(255) NOT NULL PRIMARY KEY REFERENCES BusinessEntity(BusinessEntityID),
RegisterTime DATE,
UserName VARCHAR(50));

CREATE TABLE Payment(
TransactionID VARCHAR(255) NOT NULL PRIMARY KEY,
PaymentTime DATETIME,
PaymentStatus VARCHAR(50),
PaymentMethod VARCHAR(50));

CREATE TABLE TakeOutOrder(
OrderID VARCHAR(255) NOT NULL PRIMARY KEY,
BusinessEntityID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES BusinessEntity(BusinessEntityID),
TransactionID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES Payment(TransactionID),
OrderTime DATETIME,
OrderStatus VARCHAR(50));

CREATE TABLE OrderItem(
OrderID VARCHAR(255) NOT NULL REFERENCES TakeOutOrder(OrderID),
DishID VARCHAR(255) NOT NULL REFERENCES Dish(DishID),
CONSTRAINT PK_Person PRIMARY KEY (OrderID, DishID));

CREATE TABLE DeliverRecord(
DeliveryID VARCHAR(255) NOT NULL PRIMARY KEY,
EmployeeID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES BusinessEntity(BusinessEntityID),
OrderID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES TakeOutOrder(OrderID),
DeliverStatus VARCHAR(50),
DeliverTime DATETIME);

CREATE TABLE Review(
ReviewID VARCHAR(255) NOT NULL PRIMARY KEY,
RestaurantID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES Restaurant(RestaurantID),
CustomerID VARCHAR(255) NOT NULL FOREIGN KEY REFERENCES BusinessEntity(BusinessEntityID),
Comment VARCHAR(300),
Rate FLOAT(50));
GO
-----------------------------------------------------------------------------------------
--I loaded all my data from txt files to tables using 'Data Import Wizard'
-----------------------------------------------------------------------------------------
--Computed Columns based on a function

CREATE FUNCTION dbo.SubTotal(@Oid FLOAT) --Create function to calculate subtotal of a order
RETURNS FLOAT(16)
AS
BEGIN
DECLARE @ReturnS FLOAT(16);
SELECT @ReturnS=SUM(Dish.DishPrice)
FROM Dish
JOIN OrderItem
ON OrderItem.DishID = Dish.DishID
WHERE OrderItem.OrderID = @Oid
RETURN @returnS;
END
GO

ALTER TABLE dbo.TakeOutOrder --Use function SubTotal() to create a computed column
ADD Subtotal AS dbo.SubTotal(TakeOutOrder.OrderID)
GO
---------------------------------------------------------------------------------------
--Each team is expected to create at least 2 views
CREATE VIEW dbo.CUSTOMER_INFO_YEAR AS --This view is used to show customers' total orders after date 11/29/2016
SELECT be.BusinessEntityID, be.FirstName, be.LastName, SUM(od.Subtotal) AS [OrderTotal]
FROM BusinessEntity be
JOIN Customer c
ON c.BusinessEntityID=be.BusinessEntityID
JOIN TakeOutOrder od
ON od.BusinessEntityID=c.BusinessEntityID
WHERE od.OrderTime > '2016-11-29 00:00:00'
GROUP BY be.BusinessEntityID, be.FirstName, be.LastName;
GO

CREATE VIEW RESTAURANT_ABOVE_AVG_RATE AS --This view is show restaurant information which rate is above average
SELECT DISTINCT r.RestaurantName, addr.City, addr.State, addr.PhoneNo, AVG(rv.Rate) AS [Average_Rate]
FROM Address addr
JOIN Restaurant r
ON addr.AddressID=r.AddressID
JOIN Review rv
ON rv.RestaurantID= r.RestaurantID
WHERE rv.Rate>(SELECT AVG(Rate) FROM Review)
GROUP BY r.RestaurantName, addr.City, addr.State, addr.PhoneNo
GO







