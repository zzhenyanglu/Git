/*
  Alexander Rasin
  CSC-453 Supplemental SQL
  Spring, 2012
*/

DROP TABLE Student CASCADE CONSTRAINTS;

CREATE TABLE Student
(
  StudentID VARCHAR2(3),
  Name      VARCHAR2(35),      
  Age       NUMBER(3,0),
  Transfer  CHAR(3),
  Standing  VARCHAR2(15),
  
  CONSTRAINT Student_PK
       PRIMARY KEY (StudentID)
);


INSERT INTO Student
    VALUES('1', 'Alex S.', 33, 'yes', 'PhD');
INSERT INTO Student
    VALUES('2', 'Jane B.', 26, 'no', 'Freshman');
INSERT INTO Student
    VALUES('3', 'Jerry Z.', 27, 'no', 'Junior');
INSERT INTO Student
    VALUES('4', 'Brea V.', 22, 'yes', 'Junior');
INSERT INTO Student
    VALUES('5', 'Larry Z.', 21, 'no', 'Freshman');
INSERT INTO Student
    VALUES('6', 'Alan D.', 20, 'no', 'Junior');
INSERT INTO Student
    VALUES('7', 'Alex S.', 25, 'yes', 'Freshman');

DROP VIEW JuniorStudents;
CREATE VIEW JuniorStudents
  AS SELECT * FROM Student
           WHERE Standing = 'Junior';

SELECT COUNT(*) FROM JuniorStudents;
SELECT * From JuniorStudents;

CREATE VIEW TransferStudents
  AS SELECT * FROM Student
           WHERE Transfer = 'yes';


SELECT COUNT(*) FROM TransferStudents;
SELECT * From TransferStudents;

INSERT INTO Student
    VALUES('8', 'Lynn T.', 20, 'no', 'Junior');

INSERT INTO Student
    VALUES('9', 'James B.', 25, 'yes', 'Senior');

INSERT INTO Student
    VALUES('10', 'Lily P.', 20, 'yes', 'Junior');

-- Insert data into views

-- Create a view that checks inserts
CREATE VIEW StrictTransferStudents
  AS SELECT * FROM Student
           WHERE Transfer = 'yes'
           WITH CHECK OPTION ;


INSERT INTO JuniorStudents
    VALUES('11', 'Not A Real Student', 10, 'no', 'Junior');

INSERT INTO JuniorStudents
    VALUES('12', 'Mark M.', 25, 'no', 'Junior');

INSERT INTO TransferStudents
    VALUES('13', 'Alice A.', 23, 'yes', 'Senior');

-- SWITH CHECK OPTION will block unrelated inserts
INSERT INTO StrictTransferStudents
    VALUES('14', 'Ann B.', 21, 'no', 'Junior');

-- Can still insert it here
INSERT INTO TransferStudents
    VALUES('14', 'Ann B.', 21, 'no', 'Junior');


SELECT * FROM JuniorStudents;

-- A restricted view on student data (no age attribute)
DROP VIEW LimitedStudentView;
CREATE VIEW LimitedStudentView
  AS SELECT StudentID, Name, Transfer, Standing
     FROM Student;

SELECT COUNT(*) FROM LimitedStudentView;
SELECT * FROM LimitedStudentView;

-- Age is hidden in that view (can't access)
SELECT Age FROM LimitedStudentView;

-- Can we insert in that view?
INSERT INTO LimitedStudentView
    VALUES ('15', 'Lucky S.', 'yes', 'Freshman');

SELECT * FROM Student;

-- How about a view that reports age ranges?
DROP VIEW AgeRangeReport;
CREATE VIEW AgeRangeReport
  AS SELECT Standing, MIN(Age) AS MinAge, MAX(Age) AS MaxAge
  FROM Student
  GROUP BY Standing;

SELECT COUNT(*) FROM AgeRangeReport;
SELECT * FROM AgeRangeReport;

INSERT INTO Student
   VALUES('16', 'Ellis F.', 58, 'yes', 'Junior');

-- Can we add data into the AgeRangeReport view?
INSERT INTO AgeRangeReport
   VALUES('Pre-College', 15, 20);

