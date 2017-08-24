DROP TABLE Strings;
CREATE TABLE Strings
( 
  Key INTEGER PRIMARY KEY,
  String VARCHAR2(100)
)

INSERT INTO Strings
  VALUES(1, 'http://www.google.com/');

INSERT INTO Strings
  VALUES(2, 'http://www.altavista.com/');

INSERT INTO Strings
  VALUES(3, 'https://www.search.com/');

INSERT INTO Strings
  VALUES(4, 'ftps://www.mozilla.com/');

INSERT INTO Strings
  VALUES(5, 'CSC355 uses http://col.cdm.depaul.edu/');

INSERT INTO Strings
  VALUES(6, 'CSC451 and CSC351');

INSERT INTO Strings
  VALUES(7, 'IT223');

INSERT INTO Strings
  VALUES(8, 'GPH425');

INSERT INTO Strings
  VALUES(9, 'DC270');
  
INSERT INTO Strings
  VALUES(10, 'CS127');

INSERT INTO Strings
  VALUES(11, 'CS227');

DROP TABLE Contacts
CREATE TABLE contacts
(
  l_name    VARCHAR2(30), 
  p_number  VARCHAR2(30)
    CONSTRAINT p_number_format      
      CHECK ( REGEXP_LIKE ( p_number, '^\(\d{3}\) \d{3}-\d{4}$' ) )
);


INSERT INTO contacts (p_number) VALUES( '(650) 555-5555' ); 
INSERT INTO contacts (p_number) VALUES( '(215) 555-3427' ); 

INSERT INTO contacts (p_number) VALUES( '650 555-5555' ); 
INSERT INTO contacts (p_number) VALUES( '650 555 5555' ); 
INSERT INTO contacts (p_number) VALUES( '(650)555-5555' ); 
