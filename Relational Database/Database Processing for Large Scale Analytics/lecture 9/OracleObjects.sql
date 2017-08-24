
DROP TYPE Customer;
CREATE TYPE Customer AS OBJECT (  
   id   NUMBER, 
   name VARCHAR2(20), 
   addr VARCHAR2(30)
); 


DROP TYPE SmartCustomer;
CREATE TYPE SmartCustomer AS OBJECT (  
   id   NUMBER, 
   name VARCHAR2(20), 
   addr VARCHAR2(30), 
   MEMBER FUNCTION matchingName (c SmartCustomer) RETURN CHAR
); 


CREATE TYPE BODY SmartCustomer AS 
   MEMBER FUNCTION matchingName (c SmartCustomer) RETURN CHAR IS 
   BEGIN 
      IF Name = c.Name THEN
         RETURN 'Yes';  -- Names match
      ELSE 
         RETURN 'No';
      END IF;
   END;
END;


DECLARE
  c1 SmartCustomer;
  c2 SmartCustomer;
BEGIN
  c1 := NEW SmartCustomer(10,'Jenny','Address1');
  c2 := NEW SmartCustomer(20,'Lenny','Address2');

  DBMS_OUTPUT.PUT_LINE('Matches? ' || c1.matchingName(c2));
END;
/

DROP Table Enrolled;
CREATE TABLE Enrolled
(
  EID    INTEGER PRIMARY KEY,
  EDATE  DATE,
  cust   SmartCustomer 
)

INSERT INTO Enrolled
    VALUES(1, '20-jan-2011', NEW SmartCustomer(30, 'Manny', 'Address3'));


SELECT * FROM Enrolled;


SELECT EDate, ex.cust.Name
FROM Enrolled ex;


DECLARE
  c1 SmartCustomer;
  c2 SmartCustomer;
BEGIN

  c1 := NEW SmartCustomer(40, 'Manny', 'Address4');
  SELECT e.cust INTO c2
    FROM Enrolled e
      WHERE e.cust.matchingName(c1) = 'Yes';
      

  DBMS_OUTPUT.PUT_LINE('Matches? ' || c2.addr);
END;
/
