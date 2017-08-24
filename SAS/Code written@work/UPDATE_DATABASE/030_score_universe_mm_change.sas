*==============================================================================================*;
*  Macro:  	     cac_silh_scoring
   Purpose: 	     Score all dimensions and silhouettes for CACdirect matched data
   Created:          8/1/2012	
   Last Edited:      8/5/2012
   Code compiled by: Cara Joyce
   Authors:	     Brad Rukstales, Joel Schiltz, Jim Hoskins, Erik Lund, Cara Joyce
   Notes:            1) If scoring client file, assumes all required base_demo, geo_interest, and census data is on the file
                     2) Libname must be defined in user code 
   Change History:   8/31 - Confirmed match to Brads 1pct sample scores
                     8/31 - Confirmed match to Brads 1pct sample scores (2/1000 of sample did not match - 455/1337552 of full sample did not match)
                          - All includes moved to local folder (2/1000 of sample did not  match)
                          - Removed all includes from job that calls this (2/1000 of sample did not  match)
                          - Added obs, removed freqs and profile, pointed at clean copy of 1pct in silh directory (2/1000 of sample did not  match)
                          - Replaced lifestage scoring with more efficient code (elses) (2/1000 of sample did not  match)
                          - Combined last 2 datasteps into 1 (2/1000 of sample did not  match)
                          - Combined last 2 datasteps, yes again, into 1 (2/1000 of sample did not  match)
                          - Renamed 3 fields and removed sort/merge, combined datasteps that were around that sort/merge (2/1000 of sample did not  match)
                          - Combined last 2 datasteps, yes again, into 1 
/*DID NOT WORK
             CANNOT DO THIS!           - Combined first 2 datasteps, yes again, into 1 (2/1000 of sample did not  match)
                                                  - HUGE PROBLEMS - undide
             CANNOT DO THIS!           - Combined remaining 2 datasteps into 1 
                                                  - HUGE PROBLEMS - undide
                          - DID NOT DO ABOVE
              MY KEEPS SUCK!!! - Add keeps (2/1000 of sample did not match) SCREWED ME UP!!!!!
                          - Put elses around final seg assignment - (2/1000 of sample did not match)
*/
                          - Renamed CAC_SILH_BUY_STYLE_{6} array to test{6}  (2/1000 of sample did not  match)
                          - Put elses around final seg assignment - (2/1000 of sample did not match)
                          - Replaced all renames in cacdirect_modeling_recodes with new variable creation (2/1000 of sample did not match)
                          - Combine last 2 data sets (why did this finally work????) (2/1000)
                          - Combine remaining 2 data sets (why did this finally work????) (2/1000)
                          - Removed silh1 renames, replaced with creating new vars
                          - Apply cen_keeps (cannot apply base/geo keeps as is) (2/1000)
                          - Add demo_hh_type fill (from 5pct), causes 5/1000 mismatches on style2and5 - (2/1000 of sample did not  match)
                          - Add census fill (from 5pct) - caused mismatches - REMOVED
                          - put permanent write in single datastep                     
                          - commented out etech, dropped cac_silh after creating old version, renamed new silh on out, limited output vars, got rid of old lifedriver (2/1000)
                     9/2  - Recodes of final silhouette designations
                     10/3 - Numerous changes to get around wps issues
                     11/30- 2nd round of rename coding for silhouettes



        12/6/2012 ---TESTING EMBEDDED IN CODE---MUST  CHANGE BEFORE ROLLOUT

*==============================================================================================*;


%macro silhouettes(direct=N                  /*** Y-scoring direct data, N-scoring input client file;          ***/
                   ,state_list=NO              /*** list of states to process, enter NONE if running client file ***/
                   ,lib=                     /**** Libname of CACdirect matched client data - must be defined  ***/
                   ,indata=                  /**** CACdirect matched client data                               ***/
                   ,outdata=                 /**** Output dataset name                                         ***/
                   ,email=mmattingly             /**** CAC Group email user name                                   ***/
                   ,jdsobs=max
);

options nomprint;
%include './030_silh_build_formats.inc';
options mprint errors=1;
%include './030_cacdirect_modeling_recodes.inc';
%include './030_rename_enh.inc';

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
   
   /*%if %cmpres(&state_list)=  %then %do; */
   %if %cmpres("&state_list")=  %then %do;                                         *<---JDS modified to this after line below worked - ran OR (but not tested on full process)*;
   /*%if "&state_list"=  %then %do;*/                                              *<---JDS tested this on 9/3 after all jobs were done - OR did not process, this worked*;
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
   
   %if &direct=N %then %let state_count=1;                   *<-------------for protection from idiot users*;
   ********************************************************;
   *---------START OF MASTER STATE LOOP-------------------*;
   %do state_num=1 %to &state_count;
      %let curstate=%scan(&states_for_match, &state_num);
   *------------------------------------------------------*;
   ********************************************************;
      %if &direct=Y %then %do;

         data oops_&curstate;
            set base.base_demo_&curstate (obs=&jdsobs keep=cac_hh_pid cac_addr_zip cac_addr_zip4 cac_addr_state) end=eof;
            ***___FOR GEO / CENSUS MATCHING___***; 
            format match_zip5 $5. match_zip4 $4. match_zip2 $7. match_state $2.;
            match_state=cac_addr_state;
            ***___assign cacdir zip5 when matched___***;
            match_zip5=cac_addr_zip;
            ***___assign cacdir zip4 when matched and zip4 not missing___***;
            if cac_addr_zip4 ne '' then do;
                  match_zip4=compress(cac_addr_zip4);
                  match_zip2=compress(cac_addr_zip||substr(cac_addr_zip4,1,2));
            end;
         run;
      
         proc sort data=oops_&curstate;
            by cac_hh_pid;
         run;
   
         *-----------------------------------------*;
         * 2) ADD GEO INTERESTS 
         *-----------------------------------------*;
         proc sort data=oops_&curstate (keep=cac_hh_pid match_zip5 match_zip2 rename=(match_zip5=cac_addr_zip match_zip2=cac_addr_zip2)) out=client_z2_&curstate ;
            by cac_addr_zip2;
         run;
         
         proc sort data=geo.geo_interest_&curstate out=geo_interest_&curstate;
            by cac_addr_zip2;
         run;
     
         data client_z2_found_&curstate (drop=newzip) zip_&curstate (drop=geo: rename=(cac_addr_zip2=hold));
            format cac_addr_zip2 $7.;
            merge client_z2_&curstate (in=a)
                  geo_interest_&curstate (in=b /**keep=&geo_keeps cac_addr_zip2**/ drop=cac_addr_state cac_addr_zip);
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
     
         data client_zip_found_&curstate (drop=cac_addr_zip2 newzip rename=(hold=cac_addr_zip2)) state_&curstate (drop=geo: drop=cac_addr_zip2);
            format cac_addr_zip2 $7.;
            merge zip_&curstate (in=a rename=(newzip=cac_addr_zip2))
                  geo_interest_&curstate (in=b /**keep=&geo_keeps cac_addr_zip2**/ drop=cac_addr_state cac_addr_zip);
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
                  geo_interest_&curstate (in=b  /**keep=&geo_keeps cac_addr_zip2**/ drop=cac_addr_state cac_addr_zip);
            by cac_addr_zip2;
            cac_geo_match=3;
            if a and b;
         run;
       
         data client_z2_final_&curstate;
            set client_z2_found_&curstate (keep=cac_hh_pid cac_geo_match geo_:) 
                client_zip_found_&curstate  (keep=cac_hh_pid cac_geo_match geo_:)
                client_state_found_&curstate (keep=cac_hh_pid cac_geo_match geo_:);
         run;
      
         proc sort data=client_z2_final_&curstate;
            by cac_hh_pid;
         run;
     
         data oops_&curstate(sortedby=cac_hh_pid);
            merge oops_&curstate (in=a)
                  client_z2_final_&curstate (in=b);
            by cac_hh_pid;
            if a and b;
         run;
   
         proc datasets library=work nolist;
            delete client_z2_final_&curstate client_z2_found_&curstate client_zip_found_&curstate client_state_found_&curstate client_z2_&curstate;
         quit;
   
         *-----------------------------------------*;
         * 3) ADD CENSUS DATA 
         *-----------------------------------------*;
   
%macro replaced;
         proc sort data=oops_&curstate;
            by match_zip5 match_zip4;
         run;
   
         data oops_&curstate ;
            merge oops_&curstate(in=a)
                  cen2010.bad_one_cac_census_final_&curstate (in=b keep=&cen_keeps cac_addr_zip cac_addr_zip4 rename=(cac_addr_zip=match_zip5 cac_addr_zip4=match_zip4));
            by match_zip5 match_zip4;
            if a;
            cac_census_match=b;
         run;
   
         proc sort data=oops_&curstate;
            by cac_hh_pid;
         run;
%mend replaced;

*%replaced;

%macro newcen;
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

         data client_with_census_&curstate;
            merge client_with_cen_id_&curstate (in=a)
                  cen2010.cac_census_final_&curstate (in=b keep=&cen_keeps cac_census_id);
            by cac_census_id;
            if a and b;
         run;

         data oops_&curstate;
            set client_with_census_&curstate 
                nm_cen_zip_&curstate;
         run;

         proc sort data=oops_&curstate;
            by cac_hh_pid;
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
%mend newcen;
%newcen;
   
         *-----------------------------------------*;
         * 4) RECONSTRUCT FULL FILE FOR SCORING
         *-----------------------------------------*;
         %macro wpssucks;
         proc sort data=base.base_demo_&curstate (obs=&jdsobs /**keep=%base_keeps**/) out=base;
            by cac_hh_pid;
         run;
         %mend wpssucks;
         data base (sortedby=cac_hh_pid);
            set base.base_demo_&curstate (obs=&jdsobs

		/***NOTE ---- TESTING RENAME CHANGE.  WILL NEED TO REMOVE THIS BEFORE GOING LIVE****/
		drop=
		CAC_SILH
		CAC_SILH_BUY_STYLE_GROUP
		CAC_SILH_BUY_STYLE_RANK_1
		CAC_SILH_BUY_STYLE_RANK_2
		CAC_SILH_BUY_STYLE_RANK_3
		CAC_SILH_BUY_STYLE_RANK_4
		CAC_SILH_BUY_STYLE_RANK_5
		CAC_SILH_BUY_STYLE_RANK_6
		CAC_SILH_DIG_INF
		CAC_SILH_ECOM
		CAC_SILH_GEO
		CAC_SILH_LIFESTAGE
		CAC_SILH_LIFESTAGE_GROUP
		CAC_SILH_LIFESTYLE
		CAC_SILH_LOYAL
		CAC_SILH_LSTYLE_MACRO
		CAC_SILH_PRICE
		CAC_SILH_SOCIAL
		CAC_SILH_SOCIO_ECON
		CAC_SILH_SOCIO_GROUP
		CAC_SILH_SUPER
		CAC_SILH_TECH
		);
            
         run;

   %end;                                         *<--------------------------------- END OF DIRECT=Y LOOP *;

   %if &direct=Y %then %do;
      data newsilh.cac_silh_&curstate (keep=cac_hh_pid cac_addr_zip cac_addr_zip4 cac_sil: superseg silhouette rename=(silhouette=cac_silh superseg=cac_silh_super));        
   %end;
   %if &direct=N %then %do;
      data &lib..&outdata (keep=cac_hh_pid cac_addr_zip cac_addr_zip4 cac_sil: superseg silhouette rename=(silhouette=cac_silh superseg=cac_silh_super));
         set &lib..&indata (obs=&jdsobs keep=/*&base_keeps*/ cac_:  geo: &cen_keeps /* &geo_keeps*/);
   %end;
      %if &direct=Y %then %do;
          merge base (in=a)
                oops_&curstate (in=b obs=&jdsobs keep=/*&base_keeps*/ cac_:  geo: &cen_keeps /* &geo_keeps*/ drop=cac_addr_zip cac_addr_zip4 cac_addr_state);
          by cac_hh_pid;
          if a and b;
      %end;
      
      
      
      
      drop cac_silh;
      
      
      
      
      
      *******************************************************;
      *** SCORE BUY_STYLE 05_10_2012 ***;
      *******************************************************;
      M_INCOME_UNDER_15=(strip(CAC_DEMO_INCOME_ENH)='1');
      M_INC_15_20=(strip(CAC_DEMO_INCOME_ENH)='2');
      M_INC_20_30=(strip(CAC_DEMO_INCOME_ENH)='3');
      cac_net_worth_temp=cac_demo_net_worth_enh;
      if cac_demo_net_worth_enh=. then cac_demo_net_worth_enh=0;
      cac_home_mtg_temp=cac_home_mtg;
      if cac_home_mtg=. then cac_home_mtg=0;
      CAC_CRED_MORTGAGE_INCOME_temp=CAC_CRED_MORTGAGE_INCOME_INDEX;
      if CAC_CRED_MORTGAGE_INCOME_INDEX = . then CAC_CRED_MORTGAGE_INCOME_INDEX=0;
      array lstage_{19};
      do i=1 to 19;
         lstage_{i}=0;
      end;
      if cac_lifestage_group=. then cac_lifestage_group=19;
      lstage_{cac_lifestage_group}=1;
      if CAC_DEMO_HH_TYPE_ENH= . Then CAC_DEMO_HH_TYPE_ENH=9.0357498;  *<----------------- Added for 5 people not getting scored on style 2 & 5 **;
      cac_silh_buy_style_1=1 / (1 + (exp(-1 * (-1.387946299 + (LSTAGE_5 * (-0.220487723 )) + (CAC_DEMO_ADULT_18_24_ENH 
                           * (0.1441834833 )) + (CAC_DEMO_ADULT_65_PLUS_INF_ENH * (0.3961436009 )) + (CAC_DEMO_ADULT_UNKNOWN_ENH * (0.1055795272 )) + (CAC_DEMO_AGE_ENH * 
                           (-0.141676819 )) + (CAC_DEMO_KIDS_06_10_ENH * (0.0667242662 )) + (CAC_DEMO_NUM_ADULTS * (0.0929187754 )) + (CAC_INT_26 * (-0.209364158 
                           )) + (CAC_INT_32 * (-0.235854654 )) + (CAC_INT_48 * (0.6002394638 )) + (CAC_INT_72 * (0.3049622196 )) + (CAC_INT_75 * (-0.508873751 
                           )) + (CAC_INT_90 * (-0.388213123 )) + (CAC_INT_92 * (0.2474877626 )) + (CAC_INT_96 * (-0.2287416 )) + (CAC_INT_111 * (-0.243233735 
                           )) + (CAC_INT_114 * (0.2441581211 )) + (CAC_INT_115 * (0.2239970762 )) + (CAC_INT_120 * (0.3222579571 )) + (CAC_INT_MAIL_BUY * 
                           (-0.18004545 )) + (CAC_INT_MAIL_DONOR * (-0.183024519 )) + (GEO_CAC_INT_7 * (-2.600903229 )) + (GEO_CAC_INT_11 * (-0.620633191 )) + 
                           (GEO_CAC_INT_15 * (1.055430216 )) + (GEO_CAC_INT_19 * (-0.685041396 )) + (GEO_CAC_INT_22 * (1.2573524397 )) + (GEO_CAC_INT_37 * 
                           (-1.204379927 )) + (GEO_CAC_INT_65 * (-2.705307039 )) + (GEO_CAC_INT_77 * (2.8892562489 )) + (GEO_CAC_INT_79 * (8.7031622071 )) + 
                           (GEO_CAC_INT_92 * (1.1826450608 )) + (GEO_CAC_INT_94 * (0.9805340678 )) + (GEO_CAC_INT_110 * (-2.176551335 )) + (GEO_CAC_INT_118 * 
                           (2.3261588193 )) + (GEO_CAC_INT_121 * (-2.073201195 )) ))));
      cac_silh_buy_style_2=1 / (1 + (exp(-1 * (-1.512210442 + (LSTAGE_13 * (0.223275803 )) + 
                           (CAC_CRED_FINANCIAL_INSTALLMENT * (0.120811945 )) + (CAC_CRED_STD_RETAIL * (-0.168958192 )) + (CAC_CRED_VISA * (0.2287728039 )) + 
                           (CAC_DEMO_ADULT_55_64_ENH * (0.0631066083 )) + (CAC_DEMO_ADULT_75_PLUS_ENH * (0.15482867 )) + (CAC_DEMO_HH_TYPE_ENH * (0.0275359792 )) + 
                           (CAC_DEMO_OCCUPATION * (-0.012838343 )) + (CAC_INT_5 * (-0.181919343 )) + (CAC_INT_19 * (-0.229594578 )) + (CAC_INT_38 * 
                           (-0.262536788 )) + (CAC_INT_44 * (0.5362730618 )) + (CAC_INT_49 * (0.1806292308 )) + (CAC_INT_50 * (-0.213521153 )) + (CAC_INT_60 * 
                           (-0.248930411 )) + (CAC_INT_62 * (0.3563986755 )) + (CAC_INT_63 * (-0.481465331 )) + (CAC_INT_80 * (0.4138781269 )) + (CAC_INT_110 
                           * (0.2516880045 )) + (CAC_INT_119 * (-0.229725109 )) + (CAC_INT_MAIL_DONOR * (0.1861843358 )) + (GEO_CAC_INT_6 * (-2.223424982 )) + 
                           (GEO_CAC_INT_10 * (1.4795964937 )) + (GEO_CAC_INT_22 * (-3.230099575 )) + (GEO_CAC_INT_27 * (-1.406908091 )) + (GEO_CAC_INT_39 * 
                           (1.2714060765 )) + (GEO_CAC_INT_50 * (-1.270811857 )) + (GEO_CAC_INT_61 * (2.1420271351 )) + (GEO_CAC_INT_67 * (6.3421200219 )) + 
                           (GEO_CAC_INT_68 * (3.8169862046 )) + (GEO_CAC_INT_78 * (-2.250935542 )) + (GEO_CAC_INT_87 * (-5.20822348 )) + (GEO_CAC_INT_88 * 
                           (-2.501826129 )) + (GEO_CAC_INT_96 * (2.3914167781 )) + (GEO_CAC_INT_100 * (-1.052227283 )) ))));
      cac_silh_buy_style_3=1 / (1 + (exp(-1 * (-3.025589366 + (LSTAGE_3 * (-0.644077485 )) + (CAC_CRED_BANK * 
                           (0.1023889386 )) + (CAC_CRED_FINANCIAL_BANKING * (0.0981865957 )) + (CAC_DEMO_ADULT_75_PLUS_ENH * (-0.13155543 )) + (CAC_DEMO_AGE_ENH * 
                           (0.0989905065 )) + (CAC_DEMO_NUM_KIDS_ENH * (-0.064937614 )) + (CAC_INT_1 * (0.1307914514 )) + (CAC_INT_15 * (-0.161622348 )) + 
                           (CAC_INT_32 * (-0.160714779 )) + (CAC_INT_38 * (0.1398028292 )) + (CAC_INT_40 * (0.1039076868 )) + (CAC_INT_50 * (0.1528014895 )) + 
                           (CAC_INT_62 * (0.1705329084 )) + (CAC_INT_72 * (-0.222460627 )) + (CAC_INT_74 * (0.5729893897 )) + (CAC_INT_76 * (0.2144975082 )) + 
                           (CAC_INT_89 * (-0.189436496 )) + (CAC_INT_99 * (-0.322116381 )) + (GEO_CAC_INT_20 * (0.6634510413 )) + (GEO_CAC_INT_24 * 
                           (-1.146878343 )) + (GEO_CAC_INT_30 * (1.9214345275 )) + (GEO_CAC_INT_35 * (1.0573586369 )) + (GEO_CAC_INT_36 * (-2.436057136 )) + 
                           (GEO_CAC_INT_52 * (2.8031821424 )) + (GEO_CAC_INT_58 * (1.5501107777 )) + (GEO_CAC_INT_64 * (-2.143074993 )) + (GEO_CAC_INT_73 * 
                           (4.5320640067 )) + (GEO_CAC_INT_76 * (2.4557841251 )) + (GEO_CAC_INT_82 * (3.2227125943 )) + (GEO_CAC_INT_87 * (6.0591919875 )) + 
                           (GEO_CAC_INT_92 * (-0.727558724 )) + (GEO_CAC_INT_95 * (-2.270889237 )) + (GEO_CAC_INT_106 * (-1.979823573 )) + (GEO_CAC_INT_107 * 
                           (1.9529542273 )) + (GEO_CAC_INT_110 * (-2.637747791 )) ))));
      cac_silh_buy_style_4=1 / (1 + (exp(-1 * (-0.308987285 + (M_INCOME_UNDER_15 * (0.2703802488 )) + (M_INC_20_30 
                           * (0.1805325288 )) + (CAC_CRED_BANK * (-0.165222262 )) + (CAC_CRED_CATALOG * (0.8906309305 )) + (CAC_CRED_MORTGAGE_INCOME_INDEX * 
                           (0.0037524647 )) + (CAC_DEMO_ADULT_35_44_ENH * (0.0878400933 )) + (CAC_DEMO_ADULT_45_54_ENH * (0.0593655685 )) + (CAC_DEMO_AGE_ENH * 
                           (-0.122342008 )) + (CAC_DEMO_NARROW_INC_NUM * (-0.002860157 )) + (CAC_DEMO_NET_WORTH_ENH * (-0.011421595 )) + (CAC_DEMO_NUM_KIDS_ENH * 
                           (0.0769328845 )) + (CAC_INT_3 * (0.1349785748 )) + (CAC_INT_20 * (-0.175879052 )) + (CAC_INT_27 * (-0.199075217 )) + (CAC_INT_30 * 
                           (0.1643920851 )) + (CAC_INT_42 * (-0.325425302 )) + (CAC_INT_49 * (0.1356673545 )) + (CAC_INT_53 * (0.2350728078 )) + (CAC_INT_62 * 
                           (-0.234702164 )) + (CAC_INT_84 * (-0.224282289 )) + (CAC_INT_101 * (0.3210503984 )) + (CAC_INT_102 * (0.20835598 )) + 
                           (GEO_CAC_INT_3 * (1.250421988 )) + (GEO_CAC_INT_4 * (-2.131211857 )) + (GEO_CAC_INT_15 * (0.8953215589 )) + (GEO_CAC_INT_23 * 
                           (-2.310445151 )) + (GEO_CAC_INT_30 * (1.587516666 )) + (GEO_CAC_INT_49 * (1.2092351952 )) + (GEO_CAC_INT_55 * (-2.98899245 )) + 
                           (GEO_CAC_INT_68 * (2.2487873516 )) + (GEO_CAC_INT_78 * (-2.384654597 )) + (GEO_CAC_INT_92 * (-1.676177516 )) + (GEO_CAC_INT_95 * 
                           (2.7733985577 )) + (GEO_CAC_INT_97 * (1.8899610259 )) + (GEO_CAC_INT_114 * (-1.658605055 )) ))));
      cac_silh_buy_style_5=1 / (1 + (exp(-1 * (-1.379040541 + (LSTAGE_9 * (-0.306148183 )) + (CAC_DEMO_ADULT_55_64_ENH 
                           * (0.0750776717 )) + (CAC_DEMO_AGE_ENH * (-0.07764446 )) + (CAC_DEMO_HH_SIZE_ENH * (0.115037761 )) + (CAC_DEMO_HH_TYPE_ENH * (0.0155998533 )) + 
                           (CAC_DEMO_KIDS_06_10_ENH * (0.027335923 )) + (CAC_DEMO_NUM_ADULTS * (-0.228100688 )) + (CAC_HOME_OWN * (-0.134038183 )) + (CAC_INT_7 * 
                           (-0.147985206 )) + (CAC_INT_18 * (-0.179889875 )) + (CAC_INT_21 * (0.1585663 )) + (CAC_INT_26 * (0.1712405076 )) + (CAC_INT_33 * 
                           (-0.163678154 )) + (CAC_INT_36 * (0.3322002978 )) + (CAC_INT_40 * (0.1840867476 )) + (CAC_INT_43 * (0.2315121891 )) + (CAC_INT_46 * 
                           (0.2512182311 )) + (CAC_INT_55 * (-0.191012526 )) + (CAC_INT_57 * (-0.258903968 )) + (CAC_INT_66 * (-0.414497305 )) + (CAC_INT_93 * 
                           (0.467847678 )) + (CAC_INT_98 * (0.221731348 )) + (CAC_INT_107 * (0.2661119248 )) + (CAC_INT_112 * (-0.349999787 )) + (CAC_INT_118 
                           * (-0.159932748 )) + (CAC_INT_POL_PARTY * (0.1499587362 )) + (GEO_CAC_INT_11 * (-1.731962889 )) + (GEO_CAC_INT_19 * (1.8843192923 
                           )) + (GEO_CAC_INT_28 * (-1.247390563 )) + (GEO_CAC_INT_67 * (-4.410233708 )) + (GEO_CAC_INT_82 * (-2.520123247 )) + (GEO_CAC_INT_84 
                           * (2.9924848011 )) + (GEO_CAC_INT_103 * (-2.173389863 )) + (GEO_CAC_INT_113 * (-3.70901094 )) + (GEO_CAC_INT_118 * (1.4826181992 )) 
                           ))));
      cac_silh_buy_style_6=1 / (1 + (exp(-1 * (-3.85070443 + (M_INC_15_20 * (0.2243257917 )) + 
                           (CAC_CRED_COMP_ELECTRONIC * (0.2840295042 )) + (CAC_DEMO_ADULT_18_24_ENH * (-0.196288694 )) + (CAC_DEMO_ADULT_25_34_ENH * (-0.128150803 )) 
                           + (CAC_DEMO_ADULT_35_44_ENH * (-0.092899403 )) + (CAC_DEMO_ADULT_35_44_INF_ENH * (0.2639959315 )) + (CAC_DEMO_ADULT_65_74_ENH * (0.1472297001 
                           )) + (CAC_DEMO_ADULT_75_PLUS_ENH * (0.0922389428 )) + (CAC_DEMO_AGE_ENH * (0.1178055928 )) + (CAC_DEMO_NARROW_INC_NUM * (-0.00122923 )) + 
                           (CAC_DEMO_OCCUPATION * (0.011726847 )) + (CAC_HOME_MTG * (-0.000841175 )) + (CAC_HOME_RES_LENGTH * (0.0445288735 )) + (CAC_INT_1 * 
                           (0.161526894 )) + (CAC_INT_13 * (0.1924910427 )) + (CAC_INT_31 * (-0.212576442 )) + (CAC_INT_37 * (-0.231855189 )) + (CAC_INT_57 * 
                           (-0.243328779 )) + (CAC_INT_60 * (-0.248273705 )) + (CAC_INT_67 * (-0.32528321 )) + (CAC_INT_82 * (0.1900968924 )) + (GEO_CAC_INT_4 
                           * (2.159944332 )) + (GEO_CAC_INT_20 * (-0.993707301 )) + (GEO_CAC_INT_35 * (2.0267386022 )) + (GEO_CAC_INT_36 * (-3.266584573 )) + 
                           (GEO_CAC_INT_57 * (-2.909944282 )) + (GEO_CAC_INT_60 * (1.9121916026 )) + (GEO_CAC_INT_69 * (-9.035202627 )) + (GEO_CAC_INT_74 * 
                           (3.5881450604 )) + (GEO_CAC_INT_82 * (-2.228146483 )) + (GEO_CAC_INT_98 * (0.8989657912 )) + (GEO_CAC_INT_100 * (-1.560902303 )) + 
                           (GEO_CAC_INT_105 * (-2.750013303 )) + (GEO_CAC_INT_113 * (-4.065847756 )) + (GEO_CAC_INT_116 * (2.647475805 )) ))));
      cac_demo_net_worth_enh=cac_net_worth_temp;
      cac_home_mtg=cac_home_mtg_temp;
      CAC_CRED_MORTGAGE_INCOME_INDEX=CAC_CRED_MORTGAGE_INCOME_temp;
      drop m_income_under_15 m_inc_15_20 m_inc_20_30 lstage_1-lstage_19 cac_home_mtg_temp cac_net_worth_temp CAC_CRED_MORTGAGE_INCOME_temp;
      label cac_silh_buy_style_1= "Buying Style: WANT IT NOW";
      label cac_silh_buy_style_2= "Buying Style: ENVIRONMENT/HEALTH";
      label cac_silh_buy_style_3= "Buying Style: BRAND LOYAL";
      label cac_silh_buy_style_4= "Buying Style: PRICE";
      label cac_silh_buy_style_5= "Buying Style: SHOPPING AS RELAXATION";
      label cac_silh_buy_style_6= "Buying Style: LEAVE ME ALONE";
      *******************************************************;
      *** END BUY_STYLE 05_10_2012 ***;
      *******************************************************;
      *******************************************************;
      *** SCORE GEO 05_12_2012 ***;
      *******************************************************;
      cac_silh_geo=put(cac_addr_zip,$geof.)+0;
      *******************************************************;
      *** END SCORE GEO 05_12_2012 ***;
      *******************************************************;
      *******************************************************;
      *** SCORE LIFESTAGE 05_12_2012 ***;
      *******************************************************;
      format lifestage_raw $4.;           *<-------------------------------------ADDED 10/3/2012 by JS cuz WPS SUCKS*;
      ** BYTE 1: MARITAL STATUS **;
      if cac_demo_marital_status=1 or cac_demo_marital_status=3 then substr(lifestage_raw,1,1)="M";
      else if cac_demo_marital_status=2 then substr(lifestage_raw,1,1)="S";
      else substr(lifestage_raw,1,1)="X";
      ** BYTE 2: GENDER IF SINGLE **;
      if cac_demo_marital_status=2 and cac_ind1_gender=1 then substr(lifestage_raw,2,1)="M";
      else if cac_demo_marital_status=2 and 2<=cac_ind1_gender<=3 then substr(lifestage_raw,2,1)="F";
      else if cac_demo_marital_status=2 then substr(lifestage_raw,2,1)="X";
      if cac_ind1_gender=1 then gender="M";
      else if 2<=cac_ind1_gender<=3 then gender="F";
      else gender="X";
      ** BYTE 3: PRESENCE OF CHILDREN **;
      if cac_demo_kids_11_15_enh>0 or cac_demo_kids_16_17_enh>0 then substr(lifestage_raw,3,1)='3';
      else if cac_demo_kids_06_10_enh>0 then substr(lifestage_raw,3,1)='2';
      else if cac_demo_kids_00_02_enh>0 or cac_demo_kids_03_05_enh>0 then substr(lifestage_raw,3,1)='1';
      else if cac_demo_kids_enh>0 then substr(lifestage_raw,3,1)="4";
      numadults=cac_demo_num_adults;
      if numadults>2 then numadults=2;
      bd1=floor(cac_ind1_birthdate_enh/100);
      bd2=floor(cac_ind2_birthdate_enh/100);
      diff=abs(bd1-bd2);
      if numadults=2 and 0<=diff<=8 and cac_ind1_gender ne cac_ind2_gender then mar_q=1;
      else mar_q=0;
      age=cac_demo_age_enh;
      length lifestage_mod $ 7.;
      *----- JDS added elses on 6/29 - moved "X" lines of code below gender lines of code ------*;
      if lifestage_raw='M ' and Age=1 and numadults=2 and mar_q=0 then lifestage_mod='M_1_Y_';
      else if lifestage_raw='M ' and Age=1 and numadults=2 and mar_q=1 then lifestage_mod='M_1_Y_';
      else if lifestage_raw='M ' and Age=2 and numadults=2 and mar_q=0 and gender="M" then lifestage_mod='S_2_ _M';
      else if lifestage_raw='M ' and Age=2 and numadults=2 and mar_q=0 and gender="F" then lifestage_mod='S_2_ _F';
      else if lifestage_raw='M ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='S_2_ _X';
      else if lifestage_raw='M ' and Age=3 and numadults=2 and mar_q=0 and gender="M" then lifestage_mod='S_3_ _M';
      else if lifestage_raw='M ' and Age=3 and numadults=2 and mar_q=0 and gender="F" then lifestage_mod='S_3_ _F';
      else if lifestage_raw='M ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='S_3_ _X';
      else if lifestage_raw='M ' and Age=4 and numadults=2 and mar_q=0 and gender="M" then lifestage_mod='S_4_ _M';
      else if lifestage_raw='M ' and Age=4 and numadults=2 and mar_q=0 and gender="F" then lifestage_mod='S_4_ _F';
      else if lifestage_raw='M ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='S_4_ _X';
      else if lifestage_raw='M ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='M_5_ _';
      else if lifestage_raw='M ' and Age=5 and numadults=2 and mar_q=1 then lifestage_mod='M_5_ _';
      else if lifestage_raw='M ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='M_6_ _';
      else if lifestage_raw='M ' and Age=6 and numadults=2 and mar_q=1 then lifestage_mod='M_6_ _';
      else if lifestage_raw='M ' and Age=7 and numadults=2 and mar_q=0 and gender="M" then lifestage_mod='S_7_ _M';
      else if lifestage_raw='M ' and Age=7 and numadults=2 and mar_q=0 and gender="F" then lifestage_mod='S_7_ _F';
      else if lifestage_raw='M ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='S_7_ _X';
      else if lifestage_raw='M ' and Age=7 and numadults=2 and mar_q=1 then lifestage_mod='M_7_ _';
      else if lifestage_raw='M 1 ' and Age=1 and numadults=2 and mar_q=0 then lifestage_mod='M_1_Y_';
      else if lifestage_raw='M 1 ' and Age=1 and numadults=2 and mar_q=1 then lifestage_mod='M_1_Y_';
      else if lifestage_raw='M 1 ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='M 1 ' and Age=2 and numadults=2 and mar_q=1 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='M 1 ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='M 1 ' and Age=3 and numadults=2 and mar_q=1 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='M 1 ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='M_4_ _';
      else if lifestage_raw='M 1 ' and Age=4 and numadults=2 and mar_q=1 then lifestage_mod='M_4_ _';
      else if lifestage_raw='M 1 ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='M_5_ _';
      else if lifestage_raw='M 1 ' and Age=5 and numadults=2 and mar_q=1 then lifestage_mod='M_5_ _';
      else if lifestage_raw='M 1 ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='M_6_ _';
      else if lifestage_raw='M 1 ' and Age=6 and numadults=2 and mar_q=1 then lifestage_mod='M_6_ _';
      else if lifestage_raw='M 1 ' and Age=7 and numadults=2 and mar_q=0 and gender="M" then lifestage_mod='S_7_ _M';
      else if lifestage_raw='M 1 ' and Age=7 and numadults=2 and mar_q=0 and gender="F" then lifestage_mod='S_7_ _F';
      else if lifestage_raw='M 1 ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='S_7_ _X';
      else if lifestage_raw='M 1 ' and Age=7 and numadults=2 and mar_q=1 then lifestage_mod='M_7_ _';
      else if lifestage_raw='M 2 ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='M 2 ' and Age=2 and numadults=2 and mar_q=1 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='M 2 ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='M 2 ' and Age=3 and numadults=2 and mar_q=1 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='M 2 ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='M_4_Y_';
      else if lifestage_raw='M 2 ' and Age=4 and numadults=2 and mar_q=1 then lifestage_mod='M_4_Y_';
      else if lifestage_raw='M 2 ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='M_5_Y_';
      else if lifestage_raw='M 2 ' and Age=5 and numadults=2 and mar_q=1 then lifestage_mod='M_5_ _';
      else if lifestage_raw='M 2 ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='M_6_ _';
      else if lifestage_raw='M 2 ' and Age=6 and numadults=2 and mar_q=1 then lifestage_mod='M_6_ _';
      else if lifestage_raw='M 2 ' and Age=7 and numadults=2 and mar_q=0 and gender="M" then lifestage_mod='S_7_ _M';
      else if lifestage_raw='M 2 ' and Age=7 and numadults=2 and mar_q=0 and gender="F" then lifestage_mod='S_7_ _F';
      else if lifestage_raw='M 2 ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='S_7_ _X';
      else if lifestage_raw='M 2 ' and Age=7 and numadults=2 and mar_q=1 then lifestage_mod='M_7_ _';
      else if lifestage_raw='M 3 ' and Age=1 and numadults=2 and mar_q=0 then lifestage_mod='S_1_ _';
      else if lifestage_raw='M 3 ' and Age=1 and numadults=2 and mar_q=1 then lifestage_mod='M_1_Y_';
      else if lifestage_raw='M 3 ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='M 3 ' and Age=2 and numadults=2 and mar_q=1 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='M 3 ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='M 3 ' and Age=3 and numadults=2 and mar_q=1 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='M 3 ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='M_4_Y_';
      else if lifestage_raw='M 3 ' and Age=4 and numadults=2 and mar_q=1 then lifestage_mod='M_4_Y_';
      else if lifestage_raw='M 3 ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='M_5_Y_';
      else if lifestage_raw='M 3 ' and Age=5 and numadults=2 and mar_q=1 then lifestage_mod='M_5_Y_';
      else if lifestage_raw='M 3 ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='M_6_ _';
      else if lifestage_raw='M 3 ' and Age=6 and numadults=2 and mar_q=1 then lifestage_mod='M_6_ _';
      else if lifestage_raw='M 3 ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='M_7_ _';
      else if lifestage_raw='M 3 ' and Age=7 and numadults=2 and mar_q=1 then lifestage_mod='M_7_ _';
      else if lifestage_raw='M 4 ' and Age=1 and numadults=2 and mar_q=0 then lifestage_mod='M_1_Y_';
      else if lifestage_raw='M 4 ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='M_2_ _';
      else if lifestage_raw='M 4 ' and Age=2 and numadults=2 and mar_q=1 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='M 4 ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='M_3_ _';
      else if lifestage_raw='M 4 ' and Age=3 and numadults=2 and mar_q=1 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='M 4 ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='M_4_ _';
      else if lifestage_raw='M 4 ' and Age=4 and numadults=2 and mar_q=1 then lifestage_mod='M_4_ _';
      else if lifestage_raw='M 4 ' and Age=5 and numadults=2 and mar_q=0 and gender="M" then lifestage_mod='S_5_ _M';
      else if lifestage_raw='M 4 ' and Age=5 and numadults=2 and mar_q=0 and gender="F" then lifestage_mod='S_5_ _F';
      else if lifestage_raw='M 4 ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='S_5_ _X';
      else if lifestage_raw='M 4 ' and Age=6 and numadults=2 and mar_q=0 and gender="M" then lifestage_mod='S_6_ _M';
      else if lifestage_raw='M 4 ' and Age=6 and numadults=2 and mar_q=0 and gender="F" then lifestage_mod='S_6_ _F';
      else if lifestage_raw='M 4 ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='S_6_ _X';
      else if lifestage_raw='SF ' and Age=1 and numadults=1 and mar_q=0 then lifestage_mod='S_1_ _';
      else if lifestage_raw='SF ' and Age=1 and numadults=2 and mar_q=0 then lifestage_mod='M_1_Y_';
      else if lifestage_raw='SF ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='S_2_ _F';
      else if lifestage_raw='SF ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='S_2_Y_F';
      else if lifestage_raw='SF ' and Age=2 and numadults=2 and mar_q=1 then lifestage_mod='M_2_ _';
      else if lifestage_raw='SF ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='S_3_ _F';
      else if lifestage_raw='SF ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='S_3_ _F';
      else if lifestage_raw='SF ' and Age=3 and numadults=2 and mar_q=1 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SF ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='S_4_ _F';
      else if lifestage_raw='SF ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='S_4_ _F';
      else if lifestage_raw='SF ' and Age=4 and numadults=2 and mar_q=1 then lifestage_mod='M_4_ _';
      else if lifestage_raw='SF ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='S_5_ _F';
      else if lifestage_raw='SF ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='S_5_ _F';
      else if lifestage_raw='SF ' and Age=5 and numadults=2 and mar_q=1 then lifestage_mod='S_5_ _F';
      else if lifestage_raw='SF ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='S_6_ _F';
      else if lifestage_raw='SF ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='S_6_ _F';
      else if lifestage_raw='SF ' and Age=6 and numadults=2 and mar_q=1 then lifestage_mod='S_6_ _F';
      else if lifestage_raw='SF ' and Age=7 and numadults=1 and mar_q=0 then lifestage_mod='S_7_ _F';
      else if lifestage_raw='SF ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='S_7_ _F';
      else if lifestage_raw='SF ' and Age=7 and numadults=2 and mar_q=1 then lifestage_mod='S_7_ _F';
      else if lifestage_raw='SF1 ' and Age=1 and numadults=1 and mar_q=0 then lifestage_mod='S_1_ _F';
      else if lifestage_raw='SF1 ' and Age=1 and numadults=2 and mar_q=0 then lifestage_mod='M_1_Y_';
      else if lifestage_raw='SF1 ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='S_2_Y_F';
      else if lifestage_raw='SF1 ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='SF1 ' and Age=2 and numadults=2 and mar_q=1 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='SF1 ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='S_3_Y_F';
      else if lifestage_raw='SF1 ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SF1 ' and Age=3 and numadults=2 and mar_q=1 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SF1 ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='S_4_ _F';
      else if lifestage_raw='SF1 ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='S_4_ _F';
      else if lifestage_raw='SF1 ' and Age=4 and numadults=2 and mar_q=1 then lifestage_mod='M_4_ _';
      else if lifestage_raw='SF1 ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='S_5_ _F';
      else if lifestage_raw='SF1 ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='S_5_ _F';
      else if lifestage_raw='SF1 ' and Age=5 and numadults=2 and mar_q=1 then lifestage_mod='S_5_ _F';
      else if lifestage_raw='SF1 ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='S_6_ _F';
      else if lifestage_raw='SF1 ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='S_6_ _F';
      else if lifestage_raw='SF1 ' and Age=6 and numadults=2 and mar_q=1 then lifestage_mod='S_6_ _F';
      else if lifestage_raw='SF1 ' and Age=7 and numadults=1 and mar_q=0 then lifestage_mod='S_7_ _F';
      else if lifestage_raw='SF1 ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='S_7_Y_F';
      else if lifestage_raw='SF2 ' and Age=1 and numadults=1 and mar_q=0 then lifestage_mod='S_1_Y_F';
      else if lifestage_raw='SF2 ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='S_2_ _F';
      else if lifestage_raw='SF2 ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='S_2_Y_F';
      else if lifestage_raw='SF2 ' and Age=2 and numadults=2 and mar_q=1 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='SF2 ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='S_3_Y_F';
      else if lifestage_raw='SF2 ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SF2 ' and Age=3 and numadults=2 and mar_q=1 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SF2 ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='S_4_Y_F';
      else if lifestage_raw='SF2 ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='S_4_ _F';
      else if lifestage_raw='SF2 ' and Age=4 and numadults=2 and mar_q=1 then lifestage_mod='M_4_Y_';
      else if lifestage_raw='SF2 ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='S_5_ _F';
      else if lifestage_raw='SF2 ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='S_5_ _F';
      else if lifestage_raw='SF2 ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='S_6_ _F';
      else if lifestage_raw='SF2 ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='S_6_ _F';
      else if lifestage_raw='SF2 ' and Age=6 and numadults=2 and mar_q=1 then lifestage_mod='S_6_ _F';
      else if lifestage_raw='SF2 ' and Age=7 and numadults=1 and mar_q=0 then lifestage_mod='S_7_ _F';
      else if lifestage_raw='SF2 ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='M_7_ _';
      else if lifestage_raw='SF3 ' and Age=1 and numadults=1 and mar_q=0 then lifestage_mod='S_1_Y_F';
      else if lifestage_raw='SF3 ' and Age=1 and numadults=2 and mar_q=0 then lifestage_mod='S_1_ _F';
      else if lifestage_raw='SF3 ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='S_2_ _F';
      else if lifestage_raw='SF3 ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='S_2_ _F';
      else if lifestage_raw='SF3 ' and Age=2 and numadults=2 and mar_q=1 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='SF3 ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='S_3_Y_F';
      else if lifestage_raw='SF3 ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='S_3_ _F';
      else if lifestage_raw='SF3 ' and Age=3 and numadults=2 and mar_q=1 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SF3 ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='S_4_Y_F';
      else if lifestage_raw='SF3 ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='M_4_Y_';
      else if lifestage_raw='SF3 ' and Age=4 and numadults=2 and mar_q=1 then lifestage_mod='M_4_Y_';
      else if lifestage_raw='SF3 ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='S_5_ _F';
      else if lifestage_raw='SF3 ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='S_5_ _F';
      else if lifestage_raw='SF3 ' and Age=5 and numadults=2 and mar_q=1 then lifestage_mod='S_5_Y_F';
      else if lifestage_raw='SF3 ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='S_6_ _F';
      else if lifestage_raw='SF3 ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='S_6_ _F';
      else if lifestage_raw='SF3 ' and Age=6 and numadults=2 and mar_q=1 then lifestage_mod='M_6_ _';
      else if lifestage_raw='SF3 ' and Age=7 and numadults=1 and mar_q=0 then lifestage_mod='S_7_ _F';
      else if lifestage_raw='SF3 ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='S_7_ _F';
      else if lifestage_raw='SM ' and Age=1 and numadults=1 and mar_q=0 then lifestage_mod='S_1_ _M';
      else if lifestage_raw='SM ' and Age=1 and numadults=2 and mar_q=0 then lifestage_mod='S_1_ _M';
      else if lifestage_raw='SM ' and Age=1 and numadults=2 and mar_q=1 then lifestage_mod='S_1_ _M';
      else if lifestage_raw='SM ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='S_2_ _M';
      else if lifestage_raw='SM ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='M_2_ _';
      else if lifestage_raw='SM ' and Age=2 and numadults=2 and mar_q=1 then lifestage_mod='M_2_ _';
      else if lifestage_raw='SM ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='S_3_ _M';
      else if lifestage_raw='SM ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SM ' and Age=3 and numadults=2 and mar_q=1 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SM ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='S_4_ _M';
      else if lifestage_raw='SM ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='M_4_ _';
      else if lifestage_raw='SM ' and Age=4 and numadults=2 and mar_q=1 then lifestage_mod='M_4_ _';
      else if lifestage_raw='SM ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='S_5_ _M';
      else if lifestage_raw='SM ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='S_5_ _M';
      else if lifestage_raw='SM ' and Age=5 and numadults=2 and mar_q=1 then lifestage_mod='M_5_ _';
      else if lifestage_raw='SM ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='S_6_ _M';
      else if lifestage_raw='SM ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='S_6_ _M';
      else if lifestage_raw='SM ' and Age=6 and numadults=2 and mar_q=1 then lifestage_mod='S_6_ _M';
      else if lifestage_raw='SM ' and Age=7 and numadults=1 and mar_q=0 then lifestage_mod='S_7_ _M';
      else if lifestage_raw='SM ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='M_7_ _';
      else if lifestage_raw='SM ' and Age=7 and numadults=2 and mar_q=1 then lifestage_mod='M_7_ _';
      else if lifestage_raw='SM1 ' and Age=1 and numadults=1 and mar_q=0 then lifestage_mod='S_1_ _M';
      else if lifestage_raw='SM1 ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='SM1 ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='SM1 ' and Age=2 and numadults=2 and mar_q=1 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='SM1 ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SM1 ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SM1 ' and Age=3 and numadults=2 and mar_q=1 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SM1 ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='S_4_ _M';
      else if lifestage_raw='SM1 ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='S_4_ _M';
      else if lifestage_raw='SM1 ' and Age=4 and numadults=2 and mar_q=1 then lifestage_mod='M_4_Y_';
      else if lifestage_raw='SM1 ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='S_5_ _M';
      else if lifestage_raw='SM1 ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='S_5_ _M';
      else if lifestage_raw='SM1 ' and Age=5 and numadults=2 and mar_q=1 then lifestage_mod='M_5_ _';
      else if lifestage_raw='SM1 ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='S_6_ _M';
      else if lifestage_raw='SM1 ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='S_6_ _M';
      else if lifestage_raw='SM1 ' and Age=7 and numadults=1 and mar_q=0 then lifestage_mod='S_7_ _M';
      else if lifestage_raw='SM1 ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='S_7_ _M';
      else if lifestage_raw='SM2 ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='S_2_ _M';
      else if lifestage_raw='SM2 ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='SM2 ' and Age=2 and numadults=2 and mar_q=1 then lifestage_mod='M_2_ _';
      else if lifestage_raw='SM2 ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='S_3_Y_M';
      else if lifestage_raw='SM2 ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SM2 ' and Age=3 and numadults=2 and mar_q=1 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SM2 ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='S_4_Y_M';
      else if lifestage_raw='SM2 ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='M_4_Y_';
      else if lifestage_raw='SM2 ' and Age=4 and numadults=2 and mar_q=1 then lifestage_mod='M_4_ _';
      else if lifestage_raw='SM2 ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='S_5_ _M';
      else if lifestage_raw='SM2 ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='S_5_ _M';
      else if lifestage_raw='SM2 ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='M_6_Y_';
      else if lifestage_raw='SM2 ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='M_7_Y_';
      else if lifestage_raw='SM3 ' and Age=1 and numadults=1 and mar_q=0 then lifestage_mod='M_1_Y_';
      else if lifestage_raw='SM3 ' and Age=1 and numadults=2 and mar_q=1 then lifestage_mod='M_1_Y_';
      else if lifestage_raw='SM3 ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='S_2_Y_M';
      else if lifestage_raw='SM3 ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='S_2_ _M';
      else if lifestage_raw='SM3 ' and Age=2 and numadults=2 and mar_q=1 then lifestage_mod='S_2_Y_M';
      else if lifestage_raw='SM3 ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='S_3_Y_M';
      else if lifestage_raw='SM3 ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SM3 ' and Age=3 and numadults=2 and mar_q=1 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SM3 ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='S_4_ _M';
      else if lifestage_raw='SM3 ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='M_4_Y_';
      else if lifestage_raw='SM3 ' and Age=4 and numadults=2 and mar_q=1 then lifestage_mod='M_4_Y_';
      else if lifestage_raw='SM3 ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='S_5_ _M';
      else if lifestage_raw='SM3 ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='S_5_ _M';
      else if lifestage_raw='SM3 ' and Age=5 and numadults=2 and mar_q=1 then lifestage_mod='S_5_Y_M';
      else if lifestage_raw='SM3 ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='S_6_Y_M';
      else if lifestage_raw='SM3 ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='S_6_ _M';
      else if lifestage_raw='SM3 ' and Age=6 and numadults=2 and mar_q=1 then lifestage_mod='S_6_ _M';
      else if lifestage_raw='SM3 ' and Age=7 and numadults=1 and mar_q=0 then lifestage_mod='S_7_ _M';
      else if lifestage_raw='SM3 ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='S_7_ _M';
      else if lifestage_raw='SX ' and Age=1 and numadults=1 and mar_q=0 then lifestage_mod='S_1_ _U';
      else if lifestage_raw='SX ' and Age=1 and numadults=2 and mar_q=0 then lifestage_mod='S_1_Y_U';
      else if lifestage_raw='SX ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='S_2_ _U';
      else if lifestage_raw='SX ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='SX ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='S_3_ _U';
      else if lifestage_raw='SX ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='M_3_ _';
      else if lifestage_raw='SX ' and Age=3 and numadults=2 and mar_q=1 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SX ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='S_4_ _U';
      else if lifestage_raw='SX ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='S_4_ _U';
      else if lifestage_raw='SX ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='S_5_ _U';
      else if lifestage_raw='SX ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='S_5_ _U';
      else if lifestage_raw='SX ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='S_6_ _U';
      else if lifestage_raw='SX ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='S_6_ _U';
      else if lifestage_raw='SX ' and Age=6 and numadults=2 and mar_q=1 then lifestage_mod='M_6_ _';
      else if lifestage_raw='SX ' and Age=7 and numadults=1 and mar_q=0 then lifestage_mod='S_7_ _U';
      else if lifestage_raw='SX ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='S_7_ _U';
      else if lifestage_raw='SX1 ' and Age=1 and numadults=1 and mar_q=0 then lifestage_mod='M_1_Y_';
      else if lifestage_raw='SX1 ' and Age=1 and numadults=2 and mar_q=0 then lifestage_mod='M_1_Y_';
      else if lifestage_raw='SX1 ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='SX1 ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='SX1 ' and Age=2 and numadults=2 and mar_q=1 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='SX1 ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='S_3_ _U';
      else if lifestage_raw='SX1 ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='S_3_Y_U';
      else if lifestage_raw='SX1 ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='S_4_ _U';
      else if lifestage_raw='SX1 ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='S_4_Y_U';
      else if lifestage_raw='SX1 ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='S_5_ _U';
      else if lifestage_raw='SX1 ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='M_5_Y_';
      else if lifestage_raw='SX1 ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='S_6_ _U';
      else if lifestage_raw='SX1 ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='S_6_ _U';
      else if lifestage_raw='SX1 ' and Age=7 and numadults=1 and mar_q=0 then lifestage_mod='S_7_Y_U';
      else if lifestage_raw='SX1 ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='S_7_ _U';
      else if lifestage_raw='SX2 ' and Age=1 and numadults=1 and mar_q=0 then lifestage_mod='S_1_Y_U';
      else if lifestage_raw='SX2 ' and Age=1 and numadults=2 and mar_q=0 then lifestage_mod='M_1_Y_';
      else if lifestage_raw='SX2 ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='SX2 ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='M_2_ _';
      else if lifestage_raw='SX2 ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='SX2 ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='S_3_ _U';
      else if lifestage_raw='SX2 ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='M_4_Y_';
      else if lifestage_raw='SX2 ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='S_4_Y_U';
      else if lifestage_raw='SX2 ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='S_5_Y_U';
      else if lifestage_raw='SX2 ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='S_5_ _U';
      else if lifestage_raw='SX2 ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='M_6_ _';
      else if lifestage_raw='SX2 ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='S_6_ _U';
      else if lifestage_raw='SX3 ' and Age=1 and numadults=1 and mar_q=0 then lifestage_mod='S_1_ _U';
      else if lifestage_raw='SX3 ' and Age=1 and numadults=2 and mar_q=0 then lifestage_mod='S_1_ _U';
      else if lifestage_raw='SX3 ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='S_2_ _U';
      else if lifestage_raw='SX3 ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='SX3 ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='S_3_ _U';
      else if lifestage_raw='SX3 ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='S_3_Y_U';
      else if lifestage_raw='SX3 ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='S_4_ _U';
      else if lifestage_raw='SX3 ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='M_4_ _';
      else if lifestage_raw='SX3 ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='M_5_ _';
      else if lifestage_raw='SX3 ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='S_5_ _U';
      else if lifestage_raw='SX3 ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='M_6_ _';
      else if lifestage_raw='SX3 ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='M_6_Y_';
      else if lifestage_raw='SX3 ' and Age=7 and numadults=1 and mar_q=0 then lifestage_mod='S_7_ _U';
      else if lifestage_raw='SX3 ' and Age=7 and numadults=2 and mar_q=0 then lifestage_mod='M_7_Y_';
      else if lifestage_raw='SX4 ' and Age=1 and numadults=1 and mar_q=0 then lifestage_mod='S_1_Y_U';
      else if lifestage_raw='SX4 ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='S_2_ _U';
      else if lifestage_raw='SX4 ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='M_3_ _';
      else if lifestage_raw='SX4 ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='S_4_ _U';
      else if lifestage_raw='SX4 ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='S_5_ _U';
      else if lifestage_raw='SX4 ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='S_6_ _U';
      else if lifestage_raw='SX4 ' and Age=7 and numadults=1 and mar_q=0 then lifestage_mod='S_7_ _U';
      else if lifestage_raw='X ' and Age=1 and numadults=1 and mar_q=0 then lifestage_mod='S_1_ _U';
      else if lifestage_raw='X ' and Age=1 and numadults=2 and mar_q=0 then lifestage_mod='M_1_ _';
      else if lifestage_raw='X ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='S_2_ _U';
      else if lifestage_raw='X ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='S_2_ _U';
      else if lifestage_raw='X ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='S_3_ _U';
      else if lifestage_raw='X ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='M_3_ _';
      else if lifestage_raw='X ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='S_4_ _U';
      else if lifestage_raw='X ' and Age=4 and numadults=2 and mar_q=0 then lifestage_mod='S_4_ _U';
      else if lifestage_raw='X ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='S_5_ _U';
      else if lifestage_raw='X ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='M_5_ _';
      else if lifestage_raw='X ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='S_6_ _U';
      else if lifestage_raw='X ' and Age=6 and numadults=2 and mar_q=0 then lifestage_mod='S_6_Y_U';
      else if lifestage_raw='X ' and Age=7 and numadults=1 and mar_q=0 then lifestage_mod='S_7_ _U';
      else if lifestage_raw='X 1 ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='X 1 ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='M_3_ _';
      else if lifestage_raw='X 1 ' and Age=3 and numadults=2 and mar_q=0 then lifestage_mod='M_3_Y_';
      else if lifestage_raw='X 1 ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='S_4_ _U';
      else if lifestage_raw='X 1 ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='M_5_Y_';
      else if lifestage_raw='X 1 ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='S_6_ _U';
      else if lifestage_raw='X 2 ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='S_2_ _U';
      else if lifestage_raw='X 2 ' and Age=2 and numadults=2 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='X 2 ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='S_3_Y_U';
      else if lifestage_raw='X 2 ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='S_5_ _U';
      else if lifestage_raw='X 2 ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='S_6_ _U';
      else if lifestage_raw='X 3 ' and Age=2 and numadults=1 and mar_q=0 then lifestage_mod='M_2_Y_';
      else if lifestage_raw='X 3 ' and Age=3 and numadults=1 and mar_q=0 then lifestage_mod='S_3_ _U';
      else if lifestage_raw='X 3 ' and Age=4 and numadults=1 and mar_q=0 then lifestage_mod='M_4_ _';
      else if lifestage_raw='X 3 ' and Age=5 and numadults=1 and mar_q=0 then lifestage_mod='M_5_ _';
      else if lifestage_raw='X 3 ' and Age=5 and numadults=2 and mar_q=0 then lifestage_mod='M_5_ _';
      else if lifestage_raw='X 3 ' and Age=6 and numadults=1 and mar_q=0 then lifestage_mod='S_6_ _U';
      else if lifestage_raw='X 3 ' and Age=7 and numadults=1 and mar_q=0 then lifestage_mod='M_7_Y_';
      if Lifestage_mod='S_1_ _M' then CAC_Lifestage='BSM';
      else if Lifestage_mod='S_1_ _U' then CAC_Lifestage='BSF';
      else if Lifestage_mod='S_1_ _' then CAC_Lifestage='BS';
      else if Lifestage_mod='M_1_Y_' then CAC_Lifestage='BP';
      else if Lifestage_mod='S_1_Y_U' then CAC_Lifestage='BSP';
      else if Lifestage_mod='S_1_ _F' then CAC_Lifestage='BSF';
      else if Lifestage_mod='S_1_Y_F' then CAC_Lifestage='BSP';
      else if Lifestage_mod='M_1_ _' then CAC_Lifestage='BP';
      else if Lifestage_mod='M_2_Y_' then CAC_Lifestage='YP';
      else if Lifestage_mod='S_2_ _F' then CAC_Lifestage='YSF';
      else if Lifestage_mod='S_2_ _M' then CAC_Lifestage='YSM';
      else if Lifestage_mod='S_2_ _U' then CAC_Lifestage='YS';
      else if Lifestage_mod='M_2_ _' then CAC_Lifestage='YC';
      else if Lifestage_mod='S_2_Y_F' then CAC_Lifestage='YSP';
      else if Lifestage_mod='S_2_ _X' then CAC_Lifestage='YS';
      else if Lifestage_mod='S_2_Y_M' then CAC_Lifestage='YSP';
      else if Lifestage_mod='M_3_Y_' then CAC_Lifestage='EP';
      else if Lifestage_mod='S_3_ _U' then CAC_Lifestage='ES';
      else if Lifestage_mod='M_3_ _' then CAC_Lifestage='EC';
      else if Lifestage_mod='S_3_ _F' then CAC_Lifestage='ESF';
      else if Lifestage_mod='S_3_ _M' then CAC_Lifestage='ESM';
      else if Lifestage_mod='S_3_Y_F' then CAC_Lifestage='ESP';
      else if Lifestage_mod='S_3_ _X' then CAC_Lifestage='ES';
      else if Lifestage_mod='S_3_Y_M' then CAC_Lifestage='ESP';
      else if Lifestage_mod='S_3_Y_U' then CAC_Lifestage='ESP';
      else if Lifestage_mod='M_4_ _' then CAC_Lifestage='SC';
      else if Lifestage_mod='M_4_Y_' then CAC_Lifestage='SF';
      else if Lifestage_mod='S_4_ _F' then CAC_Lifestage='SSF';
      else if Lifestage_mod='S_4_ _U' then CAC_Lifestage='SS';
      else if Lifestage_mod='S_4_ _M' then CAC_Lifestage='SSM';
      else if Lifestage_mod='S_4_Y_F' then CAC_Lifestage='SSP';
      else if Lifestage_mod='S_4_ _X' then CAC_Lifestage='SS';
      else if Lifestage_mod='S_4_Y_U' then CAC_Lifestage='SSP';
      else if Lifestage_mod='S_4_Y_M' then CAC_Lifestage='SSP';
      else if Lifestage_mod='M_5_ _' then CAC_Lifestage='EN';
      else if Lifestage_mod='S_5_ _F' then CAC_Lifestage='PRF';
      else if Lifestage_mod='S_5_ _M' then CAC_Lifestage='PRM';
      else if Lifestage_mod='M_5_Y_' then CAC_Lifestage='AEN';
      else if Lifestage_mod='S_5_ _U' then CAC_Lifestage='PRS';
      else if Lifestage_mod='S_5_ _X' then CAC_Lifestage='PRS';
      else if Lifestage_mod='S_5_Y_U' then CAC_Lifestage='AEN';
      else if Lifestage_mod='S_5_Y_F' then CAC_Lifestage='AEN';
      else if Lifestage_mod='S_5_Y_M' then CAC_Lifestage='AEN';
      else if Lifestage_mod='M_6_ _' then CAC_Lifestage='RC';
      else if Lifestage_mod='S_6_ _F' then CAC_Lifestage='RS';
      else if Lifestage_mod='S_6_ _U' then CAC_Lifestage='RS';
      else if Lifestage_mod='S_6_ _M' then CAC_Lifestage='RS';
      else if Lifestage_mod='M_6_Y_' then CAC_Lifestage='RC';
      else if Lifestage_mod='S_6_Y_M' then CAC_Lifestage='RS';
      else if Lifestage_mod='S_6_ _X' then CAC_Lifestage='RS';
      else if Lifestage_mod='S_6_Y_U' then CAC_Lifestage='RS';
      else if Lifestage_mod='S_7_ _X' then CAC_Lifestage='LS';
      else if Lifestage_mod='M_7_ _' then CAC_Lifestage='LC';
      else if Lifestage_mod='S_7_ _F' then CAC_Lifestage='LS';
      else if Lifestage_mod='S_7_ _M' then CAC_Lifestage='LS';
      else if Lifestage_mod='S_7_ _U' then CAC_Lifestage='LS';
      else if Lifestage_mod='M_7_Y_' then CAC_Lifestage='LC';
      else if Lifestage_mod='S_7_Y_F' then CAC_Lifestage='LS';
      else if Lifestage_mod='S_7_Y_U' then CAC_Lifestage='LS';
      if cac_lifestage ='BSM' then cac_lifestage_group=1;
      else if cac_lifestage ='BSF' then cac_lifestage_group=1;
      else if cac_lifestage ='BS' then cac_lifestage_group=1;
      else if cac_lifestage ='BP' then cac_lifestage_group=2;
      else if cac_lifestage ='BSP' then cac_lifestage_group=5;
      else if cac_lifestage ='YP' then cac_lifestage_group=2;
      else if cac_lifestage ='YSF' then cac_lifestage_group=1;
      else if cac_lifestage ='YSM' then cac_lifestage_group=1;
      else if cac_lifestage ='YS' then cac_lifestage_group=1;
      else if cac_lifestage ='YC' then cac_lifestage_group=3;
      else if cac_lifestage ='YSP' then cac_lifestage_group=4;
      else if cac_lifestage ='EP' then cac_lifestage_group=5;
      else if cac_lifestage ='ES' then cac_lifestage_group=6;
      else if cac_lifestage ='EC' then cac_lifestage_group=7;
      else if cac_lifestage ='ESF' then cac_lifestage_group=6;
      else if cac_lifestage ='ESM' then cac_lifestage_group=6;
      else if cac_lifestage ='ESP' then cac_lifestage_group=4;
      else if cac_lifestage ='SC' then cac_lifestage_group=8;
      else if cac_lifestage ='SF' then cac_lifestage_group=9;
      else if cac_lifestage ='SSF' then cac_lifestage_group=10;
      else if cac_lifestage ='SS' then cac_lifestage_group=10;
      else if cac_lifestage ='SSM' then cac_lifestage_group=10;
      else if cac_lifestage ='SSP' then cac_lifestage_group=11;
      else if cac_lifestage ='EN' then cac_lifestage_group=12;
      else if cac_lifestage ='PRF' then cac_lifestage_group=13;
      else if cac_lifestage ='PRM' then cac_lifestage_group=13;
      else if cac_lifestage ='AEN' then cac_lifestage_group=14;
      else if cac_lifestage ='PRS' then cac_lifestage_group=13;
      else if cac_lifestage ='RC' then cac_lifestage_group=15;
      else if cac_lifestage ='RS' then cac_lifestage_group=16;
      else if cac_lifestage ='LS' then cac_lifestage_group=17;
      else if cac_lifestage ='LC' then cac_lifestage_group=18;
      drop lifestage_raw gender numadults mar_q lifestage_mod age;
      *******************************************************;
      *** END SCORE LIFESTAGE 05_12_2012 ***;
      *******************************************************;
      *******************************************************;
      *** SCORE SOCIO_ECONOMIC 05_14_2012 ***;
      *******************************************************;
      monthly_inc=cac_demo_narrow_inc_num*1000/12;
      if cac_demo_narrow_inc_num<=50 then tax_rate=0;
      else if cac_demo_narrow_inc_num<=75 then tax_rate=.07;
      else if cac_demo_narrow_inc_num<=100 then tax_rate=.08;
      else if cac_demo_narrow_inc_num<=200 then tax_rate=.12;
      else if cac_demo_narrow_inc_num<=500 then tax_rate=.19;
      else tax_rate=0.25;
      if cac_home_own="1" or cac_home_own="2" then do;
         if monthly_inc>0 and cen_hserent_4>0 then do;
            monthly_disp_inc=monthly_inc-cen_hserent_4;
            monthly_disp_pct=monthly_disp_inc/monthly_inc;
            *** RULESETS ***;
            * 1: if rent is >75% of income, make 75% of income *;
            * 2: if disp_income <0, make 50% of income *;
            if cen_hserent_4/monthly_inc>0.75 then monthly_disp_inc=0.25 * monthly_inc;
            if monthly_disp_inc<0 then monthly_disp_inc=0.5*monthly_inc;
         end;
      end;
      else if cac_home_own="4" then do;
         acen_hsecost_21 = cen_hsecost_21/1000;
         * monthly costs as inc% with mortgage *;
         acen_hsecost_30 = cen_hsecost_30/1000;
         * monthly costs as inc% without mortgage *;
         if cac_home_mtg>0 then do;
            *** -0.536821623% is based on 30-year at 5% ***;
            ** 15% deflation of census **;
            *** cen_hsecost_30 - non-mortgage costs avg ***;
            mort_pay=cac_home_mtg*1000*(0.00536821623);
            if acen_hsecost_21>0 then monthly_cost=mort_pay+(monthly_inc*(acen_hsecost_30*0.85));
            *add non-mortgage monthly costs *;
            else monthly_cost=mort_pay+(monthly_inc*0.12);
            ** lower than national average of 13.9% **;
            if monthly_disp_inc/monthly_inc<0.25 then monthly_disp_inc=0.25*monthly_inc;
            group=1;
         end;
         else if cac_demo_age_enh<=5 then do;
            *** IF NOT KNOWN TO HAVE A MORTGAGE, ASSUME MORTGAGE IF < AGE 65 ***;
            *** AND USE CENSUS CEN_HSECOST_14 ***;
            if cen_hsecost_14>0 then monthly_cost=CEN_HSECOST_14*0.85;
            else monthly_cost=monthly_inc*0.12;
            if monthly_disp_inc/monthly_inc>0.75 then monthly_disp_inc=0.75;
            group=2;
         end;
      else do;
         if acen_hsecost_30>0 then monthly_cost=monthly_inc*acen_hsecost_30;
         else monthly_cost=monthly_inc*0.12;
         group=3;
         end;
         monthly_disp_inc=monthly_inc-monthly_cost;
         if monthly_disp_inc<0 then monthly_disp_inc=.;
      end;
      monthly_disp_pct=monthly_disp_inc/monthly_inc;
      length mastvar1 $ 9;
      substr(mastvar1,1,1)=put(cac_home_own,1.);
      substr(mastvar1,2,1)="_";
      substr(mastvar1,3,1)=put(cac_demo_age_enh,1.);
      substr(mastvar1,4,1)="_";
      substr(mastvar1,5,5)=put(cac_demo_narrow_inc_num,z5.1);
      length mastvar2 $ 7;
      substr(mastvar2,1,1)=put(cac_demo_age_enh,1.);
      substr(mastvar2,2,1)="_";
      substr(mastvar2,3,5)=put(cac_demo_narrow_inc_num,z5.1);
      if monthly_disp_inc ne . then fin_group=1;
      else do;
         tj=put(mastvar1,$mast1f.);
          if 0<=tj<=1 then monthly_disp_pct=tj;
          if monthly_disp_pct ne . then fin_group=2;
          else do;
             tj=put(mastvar2,$mast2f.);
             if 0<=tj<=1 then monthly_disp_pct=tj;
             if monthly_disp_pct ne . then fin_group=3;
          end;
          if monthly_disp_inc =. then monthly_disp_inc=monthly_inc*monthly_disp_pct;
      end;
      if monthly_disp_inc/monthly_inc<0.25 then monthly_disp_inc=0.25*monthly_inc;
      cac_demo_monthly_disp_inc_at_num=monthly_disp_inc-(tax_rate*monthly_inc);
      cac_demo_monthly_inc=monthly_inc;
      cac_demo_monthly_disp_inc_num=monthly_disp_inc;
      if 0<=(12*cac_demo_monthly_disp_inc_num)<=14999 then cac_demo_monthly_disp_inc=1;
      else if 15000<=(12*cac_demo_monthly_disp_inc_num)<=19999 then cac_demo_monthly_disp_inc=2;
      else if 20000<=(12*cac_demo_monthly_disp_inc_num)<=24999 then cac_demo_monthly_disp_inc=3;
      else if 25000<=(12*cac_demo_monthly_disp_inc_num)<=29999 then cac_demo_monthly_disp_inc=4;
      else if 30000<=(12*cac_demo_monthly_disp_inc_num)<=34999 then cac_demo_monthly_disp_inc=5;
      else if 35000<=(12*cac_demo_monthly_disp_inc_num)<=39999 then cac_demo_monthly_disp_inc=6;
      else if 40000<=(12*cac_demo_monthly_disp_inc_num)<=44999 then cac_demo_monthly_disp_inc=7;
      else if 45000<=(12*cac_demo_monthly_disp_inc_num)<=49999 then cac_demo_monthly_disp_inc=8;
      else if 50000<=(12*cac_demo_monthly_disp_inc_num)<=54999 then cac_demo_monthly_disp_inc=9;
      else if 55000<=(12*cac_demo_monthly_disp_inc_num)<=59999 then cac_demo_monthly_disp_inc=10;
      else if 60000<=(12*cac_demo_monthly_disp_inc_num)<=64999 then cac_demo_monthly_disp_inc=11;
      else if 65000<=(12*cac_demo_monthly_disp_inc_num)<=69999 then cac_demo_monthly_disp_inc=12;
      else if 70000<=(12*cac_demo_monthly_disp_inc_num)<=74999 then cac_demo_monthly_disp_inc=13;
      else if 75000<=(12*cac_demo_monthly_disp_inc_num)<=79999 then cac_demo_monthly_disp_inc=14;
      else if 80000<=(12*cac_demo_monthly_disp_inc_num)<=84999 then cac_demo_monthly_disp_inc=15;
      else if 85000<=(12*cac_demo_monthly_disp_inc_num)<=89999 then cac_demo_monthly_disp_inc=16;
      else if 90000<=(12*cac_demo_monthly_disp_inc_num)<=94999 then cac_demo_monthly_disp_inc=17;
      else if 95000<=(12*cac_demo_monthly_disp_inc_num)<=99999 then cac_demo_monthly_disp_inc=18;
      else if 100000<=(12*cac_demo_monthly_disp_inc_num)<=104999 then cac_demo_monthly_disp_inc=19;
      else if 105000<=(12*cac_demo_monthly_disp_inc_num)<=109999 then cac_demo_monthly_disp_inc=20;
      else if 110000<=(12*cac_demo_monthly_disp_inc_num)<=114999 then cac_demo_monthly_disp_inc=21;
      else if 115000<=(12*cac_demo_monthly_disp_inc_num)<=119999 then cac_demo_monthly_disp_inc=22;
      else if 120000<=(12*cac_demo_monthly_disp_inc_num)<=124999 then cac_demo_monthly_disp_inc=23;
      else if 125000<=(12*cac_demo_monthly_disp_inc_num)<=129999 then cac_demo_monthly_disp_inc=24;
      else if 130000<=(12*cac_demo_monthly_disp_inc_num)<=134999 then cac_demo_monthly_disp_inc=25;
      else if 135000<=(12*cac_demo_monthly_disp_inc_num)<=139999 then cac_demo_monthly_disp_inc=26;
      else if 140000<=(12*cac_demo_monthly_disp_inc_num)<=144999 then cac_demo_monthly_disp_inc=27;
      else if 145000<=(12*cac_demo_monthly_disp_inc_num)<=149999 then cac_demo_monthly_disp_inc=28;
      else if 150000<=(12*cac_demo_monthly_disp_inc_num)<=159999 then cac_demo_monthly_disp_inc=29;
      else if 160000<=(12*cac_demo_monthly_disp_inc_num)<=169999 then cac_demo_monthly_disp_inc=30;
      else if 170000<=(12*cac_demo_monthly_disp_inc_num)<=174999 then cac_demo_monthly_disp_inc=31;
      else if 175000<=(12*cac_demo_monthly_disp_inc_num)<=189999 then cac_demo_monthly_disp_inc=32;
      else if 190000<=(12*cac_demo_monthly_disp_inc_num)<=199999 then cac_demo_monthly_disp_inc=33;
      else if 200000<=(12*cac_demo_monthly_disp_inc_num)<=224999 then cac_demo_monthly_disp_inc=34;
      else if 225000<=(12*cac_demo_monthly_disp_inc_num)<=249999 then cac_demo_monthly_disp_inc=35;
      else if 250000<=(12*cac_demo_monthly_disp_inc_num)<=9999999 then cac_demo_monthly_disp_inc=36;
      if 0<=(12*cac_demo_monthly_disp_inc_at_num)<=14999 then cac_demo_monthly_disp_inc_at=1;
      else if 15000<=(12*cac_demo_monthly_disp_inc_at_num)<=19999 then cac_demo_monthly_disp_inc_at=2;
      else if 20000<=(12*cac_demo_monthly_disp_inc_at_num)<=24999 then cac_demo_monthly_disp_inc_at=3;
      else if 25000<=(12*cac_demo_monthly_disp_inc_at_num)<=29999 then cac_demo_monthly_disp_inc_at=4;
      else if 30000<=(12*cac_demo_monthly_disp_inc_at_num)<=34999 then cac_demo_monthly_disp_inc_at=5;
      else if 35000<=(12*cac_demo_monthly_disp_inc_at_num)<=39999 then cac_demo_monthly_disp_inc_at=6;
      else if 40000<=(12*cac_demo_monthly_disp_inc_at_num)<=44999 then cac_demo_monthly_disp_inc_at=7;
      else if 45000<=(12*cac_demo_monthly_disp_inc_at_num)<=49999 then cac_demo_monthly_disp_inc_at=8;
      else if 50000<=(12*cac_demo_monthly_disp_inc_at_num)<=54999 then cac_demo_monthly_disp_inc_at=9;
      else if 55000<=(12*cac_demo_monthly_disp_inc_at_num)<=59999 then cac_demo_monthly_disp_inc_at=10;
      else if 60000<=(12*cac_demo_monthly_disp_inc_at_num)<=64999 then cac_demo_monthly_disp_inc_at=11;
      else if 65000<=(12*cac_demo_monthly_disp_inc_at_num)<=69999 then cac_demo_monthly_disp_inc_at=12;
      else if 70000<=(12*cac_demo_monthly_disp_inc_at_num)<=74999 then cac_demo_monthly_disp_inc_at=13;
      else if 75000<=(12*cac_demo_monthly_disp_inc_at_num)<=79999 then cac_demo_monthly_disp_inc_at=14;
      else if 80000<=(12*cac_demo_monthly_disp_inc_at_num)<=84999 then cac_demo_monthly_disp_inc_at=15;
      else if 85000<=(12*cac_demo_monthly_disp_inc_at_num)<=89999 then cac_demo_monthly_disp_inc_at=16;
      else if 90000<=(12*cac_demo_monthly_disp_inc_at_num)<=94999 then cac_demo_monthly_disp_inc_at=17;
      else if 95000<=(12*cac_demo_monthly_disp_inc_at_num)<=99999 then cac_demo_monthly_disp_inc_at=18;
      else if 100000<=(12*cac_demo_monthly_disp_inc_at_num)<=104999 then cac_demo_monthly_disp_inc_at=19;
      else if 105000<=(12*cac_demo_monthly_disp_inc_at_num)<=109999 then cac_demo_monthly_disp_inc_at=20;
      else if 110000<=(12*cac_demo_monthly_disp_inc_at_num)<=114999 then cac_demo_monthly_disp_inc_at=21;
      else if 115000<=(12*cac_demo_monthly_disp_inc_at_num)<=119999 then cac_demo_monthly_disp_inc_at=22;
      else if 120000<=(12*cac_demo_monthly_disp_inc_at_num)<=124999 then cac_demo_monthly_disp_inc_at=23;
      else if 125000<=(12*cac_demo_monthly_disp_inc_at_num)<=129999 then cac_demo_monthly_disp_inc_at=24;
      else if 130000<=(12*cac_demo_monthly_disp_inc_at_num)<=134999 then cac_demo_monthly_disp_inc_at=25;
      else if 135000<=(12*cac_demo_monthly_disp_inc_at_num)<=139999 then cac_demo_monthly_disp_inc_at=26;
      else if 140000<=(12*cac_demo_monthly_disp_inc_at_num)<=144999 then cac_demo_monthly_disp_inc_at=27;
      else if 145000<=(12*cac_demo_monthly_disp_inc_at_num)<=149999 then cac_demo_monthly_disp_inc_at=28;
      else if 150000<=(12*cac_demo_monthly_disp_inc_at_num)<=159999 then cac_demo_monthly_disp_inc_at=29;
      else if 160000<=(12*cac_demo_monthly_disp_inc_at_num)<=169999 then cac_demo_monthly_disp_inc_at=30;
      else if 170000<=(12*cac_demo_monthly_disp_inc_at_num)<=174999 then cac_demo_monthly_disp_inc_at=31;
      else if 175000<=(12*cac_demo_monthly_disp_inc_at_num)<=189999 then cac_demo_monthly_disp_inc_at=32;
      else if 190000<=(12*cac_demo_monthly_disp_inc_at_num)<=199999 then cac_demo_monthly_disp_inc_at=33;
      else if 200000<=(12*cac_demo_monthly_disp_inc_at_num)<=224999 then cac_demo_monthly_disp_inc_at=34;
      else if 225000<=(12*cac_demo_monthly_disp_inc_at_num)<=249999 then cac_demo_monthly_disp_inc_at=35;
      else if 250000<=(12*cac_demo_monthly_disp_inc_at_num)<=9999999 then cac_demo_monthly_disp_inc_at=36;
      cac_silh_socio_econ=cac_demo_monthly_disp_inc_at;
      if cac_silh_socio_econ>=29 then cac_silh_socio_group=9;
      else if cac_silh_socio_econ>=24 then cac_silh_socio_group=8;
      else if cac_silh_socio_econ>=19 then cac_silh_socio_group=7;
      else if cac_silh_socio_econ>=14 then cac_silh_socio_group=6;
      else if cac_silh_socio_econ>=9 then cac_silh_socio_group=5;
      else if cac_silh_socio_econ>=7 then cac_silh_socio_group=4;
      else if cac_silh_socio_econ>=5 then cac_silh_socio_group=3;
      else if cac_silh_socio_econ>=2 then cac_silh_socio_group=2;
      else if cac_silh_socio_econ>=1 then cac_silh_socio_group=1;
      If cac_home_own=4 then cac_silh_socio_group=cac_silh_socio_group+10;
      if cac_silh_socio_group in (8 9) then cac_silh_socio_group=7;

      drop fin_group tj mastvar1 mastvar2 monthly_disp_inc group tax_rate monthly_disp_pct acen_: mort_pay cac_demo_monthly_disp:;
      *******************************************************;
      *** END SCORE SOCIO_ECONOMIC 05_14_2012 ***;
      *******************************************************;
      *******************************************************;
      *** SCORE LIFESTYLE CJ 1PCT 05_12_2012 ***;
      *******************************************************;
      int_84 = max(of CAC_INT_4 CAC_INT_56);
      cac_int_133 = max(of CAC_INT_49 CAC_INT_58);
      cac_int_136 = max(of CAC_INT_113 CAC_INT_38);
      cac_int_137 = max(of CAC_INT_85 CAC_INT_87 CAC_INT_88 CAC_INT_86);
      cac_int_141 = max(of CAC_INT_24 CAC_INT_52);
      cac_int_143 = max(of CAC_INT_23 CAC_INT_51 CAC_INT_29);
      int_122 = 0;
      *Where did Tennis go?;
 

      FACTOR1 =  ((cac_int_1 - 0.389493072)/7.08786989)*0.102421539+ ((cac_int_70 - 0.106765272)/4.4886772)*-0.08479169+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*-0.05150399+ ((cac_int_80 - 0.168759982)/5.44400514)*-0.00418044+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*-0.0882942+ ((cac_int_76 - 0.06883226)/3.67985362)*-0.13790367+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*0.024029312+ ((cac_int_78 - 0.132180265)/4.92287309)*0.051379152+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*0.027149782+ ((cac_int_46 - 0.216440409)/5.98584901)*-0.02440465+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*-0.05904437+ ((cac_int_26 - 0.403502844)/7.13096095)*-0.03488583+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*0.005998542+ ((cac_int_28 - 0.552858324)/7.22686715)*0.034692401+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*-0.06728802+ ((cac_int_34 - 0.066279209)/3.61591108)*-0.07124483+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*0.081720065+ ((cac_int_41 - 0.164022888)/5.3823259)*-0.0742636+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*-0.12571285+ ((cac_int_42 - 0.122584465)/4.76695384)*-0.04456988+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*-0.0163178+ ((cac_int_19 - 0.272773581)/6.47375927)*-0.02660403+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*-0.04074491+ ((cac_int_98 - 0.464987843)/7.24975273)*0.031321841+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*-0.06610169+ ((cac_int_100 - 0.704329822)/6.63303623)*-0.06265914+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*0.002220863+ ((cac_int_102 - 0.135061733)/4.96797365)*0.052702668+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*-0.08057851+ ((cac_int_104 - 0.21816945)/6.0030762)*0.019240989+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*-0.0500408+ ((cac_int_107 - 0.110066927)/4.54912283)*0.006219486+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*-0.01382062+ ((cac_int_109 - 0.486272839)/7.26485315)*0.285024323+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*0.240378793+ ((cac_int_44 - 0.142164325)/5.07595701)*0.282603211+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*-0.09030269+ ((cac_int_3 - 0.319066058)/6.77506341)*0.145005529+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*-0.04954982+ ((cac_int_36 - 0.063761936)/3.55135807)*-0.04432549+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*-0.06263451+ ((cac_int_62 - 0.115761997)/4.650377)*0.079171352+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*0.001395864+ ((cac_int_60 - 0.111746232)/4.57936798)*-0.03538211+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*-0.08673486+ ((cac_int_65 - 0.071961444)/3.75624155)*-0.08188507+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*0.205901211+ ((cac_int_114 - 0.119576572)/4.7161696)*0.052888555+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*0.064404808+ ((cac_int_13 - 0.282988351)/6.54738614)*0.171646763+
                 ((cac_int_116 - 0.035083472)/2.67434065)*0.02910553+ ((cac_int_43 - 0.156240519)/5.27748174)*0.004613111+
                 ((cac_int_118 - 0.229368989)/6.1109842)*0.02574168+ ((cac_int_31 - 0.142147159)/5.07570132)*-0.02257865+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*-0.02015982+ ((cac_int_32 - 0.389978397)/7.08946483)*0.066913085+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*-0.0937534+ ((cac_int_68 - 0.080678364)/3.95852008)*-0.03395606+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*-0.05421552+ ((cac_int_133 - 0.592181532)/7.14301305)*0.036375013+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*0.020763651+ ((cac_int_37 - 0.219569432)/6.01691179)*-0.0199367+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*-0.01158408+ ((cac_int_137 - 0.248972434)/6.28527293)*-0.01633417+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*-0.13777985+ ((cac_int_12 - 0.658468442)/6.89292371)*0.20994211+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*-0.12748692+ ((cac_int_141 - 0.19344787)/5.74141272)*-0.07441051+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*-0.00898231+ ((cac_int_143 - 0.176853601)/5.54582377)*0.126052036;
      FACTOR2 =  ((cac_int_1 - 0.389493072)/7.08786989)*0.101512225+ ((cac_int_70 - 0.106765272)/4.4886772)*0.033045499+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*-0.07026706+ ((cac_int_80 - 0.168759982)/5.44400514)*-0.04009752+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*-0.07452036+ ((cac_int_76 - 0.06883226)/3.67985362)*0.109976821+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*-0.20191543+ ((cac_int_78 - 0.132180265)/4.92287309)*-0.02710523+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*-0.06555596+ ((cac_int_46 - 0.216440409)/5.98584901)*0.103820579+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*-0.06287486+ ((cac_int_26 - 0.403502844)/7.13096095)*0.071458029+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*-0.06272214+ ((cac_int_28 - 0.552858324)/7.22686715)*-0.03311663+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*-0.00690588+ ((cac_int_34 - 0.066279209)/3.61591108)*-0.00938642+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*-0.08752937+ ((cac_int_41 - 0.164022888)/5.3823259)*-0.02705484+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*0.025711776+ ((cac_int_42 - 0.122584465)/4.76695384)*-0.03646744+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*-0.07872846+ ((cac_int_19 - 0.272773581)/6.47375927)*-0.04003852+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*-0.06022305+ ((cac_int_98 - 0.464987843)/7.24975273)*0.008906706+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*-0.02026342+ ((cac_int_100 - 0.704329822)/6.63303623)*-0.0320239+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*-0.01712499+ ((cac_int_102 - 0.135061733)/4.96797365)*-0.05553384+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*-0.03260034+ ((cac_int_104 - 0.21816945)/6.0030762)*0.167848444+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*-0.02386945+ ((cac_int_107 - 0.110066927)/4.54912283)*0.056842116+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*0.202199944+ ((cac_int_109 - 0.486272839)/7.26485315)*0.030158651+
                 ((cac_int_30 - 0.298722672)/6.65272485)*0.040463504+ ((cac_int_44 - 0.142164325)/5.07595701)*-0.1893085+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*0.270287075+ ((cac_int_3 - 0.319066058)/6.77506341)*-0.12650828+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*-0.07319757+ ((cac_int_36 - 0.063761936)/3.55135807)*0.025808895+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*-0.07438579+ ((cac_int_62 - 0.115761997)/4.650377)*-0.1177029+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*-0.01859173+ ((cac_int_60 - 0.111746232)/4.57936798)*0.159616345+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*0.339846194+ ((cac_int_65 - 0.071961444)/3.75624155)*-0.08099437+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*-0.02168779+ ((cac_int_114 - 0.119576572)/4.7161696)*0.157648071+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*0.046235902+ ((cac_int_13 - 0.282988351)/6.54738614)*-0.00787474+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*-0.04757791+ ((cac_int_43 - 0.156240519)/5.27748174)*0.109843955+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*0.089822989+ ((cac_int_31 - 0.142147159)/5.07570132)*-0.04680166+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*-0.03824564+ ((cac_int_32 - 0.389978397)/7.08946483)*0.013034639+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*-0.03885945+ ((cac_int_68 - 0.080678364)/3.95852008)*0.137257716+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*-0.00330385+ ((cac_int_133 - 0.592181532)/7.14301305)*0.0870497+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*-0.01541909+ ((cac_int_37 - 0.219569432)/6.01691179)*0.064221575+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*-0.03913399+ ((cac_int_137 - 0.248972434)/6.28527293)*0.06561001+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*0.007755959+ ((cac_int_12 - 0.658468442)/6.89292371)*0.073046502+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*-0.03243797+ ((cac_int_141 - 0.19344787)/5.74141272)*0.065213647+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*-0.02347257+ ((cac_int_143 - 0.176853601)/5.54582377)*-0.14820088;
      FACTOR3 =  ((cac_int_1 - 0.389493072)/7.08786989)*-0.05006765+ ((cac_int_70 - 0.106765272)/4.4886772)*-0.02347154+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*-0.00519906+ ((cac_int_80 - 0.168759982)/5.44400514)*-0.00508538+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*-0.042685+ ((cac_int_76 - 0.06883226)/3.67985362)*-0.08426318+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*0.020106753+ ((cac_int_78 - 0.132180265)/4.92287309)*-0.05320284+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*-0.01047233+ ((cac_int_46 - 0.216440409)/5.98584901)*0.057888655+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*-0.02175166+ ((cac_int_26 - 0.403502844)/7.13096095)*-0.05076205+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*0.003338718+ ((cac_int_28 - 0.552858324)/7.22686715)*-0.01894981+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*-0.01561335+ ((cac_int_34 - 0.066279209)/3.61591108)*-0.02306164+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*0.005921793+ ((cac_int_41 - 0.164022888)/5.3823259)*0.006426884+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*0.039755219+ ((cac_int_42 - 0.122584465)/4.76695384)*-0.01627678+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*0.030181039+ ((cac_int_19 - 0.272773581)/6.47375927)*-0.02086066+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*-0.01886623+ ((cac_int_98 - 0.464987843)/7.24975273)*-0.01963987+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*0.018087615+ ((cac_int_100 - 0.704329822)/6.63303623)*-0.00293891+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*-0.02608272+ ((cac_int_102 - 0.135061733)/4.96797365)*0.021462782+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*-0.0454414+ ((cac_int_104 - 0.21816945)/6.0030762)*-0.0250067+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*-0.08539777+ ((cac_int_107 - 0.110066927)/4.54912283)*-0.06335126+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*-0.08178455+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.06064799+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.02646394+ ((cac_int_44 - 0.142164325)/5.07595701)*0.044915588+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*-0.07365339+ ((cac_int_3 - 0.319066058)/6.77506341)*0.022678025+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*0.386491864+ ((cac_int_36 - 0.063761936)/3.55135807)*0.387592376+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*0.415373799+ ((cac_int_62 - 0.115761997)/4.650377)*0.275012386+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*-0.05050535+ ((cac_int_60 - 0.111746232)/4.57936798)*0.178559527+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*-0.01546949+ ((cac_int_65 - 0.071961444)/3.75624155)*0.12907121+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*-0.06061877+ ((cac_int_114 - 0.119576572)/4.7161696)*-0.03267346+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*-0.02700138+ ((cac_int_13 - 0.282988351)/6.54738614)*-0.00134057+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*-0.0792103+ ((cac_int_43 - 0.156240519)/5.27748174)*0.001415179+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*0.031451367+ ((cac_int_31 - 0.142147159)/5.07570132)*0.002967038+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*0.080387288+ ((cac_int_32 - 0.389978397)/7.08946483)*0.000138969+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*0.030082864+ ((cac_int_68 - 0.080678364)/3.95852008)*-0.00311822+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*-0.02952078+ ((cac_int_133 - 0.592181532)/7.14301305)*-0.06749533+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*-0.01982595+ ((cac_int_37 - 0.219569432)/6.01691179)*-0.02367541+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*-0.00321364+ ((cac_int_137 - 0.248972434)/6.28527293)*-0.03478713+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*0.02440207+ ((cac_int_12 - 0.658468442)/6.89292371)*-0.08212854+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*0.023755343+ ((cac_int_141 - 0.19344787)/5.74141272)*-0.05688004+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*0.041426023+ ((cac_int_143 - 0.176853601)/5.54582377)*0.097606755;
      FACTOR4 =  ((cac_int_1 - 0.389493072)/7.08786989)*-0.03030023+ ((cac_int_70 - 0.106765272)/4.4886772)*0.01972541+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*0.072109904+ ((cac_int_80 - 0.168759982)/5.44400514)*0.005475804+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*0.059424777+ ((cac_int_76 - 0.06883226)/3.67985362)*0.163056793+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*-0.1299436+ ((cac_int_78 - 0.132180265)/4.92287309)*-0.05145848+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*-0.08854569+ ((cac_int_46 - 0.216440409)/5.98584901)*0.040041057+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*0.068839411+ ((cac_int_26 - 0.403502844)/7.13096095)*-0.04164198+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*0.161111288+ ((cac_int_28 - 0.552858324)/7.22686715)*0.116779182+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*0.362482147+ ((cac_int_34 - 0.066279209)/3.61591108)*0.07551573+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*0.000239646+ ((cac_int_41 - 0.164022888)/5.3823259)*-0.01925502+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*-0.01105705+ ((cac_int_42 - 0.122584465)/4.76695384)*0.320620443+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*-0.07372672+ ((cac_int_19 - 0.272773581)/6.47375927)*-0.07645115+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*-0.05500516+ ((cac_int_98 - 0.464987843)/7.24975273)*-0.13801155+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*0.079312128+ ((cac_int_100 - 0.704329822)/6.63303623)*-0.10709302+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*-0.05576586+ ((cac_int_102 - 0.135061733)/4.96797365)*-0.07747629+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*0.044528404+ ((cac_int_104 - 0.21816945)/6.0030762)*-0.09368617+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*0.009510338+ ((cac_int_107 - 0.110066927)/4.54912283)*-0.04974799+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*-0.03958761+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.03176567+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.0348867+ ((cac_int_44 - 0.142164325)/5.07595701)*0.019942817+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*0.021964082+ ((cac_int_3 - 0.319066058)/6.77506341)*-0.09895551+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*-0.01391685+ ((cac_int_36 - 0.063761936)/3.55135807)*0.009454544+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*0.057038343+ ((cac_int_62 - 0.115761997)/4.650377)*-0.10062514+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*-0.03103475+ ((cac_int_60 - 0.111746232)/4.57936798)*-0.04945602+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*-0.00585584+ ((cac_int_65 - 0.071961444)/3.75624155)*0.016331855+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*-0.03763757+ ((cac_int_114 - 0.119576572)/4.7161696)*-0.10144426+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*-0.05988221+ ((cac_int_13 - 0.282988351)/6.54738614)*-0.04067297+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*0.020229708+ ((cac_int_43 - 0.156240519)/5.27748174)*0.143059017+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*0.181928034+ ((cac_int_31 - 0.142147159)/5.07570132)*0.319697666+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*0.01865774+ ((cac_int_32 - 0.389978397)/7.08946483)*0.160582738+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*0.038149479+ ((cac_int_68 - 0.080678364)/3.95852008)*0.010195893+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*-0.01490625+ ((cac_int_133 - 0.592181532)/7.14301305)*0.128738168+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*-0.03815493+ ((cac_int_37 - 0.219569432)/6.01691179)*0.034820056+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*-0.05721351+ ((cac_int_137 - 0.248972434)/6.28527293)*-0.08110007+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*0.000207767+ ((cac_int_12 - 0.658468442)/6.89292371)*-0.03274388+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*0.038211015+ ((cac_int_141 - 0.19344787)/5.74141272)*-0.00843232+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*-0.09047854+ ((cac_int_143 - 0.176853601)/5.54582377)*0.019619158;
      FACTOR5 =  ((cac_int_1 - 0.389493072)/7.08786989)*-0.02766774+ ((cac_int_70 - 0.106765272)/4.4886772)*-0.00676004+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*-0.03948487+ ((cac_int_80 - 0.168759982)/5.44400514)*0.123262683+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*-0.00645417+ ((cac_int_76 - 0.06883226)/3.67985362)*-0.01150358+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*0.027203703+ ((cac_int_78 - 0.132180265)/4.92287309)*-0.00047504+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*-0.12503576+ ((cac_int_46 - 0.216440409)/5.98584901)*-0.01473149+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*-0.04232961+ ((cac_int_26 - 0.403502844)/7.13096095)*0.005577795+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*-0.06153859+ ((cac_int_28 - 0.552858324)/7.22686715)*0.045081411+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*-0.06203812+ ((cac_int_34 - 0.066279209)/3.61591108)*-0.07123317+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*0.010225464+ ((cac_int_41 - 0.164022888)/5.3823259)*-0.03401992+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*0.025393617+ ((cac_int_42 - 0.122584465)/4.76695384)*-0.02926301+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*-0.0085551+ ((cac_int_19 - 0.272773581)/6.47375927)*-0.03247284+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*-0.02682454+ ((cac_int_98 - 0.464987843)/7.24975273)*0.017494533+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*0.023527165+ ((cac_int_100 - 0.704329822)/6.63303623)*-0.01704452+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*-0.04821557+ ((cac_int_102 - 0.135061733)/4.96797365)*0.010585167+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*-0.04426839+ ((cac_int_104 - 0.21816945)/6.0030762)*0.016167961+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*-0.0155581+ ((cac_int_107 - 0.110066927)/4.54912283)*0.029997045+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*-0.02635669+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.0336027+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.04097168+ ((cac_int_44 - 0.142164325)/5.07595701)*-0.01924185+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*-0.04085721+ ((cac_int_3 - 0.319066058)/6.77506341)*0.032060812+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*-0.0105437+ ((cac_int_36 - 0.063761936)/3.55135807)*-0.01686025+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*-0.02292404+ ((cac_int_62 - 0.115761997)/4.650377)*-0.00515719+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*-0.0152415+ ((cac_int_60 - 0.111746232)/4.57936798)*0.009399418+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*-0.04054059+ ((cac_int_65 - 0.071961444)/3.75624155)*0.00778142+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*-0.04597528+ ((cac_int_114 - 0.119576572)/4.7161696)*-0.04087994+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*-0.12970592+ ((cac_int_13 - 0.282988351)/6.54738614)*-0.03756119+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*0.036492601+ ((cac_int_43 - 0.156240519)/5.27748174)*0.099540614+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*0.05606449+ ((cac_int_31 - 0.142147159)/5.07570132)*0.01487647+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*0.153816132+ ((cac_int_32 - 0.389978397)/7.08946483)*-0.01157335+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*0.010527647+ ((cac_int_68 - 0.080678364)/3.95852008)*-0.01475797+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*0.261598858+ ((cac_int_133 - 0.592181532)/7.14301305)*-0.00661939+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*0.408675649+ ((cac_int_37 - 0.219569432)/6.01691179)*0.065518364+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*0.451409422+ ((cac_int_137 - 0.248972434)/6.28527293)*-0.0202947+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*0.08319234+ ((cac_int_12 - 0.658468442)/6.89292371)*-0.00561618+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*0.27681144+ ((cac_int_141 - 0.19344787)/5.74141272)*-0.02039774+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*-0.02521569+ ((cac_int_143 - 0.176853601)/5.54582377)*-0.01573099;
      FACTOR6 =  ((cac_int_1 - 0.389493072)/7.08786989)*-0.01356781+ ((cac_int_70 - 0.106765272)/4.4886772)*0.009553511+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*-0.01584343+ ((cac_int_80 - 0.168759982)/5.44400514)*0.020287522+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*-0.01463154+ ((cac_int_76 - 0.06883226)/3.67985362)*-0.0088596+
                 ((cac_int_77 - 0.055172724)/3.31863121)*-0.00447879+ ((cac_int_78 - 0.132180265)/4.92287309)*0.004292156+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*0.011487993+ ((cac_int_46 - 0.216440409)/5.98584901)*-0.0255649+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*0.006803495+ ((cac_int_26 - 0.403502844)/7.13096095)*0.11563542+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*0.011282616+ ((cac_int_28 - 0.552858324)/7.22686715)*0.168782829+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*0.001900334+ ((cac_int_34 - 0.066279209)/3.61591108)*-0.01810303+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*-0.01460002+ ((cac_int_41 - 0.164022888)/5.3823259)*-0.064468+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*-0.026933+ ((cac_int_42 - 0.122584465)/4.76695384)*-0.04019578+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*-0.07445273+ ((cac_int_19 - 0.272773581)/6.47375927)*0.011030632+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*-0.00414036+ ((cac_int_98 - 0.464987843)/7.24975273)*0.38505067+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*0.329637251+ ((cac_int_100 - 0.704329822)/6.63303623)*0.366745378+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*0.025876559+ ((cac_int_102 - 0.135061733)/4.96797365)*-0.00519581+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*-0.03083802+ ((cac_int_104 - 0.21816945)/6.0030762)*-0.01823104+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*-0.00390823+ ((cac_int_107 - 0.110066927)/4.54912283)*0.018483391+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*-0.01411269+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.0205728+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.02628562+ ((cac_int_44 - 0.142164325)/5.07595701)*-0.03064001+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*-0.01263017+ ((cac_int_3 - 0.319066058)/6.77506341)*0.037759917+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*-0.03211243+ ((cac_int_36 - 0.063761936)/3.55135807)*0.007907409+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*-0.02996912+ ((cac_int_62 - 0.115761997)/4.650377)*0.013146978+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*0.01041972+ ((cac_int_60 - 0.111746232)/4.57936798)*0.02212805+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*-0.00125591+ ((cac_int_65 - 0.071961444)/3.75624155)*-0.00152437+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*0.071598557+ ((cac_int_114 - 0.119576572)/4.7161696)*0.013089412+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*0.02675512+ ((cac_int_13 - 0.282988351)/6.54738614)*-0.03393417+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*0.032477872+ ((cac_int_43 - 0.156240519)/5.27748174)*-0.01373336+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*-0.00005194+ ((cac_int_31 - 0.142147159)/5.07570132)*-0.06307014+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*0.064002448+ ((cac_int_32 - 0.389978397)/7.08946483)*-0.02048689+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*-0.00449856+ ((cac_int_68 - 0.080678364)/3.95852008)*0.019453232+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*-0.02077351+ ((cac_int_133 - 0.592181532)/7.14301305)*0.187262114+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*-0.01149248+ ((cac_int_37 - 0.219569432)/6.01691179)*0.021325137+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*0.030016557+ ((cac_int_137 - 0.248972434)/6.28527293)*-0.01007652+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*0.014158862+ ((cac_int_12 - 0.658468442)/6.89292371)*-0.05938104+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*0.029801953+ ((cac_int_141 - 0.19344787)/5.74141272)*-0.06786115+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*-0.02262292+ ((cac_int_143 - 0.176853601)/5.54582377)*-0.04026023;
      FACTOR7 =  ((cac_int_1 - 0.389493072)/7.08786989)*-0.03314531+ ((cac_int_70 - 0.106765272)/4.4886772)*0.113190908+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*-0.04243926+ ((cac_int_80 - 0.168759982)/5.44400514)*-0.04736808+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*0.415744038+ ((cac_int_76 - 0.06883226)/3.67985362)*0.352385762+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*-0.10486543+ ((cac_int_78 - 0.132180265)/4.92287309)*0.021594229+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*-0.04130191+ ((cac_int_46 - 0.216440409)/5.98584901)*0.051116411+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*0.028057512+ ((cac_int_26 - 0.403502844)/7.13096095)*-0.04050739+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*-0.00921506+ ((cac_int_28 - 0.552858324)/7.22686715)*-0.0090161+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*0.067195807+ ((cac_int_34 - 0.066279209)/3.61591108)*0.051520865+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*-0.0797076+ ((cac_int_41 - 0.164022888)/5.3823259)*-0.00257489+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*0.080834901+ ((cac_int_42 - 0.122584465)/4.76695384)*0.01020579+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*-0.1138512+ ((cac_int_19 - 0.272773581)/6.47375927)*-0.01635879+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*-0.02059052+ ((cac_int_98 - 0.464987843)/7.24975273)*-0.02477132+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*0.003015802+ ((cac_int_100 - 0.704329822)/6.63303623)*-0.00461637+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*-0.02730863+ ((cac_int_102 - 0.135061733)/4.96797365)*0.340806784+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*0.084277622+ ((cac_int_104 - 0.21816945)/6.0030762)*0.042808527+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*0.009432986+ ((cac_int_107 - 0.110066927)/4.54912283)*-0.06733068+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*-0.10353872+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.01912763+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.03575365+ ((cac_int_44 - 0.142164325)/5.07595701)*-0.02477328+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*-0.0387234+ ((cac_int_3 - 0.319066058)/6.77506341)*0.259505062+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*0.017375104+ ((cac_int_36 - 0.063761936)/3.55135807)*-0.0547314+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*-0.02977481+ ((cac_int_62 - 0.115761997)/4.650377)*0.015376257+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*-0.04494074+ ((cac_int_60 - 0.111746232)/4.57936798)*-0.13286184+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*0.014677387+ ((cac_int_65 - 0.071961444)/3.75624155)*0.016514841+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*-0.04572172+ ((cac_int_114 - 0.119576572)/4.7161696)*0.00268455+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*0.016968461+ ((cac_int_13 - 0.282988351)/6.54738614)*-0.00100612+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*-0.01121366+ ((cac_int_43 - 0.156240519)/5.27748174)*-0.11818023+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*-0.02497017+ ((cac_int_31 - 0.142147159)/5.07570132)*0.010970379+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*-0.03844691+ ((cac_int_32 - 0.389978397)/7.08946483)*-0.01773857+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*0.056392112+ ((cac_int_68 - 0.080678364)/3.95852008)*-0.050403+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*-0.01142302+ ((cac_int_133 - 0.592181532)/7.14301305)*0.009501647+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*0.003824488+ ((cac_int_37 - 0.219569432)/6.01691179)*0.032481329+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*0.010177627+ ((cac_int_137 - 0.248972434)/6.28527293)*0.071206589+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*0.002095186+ ((cac_int_12 - 0.658468442)/6.89292371)*-0.01849939+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*0.027270408+ ((cac_int_141 - 0.19344787)/5.74141272)*0.031578475+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*-0.00808004+ ((cac_int_143 - 0.176853601)/5.54582377)*-0.01960918;
      FACTOR8 =  ((cac_int_1 - 0.389493072)/7.08786989)*-0.04709066+ ((cac_int_70 - 0.106765272)/4.4886772)*-0.0146122+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*-0.03734202+ ((cac_int_80 - 0.168759982)/5.44400514)*0.00646408+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*-0.00549297+ ((cac_int_76 - 0.06883226)/3.67985362)*-0.01801532+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*-0.00309525+ ((cac_int_78 - 0.132180265)/4.92287309)*-0.0255804+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*-0.00685499+ ((cac_int_46 - 0.216440409)/5.98584901)*-0.02686593+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*0.004850438+ ((cac_int_26 - 0.403502844)/7.13096095)*-0.01512383+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*-0.04710236+ ((cac_int_28 - 0.552858324)/7.22686715)*-0.056466+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*-0.12019126+ ((cac_int_34 - 0.066279209)/3.61591108)*-0.05223647+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*0.023805986+ ((cac_int_41 - 0.164022888)/5.3823259)*0.008275096+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*0.039472252+ ((cac_int_42 - 0.122584465)/4.76695384)*-0.04578567+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*0.073272424+ ((cac_int_19 - 0.272773581)/6.47375927)*0.512414663+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*0.525416452+ ((cac_int_98 - 0.464987843)/7.24975273)*0.015552331+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*-0.04837381+ ((cac_int_100 - 0.704329822)/6.63303623)*0.088764673+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*-0.0342944+ ((cac_int_102 - 0.135061733)/4.96797365)*-0.0338237+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*0.001522481+ ((cac_int_104 - 0.21816945)/6.0030762)*-0.01372243+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*-0.0338015+ ((cac_int_107 - 0.110066927)/4.54912283)*-0.05775983+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*0.025976923+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.0295792+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.01125099+ ((cac_int_44 - 0.142164325)/5.07595701)*-0.02653709+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*0.033806126+ ((cac_int_3 - 0.319066058)/6.77506341)*-0.04722923+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*-0.00822226+ ((cac_int_36 - 0.063761936)/3.55135807)*-0.07821886+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*0.005699851+ ((cac_int_62 - 0.115761997)/4.650377)*0.003886831+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*-0.09274263+ ((cac_int_60 - 0.111746232)/4.57936798)*0.002703332+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*-0.08509152+ ((cac_int_65 - 0.071961444)/3.75624155)*0.028180307+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*-0.00884668+ ((cac_int_114 - 0.119576572)/4.7161696)*-0.04092415+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*-0.07534005+ ((cac_int_13 - 0.282988351)/6.54738614)*-0.01927623+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*-0.02459588+ ((cac_int_43 - 0.156240519)/5.27748174)*-0.06115984+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*0.040075978+ ((cac_int_31 - 0.142147159)/5.07570132)*0.048340396+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*0.105579256+ ((cac_int_32 - 0.389978397)/7.08946483)*0.046477465+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*0.016031734+ ((cac_int_68 - 0.080678364)/3.95852008)*-0.01945534+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*-0.03431276+ ((cac_int_133 - 0.592181532)/7.14301305)*-0.08677497+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*-0.03880113+ ((cac_int_37 - 0.219569432)/6.01691179)*0.028392222+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*-0.01733721+ ((cac_int_137 - 0.248972434)/6.28527293)*0.193180978+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*0.017333188+ ((cac_int_12 - 0.658468442)/6.89292371)*-0.03851499+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*0.031698798+ ((cac_int_141 - 0.19344787)/5.74141272)*-0.04088625+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*-0.01050447+ ((cac_int_143 - 0.176853601)/5.54582377)*-0.04349092;
      FACTOR9 =  ((cac_int_1 - 0.389493072)/7.08786989)*0.007067029+ ((cac_int_70 - 0.106765272)/4.4886772)*-0.10173193+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*-0.09085323+ ((cac_int_80 - 0.168759982)/5.44400514)*0.016323529+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*-0.01442257+ ((cac_int_76 - 0.06883226)/3.67985362)*-0.16908917+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*0.23108474+ ((cac_int_78 - 0.132180265)/4.92287309)*-0.06018681+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*0.037011911+ ((cac_int_46 - 0.216440409)/5.98584901)*-0.01181179+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*0.000488762+ ((cac_int_26 - 0.403502844)/7.13096095)*-0.02983936+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*0.0601914+ ((cac_int_28 - 0.552858324)/7.22686715)*0.002048537+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*-0.00998708+ ((cac_int_34 - 0.066279209)/3.61591108)*-0.01691241+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*0.015109426+ ((cac_int_41 - 0.164022888)/5.3823259)*-0.02923176+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*-0.11439565+ ((cac_int_42 - 0.122584465)/4.76695384)*-0.05430064+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*0.050617382+ ((cac_int_19 - 0.272773581)/6.47375927)*-0.02332673+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*-0.02925104+ ((cac_int_98 - 0.464987843)/7.24975273)*-0.01013417+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*0.011392413+ ((cac_int_100 - 0.704329822)/6.63303623)*-0.00158019+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*-0.0386346+ ((cac_int_102 - 0.135061733)/4.96797365)*0.113549755+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*0.316037508+ ((cac_int_104 - 0.21816945)/6.0030762)*-0.04458565+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*0.487609453+ ((cac_int_107 - 0.110066927)/4.54912283)*0.377399122+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*0.096411217+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.02318189+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.04654228+ ((cac_int_44 - 0.142164325)/5.07595701)*-0.01680921+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*0.025237354+ ((cac_int_3 - 0.319066058)/6.77506341)*0.045035848+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*-0.2044404+ ((cac_int_36 - 0.063761936)/3.55135807)*-0.00552716+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*-0.0615583+ ((cac_int_62 - 0.115761997)/4.650377)*0.022908101+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*-0.01534163+ ((cac_int_60 - 0.111746232)/4.57936798)*0.000884787+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*-0.01882816+ ((cac_int_65 - 0.071961444)/3.75624155)*0.128660576+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*-0.03692908+ ((cac_int_114 - 0.119576572)/4.7161696)*-0.09767343+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*-0.11700402+ ((cac_int_13 - 0.282988351)/6.54738614)*-0.0189416+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*0.029200234+ ((cac_int_43 - 0.156240519)/5.27748174)*-0.08243386+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*-0.03570065+ ((cac_int_31 - 0.142147159)/5.07570132)*-0.02109227+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*0.045016698+ ((cac_int_32 - 0.389978397)/7.08946483)*-0.01996352+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*-0.00746348+ ((cac_int_68 - 0.080678364)/3.95852008)*-0.03086636+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*0.063340346+ ((cac_int_133 - 0.592181532)/7.14301305)*0.010081149+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*-0.00167435+ ((cac_int_37 - 0.219569432)/6.01691179)*-0.02529441+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*-0.049424+ ((cac_int_137 - 0.248972434)/6.28527293)*0.014907987+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*0.098050253+ ((cac_int_12 - 0.658468442)/6.89292371)*-0.04605331+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*0.051921077+ ((cac_int_141 - 0.19344787)/5.74141272)*0.016763938+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*-0.00245547+ ((cac_int_143 - 0.176853601)/5.54582377)*-0.0114767;
     FACTOR10 =  ((cac_int_1 - 0.389493072)/7.08786989)*0.056174323+ ((cac_int_70 - 0.106765272)/4.4886772)*0.00053898+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*-0.00610386+ ((cac_int_80 - 0.168759982)/5.44400514)*0.035304105+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*0.009670502+ ((cac_int_76 - 0.06883226)/3.67985362)*-0.08656915+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*0.058206413+ ((cac_int_78 - 0.132180265)/4.92287309)*0.051156311+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*0.021943401+ ((cac_int_46 - 0.216440409)/5.98584901)*-0.03150976+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*0.041699102+ ((cac_int_26 - 0.403502844)/7.13096095)*0.2260849+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*0.171993948+ ((cac_int_28 - 0.552858324)/7.22686715)*-0.13444733+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*-0.03363661+ ((cac_int_34 - 0.066279209)/3.61591108)*-0.10034608+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*-0.0163909+ ((cac_int_41 - 0.164022888)/5.3823259)*0.442323116+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*0.176429357+ ((cac_int_42 - 0.122584465)/4.76695384)*-0.05548328+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*0.032014282+ ((cac_int_19 - 0.272773581)/6.47375927)*-0.02659404+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*-0.01370883+ ((cac_int_98 - 0.464987843)/7.24975273)*0.002331553+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*-0.11437848+ ((cac_int_100 - 0.704329822)/6.63303623)*0.033885952+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*0.354848952+ ((cac_int_102 - 0.135061733)/4.96797365)*-0.00317632+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*0.001514186+ ((cac_int_104 - 0.21816945)/6.0030762)*-0.07307943+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*-0.01214034+ ((cac_int_107 - 0.110066927)/4.54912283)*-0.03783467+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*-0.09151038+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.04773527+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.02869268+ ((cac_int_44 - 0.142164325)/5.07595701)*-0.02411643+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*0.064261759+ ((cac_int_3 - 0.319066058)/6.77506341)*0.072861275+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*-0.01446186+ ((cac_int_36 - 0.063761936)/3.55135807)*0.024770975+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*-0.04742654+ ((cac_int_62 - 0.115761997)/4.650377)*-0.02696299+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*-0.00417557+ ((cac_int_60 - 0.111746232)/4.57936798)*0.016382483+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*0.089508009+ ((cac_int_65 - 0.071961444)/3.75624155)*-0.01619477+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*-0.0439381+ ((cac_int_114 - 0.119576572)/4.7161696)*-0.10842211+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*-0.08405293+ ((cac_int_13 - 0.282988351)/6.54738614)*-0.03092415+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*-0.05490005+ ((cac_int_43 - 0.156240519)/5.27748174)*0.075021046+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*0.028382779+ ((cac_int_31 - 0.142147159)/5.07570132)*-0.02773946+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*0.029479356+ ((cac_int_32 - 0.389978397)/7.08946483)*-0.02278439+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*0.009946093+ ((cac_int_68 - 0.080678364)/3.95852008)*-0.02627851+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*-0.00152955+ ((cac_int_133 - 0.592181532)/7.14301305)*-0.11030376+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*-0.04856387+ ((cac_int_37 - 0.219569432)/6.01691179)*-0.06036371+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*-0.08221214+ ((cac_int_137 - 0.248972434)/6.28527293)*-0.03256667+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*-0.01035852+ ((cac_int_12 - 0.658468442)/6.89292371)*-0.08437037+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*0.05082224+ ((cac_int_141 - 0.19344787)/5.74141272)*0.385890489+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*0.057679147+ ((cac_int_143 - 0.176853601)/5.54582377)*0.04464735;
     FACTOR11 =  ((cac_int_1 - 0.389493072)/7.08786989)*0.036070726+ ((cac_int_70 - 0.106765272)/4.4886772)*0.004562406+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*0.040653126+ ((cac_int_80 - 0.168759982)/5.44400514)*-0.02757849+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*0.055812973+ ((cac_int_76 - 0.06883226)/3.67985362)*0.012063712+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*-0.00507959+ ((cac_int_78 - 0.132180265)/4.92287309)*-0.04070396+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*0.475909845+ ((cac_int_46 - 0.216440409)/5.98584901)*-0.02443215+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*-0.03996128+ ((cac_int_26 - 0.403502844)/7.13096095)*-0.10458437+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*0.044118532+ ((cac_int_28 - 0.552858324)/7.22686715)*-0.03011986+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*0.011956691+ ((cac_int_34 - 0.066279209)/3.61591108)*0.433731481+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*0.144575671+ ((cac_int_41 - 0.164022888)/5.3823259)*-0.0177779+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*-0.02151943+ ((cac_int_42 - 0.122584465)/4.76695384)*-0.02869747+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*0.042889457+ ((cac_int_19 - 0.272773581)/6.47375927)*-0.01555977+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*-0.01372338+ ((cac_int_98 - 0.464987843)/7.24975273)*-0.0228623+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*0.018007437+ ((cac_int_100 - 0.704329822)/6.63303623)*0.04283788+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*0.110610917+ ((cac_int_102 - 0.135061733)/4.96797365)*-0.00867346+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*-0.02531714+ ((cac_int_104 - 0.21816945)/6.0030762)*0.006484988+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*-0.00006923+ ((cac_int_107 - 0.110066927)/4.54912283)*0.043516051+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*0.089410935+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.04374821+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.02257425+ ((cac_int_44 - 0.142164325)/5.07595701)*-0.05928183+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*-0.07279973+ ((cac_int_3 - 0.319066058)/6.77506341)*-0.0310975+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*0.017403405+ ((cac_int_36 - 0.063761936)/3.55135807)*-0.01307349+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*0.022438341+ ((cac_int_62 - 0.115761997)/4.650377)*-0.01939177+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*0.000032741+ ((cac_int_60 - 0.111746232)/4.57936798)*-0.02805826+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*-0.05588817+ ((cac_int_65 - 0.071961444)/3.75624155)*-0.05618598+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*0.010056712+ ((cac_int_114 - 0.119576572)/4.7161696)*0.122855718+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*0.012225152+ ((cac_int_13 - 0.282988351)/6.54738614)*-0.04756933+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*-0.02079754+ ((cac_int_43 - 0.156240519)/5.27748174)*-0.03152767+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*0.025193552+ ((cac_int_31 - 0.142147159)/5.07570132)*-0.01340192+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*-0.06979145+ ((cac_int_32 - 0.389978397)/7.08946483)*0.118594811+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*0.389146705+ ((cac_int_68 - 0.080678364)/3.95852008)*0.002870142+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*0.051014461+ ((cac_int_133 - 0.592181532)/7.14301305)*-0.05370823+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*-0.09507213+ ((cac_int_37 - 0.219569432)/6.01691179)*-0.1135724+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*-0.10340388+ ((cac_int_137 - 0.248972434)/6.28527293)*-0.00892245+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*-0.02218144+ ((cac_int_12 - 0.658468442)/6.89292371)*-0.03128036+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*-0.05058252+ ((cac_int_141 - 0.19344787)/5.74141272)*-0.13098531+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*-0.02913607+ ((cac_int_143 - 0.176853601)/5.54582377)*0.016254879;
     FACTOR12 =  ((cac_int_1 - 0.389493072)/7.08786989)*0.020217013+ ((cac_int_70 - 0.106765272)/4.4886772)*0.358093946+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*0.473578919+ ((cac_int_80 - 0.168759982)/5.44400514)*-0.03781513+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*0.032338575+ ((cac_int_76 - 0.06883226)/3.67985362)*-0.07707527+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*0.489160394+ ((cac_int_78 - 0.132180265)/4.92287309)*0.160637927+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*-0.02460447+ ((cac_int_46 - 0.216440409)/5.98584901)*0.004179357+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*-0.03905583+ ((cac_int_26 - 0.403502844)/7.13096095)*-0.03178501+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*0.009777149+ ((cac_int_28 - 0.552858324)/7.22686715)*0.064119942+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*-0.02031553+ ((cac_int_34 - 0.066279209)/3.61591108)*0.006144701+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*-0.0141181+ ((cac_int_41 - 0.164022888)/5.3823259)*0.007317698+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*0.033465063+ ((cac_int_42 - 0.122584465)/4.76695384)*0.0513257+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*-0.05991351+ ((cac_int_19 - 0.272773581)/6.47375927)*-0.02766148+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*-0.02686476+ ((cac_int_98 - 0.464987843)/7.24975273)*-0.05238702+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*0.065988203+ ((cac_int_100 - 0.704329822)/6.63303623)*-0.0528959+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*0.008435669+ ((cac_int_102 - 0.135061733)/4.96797365)*-0.07100532+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*-0.02692379+ ((cac_int_104 - 0.21816945)/6.0030762)*0.010262145+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*-0.04063565+ ((cac_int_107 - 0.110066927)/4.54912283)*-0.02328923+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*-0.08381775+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.02445936+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.02448064+ ((cac_int_44 - 0.142164325)/5.07595701)*-0.11846947+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*-0.09176242+ ((cac_int_3 - 0.319066058)/6.77506341)*-0.07612855+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*0.036026938+ ((cac_int_36 - 0.063761936)/3.55135807)*-0.04439187+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*-0.03011839+ ((cac_int_62 - 0.115761997)/4.650377)*0.009008873+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*-0.02560271+ ((cac_int_60 - 0.111746232)/4.57936798)*0.006415913+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*-0.1263394+ ((cac_int_65 - 0.071961444)/3.75624155)*0.019229843+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*-0.01634681+ ((cac_int_114 - 0.119576572)/4.7161696)*-0.04672475+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*-0.01202661+ ((cac_int_13 - 0.282988351)/6.54738614)*0.045060107+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*0.036124458+ ((cac_int_43 - 0.156240519)/5.27748174)*0.188619709+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*-0.07026229+ ((cac_int_31 - 0.142147159)/5.07570132)*-0.02485495+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*-0.07349528+ ((cac_int_32 - 0.389978397)/7.08946483)*-0.05466779+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*0.05500733+ ((cac_int_68 - 0.080678364)/3.95852008)*-0.02244546+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*-0.04358545+ ((cac_int_133 - 0.592181532)/7.14301305)*0.001532397+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*0.003307652+ ((cac_int_37 - 0.219569432)/6.01691179)*0.115913704+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*-0.01909941+ ((cac_int_137 - 0.248972434)/6.28527293)*0.083226041+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*0.019281047+ ((cac_int_12 - 0.658468442)/6.89292371)*0.005564649+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*0.019973444+ ((cac_int_141 - 0.19344787)/5.74141272)*0.014327258+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*-0.02147416+ ((cac_int_143 - 0.176853601)/5.54582377)*0.028202747;
     FACTOR13 =  ((cac_int_1 - 0.389493072)/7.08786989)*-0.045133+ ((cac_int_70 - 0.106765272)/4.4886772)*0.020276806+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*0.016154182+ ((cac_int_80 - 0.168759982)/5.44400514)*-0.06943564+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*0.02346786+ ((cac_int_76 - 0.06883226)/3.67985362)*0.015297465+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*0.002205706+ ((cac_int_78 - 0.132180265)/4.92287309)*-0.02990347+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*0.025864374+ ((cac_int_46 - 0.216440409)/5.98584901)*-0.02975047+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*0.040254446+ ((cac_int_26 - 0.403502844)/7.13096095)*-0.02758344+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*-0.01244597+ ((cac_int_28 - 0.552858324)/7.22686715)*-0.03259992+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*0.036654569+ ((cac_int_34 - 0.066279209)/3.61591108)*-0.04359728+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*-0.05669635+ ((cac_int_41 - 0.164022888)/5.3823259)*0.042493589+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*-0.024168+ ((cac_int_42 - 0.122584465)/4.76695384)*0.043060445+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*-0.03029735+ ((cac_int_19 - 0.272773581)/6.47375927)*0.002049383+
                 ((cac_int_91 - 0.167827837)/5.43199249)*0.00835226+ ((cac_int_98 - 0.464987843)/7.24975273)*0.006501093+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*-0.00183532+ ((cac_int_100 - 0.704329822)/6.63303623)*0.041247797+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*-0.04074973+ ((cac_int_102 - 0.135061733)/4.96797365)*-0.02305472+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*0.023825029+ ((cac_int_104 - 0.21816945)/6.0030762)*-0.00835796+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*0.023510885+ ((cac_int_107 - 0.110066927)/4.54912283)*-0.02738873+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*0.004381682+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.0794924+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.06062497+ ((cac_int_44 - 0.142164325)/5.07595701)*-0.06587509+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*0.050966637+ ((cac_int_3 - 0.319066058)/6.77506341)*-0.02823032+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*0.017002053+ ((cac_int_36 - 0.063761936)/3.55135807)*0.057375957+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*0.013917449+ ((cac_int_62 - 0.115761997)/4.650377)*-0.01466842+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*0.017771254+ ((cac_int_60 - 0.111746232)/4.57936798)*0.012670439+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*0.05850007+ ((cac_int_65 - 0.071961444)/3.75624155)*0.050013782+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*0.115323928+ ((cac_int_114 - 0.119576572)/4.7161696)*0.080819563+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*0.443936374+ ((cac_int_13 - 0.282988351)/6.54738614)*0.078912191+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*-0.02418514+ ((cac_int_43 - 0.156240519)/5.27748174)*-0.12736587+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*-0.1506512+ ((cac_int_31 - 0.142147159)/5.07570132)*-0.11730668+
                 ((cac_int_120 - 0.039406957)/2.82798262)*-0.17044142+ ((cac_int_32 - 0.389978397)/7.08946483)*-0.05414029+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*-0.00754968+ ((cac_int_68 - 0.080678364)/3.95852008)*-0.05551572+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*0.059355379+ ((cac_int_133 - 0.592181532)/7.14301305)*-0.03550812+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*-0.07055698+ ((cac_int_37 - 0.219569432)/6.01691179)*0.235742032+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*-0.08330974+ ((cac_int_137 - 0.248972434)/6.28527293)*-0.03727929+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*0.346137955+ ((cac_int_12 - 0.658468442)/6.89292371)*0.125730313+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*0.069537068+ ((cac_int_141 - 0.19344787)/5.74141272)*-0.00392449+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*0.430083029+ ((cac_int_143 - 0.176853601)/5.54582377)*-0.02684863;
     FACTOR14 =  ((cac_int_1 - 0.389493072)/7.08786989)*0.010714248+ ((cac_int_70 - 0.106765272)/4.4886772)*-0.06893586+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*0.032676695+ ((cac_int_80 - 0.168759982)/5.44400514)*-0.08506101+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*-0.04515857+ ((cac_int_76 - 0.06883226)/3.67985362)*-0.04273844+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*-0.01304183+ ((cac_int_78 - 0.132180265)/4.92287309)*-0.02774191+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*-0.00003442+ ((cac_int_46 - 0.216440409)/5.98584901)*0.109981848+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*0.020641277+ ((cac_int_26 - 0.403502844)/7.13096095)*0.223855451+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*-0.10130534+ ((cac_int_28 - 0.552858324)/7.22686715)*0.255408183+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*0.081662854+ ((cac_int_34 - 0.066279209)/3.61591108)*0.005833112+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*0.210692494+ ((cac_int_41 - 0.164022888)/5.3823259)*0.002959987+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*0.056953664+ ((cac_int_42 - 0.122584465)/4.76695384)*0.051079487+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*0.435611703+ ((cac_int_19 - 0.272773581)/6.47375927)*0.029052638+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*0.03681146+ ((cac_int_98 - 0.464987843)/7.24975273)*-0.19571891+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*0.066270494+ ((cac_int_100 - 0.704329822)/6.63303623)*-0.15050076+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*-0.21889865+ ((cac_int_102 - 0.135061733)/4.96797365)*-0.06493545+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*0.124193211+ ((cac_int_104 - 0.21816945)/6.0030762)*0.082136212+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*0.043114054+ ((cac_int_107 - 0.110066927)/4.54912283)*-0.04978808+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*0.059156376+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.01283646+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.03288678+ ((cac_int_44 - 0.142164325)/5.07595701)*-0.01222571+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*-0.0130593+ ((cac_int_3 - 0.319066058)/6.77506341)*-0.09461396+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*0.096314956+ ((cac_int_36 - 0.063761936)/3.55135807)*-0.13984702+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*0.086563618+ ((cac_int_62 - 0.115761997)/4.650377)*-0.07932004+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*0.059425112+ ((cac_int_60 - 0.111746232)/4.57936798)*-0.13630918+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*-0.05716385+ ((cac_int_65 - 0.071961444)/3.75624155)*-0.00974609+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*-0.00085511+ ((cac_int_114 - 0.119576572)/4.7161696)*0.01875559+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*-0.0384296+ ((cac_int_13 - 0.282988351)/6.54738614)*0.020802999+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*-0.00343871+ ((cac_int_43 - 0.156240519)/5.27748174)*-0.15888201+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*-0.17536003+ ((cac_int_31 - 0.142147159)/5.07570132)*-0.03110613+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*-0.16971926+ ((cac_int_32 - 0.389978397)/7.08946483)*-0.05208615+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*-0.05100858+ ((cac_int_68 - 0.080678364)/3.95852008)*-0.112564+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*0.040797556+ ((cac_int_133 - 0.592181532)/7.14301305)*0.135822141+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*-0.00529337+ ((cac_int_37 - 0.219569432)/6.01691179)*-0.05515263+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*-0.02570273+ ((cac_int_137 - 0.248972434)/6.28527293)*0.006795032+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*0.025424739+ ((cac_int_12 - 0.658468442)/6.89292371)*0.012939451+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*-0.08956045+ ((cac_int_141 - 0.19344787)/5.74141272)*0.20410954+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*0.010158497+ ((cac_int_143 - 0.176853601)/5.54582377)*-0.02553833;
     FACTOR15 =  ((cac_int_1 - 0.389493072)/7.08786989)*-0.14622783+ ((cac_int_70 - 0.106765272)/4.4886772)*0.035639689+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*0.088217845+ ((cac_int_80 - 0.168759982)/5.44400514)*0.002759198+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*0.100483018+ ((cac_int_76 - 0.06883226)/3.67985362)*0.017268544+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*-0.0478486+ ((cac_int_78 - 0.132180265)/4.92287309)*-0.17266556+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*-0.06218554+ ((cac_int_46 - 0.216440409)/5.98584901)*0.017978797+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*-0.02560216+ ((cac_int_26 - 0.403502844)/7.13096095)*0.069994223+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*-0.13183026+ ((cac_int_28 - 0.552858324)/7.22686715)*-0.09638545+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*-0.03481293+ ((cac_int_34 - 0.066279209)/3.61591108)*0.124093411+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*0.016427608+ ((cac_int_41 - 0.164022888)/5.3823259)*-0.00254702+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*0.363742154+ ((cac_int_42 - 0.122584465)/4.76695384)*0.071534021+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*0.076833978+ ((cac_int_19 - 0.272773581)/6.47375927)*0.010459725+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*0.018629397+ ((cac_int_98 - 0.464987843)/7.24975273)*0.100621886+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*-0.06526149+ ((cac_int_100 - 0.704329822)/6.63303623)*0.052379846+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*0.088185814+ ((cac_int_102 - 0.135061733)/4.96797365)*-0.07986381+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*-0.09910695+ ((cac_int_104 - 0.21816945)/6.0030762)*-0.05248171+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*-0.04918109+ ((cac_int_107 - 0.110066927)/4.54912283)*0.08993085+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*0.11822131+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.03523129+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*0.021968458+ ((cac_int_44 - 0.142164325)/5.07595701)*0.083046929+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*0.047947594+ ((cac_int_3 - 0.319066058)/6.77506341)*-0.07918631+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*-0.09951106+ ((cac_int_36 - 0.063761936)/3.55135807)*-0.03893894+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*-0.01243931+ ((cac_int_62 - 0.115761997)/4.650377)*-0.04650751+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*0.031160352+ ((cac_int_60 - 0.111746232)/4.57936798)*0.05402414+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*-0.03821363+ ((cac_int_65 - 0.071961444)/3.75624155)*-0.04055312+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*0.054481588+ ((cac_int_114 - 0.119576572)/4.7161696)*-0.12568468+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*0.20074772+ ((cac_int_13 - 0.282988351)/6.54738614)*0.032980484+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*0.509183372+ ((cac_int_43 - 0.156240519)/5.27748174)*-0.10032566+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*-0.05532257+ ((cac_int_31 - 0.142147159)/5.07570132)*0.112163166+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*0.116311541+ ((cac_int_32 - 0.389978397)/7.08946483)*-0.11271308+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*-0.08097723+ ((cac_int_68 - 0.080678364)/3.95852008)*-0.02620061+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*0.085332404+ ((cac_int_133 - 0.592181532)/7.14301305)*-0.03042494+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*0.038695844+ ((cac_int_37 - 0.219569432)/6.01691179)*-0.16570881+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*0.095111463+ ((cac_int_137 - 0.248972434)/6.28527293)*0.001084991+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*-0.07110171+ ((cac_int_12 - 0.658468442)/6.89292371)*-0.06694228+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*-0.08954131+ ((cac_int_141 - 0.19344787)/5.74141272)*-0.00972386+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*-0.0781402+ ((cac_int_143 - 0.176853601)/5.54582377)*0.172157913;
     FACTOR16 =  ((cac_int_1 - 0.389493072)/7.08786989)*-0.01393563+ ((cac_int_70 - 0.106765272)/4.4886772)*0.066661162+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*-0.07804473+ ((cac_int_80 - 0.168759982)/5.44400514)*0.489904497+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*-0.0402877+ ((cac_int_76 - 0.06883226)/3.67985362)*0.118957007+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*-0.02364072+ ((cac_int_78 - 0.132180265)/4.92287309)*0.136613641+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*-0.02616816+ ((cac_int_46 - 0.216440409)/5.98584901)*0.000204136+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*0.017040685+ ((cac_int_26 - 0.403502844)/7.13096095)*-0.04824613+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*0.049276039+ ((cac_int_28 - 0.552858324)/7.22686715)*-0.03945645+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*0.092355679+ ((cac_int_34 - 0.066279209)/3.61591108)*0.054877377+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*-0.06955953+ ((cac_int_41 - 0.164022888)/5.3823259)*0.023337713+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*-0.07583729+ ((cac_int_42 - 0.122584465)/4.76695384)*0.068614227+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*-0.10034401+ ((cac_int_19 - 0.272773581)/6.47375927)*0.016704941+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*0.015046594+ ((cac_int_98 - 0.464987843)/7.24975273)*0.037915755+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*-0.02635832+ ((cac_int_100 - 0.704329822)/6.63303623)*0.02335804+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*0.024460209+ ((cac_int_102 - 0.135061733)/4.96797365)*-0.08470708+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*0.090293691+ ((cac_int_104 - 0.21816945)/6.0030762)*0.028613847+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*0.008925131+ ((cac_int_107 - 0.110066927)/4.54912283)*-0.08854902+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*0.04163949+ ((cac_int_109 - 0.486272839)/7.26485315)*0.017537498+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.01272706+ ((cac_int_44 - 0.142164325)/5.07595701)*0.199254149+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*0.097552305+ ((cac_int_3 - 0.319066058)/6.77506341)*-0.08515847+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*0.10835264+ ((cac_int_36 - 0.063761936)/3.55135807)*-0.05514934+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*-0.04528212+ ((cac_int_62 - 0.115761997)/4.650377)*0.04934226+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*-0.06392834+ ((cac_int_60 - 0.111746232)/4.57936798)*-0.06716465+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*0.005946318+ ((cac_int_65 - 0.071961444)/3.75624155)*0.040303192+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*-0.07901174+ ((cac_int_114 - 0.119576572)/4.7161696)*0.038067635+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*-0.06767328+ ((cac_int_13 - 0.282988351)/6.54738614)*0.013561485+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*0.00506834+ ((cac_int_43 - 0.156240519)/5.27748174)*-0.18837042+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*-0.19403347+ ((cac_int_31 - 0.142147159)/5.07570132)*-0.0778312+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*-0.21702857+ ((cac_int_32 - 0.389978397)/7.08946483)*-0.08998741+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*-0.01167242+ ((cac_int_68 - 0.080678364)/3.95852008)*0.452497905+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*0.035140598+ ((cac_int_133 - 0.592181532)/7.14301305)*-0.03458737+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*-0.00921061+ ((cac_int_37 - 0.219569432)/6.01691179)*-0.18157426+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*0.023109646+ ((cac_int_137 - 0.248972434)/6.28527293)*0.018976763+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*-0.05936739+ ((cac_int_12 - 0.658468442)/6.89292371)*-0.07719137+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*0.03399699+ ((cac_int_141 - 0.19344787)/5.74141272)*-0.0329654+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*0.073709048+ ((cac_int_143 - 0.176853601)/5.54582377)*0.047926408;
     FACTOR17 =  ((cac_int_1 - 0.389493072)/7.08786989)*-0.00207315+ ((cac_int_70 - 0.106765272)/4.4886772)*-0.05930611+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*0.080099166+ ((cac_int_80 - 0.168759982)/5.44400514)*-0.00254066+
                 ((cac_int_75 - 0.052414312)/3.23932678)*-0.06184735+ ((cac_int_76 - 0.06883226)/3.67985362)*0.157676342+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*-0.12436425+ ((cac_int_78 - 0.132180265)/4.92287309)*0.246354358+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*0.051853721+ ((cac_int_46 - 0.216440409)/5.98584901)*-0.10494315+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*-0.00026576+ ((cac_int_26 - 0.403502844)/7.13096095)*-0.04696188+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*0.013417179+ ((cac_int_28 - 0.552858324)/7.22686715)*-0.05019687+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*-0.13492153+ ((cac_int_34 - 0.066279209)/3.61591108)*-0.05758308+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*0.060289742+ ((cac_int_41 - 0.164022888)/5.3823259)*-0.00991667+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*-0.08570291+ ((cac_int_42 - 0.122584465)/4.76695384)*-0.03840372+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*0.168685953+ ((cac_int_19 - 0.272773581)/6.47375927)*-0.07126348+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*-0.07586786+ ((cac_int_98 - 0.464987843)/7.24975273)*0.023163105+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*-0.02441886+ ((cac_int_100 - 0.704329822)/6.63303623)*0.091702323+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*0.07936139+ ((cac_int_102 - 0.135061733)/4.96797365)*-0.0768508+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*0.093396466+ ((cac_int_104 - 0.21816945)/6.0030762)*-0.00034258+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*-0.00485888+ ((cac_int_107 - 0.110066927)/4.54912283)*-0.09763468+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*-0.01189155+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.0335083+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.03373483+ ((cac_int_44 - 0.142164325)/5.07595701)*-0.02188951+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*0.046436601+ ((cac_int_3 - 0.319066058)/6.77506341)*-0.0079978+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*-0.04033983+ ((cac_int_36 - 0.063761936)/3.55135807)*-0.05449692+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*-0.01752477+ ((cac_int_62 - 0.115761997)/4.650377)*0.039884809+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*0.683865242+ ((cac_int_60 - 0.111746232)/4.57936798)*-0.02797589+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*-0.00667629+ ((cac_int_65 - 0.071961444)/3.75624155)*0.281832503+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*0.03522093+ ((cac_int_114 - 0.119576572)/4.7161696)*0.014035922+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*0.077594+ ((cac_int_13 - 0.282988351)/6.54738614)*-0.02514242+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*0.02950139+ ((cac_int_43 - 0.156240519)/5.27748174)*0.010710123+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*0.027637225+ ((cac_int_31 - 0.142147159)/5.07570132)*0.098528919+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*0.153964511+ ((cac_int_32 - 0.389978397)/7.08946483)*0.051366399+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*-0.05352116+ ((cac_int_68 - 0.080678364)/3.95852008)*-0.03468678+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*-0.04296007+ ((cac_int_133 - 0.592181532)/7.14301305)*-0.10312712+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*-0.00212601+ ((cac_int_37 - 0.219569432)/6.01691179)*0.043510702+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*0.078935131+ ((cac_int_137 - 0.248972434)/6.28527293)*-0.05991594+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*-0.03977154+ ((cac_int_12 - 0.658468442)/6.89292371)*0.015670715+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*-0.09442049+ ((cac_int_141 - 0.19344787)/5.74141272)*-0.05899554+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*-0.03480364+ ((cac_int_143 - 0.176853601)/5.54582377)*-0.01363774;
     FACTOR18 =  ((cac_int_1 - 0.389493072)/7.08786989)*0.031994424+ ((cac_int_70 - 0.106765272)/4.4886772)*-0.04026682+ 
                 ((cac_int_71 - 0.038507701)/2.79683775)*-0.11546483+ ((cac_int_80 - 0.168759982)/5.44400514)*-0.02563761+ 
                 ((cac_int_75 - 0.052414312)/3.23932678)*-0.03393616+ ((cac_int_76 - 0.06883226)/3.67985362)*-0.0152563+ 
                 ((cac_int_77 - 0.055172724)/3.31863121)*0.069581965+ ((cac_int_78 - 0.132180265)/4.92287309)*0.053560371+ 
                 ((cac_int_5 - 0.25207675)/6.31125143)*0.034468765+ ((cac_int_46 - 0.216440409)/5.98584901)*0.060973477+ 
                 ((cac_int_48 - 0.021834657)/2.12422197)*0.797448628+ ((cac_int_26 - 0.403502844)/7.13096095)*-0.04128522+ 
                 ((cac_int_27 - 0.132045657)/4.9207474)*-0.10441655+ ((cac_int_28 - 0.552858324)/7.22686715)*-0.06040781+ 
                 ((cac_int_40 - 0.226853481)/6.08729285)*0.104063981+ ((cac_int_34 - 0.066279209)/3.61591108)*0.00244966+ 
                 ((cac_int_33 - 0.418153727)/7.16956298)*-0.02658771+ ((cac_int_41 - 0.164022888)/5.3823259)*0.050656933+ 
                 ((cac_int_53 - 0.056021281)/3.34255212)*0.042128622+ ((cac_int_42 - 0.122584465)/4.76695384)*0.145569791+ 
                 ((cac_int_54 - 0.108450513)/4.51969473)*0.055344001+ ((cac_int_19 - 0.272773581)/6.47375927)*0.020686047+ 
                 ((cac_int_91 - 0.167827837)/5.43199249)*0.01401946+ ((cac_int_98 - 0.464987843)/7.24975273)*0.054805887+ 
                 ((cac_int_21 - 0.425967702)/7.18748696)*-0.04249038+ ((cac_int_100 - 0.704329822)/6.63303623)*0.049890568+ 
                 ((cac_int_22 - 0.198617345)/5.7989468)*0.085142491+ ((cac_int_102 - 0.135061733)/4.96797365)*0.055536724+ 
                 ((cac_int_103 - 0.112789721)/4.59799626)*-0.08064825+ ((cac_int_104 - 0.21816945)/6.0030762)*0.030283529+ 
                 ((cac_int_105 - 0.088323559)/4.1245751)*-0.01416902+ ((cac_int_107 - 0.110066927)/4.54912283)*0.045120548+ 
                 ((cac_int_108 - 0.207103395)/5.89009715)*0.022177348+ ((cac_int_109 - 0.486272839)/7.26485315)*-0.00841454+ 
                 ((cac_int_30 - 0.298722672)/6.65272485)*-0.00266663+ ((cac_int_44 - 0.142164325)/5.07595701)*0.023107064+ 
                 ((cac_int_55 - 0.173180532)/5.50016162)*-0.15250034+ ((cac_int_3 - 0.319066058)/6.77506341)*0.035007578+ 
                 ((cac_int_59 - 0.069048691)/3.68520606)*0.075961843+ ((cac_int_36 - 0.063761936)/3.55135807)*-0.04122537+ 
                 ((cac_int_61 - 0.087247501)/4.10179151)*-0.0593464+ ((cac_int_62 - 0.115761997)/4.650377)*-0.01351135+ 
                 ((cac_int_63 - 0.027690967)/2.38501873)*0.014363526+ ((cac_int_60 - 0.111746232)/4.57936798)*-0.05358005+ 
                 ((cac_int_64 - 0.091618315)/4.19320315)*-0.11900387+ ((cac_int_65 - 0.071961444)/3.75624155)*-0.09430494+ 
                 ((cac_int_10 - 0.449651248)/7.23065207)*-0.10017827+ ((cac_int_114 - 0.119576572)/4.7161696)*0.197856899+ 
                 ((cac_int_115 - 0.1076034)/4.50414663)*0.03039286+ ((cac_int_13 - 0.282988351)/6.54738614)*-0.0795866+ 
                 ((cac_int_116 - 0.035083472)/2.67434065)*-0.06358865+ ((cac_int_43 - 0.156240519)/5.27748174)*0.084577102+ 
                 ((cac_int_118 - 0.229368989)/6.1109842)*-0.01873692+ ((cac_int_31 - 0.142147159)/5.07570132)*-0.0681152+ 
                 ((cac_int_120 - 0.039406957)/2.82798262)*0.143434775+ ((cac_int_32 - 0.389978397)/7.08946483)*-0.11022948+ 
                 ((cac_int_39 - 0.115473048)/4.64532837)*-0.16882395+ ((cac_int_68 - 0.080678364)/3.95852008)*0.035834076+ 
                 ((cac_int_7 - 0.22575432)/6.07684277)*-0.08437466+ ((cac_int_133 - 0.592181532)/7.14301305)*0.04084472+ 
                 ((cac_int_9 - 0.264268599)/6.40918779)*-0.00308013+ ((cac_int_37 - 0.219569432)/6.01691179)*0.069215216+ 
                 ((cac_int_136 - 0.210817055)/5.92873838)*-0.02273716+ ((cac_int_137 - 0.248972434)/6.28527293)*0.016940114+ 
                 ((cac_int_11 - 0.070777732)/3.72759477)*0.011173857+ ((cac_int_12 - 0.658468442)/6.89292371)*-0.00353083+ 
                 ((cac_int_6 - 0.084624017)/4.04545287)*-0.00183916+ ((cac_int_141 - 0.19344787)/5.74141272)*-0.04738816+ 
                 ((cac_int_8 - 0.121937097)/4.75610364)*0.019661392+ ((cac_int_143 - 0.176853601)/5.54582377)*0.062809306;

      drop int_: cac_int_133 cac_int_136 cac_int_137 cac_int_141 cac_int_143;
      array cac_style_factor{18};
      array fact{18} factor1-factor18;
      if cac_int_flag=1 then do;
         do i=1 to 18;
            cac_style_factor{i}=fact{i};
         end;
         maxf = max(of cac_style_factor1-cac_style_factor18 );
         if maxf = cac_style_factor1 then cac_style_group = 1;
         else if maxf = cac_style_factor2 then cac_style_group = 2;
         else if maxf = cac_style_factor3 then cac_style_group = 3;
         else if maxf = cac_style_factor4 then cac_style_group = 4;
         else if maxf = cac_style_factor5 then cac_style_group = 5;
         else if maxf = cac_style_factor6 then cac_style_group = 6;
         else if maxf = cac_style_factor7 then cac_style_group = 7;
         else if maxf = cac_style_factor8 then cac_style_group = 8;
         else if maxf = cac_style_factor9 then cac_style_group = 9;
         else if maxf = cac_style_factor10 then cac_style_group = 10;
         else if maxf = cac_style_factor11 then cac_style_group = 11;
         else if maxf = cac_style_factor12 then cac_style_group = 12;
         else if maxf = cac_style_factor13 then cac_style_group = 13;
         else if maxf = cac_style_factor14 then cac_style_group = 14;
         else if maxf = cac_style_factor15 then cac_style_group = 15;
         else if maxf = cac_style_factor16 then cac_style_group = 16;
         else if maxf = cac_style_factor17 then cac_style_group = 17;
         else if maxf = cac_style_factor18 then cac_style_group = 18;
      end;
      drop factor:;

      *******************************************************;
      *** SCORE BUY STYLE: CJ HARDCODE RANKS 08/06/2012   ***;
      *******************************************************;
      if cac_silh_buy_style_1 >= 0.1914896 then cac_silh_buy_style_rank_1 = 0;
      else if cac_silh_buy_style_1 >= 0.1552344 then cac_silh_buy_style_rank_1 = 1;
      else if cac_silh_buy_style_1 >= 0.1325194 then cac_silh_buy_style_rank_1 = 2;
      else if cac_silh_buy_style_1 >= 0.1150634 then cac_silh_buy_style_rank_1 = 3;
      else if cac_silh_buy_style_1 >= 0.1002087 then cac_silh_buy_style_rank_1 = 4;
      else if cac_silh_buy_style_1 >= 0.0867933 then cac_silh_buy_style_rank_1 = 5;
      else if cac_silh_buy_style_1 >= 0.0741027 then cac_silh_buy_style_rank_1 = 6;
      else if cac_silh_buy_style_1 >= 0.0612606 then cac_silh_buy_style_rank_1 = 7;
      else if cac_silh_buy_style_1 >= 0.0465432 then cac_silh_buy_style_rank_1 = 8;
      else if cac_silh_buy_style_1 ne . then cac_silh_buy_style_rank_1 = 9;
      if cac_silh_buy_style_2 >= 0.1410965 then cac_silh_buy_style_rank_2 = 0;
      else if cac_silh_buy_style_2 >= 0.1203953 then cac_silh_buy_style_rank_2 = 1;
      else if cac_silh_buy_style_2 >= 0.106764 then cac_silh_buy_style_rank_2 = 2;
      else if cac_silh_buy_style_2 >= 0.0956389 then cac_silh_buy_style_rank_2 = 3;
      else if cac_silh_buy_style_2 >= 0.0857087 then cac_silh_buy_style_rank_2 = 4;
      else if cac_silh_buy_style_2 >= 0.0762297 then cac_silh_buy_style_rank_2 = 5;
      else if cac_silh_buy_style_2 >= 0.0666499 then cac_silh_buy_style_rank_2 = 6;
      else if cac_silh_buy_style_2 >= 0.0561405 then cac_silh_buy_style_rank_2 = 7;
      else if cac_silh_buy_style_2 >= 0.0430147 then cac_silh_buy_style_rank_2 = 8;
      else if cac_silh_buy_style_2 ne . then cac_silh_buy_style_rank_2 = 9;
      if cac_silh_buy_style_3 >= 0.1401226 then cac_silh_buy_style_rank_3 = 0;
      else if cac_silh_buy_style_3 >= 0.1218048 then cac_silh_buy_style_rank_3 = 1;
      else if cac_silh_buy_style_3 >= 0.1102913 then cac_silh_buy_style_rank_3 = 2;
      else if cac_silh_buy_style_3 >= 0.1014279 then cac_silh_buy_style_rank_3 = 3;
      else if cac_silh_buy_style_3 >= 0.0938979 then cac_silh_buy_style_rank_3 = 4;
      else if cac_silh_buy_style_3 >= 0.0870601 then cac_silh_buy_style_rank_3 = 5;
      else if cac_silh_buy_style_3 >= 0.0804441 then cac_silh_buy_style_rank_3 = 6;
      else if cac_silh_buy_style_3 >= 0.0734555 then cac_silh_buy_style_rank_3 = 7;
      else if cac_silh_buy_style_3 >= 0.0647018 then cac_silh_buy_style_rank_3 = 8;
      else if cac_silh_buy_style_3 ne . then cac_silh_buy_style_rank_3 = 9;
      if cac_silh_buy_style_4 >= 0.1836051 then cac_silh_buy_style_rank_4 = 0;
      else if cac_silh_buy_style_4 >= 0.1528531 then cac_silh_buy_style_rank_4 = 1;
      else if cac_silh_buy_style_4 >= 0.1345368 then cac_silh_buy_style_rank_4 = 2;
      else if cac_silh_buy_style_4 >= 0.1209019 then cac_silh_buy_style_rank_4 = 3;
      else if cac_silh_buy_style_4 >= 0.1093711 then cac_silh_buy_style_rank_4 = 4;
      else if cac_silh_buy_style_4 >= 0.0986251 then cac_silh_buy_style_rank_4 = 5;
      else if cac_silh_buy_style_4 >= 0.0877663 then cac_silh_buy_style_rank_4 = 6;
      else if cac_silh_buy_style_4 >= 0.0759449 then cac_silh_buy_style_rank_4 = 7;
      else if cac_silh_buy_style_4 >= 0.0615651 then cac_silh_buy_style_rank_4 = 8;
      else if cac_silh_buy_style_4 ne . then cac_silh_buy_style_rank_4 = 9;
      if cac_silh_buy_style_5 >= 0.1614657 then cac_silh_buy_style_rank_5 = 0;
      else if cac_silh_buy_style_5 >= 0.1389945 then cac_silh_buy_style_rank_5 = 1;
      else if cac_silh_buy_style_5 >= 0.124533 then cac_silh_buy_style_rank_5 = 2;
      else if cac_silh_buy_style_5 >= 0.1132527 then cac_silh_buy_style_rank_5 = 3;
      else if cac_silh_buy_style_5 >= 0.1035753 then cac_silh_buy_style_rank_5 = 4;
      else if cac_silh_buy_style_5 >= 0.0945554 then cac_silh_buy_style_rank_5 = 5;
      else if cac_silh_buy_style_5 >= 0.0855548 then cac_silh_buy_style_rank_5 = 6;
      else if cac_silh_buy_style_5 >= 0.0757885 then cac_silh_buy_style_rank_5 = 7;
      else if cac_silh_buy_style_5 >= 0.0635208 then cac_silh_buy_style_rank_5 = 8;
      else if cac_silh_buy_style_5 ne . then cac_silh_buy_style_rank_5 = 9;
      if cac_silh_buy_style_6 >= 0.1653954 then cac_silh_buy_style_rank_6 = 0;
      else if cac_silh_buy_style_6 >= 0.1302555 then cac_silh_buy_style_rank_6 = 1;
      else if cac_silh_buy_style_6 >= 0.1095796 then cac_silh_buy_style_rank_6 = 2;
      else if cac_silh_buy_style_6 >= 0.0960878 then cac_silh_buy_style_rank_6 = 3;
      else if cac_silh_buy_style_6 >= 0.0856388 then cac_silh_buy_style_rank_6 = 4;
      else if cac_silh_buy_style_6 >= 0.0762272 then cac_silh_buy_style_rank_6 = 5;
      else if cac_silh_buy_style_6 >= 0.0670661 then cac_silh_buy_style_rank_6 = 6;
      else if cac_silh_buy_style_6 >= 0.0580846 then cac_silh_buy_style_rank_6 = 7;
      else if cac_silh_buy_style_6 >= 0.0482637 then cac_silh_buy_style_rank_6 = 8;
      else if cac_silh_buy_style_6 ne . then cac_silh_buy_style_rank_6 = 9;

      array cac_silh_buy_style_{6};
      array cac_silh_buy_style_rank_{6};
      max_pmod=-9999;
      cac_silh_buy_style_group=0;
      do i=1 to 6;
         if cac_silh_buy_style_{i}>max_pmod and cac_silh_buy_style_rank_{i}<1 then do;
            max_pmod=cac_silh_buy_style_{i};
            cac_silh_buy_style_group=i;
         end;
      end;
      drop i;
      *******************************************************;
      *** END SCORE BUY STYLE                             ***;
      *******************************************************;
      %cacdirect_recode; 
      %fivepctfill;
      *________________________________________________________________________________*;
      * * TECH SCORING *________________________________________________________________________________*;
      *------------------------*;
      *** SCORE 4 MODELS ***;
      *------------------------*;
      tech_score_1=1 / (1 + (exp(-1 * (-1.061071903 + (M_GEO_CAC_INT_42 * (1.4979469659 )) + (M_GEO_CAC_INT_67 * 
                               (3.7687022341 )) + (M_GEO_CAC_INT_80 * (-1.524962372 )) + (M_GEO_CAC_INT_92 * (-1.142890373 )) + (M_ADLT_55_64_1PLUS * 
                               (0.1442145811 )) + (M_DWEL_MULT_APTNUM * (-0.251558153 )) + (M_FAM_COMP_11 * (0.3794060749 )) + (M_FAM_COMP_12 * (0.4244844421 )) + 
                               (M_LOR_20_PLUS_YRS * (-0.236408977 )) + (M_INC_45_50 * (0.2030298577 )) + (M_INC_225_250 * (-0.38579567 )) + (M_INC_250_PLUS * 
                               (-0.314907641 )) + (M_OCC_PROF_TECH * (0.2797151794 )) + (CAC_DEMO_NUM_KIDS_ENH * (-0.074472225 )) + (CAC_DEMO_ADULT_25_34_ENH * 
                               (0.071936611 )) + (CAC_DEMO_ADULT_65_PLUS_INF_ENH * (0.4629879333 )) + (CAC_DEMO_EDUCATION_ENH * (0.1354797136 )) + (CAC_DEMO_AGE_ENH * 
                               (-0.149411407 )) + (CAC_DEMO_HH_TYPE_ENH * (-0.023917342 )) + (CAC_DEMO_NARROW_INC_NUM * (0.0035634138 )) + (CAC_INT_6 * (0.2128015896 
                               )) + (CAC_INT_18 * (0.442364306 )) + (CAC_INT_29 * (0.3357800316 )) + (CAC_INT_33 * (0.2056078891 )) + (CAC_INT_45 * (-0.182685413 
                               )) + (CAC_INT_49 * (-0.12866784 )) + (CAC_INT_50 * (-0.168796489 )) + (CAC_INT_55 * (0.1547107604 )) + (CAC_INT_87 * (-0.45332429 
                               )) + (CAC_INT_104 * (-0.2564658 )) + (CAC_INT_111 * (0.2875640687 )) + (CAC_INT_116 * (0.3375103504 )) + (CEN_FACTOR6 * 
                               (-1.962374569 )) + (CEN_POPOCC_7 * (0.5749453681 )) + (CEN_POPOCC_10 * (-1.167665432 )) ))));
    tech_score_2=1 / (1 + (exp(-1 * (0.3840326739 + (M_GEO_CAC_INT_4 * (-1.302798112 )) + (M_GEO_CAC_INT_52 * 
                               (-1.61769106 )) + (M_GEO_CAC_INT_58 * (-1.434969841 )) + (M_GEO_CAC_INT_68 * (-2.86817039 )) + (M_GEO_CAC_INT_72 * (3.4957844926 )) 
                               + (M_GEO_CAC_INT_79 * (5.2395360933 )) + (M_GEO_CAC_INT_94 * (1.0264810453 )) + (M_ADLT_25_34_1PLUS * (0.1687631005 )) + 
                               (M_ADLT_75PLUS_1PLUS * (-0.133822858 )) + (M_DWELL_SINGLE * (-0.230698846 )) + (M_FAM_COMP_06 * (0.1960832215 )) + (M_FAM_COMP_11 * 
                               (0.3551945892 )) + (M_FAM_COMP_14 * (-0.145468296 )) + (M_MAIL_BUY_SINGLE * (-0.171359657 )) + (M_INCOME_UNDER_15 * (-0.190503383 
                               )) + (M_INCOME * (-0.001313575 )) + (M_OCC_PROF_TECH * (-0.191799655 )) + (M_POL_PARTY_IND * (0.3795999836 )) + 
                               (CAC_CRED_SPEC_APPAREL * (0.190904627 )) + (CAC_DEMO_EDUCATION_ENH * (-0.058218179 )) + (CAC_HOME_MTG_AMT_ORIG * (0.000319308 )) + 
                               (CAC_INT_1 * (0.1293198329 )) + (CAC_INT_5 * (0.1116123431 )) + (CAC_INT_16 * (-0.116713824 )) + (CAC_INT_18 * (-0.174672935 )) + 
                               (CAC_INT_23 * (0.1293963254 )) + (CAC_INT_25 * (0.1575028672 )) + (CAC_INT_35 * (-0.127834106 )) + (CAC_INT_49 * (-0.227678104 )) + 
                               (CAC_INT_61 * (0.2283533469 )) + (CAC_INT_64 * (-0.251506181 )) + (CAC_INT_75 * (-0.271891951 )) + (CAC_INT_84 * (0.2047307257 )) + 
                               (CEN_FACTOR15 * (1.9391252532 )) + (CEN_FAMRACE_4 * (-0.191947593 )) ))));
    tech_score_3=1 / (1 + (exp(-1 * (-1.666744896 + (M_GEO_CAC_INT_4 * (0.9367744867 )) + (M_GEO_CAC_INT_39 * 
                               (0.9776873251 )) + (M_GEO_CAC_INT_72 * (-1.829238485 )) + (M_ADLT_25_34_1PLUS * (-0.146320078 )) + (M_CRED_SPEC_APP * (-0.167562649 
                               )) + (M_FAM_COMP_04 * (-0.178023843 )) + (M_FAM_COMP_05 * (-0.288895308 )) + (M_FAM_COMP_06 * (-0.201386352 )) + (M_FAM_COMP_12 * 
                               (-0.280689338 )) + (M_FAM_COMP_13 * (0.2848319037 )) + (M_FAM_COMP_14 * (0.1747655013 )) + (M_INC_105_110 * (-0.3453669 )) + 
                               (M_INCOME * (0.0006509821 )) + (M_NUM_KIDS_4 * (0.3102172138 )) + (M_OCC_PROF_TECH * (-0.12625669 )) + (M_OCC_RETIRED * 
                               (-0.175104715 )) + (CAC_DEMO_ADULT_55_64_ENH * (0.0546863832 )) + (CAC_INT_16 * (0.0960322587 )) + (CAC_INT_18 * (-0.184763025 )) + 
                               (CAC_INT_23 * (-0.160403736 )) + (CAC_INT_25 * (-0.139830268 )) + (CAC_INT_29 * (-0.402728172 )) + (CAC_INT_49 * (0.0947684766 )) + 
                               (CAC_INT_53 * (0.2629753672 )) + (CAC_INT_61 * (-0.153054139 )) + (CAC_INT_62 * (-0.139211677 )) + (CAC_INT_64 * (0.2056786502 )) + 
                               (CAC_INT_73 * (0.357522668 )) + (CAC_INT_84 * (-0.150631414 )) + (CAC_INT_111 * (0.111668449 )) + (CAC_INT_FLAG * (0.1053710612 )) 
                               + (CEN_FAMRACE_4 * (0.135786168 )) + (CEN_POPOCC_11 * (-1.278502836 )) + (CEN_POPOCC_14 * (-1.234172705 )) + (CEN_POPOCC_18 * 
                               (-0.716339184 )) ))));
      tech_score_4=1 / (1 + (exp(-1 * (-1.55683555 + (M_GEO_CAC_INT_8 * (1.1595850726 )) + (M_GEO_CAC_INT_28 * 
                               (0.9114245961 )) + (M_GEO_CAC_INT_29 * (-3.72392005 )) + (M_GEO_CAC_INT_47 * (1.1379859694 )) + (M_GEO_CAC_INT_60 * (1.7473543051 
                               )) + (M_GEO_CAC_INT_91 * (-1.185598242 )) + (M_ADLT_25_34_1PLUS * (-0.141749178 )) + (M_ADLT_55_64_1PLUS * (-0.126956042 )) + 
                               (M_FAM_COMP_04 * (0.1211445897 )) + (M_FAM_COMP_11 * (-0.360233035 )) + (M_LOR_20_PLUS_YRS * (0.1515109633 )) + (M_INC_75_80 * 
                               (0.4096560264 )) + (M_INC_200_225 * (0.3323654315 )) + (M_INC_225_250 * (0.3412328316 )) + (M_NUM_PERS_5 * (0.2378201197 )) + 
                               (CAC_DEMO_ADULT_75_PLUS_ENH * (0.0896892085 )) + (CAC_DEMO_EDUCATION_ENH * (-0.036494109 )) + (CAC_DEMO_AGE_ENH * (0.0867090165 )) + 
                               (CAC_DEMO_NARROW_INC_NUM * (-0.003216978 )) + (CAC_INT_6 * (-0.168348686 )) + (CAC_INT_11 * (-0.202772451 )) + (CAC_INT_45 * 
                               (0.1425307821 )) + (CAC_INT_49 * (0.1486924699 )) + (CAC_INT_55 * (-0.14211794 )) + (CAC_INT_79 * (-0.385709165 )) + (CAC_INT_87 * 
                               (0.3358270483 )) + (CAC_INT_111 * (-0.270040011 )) + (CAC_INT_MAIL_DONOR * (0.0890222229 )) + (CEN_FACTOR5 * (0.9101128926 )) + 
                               (CEN_FACTOR9 * (0.9376669226 )) + (CEN_FAMRACE_1 * (-0.337757795 )) + (CEN_POPOCC_3 * (1.7717188748 )) + (CEN_POPOCC_10 * 
                               (0.5744979438 )) ))));
      *------------------------*;
      *** GET MAX SCORE ***;
      *** ASSIGN tech_dim ***;
      *------------------------*;
      max_tech_score=max(of tech_score_1-tech_score_4);
      if tech_score_1=max_tech_score then tech_dim=1;
      if tech_score_2=max_tech_score then tech_dim=2;
      if tech_score_3=max_tech_score then tech_dim=3;
      if tech_score_4=max_tech_score then tech_dim=4;
      *------------------------*;
      *** CREATE RELATIVE POWER *;
      *------------------------*;
      tech_ratio_1_1=tech_score_1/tech_score_1;
      tech_ratio_1_2=tech_score_1/tech_score_2;
      tech_ratio_1_3=tech_score_1/tech_score_3;
      tech_ratio_1_4=tech_score_1/tech_score_4;
      tech_ratio_2_1=tech_score_2/tech_score_1;
      tech_ratio_2_2=tech_score_2/tech_score_2;
      tech_ratio_2_3=tech_score_2/tech_score_3;
      tech_ratio_2_4=tech_score_2/tech_score_4;
      tech_ratio_3_1=tech_score_3/tech_score_1;
      tech_ratio_3_2=tech_score_3/tech_score_2;
      tech_ratio_3_3=tech_score_3/tech_score_3;
      tech_ratio_3_4=tech_score_3/tech_score_4;
      tech_ratio_4_1=tech_score_4/tech_score_1;
      tech_ratio_4_2=tech_score_4/tech_score_2;
      tech_ratio_4_3=tech_score_4/tech_score_3;
      tech_ratio_4_4=tech_score_4/tech_score_4;
      tech_power1=mean(of tech_ratio_1_1-tech_ratio_1_4);
      tech_power2=mean(of tech_ratio_2_1-tech_ratio_2_4);
      tech_power3=mean(of tech_ratio_3_1-tech_ratio_3_4);
      tech_power4=mean(of tech_ratio_4_1-tech_ratio_4_4);
      *________________________________________________________________________________*;
      * * END TECH SCORING *________________________________________________________________________________*;
      *________________________________________________________________________________*;
      * * ECOMMERCE SCORING *________________________________________________________________________________*;
      *------------------------*;
      *** SCORE 6 MODELS ***;
      *------------------------*;
      ecom_score_1=1 / (1 + (exp(-1 * (-1.956419742 + (M_GEO_CAC_INT_14 * (1.4892341574 )) + (M_GEO_CAC_INT_17 * 
                               (-1.318906704 )) + (M_GEO_CAC_INT_25 * (-1.481043243 )) + (M_GEO_CAC_INT_36 * (-5.64611954 )) + (M_GEO_CAC_INT_47 * (-3.648810225 
                               )) + (M_GEO_CAC_INT_105 * (2.0171192107 )) + (M_GEO_CAC_INT_121 * (2.2966153178 )) + (M_LOR * (-0.02494769 )) + (M_MAIL_DONOR_SNGLE 
                               * (0.2094623213 )) + (M_INC_225_250 * (-0.370808684 )) + (M_INCOME_UNDER_15 * (-0.707990013 )) + (M_OCC_PROF_TECH * (0.2043554839 
                               )) + (M_P1_AGE_35_44 * (0.1918257204 )) + (CAC_DEMO_ADULT_75_PLUS_ENH * (-0.543629013 )) + (CAC_DEMO_ADULT_65_74_ENH * (-0.196728432 )) + 
                               (CAC_DEMO_ADULT_25_34_ENH * (0.1722874951 )) + (CAC_DEMO_EDUCATION_ENH * (0.219315357 )) + (CAC_DEMO_AGE_ENH * (-0.053266129 )) + 
                               (CAC_DEMO_NUM_ADULTS * (-0.118428188 )) + (CAC_DEMO_NARROW_INC_NUM * (0.0053285264 )) + (CAC_HOME_DWELL_TYPE * (-0.363369895 )) + 
                               (CAC_INT_32 * (0.2578467058 )) + (CAC_INT_41 * (0.2671617129 )) + (CAC_INT_45 * (-0.255865843 )) + (CAC_INT_50 * (-0.305457065 )) + 
                               (CAC_INT_65 * (0.3413201057 )) + (CAC_INT_71 * (-0.525732511 )) + (CAC_INT_84 * (-0.362631422 )) + (CAC_INT_97 * (0.2035713345 )) + 
                               (CAC_INT_111 * (0.4971812451 )) + (CAC_INT_114 * (-0.440177663 )) + (CAC_INT_MAIL_BUY * (0.249453551 )) + (CEN_FACTOR6 * 
                               (-2.226565951 )) + (CEN_FACTOR15 * (-3.92043331 )) + (CEN_POPOCC_4 * (-1.522558434 )) ))));
      ecom_score_2=1 / (1 + (exp(-1 * (-0.843952551 + (M_GEO_CAC_INT_37 * (0.7618974639 )) + (M_GEO_CAC_INT_59 * 
                               (-1.260509798 )) + (M_GEO_CAC_INT_69 * (13.307618544 )) + (M_GEO_CAC_INT_92 * (-1.499645549 )) + (M_GEO_CAC_INT_107 * (-1.728905 )) 
                               + (M_GEO_CAC_INT_111 * (0.771982988 )) + (M_GEO_CAC_INT_116 * (3.5804040265 )) + (M_CRED_ANY * (0.1604215215 )) + (M_CRED_DEBIT * 
                               (0.3329774302 )) + (M_CRED_FURNITURE * (0.216170393 )) + (M_LIKELY_RENTER * (-0.314960392 )) + (M_KID_6_10_PRES * (0.2220110351 )) 
                               + (M_MAIL_DONOR_SNGLE * (-0.254668093 )) + (M_INC_55_60 * (0.3895971918 )) + (M_INC_85_90 * (0.3033596066 )) + (M_INC_40_50 * 
                               (0.1665609794 )) + (M_OCC_PROF_TECH * (0.1398995028 )) + (M_P2_AGE_25_34 * (0.1488238868 )) + (M_P2_AGE_75_PLUS * (-0.404518959 )) 
                               + /*(CAC_CRED_VEHICLE_INCOME_INDEX * (-0.025538573 )) + */(CAC_CRED_MORTGAGE_INCOME_INDEX_2 * (0.0212588046 )) + 
                               (CAC_DEMO_ADULT_UNKNOWN_ENH * (0.0761318026 )) + (CAC_DEMO_ADULT_75_PLUS_ENH * (-0.248398583 )) + (CAC_DEMO_ADULT_65_74_ENH * (-0.129652472 )) 
                               + (CAC_DEMO_AGE_ENH * (-0.113370014 )) + (CAC_HOME_RES_LENGTH * (-0.065237868 )) + (CAC_HOME_MTG * (-0.001085128 )) + (CAC_INT_19 * 
                               (0.1293961553 )) + (CAC_INT_47 * (-0.264873479 )) + (CAC_INT_57 * (-0.249269641 )) + (CAC_INT_77 * (-0.327148055 )) + (CAC_INT_111 
                               * (0.1991879639 )) + (CAC_INT_MAIL_BUY * (0.2196012334 )) + (CAC_INT_POL_DONOR * (0.2095814462 )) + (CEN_FACTOR16 * (-1.972766749 
                               )) ))));
      ecom_score_3=1 / (1 + (exp(-1 * (-1.786072934 + (M_GEO_CAC_INT_2 * (-3.122388558 )) + (M_GEO_CAC_INT_17 * 
                               (-1.10732754 )) + (M_GEO_CAC_INT_34 * (1.4689866911 )) + (M_GEO_CAC_INT_91 * (1.1544598475 )) + (M_GEO_CAC_INT_97 * (1.38595163 )) 
                               + (M_CRED_DEBIT * (-0.20634352 )) + (M_CRED_GROCERY * (1.6943473676 )) + (M_CRED_CNT_TYPES * (0.0202598526 )) + (M_FAM_COMP_13 * 
                               (0.2809310943 )) + (M_INC_65_70 * (0.2351368609 )) + (M_INC_75_80 * (-0.319353063 )) + (M_INC_20_30 * (0.1436646947 )) + 
                               (M_OCC_OTHER * (0.3233464873 )) + (M_P1_AGE_65_74 * (0.1990158653 )) + (M_P2_AGE_35_44 * (0.2103936543 )) + (M_P2_AGE_45_54 * 
                               (0.2525507436 )) + (M_P3_AGE_45_54 * (-0.38526045 )) + (CAC_DEMO_ADULT_55_64_ENH * (0.1137917345 )) + (CAC_DEMO_ADULT_65_PLUS_INF_ENH * 
                               (-0.490820912 )) + (CAC_INT_10 * (0.0905632194 )) + (CAC_INT_23 * (-0.164002176 )) + (CAC_INT_36 * (-0.251950132 )) + (CAC_INT_51 * 
                               (0.2458304147 )) + (CAC_INT_57 * (0.190936711 )) + (CAC_INT_77 * (-0.208205157 )) + (CAC_INT_90 * (0.1538541681 )) + (CAC_INT_94 * 
                               (-0.108270981 )) + (CAC_INT_102 * (-0.180504314 )) + (CAC_INT_103 * (0.1706390181 )) + (CAC_INT_113 * (0.3430547199 )) + 
                               (CAC_INT_115 * (-0.178851002 )) + (CEN_FACTOR4 * (1.2170394752 )) + (CEN_FACTOR15 * (-1.445698608 )) + (CEN_POPOCC_1 * 
                               (0.9225737138 )) + (CEN_POPOCC_19 * (0.5087421691 )) ))));
     ecom_score_4=1 / (1 + (exp(-1 * (-0.131893807 + (M_GEO_CAC_INT_31 * (1.059203191 )) + (M_GEO_CAC_INT_100 * 
                               (-0.928398286 )) + (M_CRED_ANY * (-0.136232911 )) + (M_CRED_FIN_BANKING * (0.1481259389 )) + (M_FAM_COMP_03 * (-0.228399522 )) + 
                               (M_FAM_COMP_12 * (-0.14085636 )) + (M_FAM_COMP_14 * (-0.189092937 )) + (M_MAIL_BUY_SINGLE * (-0.141755103 )) + (M_INC_30_35 * 
                               (0.2087607597 )) + (M_INC_50_55 * (0.2266820525 )) + (M_INC_125_150 * (0.1800887447 )) + (M_NUM_KIDS_5PLUS * (0.7405193737 )) + 
                               (M_OCC_PROF_TECH * (-0.133880927 )) + (M_P2_AGE_75_PLUS * (-0.148524005 )) + (M_P3_AGE_45_54 * (0.3072671479 )) + (M_POL_PARTY_DEM 
                               * (0.2555273557 )) + (CAC_CRED_FLAG * (-0.094061776 )) + (CAC_DEMO_EDUCATION_ENH * (-0.07730816 )) + (CAC_DEMO_AGE_ENH * (-0.035776307 )) + 
                               (CAC_INT_25 * (0.1176162988 )) + (CAC_INT_32 * (-0.120684084 )) + (CAC_INT_35 * (-0.124282503 )) + (CAC_INT_59 * (-0.202967214 )) + 
                               (CAC_INT_75 * (-0.296023029 )) + (CAC_INT_78 * (-0.143489611 )) + (CAC_INT_106 * (0.1817590633 )) + (CAC_INT_110 * (-0.177587449 )) 
                               + (CAC_INT_114 * (0.1847478398 )) + (CEN_FACTOR11 * (1.0934098418 )) + (CEN_FACTOR15 * (8.525828003 )) + (CEN_FAMRACE_1 * 
                               (-1.235781648 )) + (CEN_FAMRACE_7 * (1.8662815457 )) + (CEN_POPOCC_14 * (-2.319877591 )) + (CEN_POPOCC_18 * (0.6833960675 )) + 
                               (CEN_POPOCC_25 * (0.7302774191 )) ))));
     ecom_score_5=1 / (1 + (exp(-1 * (-1.806025839 + (M_GEO_CAC_INT_51 * (-3.477518515 )) + (M_GEO_CAC_INT_61 * 
                               (1.663834894 )) + (M_GEO_CAC_INT_102 * (1.3657589966 )) + (M_ADLT_75PLUS_1PLUS * (0.3419103258 )) + (M_CRED_MAIN_RETAIL * 
                               (-0.188074387 )) + (M_KNOWN_OWNER * (-0.150741892 )) + (M_LOR_20_PLUS_YRS * (0.1920610352 )) + (M_INC_150_PLUS * (0.6360308782 )) + 
                               (M_INCOME * (-0.005272225 )) + (M_NUM_ADULT * (0.120683851 )) + (M_OCC_PROF_TECH * (-0.225143076 )) + (M_P2_AGE_25_34 * 
                               (-0.228175791 )) + (M_P2_AGE_45_54 * (-0.134179204 )) + (M_P3_AGE_18_24 * (-0.477359152 )) + (M_P5_AGE_35_44 * (1.1256212786 )) + 
                               (CAC_DEMO_ADULT_65_74_ENH * (0.064132717 )) + (CAC_DEMO_ADULT_35_44_ENH * (-0.115309227 )) + (CAC_DEMO_AGE_ENH * (0.0487654744 )) + 
                               (CAC_DEMO_INCOME_INDEX_ENH * (-0.001480195 )) + (CAC_INT_2 * (0.3503968053 )) + (CAC_INT_10 * (-0.176461853 )) + (CAC_INT_34 * 
                               (0.2337942848 )) + (CAC_INT_84 * (0.189599877 )) + (CAC_INT_98 * (0.18068246 )) + (CAC_INT_100 * (-0.138085643 )) + (CAC_INT_102 * 
                               (0.1889833111 )) + (CAC_INT_107 * (0.1983470565 )) + (CAC_INT_111 * (-0.374280853 )) + (CEN_FACTOR2 * (1.1433712374 )) + 
                               (CEN_FACTOR5 * (1.4026167645 )) + (CEN_FAMRACE_5 * (0.8277892805 )) + (CEN_POPOCC_13 * (0.7125916686 )) + (CEN_POPOCC_14 * 
                               (1.3541672719 )) + (CEN_POPOCC_15 * (-1.537899529 )) + (CEN_POPOCC_22 * (2.990987885 )) ))));
     ecom_score_6=1 / (1 + (exp(-1 * (-2.483351566 + (M_GEO_CAC_INT_7 * (-2.251170699 )) + (M_GEO_CAC_INT_9 * (1.580841616 
                               )) + (M_GEO_CAC_INT_11 * (2.5303397038 )) + (M_GEO_CAC_INT_26 * (1.5792883103 )) + (M_GEO_CAC_INT_32 * (-1.265813838 )) + 
                               (M_GEO_CAC_INT_72 * (-2.203414155 )) + (M_GEO_CAC_INT_90 * (-1.581933533 )) + (M_GEO_CAC_INT_92 * (1.3562093895 )) + 
                               (M_GEO_CAC_INT_108 * (1.3141903437 )) + (M_GEO_CAC_INT_115 * (-1.559324579 )) + (M_ADLT_25_34_1PLUS * (-0.183536577 )) + 
                               (M_CRED_FURNITURE * (-0.196063095 )) + (M_FAM_COMP_13 * (-0.391490053 )) + (M_HOME_OWNER * (-0.248782492 )) + (M_LOR * (0.029172361 
                               )) + (M_INC_75_80 * (0.5003639316 )) + (M_OCC_RETIRED * (0.1748362653 )) + (M_P1_AGE_35_44 * (-0.188742074 )) + (M_P2_AGE_25_34 * 
                               (-0.334555525 )) + (M_P2_AGE_65_74 * (0.3071533583 )) + (M_P2_AGE_75_PLUS * (0.414126482 )) + (M_POL_PARTY_MIX * (0.7410680919 )) + 
                               (CAC_DEMO_AGE_ENH * (0.1121097077 )) + (CAC_DEMO_HH_TYPE_ENH * (0.0167023173 )) + (CAC_DEMO_NARROW_INC_NUM * (-0.004458182 )) + (CAC_INT_32 
                               * (-0.185861023 )) + (CAC_INT_45 * (0.1527674424 )) + (CAC_INT_49 * (0.1287098212 )) + (CAC_INT_71 * (0.2746729044 )) + (CAC_INT_82 
                               * (0.2915932645 )) + (CAC_INT_85 * (0.2556371698 )) + (CAC_INT_98 * (-0.149542525 )) + (CAC_INT_111 * (-0.376267021 )) + 
                               (CEN_FACTOR11 * (-1.166244438 )) + (CEN_POPOCC_10 * (0.8028591927 )) ))));
      *------------------------*;
      *** GET MAX SCORE ***;
      *** ASSIGN ecom_dim ***;
      *------------------------*;
      max_ecom_score=max(of ecom_score_1-ecom_score_6);
      if ecom_score_1=max_ecom_score then ecom_dim=1;
      if ecom_score_2=max_ecom_score then ecom_dim=2;
      if ecom_score_3=max_ecom_score then ecom_dim=3;
      if ecom_score_4=max_ecom_score then ecom_dim=4;
      if ecom_score_5=max_ecom_score then ecom_dim=5;
      if ecom_score_6=max_ecom_score then ecom_dim=6;
      *------------------------*;
      *** CREATE RELATIVE POWER *;
      *------------------------*;
      ecom_ratio_1_1=ecom_score_1/ecom_score_1;
      ecom_ratio_1_2=ecom_score_1/ecom_score_2;
      ecom_ratio_1_3=ecom_score_1/ecom_score_3;
      ecom_ratio_1_4=ecom_score_1/ecom_score_4;
      ecom_ratio_1_5=ecom_score_1/ecom_score_5;
      ecom_ratio_1_6=ecom_score_1/ecom_score_6;
      ecom_ratio_2_1=ecom_score_2/ecom_score_1;
      ecom_ratio_2_2=ecom_score_2/ecom_score_2;
      ecom_ratio_2_3=ecom_score_2/ecom_score_3;
      ecom_ratio_2_4=ecom_score_2/ecom_score_4;
      ecom_ratio_2_5=ecom_score_2/ecom_score_5;
      ecom_ratio_2_6=ecom_score_2/ecom_score_6;
      ecom_ratio_3_1=ecom_score_3/ecom_score_1;
      ecom_ratio_3_2=ecom_score_3/ecom_score_2;
      ecom_ratio_3_3=ecom_score_3/ecom_score_3;
      ecom_ratio_3_4=ecom_score_3/ecom_score_4;
      ecom_ratio_3_5=ecom_score_3/ecom_score_5;
      ecom_ratio_3_6=ecom_score_3/ecom_score_6;
      ecom_ratio_4_1=ecom_score_4/ecom_score_1;
      ecom_ratio_4_2=ecom_score_4/ecom_score_2;
      ecom_ratio_4_3=ecom_score_4/ecom_score_3;
      ecom_ratio_4_4=ecom_score_4/ecom_score_4;
      ecom_ratio_4_5=ecom_score_4/ecom_score_5;
      ecom_ratio_4_6=ecom_score_4/ecom_score_6;
      ecom_ratio_5_1=ecom_score_5/ecom_score_1;
      ecom_ratio_5_2=ecom_score_5/ecom_score_2;
      ecom_ratio_5_3=ecom_score_5/ecom_score_3;
      ecom_ratio_5_4=ecom_score_5/ecom_score_4;
      ecom_ratio_5_5=ecom_score_5/ecom_score_5;
      ecom_ratio_5_6=ecom_score_5/ecom_score_6;
      ecom_ratio_6_1=ecom_score_6/ecom_score_1;
      ecom_ratio_6_2=ecom_score_6/ecom_score_2;
      ecom_ratio_6_3=ecom_score_6/ecom_score_3;
      ecom_ratio_6_4=ecom_score_6/ecom_score_4;
      ecom_ratio_6_5=ecom_score_6/ecom_score_5;
      ecom_ratio_6_6=ecom_score_6/ecom_score_6;
      ecom_power1=mean(of ecom_ratio_1_1-ecom_ratio_1_6);
      ecom_power2=mean(of ecom_ratio_2_1-ecom_ratio_2_6);
      ecom_power3=mean(of ecom_ratio_3_1-ecom_ratio_3_6);
      ecom_power4=mean(of ecom_ratio_4_1-ecom_ratio_4_6);
      ecom_power5=mean(of ecom_ratio_5_1-ecom_ratio_5_6);
      ecom_power6=mean(of ecom_ratio_6_1-ecom_ratio_6_6);
      *________________________________________________________________________________*;
      * * END ECOMMERCE SCORING *________________________________________________________________________________*;
      *________________________________________________________________________________*;
      * * SOCIAL SCORING *________________________________________________________________________________*;
      *------------------------*;
      *** SCORE 4 MODELS ***;
      *------------------------*;
      social_score_1=1 / (1 + (exp(-1 * (-0.331345275 + (M_GEO_CAC_INT_8 * (-3.259158406 )) + (M_GEO_CAC_INT_10 * 
                         (1.1715822336 )) + (M_GEO_CAC_INT_28 * (-1.533671596 )) + (M_GEO_CAC_INT_76 * (3.3106541567 )) + (M_GEO_CAC_INT_94 * (-1.252757414 
                         )) + (M_GEO_CAC_INT_118 * (1.7935563757 )) + (M_ADLT_75PLUS_1PLUS * (-0.739162645 )) + (M_CRED_BANK * (0.1331100082 )) + 
                         (M_FAM_COMP_01 * (-0.237466138 )) + (M_LOR * (-0.031760525 )) + (M_INCOME_UNDER_15 * (-0.483948638 )) + (M_NUM_ADULT_2 * 
                         (-0.142403866 )) + (M_NUM_PERS * (0.1101759981 )) + (M_P2_AGE_25_34 * (0.3836096975 )) + (M_P2_AGE_55_64 * (-0.335068787 )) + 
                         (M_P2_AGE_65_74 * (-0.611740831 )) + (M_P2_AGE_75_PLUS * (-0.99073393 )) + (CAC_DEMO_ADULT_65_74_ENH * (-0.235531207 )) + 
                         (CAC_DEMO_ADULT_18_24_ENH * (0.2260088002 )) + (CAC_DEMO_ADULT_65_PLUS_INF_ENH * (0.6667842913 )) + (CAC_DEMO_EDUCATION_ENH * (0.0880657409 )) 
                         + (CAC_DEMO_AGE_ENH * (-0.268281693 )) + (CAC_DEMO_NARROW_INC_NUM * (0.0014016578 )) + (CAC_INT_9 * (-0.299552073 )) + (CAC_INT_15 * 
                         (0.1659592137 )) + (CAC_INT_89 * (-0.351662409 )) + (CAC_INT_103 * (-0.290704655 )) + (CAC_INT_111 * (0.3306578181 )) + 
                         (CAC_INT_115 * (0.2079834403 )) + (CAC_INT_117 * (0.4853841867 )) + (CEN_FACTOR10 * (-2.247287198 )) + (CEN_FACTOR14 * 
                         (1.6560340815 )) + (CEN_FAMRACE_8 * (1.3877969523 )) + (CEN_POPOCC_13 * (-1.113359667 )) + (CEN_POPOCC_14 * (-1.671360772 )) ))));
      social_score_2=1 / (1 + (exp(-1 * (-1.93868488 + (M_GEO_CAC_INT_3 * (-1.020109356 )) + (M_GEO_CAC_INT_25 * 
                         (-1.124111653 )) + (M_GEO_CAC_INT_79 * (6.9393714624 )) + (M_GEO_CAC_INT_93 * (5.6976769401 )) + (M_ADLT_75PLUS_1PLUS * 
                         (-0.127563491 )) + (M_KID_0_2_PRES * (0.4931952296 )) + (M_KID_3_5_PRES * (0.198220705 )) + (M_LOR_20_PLUS_YRS * (-0.135985701 )) + 
                         (M_LOR * (-0.012570511 )) + (M_INC_40_45 * (-0.321134978 )) + (M_INC_90_95 * (-0.316460708 )) + (M_INC_20_30 * (-0.307307762 )) + 
                         (M_P2_AGE_45_54 * (0.1775500242 )) + (M_P2_AGE_55_64 * (0.1538832676 )) + (M_P4_AGE_75_PLUS * (0.9793529594 )) + 
                         (CAC_DEMO_ADULT_75_PLUS_ENH * (-0.35167681 )) + (CAC_DEMO_EDUCATION_ENH * (0.0442274669 )) + (CAC_DEMO_AGE_ENH * (-0.088249834 )) + (CAC_INT_13 
                         * (-0.192155698 )) + (CAC_INT_17 * (0.2327558381 )) + (CAC_INT_29 * (-0.423891506 )) + (CAC_INT_38 * (-0.222449556 )) + (CAC_INT_41 
                         * (0.3121412167 )) + (CAC_INT_84 * (-0.224547986 )) + (CAC_INT_90 * (0.1743952887 )) + (CAC_INT_94 * (0.121193485 )) + (CAC_INT_95 
                         * (-0.247166976 )) + (CAC_INT_105 * (0.1880793619 )) + (CAC_INT_109 * (-0.221039118 )) + (CAC_INT_111 * (0.3467149746 )) + 
                         (CAC_INT_118 * (0.1509825444 )) + (CEN_FACTOR12 * (-1.753385289 )) + (CEN_FAMRACE_4 * (0.5650941392 )) + (CEN_POPOCC_6 * 
                         (1.4678215849 )) + (CEN_POPOCC_16 * (-1.035569362 )) ))));
      social_score_3=1 / (1 + (exp(-1 * (-0.505803573 + (M_GEO_CAC_INT_3 * (0.9944211301 )) + (M_GEO_CAC_INT_15 * 
                         (0.7955968172 )) + (M_GEO_CAC_INT_35 * (-1.178984982 )) + (M_GEO_CAC_INT_67 * (-5.114752437 )) + (M_GEO_CAC_INT_74 * (5.4522496697 
                         )) + (M_ADLT_45_54_1PLUS * (0.1418817822 )) + (M_ADLT_75PLUS_1PLUS * (-0.577121808 )) + (M_ADLT_UNK_1PLUS * (0.1275320506 )) + 
                         (M_CRED_HOME_OFFICE * (0.5069756269 )) + (M_CRED_CNT_TYPES * (0.0344112037 )) + (M_INC_95_100 * (0.2941626356 )) + 
                         (M_INCOME_UNDER_15 * (-0.179179366 )) + (M_NUM_ADULT_2 * (-0.103685295 )) + (M_OCC_EMP_UNKNOWN * (0.1317206814 )) + (M_P1_AGE_25_34 
                         * (-0.194417294 )) + (M_P1_AGE_65_74 * (-0.137081083 )) + (M_P2_AGE_35_44 * (0.1467677999 )) + (CAC_DEMO_ADULT_65_74_ENH * 
                         (-0.122405538 )) + (CAC_DEMO_AGE_ENH * (-0.148744324 )) + (CAC_DEMO_NARROW_INC_NUM * (0.0012577237 )) + (CAC_HOME_RES_LENGTH * 
                         (-0.048144924 )) + (CAC_INT_9 * (0.19209549 )) + (CAC_INT_26 * (-0.118627566 )) + (CAC_INT_47 * (-0.230282119 )) + (CAC_INT_64 * 
                         (-0.235765099 )) + (CAC_INT_72 * (0.2313784102 )) + (CAC_INT_76 * (-0.300380999 )) + (CAC_INT_78 * (-0.227920267 )) + (CAC_INT_92 * 
                         (0.147022536 )) + (CAC_INT_99 * (-0.409951611 )) + (CEN_FACTOR9 * (1.2469283944 )) + (CEN_FACTOR16 * (2.1520281643 )) + 
                         (CEN_FAMRACE_5 * (0.904398933 )) + (CEN_POPOCC_10 * (-1.922773161 )) + (CEN_POPOCC_21 * (0.7742663621 )) ))));
      social_score_4=1 / (1 + (exp(-1 * (-1.255187161 + (M_GEO_CAC_INT_45 * (1.3305318094 )) + (M_GEO_CAC_INT_87 * 
                         (-3.821705364 )) + (M_ADLT_25_34_1PLUS * (-0.21894605 )) + (M_ADLT_75PLUS_1PLUS * (0.5390978754 )) + (M_ADLT_UNK_1PLUS * 
                         (-0.245814738 )) + (M_CRED_CNT_TYPES * (-0.025579497 )) + (M_FAM_COMP_13 * (-0.507441121 )) + (M_LOR * (0.0360308392 )) + 
                         (M_MAIL_DONOR_SNGLE * (0.1584633398 )) + (M_INCOME_UNDER_15 * (0.2130976002 )) + (M_INC_150_PLUS * (0.2173065054 )) + 
                         (M_P2_AGE_25_34 * (-0.340061016 )) + (M_P2_AGE_35_44 * (-0.41952151 )) + (M_P2_AGE_45_54 * (-0.279577773 )) + (M_P2_AGE_75_PLUS * 
                         (0.3080434791 )) + (CAC_DEMO_ADULT_65_74_ENH * (0.1804466141 )) + (CAC_DEMO_ADULT_18_24_ENH * (-0.261846136 )) + (CAC_DEMO_AGE_ENH * 
                         (0.2499524459 )) + (CAC_DEMO_NUM_GENERATIONS_ENH * (-0.068585366 )) + (CAC_DEMO_NARROW_INC_NUM * (-0.003207649 )) + (CAC_INT_15 * 
                         (-0.146566163 )) + (CAC_INT_17 * (-0.16847598 )) + (CAC_INT_20 * (0.1760163769 )) + (CAC_INT_38 * (0.2044021768 )) + (CAC_INT_45 * 
                         (0.1554409616 )) + (CAC_INT_47 * (0.2441394737 )) + (CAC_INT_78 * (0.2069326284 )) + (CAC_INT_89 * (0.2271961606 )) + (CAC_INT_92 * 
                         (-0.184337857 )) + (CAC_INT_111 * (-0.331315513 )) + (CEN_POPOCC_10 * (1.1886579686 )) + (CEN_POPOCC_16 * (0.9431781409 )) + 
                         (CEN_POPOCC_17 * (0.7747418034 )) ))));
      social_dim=social_score_1/social_score_4;
      if social_dim=. then social_dim=6;
      *--- 127 people *;
      *________________________________________________________________________________*;
      * * END social SCORING *________________________________________________________________________________*;
      *________________________________________________________________________________*;
      * * INFLUENCER SCORING *________________________________________________________________________________*;
      *------------------------*;
      *** SCORE 4 MODELS ***;
      *------------------------*;
      influence_score_1=1 / (1 + (exp(-1 * (0.6519139694 + (M_GEO_CAC_INT_4 * (-1.080240863 )) + (M_GEO_CAC_INT_13 * 
                            (1.3066933689 )) + (M_GEO_CAC_INT_26 * (-1.065466255 )) + (M_GEO_CAC_INT_39 * (-1.432662497 )) + (M_GEO_CAC_INT_58 * (-1.701382274 
                            )) + (M_GEO_CAC_INT_120 * (2.4289341732 )) + (M_ADLT_25_34_1PLUS * (0.2592174988 )) + (M_ADLT_35_44_1PLUS * (0.1273931052 )) + 
                            (M_ADLT_45_54_1PLUS * (0.1506866743 )) + (M_ADLT_75PLUS_1PLUS * (-0.256202278 )) + (M_FAM_COMP_11 * (0.3267515633 )) + 
                            (M_FAM_COMP_12 * (0.2568836961 )) + (M_LOR_20_PLUS_YRS * (-0.140712496 )) + (M_MAIL_DONOR_SNGLE * (-0.177225676 )) + (M_INC_35_40 * 
                            (-0.24177981 )) + (M_INC_140_145 * (0.3256669885 )) + (M_P2_AGE_18_24 * (0.3696198003 )) + (M_P2_AGE_65_74 * (-0.213183477 )) + 
                            (M_P4_AGE_75_PLUS * (0.6470999624 )) + (M_TXL_GENDER_F * (-0.217817039 )) + (CAC_DEMO_ADULT_UNKNOWN_ENH * (0.0853787604 )) + 
                            (CAC_DEMO_AGE_ENH * (-0.064616217 )) + (CAC_INT_5 * (0.1679376846 )) + (CAC_INT_18 * (0.2646452529 )) + (CAC_INT_20 * (-0.15656836 )) + 
                            (CAC_INT_23 * (0.1754550293 )) + (CAC_INT_35 * (-0.098713293 )) + (CAC_INT_49 * (-0.121597929 )) + (CAC_INT_64 * (-0.228410953 )) + 
                            (CAC_INT_75 * (-0.370252944 )) + (CAC_INT_111 * (0.1585753401 )) + (CAC_INT_116 * (0.2979475769 )) + (CEN_FACTOR15 * (2.9024327566 
                            )) + (CEN_FAMRACE_5 * (-0.752719992 )) + (CEN_POPOCC_15 * (-1.230066431 )) ))));
      influence_score_2=1 / (1 + (exp(-1 * (-1.491562251 + (M_GEO_CAC_INT_1 * (-1.148785892 )) + (M_GEO_CAC_INT_3 * 
                            (-0.652723166 )) + (M_GEO_CAC_INT_25 * (0.8264339335 )) + (M_GEO_CAC_INT_38 * (0.6433307088 )) + (M_GEO_CAC_INT_51 * (2.1614400956 
                            )) + (M_GEO_CAC_INT_52 * (1.704923046 )) + (M_GEO_CAC_INT_68 * (-1.957360205 )) + (M_GEO_CAC_INT_73 * (4.3691054235 )) + 
                            (M_GEO_CAC_INT_92 * (-0.619401476 )) + (M_GEO_CAC_INT_96 * (-0.971414274 )) + (M_GEO_CAC_INT_109 * (1.86344747 )) + 
                            (M_GEO_CAC_INT_116 * (-2.673234632 )) + (M_GEO_CAC_INT_120 * (-2.752581156 )) + (M_CRED_EDUCATION * (0.7413884823 )) + 
                            (M_CRED_MASTERCARD * (-0.250580076 )) + (M_CRED_HIGH_RETAIL * (-0.202337547 )) + (M_KID_16_17_PRES * (0.1930749755 )) + 
                            (M_LOR_0_6MOS * (-0.818512934 )) + (M_INC_75_80 * (-0.338862477 )) + (M_INC_115_120 * (-0.324248321 )) + (M_NUM_PERS_4 * 
                            (-0.121424845 )) + (M_OCC_OTHER * (0.3825668059 )) + (M_P1_AGE_65_74 * (-0.237891947 )) + (M_P1_AGE_75_PLUS * (-0.469813301 )) + 
                            (M_P3_AGE_55_64 * (0.2744936763 )) + (CAC_DEMO_ADULT_45_64_INF_ENH * (-0.437626273 )) + (CAC_INT_2 * (0.2709066977 )) + (CAC_INT_5 * 
                            (-0.155635953 )) + (CAC_INT_10 * (-0.149499272 )) + (CAC_INT_77 * (0.2131420811 )) + (CAC_INT_84 * (0.2503478585 )) + (CAC_INT_87 * 
                            (0.391465238 )) + (CAC_INT_116 * (-0.344357067 )) + (CEN_POPOCC_8 * (0.8544986595 )) + (CEN_POPOCC_14 * (-2.245942213 )) ))));
      influence_score_3=1 / (1 + (exp(-1 * (-1.929297908 + (M_GEO_CAC_INT_49 * (0.7159892676 )) + (M_GEO_CAC_INT_62 * 
                            (-1.662158126 )) + (M_GEO_CAC_INT_65 * (-2.174071528 )) + (M_GEO_CAC_INT_68 * (1.6947920089 )) + (M_GEO_CAC_INT_73 * (4.0231891301 
                            )) + (M_GEO_CAC_INT_78 * (-1.402596604 )) + (M_GEO_CAC_INT_83 * (-2.528512978 )) + (M_GEO_CAC_INT_90 * (-2.468391853 )) + 
                            (M_GEO_CAC_INT_91 * (1.1130191793 )) + (M_GEO_CAC_INT_100 * (0.9876623265 )) + (M_GEO_CAC_INT_103 * (2.439578214 )) + 
                            (M_GEO_CAC_INT_116 * (1.9256337004 )) + (M_CRED_FIN_SER_ * (0.2953451649 )) + (M_CRED_STD_RETAIL * (0.086427404 )) + 
                            (M_CRED_CNT_TYPES * (0.0082043987 )) + (M_FAM_COMP_14 * (0.1376093213 )) + (M_KNOWN_RENTER * (-0.248055052 )) + (M_INCOME_UNDER_15 
                            * (-0.194306585 )) + (M_OCC_PROPRIETER * (-0.270354895 )) + (M_P2_AGE_45_54 * (-0.086598982 )) + (M_P4_AGE_75_PLUS * (-0.58325451 
                            )) + (M_MARRIED_PRESENT * (0.1030857776 )) + (CAC_DEMO_ADULT_UNKNOWN_ENH * (-0.056340555 )) + (CAC_DEMO_ADULT_18_24_ENH * (-0.115589917 )) 
                            + (CAC_DEMO_AGE_ENH * (0.0361742898 )) + (CAC_HOME_VALUATION_MODEL_ENH * (0.0001850078 )) + (CAC_INT_20 * (0.1599483616 )) + (CAC_INT_31 * 
                            (0.1205661233 )) + (CAC_INT_48 * (-0.36758847 )) + (CAC_INT_75 * (0.1664103321 )) + (CAC_INT_77 * (-0.202547541 )) + (CAC_INT_94 * 
                            (-0.083714017 )) + (CAC_INT_99 * (0.2225177966 )) + (CEN_FACTOR18 * (-1.39301951 )) + (CEN_POPOCC_3 * (1.7519335968 )) ))));
      influence_score_4=1 / (1 + (exp(-1 * (-2.104299705 + (M_GEO_CAC_INT_10 * (-1.352959937 )) + (M_GEO_CAC_INT_28 * 
                            (0.9975195185 )) + (M_GEO_CAC_INT_72 * (-2.465973761 )) + (M_GEO_CAC_INT_73 * (-5.624820474 )) + (M_GEO_CAC_INT_77 * (2.056098974 
                            )) + (M_GEO_CAC_INT_90 * (1.4983796506 )) + (M_GEO_CAC_INT_104 * (-0.18082735 )) + (M_GEO_CAC_INT_106 * (1.4141790447 )) + 
                            (M_ADLT_75PLUS_1PLUS * (0.488913687 )) + (M_KID_3_5_PRES * (0.1846694025 )) + (M_LOR_0_6MOS * (0.8082690268 )) + (M_LOR_20_PLUS_YRS 
                            * (0.1967682181 )) + (M_INCOME_UNDER_15 * (0.1687152068 )) + (M_P2_AGE_18_24 * (-0.54187011 )) + (M_P2_AGE_25_34 * (-0.330335756 )) 
                            + (M_P2_AGE_35_44 * (-0.182989511 )) + (M_P2_AGE_55_64 * (0.1640681021 )) + (M_TXL_GENDER_M * (-0.256065128 )) + 
                            (CAC_CRED_FINANCIAL_INSTALLMENT * (-0.121907164 )) + (CAC_DEMO_ADULT_65_74_ENH * (0.1176305355 )) + (CAC_DEMO_ADULT_45_64_INF_ENH * 
                            (0.4097365952 )) + (CAC_DEMO_AGE_ENH * (0.0653957358 )) + (CAC_DEMO_INCOME_INDEX_ENH * (-0.000847552 )) + (CAC_INT_4 * (0.1289669362 )) + 
                            (CAC_INT_16 * (0.1596046591 )) + (CAC_INT_18 * (-0.261997562 )) + (CAC_INT_38 * (-0.170782226 )) + (CAC_INT_61 * (-0.302153207 )) + 
                            (CAC_INT_64 * (0.324071609 )) + (CAC_INT_95 * (0.1784455543 )) + (CAC_INT_107 * (-0.215790862 )) + (CAC_INT_111 * (-0.187372491 )) 
                            + (CEN_FAMRACE_1 * (-0.357480554 )) + (CEN_POPOCC_14 * (1.3919731019 )) + (CEN_POPOCC_25 * (0.7845559432 )) ))));
      influence_dim=influence_score_1/influence_score_4;
      if influence_dim=. then influence_dim=6;
      *________________________________________________________________________________*;
      * * END INFLUENCER SCORING *________________________________________________________________________________*;
      *________________________________________________________________________________*;
      * * PROC RANK REPLACED WITH HARD CODES *_________________________________________*;
      %rankvars;

      *________________________________________________________________________________*;
      * * TECHNOLOGY SCORING *________________________________________________________________________________*;
      *------------------------*;
      *** GET MAX SCORE RANK ***;
      *** ASSIGN tech_dim_rank ***;
      *------------------------*;

      max_tech_rank=max(of tech_rank_score_1-tech_rank_score_4);
      if tech_rank_score_1=max_tech_rank then tech_dim_rank=1;
      if tech_rank_score_2=max_tech_rank then tech_dim_rank=2;
      if tech_rank_score_3=max_tech_rank then tech_dim_rank=3;
      if tech_rank_score_4=max_tech_rank then tech_dim_rank=4;
      *------------------------*;
      *** GET MAX POWER (ratio) RANK ***;
      *** ASSIGN ratio ***;
      *------------------------*;
      max_tech_pow=max(of tech_rank_power1-tech_rank_power4);
      if max_tech_pow=tech_rank_power1 then tech_ratio=1;
      if max_tech_pow=tech_rank_power2 then tech_ratio=2;
      if max_tech_pow=tech_rank_power3 then tech_ratio=3;
      if max_tech_pow=tech_rank_power4 then tech_ratio=4;
      *------------------------*;
      *** ADJUSTMENTS ***;
      *------------------------*;
      if tech_dim_rank=3 then tech_combined=3;
      else if tech_dim_rank=4 then tech_combined=4;
      else if tech_ratio=1 then tech_combined=1;
      else if tech_ratio=2 then tech_combined=2;
      if tech_combined=2 and tech_rank_score_2<40 then tech_combined=3;
      if tech_combined=4 and (tech_rank_score_4<10 or tech_rank_score_3>75) then tech_combined=3;
      if tech_combined=. then tech_combined=3;
      label cac_silh_tech= 'CAC Group Silhouettes: Technology Attitudes';
      cac_silh_tech=tech_combined;
      *________________________________________________________________________________*;
      * * END TECHNOLOGY SCORING *________________________________________________________________________________*;
      *________________________________________________________________________________*;
      * * ECOMMERCE SCORING *________________________________________________________________________________*;
      *------------------------*;
      *** GET MAX SCORE RANK ***;
      *** ASSIGN ecom_dim_rank ***;
      *------------------------*;
      max_ecom_rank=max(of ecom_rank_score_1-ecom_rank_score_6);
      if ecom_rank_score_1=max_ecom_rank then ecom_dim_rank=1;
      if ecom_rank_score_2=max_ecom_rank then ecom_dim_rank=2;
      if ecom_rank_score_3=max_ecom_rank then ecom_dim_rank=3;
      if ecom_rank_score_4=max_ecom_rank then ecom_dim_rank=4;
      if ecom_rank_score_5=max_ecom_rank then ecom_dim_rank=5;
      if ecom_rank_score_6=max_ecom_rank then ecom_dim_rank=6;
      *------------------------*;
      *** GET MAX POWER (ratio) RANK ***;
      *** ASSIGN ratio ***;
      *------------------------*;
      max_ecom_pow=max(of ecom_rank_power1-ecom_rank_power6);
      if max_ecom_pow=ecom_rank_power1 then ecom_ratio=1;
      if max_ecom_pow=ecom_rank_power2 then ecom_ratio=2;
      if max_ecom_pow=ecom_rank_power3 then ecom_ratio=3;
      if max_ecom_pow=ecom_rank_power4 then ecom_ratio=4;
      if max_ecom_pow=ecom_rank_power5 then ecom_ratio=5;
      if max_ecom_pow=ecom_rank_power6 then ecom_ratio=6;
      *------------------------*;
      *** ADJUSTMENTS ***;
      *------------------------*;
      if ecom_dim_rank=3 then ecom_combined=3;
      else if ecom_dim_rank=5 then ecom_combined=5;
      else if ecom_dim=6 then ecom_combined=6;
      else if ecom_dim=4 then ecom_combined=4;
      else if ecom_dim=2 then ecom_combined=2;
      else if ecom_ratio=1 then ecom_combined=1;
      else ecom_combined=1;
      if ecom_combined=2 and ecom_rank_score_1>60 then ecom_combined=1;
      if ecom_combined=3 and ecom_rank_score_2>60 then ecom_combined=2;
      if ecom_combined=4 then do;
         if ecom_rank_score_3>50 or ecom_rank_score_2>50 or ecom_rank_score_1 >50 then ecom_combined=3;
         else ecom_combined=5;
      end;
      if ecom_combined=5 and (ecom_rank_score_5<10 or ecom_rank_score_6>75) then ecom_combined=6;
      if ecom_combined>4 then ecom_combined=ecom_combined-1;
      label cac_silh_ecom= 'CAC Group Silhouettes: eCommerce Attitudes';
      cac_silh_ecom=ecom_combined;
      *________________________________________________________________________________*;
      * * END ECOMMERCE SCORING *________________________________________________________________________________*;
      *________________________________________________________________________________*;
      * * SOCIAL SCORING *________________________________________________________________________________*;
      label cac_silh_social= 'CAC Group Silhouettes: Social Networking/Media Engagement';
      cac_silh_social=ceil((100-social_rank_score)/10);
      *________________________________________________________________________________*;
      * * END SOCIAL SCORING *________________________________________________________________________________*;
      * * SOCIAL SCORING *________________________________________________________________________________*;
      label cac_silh_dig_inf= 'CAC Group Silhouettes: Digial Influencer';
      cac_silh_dig_inf=ceil((100-influence_rank_score)/10);
      *________________________________________________________________________________*;
      * * END SOCIAL SCORING *________________________________________________________________________________*;
      cac_silh_lifestage=cac_lifestage;
      cac_silh_lifestage_group=cac_lifestage_group;
      cac_silh_lifestyle=cac_style_group;
      *FIX STUPID MISSINGS*;
      cac_silh_buy_style_group=cac_silh_buy_style_group+1;
      if cac_silh_lifestyle=.  then cac_silh_lifestyle=19;
      if cac_silh_geo in (9,99) then cac_silh_geo=1;
      cac_silh_socio_group_lc=cac_silh_socio_group;
      if cac_silh_socio_group_lc=. then cac_silh_socio_group_lc=1;
      if cac_silh_socio_group_lc>7 then cac_silh_socio_group_lc=cac_silh_socio_group_lc-3;

      *APPLY GEO FOR LATENT*;
      cac_silh_geo_lc=put(cac_addr_zip,$geolc.)+0;
      if cac_silh_geo_lc=6 then cac_silh_geo_lc=1;   *--- only 9 people on point1pct file so just collapsing---*;
      *SPLIT SocioE FOR LATENT*;
           /*INCOME: low-to-high: 1-9 */
      if cac_silh_socio_group_lc=1 then cac_silh_socio_income=1;          /*non-owner,1250-or less */
      else if cac_silh_socio_group_lc=2 then cac_silh_socio_income=2;          /*non-owner,1250-2500 */
      else if cac_silh_socio_group_lc=3 then cac_silh_socio_income=3;          /*non-owner,2500-3333 */
      else if cac_silh_socio_group_lc=4 then cac_silh_socio_income=4;          /*non-owner,3333-4167 */
      else if cac_silh_socio_group_lc=5 then cac_silh_socio_income=5;          /*non-owner,4167-6250 */
      else if cac_silh_socio_group_lc=6 then cac_silh_socio_income=6;          /*non-owner,6250-8333 */
      else if cac_silh_socio_group_lc=7 then cac_silh_socio_income=7;          /*non-owner,8333-or more */
      else if cac_silh_socio_group_lc=8 then cac_silh_socio_income=1;          /*Homeowner,1250-or less */
      else if cac_silh_socio_group_lc=9 then cac_silh_socio_income=2;          /*Homeowner,1250-2500 */
      else if cac_silh_socio_group_lc=10 then cac_silh_socio_income=3;          /*Homeowner,2500-3333 */
      else if cac_silh_socio_group_lc=11 then cac_silh_socio_income=4;          /*Homeowner,3333-4167 */
      else if cac_silh_socio_group_lc=12 then cac_silh_socio_income=5;          /*Homeowner,4167-6250 */
      else if cac_silh_socio_group_lc=13 then cac_silh_socio_income=6;          /*Homeowner,6250-8333 */
      else if cac_silh_socio_group_lc=14 then cac_silh_socio_income=7;          /*Homeowner,8333-10417 */
      else if cac_silh_socio_group_lc=15 then cac_silh_socio_income=8;          /*Homeowner,10417-12500 */
      else if cac_silh_socio_group_lc=16 then cac_silh_socio_income=9;          /*Homeowner,12500-or more*/

           /*HO: 1=rent, 2=own*/
      if cac_silh_socio_group_lc=1 then cac_silh_socio_ho=1;          /*non-owner,1250-or less */
      else if cac_silh_socio_group_lc=2 then cac_silh_socio_ho=1;          /*non-owner,1250-2500 */
      else if cac_silh_socio_group_lc=3 then cac_silh_socio_ho=1;          /*non-owner,2500-3333 */
      else if cac_silh_socio_group_lc=4 then cac_silh_socio_ho=1;          /*non-owner,3333-4167 */
      else if cac_silh_socio_group_lc=5 then cac_silh_socio_ho=1;          /*non-owner,4167-6250 */
      else if cac_silh_socio_group_lc=6 then cac_silh_socio_ho=1;          /*non-owner,6250-8333 */
      else if cac_silh_socio_group_lc=7 then cac_silh_socio_ho=1;          /*non-owner,8333-or more */
      else if cac_silh_socio_group_lc=8 then cac_silh_socio_ho=2;          /*Homeowner,1250-or less */
      else if cac_silh_socio_group_lc=9 then cac_silh_socio_ho=2;          /*Homeowner,1250-2500 */
      else if cac_silh_socio_group_lc=10 then cac_silh_socio_ho=2;          /*Homeowner,2500-3333 */
      else if cac_silh_socio_group_lc=11 then cac_silh_socio_ho=2;          /*Homeowner,3333-4167 */
      else if cac_silh_socio_group_lc=12 then cac_silh_socio_ho=2;          /*Homeowner,4167-6250 */
      else if cac_silh_socio_group_lc=13 then cac_silh_socio_ho=2;          /*Homeowner,6250-8333 */
      else if cac_silh_socio_group_lc=14 then cac_silh_socio_ho=2;          /*Homeowner,8333-10417 */
      else if cac_silh_socio_group_lc=15 then cac_silh_socio_ho=2;          /*Homeowner,10417-12500 */
      else if cac_silh_socio_group_lc=16 then cac_silh_socio_ho=2;          /*Homeowner,12500-or more*/



      *SPLIT LS FOR LATENT*;
           /*COMP: 1=Single, 2=Couple, 3=Family*/
      if cac_silh_lifestage_group=1 then cac_silh_lifestage_comp=1;          /*Young Singles*/
      else if cac_silh_lifestage_group=2 then cac_silh_lifestage_comp=3;          /*Young Parents*/
      else if cac_silh_lifestage_group=3 then cac_silh_lifestage_comp=2;          /*Young Couples*/
      else if cac_silh_lifestage_group=4 then cac_silh_lifestage_comp=1;          /*Young Single Parents*/
      else if cac_silh_lifestage_group=5 then cac_silh_lifestage_comp=3;          /*Emerging Parents*/
      else if cac_silh_lifestage_group=6 then cac_silh_lifestage_comp=1;          /*Emerging Singles*/
      else if cac_silh_lifestage_group=7 then cac_silh_lifestage_comp=2;          /*Emerging Couples*/
      else if cac_silh_lifestage_group=8 then cac_silh_lifestage_comp=2;          /*Established Couple*/
      else if cac_silh_lifestage_group=9 then cac_silh_lifestage_comp=3;          /*Established Family*/
      else if cac_silh_lifestage_group=10 then cac_silh_lifestage_comp=1;          /*Established Singles*/
      else if cac_silh_lifestage_group=11 then cac_silh_lifestage_comp=3;          /*Established Single Parents*/
      else if cac_silh_lifestage_group=12 then cac_silh_lifestage_comp=2;          /*Empty Nesters*/
      else if cac_silh_lifestage_group=13 then cac_silh_lifestage_comp=1;          /*Pre-Retired Singles*/
      else if cac_silh_lifestage_group=14 then cac_silh_lifestage_comp=3;          /*Almost Empty Nesters*/
      else if cac_silh_lifestage_group=15 then cac_silh_lifestage_comp=2;          /*Retired Couples*/
      else if cac_silh_lifestage_group=16 then cac_silh_lifestage_comp=1;          /*Retired Singles*/
      else if cac_silh_lifestage_group=17 then cac_silh_lifestage_comp=1;          /*Elderly Singles*/
      else if cac_silh_lifestage_group=18 then cac_silh_lifestage_comp=2;          /*Elderly Couples*/
      else if cac_silh_lifestage_group=19 then cac_silh_lifestage_comp=2;          /*???*/

         /*Age: 1=Young, 2=Emerging, 3=Established, 4=Pre-Retired, 5=Retired, 6=Elderly*/
      if cac_silh_lifestage_group=1 then cac_silh_lifestage_age=1;          /*Young Singles*/
      else if cac_silh_lifestage_group=2 then cac_silh_lifestage_age=1;          /*Young Parents*/
      else if cac_silh_lifestage_group=3 then cac_silh_lifestage_age=1;          /*Young Couples*/
      else if cac_silh_lifestage_group=4 then cac_silh_lifestage_age=1;          /*Young Single Parents*/
      else if cac_silh_lifestage_group=5 then cac_silh_lifestage_age=2;          /*Emerging Parents*/
      else if cac_silh_lifestage_group=6 then cac_silh_lifestage_age=2;          /*Emerging Singles*/
      else if cac_silh_lifestage_group=7 then cac_silh_lifestage_age=2;          /*Emerging Couples*/
      else if cac_silh_lifestage_group=8 then cac_silh_lifestage_age=3;          /*Established Couple*/
      else if cac_silh_lifestage_group=9 then cac_silh_lifestage_age=3;          /*Established Family*/
      else if cac_silh_lifestage_group=10 then cac_silh_lifestage_age=3;          /*Established Singles*/
      else if cac_silh_lifestage_group=11 then cac_silh_lifestage_age=3;          /*Established Single Parents*/
      else if cac_silh_lifestage_group=12 then cac_silh_lifestage_age=4;          /*Empty Nesters*/
      else if cac_silh_lifestage_group=13 then cac_silh_lifestage_age=4;          /*Pre-Retired Singles*/
      else if cac_silh_lifestage_group=14 then cac_silh_lifestage_age=4;          /*Almost Empty Nesters*/
      else if cac_silh_lifestage_group=15 then cac_silh_lifestage_age=5;          /*Retired Couples*/
      else if cac_silh_lifestage_group=16 then cac_silh_lifestage_age=5;          /*Retired Singles*/
      else if cac_silh_lifestage_group=17 then cac_silh_lifestage_age=6;          /*Elderly Singles*/
      else if cac_silh_lifestage_group=18 then cac_silh_lifestage_age=6;          /*Elderly Couples*/
      else if cac_silh_lifestage_group=19 then cac_silh_lifestage_age=3;          /*???*/

      array out (11) $ 2 _CAC_SILH_LIFESTAGE_AGE _CAC_SILH_LIFESTAGE_COMP _CAC_SILH_SOCIO_HO _CAC_SILH_SOCIO_INCOME _CAC_SILH_GEO_LC _cac_silh_ecom _cac_silh_tech _cac_silh_buy_style_group _cac_silh_dig_inf _cac_silh_social _cac_silh_lifestyle;
      array in (11)       CAC_SILH_LIFESTAGE_AGE  CAC_SILH_LIFESTAGE_COMP  CAC_SILH_SOCIO_HO  CAC_SILH_SOCIO_INCOME  CAC_SILH_GEO_LC  cac_silh_ecom  cac_silh_tech  cac_silh_buy_style_group  cac_silh_dig_inf  cac_silh_social  cac_silh_lifestyle;
      do jjds=1 to 11;
        out(jjds)=put(in(jjds),$2.);
      end; 
      drop jjds CAC_SILH_LIFESTAGE_AGE CAC_SILH_LIFESTAGE_COMP CAC_SILH_SOCIO_HO CAC_SILH_SOCIO_INCOME CAC_SILH_GEO_LC;
   
      cac_silh_lifedriver=1;
      cac_silh=1;   
      cac_silh_lifestage_macro=1;

      %lc_final;

      * CHANGE MISSING VALUES IN SILH DIMENSION WITH MOST PREVALENT VALUE;
      
      if cac_silh_lifestage_age=. then cac_silh_lifestage_age=3;
      if cac_silh_lifestage_comp=. then cac_silh_lifestage_comp=2;
      if cac_silh_socio_ho=. then cac_silh_socio_ho=1;
      if cac_silh_socio_income=. then cac_silh_socio_income=4;
      if cac_silh_geo_lc=. then cac_silh_geo_lc=1;
      
      lc = jds{CAC_SILH_LIFESTAGE_AGE, CAC_SILH_LIFESTAGE_COMP, CAC_SILH_SOCIO_HO, CAC_SILH_SOCIO_INCOME, CAC_SILH_GEO_LC};

      if lc=1 then do;
        if cac_silh_lifestage_age>3 or
           cac_silh_lifestage_comp>1 or 
           cac_silh_socio_ho>1 then lc=100;
      end;
      else if lc=10 then do;
         if cac_silh_lifestage_age>3 or
            cac_silh_lifestage_comp>1 then lc=100;
      end;
      else if lc=11 then do;
         if cac_silh_lifestage_comp<3 then lc=100;
      end;
      else if lc=2 then do;
         if cac_silh_lifestage_comp=1 then lc=100;
      end;
      else if lc=3 then do;
         if cac_silh_lifestage_age=1 then lc=100;
      end;
      else if lc=4 then do;
         if cac_silh_lifestage_comp>1 then lc=100;
      end;        
      else if lc=5 then do;
         if cac_silh_lifestage_comp=1 or
            cac_silh_socio_ho=1 then lc=100;
      end;        
      else if lc=6 then do;
         if cac_silh_lifestage_age<4 then lc=100;
      end;        



      else if lc=8 then do;
         if cac_silh_lifestage_age<4 then lc=100;
      end;        
      else if lc=9 then do;
         if cac_silh_lifestage_comp<3 then lc=100;
      end;        

           if lc=1 then seg= 101 ;
      else if lc=2 then seg= 801 ;
      else if lc=3 then seg= 701 ;
      else if lc=4 then seg= 601 ;
      else if lc=5 then seg= 99901 ;
      else if lc=6 then seg= 9999901 ;
      else if lc=7 then seg= 501 ;
      else if lc=8 then seg= 999901;
      else if lc=9 then seg=  401;
      else if lc=10 then seg= 201 ;
      else if lc=11 then seg= 301 ;
      else if lc=100 then seg= 99999901 ;

      if lc=100 then do;
         if cac_silh_geo_lc in (3,4) then seg=901;
         else seg=9901;
      end;
      ******************************************************************************;
      *** From /project/SILHOUETTES/CODE/CLUSTER//120_score_all_from_profile.sas ***;
      *** Modified 8/1/2012                                                      ***;
      *** Author: Brad Rukstales                                                 ***;
      ******************************************************************************;
      if seg="901" and _CAC_SILH_lifestage_age<=3 and _CAC_SILH_lifestage_comp <=2 then seg="101";
      if seg="9999901" then seg="999901";
      if seg="301" then do;
         if _cac_silh_geo_lc=5 then seg="501"; else
         if _CAC_SILH_SOCIO_INCOME>=6 then seg="501";
         else seg="401";
      end;
      if seg="901" then do;
         if _cac_silh_lifestage_comp=3 then seg="401"; else
         seg="999901";
      end;
      if seg="9901" then do;
         if _cac_silh_geo_lc=5 then seg="501"; else
         if _CAC_SILH_SOCIO_INCOME>=6 then seg="501"; else
         if _cac_silh_lifestage_comp=1 then seg="101"; else
         if _cac_silh_lifestage_comp=3 then seg="401";  else
         seg="701";
      end;
      
      max_bstyle=-99999;
      *array CAC_SILH_BUY_STYLE_{6};
      array for_now{6} cac_silh_buy_style_1-cac_silh_buy_style_6;
      do i=1 to 6;
         *if cac_silh_buy_style_{i}>max_bstyle then do;
         if for_now{i}>max_bstyle then do;
            max_bstyle=for_now{i};
            max_buystyle=i;
          end;
      end;
      
      cac_buystyle_max=max_buystyle;
      
      length seg_macro $ 5;
      if seg="101" then substr(seg_macro,1,1)="A"; else
      if seg="201" then substr(seg_macro,1,1)="B"; else
      if seg="401" then substr(seg_macro,1,1)="C"; else
      if seg="501" then substr(seg_macro,1,1)="D"; else
      if seg="601" then substr(seg_macro,1,1)="E"; else
      if seg="701" then substr(seg_macro,1,1)="F"; else
      if seg="801" then substr(seg_macro,1,1)="G"; else
      if seg="9901" then substr(seg_macro,1,1)="H"; else
      if seg="99901" then substr(seg_macro,1,1)="I"; else
      if seg="999901" then substr(seg_macro,1,1)="J"; else
      substr(seg_macro,1,1)="Z"; 
      
      if seg_macro="A" then do;
         if cac_ind1_gender=1 then substr(seg_macro,2,1)="M"; else
           substr(seg_macro,2,1)="F"; 
      end;
      
      *****************;
      *GROUP LIFESTYLE*;
      *****************;
      
      *OUTDOORS AND EXERCISE*;
         if _cac_silh_lifestyle in (1, 13) then cac_silh_lstyle_macro=1;
         else if _cac_silh_lifestyle in (2, 9) then cac_silh_lstyle_macro=2;
         else if _cac_silh_lifestyle in (10, 15) then cac_silh_lstyle_macro=3;
         else if _cac_silh_lifestyle in (3, 6, 14) then cac_silh_lstyle_macro=4;
         else if _cac_silh_lifestyle in (4, 8, 18) then cac_silh_lstyle_macro=5;
         else if _cac_silh_lifestyle in (7, 12, 16) then cac_silh_lstyle_macro=6;
         else if _cac_silh_lifestyle in (17, 11) then cac_silh_lstyle_macro=7;
         else if _cac_silh_lifestyle in (5) then cac_silh_lstyle_macro=8;
         else cac_silh_lstyle_macro=99;
      
      
      ***************************************;
      *GET DECILES FOR BUYSTYLE GROUPS 4  5*;
      ***************************************;
      *CAC_SILH_BUY_STYLE_GROUP IS 4 FOR BRAND LOYAL BUT RANKS WERE NOT SHIFTED*;
         if cac_silh_buy_style_rank_3=0 then cac_silh_loyal=1;
         else if cac_silh_buy_style_rank_3=1 then cac_silh_loyal=1;
         else if cac_silh_buy_style_rank_3=2 then cac_silh_loyal=2;
         else if cac_silh_buy_style_rank_3=3 then cac_silh_loyal=2;
         else if cac_silh_buy_style_rank_3=4 then cac_silh_loyal=3;
         else if cac_silh_buy_style_rank_3=5 then cac_silh_loyal=3;
         else if cac_silh_buy_style_rank_3=6 then cac_silh_loyal=4;
         else if cac_silh_buy_style_rank_3=7 then cac_silh_loyal=4;
         else if cac_silh_buy_style_rank_3=8 then cac_silh_loyal=5;
         else cac_silh_loyal=5;
      
      *CAC_SILH_BUY_STYLE_GROUP IS 5 FOR PRICE BUT RANKS WERE NOT SHIFTED*;
         if cac_silh_buy_style_rank_4=0 then cac_silh_price=1;
         else if cac_silh_buy_style_rank_4=1  then cac_silh_price=1;
         else if cac_silh_buy_style_rank_4=2  then cac_silh_price=2;
         else if cac_silh_buy_style_rank_4=3  then cac_silh_price=2;
         else if cac_silh_buy_style_rank_4=4  then cac_silh_price=3;
         else if cac_silh_buy_style_rank_4=5  then cac_silh_price=3;
         else if cac_silh_buy_style_rank_4=6  then cac_silh_price=4;
         else if cac_silh_buy_style_rank_4=7  then cac_silh_price=4;
         else if cac_silh_buy_style_rank_4=8  then cac_silh_price=5;
         else cac_silh_price=5;


      _cac_silh_price=put(cac_silh_price,$2.);
      _cac_silh_loyal=put(cac_silh_loyal,$2.);
      _cac_silh_lifestyle_macro=put(cac_silh_lstyle_macro,$2.);

      cac_clust_lifestage_age=_cac_silh_lifestage_age+0;
      cac_clust_geo=_cac_silh_geo_lc+0;
      cac_clust_socio_income=_cac_silh_socio_income+0;
      cac_clust_tech=_cac_silh_tech+0;
      cac_clust_lstyle_macro=cac_silh_lstyle_macro+0;
      cac_clust_ecom=_cac_silh_ecom+0;
      cac_clust_social=_cac_silh_social+0;
      cac_clust_dig_inf=_cac_silh_dig_inf+0;
      
      if cac_clust_geo=5 then cac_clust_geo=0;
      
      length groupvar $ 12 seg_macro $ 5;
      
      if seg_macro="AM" then goto AM; else
      if seg_macro="AF" then goto AF; else
      if seg_macro="B" then goto B; else
      if seg_macro="C" then goto C; else
      if seg_macro="D" then goto D; else
      if seg_macro="E" then goto E; else
      if seg_macro="F" then goto F; else
      if seg_macro="G" then goto G; else
      if seg_macro="I" then goto I; else
      if seg_macro="J" then goto J; 
      goto ending;
      
      AM: 
      if cac_clust_lifestage_age>3 then cac_clust_lifestage_age=3;
      if cac_clust_socio_income >3 then cac_clust_socio_income =3;
      if cac_clust_geo=5 then cac_clust_geo=0;
      
      if cac_silh_price>3 then cac_clust_price=3;else
      cac_clust_price=cac_silh_price;
      
      if cac_silh_loyal=5 then cac_clust_loyal=1;else
      cac_clust_loyal=0;
      
      if cac_clust_social in (1 2) then cac_clust_social=1; else
      if cac_clust_social in (3 4) then cac_clust_social=2; else
      if cac_clust_social in (5 6) then cac_clust_social=3; else
      cac_clust_social=4;
      
      if cac_clust_dig_inf in (1 ) then cac_clust_dig_inf=1; else
      if cac_clust_dig_inf in (2 3) then cac_clust_dig_inf=2; else
      if cac_clust_dig_inf in (4 5) then cac_clust_dig_inf=3; else
      cac_clust_dig_inf=4; 
      
      if cac_clust_ecom in (1 2) then cac_clust_ecom=1; else
      if cac_clust_ecom in ( 3) then cac_clust_ecom=2; else
      cac_clust_ecom=3; 
      
      if cac_clust_tech in (1 ) then cac_clust_tech=1; else
      if cac_clust_tech in (2) then cac_clust_tech=2; else
      cac_clust_tech=3;
      
      
      array all_am{8} cac_clust_price cac_clust_lifestage_age cac_clust_geo 
      cac_clust_dig_inf cac_clust_ecom cac_clust_social cac_clust_tech cac_clust_socio_income 
      ;
      do i=1 to 8;
         substr(groupvar,i,1)=put(all_am{i},1.);
      end;
      groupvar=trim(groupvar);
      cluster=put(groupvar,$am_f.);
      goto ending;



      AF:
      if cac_clust_lifestage_age>3 then cac_clust_lifestage_age=3;
      if cac_clust_socio_income >3 then cac_clust_socio_income =3;
      if cac_clust_geo=5 then cac_clust_geo=0;
      
      if cac_clust_lstyle_macro in (1 2 5 7 8) then cac_clust_lstyle_macro =1; else
      if cac_clust_lstyle_macro =3 then cac_clust_lstyle_macro =2; else
      if cac_clust_lstyle_macro =4 then cac_clust_lstyle_macro =3; else
      if cac_clust_lstyle_macro =6 then cac_clust_lstyle_macro =4; else
      cac_clust_lstyle_macro =0; 
      
      if cac_silh_price>3 then cac_clust_price=0;else
      cac_clust_price=1;
      
      if cac_silh_loyal=5 then cac_clust_loyal=0;else
      cac_clust_loyal=1;
      
      if cac_clust_social in (1 2) then cac_clust_social=1; else
      if cac_clust_social in (3 4) then cac_clust_social=2; else
      if cac_clust_social in (5 6) then cac_clust_social=3; else
      cac_clust_social=4;
      
      if cac_clust_dig_inf in (1 2 3) then cac_clust_dig_inf=1; else
      if cac_clust_dig_inf in (4 5) then cac_clust_dig_inf=2; else
      if cac_clust_dig_inf in (6 7) then cac_clust_dig_inf=3; else
      cac_clust_dig_inf=4; 
      
      if cac_clust_ecom in (1 2) then cac_clust_ecom=1; else
      if cac_clust_ecom in (2 3) then cac_clust_ecom=2; else
      cac_clust_ecom=3; 
      
      if cac_demo_num_kids_enh=0 then cac_clust_kids=0; else
      cac_clust_kids=1;
      
      array all_af{10} 
      cac_clust_price cac_clust_lifestage_age 
      cac_clust_geo cac_clust_dig_inf cac_clust_ecom
      cac_clust_social cac_clust_tech 
      cac_clust_socio_income 
      cac_clust_loyal 
      cac_clust_kids
      ;
      do i=1 to 10;
         substr(groupvar,i,1)=put(all_af{i},1.);
      end;
      groupvar=trim(groupvar);
      cluster=put(groupvar,$af_f.);
      goto ending;
      
      
      B:
      if cac_clust_socio_income in (2 3)then cac_clust_socio_income =3; else
      if cac_clust_socio_income in (6 7)then cac_clust_socio_income =6; 
      
      if cac_clust_geo=0 then cac_clust_geo=1;
      
      
      if cac_silh_price<=2 then cac_clust_price=1;else
      cac_clust_price=0;
      
      if cac_silh_loyal<=2 then cac_clust_loyal=1;else
      cac_clust_loyal=0;
      
      if cac_clust_social >5 then cac_clust_social=5; 
      
      if cac_clust_dig_inf in (1 ) then cac_clust_dig_inf=1; else
      cac_clust_dig_inf=2; 
      
      if cac_clust_ecom in (1 ) then cac_clust_ecom=1; else
      if cac_clust_ecom in (2 3 4) then cac_clust_ecom=2; else
      cac_clust_ecom=3; 
      
      if cac_clust_tech in (1 ) then cac_clust_tech=1; else
      if cac_clust_tech in (2 3 4) then cac_clust_tech=2; 
      
      array all_b{8} cac_clust_lifestage_age cac_clust_geo cac_clust_loyal cac_clust_social 
      cac_clust_ecom cac_clust_tech cac_clust_socio_income cac_clust_dig_inf  
      ;
      do i=1 to 8;
         substr(groupvar,i,1)=put(all_b{i},1.);
      end;
      groupvar=trim(groupvar);
      cluster=put(groupvar,$b_f.);
      goto ending;
      
      
      C:
      cac_clust_ho=_cac_silh_socio_ho+0;
      
      if cac_clust_socio_income in (1 2 )then cac_clust_socio_income =1; else
      if cac_clust_socio_income in (3)then cac_clust_socio_income =2; else
      if cac_clust_socio_income in (4)then cac_clust_socio_income =3; else
      if cac_clust_socio_income in (5)then cac_clust_socio_income =4; else
      cac_clust_socio_income =5; 
      
      if cac_clust_geo>3 then cac_clust_geo=3;
      
      
      if cac_silh_price=1 then cac_clust_price=1;else
      cac_clust_price=0;
      
      if cac_silh_loyal<=1 then cac_clust_loyal=1;else
      cac_clust_loyal=0;
      
      if cac_clust_social in (1 2 ) then cac_clust_social=1; else
      if cac_clust_social in (3 4) then cac_clust_social=2; else
      cac_clust_social=3;
      
      if cac_clust_dig_inf in (1 2 3) then cac_clust_dig_inf=1; else
      if cac_clust_dig_inf in (4 5 6) then cac_clust_dig_inf=2; else
      cac_clust_dig_inf=3; 
      
      if cac_clust_ecom in (1 ) then cac_clust_ecom=1; else
      cac_clust_ecom=2; 
      
      if cac_clust_tech in (1 ) then cac_clust_tech=1; else
      if cac_clust_tech in (2 3 4) then cac_clust_tech=2; 
      
      array all_c{9} cac_clust_lifestage_age cac_clust_geo cac_clust_ho cac_clust_price cac_clust_loyal 
      cac_clust_social cac_clust_ecom cac_clust_tech cac_clust_socio_income 
      ;
      do i=1 to 9;
         substr(groupvar,i,1)=put(all_c{i},1.);
      end;
      groupvar=trim(groupvar);
      cluster=put(groupvar,$c_f.);
      goto ending;
      
      
      D:
      if cac_clust_lifestage_age>3 then cac_clust_lifestage_age=4;
      
      if cac_clust_socio_income <5 then cac_clust_socio_income =5;
      
      if cac_clust_geo=5 then cac_clust_geo=0;
      if cac_clust_geo>1 then cac_clust_geo=2;
      
      
      if cac_silh_price<=2 then cac_clust_price=1;else
      cac_clust_price=0;
      
      if cac_silh_loyal<=2 then cac_clust_loyal=1;else
      cac_clust_loyal=0;
      
      if cac_clust_social in (1 2 ) then cac_clust_social=1; else
      if cac_clust_social in (3 4 5) then cac_clust_social=2; else
      cac_clust_social=3;
      
      if cac_clust_dig_inf in (1 2 ) then cac_clust_dig_inf=1; else
      if cac_clust_dig_inf in (3 4 5) then cac_clust_dig_inf=2; else
      cac_clust_dig_inf=3; 
      
      if cac_clust_ecom in (1 ) then cac_clust_ecom=1; else
      cac_clust_ecom=2; 
      
      if cac_clust_tech in (1 2 ) then cac_clust_tech=1; else
      if cac_clust_tech in (3 4) then cac_clust_tech=2; 
      
      array all_d{9} cac_clust_price cac_clust_lifestage_age cac_clust_geo 
      cac_clust_dig_inf cac_clust_ecom cac_clust_social cac_clust_tech cac_clust_socio_income 
      cac_clust_loyal 
      ;
      do i=1 to 9;
         substr(groupvar,i,1)=put(all_d{i},1.);
      end;
      groupvar=trim(groupvar);
      cluster=put(groupvar,$d_f.);
      goto ending;
      
      
      E:
      
      if cac_clust_geo=3 then cac_clust_geo=2;
      
      if cac_silh_loyal=1 then cac_clust_loyal=1;else
      cac_clust_loyal=2;
      
      if cac_clust_ecom in (1 ) then cac_clust_ecom=1; else
      if cac_clust_ecom in (2 3 4) then cac_clust_ecom=2; else
      cac_clust_ecom=3; 
      
      if cac_clust_tech in (1 ) then cac_clust_tech=1; else
      if cac_clust_tech in (2 3 4) then cac_clust_tech=2; 
      
      if cac_clust_socio_income in (1 2 3)then cac_clust_socio_income =3; else
      if cac_clust_socio_income in (6 7 8 9)then cac_clust_socio_income =6; 
      
      
      if cac_clust_dig_inf in (1 2) then cac_clust_dig_inf=1; else
      cac_clust_dig_inf=2; 
      
      array all_e{7} cac_clust_lifestage_age cac_clust_geo cac_clust_loyal 
      cac_clust_ecom cac_clust_tech cac_clust_socio_income cac_clust_dig_inf 
      ;
      do i=1 to 7;
         substr(groupvar,i,1)=put(all_e{i},1.);
      end;
      groupvar=trim(groupvar);
      cluster=put(groupvar,$e_f.);
      goto ending;
      
      
      F:
      if cac_clust_lifestage_age>=4 then cac_clust_lifestage_age=4;
      
      if cac_clust_socio_income >5 then cac_clust_socio_income =5; else
      if cac_clust_socio_income <3 then cac_clust_socio_income =3; 
      
      if cac_clust_geo=4 then cac_clust_geo=3;
      
      
      if cac_silh_price<=2 then cac_clust_price=1;else
      cac_clust_price=2;
      
      if cac_silh_loyal<=2 then cac_clust_loyal=1;else
      cac_clust_loyal=2;
      
      if cac_clust_social <=3 then cac_clust_social=1;  else
      if cac_clust_social <=5 then cac_clust_social=2;  else
      if cac_clust_social <=7 then cac_clust_social=3;  else
      cac_clust_social=4;  
      
      if cac_clust_dig_inf in (1 2) then cac_clust_dig_inf=1; else
      if cac_clust_dig_inf in (3 4 5 6) then cac_clust_dig_inf=2; else
      cac_clust_dig_inf=3; 
      
      if cac_clust_ecom in (1 2) then cac_clust_ecom=1; else
      if cac_clust_ecom in ( 3 ) then cac_clust_ecom=2; else
      cac_clust_ecom=3; 
      
      array all_f{7} cac_clust_lifestage_age cac_clust_geo cac_clust_loyal 
      cac_clust_ecom cac_clust_tech cac_clust_socio_income cac_clust_dig_inf 
      
      ;
      do i=1 to 7;
         substr(groupvar,i,1)=put(all_f{i},1.);
      end;
      groupvar=trim(groupvar);
      cluster=put(groupvar,$f_f.);
      goto ending;
      
      
      G:
      
      if cac_clust_lifestage_age<3 then cac_clust_lifestage_age=3;
      if cac_clust_lifestage_age>5 then cac_clust_lifestage_age=5;
      
      if cac_clust_socio_income <6 then cac_clust_socio_income =6;
      
      if cac_clust_geo>1 then cac_clust_geo=2;
      
      
      if cac_silh_price<=3 then cac_clust_price=3;else
      cac_clust_price=cac_silh_price;
      
      if cac_silh_loyal<=1 then cac_clust_loyal=1;else
      cac_clust_loyal=0;
      
      if cac_clust_social in (1 2 3 4) then cac_clust_social=1; else
      if cac_clust_social in (5 6 7) then cac_clust_social=2; else
      cac_clust_social=3;
      
      if cac_clust_dig_inf in (1 2 3) then cac_clust_dig_inf=1; else
      if cac_clust_dig_inf in (4 5 6) then cac_clust_dig_inf=2; else
      cac_clust_dig_inf=3; 
      
      if cac_clust_ecom in (1 ) then cac_clust_ecom=1; else
      cac_clust_ecom=2; 
      
      if cac_clust_tech in (1 ) then cac_clust_tech=1; else
      if cac_clust_tech in (2 3 4) then cac_clust_tech=2; 
      
      array all_g{6} cac_clust_lifestage_age cac_clust_geo 
      cac_clust_dig_inf cac_clust_ecom cac_clust_tech cac_clust_socio_income 
      ;
      do i=1 to 6;
         substr(groupvar,i,1)=put(all_g{i},1.);
      end;
      groupvar=trim(groupvar);
      cluster=put(groupvar,$g_f.);
      goto ending;
      
      
      I:
      if cac_clust_lifestage_age<3 then do; segh=1; goto ending; end;
      
      if cac_clust_socio_income in (1 2 )then cac_clust_socio_income =1; else
      if cac_clust_socio_income in (3 4)then cac_clust_socio_income =2; else
      if cac_clust_socio_income in (5)then cac_clust_socio_income =3; else
      if cac_clust_socio_income in (6)then cac_clust_socio_income =3; else
      cac_clust_socio_income =3; 
      
      if cac_clust_geo=0 then cac_clust_geo=1;
      
      
      if cac_silh_price<=2 then cac_clust_price=1;else
      cac_clust_price=0;
      
      if cac_silh_loyal<=1 then cac_clust_loyal=1;else
      cac_clust_loyal=0;
      
      if cac_clust_social in (1 2 ) then cac_clust_social=1; else
      if cac_clust_social in (3 4 5 6) then cac_clust_social=1; else
      cac_clust_social=2;
      
      if cac_clust_dig_inf in (1 2 3 4 5) then cac_clust_dig_inf=1; else
      cac_clust_dig_inf=2; 
      
      if cac_clust_ecom in (1 2) then cac_clust_ecom=1; else
      if cac_clust_ecom in (3 4) then cac_clust_ecom=2; else
      cac_clust_ecom=3; 
      
      if cac_clust_tech in (1 ) then cac_clust_tech=1; else
      if cac_clust_tech in (2 3 4) then cac_clust_tech=2; 
      
      array all_i{8} cac_clust_lifestage_age cac_clust_geo cac_clust_loyal cac_clust_social 
      cac_clust_ecom cac_clust_tech cac_clust_socio_income cac_clust_dig_inf 
      ;
      do i=1 to 8;
         substr(groupvar,i,1)=put(all_i{i},1.);
      end;
      groupvar=trim(groupvar);
      cluster=put(groupvar,$i_f.);
      goto ending;
      
      
      J:
      if cac_clust_socio_income >3 then cac_clust_socio_income =3;
      
      if cac_clust_geo=5 then cac_clust_geo=0;
      
      if cac_clust_lstyle_macro in (1 2 5 7 8) then cac_clust_lstyle_macro =1; else
      if cac_clust_lstyle_macro =3 then cac_clust_lstyle_macro =2; else
      if cac_clust_lstyle_macro =4 then cac_clust_lstyle_macro =3; else
      if cac_clust_lstyle_macro =6 then cac_clust_lstyle_macro =4; else
      cac_clust_lstyle_macro =0; 
      
      if cac_silh_price>2 then cac_clust_price=0;else
      cac_clust_price=1;
      
      if cac_silh_loyal<=1 then cac_clust_loyal=1;else
      cac_clust_loyal=0;
      
      if cac_clust_social in (1 2 3 4 5 6 7) then cac_clust_social=1; else
      if cac_clust_social in (8) then cac_clust_social=2; else
      if cac_clust_social in (9) then cac_clust_social=3; else
      cac_clust_social=4;
      
      if cac_clust_dig_inf in (1 2 3 4 5 6 7) then cac_clust_dig_inf=1; else
      if cac_clust_dig_inf in (8) then cac_clust_dig_inf=2; else
      if cac_clust_dig_inf in (9) then cac_clust_dig_inf=3; else
      cac_clust_dig_inf=4; 
      
      if cac_clust_ecom in (1 2 3) then cac_clust_ecom=1; else
      if cac_clust_ecom in (4) then cac_clust_ecom=2; else
      cac_clust_ecom=3; 
      
      if cac_clust_tech in (1 2 3) then cac_clust_tech=1; else
      if cac_clust_tech in (4) then cac_clust_tech=2; else
      cac_clust_tech=3; 
      
      cac_clust_ho=_cac_silh_socio_ho+0;
      
      array all_j{10} 
      cac_clust_price cac_clust_lifestage_age cac_clust_geo 
      cac_clust_dig_inf cac_clust_ecom cac_clust_social cac_clust_tech cac_clust_socio_income 
      cac_clust_loyal cac_clust_ho
      ;
      do i=1 to 10;
         substr(groupvar,i,1)=put(all_j{i},1.);
      end;
      groupvar=trim(groupvar);
      cluster=put(groupvar,$j_f.);
      goto ending;

      ending:
      if segh=1 then do;
         substr(seg_macro,1,1)="H";
         cluster=1;
      end;
      
      
      if seg_macro="AF" then do;
         if cluster=7 then cluster=5;
         if cluster=8 then cluster=6;
      end; else
      if seg_macro="AM" then do;
         if cluster=7 then cluster=6;
         if cluster=8 then cluster=7;
      end; else
      if seg_macro="B" then do;
         if cluster>4 then cluster=cluster-1;
      end; else
      if seg_macro="C" then do;
         if cluster=3 then do;
            if cac_clust_lifestage_age=2 then cluster=2; else
            if cac_clust_lifestage_age=3 then cluster=7; 
         end;
         if cluster>2 then cluster=cluster-1;
      end; else
      if seg_macro="F" then do;
         if cluster=2 then cluster=1;
         if cluster=6 then cluster=3;
         if cluster=>2 then cluster=cluster-1;
      end; else
      if seg_macro="G" then do;
         if cluster=6 then cluster=5;
         if cluster=>6 then cluster=cluster-1;
      end; else  
      if seg_macro="I" then do;
         if cluster=10 then cluster=9;
         if cluster=4 then cluster=3;
         if cluster=7 then cluster=5;
         if cluster=>5 then cluster=cluster-1;
         if cluster>5 then cluster=cluster-1;
      end; 
      
      if substr(seg_macro,2,1)=" " then do;
         substr(seg_macro,2,1)="_"; substr(seg_macro,3,1)=left(trim(cluster));
      end; else do;
         substr(seg_macro,3,1)="_"; substr(seg_macro,4,1)=left(trim(cluster));
      end;


      ***  COLLAPSING HERE ***;
      if seg_macro="H_1" then seg_macro="F_1";
      if seg_macro="D_8" then seg_macro="D_2";
      if seg_macro="G_6" then seg_macro="G_5";
      if seg_macro="B_6" then seg_macro="B_4";
      if seg_macro="D_3" then seg_macro="D_2";
      if seg_macro="E_4" then seg_macro="E_3";
      if seg_macro="I_4" then seg_macro="I_3";
      if seg_macro="I_2" then do;
         if _cac_silh_lifestage_age=5 then seg_macro="I_6"; else
         seg_macro="I_1";
      end;
      if seg_macro="G_5" then seg_macro="H_1"; 
      if seg_macro="I_6" then seg_macro="H_2"; 
      if seg_macro="I_7" then seg_macro="H_3"; 
      if seg_macro="B_7" then seg_macro="B_4"; 
      if seg_macro="G_7" then seg_macro="G_3"; 
      if seg_macro="G_4" then seg_macro="G_3"; 
      
      %macro old;
      /*** CODE CHANGED 9/11/2012 per BR REQUEST TO COLLAPSE As and Bs ***/
         if seg_macro='AF_1' then do; superseg='A';silhouette='A1';end;
         else if seg_macro='AF_2' then do; superseg='A';silhouette='A2';end;
         else if seg_macro='AF_3' then do; superseg='A';silhouette='A3';end;
         else if seg_macro='AM_1' then do; superseg='B';silhouette='B1';end;
         else if seg_macro='AM_2' then do; superseg='B';silhouette='B2';end;
         else if seg_macro='AM_3' then do; superseg='B';silhouette='B3';end;
         else if seg_macro='C_1' then do; superseg='C';silhouette='C1';end;
         else if seg_macro='C_2' then do; superseg='C';silhouette='C2';end;
         else if seg_macro='D_6' then do; superseg='C';silhouette='C3';end;
         else if seg_macro='F_1' then do; superseg='C';silhouette='C4';end;
         else if seg_macro='B_1' then do; superseg='D';silhouette='D1';end;
         else if seg_macro='B_2' then do; superseg='D';silhouette='D2';end;
         else if seg_macro='B_3' then do; superseg='D';silhouette='D3';end;
         else if seg_macro='B_5' then do; superseg='D';silhouette='D4';end;
         else if seg_macro='E_2' then do; superseg='D';silhouette='D5';end;
         else if seg_macro='AF_4' then do; superseg='E';silhouette='E1';end;
         else if seg_macro='AF_5' then do; superseg='E';silhouette='E2';end;
         else if seg_macro='AF_6' then do; superseg='E';silhouette='E3';end;
         else if seg_macro='AM_5' then do; superseg='E';silhouette='E4';end;
         else if seg_macro='AM_6' then do; superseg='E';silhouette='E5';end;
         else if seg_macro='D_1' then do; superseg='F';silhouette='F1';end;
         else if seg_macro='D_2' then do; superseg='F';silhouette='F2';end;
         else if seg_macro='D_4' then do; superseg='F';silhouette='F3';end;
         else if seg_macro='D_5' then do; superseg='F';silhouette='F4';end;
         else if seg_macro='AM_4' then do; superseg='G';silhouette='G1';end;
         else if seg_macro='AM_7' then do; superseg='G';silhouette='G2';end;
         else if seg_macro='B_4' then do; superseg='G';silhouette='G3';end;
         else if seg_macro='E_1' then do; superseg='G';silhouette='G4';end;
         else if seg_macro='E_3' then do; superseg='G';silhouette='G5';end;
         else if seg_macro='E_5' then do; superseg='G';silhouette='G6';end;
         else if seg_macro='J_3' then do; superseg='G';silhouette='G7';end;
         else if seg_macro='G_1' then do; superseg='H';silhouette='H1';end;
         else if seg_macro='G_2' then do; superseg='H';silhouette='H2';end;
         else if seg_macro='G_3' then do; superseg='H';silhouette='H3';end;
         else if seg_macro='F_2' then do; superseg='I';silhouette='I1';end;
         else if seg_macro='F_3' then do; superseg='I';silhouette='I2';end;
         else if seg_macro='F_4' then do; superseg='I';silhouette='I3';end;
         else if seg_macro='I_1' then do; superseg='I';silhouette='I4';end;
         else if seg_macro='I_3' then do; superseg='I';silhouette='I5';end;
         else if seg_macro='C_3' then do; superseg='J';silhouette='J1';end;
         else if seg_macro='C_4' then do; superseg='J';silhouette='J2';end;
         else if seg_macro='C_5' then do; superseg='J';silhouette='J3';end;
         else if seg_macro='C_6' then do; superseg='J';silhouette='J4';end;
         else if seg_macro='D_7' then do; superseg='J';silhouette='J5';end;
         else if seg_macro='E_6' then do; superseg='J';silhouette='J6';end;
         else if seg_macro='J_2' then do; superseg='K';silhouette='K1';end;
         else if seg_macro='J_4' then do; superseg='K';silhouette='K2';end;
         else if seg_macro='J_6' then do; superseg='K';silhouette='K3';end;
         else if seg_macro='J_7' then do; superseg='K';silhouette='K4';end;
         else if seg_macro='J_1' then do; superseg='L';silhouette='L1';end;
         else if seg_macro='J_5' then do; superseg='L';silhouette='L2';end;
         else if seg_macro='J_8' then do; superseg='L';silhouette='L3';end;
         else if seg_macro='I_5' then do; superseg='L';silhouette='L4';end;
         else if seg_macro='H_1' then do; superseg='M';silhouette='M1';end;
         else if seg_macro='H_2' then do; superseg='M';silhouette='M2';end;
         else if seg_macro='H_3' then do; superseg='M';silhouette='M3';end;
         else if seg_macro='E_7' then do; superseg='M';silhouette='M4';end;
         else if seg_macro='E_8' then do; superseg='M';silhouette='M5';end;
      %mend old;
      %macro old2;
              if seg_macro='AF_1' then do;   silhouette='A1';   superseg='A'; end;
         else if seg_macro='AM_1' then do;   silhouette='A2';   superseg='A'; end;
         else if seg_macro='AF_2' then do;   silhouette='A3';   superseg='A'; end;
         else if seg_macro='AM_3' then do;   silhouette='A4';   superseg='A'; end;
         else if seg_macro='AF_3' then do;   silhouette='A5';   superseg='A'; end;
         else if seg_macro='AM_2' then do;   silhouette='A6';   superseg='A'; end;
         else if seg_macro='C_1' then do;   silhouette='B1';   superseg='B'; end;
         else if seg_macro='C_2' then do;   silhouette='B2';   superseg='B'; end;
         else if seg_macro='D_6' then do;   silhouette='B3';   superseg='B'; end;
         else if seg_macro='F_1' then do;   silhouette='B4';   superseg='B'; end;
         else if seg_macro='B_1' then do;   silhouette='C1';   superseg='C'; end;
         else if seg_macro='B_2' then do;   silhouette='C2';   superseg='C'; end;
         else if seg_macro='B_3' then do;   silhouette='C3';   superseg='C'; end;
         else if seg_macro='B_5' then do;   silhouette='C4';   superseg='C'; end;
         else if seg_macro='E_2' then do;   silhouette='C5';   superseg='C'; end;
         else if seg_macro='AF_4' then do;   silhouette='D1';   superseg='D'; end;
         else if seg_macro='AF_5' then do;   silhouette='D2';   superseg='D'; end;
         else if seg_macro='AF_6' then do;   silhouette='D3';   superseg='D'; end;
         else if seg_macro='AM_5' then do;   silhouette='D4';   superseg='D'; end;
         else if seg_macro='AM_6' then do;   silhouette='D5';   superseg='D'; end;
         else if seg_macro='D_1' then do;   silhouette='E1';   superseg='E'; end;
         else if seg_macro='D_2' then do;   silhouette='E2';   superseg='E'; end;
         else if seg_macro='D_4' then do;   silhouette='E3';   superseg='E'; end;
         else if seg_macro='D_5' then do;   silhouette='E4';   superseg='E'; end;
         else if seg_macro='AM_4' then do;   silhouette='F1';   superseg='F'; end;
         else if seg_macro='AM_7' then do;   silhouette='F2';   superseg='F'; end;
         else if seg_macro='B_4' then do;   silhouette='F3';   superseg='F'; end;
         else if seg_macro='E_1' then do;   silhouette='F4';   superseg='F'; end;
         else if seg_macro='E_3' then do;   silhouette='F5';   superseg='F'; end;
         else if seg_macro='E_5' then do;   silhouette='F6';   superseg='F'; end;
         else if seg_macro='J_3' then do;   silhouette='F7';   superseg='F'; end;
         else if seg_macro='G_1' then do;   silhouette='G1';   superseg='G'; end;
         else if seg_macro='G_2' then do;   silhouette='G2';   superseg='G'; end;
         else if seg_macro='G_3' then do;   silhouette='G3';   superseg='G'; end;
         else if seg_macro='F_2' then do;   silhouette='I1';   superseg='I'; end;
         else if seg_macro='F_3' then do;   silhouette='I2';   superseg='I'; end;
         else if seg_macro='F_4' then do;   silhouette='I3';   superseg='I'; end;
         else if seg_macro='I_1' then do;   silhouette='I4';   superseg='I'; end;
         else if seg_macro='I_3' then do;   silhouette='I5';   superseg='I'; end;
         else if seg_macro='C_3' then do;   silhouette='H1';   superseg='H'; end;
         else if seg_macro='C_4' then do;   silhouette='H2';   superseg='H'; end;
         else if seg_macro='C_5' then do;   silhouette='H3';   superseg='H'; end;
         else if seg_macro='C_6' then do;   silhouette='H4';   superseg='H'; end;
         else if seg_macro='D_7' then do;   silhouette='H5';   superseg='H'; end;
         else if seg_macro='E_6' then do;   silhouette='L6';   superseg='L'; end;
         else if seg_macro='J_2' then do;   silhouette='J1';   superseg='J'; end;
         else if seg_macro='J_4' then do;   silhouette='J2';   superseg='J'; end;
         else if seg_macro='J_6' then do;   silhouette='J3';   superseg='J'; end;
         else if seg_macro='J_7' then do;   silhouette='J4';   superseg='J'; end;
         else if seg_macro='J_1' then do;   silhouette='K1';   superseg='K'; end;
         else if seg_macro='J_5' then do;   silhouette='K2';   superseg='K'; end;
         else if seg_macro='J_8' then do;   silhouette='K3';   superseg='K'; end;
         else if seg_macro='I_5' then do;   silhouette='K4';   superseg='K'; end;
         else if seg_macro='H_1' then do;   silhouette='L1';   superseg='L'; end;
         else if seg_macro='H_2' then do;   silhouette='L2';   superseg='L'; end;
         else if seg_macro='H_3' then do;   silhouette='L3';   superseg='L'; end;
         else if seg_macro='E_7' then do;   silhouette='L4';   superseg='L'; end;
         else if seg_macro='E_8' then do;   silhouette='L5';   superseg='L'; end;
      %mend old2;

           if seg_macro='AF_1' then do;   silhouette='A1';   superseg='A'; end;
      else if seg_macro='AM_1' then do;   silhouette='A2';   superseg='A'; end;
      else if seg_macro='AF_2' then do;   silhouette='A3';   superseg='A'; end;
      else if seg_macro='AM_3' then do;   silhouette='A4';   superseg='A'; end;
      else if seg_macro='AF_3' then do;   silhouette='A5';   superseg='A'; end;
      else if seg_macro='AM_2' then do;   silhouette='A6';   superseg='A'; end;
      else if seg_macro='C_1' then do;   silhouette='B1';   superseg='B'; end;
      else if seg_macro='C_2' then do;   silhouette='B2';   superseg='B'; end;
      else if seg_macro='D_6' then do;   silhouette='B3';   superseg='B'; end;
      else if seg_macro='F_1' then do;   silhouette='B4';   superseg='B'; end;
      else if seg_macro='B_1' then do;   silhouette='C1';   superseg='C'; end;
      else if seg_macro='B_2' then do;   silhouette='C2';   superseg='C'; end;
      else if seg_macro='B_3' then do;   silhouette='C3';   superseg='C'; end;
      else if seg_macro='B_5' then do;   silhouette='C4';   superseg='C'; end;
      else if seg_macro='E_2' then do;   silhouette='C5';   superseg='C'; end;
      else if seg_macro='AF_4' then do;   silhouette='D1';   superseg='D'; end;
      else if seg_macro='AF_5' then do;   silhouette='D2';   superseg='D'; end;
      else if seg_macro='AF_6' then do;   silhouette='D3';   superseg='D'; end;
      else if seg_macro='AM_5' then do;   silhouette='D4';   superseg='D'; end;
      else if seg_macro='AM_6' then do;   silhouette='D5';   superseg='D'; end;
      else if seg_macro='D_1' then do;   silhouette='E1';   superseg='E'; end;
      else if seg_macro='D_2' then do;   silhouette='E2';   superseg='E'; end;
      else if seg_macro='D_4' then do;   silhouette='E3';   superseg='E'; end;
      else if seg_macro='D_5' then do;   silhouette='E4';   superseg='E'; end;
      else if seg_macro='AM_4' then do;   silhouette='F1';   superseg='F'; end;
      else if seg_macro='AM_7' then do;   silhouette='F2';   superseg='F'; end;
      else if seg_macro='B_4' then do;   silhouette='F3';   superseg='F'; end;
      else if seg_macro='E_1' then do;   silhouette='F4';   superseg='F'; end;
      else if seg_macro='E_3' then do;   silhouette='F5';   superseg='F'; end;
      else if seg_macro='E_5' then do;   silhouette='F6';   superseg='F'; end;
      else if seg_macro='J_3' then do;   silhouette='F7';   superseg='F'; end;
      else if seg_macro='G_1' then do;   silhouette='G1';   superseg='G'; end;
      else if seg_macro='G_2' then do;   silhouette='G2';   superseg='G'; end;
      else if seg_macro='G_3' then do;   silhouette='G3';   superseg='G'; end;
      else if seg_macro='F_2' then do;   silhouette='I1';   superseg='I'; end;
      else if seg_macro='F_3' then do;   silhouette='I2';   superseg='I'; end;
      else if seg_macro='F_4' then do;   silhouette='I3';   superseg='I'; end;
      else if seg_macro='I_1' then do;   silhouette='I4';   superseg='I'; end;
      else if seg_macro='I_3' then do;   silhouette='I5';   superseg='I'; end;
      else if seg_macro='C_3' then do;   silhouette='H1';   superseg='H'; end;
      else if seg_macro='C_4' then do;   silhouette='H2';   superseg='H'; end;
      else if seg_macro='C_5' then do;   silhouette='H3';   superseg='H'; end;
      else if seg_macro='C_6' then do;   silhouette='H4';   superseg='H'; end;
      else if seg_macro='D_7' then do;   silhouette='H5';   superseg='H'; end;
      else if seg_macro='E_6' then do;   silhouette='L6';   superseg='L'; end;
      else if seg_macro='J_2' then do;   silhouette='K1';   superseg='K'; end;
      else if seg_macro='J_4' then do;   silhouette='K2';   superseg='K'; end;
      else if seg_macro='J_6' then do;   silhouette='K3';   superseg='K'; end;
      else if seg_macro='J_7' then do;   silhouette='K4';   superseg='K'; end;
      else if seg_macro='J_1' then do;   silhouette='J1';   superseg='J'; end;
      else if seg_macro='J_5' then do;   silhouette='J2';   superseg='J'; end;
      else if seg_macro='J_8' then do;   silhouette='J3';   superseg='J'; end;
      else if seg_macro='I_5' then do;   silhouette='J4';   superseg='J'; end;
      else if seg_macro='H_1' then do;   silhouette='L1';   superseg='L'; end;
      else if seg_macro='H_2' then do;   silhouette='L2';   superseg='L'; end;
      else if seg_macro='H_3' then do;   silhouette='L3';   superseg='L'; end;
      else if seg_macro='E_7' then do;   silhouette='L4';   superseg='L'; end;
      else if seg_macro='E_8' then do;   silhouette='L5';   superseg='L'; end;


      if cluster in (97 98 99) then do; superseg = 'X'; seg_macro='X_X'; silhouette='XX'; end;
   run;

   %end;                      *<--------------------------------------------------- END OF STATE_NUM LOOP; 

%mend silhouettes;

