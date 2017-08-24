%include "./.mover_includes.inc"; 


%let user=mmattingly;
%let pw=BearDown_15;
%let server=216.157.38.64;

   proc printto log  ="/project/CACDIRECT/CODE/PROD/NEW_MOVER/LOGS/050_update_value_score_&tdate..log" new;
   proc printto print="/project/CACDIRECT/CODE/PROD/NEW_MOVER/LOGS/050_update_value_score_&tdate..lst" new;
   run;

   ***STEP 1: OVERLAP ANALYSIS ***;

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


proc sort data=nmsql.COGENSIA_MOVERS out=movers;
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

proc freq data=movers;table update_flag;run;

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

proc freq data=movers;table update_flag;run;

proc sql noprint;
   select sum(update_flag) into: updated
   from movers;
quit;

data movers;
   set movers (drop=update_flag);
run;

proc contents data=movers;run;


***STEP 2: UPDATE DATABASE ***;


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


***STEP 3: CHECK AND EMAIL ***;


filename sendmail email to=('nli@cogensia.com' ) subject="QC of New Mover Update File" from="webmaster@cogensia.com" ;

data _null_;
   file sendmail;
   put "----------------------------------------------------------";
   put "         IMPORT OF NEW MOVER UPDATE VALUESCORE DATA: &tdate.           ";
   put "----------------------------------------------------------";
   put ;
   put "   Number of records in update file: &nobs_update";
   put ;
   put "   Number of records in both file and database: &overlap";
   put ;
   put "   Number of records updated in the database: &updated";
run;
