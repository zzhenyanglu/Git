%let user = mmattingly;
%let pw=BearDown_15;
libname nmsql ODBC NOPROMPT="UID=&user;pwd=&pw;DSN=MSSQL;SERVER=216.157.38.64;DATABASE=CAC_DIRECT;" readbuff=10000 insertbuff=10000 dbcommit=10000;

libname nmsas '/project/CACDIRECT/DATA/NEW_MOVER/EPSILON/SAS';

%global tdate;
%let tdate=&sysdate;
%put TODAY: &tdate;
