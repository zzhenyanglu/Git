%include "./.mover_includes.inc";
%let user=mmattingly;
%let pw=BearDown_15;
%let server=216.157.38.64;

title 'MAX ID BEFORE';
proc sql noprint;
   select max(cac_nm_id) into :maxid
   from nmsql.COGENSIA_MOVERS;
quit;

title 'NUMBER OF OBS BEFORE STACK DEDUPE AND DELETE';
proc sql noprint;
   select count(distinct CAC_NM_ID) into :beforeobs
   from nmsql.COGENSIA_MOVERS;
quit;

title 'MINIMUM DATE BEFORE STACK DEDUPE AND DELETE';
proc sql noprint;
   select min(CAC_NM_FILE_DT) FORMAT=DATE7. into :beforedate
   from nmsql.COGENSIA_MOVERS;
quit;

%nobs(data=nmsas.new_mover_&tdate);
%let newobs=&nobs;

data movers bad_date;
   set nmsql.COGENSIA_MOVERS
       nmsas.new_mover_&tdate;
   file_month=month(CAC_NM_FILE_DT);
   file_year=year(CAC_NM_FILE_DT);
   if intck('day',CAC_NM_FILE_DT,DATE()) ge 180 then output bad_date;
   else output movers;
run;

%nobs(data=bad_date);
%let deleteddateobs=&nobs;

%nobs(data=movers);
%let leftobs=&nobs;

proc sort data=movers NODUPKEY;
   by CAC_NM_CONTRACTED_ADDR CAC_NM_CONTRACTED_NAME;
run;

%nobs(data=movers);
%let afterobs=&nobs;

proc format;
   value pkmon
   1='Jan'
   2='Feb'
   3='Mar'
   4='Apr'
   5='May'
   6='Jun'
   7='Jul'
   8='Aug'
   9='Sep'
   10='Oct'
   11='Nov'
   12='Dec';
run;

proc freq data=movers;
   format file_month pkmon.;
   tables file_month*file_year /list missing;
run;


*** ADDED UPDATE VALUE SCORE ***;

%nobs(data=nmsas.update_valuescore_&tdate);
%let nobs_update = &nobs;
%put NUMBER OF RECORDS ON UPDATE FILE &nobs_update;

proc sql;
   title 'NUMBER OF RECORDS OVERLAP';
   select count(distinct a.CAC_NM_ID) into :overlap
   from nmsql.COGENSIA_MOVERS as a, nmsas.update_valuescore_&tdate as b
   where a.CAC_NM_CONTRACTED_ADDR = b.CAC_NM_CONTRACTED_ADDR
     and a.CAC_NM_FIPS_STATE_CODE = b.CAC_NM_FIPS_STATE_CODE
     and a.CAC_NM_ZIP_CODE = b.CAC_NM_ZIP_CODE
     and (a.CAC_NM_CONTRACTED_NAME = b.CAC_NM_CONTRACTED_NAME
       or a.CAC_NM_CONTRACTED_NAME = b.CAC_NM_CONTRACTED_NAME_2);
quit; 

%put NUMBER OF RECORDS OVERLAP: &overlap;

proc sql;
   title 'NUMBER OF RECORDS OVERLAP WITH DIFFERENT VALUE SCORE BEFORE UPDATE';
   select count(distinct a.CAC_NM_ID) into :diff_score_before
   from nmsql.COGENSIA_MOVERS as a, nmsas.update_valuescore_&tdate as b
   where a.CAC_NM_CONTRACTED_ADDR = b.CAC_NM_CONTRACTED_ADDR
     and a.CAC_NM_FIPS_STATE_CODE = b.CAC_NM_FIPS_STATE_CODE
     and a.CAC_NM_ZIP_CODE = b.CAC_NM_ZIP_CODE
     and a.CAC_NM_TARGET_VALUESCORE ne b.NEW_CAC_NM_TARGET_VALUESCORE
     and (a.CAC_NM_CONTRACTED_NAME = b.CAC_NM_CONTRACTED_NAME
       or a.CAC_NM_CONTRACTED_NAME = b.CAC_NM_CONTRACTED_NAME_2);
quit;      

%put NUMBER OF RECORDS OVERLAP WITH DIFFERENT VALUE SCORE BEFORE UPDATE: &diff_score_before;


proc sort data=movers;
   by CAC_NM_CONTRACTED_ADDR CAC_NM_CONTRACTED_NAME cac_nm_fips_state_code cac_nm_zip_code;
run;

proc sort data=nmsas.update_valuescore_&tdate nodupkey out=update_1;
   by CAC_NM_CONTRACTED_ADDR CAC_NM_CONTRACTED_NAME cac_nm_fips_state_code cac_nm_zip_code;
run;

data movers (drop=new_cac_nm_target_valuescore);
   merge movers (in=a)
         update_1 (in=b drop=CAC_NM_CONTRACTED_NAME_2);
   by CAC_NM_CONTRACTED_ADDR CAC_NM_CONTRACTED_NAME cac_nm_fips_state_code cac_nm_zip_code;
   format update_flag 1.;
   if a and b then do;
      cac_nm_target_valuescore = new_cac_nm_target_valuescore;
      update_flag = 1;
   end;
   if a then output movers;
run;

proc freq data=movers;
   title "AFTER FULL MATCH";
   table update_flag;
run;

proc sort data=nmsas.update_valuescore_&tdate nodupkey out=update_2;
   by CAC_NM_CONTRACTED_ADDR CAC_NM_CONTRACTED_NAME_2 cac_nm_fips_state_code cac_nm_zip_code;
run;

data movers (drop=new_cac_nm_target_valuescore);
   merge movers (in=a)
         update_2 (in=b drop=CAC_NM_CONTRACTED_NAME rename=(CAC_NM_CONTRACTED_NAME_2 = CAC_NM_CONTRACTED_NAME));
   by CAC_NM_CONTRACTED_ADDR CAC_NM_CONTRACTED_NAME cac_nm_fips_state_code cac_nm_zip_code;
   format update_flag 1.;
   if a and b then do;
      cac_nm_target_valuescore = new_cac_nm_target_valuescore;
      update_flag = 1;
   end;
   if a then output movers;
run;

proc freq data=movers;
   table "AFTER MATCH WITHOUT MIDDLE NAME";
   table update_flag;
run;

proc sql noprint;
   select sum(update_flag) into: updated
   from movers;
quit;

data movers;
   set movers (drop=update_flag);
run;

proc contents data=movers;run;





*RSS FL 22DEC2014 - ADD IN BACKUP TABLE IN CASE OF TRANSFER FAILURE;
proc sql noprint; 
   connect to odbc (NOPROMPT="UID=&user;pwd=&pw;DSN=MSSQL;SERVER=&server;DATABASE=CAC_DIRECT;");
   execute(truncate table dbo.cogensia_movers_backup) by odbc;
   execute(
      insert into dbo.cogensia_movers_backup (CAC_NM_AREA_CODE_WITH_SUPP_APPL,
                                         CAC_NM_CARRIER_ROUTE,
                                         CAC_NM_CEN_HOME_VALUE,
                                         CAC_NM_CEN_INC_CODE_NEW_ADDR,
                                         CAC_NM_CEN_INC_CODE_NEW_ADDR_R,
                                         CAC_NM_CEN_INC_CODE_PREV_ADDR,
                                         CAC_NM_CEN_INC_CODE_PREV_ADDR_R,
                                         CAC_NM_CITY,
                                         CAC_NM_CONTRACTED_ADDR,
                                         CAC_NM_CONTRACTED_NAME,
                                         CAC_NM_COUNTY_CODE,
                                         CAC_NM_COUNTY_CODE_OLD_ADDR,
                                         CAC_NM_DELIVERY_POINT_CODE,
                                         CAC_NM_DISTANCE_OF_MOVE,
                                         CAC_NM_DPV_FLAG,
                                         CAC_NM_DWELLING_ADDR_TYPE,
                                         CAC_NM_FILE_DT,
                                         CAC_NM_FIPS_STATE_CODE,
                                         CAC_NM_GENDER,
                                         CAC_NM_HH_AGE,
                                         CAC_NM_HH_MOVE_DATE,
                                         CAC_NM_HOMEOWNER_RENTER_CODE,
                                         CAC_NM_ID,
                                         CAC_NM_IMPORT_DATE,
                                         CAC_NM_INDIV_TWO_YEAR_AGE_BAND,
                                         CAC_NM_MARITAL_STATUS,
                                         CAC_NM_MARITAL_STATUS_WITHIN_HH,
                                         CAC_NM_NUMBER_OF_ADULTS_IN_HH,
                                         CAC_NM_NUMBER_OF_KIDS_IN_HH,
                                         CAC_NM_PET_OWNER,
                                         CAC_NM_STATE_ABBREVIATION,
                                         CAC_NM_TARGET_INC,
                                         CAC_NM_TARGET_VALUESCORE,
                                         CAC_NM_TELEPHONE_WITH_SUPP_APPL,
                                         CAC_NM_ZIP_CODE,
                                         CAC_NM_ZIPPLUS_4
      )
   
      select CAC_NM_AREA_CODE_WITH_SUPP_APPL,
             CAC_NM_CARRIER_ROUTE,
             CAC_NM_CEN_HOME_VALUE,
             CAC_NM_CEN_INC_CODE_NEW_ADDR,
             CAC_NM_CEN_INC_CODE_NEW_ADDR_R,
             CAC_NM_CEN_INC_CODE_PREV_ADDR,
             CAC_NM_CEN_INC_CODE_PREV_ADDR_R,
             CAC_NM_CITY,
             CAC_NM_CONTRACTED_ADDR,
             CAC_NM_CONTRACTED_NAME,
             CAC_NM_COUNTY_CODE,
             CAC_NM_COUNTY_CODE_OLD_ADDR,
             CAC_NM_DELIVERY_POINT_CODE,
             CAC_NM_DISTANCE_OF_MOVE,
             CAC_NM_DPV_FLAG,
             CAC_NM_DWELLING_ADDR_TYPE,
             CAC_NM_FILE_DT,
             CAC_NM_FIPS_STATE_CODE,
             CAC_NM_GENDER,
             CAC_NM_HH_AGE,
             CAC_NM_HH_MOVE_DATE,
             CAC_NM_HOMEOWNER_RENTER_CODE,
             CAC_NM_ID,
             CAC_NM_IMPORT_DATE,
             CAC_NM_INDIV_TWO_YEAR_AGE_BAND,
             CAC_NM_MARITAL_STATUS,
             CAC_NM_MARITAL_STATUS_WITHIN_HH,
             CAC_NM_NUMBER_OF_ADULTS_IN_HH,
             CAC_NM_NUMBER_OF_KIDS_IN_HH,
             CAC_NM_PET_OWNER,
             CAC_NM_STATE_ABBREVIATION,
             CAC_NM_TARGET_INC,
             CAC_NM_TARGET_VALUESCORE,
             CAC_NM_TELEPHONE_WITH_SUPP_APPL,
             CAC_NM_ZIP_CODE,
             CAC_NM_ZIPPLUS_4
      from dbo.cogensia_movers) by odbc;
   disconnect from odbc;
quit;

proc sql noprint;
   drop table nmsql.COGENSIA_MOVERS;
   create table nmsql.COGENSIA_MOVERS (CAC_NM_AREA_CODE_WITH_SUPP_APPL Char(3),
                                       CAC_NM_CARRIER_ROUTE Char(4),
                                       CAC_NM_CEN_HOME_VALUE Char(3),
                                       CAC_NM_CEN_INC_CODE_NEW_ADDR Char(3),
                                       CAC_NM_CEN_INC_CODE_NEW_ADDR_R Char(3),
                                       CAC_NM_CEN_INC_CODE_PREV_ADDR Char(3),
                                       CAC_NM_CEN_INC_CODE_PREV_ADDR_R Char(3),
                                       CAC_NM_CITY Char(13),
                                       CAC_NM_CONTRACTED_ADDR Char(40),
                                       CAC_NM_CONTRACTED_NAME Char(40),
                                       CAC_NM_COUNTY_CODE Char(3),
                                       CAC_NM_COUNTY_CODE_OLD_ADDR Char(3),
                                       CAC_NM_DELIVERY_POINT_CODE Char(3),
                                       CAC_NM_DISTANCE_OF_MOVE Char(4),
                                       CAC_NM_DPV_FLAG Char(1),
                                       CAC_NM_DWELLING_ADDR_TYPE Char(1),
                                       CAC_NM_FILE_DT Date,
                                       CAC_NM_FIPS_STATE_CODE Char(2),
                                       CAC_NM_GENDER Char(1),
                                       CAC_NM_HH_AGE Char(2),
                                       CAC_NM_HH_MOVE_DATE Char(6),
                                       CAC_NM_HOMEOWNER_RENTER_CODE Char(1),
                                       CAC_NM_ID Num(8),
                                       CAC_NM_IMPORT_DATE Date,
                                       CAC_NM_INDIV_TWO_YEAR_AGE_BAND Char(6),
                                       CAC_NM_MARITAL_STATUS Char(1),
                                       CAC_NM_MARITAL_STATUS_WITHIN_HH Char(1),
                                       CAC_NM_NUMBER_OF_ADULTS_IN_HH Char(2),
                                       CAC_NM_NUMBER_OF_KIDS_IN_HH Char(1),
                                       CAC_NM_PET_OWNER Char(1),
                                       CAC_NM_STATE_ABBREVIATION Char(2),
                                       CAC_NM_TARGET_INC Char(1),
                                       CAC_NM_TARGET_VALUESCORE Char(3),
                                       CAC_NM_TELEPHONE_WITH_SUPP_APPL Char(7),
                                       CAC_NM_ZIP_CODE Char(5),
                                       CAC_NM_ZIPPLUS_4 Char(4)
                                      );
quit;

proc sql noprint;
   insert into nmsql.COGENSIA_MOVERS (CAC_NM_AREA_CODE_WITH_SUPP_APPL,
                                      CAC_NM_CARRIER_ROUTE,
                                      CAC_NM_CEN_HOME_VALUE,
                                      CAC_NM_CEN_INC_CODE_NEW_ADDR,
                                      CAC_NM_CEN_INC_CODE_NEW_ADDR_R,
                                      CAC_NM_CEN_INC_CODE_PREV_ADDR,
                                      CAC_NM_CEN_INC_CODE_PREV_ADDR_R,
                                      CAC_NM_CITY,
                                      CAC_NM_CONTRACTED_ADDR,
                                      CAC_NM_CONTRACTED_NAME,
                                      CAC_NM_COUNTY_CODE,
                                      CAC_NM_COUNTY_CODE_OLD_ADDR,
                                      CAC_NM_DELIVERY_POINT_CODE,
                                      CAC_NM_DISTANCE_OF_MOVE,
                                      CAC_NM_DPV_FLAG,
                                      CAC_NM_DWELLING_ADDR_TYPE,
                                      CAC_NM_FILE_DT,
                                      CAC_NM_FIPS_STATE_CODE,
                                      CAC_NM_GENDER,
                                      CAC_NM_HH_AGE,
                                      CAC_NM_HH_MOVE_DATE,
                                      CAC_NM_HOMEOWNER_RENTER_CODE,
                                      CAC_NM_ID,
                                      CAC_NM_IMPORT_DATE,
                                      CAC_NM_INDIV_TWO_YEAR_AGE_BAND,
                                      CAC_NM_MARITAL_STATUS,
                                      CAC_NM_MARITAL_STATUS_WITHIN_HH,
                                      CAC_NM_NUMBER_OF_ADULTS_IN_HH,
                                      CAC_NM_NUMBER_OF_KIDS_IN_HH,
                                      CAC_NM_PET_OWNER,
                                      CAC_NM_STATE_ABBREVIATION,
                                      CAC_NM_TARGET_INC,
                                      CAC_NM_TARGET_VALUESCORE,
                                      CAC_NM_TELEPHONE_WITH_SUPP_APPL,
                                      CAC_NM_ZIP_CODE,
                                      CAC_NM_ZIPPLUS_4
   )

   select CAC_NM_AREA_CODE_WITH_SUPP_APPL,
          CAC_NM_CARRIER_ROUTE,
          CAC_NM_CEN_HOME_VALUE,
          CAC_NM_CEN_INC_CODE_NEW_ADDR,
          CAC_NM_CEN_INC_CODE_NEW_ADDR_R,
          CAC_NM_CEN_INC_CODE_PREV_ADDR,
          CAC_NM_CEN_INC_CODE_PREV_ADDR_R,
          CAC_NM_CITY,
          CAC_NM_CONTRACTED_ADDR,
          CAC_NM_CONTRACTED_NAME,
          CAC_NM_COUNTY_CODE,
          CAC_NM_COUNTY_CODE_OLD_ADDR,
          CAC_NM_DELIVERY_POINT_CODE,
          CAC_NM_DISTANCE_OF_MOVE,
          CAC_NM_DPV_FLAG,
          CAC_NM_DWELLING_ADDR_TYPE,
          CAC_NM_FILE_DT,
          CAC_NM_FIPS_STATE_CODE,
          CAC_NM_GENDER,
          CAC_NM_HH_AGE,
          CAC_NM_HH_MOVE_DATE,
          CAC_NM_HOMEOWNER_RENTER_CODE,
          CAC_NM_ID,
          CAC_NM_IMPORT_DATE,
          CAC_NM_INDIV_TWO_YEAR_AGE_BAND,
          CAC_NM_MARITAL_STATUS,
          CAC_NM_MARITAL_STATUS_WITHIN_HH,
          CAC_NM_NUMBER_OF_ADULTS_IN_HH,
          CAC_NM_NUMBER_OF_KIDS_IN_HH,
          CAC_NM_PET_OWNER,
          CAC_NM_STATE_ABBREVIATION,
          CAC_NM_TARGET_INC,
          CAC_NM_TARGET_VALUESCORE,
          CAC_NM_TELEPHONE_WITH_SUPP_APPL,
          CAC_NM_ZIP_CODE,
          CAC_NM_ZIPPLUS_4
   from movers;
quit;

title 'MINIMUM DATE AFTER';
proc sql noprint;
   select min(CAC_NM_FILE_DT) FORMAT=DATE7. into :deleteddates
   from nmsql.COGENSIA_MOVERS;
quit;

title 'NUMBER OF OBS AFTER';
proc sql noprint;
   select count(distinct CAC_NM_ID) into :totalnuminsql
   from nmsql.COGENSIA_MOVERS;
quit;

title 'MAX ID AFTER';
proc sql noprint;
   select max(cac_nm_id) into :aftermaxid
   from nmsql.COGENSIA_MOVERS;
quit;

*** CHECK VALUE SCORE UPDATE ***;

proc sql;
   title 'NUMBER OF RECORDS OVERLAP WITH DIFFERENT VALUE SCORE AFTER UPDATE';
   select count(distinct a.CAC_NM_ID) into :diff_score
   from nmsql.COGENSIA_MOVERS as a, nmsas.update_valuescore_&tdate as b
   where a.CAC_NM_CONTRACTED_ADDR = b.CAC_NM_CONTRACTED_ADDR
     and a.CAC_NM_FIPS_STATE_CODE = b.CAC_NM_FIPS_STATE_CODE
     and a.CAC_NM_ZIP_CODE = b.CAC_NM_ZIP_CODE
     and a.CAC_NM_TARGET_VALUESCORE ne b.NEW_CAC_NM_TARGET_VALUESCORE
     and (a.CAC_NM_CONTRACTED_NAME = b.CAC_NM_CONTRACTED_NAME
       or a.CAC_NM_CONTRACTED_NAME = b.CAC_NM_CONTRACTED_NAME_2);
quit;      

%put NUMBER OF RECORDS OVERLAP WITH DIFFERENT VALUE SCORE AFTER UPDATE: &diff_score;



/* Email receipts changed by Felix on Dec 18, 2014 from mmattingly@cogensia.com to rstoltz@cogensia.com and felixlu@cogensia.com  */
filename sendmail email to=('rstoltz@cogensia.com' 'felixlu@cogensia.com') subject="QC of New Mover Files" from="webmaster@cogensia.com" attach=("./qc_report_nmsas.new_mover_&tdate..htm" "./030_mover_processing.lst");

data _null_;
   file sendmail;
   put "----------------------------------------------------------";
   put "              IMPORT OF NEW MOVER DATA: &tdate.           ";
   put "----------------------------------------------------------";
   put;
   put "   Number of observations before new data was read in: &beforeobs";
   put;
   put "   Number of observations new observations imported: &newobs";
   put;
   put "   Number of observations deleted due to bad dates: &deleteddateobs";
   put;
   put "   Number of observations left after deleted dates: &leftobs";
   put;
   put "   Number of observations left after deduping: &afterobs";
   put;
   put "   Min File Date before new data was read in: &beforedate";
   put;
   put "   Min File Date after new data was read in and processing done: &deleteddates";
   put;
   put "   Max id before data was read in: &maxid";
   put;
   put "   Max id after data was read in: &aftermaxid";
   put;
   put "   Total number of obs now in sql: &totalnuminsql";
   put;
   put "  -------------------------------------------------------------------";
   put;
   put "   Number of records in this week update file: &nobs_update";
   put ;
   put "   Number of records in both update file and database: &overlap";
   put ;
   put "   Number of records updated in the database: &updated";
   put ;
   put "   Number of records with different value score after update: &diff_score";
run;
