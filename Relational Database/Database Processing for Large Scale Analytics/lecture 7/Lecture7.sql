
/*
	SQL Examples
	Alexander Rasin
	CSC 455 Fall 2013
*/

-- Store(StoreID, City, State)
-- Transaction(StoreID, TransID, Date, Amount)

-- get rid of existing tables
DROP TABLE Transaction;
DROP TABLE Store;

-- create the new tables, each with primary keys
CREATE TABLE Store(
        StoreID   NUMBER,
        City    VARCHAR2(20),
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
INSERT INTO Store VALUES  (300, 'Schaumburg', 'IL');
INSERT INTO Store VALUES  (400, 'Boston', 'MA');
INSERT INTO Store VALUES  (500, 'Boston', 'MA');
INSERT INTO Store VALUES  (600, 'Portland', 'ME');

INSERT INTO Store VALUES  		(700, NULL, 'ME');
INSERT INTO Store VALUES  		(800, NULL, 'IL');


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

INSERT INTO Transaction Values(500, 4, '17-Oct-2011', NULL);
INSERT INTO Transaction Values(600, 2, '12-Oct-2011', NULL);


