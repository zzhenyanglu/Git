
/*
	SQL Examples
	Alexander Rasin
	CSC 455 Fall 2013
*/

DROP TABLE Enrollment;
DROP TABLE Student;
DROP TABLE Course;
-- Course/Student Example

CREATE TABLE Student
(
  ID VARCHAR2(5),
  Name VARCHAR2(25),
  Standing VARCHAR2(8),
  
  CONSTRAINT Student_PK
     PRIMARY KEY(ID)
);

CREATE TABLE Course
(
  CourseID VARCHAR2(15),
  Name VARCHAR2(50),
  Credits NUMBER(*,0),
  
  CONSTRAINT Course_PK
     PRIMARY KEY( CourseID)
);

CREATE TABLE Enrollment
(
  StudentID VARCHAR2(5),
  CourseID VARCHAR2(15),
  Enrolled DATE,

  CONSTRAINT E_PK
     PRIMARY KEY(CourseID, StudentID),
  
  CONSTRAINT E_FK1
     FOREIGN KEY (CourseID)
       REFERENCES Course(CourseID),
       
  CONSTRAINT E_FK2
     FOREIGN KEY (StudentID)
       REFERENCES Student(ID)
);

INSERT INTO Course VALUES ('CSC211', 'Intro to Java I', 4);
INSERT INTO Course VALUES ('IT130', 'The Internet and the Web', 2);
INSERT INTO Course VALUES ('CSC451', 'Database Design', 4);

INSERT INTO Student VALUES ('12345', 'Paul K', 'Grad');
INSERT INTO Student VALUES ('23456', 'Larry P', 'Grad');
INSERT INTO Student VALUES ('34567', 'Ana B', 'Ugrad');
INSERT INTO Student VALUES ('45678', 'Mary Y', 'Grad');
INSERT INTO Student VALUES ('56789', 'Pat B', 'Ugrad');

INSERT INTO Enrollment VALUES('12345', 'CSC211', '01-Jan-2011');
INSERT INTO Enrollment VALUES('12345', 'CSC451', '02-Jan-2011');

INSERT INTO Enrollment VALUES('23456', 'IT130', '03-Jan-2011');

INSERT INTO Enrollment VALUES('34567', 'CSC211', '06-Jan-2011');
INSERT INTO Enrollment VALUES('34567', 'IT130', '07-Jan-2011');
INSERT INTO Enrollment VALUES('34567', 'CSC451', '11-Jan-2011');

INSERT INTO Enrollment VALUES('45678', 'IT130', '02-Jan-2011');
INSERT INTO Enrollment VALUES('45678', 'CSC211', '02-Jan-2011');


SELECT * FROM Enrollment;

-- Store(StoreID, City, State)
-- Transaction(StoreID, TransID, Date, Amount)

-- get rid of existing tables
DROP TABLE Transaction;
DROP TABLE Store;

-- create the new tables, each with primary keys

CREATE TABLE Store(
        StoreID   NUMBER,
        City    VARCHAR2(20) NOT NULL,
        State  CHAR(2) NOT NULL,
      
      CONSTRAINT STORE_ID
            PRIMARY KEY (StoreID)
);

CREATE TABLE Transaction(
        StoreID   NUMBER,
	TransID  NUMBER,
	TDate       DATE,
        Amount  NUMBER(*, 2),

      CONSTRAINT DateCheck
           Check (TDate > To_Date('01-Jan-2010')),
      CONSTRAINT AmountCheck
           Check (Amount > 0.00),
      CONSTRAINT Transaction_ID
           PRIMARY KEY (StoreID, TransID),
      CONSTRAINT Transaction_FK1
           FOREIGN KEY (StoreID)
           REFERENCES Store(StoreID)
);

-- insert data...
INSERT INTO Store VALUES  (100, 'Chicago', 'IL');
INSERT INTO Store VALUES  (200, 'Chicago', 'IL');
INSERT INTO Store VALUES  
		(300, 'Schaumburg', 'IL');
INSERT INTO Store VALUES  (400, 'Boston', 'MA');
INSERT INTO Store VALUES  (500, 'Boston', 'MA');
INSERT INTO Store VALUES  
		(600, 'Portland', 'ME');


INSERT INTO Transaction Values(100, 1, '10-Oct-2011', 100.00);
INSERT INTO Transaction Values(100, 2, '11-Oct-2011', 120.00);
INSERT INTO Transaction Values(200, 1, '11-Oct-2011', 50.00);
INSERT INTO Transaction Values(200, 2, '11-Oct-2011', 70.00);
INSERT INTO Transaction Values(300, 1, '12-Oct-2011', 20.00);
INSERT INTO Transaction Values(400, 1, '10-Oct-2011', 10.00);

INSERT INTO Transaction Values(400, 2, '11-Oct-2011', 20.00);
INSERT INTO Transaction Values(400, 3, '12-Oct-2011', 30.00);
INSERT INTO Transaction Values(500, 1, '10-Oct-2011', 10.00);
INSERT INTO Transaction Values(500, 2, '10-Oct-2011', 110.00);
INSERT INTO Transaction Values(500, 3, '11-Oct-2011', 90.00);
INSERT INTO Transaction Values(600, 1, '11-Oct-2011', 300.00);

UPDATE Store SET city= 'Bohston'
    WHERE city = 'Boston';

UPDATE Store SET city= 'Boston'
    WHERE city LIKE 'B%ton';

UPDATE Transaction SET Amount = Amount * 1.2
   WHERE StoreID = 400;

UPDATE Transaction SET TransID = 5
  WHERE StoreID = 600;

UPDATE Transaction SET TransID = 5
  WHERE StoreID = 400 AND Amount =20;

DELETE FROM Transaction
        WHERE TransID = 1;

DELETE FROM Transaction
        WHERE TDate <= to_date('11-Oct-2011');

DELETE FROM Transaction
        WHERE TDate != to_date('12-Oct-2011');   

DELETE FROM Store
        WHERE City = 'Boston';

DELETE FROM Store
        WHERE StoreID = 600;   




SELECT * from Store, Transaction;
SELECT TDate, Amount from Transaction;

SELECT DISTINCT city
 FROM store
 WHERE state = 'IL' OR state = 'ME';

SELECT TDate, Amount
 FROM Transaction
 WHERE Amount >= 100;

 SELECT TDate, Amount
 FROM Transaction
 WHERE Amount > 40 AND Amount < 80;

SELECT *
 FROM Store
 WHERE (state = 'IL' OR city = 'Portland') AND StoreID != 100;

SELECT TDate, Amount
 FROM Transaction
  WHERE (Amount >=20 AND Amount <35)
      OR (Amount >100 AND Amount<= 120);

SELECT *
 FROM Store
 ORDER BY State, City;

  SELECT Amount, TDate, TransID
  FROM Transaction
  ORDER BY Amount;

 SELECT TDate, Amount
 FROM Transaction
 WHERE Amount >=20
 ORDER BY TDate, Amount;

 SELECT COUNT(DISTINCT State)
 FROM Store;

  SELECT SUM(Amount)
  FROM Transaction
  WHERE Amount <= 20 or Amount >= 100;

  SELECT AVG(Amount)
  FROM Transaction
  WHERE TDate = to_date('11-Oct-2011');

 SELECT SUM(Amount)/COUNT(Amount)
  FROM Transaction;

  SELECT MIN(Amount)
  FROM Transaction
  WHERE TDate = to_date('12-Oct-2011');

 SELECT MIN(Amount)
  FROM  Transaction
  WHERE  AMOUNT > 2255;

  SELECT MAX(Amount)
  FROM Transaction
  WHERE TDate = to_date('10-Oct-2011');

  SELECT MAX(Amount)
  FROM Transaction
  WHERE Amount < 55;

 SELECT state, COUNT(StoreID)
  FROM Store
  GROUP BY state;

  SELECT state, COUNT(DISTINCT city)
  FROM Store
  GROUP BY state;

  SELECT state, city, COUNT(StoreID)
  FROM Store
  GROUP BY state, city;

  SELECT TDate, SUM(Amount)
  FROM Transaction
  GROUP BY TDate;

 SELECT StoreID, MAX(Amount)
  FROM Transaction
  GROUP BY StoreID
  ORDER BY StoreID;

SELECT StoreID, 0.5*MIN(Amount), 1.5*MAX(Amount)
  FROM Transaction
  GROUP BY StoreID
  ORDER BY StoreID ASC;

 SELECT TDate, SUM(Amount)
  FROM Transaction
  GROUP BY Tdate
  HAVING Sum(Amount) > 200;

SELECT StoreID
FROM Store
WHERE (state = 'IL' OR city = 'Boston') 
   AND NOT city = 'Schaumburg';

SELECT TDate, MIN(Amount), Max(Amount), AVG(Amount)
FROM Transaction
GROUP BY TDate;

SELECT * from Transaction 
   WHERE TDate = to_date(SYSDATE - 9);


INSERT INTO Transaction Values(100, 1, '10-Oct-2011', 100.00);
INSERT INTO Transaction Values(200, 1, '11-Oct-2011', 50.00);
INSERT INTO Transaction Values(300, 1, '12-Oct-2011', NULL);
INSERT INTO Transaction Values(400, 1, '10-Oct-2011', 10.00);
INSERT INTO Transaction Values(500, 1, '10-Oct-2011', 10.00);
INSERT INTO Transaction Values(600, 1, '11-Oct-2011', NULL);

SELECT COUNT(*) FROM Transaction;
SELECT COUNT(Amount) FROM Transaction;
SELECT AVG(Amount) FROM Transaction;

SELECT COUNT(Amount) FROM Transaction Where Amount < 10;

SELECT Amount, COUNT(*)
FROM Transaction
GROUP BY Amount
ORDER BY Amount DESC;

SELECT * from Store
WHERE storeid = to_number('200.0');

SELECT * FROM Transaction
WHERE amount = to_char(50);

select amount
FROM Transaction;

INSERT INTO Transaction Values(400, 88, '11-Dec-2011', 105.22);
INSERT INTO Transaction Values(400, 89, '11-Dec-2011', 100.312);
