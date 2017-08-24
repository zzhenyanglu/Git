%macro lifesaver(client_dir=, client_data=, client_id=, state_var=, zip5=, zip4=, state_list=, base=1, ethnic=1, geo_interest=1, census=1, census_keep=,  email=jschiltz@cac-group.com);
*==============================================================================================*;
*  Macro:  	lifesaver 
   Purpose: 	Process file previously matched to cacdirect to add fields the user forgot to grab
   Created:	5/25/2012
   Author:	Joel Schiltz
   Sections:	1) MATCHING PREP
                2) CLEAN DATA
                    --Input data: &clib..&client_data
                    --Output data: oops
                8) ADD GEO INTERESTS (IF SELECTED)  
                9) ADD CENSUS DATA (IF SELECTED)  
               10) ADD ETHNIC DATA (IF SELECTED)  
               12) STACK STATE RESULTS INTO FULL SAMPLE
               13) FINAL OUTPUT
*==============================================================================================*;

*-----------------------------------------*;
* 1) MATCHING PREP        
*-----------------------------------------*;
data _null_;
   start_dt=put(datetime(), datetime.);
   call symput('start_dt',start_dt);
   start_time=put(time(), time.);
   call symput('start_time',start_time);
   start_date=put(date(), date.);
   call symput('start_date',start_date);
run;

%if %cmpres(&state_list)=  %then %do;
     %let state_list='AK' 'AL' 'AR' 'AZ' 'CA' 'CO' 'CT' 'DE' 'FL' 'GA'
                     'HI' 'IA' 'ID' 'IL' 'IN' 'KS' 'KY' 'LA' 'MA' 'MD'
                     'ME' 'MI' 'MN' 'MO' 'MS' 'MT' 'NC' 'ND' 'NE' 'NH'
                     'NJ' 'NM' 'NV' 'NY' 'OH' 'OK' 'OR' 'PA' 'RI' 'SC'
                     'SD' 'TN' 'TX' 'UT' 'VA' 'VT' 'WA' 'WI' 'WV' 'WY'
                     'DC';
   %let states_for_match=AK AL AR AZ CA CO CT DE FL GA
                         HI IA ID IL IN KS KY LA MA MD
                         ME MI MN MO MS MT NC ND NE NH
                         NJ NM NV NY OH OK OR PA RI SC
                         SD TN TX UT VA VT WA WI WV WY
                         DC;
%end;
%else %do;
   data _null_;
      format var $500.;
      var="&state_list";
      var=compress(var,"'");
      call symput('states_for_match',var);
   run;
%end;
%let full_states='AK' 'AL' 'AR' 'AZ' 'CA' 'CO' 'CT' 'DE' 'FL' 'GA'
                 'HI' 'IA' 'ID' 'IL' 'IN' 'KS' 'KY' 'LA' 'MA' 'MD'
                 'ME' 'MI' 'MN' 'MO' 'MS' 'MT' 'NC' 'ND' 'NE' 'NH'
                 'NJ' 'NM' 'NV' 'NY' 'OH' 'OK' 'OR' 'PA' 'RI' 'SC'
                 'SD' 'TN' 'TX' 'UT' 'VA' 'VT' 'WA' 'WI' 'WV' 'WY'
                 'DC';

%let state_count = 0;
%do %while(%qscan(&states_for_match, &state_count+1, %str( )) ne %str());
   %let state_count = %eval(&state_count+1);
%end;

%let namelen=0;
libname clin "&client_dir";
data _null_;
   format lib $1000.;
   lib="&client_dir";
   if length(compress(lib))>1 then do;
      call symput('clib','clin');
   end;
   else do;
      call symput('clib','work');
   end;
   namelen=length("&client_data");
   if namelen>26 then do;
      call symput('namelen','1');
   end;
run;

%if &namelen=1 %then %goto toolong;

%if &clib=work %then %do;
   filename sendmail email to=("&email")
                     subject="CACdirect Lifesaver Results - Potential Warning" 
                     from="webmaster@cac-group.com" 
                     ;

   data _null_;
      file sendmail;
      put "Don't worry, you CACdirect lifesaver job is still processing";
      put ;
      put "However, we did notice that you are processing from the WORK directory.";
      put ;
      put "This means that your matched file will not be written to a permanent location and you could lose hours of processing";
      put ;
      put "If this was intentional, I hope the subsequent code in this job makes a copy.  If not, you may want to kill your job and specify a permanent folder structure";
      put ;
      put "Good Work!";
      put ;
      put "Sincerely,";
      put "Your CACdirect Team";
   run;

%end;

/*
%nobs(data=&clib..&client_data);
%let full=&nobs;
*/

*-----------------------------------------*;
* 1) PREP DATA
     prep for matching 
     set aside known bad
* 4) SPLIT INTO STATES
*-----------------------------------------*;

   data %do state_num=1 %to &state_count; oops_%scan(&states_for_match, &state_num) %end;;
      set &clib..&client_data (keep=&client_id  cac_hh_pid &zip5 &zip4 &state_var %if &base=0 %then %do; cac_addr_zip cac_addr_zip4 cac_addr_state cacdirect_hh_match %end; ) end=eof;
      *--------------  MOVED HERE FROM ABOVE DATASTEP ON 10/1/2012 by Mike Mattingly ---------------*;
      ***___FOR GEO / CENSUS MATCHING___***; 
      format match_zip5 $5. match_zip4 $4. match_zip2 $7. match_state $2.;
      %if &base=0 %then %do;
         if cac_hh_pid^='' then do;
            match_state=cac_addr_state;
            ***___assign cacdir zip5 when matched___***;
            match_zip5=cac_addr_zip;
            ***___assign cacdir zip4 when matched and zip4 not missing___***;
            if cac_addr_zip4 ne '' then do;
                  match_zip4=compress(cac_addr_zip4);
                  match_zip2=compress(cac_addr_zip||substr(cac_addr_zip4,1,2));
            end;
            else if cac_addr_zip4='' then do;
               ***___if client zip4 is populated then assign that___***;
               %if &zip4 ne %str() %then %do; 
                     match_zip4=&zip4;
                     match_zip2=compress(match_zip5||substr(&zip4,1,2));
                     if match_zip4='' then match_zip2=compress(match_zip5||'XX');
               %end;
               ***___if client zip4 is not populated then make zip2 end in xx___***;
               %if &zip4 eq %str() %then %do;
                     match_zip2=compress(match_zip5||'XX');
               %end;
            end;
         end;
         else do;
            ***___assign client zip5 and client zip2 where available___***;
            match_state=&state_var;
            match_zip5=&zip5;
            match_zip2=compress(match_zip5||'XX');
            %if &zip4 ne %str() %then %do; 
               match_zip4=&zip4;
               match_zip2=compress(match_zip5 || substr(&zip4,1,2));
               if match_zip4='' then match_zip2=compress(match_zip5||'XX');
            %end;
         end;
      %end;
      %if &base=1 %then %do;
         cacdirect_hh_match=1;
         ***___assign client zip5 and client zip2 where available___***;
         match_state=&state_var;
         match_zip5=&zip5;
         match_zip2=compress(match_zip5||'XX');
         %if &zip4 ne %str() %then %do; 
            match_zip4=&zip4;
            match_zip2=compress(match_zip5 || substr(&zip4,1,2));
            if match_zip4='' then match_zip2=compress(match_zip5||'XX');
         %end;
      %end;
      *----------- END MOVE ---------------*;
      if match_state="%scan(&states_for_match, 1)" then output oops_%scan(&states_for_match, 1);
      %if &state_count>1 %then %do;
         %do state_num=2 %to &state_count;
            else if match_state="%scan(&states_for_match, &state_num)" then output oops_%scan(&states_for_match, &state_num);
         %end;
      %end;
   run;

*---------START OF MASTER STATE LOOP-------------------*;
%do state_num=1 %to &state_count;
   %let curstate=%scan(&states_for_match, &state_num);
*------------------------------------------------------*;
********************************************************;
   %nobs(data=oops_&curstate);
   %if &nobs>0 %then %do;

      proc sort data=oops_&curstate;
         by &client_id;
      run;

*-----------------------------------------*;
* 8) ADD BASE DEMOS    (IF SELECTED)  
*-----------------------------------------*;
      %if &base=1 %then %do;

         proc sort data=oops_&curstate (keep=cac_hh_pid &client_id) nodupkey out=uniq_&curstate;
            by cac_hh_pid &client_id;
         run; 

         data base_&curstate;
            merge uniq_&curstate (in=a)
                  base.base_demo_&curstate (in=b);
            by cac_hh_pid;
            if a;
         run;
 
         proc sort data=base_&curstate;
            by &client_id;
         run;

      %end;                *<----------------------- END OF BASE=1 LOOP*;

*-----------------------------------------*;
* 8) ADD GEO INTERESTS (IF SELECTED)  
*-----------------------------------------*;
      %if &geo_interest=1 %then %do;

         proc sort data=oops_&curstate (keep=&client_id match_zip5 match_zip2 rename=(match_zip5=cac_addr_zip match_zip2=cac_addr_zip2)) out=client_z2_&curstate ;
            by cac_addr_zip2;
         run;
         
         proc sort data=geo.geo_interest_&curstate;
            by cac_addr_zip2;
         run;
     
         data client_z2_found_&curstate (drop=newzip) zip_&curstate (rename=(cac_addr_zip2=hold));
            format cac_addr_zip2 $7.;
            merge client_z2_&curstate (in=a)
                  geo.geo_interest_&curstate (in=b drop=cac_addr_state cac_addr_zip);
            by cac_addr_zip2;
            cac_geo_match=1;
            if substr(cac_addr_zip2,6,2)='XX' then cac_geo_match=2;
            if a and b and geo_cac_int_1^=. then output client_z2_found_&curstate;
            else if a then do;
               cac_geo_match=0;
               format newzip $7.;
               newzip=strip(compress(cac_addr_zip || 'XX'));
               output zip_&curstate;
            end;
         run;
     
         proc sort data=zip_&curstate;
             by newzip;
         run;
     
         data client_zip_found_&curstate (drop=cac_addr_zip2 newzip rename=(hold=cac_addr_zip2)) state_&curstate (drop=cac_addr_zip2);
            format cac_addr_zip2 $7.;
            merge zip_&curstate (in=a rename=(newzip=cac_addr_zip2))
                  geo.geo_interest_&curstate (in=b drop=cac_addr_state cac_addr_zip);
            by cac_addr_zip2;
            cac_geo_match=2;
            if a and b and geo_cac_int_1^=. then output client_zip_found_&curstate;
            else if a then do;
               cac_geo_match=0;
               newzip='XXXXXXX';
               output state_&curstate;
            end;
         run;
     
         data client_state_found_&curstate (drop=cac_addr_zip2 rename=(hold=cac_addr_zip2));
            merge state_&curstate (in=a rename=(newzip=cac_addr_zip2))
                  geo.geo_interest_&curstate (in=b drop=cac_addr_state cac_addr_zip);
            by cac_addr_zip2;
            cac_geo_match=3;
            if a and b;
         run;
       
         data client_z2_final_&curstate;
            set client_z2_found_&curstate (keep=&client_id cac_geo_match geo_:) 
                client_zip_found_&curstate  (keep=&client_id cac_geo_match geo_:)
                client_state_found_&curstate (keep=&client_id cac_geo_match geo_:);
         run;
      
         proc sort data=client_z2_final_&curstate;
            by &client_id;
         run;
     
         data oops_&curstate(sortedby=&client_id);
            merge oops_&curstate (in=a)
                  client_z2_final_&curstate (in=b);
            by &client_id;
            if a and b;
         run;

         proc datasets library=work nolist;
            delete client_z2_final_&curstate client_z2_found_&curstate client_zip_found_&curstate client_state_found_&curstate client_z2_&curstate;
         quit;

      %end;                                      *------------------------------------ END OF GEO LEVEL INTEREST APPENED;
     
*-----------------------------------------*;
* 9) ADD CENSUS DATA (IF SELECTED)    
*-----------------------------------------*;
      %if &census=1 %then %do ;

         proc sort data=oops_&curstate;
            by match_zip5 match_zip4;
         run;

         data m_cen_zip9_&curstate nm_cen_zip9_&curstate;
            merge oops_&curstate (in=a)
                  cen2010.cac_census_xref_&curstate (in=b rename=(cac_addr_zip=match_zip5 cac_addr_zip4=match_zip4));
            by match_zip5 match_zip4;
            if a and b then do;
               cac_census_match=1;
               cac_census_match_level='ZIP9';
               output m_cen_zip9_&curstate; 
            end;

            else if a and not b then output nm_cen_zip9_&curstate;

         run;

         proc sort data=nm_cen_zip9_&curstate; 
            by match_zip5;
         run;

         data cen_xref_&curstate;
           set cen2010.cac_census_xref_&curstate (where=(cac_addr_zip4 eq ''));
         run;

         proc sort data=cen_xref_&curstate;
           by cac_addr_zip;
         run;

         data m_cen_zip5_&curstate nm_cen_zip_&curstate;
            merge nm_cen_zip9_&curstate (in=a drop=cac_census_id)
                  cen_xref_&curstate (in=b keep=cac_census_id cac_addr_zip rename=(cac_addr_zip=match_zip5));        
            by match_zip5;
            if a and b then do;
               cac_census_match=1;
               cac_census_match_level='ZIP5';
               output m_cen_zip5_&curstate;
            end;
    
            else if a and not b then do;
                 cac_census_match=0;
                 output nm_cen_zip_&curstate;
            end;

         run;

         data client_with_cen_id_&curstate;
           set m_cen_zip9_&curstate m_cen_zip5_&curstate;
         run;
  
         proc sort data=client_with_cen_id_&curstate;
           by cac_census_id;
         run;

         data oops_&curstate;
            merge client_with_cen_id_&curstate (in=a)
                  cen2010.cac_census_final_&curstate (in=b keep=cac_census_id cen_:);
            by cac_census_id;
            if a and b;
         run;

         data oops_&curstate;
            set oops_&curstate 
                nm_cen_zip_&curstate;
         run;
                     
         proc sort data=oops_&curstate;
            by &client_id;
         run;

         proc datasets lib=work nolist; 
            delete cen_xref_&curstate;
            delete m_cen_zip9_&curstate;
            delete nm_cen_zip9_&curstate;
            delete m_cen_zip5_&curstate;
            delete nm_cen_zip_&curstate;
            delete client_with_cen_id_&curstate;
            delete client_with_census_&curstate;
         quit;

      %end; 

*-----------------------------------------*;
* 10) ADD ETHNIC DATA (IF SELECTED)    
*-----------------------------------------*;
      %if &ethnic=1 %then %do ;
         proc sort data=oops_&curstate (keep=cac_hh_pid &client_id) out=for_etech_&curstate;
            by cac_hh_pid;
         run;

         proc sort data=et.etech_&curstate;
            by cac_hh_pid;
         run;

         data match_etech_&curstate;
            merge for_etech_&curstate (in=a)
                  et.etech_&curstate (in=b);
            by cac_hh_pid;
            cac_ethnic_match=0;
            if a and b then cac_ethnic_match=1;
            if a then output;
         run;

         proc sort data=match_etech_&curstate;
            by &client_id;
         run;
  
         data oops_&curstate(sortedby=&client_id);
            merge oops_&curstate (in=a)
                  match_etech_&curstate (in=b);
            by &client_id;
            if a and b;
         run; 

         proc datasets library=work nolist;
            delete match_etech_&curstate for_etech_&curstate;
         quit;

      %end;                                      *------------------------------------ END OF ETHNIC DATA APPENED;

*-----------------------------------------*;
* 12) STACK STATE RESULTS INTO FULL SAMPLE
*-----------------------------------------*;
      proc append base=oops_matched data=oops_&curstate force;
      run;
   
      proc datasets library=work nolist;
         delete oops_&curstate;
      quit;

   %end;                      *---------------------------- END OF STATE_NUM LOOP; 
%end;                      *-----------------------------END OF NOBS CONDITION;
   
*-----------------------------------------*;
* 13) OUTPUT FINAL FILE                   
*-----------------------------------------*;
proc sort data=oops_matched;
   by &client_id;
run;

proc sort data=&clib..&client_data out=client_in;
   by &client_id;
run;

data &clib..&client_data._saved;
  merge client_in (in=a)
        oops_matched (in=b drop=match_zip5 match_zip4 match_zip2 &zip5 &zip4 &state_var match_state cac_hh_pid %if &base=0 %then %do; cac_addr_zip cac_addr_zip4 cac_addr_state cacdirect_hh_match %end;)        
        %if &base=1 %then %do;
           base_&curstate (in=c)
        %end;
       ;
   by &client_id;
   if a AND b;
   %if &base=1 %then %do; 
      cac_base_match=c;
      label cac_base_match='CACdirect Match to Base Demo Data';
   %end; 
   %if &geo_interest=1 %then %do; 
      label cac_geo_match='CACdirect Match to Geo Interest Data'; 
   %end; 
   %if &census=1 %then %do; 
      label cac_census_match='CACdirect Match to Census Data';
   %end; 
   %if &ethnic=1 %then %do; 
      label cac_ethnic_match='CACdirect Match to Ethnicity Data';
   %end;
run;

proc contents data=&clib..&client_data._saved;

%nobs(data=_dump);

ods html body="./cacdirect_lifesaver_results_&client_data..html";

title 'Overall Match Rates to Selected Sources';
proc freq data=&clib..&client_data._saved;
   tables %if &geo_interest=1 %then %do; cac_geo_match %end; 
          %if &base=1 %then %do; cac_base_match %end; 
          %if &census=1 %then %do; cac_census_match %end; 
          %if &ethnic=1 %then %do; cac_ethnic_match %end; / list missing;
   format cac_active_flag cac_act. cac_production cac_prod.
          %if &geo_interest=1 %then %do; cac_geo_match geo_match. %end; 
          %if &census=1 %then %do; cac_census_match match. %end; 
          %if &ethnic=1 %then %do; cac_ethnic_match match. %end; ;
run;

title 'Match Rates for CACdirect Houseohld Matches to Selected Sources';
proc freq data=&clib..&client_data._saved;
   where cacdirect_hh_match=1;
   tables %if &geo_interest=1 %then %do; cac_geo_match %end; 
          %if &census=1 %then %do; cac_census_match %end; 
          %if &ethnic=1 %then %do; cac_ethnic_match %end; / list missing;
   format cac_active_flag cac_act. cac_production cac_prod.
          %if &geo_interest=1 %then %do; cac_geo_match geo_match. %end; 
          %if &census=1 %then %do; cac_census_match match. %end; 
          %if &ethnic=1 %then %do; cac_ethnic_match match. %end; ;
run;

title 'Contents of Matched Data';
proc contents data=&clib..&client_data._saved;
run;

ods html close;

data _null_;
   end_time=put(time(), time.);
   call symput('end_time',end_time);
   end_date=put(date(), date.);
   call symput('end_date',end_date);
   end_dt=put(datetime(),datetime.);
run;

filename sendmail email to=("&email")
                  subject="CACdirect Lifesaver Results - &client_data" 
                  from="webmaster@cac-group.com" 
                  attach="./cacdirect_lifesaver_results_&client_data..html";
data _null_;
   file sendmail;
   put "Your CACdirect lifesaver job has completed.";
   put ;
   put "The dataset (&client_data._saved) has been saved and placed in &client_dir with the following types of data appended:";
   %if &ethnic=1 %then %do;
      put "      - Ethnic / religious data ('Ethnic' or 'Etech' data - all have prefix of 'ETECH_')";
   %end;
   %if &geo_interest=1 %then %do;
      put "      - Geographic level interests ('Geo Int' data - all have prefix of 'GEO_'), at Zip+2 level where possible";
   %end;
   %if &census=1 %then %do;
      put "      - Census data ('Census' data - all have prefix of 'CEN_'), at the Zip+4 level where possible";
   %end;
   put ;
   put "The job was initiated on &start_date at &start_time and completed on &end_date at &end_time";
   put ;
   put "Good Work!";
   put ;
   put "Please ensure you read the CACdirect manual before using this data.  The CACdirect Data Dictionary, along with this manual, can be found in P:\CACDIRECT\ADMIN\DATABASE\DOCUMENTATION.";
   put ;
   put "Sincerely,";
   put "Your CACdirect Team";
run;


%toolong:

%if &namelen=1 %then %do;
   filename sendmail email to=("&email")
                     subject="CACdirect Lifesaver Results - RTFM" 
                     from="webmaster@cac-group.com" 
                     ;

   data _null_;
      file sendmail;
      put "Your CACdirect lifesaver job has completed - in a miserable failure.";
      put ;
      put "The dataset (&client_data) you submitted could not be processed since the name was too long (>26 bytes).";
      put ;
      put "You were specifically warned about this in the training presentation and in the technical documentation.";
      put ;
      put "Please try again.  Good Work!";
      put ;
      put "Sincerely,";
      put "Your CACdirect Team";
   run;

%end;

%mend lifesaver;
