*========================================================================================;
* Program 060_append_etech.sas
  Purpose Read in data returned from Etech and Append to Existing Etech Tables
  Authors Mike Mattingly, Lisa Fales, Patty Seeburger
  Design  Split Raw File from Etech into States
  	  Ensure Unique at CAC_HH_PID level
  	  Append to exiting CAC Direct Etech Dataset
  	  Email Frequency of key variables
*========================================================================================;
options mprint linesize=max;
%let testobs=max;

%macro readin(qtr=,year=,email=,cacdir_loc=B,codepath=PROD);

    %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc";

    %if &cacdir_loc=A %then %do;                                              
        libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/A";
        libname curet    "/project/CACDIRECT/&cidatapath./ETECH/B";
        libname et       "/project/CACDIRECT/&cidatapath./ETECH/A";
    %end;
    
    %else %if &cacdir_loc=B %then %do;                               
           libname base  "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";
           libname curet "/project/CACDIRECT/&cidatapath./ETECH/A";
           libname et    "/project/CACDIRECT/&cidatapath./ETECH/B";
    %end;

%let sts = AK AL AR AZ CA CO CT DE FL GA
           HI IA ID IL IN KS KY LA MA MD
           ME MI MN MO MS MT NC ND NE NH
           NJ NM NV NY OH OK OR PA RI SC
           SD TN TX UT VA VT WA WI WV WY
           DC;

data et.misfits  %do st=1 %to 51; 
                   etech_%scan(&sts,&st)_&year._&qtr
                 %end;;
   infile "/project/CACDIRECT/&cidatapath./ETECH/FROMETECH/etech_Combine_CAC_Encoded.csv" dsd missover obs=&testobs;
   length 
          ETECH_ETHNIC_CODE            $2 
          ETECH_RELIGION_CODE          $1 
          ETECH_LANGUAGE_CODE          $2 
          ETECH_GROUP_CODE             $1 
          ETECH_COUNTRY_OF_ORIGIN_CODE $2 
          ETECH_ASSIMILATION           $1 
          ETECH_GENDER_CODE            $1
          CAC_HH_PID                   $27
          orig_data_2_Last_name        $5
          orig_data_3_First_name       $5
          orig_data_4_mid_init         $1
          orig_data_5_zip              $5
          orig_data_6_zip_ext          $4
          ETECH_STATE                  $2.;
   input  CAC_HH_PID                   $
          orig_data_2_Last_name        $
          orig_data_3_First_name       $
          orig_data_4_mid_init         $
          orig_data_5_zip              $
          orig_data_6_zip_ext          $
          ETECH_STATE                  $ 
          ETECH_ETHNIC_CODE            $
          ETECH_RELIGION_CODE          $
          ETECH_LANGUAGE_CODE          $
          ETECH_GROUP_CODE             $
          ETECH_COUNTRY_OF_ORIGIN_CODE $
          ETECH_ASSIMILATION           $
          ETECH_GENDER_CODE            $
          dum                          $;
          
   drop orig_data_2_last_name orig_data_3_first_name orig_data_4_mid_init orig_data_5_zip orig_data_6_zip_ext dum;
   
   %do st=1 %to 51;
      if ETECH_STATE = "%scan(&sts,&st)" then do;
         label 
              ETECH_STATE = "State Abbreviation - CAC Group Provided"
              ETECH_ASSIMILATION = "Assimilation Flag"
              ETECH_COUNTRY_OF_ORIGIN_CODE = "Country of Origin"
              ETECH_ETHNIC_CODE = "Ethnicity"
              ETECH_GENDER_CODE = "Gender"
              ETECH_GROUP_CODE = "Group Code"
              ETECH_LANGUAGE_CODE = "Language"
              ETECH_RELIGION_CODE = "Religion";         
         output etech_%scan(&sts,&st)_&year._&qtr;
      end;
   %end;

  if ETECH_STATE not in (%do st=1 %to 51; "%scan(&sts,&st)" %end;) then output et.misfits;
run;

  * APPEND NEW ETECH RECORDS TO EXISTING ETECH TABLES;
  %do st=1 %to 51;

     %let cstate=%scan(&sts,&st);

      proc printto   log="./append_etech_&year._&qtr._&st..log" new;
      proc printto print="./append_etech_&year._&qtr._&st..lst" new;
      run;

     * REMOVE ANY DUPLICATES FROM FILE FROM ETECH;
     proc sort data=etech_%scan(&sts,&st)_&year._&qtr nodupkey;
       by cac_hh_pid;
     run;

     * APPEND DATA FROM ETECH TO EXISTING ETECH TABLE;
     %let etech_appends=0;
     %let etech_obs=0;
     %nobs(data=etech_%scan(&sts,&st)_&year._&qtr);
     %let etech_appends=&nobs; 

     data etech_%scan(&sts,&st);
       set curet.etech_%scan(&sts,&st) (obs=&testobs)
           etech_%scan(&sts,&st)_&year._&qtr;
           ETECH_ID=_n_;
           label ETECH_ID = "E-Tech ID - CAC Group Created on Import";
     run;
   
     %let etech_obs=0;
     %nobs(data=etech_%scan(&sts,&st));
     %let etech_obs=&nobs;
   
     %if &etech_obs > 0 %then %do;

         proc sort data=etech_%scan(&sts,&st) nodupkey out=etech_%scan(&sts,&st);
           by cac_hh_pid;
         run;

         proc sort data=base.base_demo_%scan(&sts,&st) out=base_%scan(&sts,&st) (keep=cac_hh_pid);
          by cac_hh_pid;
         run;

         data et.etech_%scan(&sts,&st);
           merge etech_%scan(&sts,&st) (in=a)
                 base_%scan(&sts,&st) (in=b);
           by cac_hh_pid;
           if a and b;
         run;

         proc sort data=et.etech_%scan(&sts,&st);
           by cac_hh_pid;
         run;

         title1 "&cstate FREQUENCY OF ETECH";
         proc freq data=et.etech_%scan(&sts,&st);
          title 'FREQS BY STATE';
          format etech_ethnic_code $etethnic. etech_religion_code $etrelig. etech_language_code $etlang. etech_country_of_origin_code $ethisporg. 
          etech_assimilation $ethispasm. etech_gender_code $etgender.;
           tables etech_state etech_state*(ETECH_ETHNIC_CODE ETECH_RELIGION_CODE ETECH_LANGUAGE_CODE ETECH_GROUP_CODE 
                  ETECH_COUNTRY_OF_ORIGIN_CODE ETECH_ASSIMILATION ETECH_GENDER_CODE) /list missing;
         run;

         proc datasets lib=work;
          delete etech_%scan(&sts,&st);
          delete base_%scan(&sts,&st);
         run;
         quit;

     %end;

     %if &etech_obs = 0 %then %do;
          filename mail80 email to=("&email") 
	                           subject="Error Message from CAC DIRECT ETECH APPEND FOR &cstate"
	                           from="webmaster@cac-group.com";
	    data _null_;
	      file mail80;
	      put "0 Observations when attempted to append new data from Etech to existing Etech table.                   ";
              put "Please Check Log.  Etech &cstate  not updated.                                                         ";
            run;
     %end;

      proc printto log=log print=print;
      run;

  %end;
%mend;
