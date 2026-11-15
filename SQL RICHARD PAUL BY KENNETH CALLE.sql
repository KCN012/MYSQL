DROP database if exists CarRentalSystem; -- remove old data
CREATE DATABASE CarRentalSystem; -- Create data base new
USE CarRentalSystem; -- i tell MYSQL to use this DB
CREATE TABLE Customer (
-- Saving customer info
-- ID provided for every customer 
CustomerID int primary key auto_increment,
-- Rememer auto will generate itself
-- Name of the clients max 50 characters
FirstName VARCHAR(50) NOT NULL,
-- Last name of the client max 50 character
LastName Varchar(50) NOT NULL,
-- only 1 email, cannot be the same
Email Varchar(100) UNIQUE NOT NULL,
-- Client contact number
-- phone custumer 
phone Varchar(15),
-- customer phone
Address Varchar(200)
);
-- REMEMBER THIS WILL HELP TO ONLY HAVE 1 AND  INDIVIDUAL

-- =================================================
-- table: CarType
-- purpose : classify cars to each category
CREATE TABLE CarType (
-- ID for each customer
TypeID INT primary key auto_increment,
-- name of the type (SUV,COMPACT,LUXURY, ETC.)
TypeName varchar(20) not null,
-- Capacity of passangers
Capacity INT NOT NULL,
 -- Price per day (Format: 9999999.99)
 BasePricePerDay DECIMAL(10,2) NOT NULL
 );
 
 -- =============================
 -- table: Car
 -- Purpose: Save info about each vehicle
 create table CAR (
 -- unique ID for each car
 CarID int primary key auto_increment,
 -- Plate number unique
 PlateNumber varchar(10) Unique not null,
 -- Model 
 Model varchar(50) not null,
 
 -- year of fabrication
 Year INT,
 -- status of the car (rented, avaible , maintenance)
 Status varchar(20) default 'Available',
 -- type of the car(i will add table cartype)
 TypeID int,
 -- key foreign : make sure type exist in cartype
 -- cons means if not follow it not save it
 constraint fk_car_type
 foreign key (TypeID) 
 references CarType (TypeID)
        ON DELETE RESTRICT -- Doesnt remove type if there is a car assigned
        ON UPDATE CASCADE  --
 );
 -- ===============================================
 -- table:Booking
 -- Purpose:  table of each booking 
 create table Booking (
 -- ID unique for booking
 BookingID int primary key auto_increment,
 -- What client make the booking?
 CustomerID INT NOT NULL,
 -- What type of car is it?
 CarID int not null,
 -- Date of start 
 StartDate date not null,
 -- End date
 EndDate date not null,
 -- Cost
 TotalCost decimal(10,2) not null,
 
 constraint fk_booking_customer
        FOREIGN KEY (CustomerID) 
        REFERENCES Customer (CustomerID)
        ON DELETE RESTRICT
        -- if delete, do this
        ON UPDATE CASCADE,
        -- if update, do this
 CONSTRAINT fk_booking_car 
        FOREIGN KEY (CarID) 
        REFERENCES Car (CarID)
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,

    -- Small details fix it: Validated dates
    CONSTRAINT chk_booking_dates CHECK (EndDate >= StartDate)
 
 -- foreign key: connect to the client
 
 );
 -- ============================================
-- means end temporary
 DELIMITER //
CREATE TRIGGER AfterBookingInsert
-- auto delete or updating
AFTER INSERT ON Booking
FOR EACH ROW
BEGIN
    UPDATE Car 
    SET Status = 'Rented' 
    WHERE CarID  = NEW.CarID ;
END //
DELIMITER ;
-- means go back after trigger
 -- ====================================
 -- Updating status
 
 
-- Adding DATA OF EXAMPLES
-- ============================================

-- Adding Types of car
-- insert into meand adding..
INSERT INTO CarType (TypeName, Capacity, BasePricePerDay) VALUES 
('SUV', 5, 50.00),
('Compact', 4, 30.00),
('Luxury', 2, 100.00),
('Van', 7, 80.00),
('Economy', 4, 25.00);

-- Adding Clients
INSERT INTO Customer (FirstName, LastName, Email, Phone, Address) VALUES 
('Kenneth', 'Calle', 'kenneth@mail.com', '07123456', '10 London Rd'),
('Pepe', 'Mo', 'pepe@mail.com', '07969694', '65 Regent St'),
('Maria', 'Garcia', 'maria@mail.com', '07111222', '20 High St'),
('John', 'Smith', 'john@mail.com', '07444555', '5 Main Rd'),
('Ana', 'Lopez', 'ana@mail.com', '07777888', '12 Park Av');

--  Adding Cars
-- The type of Id must exist in the table of Cartype of 1 to 5
INSERT INTO Car (PlateNumber, Model, Year, Status, TypeID) VALUES 
('KSL23', 'Tesla Model 3', 2022, 'Available', 1),
('KFK42', 'Ford Focus', 2024, 'Available', 2),
('L4F4F', 'Nissan Qashqai', 2021, 'Available', 3),
('KRFMOR', 'Volvo XC90', 2019, 'Available', 4),
('KEMFL2', 'Toyota Yaris', 2023, 'Available', 5);

-- Task 2(b) - showing cars availables 
SELECT *
FROM Car 
WHERE Status = 'available';
-- where means only if follows this..


-- Insert booking of example
INSERT INTO Booking (CustomerID, CarID, StartDate, EndDate, TotalCost) VALUES 
(1, 1, '2026-02-12', '2026-02-15', 150.00),
(2, 2, '2026-02-10', '2026-02-14', 120.00);


-- ==========================================================
-- Task 2(c): List all bookings with customer and car details
-- Purpose: put together table to see names instead  lds
-- ==========================================================

SELECT 
    B.BookingID, 
    C.FirstName AS Customer_Name, 
    C.LastName AS Customer_Surname, 
    V.Model AS Car_Model, 
    B.StartDate,
    B.EndDate
FROM Booking B
INNER JOIN Customer C ON B.CustomerID = C.CustomerID
INNER JOIN Car V ON B.CarID = V.CarID;
-- joins menas please add them together

-- ==============================================
-- ==========================================================
-- Task 2(d): Show upcoming rental return dates
-- Purpose: Able to see when cars will be return
-- ==========================================================
-- select means show me this
SELECT 
    C.FirstName, 
    C.LastName, 
    B.EndDate, 
    V.Model
FROM Booking B
INNER JOIN Customer C ON B.CustomerID = C.CustomerID
INNER JOIN Car V ON B.CarID = V.CarID
ORDER BY B.EndDate ASC; -- First in first out




-- ==========================================================
-- Task 2(e): Update customer and vehicle information
-- Purpose: Keeping everyone update
-- ==========================================================

-- 1. update contact number of the cliente (ID 1)
UPDATE Customer 
SET Phone = '0799988877' 
WHERE CustomerID = 1;

-- 2. Update the state of the car
UPDATE Car 
SET Status = 'Maintenance' 
WHERE CarID = 3;


-- Verify the changes
SELECT * FROM Customer WHERE CustomerID = 1;
SELECT * FROM Car WHERE CarID = 1;
SELECT * FROM Car WHERE CarID = 2;
SELECT * FROM Car WHERE CarID = 3;


-- ==========================================================
-- Task 2(f): Privicity for customers 
-- Purpose: Showing only enough info (name and car) 
-- hiding important info ( address and contact number)

-- ==========================================================

CREATE VIEW BookingSummary AS
SELECT 
    C.FirstName, 
    C.LastName, 
    V.Model, 
    B.EndDate
FROM Booking B
JOIN Customer C ON B.CustomerID = C.CustomerID
JOIN Car V ON B.CarID = V.CarID;

-- to see results of the view:
SELECT * FROM BookingSummary;

-- This is the last enquirement i need to see final
SELECT CarID, Model, Status, TypeID 
FROM Car 
ORDER BY CarID ASC;


-- ==========================================================
-- Task 2(h): Security measures
-- Purpose: limited read-only access
-- ==========================================================

-- Create a new user (read-only access)
CREATE USER IF NOT EXISTS 'rental_staff'@'localhost' IDENTIFIED BY 'SecurePass123!';

-- Give permission to READ only (no delete, no update, no insert)
GRANT SELECT ON CarRentalSystem.* TO 'rental_staff'@'localhost';

-- Apply permissions
FLUSH PRIVILEGES;
-- update memory npw and apply new policies

--  Verify the user was created
SELECT User, Host FROM mysql.user WHERE User = 'rental_staff';
