%macro matchmaker(client_dir=, client_data=, client_id=, name_format=, name_var=, name_var2=, addr_format=, addr1=, addr2=, 
                  state_var=, zip5=, zip4=, match_lev=1, key1=, key2=, key3=, key4=, key5=, key6=, key7=, state_list=, ethnic=,
                  geo_interest=, census=, census_keep=, individual=, addr_detail=0, cacd_prod=1, results_by_state=1, email=jschiltz@cac-group.com);
*==============================================================================================*;
*  Macro:  	Matchmaker
   Purpose: 	Process client data, match to CACdirect, and return desired elements
   Created:	4/19/2012
   Author:	Patty Seeburger, Mike Mattingly, Joel Schiltz
   Sections:	1) MATCHING PREP
                2) CLEAN DATA
                    --Input data: clin.&client_data
                    --Output data: clean
                                   client_not_clean
                                   client_dups
                2) PARSIMONY
                    --Input data: clean
                    --Output data: client_outdat
                3) SPLIT INTO STATES
                    --Input data: client_outdat
                    --Output data: client_*state name*
                4) SPLIT INTO SCF
                    --Input data: client_*state name*
                    --Output data: client_scf_*state name*_*scf*_*key*
                5) GO GRAB PID AND PUT ON CLIENT FILE
                6) ADD BASE DEMO FIELDS (NOT SELECTABLE)
                7) ADD GEO INTERESTS (IF SELECTED)  
                8) ADD CENSUS DATA (IF SELECTED)  
                9) ADD ETHNIC DATA (IF SELECTED)  
               10) ADD INDIVIDUAL DATA (IF SELECTED)  
               11) STACK STATE RESULTS INTO FULL SAMPLE
               12) FINAL OUTPUT
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
    /*%let states_for_match=&state_list;*/
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

libname clin "&client_dir";

    *******************************************************************;
    *Note: create a lookup (in event of job bombing) in client library
    *      this automatically removes it in case of a job rerun       
    *******************************************************************;
proc datasets library=clin nolist;
   delete cacdirect_lookup;
quit;

*-----------------------------------------*;
* 1) CLEAN DATA
     prep for matching 
     set aside known bad
*-----------------------------------------*;
%nobs(data=clin.&client_data);
%let full=&nobs;

data clean client_not_clean;
   set clin.&client_data (keep=&client_id &zip5 &zip4 &name_var &name_var2 &addr1 &addr2 &state_var &zip5) end=eof;
   ***___CREATES SCF AND ST_SCF__***;
   mk_zip=&zip5;
   mk_scf=substr(mk_zip,1,3);
   retain changed_state 0;
   changed_state+ ((zipstate(mk_zip)^=&state_var));
   if eof then call symput('chg_st',changed_state);
   if zipstate(mk_zip) = &state_var then do;
      mstate=&state_var;
      st_scf=compress(mstate||"_"||substr(mk_zip,1,3));
   end;
   else if zipstate(mk_zip) ne &state_var and zipstate(mk_zip) in (&full_states) then do;
      mstate=zipstate(mk_zip);
      st_scf=compress(mstate||"_"||substr(mk_zip,1,3));
   end;
   ***___PUTS NAME/ADDRESS FIELDS TOGETHER IF THERE ARE TWO FIELDS___***;
   %if &addr_format=2 %then %do;
      clean_addr=upcase(compbl(strip(&addr1)||" "||strip(&addr2)));
   %end;
   %else %if &addr_format=1 %then %do;
      clean_addr=upcase(strip(&addr1));
   %end;
   %if &name_format=2 %then %do;
      clean_name=upcase(compbl(strip(&name_var)||" "||strip(&name_var2)));
   %end;
   %else %if &name_format=1 %then %do;
      clean_name=upcase(strip(&name_var));
   %end;
   ***___OUTPUT DIRTY DATA:  IF MISSING NAME OR OTHER MATCHING ELEMENT___***;
   if clean_addr='' /*or clean_name='' - ALLOW THESE for address only*/ or mstate='' or zipstate(mk_zip) not in (&state_list) or
      upcase(substr(st_scf,1,2)) not in (&full_states) or put(st_scf,$val_st_scf.)='I' then output client_not_clean;
   else output clean;
run;

*-------------------------------------------------------*;
* INITIALIZE TABLE HERE CUZ WPS SUCKS AND CANT APPEND 
*-------------------------------------------------------*;
data clin.cacdirect_lookup;
   set clean (obs=0 keep=&client_id);
   format mstate $2.
          cac_hh_pid $27.
          cac_active_flag cac_production matched_key 8.;
run;

%nobs(data=client_not_clean);
%let dirty=&nobs;
title 'You have Unclean data';
title2 'You may want to pay some attention to your file to get better match results';
proc print data=client_not_clean (obs=20);
run;
title;
title2;

*-----------------------------------------*;
* 2) PARSIMONY 
*-----------------------------------------*;

%parsimony(inlib=work, indata=clean, outlib=work, outdata=client_outdat, keep_clean=1, keep_keys=1, keep_pieces=0, pname_form=1, pname1=clean_name, pname2=, paddr_form=1, paddr1=clean_addr, paddr2=, pstate=&state_var, pzip=&zip5);

proc datasets library=work nolist;
   delete clean;
quit;

*-----------------------------------------*;
* 3) SPLIT INTO STATES
*-----------------------------------------*;

data %do state_num=1 %to &state_count; client_%scan(&states_for_match, &state_num) %end;;
   set client_outdat (rename=(parse_name_first=hold_first_name));
   drop parse:;
   st_scf=compress(mstate||"_"||substr(mk_zip,1,3));
   if mstate="%scan(&states_for_match, 1)" then output client_%scan(&states_for_match, 1);
   %if &state_count>1 %then %do;
      %do state_num=2 %to &state_count;
         else if mstate="%scan(&states_for_match, &state_num)" then output client_%scan(&states_for_match, &state_num);
      %end;
   %end;
run;

*-----------------------------------------*;
* 4) SPLIT INTO SCFS
*-----------------------------------------*;

********************************************************;
*---------START OF MASTER STATE LOOP-------------------*;
%do state_num=1 %to &state_count;
   %let curstate=%scan(&states_for_match, &state_num);
*------------------------------------------------------*;
********************************************************;
   %nobs(data=client_&curstate);
   %if &nobs>0 %then %do;

      ***___GET LIST OF ALL VALID CLIENT SCFS___***;
      proc sort data=client_&curstate (keep=st_scf) out=client_scfs_&curstate nodupkey;
         by st_scf;
      run;
   
      ***___PUT LIST OF SCFS INTO MACRO VARIABLE___***;
      %global cl_scfs;
      proc sql noprint;
         select compress(st_scf) into :list_scfs separated by ' ' 
         from client_scfs_&curstate
         order by compress(st_scf);
      quit;
   
      %put &list_scfs;
      ***___GET STATE/SCF COUNT AND WRITE OUT THE COUNT VARIABLE___***;
      %macro wc(list);
         %global count; 
         %let count = 0;
            %do %while(%qscan(&list, &count+1, %str( )) ne %str());
               %let count = %eval(&count+1);
            %end;
      %mend wc;
      %wc(&list_scfs);
      ***___GET MKEY COUNT___***;
      %global keynum;
      %let keynum=%eval(&key1 + &key2 + &key3 + &key4 + &key5 + &key6 + &key7);
      ***___OUTPUT SEPARATE DATASET FOR EACH SCF___***;
      %let scf_list = &list_scfs;
      %let num_scf = &count;
   
      ***___PREP CLIENT SCF FILES___***;
      data %do j = 1 %to &num_scf; client_scf_%scan(&scf_list, &j)%end;;
         set client_&curstate;
         %do j = 1 %to &num_scf;
            if st_scf = "%qscan(&scf_list, &j)" then output client_scf_%scan(&scf_list, &j) ;
         %end;
      run;
   
*-----------------------------------------*;
* 5) GO GRAB PID AND PUT ON CLIENT FILE
*-----------------------------------------*;
      
      *---------START OF SCF LOOP (within state)-------------------*;
      %do aaa = 1 %to &count;
      *------------------------------------------------------*;
         %let keylist=;
         %do listk=1 %to 7;
            %if &&key&listk=1 %then %do;
                %let keylist=&keylist &listk;
            %end;
         %end;
         %put &keylist;
 
         ***___ LOOP THROUGH KEYS TO FIND BEST KEY MATCH POSSIBLE___***;
         %do nums=1 %to &keynum;
            %let key=%scan(&keylist,&nums);
            %if &nums=1 %then %do; 
               proc sort data=client_scf_%scan(&scf_list, &aaa);
                  by mkey&key;
               run;
            %end;
            %if &nums>1 %then %do;
               proc sort data=nomatch_%scan(&scf_list, &aaa);
                  by mkey&key;
               run;
            %end;
   
            data cl_match_%scan(&scf_list, &aaa)_key&key 
                 nomatch_%scan(&scf_list, &aaa) (drop=CAC_ACTIVE_FLAG CAC_HH_PID CAC_PRODUCTION CAC_QTR );
               merge 
                     %if &nums=1 %then %do; 
                         client_scf_%scan(&scf_list, &aaa) (in=a)
                     %end;
                     %if &nums>1 %then %do;
                         nomatch_%scan(&scf_list, &aaa) (in=a)
                     %end;
                     scf.scf_%scan(&scf_list, &aaa)_key&key (in=b keep=CAC_ACTIVE_FLAG CAC_HH_PID CAC_PRODUCTION CAC_QTR MKEY&key);
               by mkey&key;
               if a and b then do;
                  matched=1;
                  matched_key=&key;
                  output cl_match_%scan(&scf_list, &aaa)_key&key;
               end;
               else if a and not b then output nomatch_%scan(&scf_list, &aaa);
            run;
         %end;                                     *------------------------------- END OF NUMS LOOP (for keys>1);
      %end;                                     *------------------------------- END OF SCF LOOP;

      ***___SET MATCHES TOGETHER BY KEY SO THAT WE HAVE ALL IN ONE DATASET___***;
      data client_matched_&curstate (keep=&client_id &zip5 &zip4 cac_hh_pid cac_production cac_active_flag mstate mk_zip matched matched_key hold_first_name );
         set %do t= 1 %to &count; 
                 %do g =1 %to &keynum;
                      %let key=%scan(&keylist,&g);
                      cl_match_%scan(&scf_list, &t)_key&key 
                 %end;
                      nomatch_%scan(&scf_list, &t) (in=x%scan(&scf_list, &t))
              %end;
          ;
         if %do bvd=1 %to &count; x%scan(&scf_list, &bvd) OR %end; XXXXXXXXXXXXX then do;
              matched=0;
              matched_key=.;
              cac_hh_pid=.;
              cac_active_flag=.;
              cac_production=.;
           end;
      run;
   
      *---------------------------------------------------------------*;
      *  COMMENTING OUT EFFICIENT CODE CUZ WPS CANNOT HANDLE          *;
      *---------------------------------------------------------------*;
      %macro wps; 
         proc append base=clin.cacdirect_lookup data=client_matched_&curstate (keep=mstate &client_id cac_hh_pid cac_active_flag cac_production matched_key) force;
         run;
      %mend wps;
      data clin.cac_direct_lookup;
         set clin.cacdirect_lookup
             client_matched_&curstate (keep=mstate &client_id cac_hh_pid cac_active_flag cac_production matched_key);
      run;
  
      proc datasets library=work nolist;
         delete client_&curstate client_scfs_&curstate 
                %do t= 1 %to &count; 
                   %do g =1 %to &keynum;
                        %let key=%scan(&keylist,&g);
                        cl_match_%scan(&scf_list, &t)_key&key 
                   %end;
                   nomatch_%scan(&scf_list, &t)
              %end;
          ;
      quit;

      proc sort data=client_matched_&curstate;
         by cac_hh_pid mstate mk_zip;
      run; 
   
*-----------------------------------------*;
* 6) ADD BASE DEMO FIELDS (NOT SELECTABLE)
*-----------------------------------------*;
      proc sort data=client_matched_&curstate (keep=matched cac_hh_pid where=(matched=1)) nodupkey out=for_format_&curstate;
         by cac_hh_pid;
      run;
      
      %nobs(data=for_format_&curstate);
      %let abort=&nobs;
   
      %if &abort=0 %then %do;
         data base_demo_&curstate;
            set base.base_demo_&curstate (obs=0);
         run;
      %end;
      %if &abort>0 %then %do;
         data _null_;
            set for_format_&curstate (where=(matched=1)) end=eof;
            file './formats_for_match.sas';
            if _n_=1 then put "proc format; value $client";
            format putvar $100.;
            putvar=compress("'" || cac_hh_pid || "'=1");
            put putvar;
            if eof then put 'other=0; run;';
         run;
         filename temp temp;
         proc printto log=temp; run;
         %include './formats_for_match.sas';
         proc printto log=log; run;
      
         proc sort data= base.base_demo_&curstate (where=(put(cac_hh_pid, $client.)='1')) out=base_demo_&curstate;
            by cac_hh_pid;
         run;

         x 'rm ./formats_for_match.sas';
      %end;                                                 *-------------------------> ABORT LOOP*;
      proc sort data=client_matched_&curstate;
         by cac_hh_pid;
      run;

      proc contents data=base_demo_&curstate noprint out=_dump;
      run;
       
      filename tempC temp;
      filename tempN temp;
      data _null_;
         set _dump end=eof;
         file tempC;
         if _n_=1 then put '%let cwipe=';
         if type=2 then put name;
         if eof then put ';'; 
         file tempN;
         if _n_=1 then put '%let nwipe=';
         if type=1 then put name;
         if eof then put ';'; 
      run;
      %include tempC;
      %include tempN;

      proc datasets library=work nolist;
         delete _dump;
      quit;
   
      ***___APPEND HOUSEHOLD DEMO AND INTEREST DATA___***;
      data client_with_demo_&curstate %if &match_lev=2 %then %do; (drop=ind_match) %end;;
            merge client_matched_&curstate (in=a)
                  base_demo_&curstate (in=b);
         by cac_hh_pid;  
         if a;
         %if &match_lev=2 %then %do;
            if matched=1 then do;
               hh_match=1;
               ind_match=0;
               matched=0;
               %do indmatch=1 %to 5;
                  if ind_match=0 and hold_first_name=cac_ind&indmatch._name then do;
                     ind_match=1;
                     match_person=&indmatch;
                     matched=1;
                  end;
               %end;
               if ind_match=0 then do;
                  matched_key=.;
                  array nwipe &nwipe;
                  do over nwipe;
                     nwipe=.;
                  end;
                  array cwipe &cwipe;
                  do over cwipe;
                     cwipe='';
                  end;
               end;
            end;
         %end;
         ***___FOR GEO / CENSUS MATCHING___***; 
         format match_zip5 $5. match_zip4 $4. match_zip2 $7.;
         if matched=1 then do;
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
         if matched=0 then do;
            ***___assign client zip5 and client zip2 where available___***;
            match_zip5=&zip5;
            match_zip2=compress(match_zip5||'XX');
            %if &zip4 ne %str() %then %do; 
               match_zip4=&zip4;
               match_zip2=compress(match_zip5 || substr(&zip4,1,2));
               if match_zip4='' then match_zip2=compress(match_zip5||'XX');
            %end;
         end;
         %if &cacd_prod=0 %then %do;
            drop cac_deliverability_date cac_hh_verification_date cac_niches cac_num_sources cac_qtr cac_year cac_recno cac_record_quality;
         %end;
         %if &addr_detail=0 %then %do;
            drop cac_addr_carrier_rt cac_addr_cbsa_code cac_addr_censor_cd cac_addr_county_code cac_addr_dlv_pt_code cac_addr_dsf_seasonal
                 cac_addr_dsf_type cac_addr_fips_st cac_addr_frac cac_addr_lat_long_ind cac_addr_lot_code cac_addr_num cac_addr_po_box_designator
                 cac_addr_po_route_num cac_addr_second_unit cac_addr_street cac_addr_street_pre cac_addr_street_suff cac_addr_street_suff_dir;
         %end;
      run; 
   
      proc datasets library=work nolist;
         delete base_demo_&curstate client_matched_&curstate for_format_&curstate ;
      quit;

      proc sort data=client_with_demo_&curstate;
         by &client_id;
      run;
*-----------------------------------------*;
* 7) ADD GEO INTERESTS (IF SELECTED)  
*-----------------------------------------*;
      %if &geo_interest=1 %then %do;

         proc sort data=client_with_demo_&curstate (keep=&client_id match_zip5 match_zip2 rename=(match_zip5=cac_addr_zip match_zip2=cac_addr_zip2)) out=client_z2_&curstate ;
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
     
         data client_with_demo_&curstate(sortedby=&client_id);
            merge client_with_demo_&curstate (in=a)
                  client_z2_final_&curstate (in=b);
            by &client_id;
            if a and b;
         run;

         title 'summary of GEO-Matching Results';
         proc format;  value gee 1='Match @ Zip+2 Level' 2='Match @ Zip Level' 3='Match @ State Level'; run;
         proc freq data=client_with_demo_&curstate;
            tables cac_geo_match /list missing;
            format cac_geo_match gee.;
         run; 
         title;

         proc datasets library=work nolist;
            delete client_z2_final_&curstate client_z2_found_&curstate client_zip_found_&curstate client_state_found_&curstate client_z2_&curstate;
         quit;

      %end;                                      *------------------------------------ END OF GEO LEVEL INTEREST APPENED;
     
*-----------------------------------------*;
* 8) ADD CENSUS DATA (IF SELECTED)    
*-----------------------------------------*;
      %if &census=1 %then %do ;
 

      %end; 

*-----------------------------------------*;
* 9) ADD ETHNIC DATA (IF SELECTED)    
*-----------------------------------------*;
      %if &ethnic=1 %then %do ;
         proc sort data=client_with_demo_&curstate (keep=cac_hh_pid &client_id) out=for_etech_&curstate;
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
  
         data client_with_demo_&curstate(sortedby=&client_id);
            merge client_with_demo_&curstate (in=a)
                  match_etech_&curstate (in=b);
            by &client_id;
            if a and b;
         run; 

         proc datasets library=work nolist;
            delete match_etech_&curstate for_etech_&curstate;
         quit;
      %end;                                      *------------------------------------ END OF ETHNIC DATA APPENED;

*-----------------------------------------*;
* 10) ADD INDIVIDUAL DATA (IF SELECTED)    
*-----------------------------------------*;
      %if &individual=1 %then %do;
 
         ***___IN CASE NOT SORTED___***;
         proc sort data=indiv.indiv_demo_&curstate;
            by cac_hh_pid cac_indiv_number;
         run;

         %if &match_lev=1 %then %do;

            proc sort data=client_with_demo_&curstate (keep=cac_hh_pid hold_first_name &client_id) out=for_ind_&curstate;
               by cac_hh_pid hold_first_name;
            run;

            proc sort data=indiv.indiv_demo_&curstate (keep=cac_hh_pid cac_indiv_pid cac_indiv_number cac_indiv_last cac_indiv_gender
                                                            cac_indiv_age cac_indiv_birthdate cac_indiv_name cac_indiv_mi cac_indiv_relationship) nodupkey out=name;
               by cac_hh_pid cac_indiv_name;
            run;

            data match_ind_&curstate take_first (drop=  cac_indiv:);
               merge for_ind_&curstate (in=a rename=(hold_first_name=cac_indiv_name))
                     name              (in=b);
               by cac_hh_pid cac_indiv_name;
               if a and b then output match_ind_&curstate;
               else if a then output take_first;
            run;
 
            proc sort data=take_first;
               by cac_hh_pid;
            run;

            data match_ind_&curstate.2;
               merge take_first (in=a)
                     indiv.indiv_demo_&curstate (in=b drop=cac_hh_pid_ind where=(cac_indiv_number=1));
               by cac_hh_pid ;
               if a;
            run;

            data match_ind_&curstate;
               set match_ind_&curstate
                   match_ind_&curstate.2;
            run;

         %end;
         %if &match_lev=2 %then %do;

            proc sort data=client_with_demo_&curstate (keep=cac_hh_pid match_person &client_id) out=for_ind_&curstate;
               by cac_hh_pid match_person;
            run;

            proc sort data=indiv.indiv_demo_&curstate;
               by cac_hh_pid cac_indiv_number;
            run;

            data match_ind_&curstate;
               merge for_ind_&curstate (in=a rename=(match_person=cac_indiv_number))
                     indiv.indiv_demo_&curstate (in=b drop=cac_hh_pid_ind);
               by cac_hh_pid cac_indiv_number;
               if a then output;
            run;

         %end;

         proc sort data=match_ind_&curstate;
            by &client_id;
         run;
  
         data client_with_demo_&curstate(sortedby=&client_id);
            merge client_with_demo_&curstate (in=a)
                  match_ind_&curstate (in=b);
            by &client_id;
            if a and b;
         run; 

         proc datasets library=work nolist;
            delete match_ind_&curstate match_ind_&curstate %if &match_lev=1 %then %do; match_ind_&curstate.2 %end;;
         quit;

      %end;

*-----------------------------------------*;
* 11) STACK STATE RESULTS INTO FULL SAMPLE
*-----------------------------------------*;
      proc append base=client_with_demo data=client_with_demo_&curstate force;
      run;
   
      proc datasets library=work nolist;
         delete base_demo_&curstate;
      quit;

      %if &results_by_state=1 %then %do; 
   
         %if &abort=0 %then %do;
   
         data print;
            format summary $100.;
            summary = '______________________________________________________________________________________';
            output;
            summary = "   No records matched in &curstate                                                    ";
            output;
            summary = '                                                                                      ';
            output;
            summary = '   Either you data is terrible, you did not clean it, or...                           ';
            output;
            summary = '   you are running a geographically restricted sample through and the state field     ';
            output;
            summary = '   on a handful of your records was changed by zip state.  This causes one/two        ';
            output;
            summary = '   records to run through a different state with low chance of matching, which        ';
            output;
            summary = '   leads to states with no matched records.                                           ';
            output;
            summary = '                                                                                      ';
            output;
            summary = '   SO, clean your data better - or use the supplied state parameter in the macro call.';
            output;
            summary = '______________________________________________________________________________________';
            output;
         run;
      
         proc print data=print;
         run;
    
         proc datasets library=work nolist;
            delete print;
         quit;
         
         %end;
         %if &abort>0 %then %do;

         *ods pdf file="./cacdirect_results_&client_data._&curstate..pdf";
         ods html body="./cacdirect_results_&client_data._&curstate..html";

            title "CACdirect Match Summary for &curstate";
            proc freq data=client_with_demo_&curstate;
               table matched %if &match_lev=2 %then %do; * hh_match match_person %end;;
               format matched %if &match_lev=2 %then %do; hh_match %end; match. ;
            run;
            
            title "CACdirect Match Highlights for &curstate";
            proc freq data=client_with_demo_&curstate;
               where matched=1 %if &match_lev=2 %then %do; and hh_matched=1 %end;; 
               tables matched_key cac_active_flag*cac_production 
                      %if &geo_interest=1 %then %do; cac_geo_match %end; %if &census=1 %then %do; cac_census_match %end; 
                      %if &ethnic=1 %then %do; cac_ethnic_match %end;
                      cac_addr_cdi cac_silh cac_silh_lifedriver cac_demo_age cac_demo_income cac_demo_marital_status cac_demo_kids_presence / list missing;
               format cac_active_flag cac_act. cac_production cac_prod.
                      %if &geo_interest=1 %then %do; cac_geo_match geo_match. %end; 
                      %if &census=1 %then %do; cac_census_match match. %end; %if &ethnic=1 %then %do; cac_ethnic_match match. %end; 
                      cac_silh silh.
                      cac_silh_lifedriver $silh_ld.
                      cac_addr_cdi $cac_cdi.
                      cac_demo_age cac_age.
                      cac_demo_income $cac_inc.
                      cac_demo_kids_presence cac_kids.
                      cac_demo_marital_status cac_mar.;
            run;
         %end;
         *ods pdf close;
         ods html close;
      %end;                      *---------------------------- END OF RESULTS_BY_STATE LOOP;
   %end;                      *---------------------------- END OF STATE_NUM LOOP; 
%end;                      *-----------------------------END OF NOBS CONDITION;
   
*-----------------------------------------*;
* 12) OUTPUT FINAL FILE                   
*-----------------------------------------*;
proc sort data=client_with_demo;
   by &client_id;
run;

proc sort data=clin.&client_data out=client_in;
   by &client_id;
run;

data clin.&client_data._matched _dump (keep=cacdirect_hh_match where=(cacdirect_hh_match=1));
  merge client_in (in=a)
        client_with_demo (in=b drop=match_zip5 match_zip4 match_zip2 &zip5 &zip4 hold_first_name mstate mk_zip)
        client_not_clean (in=c keep=&client_id);
   by &client_id;
   if (a AND b) OR C;
   if c then matched=0;
   rename matched=cacdirect_hh_match;
   label matched='CACdirect Match (Household Level)';
   rename matched_key=cacdirect_match_key;
   label matched_key='CACdirect key that matched to the record (Lower = More Exact)';
   %if &match_lev=2 %then %do;
      rename match_person=cacdirect_match_person;
      label match_person='CACdirect Individual that matched (Person # within the Household)';
      rename hh_match=cacdirect_hh_match;
      rename matched=cacdirect_ind_match;
      label matched='CACdirect Match (Individual Level)';
   %end;
   %if &geo_interest=1 %then %do; 
      label cac_geo_match='CACdirect Match to Geo Interest Data'; 
   %end; %if &census=1 %then %do; cac_census_match %end; 
   %if &ethnic=1 %then %do; 
      label cac_ethnic_match='CACdirect Match to Ethnicity Data';
   %end;

   drop cac_demo_dob_child: ;

run;

proc contents data=clin.&client_data._matched;

%nobs(data=_dump);

*ods pdf file="./cacdirect_results_&client_data..pdf";
ods html body="./cacdirect_results_&client_data..html";

data print;
            summary = '   Record summary                                                                                    ';   
            output;
            summary = '';   
            output;
            summary = "   Input Records: &full";
            output;
            summary = "   Dirty Records: &dirty / %eval(100*&dirty/&full)%";
            output;
            summary = "   States Changed: &chg_st / %eval(100*&chg_st/&full)%";
            output;
            summary = '';   
            output;
            summary = "   Records Sent for Matching:   %eval(&full - &dirty - &chg_st) / %eval(100*%eval(&full - &dirty - &chg_st)/&full)%";
            output;
            summary = "   Records Matched: &nobs / %eval(100*&nobs/%eval(&full-&dirty))%";
            output;
run;

title "Data Quality Report";
proc print data=print noobs;
run;

title "CACdirect Match Summary";
proc freq data=clin.&client_data._matched;
   table cacdirect_hh_match %if &match_lev=2 %then %do; * cacdirect_ind_match cacdirect_match_person %end;;
   format cacdirect_hh_match %if &match_lev=2 %then %do; cacdirect_ind_match %end; match. ;
run;

title "CACdirect Match Highlights";
proc freq data=clin.&client_data._matched;
   where cacdirect_hh_match=1 %if &match_lev=2 %then %do; and cacdirect_ind_match=1 %end;; 
   tables cacdirect_match_key cac_active_flag*cac_production 
          %if &geo_interest=1 %then %do; cac_geo_match %end; %if &census=1 %then %do; cac_census_match %end; 
          %if &ethnic=1 %then %do; cac_ethnic_match %end; 
          cac_addr_cdi cac_silh cac_silh_lifedriver cac_demo_age cac_demo_income cac_demo_marital_status cac_demo_kids_presence / list missing;
   format cac_active_flag cac_act. cac_production cac_prod.
          %if &geo_interest=1 %then %do; cac_geo_match geo_match. %end; 
          %if &census=1 %then %do; cac_census_match match. %end; %if &ethnic=1 %then %do; cac_ethnic_match match. %end;
          cac_silh silh.
          cac_silh_lifedriver $silh_ld.
          cac_addr_cdi $cac_cdi.
          cac_demo_age cac_age.
          cac_demo_income $cac_inc.
          cac_demo_kids_presence cac_kids.;
run;

title 'Contents of Matched Data';
proc contents data=clin.&client_data._matched;
run;

*ods pdf close;
ods html close;

data _null_;
   end_time=put(time(), time.);
   call symput('end_time',end_time);
   end_date=put(date(), date.);
   call symput('end_date',end_date);
   end_dt=put(datetime(),datetime.);
run;

filename sendmail email to=("&email")
                  subject="CACdirect Matching Results - &client_data" 
                  from="webmaster@cac-group.com" 
                  /*attach="./cacdirect_results_&client_data..pdf";*/
                  attach="./cacdirect_results_&client_data..html";
data _null_;
   file sendmail;
   put "Your CACdirect matching job has completed.";
   put ;
   %if &match_lev=1 %then %do; 
      put "The dataset (&client_data._matched) has been matched at the household level and placed in &client_dir with the following types of data appended:";
   %end;
   %if &match_lev=2 %then %do; 
      put "The dataset (&client_data._matched) has been matched at the individual level and placed in &client_dir with the following types of data appended:";
   %end;
   put "      - Household demographics and interests ('Base' data - includes prefixes of 'CAC_ADDR_', 'CAC_CRED_', 'CAC_DEMO_', 'CAC_HOME_', 'CAC_IND', 'CAC_INT_', 'CAC_LE_', 'CAC_MV_', 'CAC_SILH_', 'CAC_TRIG_', 'CAC_VAL_'), including Silhouettes";
   %if &geo_interest=1 %then %do;
      put "      - Geographic level interests ('Geo Int' data - all have prefix of 'GEO_'), at Zip+2 level where possible";
   %end;
   %if &ethnic=1 %then %do;
      put "      - Ethnic / religious data ('Ethnic' or 'Etech' data - all have prefix of 'ETECH_')";
   %end;
   %if &individual=1 %then %do;
      put "      - Individual data ('Indiv' data - all have prefix of 'CAC_INDIV_') for the individual that was input, or for the head of the household if that individual was not found (household matching only)";
   %end;
   put ;
   put "The job was initiated on &start_date at &start_time and completed on &end_date at &end_time";
   put ;
   put "Good Work";
   put ;
   put "Please ensure you read the CACdirect manual before using this data.  The CACdirect Data Dictionary, along with this manual, can be found in P:\CACDIRECT\ADMIN\DATABASE\DOCUMENTATION.";
   put ;
   put "Sincerely,";
   put "Your CACdirect Team";
run;
%mend matchmaker;
