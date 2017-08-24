
-- Course/Student Example

DROP TABLE Student;
DROP TABLE Course;
DROP TABLE Enrollment;

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

