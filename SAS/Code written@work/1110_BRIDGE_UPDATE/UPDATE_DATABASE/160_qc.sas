

%let st_lst =AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY;
%let st_lst_len= %sysfunc(countw(&st_lst));



%macro qc_em_coverage(email=, year=, quarter=, cac_read_dir_loc=, codepath=);
   
   /*  DIRECTING FOLDERS  */  

   %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc";
   
   %if &cac_read_dir_loc=A %then %do; *** IF CURRENT PRODUCTION DATA IS IN A THEN WRITE DATA FOR NEW QUARTER TO B;
        libname _ALL_;
        libname cur_base "/project/CACDIRECT/&cidatapath./BASE_DEMO/A";
        libname base "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";
   %end;
   

   %else %if &cac_read_dir_loc=B %then %do; *** IF CURRENT PRODUCTION DATA IS IN B THEN WRITE DATA FOR NEW QUARTER TO A;
        libname _ALL_;
        libname cur_base "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";
        libname base "/project/CACDIRECT/&cidatapath./BASE_DEMO/A";
   %end;

   /*  GATHERING STATS ON OBS FOR 51 STATES*/

   %do i=1 %to &st_lst_len;

      %let cstate = %lowcase(%qscan(&st_lst,&i)); 

      proc sql;
         create table by_silh_state_&i as
         select count(*) as NOBS, CAC_SILH_SUPER, CAC_EM_FLAG, "&cstate." as STATE
         from base.base_demo_&cstate.
         group by CAC_SILH_SUPER, CAC_EM_FLAG;
      quit;

   %end;
   
   /* STACK UP STATS  */   

   data by_silh_state;
      set 
      %do i=1 %to &st_lst_len;
         by_silh_state_&i 
      %end;
      ;
   run;

   /* PRODUCING REPORT TABLES  */

   proc sql;

      create table by_state as 
      select state, sum(nobs) as nobs, cac_em_flag 
      from by_silh_state
      group by state,  cac_em_flag;
   
      create table by_silh as 
      select cac_silh_super, sum(nobs) as nobs, cac_em_flag 
      from by_silh_state
      group by cac_silh_super, cac_em_flag;

   quit;

   data by_state_report(drop=nobs cac_em_flag V12_EM_ONLY BRIDGE_EM_ONLY NO_EM BOTH);
      set by_state;
         by STATE;
      retain TOTAL_OBS BRIDGE_EM_ONLY V12_EM_ONLY NO_EM BOTH;
      format COVERAGE percent10.1 
             V12_ONLY_COVERAGE percent10.1
             BRIDGE_ONLY_COVERAGE percent10.1
             V12_BRIDGE_BOTH_COVERAGE percent10.1      
             ;
      
      if first.state = 1 then 
         do;
            TOTAL_OBS =0;
            BRIDGE_EM_ONLY=0;
            V12_EM_ONLY =0;
            BOTH=0;
            NO_EM =0;
         end;
   
      if cac_em_flag = '10' then BRIDGE_EM_ONLY+nobs;
      if cac_em_flag = '01' then V12_EM_ONLY+nobs;
      if cac_em_flag = '00' then NO_EM+nobs;
      if cac_em_flag = '11' then BOTH+nobs;

      STATE = upcase(STATE);
      TOTAL_OBS+nobs;
      COVERAGE = ((TOTAL_OBS-NO_EM)/TOTAL_OBS);
      V12_ONLY_COVERAGE = V12_EM_ONLY/TOTAL_OBS;
      BRIDGE_ONLY_COVERAGE = BRIDGE_EM_ONLY/TOTAL_OBS;
      V12_BRIDGE_BOTH_COVERAGE = BOTH/TOTAL_OBS;

      if last.state =1 then output;
   run;
   
   data by_silh_report(drop=nobs cac_em_flag V12_EM_ONLY BRIDGE_EM_ONLY NO_EM BOTH);
      set by_silh;
      by CAC_SILH_SUPER;
      retain TOTAL_OBS NO_EM BOTH BRIDGE_EM_ONLY V12_EM_ONLY;

      format 
             CAC_SILH_SUPER_DECODE $30.
             COVERAGE percent10.1
             BRIDGE_ONLY_COVERAGE percent10.1
             V12_ONLY_COVERAGE percent10.1
             V12_BRIDGE_BOTH_COVERAGE percent10.1
             ;

      if first.cac_silh_super = 1 then 

         do;
            TOTAL_OBS =0;
            BRIDGE_EM_ONLY=0;
            V12_EM_ONLY =0;
            BOTH=0;
            NO_EM =0;
         end;
   
      if cac_em_flag = '10' then BRIDGE_EM_ONLY+nobs;
      if cac_em_flag = '01' then V12_EM_ONLY+nobs;
      if cac_em_flag = '00' then NO_EM+nobs;
      if cac_em_flag = '11' then BOTH+nobs;

      CAC_SILH_SUPER = upcase(CAC_SILH_SUPER);
      CAC_SILH_SUPER_DECODE = put(CAC_SILH_SUPER, silh_super.); 
      TOTAL_OBS+nobs;
      COVERAGE = ((TOTAL_OBS-NO_EM)/TOTAL_OBS);
      V12_ONLY_COVERAGE = (V12_EM_ONLY)/TOTAL_OBS;
      BRIDGE_ONLY_COVERAGE = (BRIDGE_EM_ONLY)/TOTAL_OBS;
      V12_BRIDGE_BOTH_COVERAGE = BOTH/TOTAL_OBS;

      if last.cac_silh_super =1 then output;
   run;  
   
   data by_silh_report;
   retain CAC_SILH_SUPER CAC_SILH_SUPER_DECODE;
   set by_silh_report;
   run;
      

   /* OUTPUT HTML REPORT */


   ODS html body ='./email_coverage_qc.html';
   
      title 'EMAIL COVERAGE RATE OF BASE_DEMO BY STATE';
      proc print data= by_state_report;run;
      title 'EMAIL COVERAGE RATE OF BASE_DEMO BY CAC_SILH_SUPER';
      proc print data= by_silh_report;run;
   
   ODS html close;

   /*   SENDING EMAILS TO EMAIL RECEIPTS   */

   filename sendmail email to=("&email") subject="QC of APPENDING EMAILS TO INTELLIBASE" from="webmaster@cogensia.com" attach="./email_coverage_qc.html";

   data _null_;
      file sendmail;
      put "           QC of EMAIL COVERAGE RATE ON INTELLIBASE ON &year. QUARTER &quarter.            ";
   run; 

%mend qc_em_coverage;

