

%let user = mmattingly;
%let pw=BearDown_15;

libname nmsql ODBC NOPROMPT="UID=&user;pwd=&pw;DSN=MSSQL;SERVER=216.157.38.64;DATABASE=CAC_DIRECT;" readbuff=10000 insertbuff=10000 dbcommit=10000;
libname cac_prod postgresql server=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com user=ais password=S0uth_D@k0t@! port=5432 database=cac_prod;



%global tdate;
%let tdate=&sysdate;
%put TODAY: &tdate;
