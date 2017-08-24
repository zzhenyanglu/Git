*========================================================================================;
* Program 010_update.sas
  Purpose Update the CAC Direct database (SAS DATASETS)   
  Authors Mike Mattingly, Patty Seeburger, Lisa Fales, Joel Schiltz
  Design  One Macro update_db loop thru specified state list to update database.
          Takes paramters for start state, end state, quarter, year, and email;
          
* Updates v3.1 2012 Quarter 3
   Include prod/dev mode for development
    Life Events Change order and correct all missing values
     Presence of Adults Recode
       Sort Base Demo by CAC_HH_PID
        Change hardcoded input file name from hardcoded wildcard characters;
        
* Updates v4.1 2012 Quarter 4      
   Change input statement to accomodate 2010 census geography, new enhanced demo and value score fields from Epsilon
    Change libnames of datasets to be parameters;
    
* Updates v5.1 2013 Quarter 1      
   Neccesary changes for first run in Vince after migrating from Jules;

* Updates v6.1 2013 Quarter 4 R2
   Add CAC_DEMO_NET_WORTH_ENH CAC_DEMO_HOME_VALUATION_ENH CAC_DEMO_INCOME_INDEX_ENH;

*========================================================================================;
*       STEP 1 Read Raw File;
*               INPUT: Raw file from Espilon project/CACDIRECT/&cidatapath./RAW/x0000???_&cstate..txt;
*               OUTPUT: process.raw_&cstate;

*       STEP 2 Merge Raw file and Current BASE_DEMO_&CSTATE table, Update Life Event Variables;
*	        INPUTS: process.raw_&cstate, base.base_demo_&cstate;
*               OUTPUTS: process.bd_inserts_&cstate, process.bd_updates_&cstate, process.bd_deletes_&cstate, process.bd_inactives_&cstate;

* 	STEP 3 Create a format for Existing Records to be keep;
*               INPUT: BD_INACTIVES_&CSTATE;
*               OUTPUT: "./keepers_&cstate.sas";

*       STEP 4 Create tables and files;
*               INPUTS: process.bd_inserts_&cstate, process.bd_updates_&cstate, base.base_demo_&cstate (where cac_hh_pid in keep format);
*               OUTPUT: process.base_demo_&cstate, indiv.indiv_demo_&cstate, process.for_parsimony_&cstate;
*                       File for Etech: "/project/CACDIRECT/&cidatapath./ETECH/FORETECH/etech_&cstate.csv";

*       STEP 5 Call to parsimony macro to parse names and addresses for build of match key files;
*               INPUTS: process.for_parsimony_&cstate;
*               OUTPUT: scf.tsp_MKEY_&cstate;

*       STEP 6 Build match key files;
*               INPUT: scf.tsp_MKEY_&cstate;
*               OUTPUT: scf.scf_stscf_key1--7;

*       STEP 7 Build GEO Interest table;
*               INPUT: process.base_demo_&cstate;
*               OUTPUT: geo.geo_interests_&cstate;

*       STEP 8 Put Lifestyle on GEO Interest table;

*       STEP 9 Build zip9 lookup table (2000 Census) REMOVED; 

*       STEP 10 Put Lifestyle on WORK.BASE_DEMO and GEO Interest table;
*               INPUT: process.base_demo_&cstate;
*               OUTPUT: work.hh_&cstate, work.zip_found_&cstate, work.zip2_found_&cstate, work.state_found_&cstate;

*       STEP 11 Write permanent base_demo_&cstate and Create SILHOUETTE and SILH LIFEDRIVER;
*               INPUT: work.hh_&cstate, work.zip_found_&cstate, work.zip2_found_&cstate, work.state_found_&cstate;
*               OUTPUT: base.base_demo_&cstate;
*========================================================================================;
options nomprint nomlogic linesize=max validvarname=upcase;

%global testobs;
%let testobs=max;

* PERCENTAGE THRESHOLDS FOR RECORD COUNT DIFFERENCES BETWEEN INITIAL LOAD AND CURRENT LOAD;
%let mnval=.8;
%let mxval=1.3;

***********************;
* START UPDATE_DB MACRO;
***********************;

*Q4MM;
%macro update_db (qtr=, year=, email=mmattingly@cac-group.com, cac_read_dir_loc=B, cstate=XXXXXXXXXX, codepath=PROD); 

    %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc";
    
    %let sts = AK AL AR AZ CA CO CT DC DE FL 
               GA HI IA ID IL IN KS KY LA MA
               MD ME MI MN MO MS MT NC ND NE 
               NH NJ NM NV NY OH OK OR PA RI
               SC SD TN TX UT VA VT WA WI WV
               WY;
               
    %let curst=&cstate;
    
    %let person = 1 2 3 4 5;
    
    data _null_;
      start_dt=put(datetime(), datetime.);
      call symput('start_dt',start_dt);
      start_time=put(time(), time.);
      call symput('start_time',start_time);
      start_date=put(date(), date.);
      call symput('start_date',start_date);
    run;
        
    %if &cac_read_dir_loc=A %then %do;                                               *** IF CURRENT PRODUCTION DATA IS IN A THEN WRITE DATA FOR NEW QUARTER TO B;
        libname _ALL_;
        libname process  "/project/CACDIRECT/&cidatapath./PROCESS";
        libname cur_base "/project/CACDIRECT/&cidatapath./BASE_DEMO/A";
        libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";
        libname indiv    "/project/CACDIRECT/&cidatapath./INDIV_DEMO/B";
        libname scf      "/project/CACDIRECT/&cidatapath./SCF_MKEY/B";
        libname geo      "/project/CACDIRECT/&cidatapath./GEO/B";
        libname samp     "/project/CACDIRECT/&cidatapath./SAMPLES/B";      
        libname cen2000  "/project17/CENSUS/DATA/FINAL";
        libname foret    "/project/CACDIRECT/&cidatapath./ETECH/FORETECH";
        libname jhis     "/project/CACDIRECT/&cidatapath./JOB_HISTORY";
    %end;
    
    %else %if &cac_read_dir_loc=B %then %do;                                        *** IF CURRENT PRODUCTION DATA IS IN B THEN WRITE DATA FOR NEW QUARTER TO A;
              libname _ALL_;
              libname process  "/project/CACDIRECT/&cidatapath./PROCESS";
              libname cur_base "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";
              libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/A";
              libname indiv    "/project/CACDIRECT/&cidatapath./INDIV_DEMO/A";
              libname scf      "/project/CACDIRECT/&cidatapath./SCF_MKEY/A";
              libname geo      "/project/CACDIRECT/&cidatapath./GEO/A";
              libname samp     "/project/CACDIRECT/&cidatapath./SAMPLES/A";          
              libname cen2000  "/project17/CENSUS/DATA/FINAL";
              libname foret    "/project/CACDIRECT/&cidatapath./ETECH/FORETECH";
              libname jhis     "/project/CACDIRECT/&cidatapath./JOB_HISTORY";
    %end;
    
    * INITIALIZE MACRO VARIABLES USED FOR QC TO 0 FOR EACH STATE;
    %let initial_raw_count=0;
    %let current_raw_count=0;
    %let initial_base_demo_obs=0;
    %let current_base_demo_obs=0;
    %let new_base_demo_obs=0;
    %let pdiff=0;
    
    ****************************************;
    * VARIABLES TO CONVERT FROM MISSING TO 0;
    ****************************************;

    %let convert_vars=
                      
                      
                      
                      cac_demo_num_kids_enh cac_demo_adult_18_24_enh cac_demo_adult_25_34_enh cac_demo_adult_35_44_enh cac_demo_adult_45_54_enh  
                      cac_demo_adult_55_64_enh cac_demo_adult_65_74_enh cac_demo_adult_75_plus_enh cac_demo_adult_unknown_enh cac_demo_education_enh
                      cac_demo_adult_65_plus_inf_enh cac_demo_adult_45_64_inf_enh cac_demo_adult_35_44_inf_enh cac_demo_adult_under_35_inf_enh
                      cac_demo_kids_00_02_enh cac_demo_kids_03_05_enh cac_demo_kids_06_10_enh cac_demo_kids_11_15_enh cac_demo_kids_16_17_enh;

    ***********************************;
    *** Y/N CHAR VAR TO BINARY VAR LIST;
    ***********************************;
    %let revars=cac_int_1 cac_int_2 cac_int_3 cac_int_4 cac_int_5 cac_int_6 cac_int_7 cac_int_8 cac_int_9 cac_int_10 cac_int_11 cac_int_12
                cac_int_13 cac_int_14 cac_int_15 cac_int_16 cac_int_17 cac_int_18 cac_int_19 cac_int_20 cac_int_21 cac_int_22
                cac_int_23 cac_int_24 cac_int_25 cac_int_26 cac_int_27 cac_int_28 cac_int_29 cac_int_30 cac_int_31 cac_int_32
                cac_int_33 cac_int_34 cac_int_35 cac_int_36 cac_int_37 cac_int_38 cac_int_39 cac_int_40 cac_int_41 cac_int_42
                cac_int_43 cac_int_44 cac_int_45 cac_int_46 cac_int_47 cac_int_48 cac_int_49 cac_int_50 cac_int_51 cac_int_52
                cac_int_53 cac_int_54 cac_int_55 cac_int_56 cac_int_57 cac_int_58 cac_int_59 cac_int_60 cac_int_61 cac_int_62
                cac_int_63 cac_int_64 cac_int_65 cac_int_66 cac_int_67 cac_int_68 cac_int_69 cac_int_70 cac_int_71 cac_int_72
                cac_int_73 cac_int_74 cac_int_75 cac_int_76 cac_int_77 cac_int_78 cac_int_79 cac_int_80 cac_int_81 cac_int_82
                cac_int_83 cac_int_84 cac_int_85 cac_int_86 cac_int_87 cac_int_88 cac_int_89 cac_int_90 cac_int_91 cac_int_92
                cac_int_93 cac_int_94 cac_int_95 cac_int_96 cac_int_97 cac_int_98 cac_int_99 cac_int_100 cac_int_101 cac_int_102
                cac_int_103 cac_int_104 cac_int_105 cac_int_106 cac_int_107 cac_int_108 cac_int_109 cac_int_110 cac_int_111 cac_int_112
                cac_int_113 cac_int_114 cac_int_115 cac_int_116 cac_int_117 cac_int_118 cac_int_119 cac_int_120 cac_int_121 cac_cred_amex
                cac_cred_any cac_cred_bank cac_cred_catalog cac_cred_comp_electronic cac_cred_debit cac_cred_finance cac_cred_furniture
                cac_cred_grocery cac_cred_home_improve cac_cred_home_office cac_cred_low_dept cac_cred_main_st_retail cac_cred_mastercard
                cac_cred_warehouse cac_cred_misc cac_cred_oil cac_cred_spec_apparel cac_cred_sport cac_cred_std_retail cac_cred_std_specialty
                cac_cred_travel cac_cred_tv_mail_ord cac_cred_high_std_retail cac_cred_high_spec_retail cac_cred_visa cac_int_mail_buy
                cac_ind1_email cac_ind2_email cac_ind3_email cac_ind4_email cac_ind5_email cac_cred_flag cac_cred_auto_loan cac_cred_education_loan
                cac_cred_financial_banking cac_cred_financial_installment cac_cred_fin_ser_insure cac_cred_leasing cac_cred_home_mortgage 
                cac_trig_coll_grad cac_trig_empty_nester cac_trig_first_child cac_trig_new_adult cac_trig_new_driver cac_trig_new_married 
                cac_trig_new_single cac_trig_new_young_adult cac_trig_retired;

    %let num_binary_vars=%sysfunc(countw(&revars)); 

    **************************************;
    * MACRO VAR LIST FOR DROPS AND KEEPS *;
    **************************************;
    %let base_drops= &revars convert_num pas;

    %let etech_keeps= cac_hh_pid cac_name_last cac_ind1_name cac_ind1_mi cac_addr_zip cac_addr_zip4 cac_addr_state cac_production cac_active_flag cac_prod_active_flag cac_census:;

    **************************************************************;
    * MACRO TO DO CHARACTER TO NUMERIC CONVERSION OF Y/N CHAR VARS;
    **************************************************************;
    filename rename temp;
     data _NULL_;
       file rename;
       put '%macro _ren_in;';
       format putvar $100.;
       %do pas = 1 %to &num_binary_vars;
         putvar = "__temp_&pas=%scan(&revars,&pas)";
         put putvar;
       %end;
       put '%mend _ren_in;';
    run;
    %include rename;

    filename myfile PIPE "gzip -dc /project/CACDIRECT/&cidatapath./RAW/O0000???_&cstate..txt.gz" lrecl=32767;
    
    * CLEAR ANY EXISTING ROWS FROM THE JOB HISTORY TABLE FOR THIS STATE, YEAR, AND QUARTER;
    data jhis.cac_direct_counts_&cstate; 
      set jhis.cac_direct_counts_&cstate;
      if state="&cstate" and cac_year=&year and cac_qtr=&qtr and &year ne 2012 and &qtr ne 1 then delete;
    run;

    data cac_direct_counts_&cstate._&year._&qtr;
    
      state="&cstate";
      cac_year=&year;
      cac_qtr=&qtr;
      
      infile "wc_&cstate..txt" dsd missover ;                                                
      input @1 obs_cnt;
      length job_start_date job_end_date $7. job_start_time $8. job_end_time $8.;
      
      raw_file_record_count=obs_cnt;
      base_demo_records=0;
      indiv_demo_records=0;
      geo_interest_records=0;
      insert_records=0;
      update_records=0;
      inactive_records=0;
      deleted_records=0;
      job_start_date="&start_date";
      job_start_time="&start_time";
      job_end_date='       ';
      job_end_time='        ';
      drop obs_cnt;
    run;
    
    proc print data=cac_direct_counts_&cstate._&year._&qtr;
    run;
    
    * QC FOR RAW RECORDS;
    proc sql noprint; 
      select raw_file_record_count into :initial_raw_count
        from jhis.cac_direct_counts_&cstate
        where state="&cstate" 
          and cac_year=2012
          and cac_qtr=1;
          
      select raw_file_record_count into :current_raw_count
        from cac_direct_counts_&cstate._&year._&qtr 
        where state="&cstate" 
          and cac_year=&year
          and cac_qtr=&qtr;
     quit;
     
     %let pdiff=%sysevalf(&current_raw_count/&initial_raw_count);
     %put &year &qtr &cstate &initial_raw_count &current_raw_count &pdiff &mnval &mxval;
    
     %if %sysevalf(&current_raw_count/&initial_raw_count) > %sysevalf(&mxval) or %sysevalf(&current_raw_count/&initial_raw_count) <  %sysevalf(&mnval) 
         %then %do;
                
         filename mail80 email to=("&email") 
	                         subject="Error Message from CAC DIRECT UPDATE PROCESS RAW FILE COUNT DIFFERENT THAN HISTORICAL COUNT FOR &CSTATE"
	                         from="webmaster@cac-group.com";
	  data _null_;
	    file mail80;
	    put "Record count of current raw file is &current_raw_count which is %sysevalf(&pdiff*100)% of original file &initial_raw_count";
	    put "This is outside of tolerance limits of %sysevalf(&mnval*100)% and %sysevalf(&mxval*100)%";
            put "&cstate not processed...please check raw file";
	  run;    
	
	%let abort=1;
             
     %end;
     
     %else %do;
     
        %put "Record count of current raw file is &current_raw_count which is %sysevalf(&pdiff*100)% of original file &initial_raw_count";
        %put "This is within tolerance limits of %sysevalf(&mnval*100)% and %sysevalf(&mxval*100)%";
        %put "Proceeding with load of &cstate";    
        
        %let abort=0;
        
     %end;

 %if &abort=0 %then %do;
   
    **********************;
    * STEP 1 READ RAW FILE;
    **********************;
     
     data process.raw_&cstate (rename=(%_ren_in) drop=cac_prod_code) process.bad_state_or_zip_&cstate;
     
      format CAC_ADDR_LATITUDE CAC_ADDR_LONGITUDE 13.8;
      
      length CAC_RECORD_QUALITY CAC_NUM_SOURCES CAC_ADDR_FIPS_ST CAC_NAME_TITLE CAC_ADDR_QUALITY CAC_ADDR_TYPE
      
      CAC_IND1_GENDER CAC_IND1_RELATIONSHIP CAC_IND2_GENDER
      CAC_IND2_RELATIONSHIP CAC_IND3_GENDER CAC_IND3_RELATIONSHIP CAC_IND4_GENDER CAC_IND4_AGE_ENH CAC_IND4_RELATIONSHIP 
      CAC_IND5_GENDER CAC_IND5_RELATIONSHIP  
      CAC_ADDR_LAT_LONG_IND CAC_HOME_OWN CAC_DEMO_MARITAL_STATUS CAC_HOME_DWELL_TYPE CAC_HOME_RES_LENGTH CAC_DEMO_NUM_ADULTS 
      CAC_DEMO_OCCUPATION
      CAC_HOME_MTG_AMT_ORIG
      CAC_HOME_EQUITY_AVAIL CAC_HOME_MARKET_VAL
      CAC_INT_POL_PARTY CAC_TRIG_CELL_PHONE_RANK CAC_TRIG_HOUSE_PURCH_RANK CAC_TRIG_SAT_DISH_RANK CAC_TRIG_LUX_VEHICLE_RANK CAC_TRIG_NONLUX_VEHICLE_RANK
      CAC_TRIG_HI_SPD_INT_RANK CAC_TRIG_HOME_LOAN_RANK CAC_TRIG_CHANGE_RES CAC_INT_POL_DONOR
      CAC_DEMO_AGE_ENH CAC_DEMO_KIDS_ENH CAC_DEMO_HH_SIZE_ENH CAC_DEMO_HH_TYPE_ENH CAC_DEMO_NUM_KIDS_ENH CAC_DEMO_ADULT_18_24_ENH CAC_DEMO_ADULT_25_34_ENH
      CAC_DEMO_ADULT_35_44_INF_ENH CAC_DEMO_ADULT_35_44_ENH CAC_DEMO_ADULT_45_54_ENH CAC_DEMO_ADULT_45_64_INF_ENH CAC_DEMO_ADULT_55_64_ENH
      CAC_DEMO_ADULT_65_PLUS_INF_ENH CAC_DEMO_ADULT_65_74_ENH CAC_DEMO_ADULT_75_PLUS_ENH CAC_DEMO_ADULT_UNDER_35_INF_ENH CAC_DEMO_ADULT_UNKNOWN_ENH
      CAC_DEMO_KIDS_00_02_ENH CAC_DEMO_KIDS_11_15_ENH CAC_DEMO_KIDS_16_17_ENH CAC_DEMO_KIDS_03_05_ENH CAC_DEMO_KIDS_06_10_ENH CAC_IND1_AGE_ENH
      CAC_IND2_AGE_ENH CAC_IND3_AGE_ENH CAC_IND4_AGE_ENH CAC_IND5_AGE_ENH
      CAC_DEMO_GENDER_CHILD_1_ENH CAC_DEMO_GENDER_CHILD_2_ENH CAC_DEMO_GENDER_CHILD_3_ENH CAC_DEMO_GENDER_CHILD_4_ENH 
      CAC_HOME_MTG CAC_HOME_MTG_SECOND 
      CAC_TRIG_CREDIT_CARD_NUM CAC_INT_POL_DONOR CAC_HOME_SALE_PRICE 
      CAC_DEMO_AGE_ENH CAC_DEMO_KIDS_ENH CAC_DEMO_HH_SIZE_ENH CAC_DEMO_HH_TYPE_ENH CAC_DEMO_NUM_KIDS_ENH CAC_DEMO_ADULT_18_24_ENH CAC_DEMO_ADULT_25_34_ENH 
      CAC_DEMO_ADULT_35_44_INF_ENH CAC_DEMO_ADULT_35_44_ENH CAC_DEMO_ADULT_45_54_ENH CAC_DEMO_ADULT_45_64_INF_ENH CAC_DEMO_ADULT_55_64_ENH 
      CAC_DEMO_ADULT_65_PLUS_INF_ENH CAC_DEMO_ADULT_65_74_ENH CAC_DEMO_ADULT_75_PLUS_ENH CAC_DEMO_ADULT_UNDER_35_INF_ENH  CAC_DEMO_ADULT_UNKNOWN_ENH 
      CAC_DEMO_KIDS_00_02_ENH CAC_DEMO_KIDS_11_15_ENH CAC_DEMO_KIDS_16_17_ENH CAC_DEMO_KIDS_03_05_ENH CAC_DEMO_KIDS_06_10_ENH CAC_IND1_AGE_ENH 
      CAC_IND2_AGE_ENH CAC_IND3_AGE_ENH CAC_IND4_AGE_ENH CAC_IND5_AGE_ENH CAC_DEMO_INCOME_INDEX_ENH CAC_DEMO_EDUCATION_ENH CAC_HOME_VALUATION_ENH 4; 
      
      
      
      infile myfile lrecl=32767 truncover obs=&testobs;
      %input_data;

      ***************************************************************;
      * GETS RID OF ALL RECORDS THAT ARE NOT IN STATE BEING PROCESSED;
      ***************************************************************;
      change_state=0;

      if cac_addr_zip eq '00000' or cac_addr_state ne "&cstate" then change_state=1;
      
      if change_state=0 then do;
         if cac_addr_state ne zipstate(cac_addr_zip) then change_state=1;
      end;

      length CAC_HH_PID $27.;
      CAC_HH_PID=compress(cac_addr_zip || "|" || cac_addr_id || "|" || eps_hh_pid);
      label CAC_HH_PID = "Household Persistent ID";

      length CAC_NAME_FIRST $14.;
      CAC_NAME_FIRST=cac_ind1_name;
      
      CAC_ADDR_FULL=compbl(strip(cac_addr_num)||" "||strip(cac_addr_frac)||" "||strip(cac_addr_street_pre)||" "||
                                          strip(cac_addr_street)||" "||strip(cac_addr_street_suff)||" "||strip(cac_addr_street_suff_dir)||" "||
                                          strip(cac_addr_second_unit)||" "||strip(cac_addr_po_route_num)||" "||strip(cac_addr_po_box_designator));
   
      label CAC_ADDR_FULL= "Mailing Address CAC Compiled From Vendor Address Components";
      
      CAC_RECNO=_n_;

      CAC_QTR=&qtr;
      CAC_YEAR=&year;

      label CAC_RECNO= "Record Number";
      label CAC_QTR   = "Raw Data Quarter";
      label CAC_YEAR  = "Raw Data Year";
   
      CAC_PRODUCTION=(cac_prod_code ='P');
      CAC_ACTIVE_FLAG=1;

      if cac_production=1 and cac_active_flag=1 then cac_prod_active_flag=1;
            else if cac_production=0 and cac_active_flag=1 then CAC_PROD_ACTIVE_FLAG=2;
            else CAC_PROD_ACTIVE_FLAG=3;
      label CAC_PROD_ACTIVE_FLAG ="Production Active Indicator Created by CAC Group";
      
      
      length CAC_ADDR_ZIP2 $7.;
      if strip(cac_addr_zip4)= '' then cac_addr_zip2=cac_addr_zip||'XX';
         else cac_addr_zip2=cac_addr_zip||substr(cac_addr_zip4,1,2);
         
      label CAC_ADDR_ZIP2="Zip Code +2";      
     
      **********************************************;
      * CDI: CONSUMER DENSITY INDEX CDI as cnty_size;
      **********************************************;
      cdi_key=cac_census_2010_state_code*1000+cac_census_2010_county_code;
      CAC_ADDR_CDI=put(cdi_key,cdif.);
      if CAC_ADDR_CDI='' then cac_addr_cdi='d';
      label CAC_ADDR_CDI='Consumer Density Index (CDI), By CAC Group';
      drop cdi_key;
  
      ******************************************;
      * CONVERT Y/N CHAR INTEREST VARS TO BINARY;
      ******************************************;
      array _char(&num_binary_vars) $ &revars;
      array _num(&num_binary_vars) __temp_1 - __temp_&num_binary_vars;
         do pas = 1 to &num_binary_vars;
            _num(pas) = (upcase(strip(_char(pas))) = 'Y');
         end;


      *****************************************************;
      * CREATE COUNTER FOR PRESENCE OF INTEREST AND HOBBIES;
      *****************************************************;
      
      cac_int_num=sum(of __temp_1-__temp_121);  **** LINES UP WITH REVARS LIST - BE CAREFUL IN CHANGING USED TO BE cac_int_1-cac_int_121;
      cac_int_flag=(cac_int_num>1);
  
      ******************;
      * BUCKET VARIABLES;
      ******************;
      if cac_demo_hh_size_enh ge 7 then cac_demo_hh_size_enh=7;
      if cac_demo_num_kids_enh ge 5 then cac_demo_num_kids_enh=5;
      if cac_demo_num_adults ge 4 then cac_demo_num_adults=4;  
      if cac_trig_credit_card_num ge 6 then cac_trig_credit_card_num=6;
      if cac_demo_num_generations_enh  ge 4 then cac_demo_num_generations_enh=4;

      *****************************************;
      * RECODE NARROW INCOME BANDS INTO NUMERIC
      *****************************************;
   
      format cac_demo_narrow_inc_num 3.1;
   
      if cac_demo_income_narrow_enh="0" then cac_demo_narrow_inc_num=7.5;
      else if cac_demo_income_narrow_enh="1" then cac_demo_narrow_inc_num=17.5;
      else if cac_demo_income_narrow_enh="2" then cac_demo_narrow_inc_num=22.5;
      else if cac_demo_income_narrow_enh="3" then cac_demo_narrow_inc_num=27.5;
      else if cac_demo_income_narrow_enh="4" then cac_demo_narrow_inc_num=32.5;
      else if cac_demo_income_narrow_enh="5" then cac_demo_narrow_inc_num=37.5;
      else if cac_demo_income_narrow_enh="6" then cac_demo_narrow_inc_num=42.5;
      else if cac_demo_income_narrow_enh="7" then cac_demo_narrow_inc_num=47.5;
      else if cac_demo_income_narrow_enh="8" then cac_demo_narrow_inc_num=52.5;
      else if cac_demo_income_narrow_enh="9" then cac_demo_narrow_inc_num=57.5;
      else if cac_demo_income_narrow_enh="A" then cac_demo_narrow_inc_num=62.5;
      else if cac_demo_income_narrow_enh="B" then cac_demo_narrow_inc_num=67.5;
      else if cac_demo_income_narrow_enh="C" then cac_demo_narrow_inc_num=72.5;
      else if cac_demo_income_narrow_enh="D" then cac_demo_narrow_inc_num=77.5;
      else if cac_demo_income_narrow_enh="E" then cac_demo_narrow_inc_num=82.5;
      else if cac_demo_income_narrow_enh="F" then cac_demo_narrow_inc_num=87.5;
      else if cac_demo_income_narrow_enh="G" then cac_demo_narrow_inc_num=92.5;
      else if cac_demo_income_narrow_enh="H" then cac_demo_narrow_inc_num=97.5;
      else if cac_demo_income_narrow_enh="I" then cac_demo_narrow_inc_num=102.5;
      else if cac_demo_income_narrow_enh="J" then cac_demo_narrow_inc_num=107.5;
      else if cac_demo_income_narrow_enh="K" then cac_demo_narrow_inc_num=112.5;
      else if cac_demo_income_narrow_enh="L" then cac_demo_narrow_inc_num=117.5;
      else if cac_demo_income_narrow_enh="M" then cac_demo_narrow_inc_num=122.5;
      else if cac_demo_income_narrow_enh="N" then cac_demo_narrow_inc_num=127.5;
      else if cac_demo_income_narrow_enh="O" then cac_demo_narrow_inc_num=132.5;
      else if cac_demo_income_narrow_enh="P" then cac_demo_narrow_inc_num=137.5;
      else if cac_demo_income_narrow_enh="Q" then cac_demo_narrow_inc_num=142.5;
      else if cac_demo_income_narrow_enh="R" then cac_demo_narrow_inc_num=147.5;
      else if cac_demo_income_narrow_enh="S" then cac_demo_narrow_inc_num=155;
      else if cac_demo_income_narrow_enh="T" then cac_demo_narrow_inc_num=165;
      else if cac_demo_income_narrow_enh="U" then cac_demo_narrow_inc_num=172.5;
      else if cac_demo_income_narrow_enh="V" then cac_demo_narrow_inc_num=182.5;
      else if cac_demo_income_narrow_enh="W" then cac_demo_narrow_inc_num=195;
      else if cac_demo_income_narrow_enh="X" then cac_demo_narrow_inc_num=212.5;
      else if cac_demo_income_narrow_enh="Y" then cac_demo_narrow_inc_num=237.5;
      else if cac_demo_income_narrow_enh="Z" then cac_demo_narrow_inc_num=250;
   
      
   
      cac_cred_mortgage_income_index=cac_home_mtg/cac_demo_narrow_inc_num;
   
      if cac_home_mtg_second=. then cac_home_mtg_second=0;
   
      cac_cred_mortgage_income_index_2=(cac_home_mtg+cac_home_mtg_second)/cac_demo_narrow_inc_num;
   
      if cac_home_sq_foot="A" then cac_demo_square_feet=750;
      else if cac_home_sq_foot="B" then cac_demo_square_feet=875;
      else if cac_home_sq_foot="C" then cac_demo_square_feet=1125;
      else if cac_home_sq_foot="D" then cac_demo_square_feet=1375;
      else if cac_home_sq_foot="E" then cac_demo_square_feet=1625;
      else if cac_home_sq_foot="F" then cac_demo_square_feet=1875;
      else if cac_home_sq_foot="G" then cac_demo_square_feet=2250;
      else if cac_home_sq_foot="H" then cac_demo_square_feet=2750;
      else if cac_home_sq_foot="I" then cac_demo_square_feet=3250;
      else if cac_home_sq_foot="J" then cac_demo_square_feet=3750;
      else if cac_home_sq_foot="K" then cac_demo_square_feet=4500;
      else if cac_home_sq_foot="L" then cac_demo_square_feet=5500;
      else if cac_home_sq_foot="M" then cac_demo_square_feet=6500;
      else if cac_home_sq_foot="N" then cac_demo_square_feet=7000;
      else if cac_home_sq_foot in ("Z" "") then cac_demo_square_feet=.;
   
      cac_home_price_per_sq_ft=1000*cac_home_mtg/cac_demo_square_feet;
   
      cac_demo_ppl_per_sq_ft=cac_demo_hh_size_enh/cac_demo_square_feet;
  
      **********************;
      * CONVERT MISSING TO 0;
      **********************;

      array _convert(%sysfunc(countw(&convert_vars))) &convert_vars;
         
         do convert_num = 1 to %sysfunc(countw(&convert_vars));
            if _convert(convert_num) = . then _convert(convert_num)=0;
         end;

      **********************;
      * CREATE CAC_INT_MAIL_DONOR;
      **********************;

      cac_int_mail_donor=min(2,sum(__temp_66,__temp_67,__temp_68,__temp_69,__temp_70,__temp_71,__temp_72,__temp_73,__temp_74,__temp_75,__temp_76,__temp_77,__temp_78));

      **********************;
      * FIX ENHANCED BIRTHDATE TO MATCH UNENHANCED FORMAT;
      **********************;

      %do indnum= 1 %to 5;
         if not(missing(cac_ind&indnum._birthdate_enh)) then cac_ind&indnum._birthdate_enh = substr(cac_ind&indnum._birthdate_enh,3,4)||substr(cac_ind&indnum._birthdate_enh,1,2);
      %end;      

     drop &base_drops;
    	  
     if change_state=1 then output process.bad_state_or_zip_&cstate;
	 
      output process.raw_&cstate;
    run;
    
    title1 "PRINT OF RAW FILE";
    proc print data=process.raw_&cstate (obs=10);
           var cac_census_2010: cac_addr_latitude cac_addr_longitude;
    run;
   
    ***************************************************************;
    * GETS RID OF ALL RECORDS THAT ARE NOT IN STATE BEING PROCESSED;
    ***************************************************************;
    title1 "RAW DATA &CSTATE CHANGE_STATE VALUES=1 ARE DELETED DUE TO INVALID ZIP OR STATE, 0=OK";
    proc freq data=process.raw_&cstate;
     tables change_state;
    run;
    
    ********************************************************;
    * STEP 2 MERGE NEW RAW FILE AND EXISTING BASE DEMO TABLE;
    ********************************************************;

    data process.raw_&cstate;
       set process.raw_&cstate (where=(change_state=0 and cac_addr_state eq "&cstate" and cac_addr_zip ne '00000'));
    run;
    
    proc sort data=process.raw_&cstate out=process.raw_&cstate; 
     by cac_hh_pid; 
    run;
    
    data process.raw_&cstate process.raw_&cstate._dups_&year._&qtr;
      set process.raw_&cstate;
      by cac_hh_pid;
      if first.cac_hh_pid and last.cac_hh_pid then output process.raw_&cstate;
      else output process.raw_&cstate._dups_&year._&qtr;
    run;
    
    %let dup_obs=0;
    %nobs(data=process.raw_&cstate._dups_&year._&qtr);
    %let dup_obs=&nobs;
    
    %if &dup_obs > 0 %then %do;
    	filename mail99 email to=("&email") 
	                subject="Message from CAC DIRECT UPDATE PROCESS DUPLICATES FOUND IN RAW FILE &CSTATE &QTR &YEAR"
	                from="webmaster@cac-group.com";
        data _null_;
          file mail99;
          put "DUPLICATE RECORDS FOR CAC_HH_PID WERE FOUND IN THE RAW FILE FOR &CSTATE                                                    ";
          put "THE STATE WAS PROCESSED WITHOUT THESE DUPLICATE RECORDS                                                                    ";
          put "THE DUPLICATE RECORDS WERE WRITTEN TO THE DATA SET PROCESS raw_&cstate._dups_&year._&qtr                                     ";
          put "THE NUMBER OF PAIRS OF DUPLICATES FOUND WAS &DUP_OBS                                                                       ";
          put "INVESTIGATE THESE RECORDS AND CONTACT DATA VENDOR                                                                          ";
        end;
    %end;
  
    proc sort data=cur_base.base_demo_&cstate out=old_base_demo_&cstate 
       (  
        keep=cac_hh_pid cac_qtr cac_year 
         );
       by cac_hh_pid;
    run;

    data process.bd_inserts_&cstate
         process.bd_updates_&cstate
         process.bd_deletes_&cstate
         process.bd_inactives_&cstate;
      merge process.raw_&cstate         (in=new)
            old_base_demo_&cstate       (in=old);
       
      by cac_hh_pid;
  
      if new and not old then do; 
      
         cac_qtr=&qtr;
         cac_year=&year;
      
         output process.bd_inserts_&cstate;
      end;

      else if old and not new then do;
              current_cac_qtr=&qtr;
              current_cac_year=&year;
              delete_flag=intck('QTR',yyq(cac_year,cac_qtr),yyq(current_cac_year,current_cac_qtr)) > 5; 
              if delete_flag=1 then output process.bd_deletes_&cstate;
                 else output process.bd_inactives_&cstate;
      end;
  
      else if new and old then do;
            output process.bd_updates_&cstate;
      end;
    run; 

    *****************************;
    * STEP2 QC REQUIRED FOR STEP4;
    *****************************;
    
    %nobs(data=process.bd_inserts_&cstate);
    %let insertobs=&nobs;
    %nobs(data=process.bd_updates_&cstate);
    %let updateobs=&nobs;
    %nobs(data=process.bd_inactives_&cstate)        
    %let inactiveobs=&nobs;
    %nobs(data=process.bd_deletes_&cstate);    
    %let delobs=&nobs;
  
    ***********************************;
    * STEP 3 CREATE FORMATS FOR KEEPERS;
    ***********************************;
    
    filename keepers "./keepers_&cstate..sas";
      data _null_;
        set process.bd_inactives_&cstate  end=eof;
        format putvar $100.;
        putvar = compress("'"||cac_hh_pid||"'='1'");
        file keepers;
        if _n_=1 then put 'proc format; value $keep';
        put putvar;
       if eof then put "other='0'; run;";
      run;

    %if %sysfunc(fileexist("./keepers_&cstate..sas")) %then %do; options nosource2 nomprint; %include "./keepers_&cstate..sas";  %end;  
  
    ****************************************************************************************;
    * STEP 4 CREATE NEW TABLES BASE DEMO, ETECH UPDATES, INDIV DEMO, ZIP9 2000 CENSUS LOOKUP;
    ****************************************************************************************;
 
    options source mprint;
  
    data process.base_demo_&cstate (drop=cac_indiv_: convert_num)
  
       foret.etech_&cstate (keep=&etech_keeps)
 
       indiv.indiv_demo_&cstate (keep=cac_hh_pid cac_hh_pid_ind cac_indiv_pid cac_indiv_number cac_indiv_last cac_indiv_name cac_indiv_mi
                                    cac_indiv_gender cac_indiv_age cac_indiv_birthdate cac_indiv_relationship)
                           
       process.for_parsimony_&cstate (keep=cac_hh_pid cac_production cac_active_flag cac_prod_active_flag cac_qtr cac_year cac_full_name cac_addr_full cac_addr_state cac_addr_zip);                    ;
     
      set 
       %if &insertobs >0 %then %do;
           process.bd_inserts_&cstate   (in=a)
       %end;
       
       %if &updateobs >0 %then %do;
           process.bd_updates_&cstate   (in=b)
       %end;
       
       %if &inactiveobs >0 %then %do;
           cur_base.base_demo_&cstate   (in=c where=(put(cac_hh_pid,$keep.)='1'))
       %end;
       ;
        
       * CREATE CAC_FULL_NAME - FOR NAME AND ADDRESS PARSING;
       cac_full_name=compbl(strip(cac_name_first)||" "||strip(cac_name_last));
       
       **********************;
       * CONVERT MISSING TO 0;
       **********************;
         array _convert(%sysfunc(countw(&convert_vars))) &convert_vars;
         
         do convert_num = 1 to %sysfunc(countw(&convert_vars));
            if _convert(convert_num) = . then _convert(convert_num)=0;
         end;
      
       if a then do;
      
             ************************************************;
             * OUTPUT NEW RECORDS FOR ETECH CSV FILE CREATION;
             ************************************************;
             file "/project/CACDIRECT/&cidatapath./ETECH/FORETECH/etech_CAC_&cstate..csv" dlm=",";
             put cac_hh_pid cac_name_last cac_ind1_name cac_ind1_mi cac_addr_zip cac_addr_zip4 cac_addr_state;
             output foret.etech_&cstate;
       end;
         
       else if b then do;
           cac_active_flag=1;
           if cac_production=1 and cac_active_flag=1 then cac_prod_active_flag=1;
	    else if cac_production=0 and cac_active_flag=1 then cac_prod_active_flag=2;
            else cac_prod_active_flag=3;
       end;
      
       else if c then do;
           cac_active_flag=0;
           if cac_production=1 and cac_active_flag=1 then cac_prod_active_flag=1;
	    else if cac_production=0 and cac_active_flag=1 then cac_prod_active_flag=2;
            else cac_prod_active_flag=3;
       end;

       *********************************;
       * RECREATE INDIVIDUAL DEMO TABLES;
       *********************************;
       %do m = 1 %to 5;
          format cac_hh_pid_ind $29.;
          if cac_ind%scan(&person, &m)_name eq ' ' then; 
             else  
                if cac_ind%scan(&person, &m)_name ne ' ' then do;
                   cac_indiv_number=%scan(&person, &m);
                   cac_indiv_last=cac_name_last;
                   cac_indiv_name=cac_ind%scan(&person, &m)_name;
                   cac_indiv_mi=cac_ind%scan(&person, &m)_mi;
                   cac_indiv_gender=cac_ind%scan(&person, &m)_gender;
                   cac_indiv_age=cac_ind%scan(&person, &m)_age_enh;
                   cac_indiv_birthdate=cac_ind%scan(&person, &m)_birthdate_enh;
                   cac_indiv_relationship=cac_ind%scan(&person, &m)_relationship;
                   cac_hh_pid_ind=compbl(cac_hh_pid||"|"||strip(cac_indiv_number));
                   cac_indiv_pid=strip(cac_ind%scan(&person, &m)_id);
                 
                  label
		          cac_hh_pid_ind = "Household-Level Persistent ID + person number (|1, |2, etc)"
		          cac_indiv_pid = "Epsilon Individual-Level Number of Person in HH"
		          cac_indiv_number = "Household Member Number"
		          cac_indiv_last = "Household Last Name"
		          cac_indiv_name = "Individual's Given Name"
		          cac_indiv_mi = "Individual's Middle Initial"
		          cac_indiv_gender = "Individual's Gender"
		          cac_indiv_age = "Individual's Age"
		          cac_indiv_birthdate = "Individual's Birthdate"
                          cac_indiv_relationship = "Individual's Relationship within Household";
         
                output indiv.indiv_demo_&cstate; 
         end;
         
       %end;
       
       ********;
       * LABELS;
       ********;
      	label 
 	    cac_ind1_id="Person 1 Persistent ID"
 	    cac_ind2_id="Person 2 Persistent ID"
 	    cac_ind3_id="Person 3 Persistent ID"
 	    cac_ind4_id="Person 4 Persistent ID"
 	    cac_ind5_id="Person 5 Persistent ID"
 	    cac_trig_hi_spd_int="High Speed Internet Trigger"
 	    cac_trig_hi_spd_int_dt="High Speed Internet Trigger Change Date"
 	    
 	    cac_addr_full="Mailing Address CAC Compiled From Vendor Address Components"
 	    cac_demo_narrow_inc_num="CAC Created Narrow Income Band"
 	    cac_demo_square_feet="CAC Created Home Square Feet"
 	    cac_cred_mortgage_income_index="CAC Created First Mortgage To Narrow Income Index"
 	    cac_cred_mortgage_income_index_2="CAC Created First And Second Mortgage To Narrow Income Index"
 	    cac_demo_ppl_per_sq_ft="CAC Created HH Size / HH Square Feet"
 	    cac_home_price_per_sq_ft="CAC Created First Mortgage To HH Square Feet"
 	    
 	    cac_record_quality="Record Quality Code"
 	    cac_num_sources="Number Of Sources Verifying Household (0-4)"
 	    cac_addr_fips_st="Fips State Code"
 	    cac_addr_zip="Zip Code"
 	    cac_addr_zip4="Zip Plus 4"
 	    cac_addr_dlv_pt_code="Delivery Point Code"
 	    cac_addr_carrier_rt="Carrier Route"
 	    cac_addr_dsf_seasonal="Dsf Season Code"
 	    cac_addr_dsf_type="Dsf Delivery Type Code"
 	    cac_addr_county_code="County Code"
 	    cac_addr_cbsa_code="Core Based Statistical Code (CBSA)"
 	    cac_name_last="Household Name"
 	    cac_name_suffix="Primary Name Suffix"
 	    cac_name_title="Primary Title"
 	    cac_addr_num="House Number"
 	    cac_addr_frac="House Fraction"
 	    cac_addr_street_pre="Street Prefix Direction"
 	    cac_addr_street="Street Name"
 	    cac_addr_street_suff="Street Suffix"
 	    cac_addr_street_suff_dir="Street Suffix Direction"
 	    cac_addr_po_route_num="Route Designator And Number"
 	    cac_addr_po_box_designator="Box Designator And Number"
 	    cac_addr_second_unit="Secondary Unit Designation"
 	    cac_addr_city="Post Office Name"
 	    cac_addr_state="State Abbreviation"
 	    cac_addr_censor_cd="Address Name Censor Code"
 	    cac_addr_quality="Address Quality Code"
 	    cac_addr_type="Address Type"
 	    cac_hh_verification_date="Verification Date Of Household"
 	    cac_ph_area_code="Telephone Area Code"
 	    cac_ph_number="Telephone Number"
 	    cac_ph_date="Telephone Transaction Date"
 	    cac_ind1_gender="Person 1 Gender Code"
 	    cac_ind1_name="Person 1 Given Name"
 	    cac_ind1_mi="Person 1 Middle Initial"
 	    cac_ind1_relationship="Person 1 Family Member Relationship"
 	    cac_ind2_gender="Person2 Gender Code"
 	    cac_ind2_name="Person 2 Given Name"
 	    cac_ind2_mi="Person 2 Middle Initial"
 	    cac_ind2_relationship="Person 2 Family Member Relationship"
 	    cac_ind3_gender="Person 3 Gender Code"
 	    cac_ind3_name="Person 3 Given Name"
 	    cac_ind3_mi="Person 3 Middle Initial"
 	    cac_ind3_relationship="Person 3 Family Member Relationship"
 	    cac_ind4_gender="Person 4 Gender Code"
 	    cac_ind4_name="Person 4 Given Name"
 	    cac_ind4_mi="Person 4 Middle Initial"
 	    cac_ind4_relationship="Person 4 Family Member Relationship"
 	    cac_ind5_gender="Person 5 Gender Code"
 	    cac_ind5_name="Person 5 Given Name"
 	    cac_ind5_mi="Person 5 Middle Initial"
 	    cac_ind5_relationship="Person 5 Family Member Relationship"
 	    cac_addr_longitude="Rooftop Longitude"
 	    cac_addr_lat_long_ind="Rooftop Latitude/Longitude Indicator"
 	    cac_home_own="Home Ownership Code"
 	    cac_h_ind_home_own="Home Owner Indicator"
 	    cac_demo_marital_status="Household Marital Status Code"
 	    cac_d_ind_marital_status="Household Marital Status Indicator"
 	    cac_home_dwell_type="Dwelling Type"
 	    cac_h_ind_dwell_type="Dwelling Type Indicator"
 	    cac_home_res_length="Length Of Residence Code"
 	    cac_h_ind_res_length="Length Of Residence Indicator"
 	    cac_home_built_year="Year Home Built"
      cac_demo_num_adults="Number Of Adults"
 	    cac_d_ind_num_adults="Number Of Adults Indicator"
 	    cac_demo_occupation="Occupation Code"
 	    cac_cred_amex="American Express Credit Card"
 	    cac_cred_any="Any Credit Card"
 	    cac_cred_bank="Bankcard"
 	    cac_cred_catalog="Catalog Showroom Credit Card"
 	    cac_cred_comp_electronic="Computer Electronic Credit Card"
 	    cac_cred_debit="Debit Card"
 	    cac_cred_finance="Finance Credit Card"
 	    cac_cred_furniture="Furniture Credit Card"
 	    cac_cred_grocery="Grocery Credit Card"
 	    cac_cred_home_improve="Home Improvement Credit Card"
 	    cac_cred_home_office="Home Office Supply Credit Card"
 	    cac_cred_low_dept="Low End Department Store Credit Card"
 	    cac_cred_main_st_retail="Main Street Retail Credit Card"
 	    cac_cred_mastercard="Mastercard Credit Card "
 	    cac_cred_warehouse="Membership Warehouse Credit Card"
 	    cac_cred_misc="Miscellaneous Credit Card"
 	    cac_cred_oil="Oil Gas Credit Card"
 	    cac_cred_spec_apparel="Specialty Apparel Credit Card"
 	    cac_cred_sport="Sporting Goods Credit Card"
 	    cac_cred_std_retail="Standard Retail Card"
 	    cac_cred_std_specialty="Standard Specialty Card"
 	    cac_cred_travel="Travel Entertainment Creditcard"
 	    cac_cred_tv_mail_ord="Tv Mail Order Credit Card"
 	    cac_cred_high_std_retail="Upscale Retail Credit Card"
 	    cac_cred_high_spec_retail="Upscale Spec Retail Card"
 	    cac_cred_visa="Visa Credit Card"
 	    cac_int_mail_buy="Mail Order Buyer"
 	    cac_int_mail_donor="Mail Order Donor"
 	    cac_ind1_email="Person 1 Email Flag"
 	    cac_ind2_email="Person 2 Email Flag"
 	    cac_ind3_email="Person 3 Email Flag"
 	    cac_ind4_email="Person 4 Email Flag"
 	    cac_ind5_email="Person 5 Email Flag"
      cac_int_1="Collectibles "
 	    cac_int_2="Collectibles Art Antique"
 	    cac_int_3="Bible Devotional"
 	    cac_int_4="Books Reading "
 	    cac_int_5="Automotive Work"
 	    cac_int_6="Boating Sailing "
 	    cac_int_7="Camping Hiking "
 	    cac_int_8="Cycling "
 	    cac_int_9="Fishing "
 	    cac_int_10="Fitness Exercise "
 	    cac_int_11="Skiing Snowboarding "
 	    cac_int_12="Sports And Recreation "
 	    cac_int_13="Walking For Health "
 	    cac_int_14="Own A Cat "
 	    cac_int_15="Own A Dog "
 	    cac_int_16="Pets "
 	    cac_int_17="Electronics "
 	    cac_int_18="Science Technology "
 	    cac_int_19="Investments "
 	    cac_int_20="Any Mail Order"
 	    cac_int_21="Home Furnishing Mail Order"
 	    cac_int_22="Videos Dvd Mail Order"
 	    cac_int_23="Self Improvement Courses "
 	    cac_int_24="Sewing Knitting "
 	    cac_int_25="Contests Sweepstakes "
 	    cac_int_26="Crafts "
 	    cac_int_27="Cultural Arts Events "
 	    cac_int_28="Gardening "
 	    cac_int_29="Career Advancement Courses "
 	    cac_int_30="Weight Control "
 	    cac_int_31="International Travel "
 	    cac_int_32="Usa Travel"
 	    cac_int_33="Home Improvement Diy "
 	    cac_int_34="Motorcycle Riding "
 	    cac_int_35="Donate To Charitable Causes "
 	    cac_int_36="Fashion "
 	    cac_int_37="Golf "
 	    cac_int_38="Hunting Shooting "
 	    cac_int_39="Rv Travel"
 	    cac_int_40="Gourmet Foods "
 	    cac_int_41="Photography "
 	    cac_int_42="Wines "
 	    cac_int_43="Gambling "
 	    cac_int_44="Natural Foods "
 	    cac_int_45="Grandchildren"
 	    cac_deliverability_date="Date Of Deliverability" 	    
 	    cac_demo_net_worth_enh="Epsilon Net Worth Model - Enhanced"
      cac_home_mtg_amt_orig="Original Mortgage Amount"
 	    cac_home_equity_avail="Available Home Equity In Thousands"
 	    cac_home_mtg="First Mortgage Amount In Thousands"
 	    cac_home_market_val="Home Market Value Tax Record"
 	    cac_home_sale_date="Home Sale Date"
 	    cac_home_sale_price="Home Sale Price Thousands $"
 	    cac_home_mtg_date="Mortgage Date"
 	    cac_home_mtg_second="Second Mortgage Amount In Thousands"
 	    cac_home_sq_foot="Living Area Square Footage Range"
 	    cac_addr_lot_code="Lot Code"
 	    cac_cred_flag="Credit Active"
 	    cac_cred_auto_loan="Other Credit Auto Loans"
 	    cac_cred_education_loan="Other Credit Education Student Loans"
 	    cac_cred_financial_banking="Other Credit Financial Services Banking"
 	    cac_cred_financial_installment="Other Credit Financial Services Installment"
 	    cac_cred_fin_ser_insure="Other Credit Financial Services Insurance"
 	    cac_cred_leasing="Other Credit Leasing"
 	    cac_cred_home_mortgage="Other Credit Mortgage Home Mortgage"
 	    cac_int_pol_party="Political Party Household"
 	    cac_addr_id="Address Persistent ID"
 	    cac_hh_pid="Household Persistent ID"
 	    cac_trig_cell_phone="Buy A Cell Phone Trigger"
 	    cac_trig_cell_phone_dt="Buy A Cell Phone Trigger Change Date"
 	    cac_trig_cell_phone_rank="Buy A Cell Phone Trigger Rank"
 	    cac_trig_house_purch="Buy A House Trigger"
 	    cac_trig_house_purch_dt="Buy A House Trigger Change Date"
 	    cac_trig_house_purch_rank="Buy A House Trigger Rank"
 	    cac_trig_sat_dish="Buy A Satellite Dish"
 	    cac_trig_sat_dish_dt="Buy A Satellite Dish Change Date"
 	    cac_trig_sat_dish_rank="Buy A Satellite Dish Rank"
 	    cac_trig_lux_vehicle="Buy Lease A Luxury Vehicle"
 	    cac_trig_lux_vehicle_dt="Buy Lease A Luxury Vehicle Change Date"
 	    cac_trig_lux_vehicle_rank="Buy Lease A Luxury Vehicle Rank"
 	    cac_trig_nonlux_vehicle="Buy Lease A Nonluxury Vehicle"
 	    cac_trig_nonlux_vehicle_dt="Buy Lease A Nonluxury Vehicle Change Date"
 	    cac_trig_nonlux_vehicle_rank="Buy Lease A Nonluxury Vehicle Rank"
 	    cac_trig_coll_grad_dt="College Graduate Change Date"
 	    cac_trig_coll_grad="College Graduate Trigger"
 	    cac_trig_empty_nester_dt="Empty Nester Change Date"
 	    cac_trig_empty_nester="Empty Nester Trigger"
 	    cac_trig_hi_spd_int="High Speed Internet Trigger"
 	    cac_trig_hi_spd_int_dt="High Speed Internet Trigger Change Date"
 	    cac_trig_hi_spd_int_rank="High Speed Internet Trigger Rank"
 	    cac_trig_home_loan="Home Loan Trigger"
 	    cac_trig_home_loan_dt="Home Loan Trigger Change Date"
 	    cac_trig_home_loan_rank="Home Loan Trigger Rank"
 	    cac_trig_change_res_dt="Move Residence Change Date"
 	    cac_trig_change_res="Move Residence Trigger"
 	    cac_trig_change_res_rank="Move Residence Trigger Rank"
 	    cac_trig_new_adult_dt="New Adult Change Date"
 	    cac_trig_new_adult="New Adult To File Trigger"
 	    cac_trig_new_young_adult_dt="New Young Adult To Change Date"
 	    cac_trig_new_young_adult="New Young Adult To File Trigger"
 	    cac_trig_new_driver_dt="New Driver Change Date"
 	    cac_trig_new_driver="New Pre Driver Trigger"
 	    cac_trig_new_married_dt="Newly Married Change Date"
 	    cac_trig_new_married="Newly Married Trigger"
 	    cac_trig_new_single_dt="Newly Single Change Date"
 	    cac_trig_new_single="Newly Single Trigger"
 	    cac_trig_retired_dt="Retired Change Date"
 	    cac_trig_retired="Retired Trigger"
 	    cac_trig_value_score_rank="Triggerval Valuescore"
 	    cac_trig_value_score_dt="Valuescore Change Date"
 	    cac_trig_value_score="Valuescore Trigger"
 	    cac_trig_home_mkt_value="Home Market Value Trigger"
 	    cac_trig_home_mkt_value_dt="Home Mkt Value Change Date"
 	    cac_trig_home_mkt_value_amt="Triggerval Home Market Value"
 	    cac_trig_income_dt="Income Change Date"
 	    cac_trig_income="Income Trigger"
 	    cac_trig_income_value="Triggerval Income"
 	    cac_trig_first_child_dt="First Child Change Date"
 	    cac_trig_first_child="New First Child 0-2 Years Old Trigger"
 	    cac_trig_credit_card_dt="Credit Card Change Date"
 	    cac_trig_credit_card="Credit Card Trigger"
 	    cac_trig_credit_card_num="Triggerval Num Of Credit Cards"
 	    cac_int_46="Baking All"
 	    cac_int_47="Bird Feeding Watching All"
 	    cac_int_48="Cigar Smoking All"
 	    cac_int_49="Cooking All"
 	    cac_int_50="Hobbies Any All"
 	    cac_int_51="Home Study Courses All"
 	    cac_int_52="Quilting All"
 	    cac_int_53="Scrapbooking All"
 	    cac_int_54="Woodworking All"
 	    cac_int_55="Best Selling Fiction All"
 	    cac_int_56="Books Reading All"
 	    cac_int_57="Childrens Books All"
 	    cac_int_58="Cooking Culinary All"
 	    cac_int_59="Country Lifestyle All"
 	    cac_int_60="Entertainment All"
 	    cac_int_61="Interior Decorating All"
 	    cac_int_62="Medical Or Health All"
 	    cac_int_63="Military All"
 	    cac_int_64="Romance All"
 	    cac_int_65="World News All"
 	    cac_int_66="Donor Active Military All"
 	    cac_int_67="Donor Alzheimers All"
 	    cac_int_68="Donor Animal Welfare All"
 	    cac_int_69="Donor Arts Or Cultural All"
 	    cac_int_70="Donor Cancer All"
 	    cac_int_71="Donor Catholic All"
 	    cac_int_72="Donor Childrens All"
 	    cac_int_73="Donor Humanitarian All"
 	    cac_int_74="Donor Native American All"
 	    cac_int_75="Donor Other Religious All"
 	    cac_int_76="Donor Political Conservative All"
 	    cac_int_77="Donor Political Liberal All"
 	    cac_int_78="Donor Veteran All"
 	    cac_int_79="Donor World Relief All"
 	    cac_int_80="Wildlife Environmental Causes All"
 	    cac_int_81="Collectibles Dolls All"
 	    cac_int_82="Collectibles Figurines All"
 	    cac_int_83="Collectibles Stamps All"
 	    cac_int_84="Collectibles Coin All"
 	    cac_int_85="Burial Insurance All"
 	    cac_int_86="Insurance All"
 	    cac_int_87="Juvenile Life Insurance All"
 	    cac_int_88="Life Insurance All"
 	    cac_int_89="Medicare Coverage All"
 	    cac_int_90="Mutual Funds All"
 	    cac_int_91="Stocks Or Bonds All"
 	    cac_int_92="Mail Order Apparel All"
 	    cac_int_93="Mail Order Big & Tall All"
 	    cac_int_94="Mail Order Books All"
 	    cac_int_95="Mail Order Childrens Products All"
 	    cac_int_96="Mail Order Food All"
 	    cac_int_97="Mail Order Gifts All"
 	    cac_int_98="Mail Order Health And Beauty Products All"
 	    cac_int_99="Mail Order Jewelry All"
 	    cac_int_100="Mail Order Magazines All"
 	    cac_int_101="Mail Order Womens Plus All"
 	    cac_int_102="Christian Or Gospel All"
 	    cac_int_103="Classical All"
 	    cac_int_104="Country All"
 	    cac_int_105="Jazz All"
 	    cac_int_106="Music Any All"
 	    cac_int_107="R And B Music All"
 	    cac_int_108="Rock N Roll All"
 	    cac_int_109="Nutrition And Diet All"
 	    cac_int_110="Vitamins And Supplements All"
 	    cac_int_111="Online Household All"
 	    cac_int_112="Swimming Pool All"
 	    cac_int_113="Hunting Big Game All"
 	    cac_int_114="Nascar All"
 	    cac_int_115="Running Jogging All"
 	    cac_int_116="Yoga Pilates All"
 	    cac_int_117="Business Travel All"
 	    cac_int_118="Cruise Ship Vacation All"
 	    cac_int_119="Leisure Travel All"
 	    cac_int_120="Timeshare All"
 	    cac_int_121="Traveler All"
 	    cac_int_pol_donor="Political Donor Propensity"
 	    cac_production="Production Code"
 	    cac_active_flag="Active Record"
 	    cac_addr_zip2="Zip Code +2"
 	    /*2015Q1R1 RSS*/
 	    cac_demo_dob_child_1_ind_enh="Child 1 Birthdate Indicator"
      cac_demo_dob_child_2_ind_enh="Child 2 Birthdate Indicator"
      cac_demo_dob_child_3_ind_enh="Child 3 Birthdate Indicator"
      cac_demo_dob_child_4_ind_enh="Child 4 Birthdate Indicator"
      cac_demo_dob_child_1_enh="Child 1 Birthdate"
      cac_demo_dob_child_2_enh="Child 2 Birthdate"
      cac_demo_dob_child_3_enh="Child 3 Birthdate"
      cac_demo_dob_child_4_enh="Child 4 Birthdate"
 	    cac_demo_gender_child_1_enh="Child 1 Gender"
 	    cac_demo_gender_child_2_enh="Child 2 Gender"
 	    cac_demo_gender_child_3_enh="Child 3 Gender"
 	    cac_demo_gender_child_4_enh="Child 4 Gender"
 	    cac_demo_income_narrow_enh="Advantage Target Narrow Band Income Enhanced"
 	    cac_int_num="Number Of Individual HH Interests"
 	    cac_int_flag="Individual HH Interests Present Flag"
 	    cac_addr_latitude="Rooftop Latitude"
 	    cac_name_first="First Name P1"
 	    /*Q4MM*/
 	    CAC_CENSUS_2010_BLOCK="Census 2010 Block Enhanced"
	    CAC_CENSUS_2010_COUNTY_CODE ="Census 2010 County Code Enhanced"
	    CAC_CENSUS_2010_MATCH_TYPE ="Census 2010 Match Type Enhanced"
	    CAC_CENSUS_2010_STATE_CODE="Census 2010 State Code Enhanced"
	    CAC_CENSUS_2010_TRACT_BLOCK_GRP="Census 2010 Tract/Block Group  Enhanced"
	    CAC_VALUE_SCORE_ALL_ENH="Target Valuescore For All Marketers Enhanced"
	    CAC_VALUE_SCORE_AUTO_FINANCE_ENH="Target Valuescore For Auto Finance Marketers Enhanced"
	    CAC_VALUE_SCORE_BANK_CARD_ENH="Target Valuescore For Bank Card Marketers Enhanced"
	    CAC_VALUE_SCORE_RETAIL_ENH="Target Valuescore For Retail Marketers Enhanced"
      CAC_DEMO_AGE_ENH="Household Age Enhanced"
	    CAC_D_IND_AGE_ENH="Household Age Indicator Enhanced"
	    CAC_DEMO_KIDS_ENH="Advantage Presence Of Children Enhanced"
	    CAC_D_IND_KIDS_ENH="Presence Of Children Indicator Enhanced"
	    CAC_DEMO_HH_SIZE_ENH="Household Size Enhanced"
	    CAC_D_IND_HH_SIZE_ENH="Household Size Indicator Enhanced"
	    CAC_DEMO_NUM_KIDS_ENH="Number Of Children In Household Enhanced"
	    CAC_DEMO_ADULT_18_24_ENH="Presence Of Adults Age 18-24 Enhanced"
	    CAC_DEMO_ADULT_25_34_ENH="Presence Of Adults Age 25-34 Enhanced"
	    CAC_DEMO_ADULT_35_44_INF_ENH="Presence Of Adults Age 35-44 (Inferred) Enhanced"
	    CAC_DEMO_ADULT_35_44_ENH="Presence Of Adults Age 35-44 Enhanced"
	    CAC_DEMO_ADULT_45_54_ENH="Presence Of Adults Age 45-54 Enhanced"
	    CAC_DEMO_ADULT_45_64_INF_ENH="Presence Of Adults Age 45-64 (Inferred) Enhanced"
	    CAC_DEMO_ADULT_55_64_ENH="Presence Of Adults Age 55-64 Enhanced"
	    CAC_DEMO_ADULT_65_PLUS_INF_ENH="Presence Of Adults Age 65+ (Inferred) Enhanced"
	    CAC_DEMO_ADULT_65_74_ENH="Presence Of Adults Age 65-74 Enhanced"
	    CAC_DEMO_ADULT_75_PLUS_ENH="Presence Of Adults Age 75+ Enhanced"
	    CAC_DEMO_ADULT_UNDER_35_INF_ENH="Presence Of Adults Age Under 35 Enhanced"
	    CAC_DEMO_ADULT_UNKNOWN_ENH="Presence Of Adults Unknown Age Enhanced"
	    CAC_DEMO_KIDS_00_02_ENH="Presence Of Children Age 0-2 Enhanced"
	    CAC_DEMO_KIDS_11_15_ENH="Presence Of Children Age 11-15 Enhanced"
	    CAC_DEMO_KIDS_16_17_ENH="Presence Of Children Age 16-17 Enhanced"
	    CAC_DEMO_KIDS_03_05_ENH="Presence Of Children Age 3-5 Enhanced"
	    CAC_DEMO_KIDS_06_10_ENH="Presence Of Children Age 6-10 Enhanced"
	    CAC_DEMO_HH_TYPE_ENH="Household Type Code Enhanced"
      CAC_IND1_BIRTHDATE_ENH="Person 1 Birth Date Enhanced"
	    CAC_IND1_BIRTHDATE_IND_ENH="Adult Birth Date Level Indicator 1 Enhanced"
	    CAC_IND1_AGE_ENH="Person 1 Exact Age Enhanced"
	    CAC_IND2_BIRTHDATE_ENH="Person 2 Birth Date Enhanced"
	    CAC_IND2_BIRTHDATE_IND_ENH="Adult Birth Date Level Indicator 2 Enhanced"
	    CAC_IND2_AGE_ENH="Person 2 Exact Age Enhanced"
	    CAC_IND3_BIRTHDATE_ENH="Person 3 Birth Date Enhanced"
	    CAC_IND3_BIRTHDATE_IND_ENH="Adult Birth Date Level Indicator 3 Enhanced"
	    CAC_IND3_AGE_ENH="Person 3 Exact Age Enhanced"
	    CAC_IND4_BIRTHDATE_ENH="Person 4 Birth Date Enhanced"
	    CAC_IND4_BIRTHDATE_IND_ENH="Adult Birth Date Level Indicator 4 Enhanced"
	    CAC_IND4_AGE_ENH="Person 4 Exact Age Enhanced"
	    CAC_IND5_BIRTHDATE_ENH="Person 5 Birth Date Enhanced"
	    CAC_IND5_BIRTHDATE_IND_ENH="Adult Birth Date Level Indicator 5 Enhanced"
	    CAC_IND5_AGE_ENH="Person 5 Exact Age Enhanced"
	    CAC_DEMO_NET_WORTH_ENH="Epsilon Net Worth Model Enhanced"
	    CAC_DEMO_NUM_GENERATIONS_ENH="Number of Generations in Household Enhanced"
	    CAC_HOME_VALUATION_ENH="Home Valuation Model Enhanced"
	    CAC_DEMO_INCOME_INDEX_ENH="Household Income Index Enhanced"
 	    CAC_H_IND_HOME_VALUATION_ENH="Home Valuation Indicator"
 	    CAC_DEMO_INCOME_ENH="Household Income Identifier Enhanced"      
 	    CAC_DEMO_INCOME_INF_ENH="Household Income Identifier Indicator Enhanced"     
 	    CAC_DEMO_EDUCATION_ENH="Household Education Enhanced"      
 	    CAC_DEMO_D_IND_EDUCATION_ENH="Household Education Indicator Enhanced"
 	    ;	    
          output process.for_parsimony_&cstate;
          output process.base_demo_&cstate;
    run;

    * PRE-SORT INDIV TABLE;
       proc sort data=indiv.indiv_demo_&cstate; 
          by cac_hh_pid cac_indiv_number;
       run;
  
    * QC FOR BASE DEMO RECORDS;
    %nobs(data=process.base_demo_&cstate);
    %let current_base_demo_obs=&nobs;
    
    %nobs(data=cur_base.base_demo_&cstate);
    %let initial_base_demo_obs=&nobs;
     
    %let pdiff=%sysevalf(&current_base_demo_obs/&initial_base_demo_obs);
         
    %if %sysevalf(&current_base_demo_obs/&initial_base_demo_obs) > %sysevalf(&mxval) or %sysevalf(&current_base_demo_obs/&initial_base_demo_obs) < %sysevalf(&mnval) %then %do;   
    
         filename mail81 email to=("&email") 
	 	                         subject="Error Message from CAC DIRECT UPDATE PROCESS BASE DEMO COUNT DIFFERENT THAN HISTORICAL COUNT FOR &CSTATE"
	 	                         from="webmaster@cac-group.com";
	 	  data _null_;
	 	    file mail81;
                    put "Base Demo Obs is &current_base_demo_obs which is %sysevalf(&pdiff*100)% of original Base Demo &initial_base_demo_obs";
                    put "This is outside of tolerance limits of %sysevalf(&mnval*100)% and %sysevalf(&mxval*100)%";
                    put "&cstate Processing Stopped..please check raw file";
	          run;  
	          
	%let abort=1;
	          
    %end;
         
    %else %do;
                   %put "Record count of Base Demo is &current_base_demo_obs which is %sysevalf(&pdiff*100)% of original Base Demo &initial_base_demo_obs";
                   %put "This is within tolerance limits of %sysevalf(&mnval*100)% and %sysevalf(&mxval*100)%";
                   %put "Proceeding with load of &cstate";
                   
        %let abort=0;
    %end;
         
 %if &abort=0 %then %do;         
         
     data temp;
      state="&cstate";
      cac_year=&year;
      cac_qtr=&qtr;
      base_demo_records=&nobs;
     run;
     
     data cac_direct_counts_&cstate._&year._&qtr;
       update cac_direct_counts_&cstate._&year._&qtr temp;
       by state cac_year cac_qtr;
     run;   
     
     proc datasets lib=work;
       delete temp;
     quit;
     run;
     
   
    ******************************************************************************************;
    * STEP 5: RUN PARSIMONY TO  PARSE NAME AND ADDRESS CREATE FUZZY VARIABLES AND CREATE MKEYS;
    ******************************************************************************************;
  
    %parsimony
     (inlib=process, 
     indata=for_parsimony_&cstate, 
     outlib=scf, 
     outdata=tsp_MKEY_&cstate, 
     keep_clean=0,
     keep_keys=1, 
     keep_pieces=0, 
     pname_form=1, 
     pname1=cac_full_name, 
     pname2=, 
     paddr_form=1, 
     paddr1=cac_addr_full, 
     paddr2=, 
     pstate=cac_addr_state, 
     pzip=cac_addr_zip);

    ********************************;
    * STEP 6: CREATE SCF/MKEY FILES ;
    ********************************;
   
      %macro scf_mkey_creation;
   
      ****************************;
      ** Get list of valid SCFs **;
      ****************************;
      data scf.tsp_MKEY_&cstate;
        set scf.tsp_MKEY_&cstate;
            informat state $2. st_scf $6.;
            state = "&curst";
            mk_scf=substr(cac_addr_zip,1,3);
            st_scf = compress(state||'_'||mk_scf);
      run;
   
      proc sort data=scf.tsp_MKEY_&cstate out=scf_&curst nodupkey;
         by st_scf;
      run;
   
      ***********************************;
      ** Create global macro variables **;
      ***********************************;
       
       %global scfs;
       
       ** Put list of SCFs into macro variable **;
   
       proc sql noprint;
         select compress(st_scf) into :scfs separated by ' ' 
         from scf_&curst
         order by compress(st_scf);
       quit;
       
       %put &scfs;
   
       ** Get state/scf count and write out the count variable **;
   
       %macro wc(list);
         %global count; 
         %let count = 0;
         
         %do %while(%qscan(&list, &count+1, %str( )) ne %str());
            %let count = %eval(&count+1);
         %end;
         %mend wc;
       %wc(&scfs);
   
       %let scf_list = &scfs;
       %let num_scf = &count;
   
     ***********************************************************;
     ** Output separate dataset for each SCF-MKEY combination **;
     ***********************************************************;
   
       %macro s_m_output; 
           
           %do m = 1 %to 7;             
                 data %do j = 1 %to &num_scf;
                    scf.scf_%scan(&scf_list, &j)_key&m
                      %end;;
             
              set scf.tsp_mkey_&cstate ;
             
             %do j = 1 %to &num_scf; 
                if st_scf = "%qscan(&scf_list, &j)" then output scf.scf_%scan(&scf_list, &j)_key&m;    
             %end;
             run;
          
             %do k = 1 %to &num_scf;
                 proc sort data=scf.scf_%scan(&scf_list, &k)_key&m;
                  by mkey&m descending cac_production descending cac_active_flag descending cac_year descending cac_qtr cac_hh_pid;
                 run;
             %end;
   
            %do z = 1 %to &num_scf;
   
               data scf.scf_%scan(&scf_list, &z)_key&m (keep=mkey&m cac_hh_pid cac_production cac_active_flag cac_qtr);
                 set scf.scf_%scan(&scf_list, &z)_key&m;
                 by mkey&m descending cac_production descending cac_active_flag descending cac_year descending cac_qtr cac_hh_pid;
                 if first.mkey&m;
             %end;
         %end;
   
       %mend s_m_output;
       %s_m_output;
   
      *********************************;
      ** Clean up temporary datasets **;
      *********************************;
       
       proc datasets lib=work nolist;
         delete scf_&curst;
       quit;
       run;
   
     %mend scf_mkey_creation;
     %scf_mkey_creation;

    ************************************;
    * STEP 7: CREATE GEO INTEREST TABLES;
    ************************************;
    %macro geo_int;

    ***************************************************************;
    * LIMIT BASE DEMO TO P1 WITH INTERESTS AND CREATE cac_addr_zip2
    ***************************************************************;
  
     data zip2 (keep=cac_addr_zip cac_addr_zip2 cac_addr_zip4 cac_production cac_active_flag cac_addr_state) 
          p1_base_demo_&cstate;
        set process.base_demo_&cstate (keep=cac_addr_state cac_addr_zip cac_addr_zip4 cac_production cac_addr_zip2 cac_active_flag cac_int_flag cac_int_:  
                             where=(cac_production=1 and cac_active_flag=1));
           output zip2;
           if (cac_int_flag=1) then output p1_base_demo_&cstate;
     run;

     proc print data=zip2 (obs=10);
        title "PRINT OF ZIPS AFTER ZIP2 FORMATTING FOR &cstate";
        title2 "JUST MAKE SURE THAT THE cac_addr_zip2 IS BEING CREATED CORRECTLY";
     run;

     %macro xzip;

    *****************************************************;
    * SORT DATASET BY ZIP2 WHERE ZIP2 IS NOT EQUAL TO XX
    * COUNT NUMBER OF RECORDS IN UNIQUE ZIP2 AND SAVE
    * AS MAS_COUNT
    *****************************************************;

      proc sort data=zip2 (keep=cac_addr_zip2 cac_addr_zip cac_addr_state where=(substr(cac_addr_zip2,6,2) ne 'XX')) out=zx2;
         by cac_addr_zip2;
      run;

      data allzip2;
         set zx2;
         by cac_addr_zip2;
         if first.cac_addr_zip2 then mas_count = 0;
         mas_count + 1;
         if last.cac_addr_zip2 then output;
      run;

    *****************************************************;
    * SORT DATASET BY ZIP2 WHERE ZIP2 IS NOT EQUAL TO XX
    * COUNT NUMBER OF RECORDS IN UNIQUE ZIP2 AND SAVE
    * AS SEL_HH_COUNT AND COUNT TOTALS FOR EACH INTEREST
    *****************************************************;

      proc sort data=p1_base_demo_&cstate (where=(substr(cac_addr_zip2,6,2) ne 'XX')) out=hhselz;
         by cac_addr_zip2;
      run;

      data select_cac_addr_zip2 (keep=geo_cac_int_1-geo_cac_int_121 sel_hh_count cac_addr_zip cac_addr_zip2 cac_addr_state);
         set hhselz;

         array all_int{121}  geo_cac_int_1-geo_cac_int_121;
         array  hh_int{121}  cac_int_1-cac_int_121;
         by cac_addr_zip2;

         if first.cac_addr_zip2 then do;
            do i = 1 to 121;
               all_int{i} = 0;
            end;
            sel_hh_count = 0;
         end;
         sel_hh_count + 1;
         do i = 1 to 121;
            all_int{i} + hh_int{i};
         end;
         if last.cac_addr_zip2 then output;
      run;

    ******************************;
    * MERGE DATASETS BACK TOGETHER
    ******************************;

      data cac_addr_zip2_x;
         merge select_cac_addr_zip2 (in=a)
               allzip2 (in=b);
         by cac_addr_zip2;
         if a and b then flag=1;
         if a and not b then flag=2;
         if b and not a then flag=3;
      run;

      proc freq data=cac_addr_zip2_x;
         title 'SHOULD BE NO RECORDS WITH FLAG=2';
         tables flag /list missing;
      run;

      data cac_addr_zip2_x;
         set cac_addr_zip2_x;
         drop flag;
      run;

    %mend xzip;
    %xzip;

    ************************************************************************;
    * BREAK INTO THREE DATASETS: ONES WITH ZIP2 DATA FOR MORE THAN 5 HH (A)
    *                            ONES WITH ZIP2 DATA FOR LESS THAN 6 HH (B)
    *                            ONES WITH ZIP2='XX' (C)
    ************************************************************************;

    data A
         B (keep=cac_addr_zip2 cac_addr_zip)
         C ;
       set cac_addr_zip2_x;
       if upcase(substr(cac_addr_zip2,6,2)) = 'XX' then output C;
       else if sel_hh_count <= 5 then output B;
       else output A;
    run;

    ************************************************************************;
    * FOR RECORDS WITH LESS THAN 6 HH, RENAME AS Z2_SEL AND Z2_MAS_HH_COUNT
    * AND RECREATE ZIP2 AS ZIP WITH XX AFTER
    ************************************************************************;

    data B;
      set B;
      cac_addr_zip2=cac_addr_zip||"XX";
    run;

    proc sort data=B;
       by cac_addr_zip2;
    run;

    proc sort data=C;
       by cac_addr_zip2;
    run;

    **************************************************;
    * MERGE B AND C TOGETHER TO GET D BY cac_addr_zip2
    **************************************************;
 
    data D;
      merge B (in=a) 
            C;
      by cac_addr_zip2;
      keep cac_addr_zip2 cac_addr_zip;
    run;

    ***********************************************************;
    * GET FRACTION OF HOUSEHOLDS WITH THAT INTEREST WITHIN ZIP2
    ***********************************************************;

    data A;
      set A;
      array all_int geo_cac_int_1-geo_cac_int_121;
      do over all_int;
         if all_int = . then all_int = 0;
         all_int = all_int / sel_hh_count;
      end;
    run;

    *********************************;
    * ROLL UP ZIP2 LEVEL TO ZIP LEVEL
    *********************************;

    proc sort data=A;
      by cac_addr_zip cac_addr_zip2;
    run;

    data zip_level (keep=cac_addr_zip cac_addr_state geo_prop: total_count);
      set A;
      by cac_addr_zip cac_addr_zip2;
            %do int = 1 %to 121;
               geo_prop_int_&int=geo_cac_int_&int.*mas_count;
            %end;
      if first.cac_addr_zip then do;
         total_count=0;
            %do int = 1 %to 121;
               total_prop_&int=0;
            %end;
      end;
         total_count+mas_count;
         %do int=1 %to 121;
            total_prop_&int+geo_prop_int_&int;
         %end;
      if last.cac_addr_zip then do;
         %do int=1 %to 121;
            geo_prop_int_&int=total_prop_&int/total_count;
         %end;
         output;
      end;
    run;

    **********************************;
    * ROLL UP ZIP LEVEL TO STATE LEVEL;
    **********************************;
   
    proc sort data=zip_level;
      by cac_addr_state cac_addr_zip;
    run;
   
    data st_level;
      set zip_level;
      cac_addr_zip2='XXXXXXX';
      by cac_addr_state cac_addr_zip;
         %do int = 1 %to 121;
             geo_cac_int_&int=geo_prop_int_&int.*total_count;
         %end;
      if first.cac_addr_state then do;
          new_total_count=0;
             %do int = 1 %to 121;
                total_prop_&int=0;
             %end;
      end;
         new_total_count+total_count;
         %do int=1 %to 121;
             total_prop_&int+geo_cac_int_&int;
         %end;
      if last.cac_addr_state then do;
          %do int=1 %to 121;
             geo_cac_int_&int=total_prop_&int/new_total_count;
          %end;
          output;
      end;
    run;
   
    *************************************;
    * GET ZIP FRACTIONS ON ZIP LEVEL DATA;
    *************************************;

    proc sort data=D nodupkey;
       by cac_addr_zip;
    run;
 
    data D;
       merge zip_level (in=a)
             D (in=b);
       by cac_addr_zip;
       cac_addr_zip2=cac_addr_zip||"XX";
          %do intnum=1 %to 121;
             geo_cac_int_&intnum=geo_prop_int_&intnum;
          %end;
       drop GEO_PROP:;
    run;
 
    proc sort data=A;
       by cac_addr_zip2;
    run;
 
    data geo.geo_interest_&cstate;
       set st_level
           D
           A;
       by cac_addr_zip2;
       drop sel_hh_count mas_count geo_prop_int: new_total_count total_:; /** APPLY LABELS TO GEO ZIP TABLE **/ %geo_label_it;
    run;

    ***********;
    * STEP 7 QC;
    ***********;
 
    %nobs(data=geo.geo_interest_&cstate);
    %global geo_interests_obs;
    %let geo_interests_obs=&nobs;
  
    %mend geo_int;
    %geo_int;
   
      **********************************************************************************;
      * STEP 11 BUILD PERMANENT BASE DEMO DATASET CREATE SILHOUETTES AND SILH LIFEDRIVER;
      **********************************************************************************;
      
      data base.base_demo_&cstate (drop=cac_hh_pid_ind change_state
                                       current_cac_qtr current_cac_year delete_flag  
                                       eps_hh_pid cac_full_name);
        set process.base_demo_&cstate. 
            
           
           ;
           
           * Convert values of inferred home ownership;
             if cac_h_ind_home_own='H' then cac_home_own=0;
           
           * v3.1 Presence of Adult Recode;
            if cac_demo_age_enh=1 and cac_demo_adult_18_24_enh in (.,0) then cac_demo_adult_18_24_enh=4;
	      else if cac_demo_age_enh=2 and cac_demo_adult_25_34_enh in (.,0) then cac_demo_adult_25_34_enh=4;
	      else if cac_demo_age_enh=3 and cac_demo_adult_35_44_enh in (.,0) then cac_demo_adult_35_44_enh=4;
	      else if cac_demo_age_enh=4 and cac_demo_adult_45_54_enh in (.,0) then cac_demo_adult_45_54_enh=4;
	      else if cac_demo_age_enh=5 and cac_demo_adult_55_64_enh in (.,0) then cac_demo_adult_55_64_enh=4;
	      else if cac_demo_age_enh=6 and cac_demo_adult_65_74_enh in (.,0) then cac_demo_adult_65_74_enh=4;
              else if cac_demo_age_enh=7 and cac_demo_adult_75_plus_enh in (.,0) then cac_demo_adult_75_plus_enh=4;

        *ADD NUMERIC SQ FOOTAGE*;
      format CAC_HOME_SQ_FOOT_NUM 7.1;
      if CAC_HOME_SQ_FOOT not in ('' 'Z') then do;
         if CAC_HOME_SQ_FOOT='A' then CAC_HOME_SQ_FOOT_NUM=375; 
         else if CAC_HOME_SQ_FOOT='B' then CAC_HOME_SQ_FOOT_NUM=874.5;
         else if CAC_HOME_SQ_FOOT='C' then CAC_HOME_SQ_FOOT_NUM=1124.5;
         else if CAC_HOME_SQ_FOOT='D' then CAC_HOME_SQ_FOOT_NUM=1374.5;
         else if CAC_HOME_SQ_FOOT='E' then CAC_HOME_SQ_FOOT_NUM=1624.5;
         else if CAC_HOME_SQ_FOOT='F' then CAC_HOME_SQ_FOOT_NUM=1874.5;
         else if CAC_HOME_SQ_FOOT='G' then CAC_HOME_SQ_FOOT_NUM=2249.5;
         else if CAC_HOME_SQ_FOOT='H' then CAC_HOME_SQ_FOOT_NUM=2749.5;
         else if CAC_HOME_SQ_FOOT='I' then CAC_HOME_SQ_FOOT_NUM=3249.5;
         else if CAC_HOME_SQ_FOOT='J' then CAC_HOME_SQ_FOOT_NUM=3749.5;
         else if CAC_HOME_SQ_FOOT='K' then CAC_HOME_SQ_FOOT_NUM=4499.5;
         else if CAC_HOME_SQ_FOOT='L' then CAC_HOME_SQ_FOOT_NUM=5499.5;
         else if CAC_HOME_SQ_FOOT='M' then CAC_HOME_SQ_FOOT_NUM=6499.5;
         else if CAC_HOME_SQ_FOOT='N' then CAC_HOME_SQ_FOOT_NUM=7000;
         else CAC_HOME_SQ_FOOT=.;
      end;
      else CAC_HOME_SQ_FOOT_NUM=.;
      
    run;

    * v3.1 Sort Base Demo by CAC_HH_PID;
    proc sort data=base.base_demo_&cstate;
      by cac_hh_pid;
    run;
    
    ************;
    * STEP 11 QC;
    ************;
    
     * JOB HISTORY SUMMARY HERE;
     * COMPLETE FOR STATE, EMAIL, AND APPEND TO PERMANENT JOB HISTORY;
    
     %nobs(data=process.bd_inserts_&cstate);
     %let insertobs=&nobs;
     %nobs(data=process.bd_updates_&cstate);
     %let updateobs=&nobs;  
     %nobs(data=process.bd_inactives_&cstate)        
     %let inactiveobs=&nobs; 
     %nobs(data=process.bd_deletes_&cstate);    
     %let delobs=&nobs; 
     %nobs(data=base.base_demo_&cstate);
     %let new_base_demo_obs=&nobs;   
     %nobs(data=indiv.indiv_demo_&cstate);
     %let indiv_demo_obs=&nobs; 
     %nobs(data=geo.geo_interest_&cstate);
     %let geo_interest_obs=&nobs;   
     %nobs(data=foret.etech_&cstate);
     %let new_etech_obs=&nobs;
   
     data _null_;
       end_time=put(time(), time.);
       call symput('end_time',end_time);
       end_date=put(date(), date.);
       call symput('end_date',end_date);
      end_dt=put(datetime(),datetime.);
     run; 
  
     data temp;
       state="&cstate";
       cac_year=&year;
       cac_qtr=&qtr;
       base_demo_records=&new_base_demo_obs;
       indiv_demo_records=&indiv_demo_obs;
       geo_interest_records=&geo_interest_obs;
       insert_records=&insertobs;
       update_records=&updateobs;
       inactive_records=&inactiveobs;
       deleted_records=&delobs;
       job_start_date="&start_date";
       job_start_time="&start_time";
       job_end_date="&end_date";
       job_end_time="&end_time";
     run;
          
     data cac_direct_counts_&cstate._&year._&qtr;
       update cac_direct_counts_&cstate._&year._&qtr temp;
       by state cac_year cac_qtr;
     run;   
          
     proc datasets lib=work;
        delete temp;
        quit;
     run; 
   
     data jhis.cac_direct_counts_&cstate;
         update jhis.cac_direct_counts_&cstate cac_direct_counts_&cstate._&year._&qtr;
          by state cac_year cac_qtr;
     run;
     
     proc transpose data=jhis.cac_direct_counts_&cstate out=wide prefix=Raw_Record_Count_Qtr;
       where state="&cstate" and cac_year=&year;
       by state;
       id cac_qtr;
       var raw_file_record_count base_demo_records indiv_demo_records geo_interest_records insert_records update_records 
           inactive_records deleted_records job_start_date job_start_time job_end_date job_end_time;
     run;

     data wide;
       set wide (rename=_name_= DATA_SET);
     run;

    ods html body="./cacdirect_update_&cstate._&year._&qtr..htm";
      title1 "Summary Report for Update of &CSTATE &YEAR Quarter &QTR";
       
      proc print data=wide noobs;
      run;

      proc freq data=base.base_demo_&cstate;
        tables cac_prod_active_flag
               cac_prod_active_flag*cac_active_flag*cac_production 
               CAC_HOME_OWN*CAC_H_IND_HOME_OWN
	       cac_addr_cdi 
               cac_demo_income_enh
               cac_demo_marital_status 
               cac_demo_hh_type_enh / list missing;
	format cac_prod_active_flag prod_act. 
	       cac_active_flag cac_act. 
	       cac_production cac_prod.
	       cac_demo_age_enh cac_age.
	       cac_demo_income_enh $cac_inc.
	       cac_demo_kids_enh cac_kids.
               cac_demo_marital_status cac_mar.;
       run;
       
       proc means data=base.base_demo_&cstate n nmiss mean min max;
           varn cac_home_valuation_enh cac_demo_income_index_enh;
       run;
    ods html close;  
      
    filename mail1 email to=("&email") 
                             subject="STEP 11 QC BUILD PERMANENT BASE DEMO DATASET CREATE SILHOUETTES AND SILH LIFEDRIVER &CSTATE" 
                             from="webmaster@cac-group.com"
                             attach="./cacdirect_update_&cstate._&year._&qtr..htm";
        
    data _null_;
      file mail1;
      put "Update for &cstate &year quarter &qtr completed.";
      put "The job was initiated on &start_date at &start_time and completed on &end_date at &end_time ";
    run;

    proc print data=base.base_demo_&cstate (obs=10);
       var cac_census_2010: cac_addr_latitude cac_addr_longitude;
    run;
    
      title2 "FINAL PROC CONTENTS &cstate";
      proc contents data=base.base_demo_&cstate varnum;
      proc contents data=foret.etech_&cstate varnum;
      proc contents data=indiv.indiv_demo_&cstate varnum;
      proc contents data=geo.geo_interest_&cstate varnum;
      
   **********************************;
   * CLEAN UP REMAINING TEMP DATASETS;
   **********************************;
           proc datasets lib=work;
             delete old_base_demo_&cstate;
             delete a;
             delete b;
             delete c;
             delete d;
             delete p1_base_demo_&cstate;
             delete select_cac_addr_zip;
             delete st_level;
             delete temp;
             delete zip2;
             delete zx2;
           run;
           quit;
           
           proc datasets lib=process;
             delete bd_inserts_&cstate;
             delete bd_updates_&cstate;
	     delete bd_deletes_&cstate;
             delete bd_inactives_&cstate;
             delete raw_&cstate;
             delete base_demo_&cstate;
             delete raw_&cstate._dups_&year._&qtr;
             delete for_parsimony_&cstate;
             delete bad_state_or_zip_&cstate;
           run;
           quit;

  %end; **** END OF DO IF ABORT=0 WHEN BASE DEMO OK;
 %end; **** END OF DO IF ABORT=0 IF RAW FILE RECORD IS OK;

%mend update_db;

