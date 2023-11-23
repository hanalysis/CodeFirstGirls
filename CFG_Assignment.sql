-- Assignment 

# Core requirement 1: Create a relational database of your choice with minimum 5 tables

# First table

CREATE DATABASE Project;

USE Project;

# Creating table

CREATE TABLE Sales (
Rank_ID CHAR(6) NOT NULL PRIMARY KEY, # Setting primary key
Brand VARCHAR(20),
Generic VARCHAR(25),
Sales INT
);

# Inserting data

USE Project;

INSERT INTO Sales (Rank_ID, Brand, Generic, Sales) VALUES
("2021_1","Comirnaty","Tozinameran",59),
("2021_2","Humira","Adalimumab",21),
("2021_3","Spikevax","Elasomeran",18),
("2021_4","Keytruda","Pembrolizumab",17),
("2021_5","Eliquis","Apixaban",17),
("2022_1","Comirnaty","Tozinameran",41),
("2022_2","Spikevax","COVID Vaccine",22),
("2022_3","Humira","Adalimumab",22),
("2022_4","Keytruda","Pembrolizumab",21),
("2022_5","Paxlovid","Nirmatrelvir",19),
("2023_1","Keytruda","Pembrolizumab",24),
("2023_2","Comirnaty","Tozinameran",18),
("2023_3","Humira","Adalimumab",13),
("2023_4","Paxlovid","Nirmatrelvir",13),
("2023_5","Eliquis","Apixaban",13);


# Second table

# Creating table

USE Project;

CREATE TABLE Manufacturer (
Brand VARCHAR(20) NOT NULL PRIMARY KEY, # Setting the primary key
Manufacturer VARCHAR (20)
);

# Inserting data

Use Project;

INSERT INTO Manufacturer (Brand, Manufacturer) VALUES
("Keytruda","Merck"),
("Humira","AbbVie"),
("Paxlovid","Pfizer"),
("Spikevax","Moderna"),
("Comirnaty","Pfizer / BioNTech"),
("Eliquis","BMS / Pfizer");


# Third table

# Making table

USE Project;

CREATE TABLE Location (
Manufacturer VARCHAR (20) NOT NULL PRIMARY KEY, # Setting the primary key
Location VARCHAR(20)
);

# Inserting data into the table

USE Project;

INSERT INTO Location (Manufacturer, Location) VALUES
("Merck","Darmstadt"),
("AbbVie","Chicago"),
("Pfizer","New York"),
("Moderna","Massachusetts"),
("Pfizer / BioNTech","Mainz"),
("BMS / Pfizer","New York");



# Fourth table

# Making table

USE Project;

CREATE TABLE Patent (
Brand VARCHAR (20) NOT NULL PRIMARY KEY, # Setting the primary key
Patent_Expiry INT,
Indication VARCHAR(20)
);

# Inserting data into the table

USE Project;

INSERT INTO Patent (Brand, Patent_Expiry, Indication) VALUES
("Keytruda", 2028,"Cancer"),
("Humira", 2023,"Arthritis"),
("Paxlovid", 2027,"COVID"),
("Spikevax", 2029,"COVID"),
("Comirnaty", NULL ,"COVID"),
("Eliquis", 2027, "Vascular disease");



# Fifth table

# Making table

USE Project;

CREATE TABLE RankID (
Rank_ID CHAR(6) NOT NULL PRIMARY KEY, # Setting the primary key
Year INT,
Place INT
);


# Inserting data into the table

USE Project;

INSERT INTO RankID (Year, Place, Rank_ID) VALUES
("2021","1","2021_1"),
("2021","2","2021_2"),
("2021","3","2021_3"),
("2021","4","2021_4"),
("2021","5","2021_5"),
("2022","1","2022_1"),
("2022","2","2022_2"),
("2022","3","2022_3"),
("2022","4","2022_4"),
("2022","5","2022_5"),
("2023","1","2023_1"),
("2023","2","2023_2"),
("2023","3","2023_3"),
("2023","4","2023_4"),
("2023","5","2023_5");


# Core requirement 2: Set primary and foreign key constraints to create relations between the tables

-- Setting foreign key for Rank_ID in tables Sales and RankID

Use Project;

ALTER TABLE Sales
ADD CONSTRAINT
fk_Rank_ID
FOREIGN KEY
(Rank_ID)
REFERENCES
RankID
(Rank_ID);


-- Setting foreign key for Manufacturer in tables manufacturer and location

Use Project;

ALTER TABLE Manufacturer
ADD CONSTRAINT
fk_Manufacturer
FOREIGN KEY
(Manufacturer)
REFERENCES
Location
(Manufacturer);


-- Setting foreign key for Brand in tables Sales and Patent

Use Project;

ALTER TABLE Sales
ADD CONSTRAINT
fk_Brand
FOREIGN KEY
(Brand)
REFERENCES
Patent
(Brand);


-- Setting foreign key for Brand in tables Sales and manufacturer

Use Project;

ALTER TABLE Sales
ADD CONSTRAINT
fk_Brand_2
FOREIGN KEY
(Brand)
REFERENCES
Manufacturer
(Brand);


# Using any type of the joins create a view that combines multiple tables in a logical way

Use Project;

CREATE VIEW Top_Sellers
AS
SELECT Sales.Brand, Sales.Generic
FROM Sales
LEFT JOIN RankID
on Sales.Rank_ID = RankID.Rank_ID
WHERE RankID.Place = 1;


-- Core requirement 3: Prepare an example query with a subquery to demonstrate how to extract data from your DB for analysis

-- What are the indications of drugs sold over 20 billion?

Use Project;

SELECT Indication FROM Patent # Query
WHERE Brand in (
SELECT Brand # Subquery
FROM Sales
WHERE Sales >= 20);


-- Core requirement 4:  In your database, create a stored function that can be applied to a query in your DB

-- Stored function to see whether product is still in patent

use Project;

DELIMITER //
CREATE FUNCTION In_Patent(
    patentyear INT
) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE patent_status VARCHAR(20);
    IF patentyear > 2023 THEN
        SET patent_status = 'In patent';
    ELSEIF patentyear <= 2023 THEN
        SET patent_status = 'Out of patent';
    END IF;
    RETURN (patent_status);
END//balance
DELIMITER ;

select * from Project.Patent;

SELECT 
	Brand,
    Indication,
    Patent_Expiry,
    In_Patent(Patent_Expiry)
FROM Patent;


-- Advanced requirement 1: Create a stored procedure and demonstrate how it runs

# Stored procedure to change / update the patent of a drug

use Project;
SELECT *
FROM patent;

DELIMITER // 

CREATE PROCEDURE UpdatePatent(
NewYear INT,
BrandID VARChAR(25))

BEGIN 

UPDATE Patent
SET Patent_Expiry = NewYear
WHERE Brand = BrandID;

END //

DELIMITER ;

# Calling procedure to check it runs
CALL UpdatePatent(2040, "Comirnaty");

# Demonstrating that the new value has been inserted
Select * From Patent;


-- Advanced requirement 2; create an event and demonstrate how it runs
# Creating an event that will insert 5 new rankIDs into Sales every year
# Note I would have to update the year annually, e.g. 2025, 2026 etc

SET GLOBAL event_scheduler = ON;

Use Project;

DELIMITER //

CREATE EVENT AnnualUpdate
ON SCHEDULE EVERY 1 MINUTE
STARTS NOW()
DO BEGIN 
	INSERT INTO RankID(Rank_ID)
    VALUES("2024_1"),
    ("2024_2"),
    ("2024_3"), 
    ("2024_4"),
    ("2024_5");
    
INSERT INTO Sales(Rank_ID)
    VALUES("2024_1"),
    ("2024_2"),
    ("2024_3"), 
    ("2024_4"),
    ("2024_5");
    END //
    
DELIMITER ;

Select * from Sales;

DROP EVENT AnnualUpdate;

