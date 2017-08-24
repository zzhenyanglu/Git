/*%let user = mmattingly;
%let pw=BearDown_15;
libname nmsql ODBC NOPROMPT="UID=&user;pwd=&pw;DSN=MSSQL;SERVER=216.157.38.64;DATABASE=CAC_DIRECT;" readbuff=10000 insertbuff=10000 dbcommit=10000;*/
   %let pw = S0uth_D@k0t@!;
   %let server = ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com;
   libname psqlib postgresql SERVER=&server PORT=5432 DATABASE=cac_prod user=newmover password=&pw ;

libname nmsas '/project/CACDIRECT/DATA/NEW_MOVER/EPSILON/SAS';

%global tdate;
%let tdate=&sysdate;
%put TODAY: &tdate;

** What file should the update process look for?;
%macro doit(curr_sas_date_in=%sysfunc(today()));
   %global date curr_sas_date;
   %let days_after_fri = %eval(&curr_sas_date_in - %eval(%sysfunc(int(%eval(&curr_sas_date_in. / 7)))*7));
   %if &days_after_fri > 2 %then %let curr_sas_date = %eval(3+%sysfunc(int(%eval(&curr_sas_date_in. / 7)))*7);
   %else %let curr_sas_date = %eval(3+%sysfunc(int(%eval(-1 + &curr_sas_date_in. / 7)))*7);
   %let year = %sysfunc(year(&curr_sas_date));
   %let mm = %sysfunc(putn(%sysfunc(month(&curr_sas_date)),z2.));
   %let dd = %sysfunc(putn(%sysfunc(day(&curr_sas_date)),z2.));
   %let date = &year.&mm.&dd.;

   %put date = &date.;
   %put curr_sas_date = &curr_sas_date.;
   %put Today is %sysfunc(today());
%mend;
%doit; 
