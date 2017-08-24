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

/* Email receipts changed by Felix on Dec 18, 2014 from mmattingly@cogensia.com to rstoltz@cogensia.com and felixlu@cogensia.com  */
filename sendmail email to=('rstoltz@cogensia.com' 'felixlu@cogensia.com') subject="QC of New Mover Files" from="webmaster@cogensia.com" attach=("./qc_report_nmsas.new_mover_&tdate..htm" "./020_mover_processing.lst");

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
run;
