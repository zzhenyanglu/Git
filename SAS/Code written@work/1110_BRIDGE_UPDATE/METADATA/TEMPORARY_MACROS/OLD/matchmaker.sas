*------------------------------------------------------------------------------------------------*;
* PROGRAM: matchmaker.sas *;
* PURPOSE: ONE MACRO TO IMPORT, CLEAN UP, AND MATCH CLIENT DATA TO CACDIRECT;
* HISTORY: 4/19/2012 CREATED
* AUTHOR:  Patty Seeburger, Mike Mattingly, Joel Schiltz
* SECTIONS:
*      >>>> STEP 1: CLEAN DATA
*                   --INPUT DATA: CLIN.&CLIENT_DATA
*                   --OUTPUT DATA: CLEAN
*                                  CLIENT_NOT_CLEAN
*                                  CLIENT_DUPS
*      >>>> STEP 2: PARSIMONY
*                   --INPUT DATA: CLEAN
*                   --OUTPUT DATA: CLIENT_OUTDAT
*      >>>> STEP 3: SPLIT INTO STATES
*                   --INPUT DATA: CLIENT_OUTDAT
*                   --OUTPUT DATA: CLIENT_*STATE NAME*
*      >>>> STEP 4: SPLIT INTO SCF
*                   --INPUT DATA: CLIENT_*STATE NAME*
*                   --OUTPUT DATA: CLIENT_SCF_*STATE NAME*_*SCF*_*KEY*
*      >>>> STEP 5: GO GRAB PID AND PUT ON CLIENT FILE
*      >>>> STEP 6: GRAB FIELDS WANTED
*      >>>> STEP 7: FINAL OUTPUT
*------------------------------------------------------------------------------------------------*;

%macro matchmaker(client_dir=, client_data=, client_id=, name_format=, name_var=, name_var2=, addr_format=, addr1=, addr2=, 
                  state_var=, zip5=, zip4=, key1=, key2=, key3=, key4=, key5=, key6=, key7=, state_list=, ethnic=,
                  geo_interest=, census=, census_keep=, individual=);

* IMPORT FORMAT OF VALID SCF BY STATE - UPDATE QUARTERLY BY CACDIRECT UPDATE PROCESS;
%include '/project13/CACDIRECT/CODE/PROD/METADATA/INCLUDES/valid_st_scf.sas';

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

/*NEED TO CHANGE SO THAT THIS WON'T HAVE QUOTES*/
%else %do;
   %let states_for_match=&state_list;
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
libname tsp &tsp;
libname demo &demo;

proc datasets library=clin nolist;
   delete cacdirect_lookup;
quit;

*********************;
*STEP 1: CLEAN DATA *;
*********************;

   data clean client_not_clean;
      set clin.&client_data (keep=&client_id &zip5 &zip4 &name_var &name_var2 &addr1 &addr2 &state_var &zip5);
      * CREATES SCF AND ST_SCF *;
      mk_zip=&zip5;
      mk_scf=substr(mk_zip,1,3);
      if zipstate(mk_zip) = &state_var then do;
         state=&state_var;
         st_scf=compress(state||"_"||substr(mk_zip,1,3));
      end;
      else if zipstate(mk_zip) ne &state_var and zipstate(mk_zip) in (&full_states) then do;
         state=zipstate(mk_zip);
         st_scf=compress(state||"_"||substr(mk_zip,1,3));
      end;
      * PUTS ADDRESS FIELDS TOGETHER IF THERE ARE TWO ADDRESS FIELDS *;
      %if &addr_format=2 %then %do;
         clean_addr=upcase(compbl(strip(&addr1)||" "||strip(&addr2)));
      %end;
      %else %if &addr_format=1 %then %do;
         clean_addr=upcase(strip(&addr1));
      %end;
      * PUTS NAME FIELDS TOGETHER IF THERE ARE TWO NAME FIELDS *;
      %if &name_format=2 %then %do;
         clean_name=upcase(compbl(strip(&name_var)||" "||strip(&name_var2)));
      %end;
      %else %if &name_format=1 %then %do;
         clean_name=upcase(strip(&name_var));
      %end;
      * CHECKS FOR MISSING VALUES AND INVALID STATES *;
      if clean_addr='' or clean_name='' or state='' or zipstate(mk_zip) not in (&state_list) or
         upcase(substr(st_scf,1,2)) not in (&full_states) or put(st_scf,$val_st_scf.)='I' then output client_not_clean;
      else output clean;
   run;

proc print data=client_not_clean (obs=100);
   title 'NOT CLEAN CLIENT DATA';
run;

proc sort data=client_not_clean;
   by &client_id;
run;

********************;
*STEP 2: PARSIMONY *;
********************;

%parsimony(inlib=work, indata=clean, outlib=work, outdata=client_outdat, keep_clean=0, keep_keys=1, keep_pieces=0, pname_form=1, pname1=clean_name, pname2=, paddr_form=1, paddr1=clean_addr, paddr2=, pstate=&state_var, pzip=&zip5);

****************************;
*STEP 3: SPLIT INTO STATES *;
****************************;

   data %do state_num=1 %to &state_count; client_%scan(&states_for_match, &state_num) %end;;
      set client_outdat;
      st_scf=compress(state||"_"||substr(mk_zip,1,3));
      if state="%scan(&states_for_match, 1)" then output client_%scan(&states_for_match, 1);
      %if &state_count>1 %then %do;
         %do state_num=2 %to &state_count;
            else if state="%scan(&states_for_match, &state_num)" then output client_%scan(&states_for_match, &state_num);
         %end;
      %end;
   run;

**************************;
* STEP 4: SPLIT INTO SCF *;
**************************;

*---------START OF MASTER STATE LOOP-------------------*;
%do state_num=1 %to &state_count;
%let curstate=%scan(&states_for_match, &state_num);
*------------------------------------------------------*;

   %nobs(data=client_&curstate);
   %if &nobs>0 %then %do;

***********************************************************
   TEMPORARY SECTION UNTIL FORMATS FIGURED OUT
***********************************************************;
/*
proc sql noprint;
   select compress(scf) into :val_scfs separated  by ' '
   from 
   (select distinct(substr(cac_addr_zip,1,3)) as scf
    from base.base_demo_%scan(&states_for_match, &state_num))
quit;
data client_&curstate app_not_clean;
   set client_&curstate;
   if substr(&zip5,1,3) NOT IN (&val_scfs) then output app_not_clean;
   else output client_&curstate;
run;
proc append base=client_not_clean data=app_not_clean force;
run;
*/
***********************************************************
   END TEMPORARY SECTION UNTIL FORMATS FIGURED OUT
***********************************************************;

   * GET LIST OF ALL VALID CLIENT SCFS *;
   proc sort data=client_&curstate (keep=st_scf) out=client_scfs_&curstate nodupkey;
      by st_scf;
   run;

   * PUT LIST OF SCFS INTO MACRO VARIABLE *;
   %global cl_scfs;
   proc sql noprint;
      select compress(st_scf) into :list_scfs separated by ' ' 
      from client_scfs_&curstate
      order by compress(st_scf);
   quit;

   %put &list_scfs;
   * GET STATE/SCF COUNT AND WRITE OUT THE COUNT VARIABLE *;
   %macro wc(list);
      %global count; 
      %let count = 0;
         %do %while(%qscan(&list, &count+1, %str( )) ne %str());
            %let count = %eval(&count+1);
         %end;
   %mend wc;
   %wc(&list_scfs);
   * GET MKEY COUNT *;
      %global keynum;
      %let keynum=%eval(&key1 + &key2 + &key3 + &key4 + &key5 + &key6 + &key7);
   * OUTPUT SEPARATE DATASET FOR EACH SCF-MKEY COMBINATION *;
   %let scf_list = &list_scfs;
   %let num_scf = &count;

    *** PREP CLIENT SCF FILES ***;
         data %do j = 1 %to &num_scf; client_scf_%scan(&scf_list, &j)%end;;
            set client_&curstate;
            %do j = 1 %to &num_scf;
               if st_scf = "%qscan(&scf_list, &j)" then output client_scf_%scan(&scf_list, &j) ;
            %end;
         run;

*********************************************;
* STEP 5: GO GRAB PID AND PUT ON CLIENT FILE*;
*********************************************;

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

* LOOP THROUGH OTHER KEYS TO FIND BEST KEY MATCH POSSIBLE *;
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

     data cl_match_%scan(&scf_list, &aaa)_key&key nomatch_%scan(&scf_list, &aaa) (drop=CAC_ACTIVE_FLAG CAC_HH_PID CAC_PRODUCTION CAC_QTR );
        merge 
              %if &nums=1 %then %do; 
                  client_scf_%scan(&scf_list, &aaa)   (in=a)
              %end;
              %if &nums>1 %then %do;
                  nomatch_%scan(&scf_list, &aaa) (in=a)
              %end;
              tsp.scf_%scan(&scf_list, &aaa)_key&key (in=b keep=CAC_ACTIVE_FLAG CAC_HH_PID CAC_PRODUCTION CAC_QTR MKEY&key);
        by mkey&key;
        if a and b then do;
           matched=1;
           matched_key=&key;
           key=mkey&key;
           output cl_match_%scan(&scf_list, &aaa)_key&key;
        end;
        if a and not b then output nomatch_%scan(&scf_list, &aaa);
   run;

%end;                                     *------------------------------- END OF NUMS LOOP (for keys>1);

%end;                                     *------------------------------- END OF SCF LOOP;

* SET MATCHES TOGETHER BY KEY SO THAT WE HAVE ALL IN ONE DATASET *;
   data client_matched_&curstate (keep=&client_id &zip5 &zip4 cac_hh_pid cac_production cac_active_flag state mk_zip matched matched_key key state );
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
            key='';
            cac_active_flag=.;
            cac_production=.;
         end;
   run;

proc append base=clin.cacdirect_lookup data=client_matched_&curstate (keep=state &client_id cac_hh_pid cac_active_flag cac_production matched_key) force;
run;

proc sort data=client_matched_&curstate;
   by cac_hh_pid state mk_zip;
run; 

******************************;
* STEP 6: GRAB FIELDS WANTED *;
******************************;

   proc sort data=client_matched_&curstate (keep=matched cac_hh_pid where=(matched=1)) nodupkey out=for_format_&curstate;
      by cac_hh_pid;
   run;
   
   %nobs(data=for_format_&curstate);
   %let abort=&nobs;

   %if &abort=0 %then %do;
      data base_demo_&curstate;
         set demo.base_demo_&curstate (obs=0);
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
      proc printto log=temp; run;
      %include './formats_for_match.sas';
      proc printto log=log; run;
   
      proc sort data= demo.base_demo_&curstate (where=(put(cac_hh_pid, $client.)='1')) out=base_demo_&curstate;
        by cac_hh_pid;
      run;

      x 'rm ./formats_for_match.sas';
   %end;                                                 *-------------------------> ABORT LOOP*;
   proc sort data=client_matched_&curstate;
      by cac_hh_pid;
   run;

*APPEND HOUSEHOLD DEMO AND INTEREST DATA *;
   data client_with_demo_&curstate;
         merge client_matched_&curstate (in=a)
               base_demo_&curstate (in=b);
      by cac_hh_pid;  
      if a;
      if matched=1 then do;
         format match_zip5 $5. match_zip4 $4. match_zip2 $7.;
         *FOR GEO / CENSUS MATCHING; 
         *assign cacdir zip5 when matched*;
         match_zip5=cac_addr_zip;
         *assign cacdir zip4 when matched and zip4 not missing*;
         if cac_addr_zip4 ne '' then do;
               match_zip2=compress(cac_addr_zip||substr(cac_addr_zip4,1,2));
               match_zip4=compress(cac_addr_zip4);
         end;
         else if cac_addr_zip4='' then do;
            *if client zip4 is populated then assign that*;
            %if &zip4 ne %str() %then %do; 
                  match_zip4=&zip4;
                  match_zip2=compress(match_zip5||substr(&zip4,1,2));
            %end;
            *if client zip4 is not populated then make zip2 end in xx*;
            %if &zip4 eq %str() %then %do;
                  match_zip2=compress(match_zip5||'XX');
            %end;
         end;
      end;
      if matched=0 then do;
         *assign client zip5 and client zip2 where available*;
         match_zip5=&zip5;
         match_zip2=compress(match_zip5||'XX');
         %if &zip4 ne %str() %then %do; 
            match_zip4=&zip4;
            match_zip2=compress(match_zip5 || substr(cac_addr_zip4,1,2));
         %end;
      end;
      if a and b then hh_matched=1; 
      else hh_matched=0; 
   run;

*APPEND GEO LEVEL INTEREST DATA;
%if &geo_interest=1 %then %do;

    proc sort data=client_with_demo_&curstate;
       by &client_id;
    run;

    proc sort data=client_with_demo_&curstate (keep=&client_id match_zip5 match_zip2 rename=(match_zip5=cac_addr_zip match_zip2=cac_addr_zip2)) out=client_z2_&curstate ;
       by cac_addr_zip2;
    run;
    
    proc sort data=geo.geo_interest_&curstate;
       by cac_addr_zip2;
    run;

    data client_z2_found_&curstate (drop=newzip) zip_&curstate (rename=(cac_addr_zip2=hold));
       format cac_addr_zip2 $7.;
       merge client_z2_&curstate (in=a)
             geo.geo_interest_&curstate (in=b drop= cac_addr_state cac_addr_zip);
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

proc freq data=client_z2_found_&curstate;
   tables cac_geo_match /list missing;
   title 'QUALITY OF MATCHES';
run;

    data client_zip_found_&curstate (drop=cac_addr_zip2 newzip rename=(hold=cac_addr_zip2)) state_&curstate (drop=cac_addr_zip2);
       format cac_addr_zip2 $7.;
       merge zip_&curstate (in=a rename=(newzip=cac_addr_zip2))
             geo.geo_interest_&curstate (in=b drop= cac_addr_state cac_addr_zip);
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
             geo.geo_interest_&curstate (in=b drop= cac_addr_state cac_addr_zip);
       by cac_addr_zip2;
       cac_geo_match=3;
       if a and b;
    run;
  
    data client_z2_final_&curstate;
      set client_z2_found_&curstate (keep=&client_id geo_:) 
          client_zip_found_&curstate  (keep=&client_id geo_:)
          client_state_found_&curstate (keep=&client_id geo_:);
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

%end;                                      *------------------------------------ END OF GEO LEVEL INTEREST APPENED;


*FUTURE FIX:
  > more data collection
	> ETHNIC
	> INDIVIDUAL
	> CREDIT
	> CENSUS 2010 (replace below census) - categorize and and allow user to select groups
  > QC & reporting
	> match by: 
		state
		key
		P1s
		freq of key vars: age, income, kids, married, CDI, silhouettes (INDEXED TO 1%?)
  > FIX/CONSOLIDATE PARSIMONY
  > KEEP/DROPS on output data (dont need everything)
  > DATA maintanence/accountability 

_________________________
 BELLS/WHISTLES
   > launch through online app
   > email report delivery
   > early notification of issues (integrated QC throughout)
   > control lenght of dataset

;

************************************************************************;
* STEP 7: GET 2010 CENSUS FACTORS *;
* leverage code use for GSK CLONE MODEL HERE;
* /project/GSK/CLONE_MODEL/CODE/020_CREATE_SAMPLE_DATA/055* AND 060.SAS;
************************************************************************;

***************************************************************;
* STEP 8: APPEND 2010 CENSUS DATA;
* leverage code used to append 2000 census data;
* Note sumlev '817' (state 5 digit zip code dne on 2010 census;
***************************************************************;



********************************************************;
*APPEND CENSUS DATA (2000) --- SHOULD WE KEEP THIS???? *;
%if &census=1 %then %do ;

    proc sort data=client_with_demo_&curstate;
       by &client_id;
    run;

       proc sort data=cen2000.census_&curstate out=temp; 
          by sumlev zip5 county tract blkgrp descending census_001; 
       run;
     
     data census_&curstate;
        set temp;
        by sumlev zip5 county tract blkgrp;
        if first.blkgrp then output;
     run;

     data match_direct_&curstate(keep=&client_id cac_census_2000_level cac_addr_zip cac_addr_zip4 cac_census_2000_county_code cac_census_2000_tract cac_census_2000_tract_suffix cac_census_2000_block_group)
          match_zip9_&curstate(keep=&client_id cac_addr_zip cac_addr_zip4)
          match_zip5_&curstate(keep=&client_id cac_addr_zip)
          non_matches_&curstate(keep=&client_id);
        set client_with_demo_&curstate (keep=&client_id cac_census_2000_level match_zip5 match_zip2 match_zip4 cac_census_2000_county_code 
                                                              cac_census_2000_tract cac_census_2000_tract_suffix cac_census_2000_block_group
                                                              rename=(match_zip5=cac_addr_zip match_zip2=cac_addr_zip2 match_zip4=cac_addr_zip4));
        if cac_census_2000_level in (1, 2, 3) then output match_direct_&curstate;
        else do;
           if length(compress(cac_addr_zip4))=4 then output match_zip9_&curstate; 
           else if length(compress(cac_addr_zip))=5 then output match_zip5_&curstate;
           else output non_matches_&curstate;  ***no identifying information exists to match;
        end;
     run;

     proc sql;
       CREATE TABLE direct_census_match_&curstate as
          SELECT aa.*
            FROM
               (
                SELECT a.&client_id, a.cac_census_2000_level, b.*
                  FROM match_direct_&curstate a, census_&curstate b
                 WHERE a.cac_census_2000_level=1 and b.sumlev='871'
                   AND translate(a.cac_addr_zip,'+',' ') = translate(b.zip5,'+',' ')
              UNION ALL
                SELECT c.&client_id, c.cac_census_2000_level, d.*
                  FROM match_direct_&curstate c, census_&curstate d
                 WHERE c.cac_census_2000_level=2 and d.sumlev='140'
                   AND compress(translate(c.cac_census_2000_county_code,'+',' ')||
                                translate(c.cac_census_2000_tract,'+',' ')||
                                translate(c.cac_census_2000_tract_suffix,'+',' ')) =
                       compress(translate(d.county,'+',' ')||
                                translate(d.tract,'+',' '))
              UNION ALL
                SELECT e.&client_id, e.cac_census_2000_level, f.*
                  FROM match_direct_&curstate e, census_&curstate f
                 WHERE e.cac_census_2000_level=3 and f.sumlev='150'
                   AND compress(translate(e.cac_census_2000_county_code,'+',' ')||
                                translate(e.cac_census_2000_tract,'+',' ')||
                                translate(e.cac_census_2000_tract_suffix,'+',' ')||
                                translate(e.cac_census_2000_block_group,'+',' ')) =
                       compress(translate(f.county,'+',' ')||
                                translate(f.tract,'+',' ')||
                                translate(f.blkgrp,'+',' '))
               ) aa
       ;
       quit;
     run;

     proc sort data=match_direct_&curstate(keep=&client_id cac_addr_zip cac_addr_zip4) out=tried_&curstate;
        by &client_id; 
     run;

     proc sort data=direct_census_match_&curstate(keep=&client_id) out=matched_&curstate; 
        by &client_id; 
     run;
     
     data failed_direct_try_zip9_&curstate(keep=&client_id cac_addr_zip cac_addr_zip4);
        merge tried_&curstate(in=_a_)
              matched_&curstate(in=_b_);
        by &client_id;
        if _a_ and not _b_;
     run;
     
   %nobs(data=non_matches_&curstate);
   %if &nobs>0 %then %do;
     proc append base=match_zip9_&curstate new=failed_direct_try_zip9_&curstate;
     run;
   %end;

     proc sort data=match_zip9_&curstate;
        by cac_addr_zip cac_addr_zip4; 
     run;

     proc sort data=z9.zip9_census_lookup_&curstate out=lookup_&curstate;
        by zip zip4; 
     run;
     
     data zip9_matchkeys_&curstate;
        merge match_zip9_&curstate(in=_a_ keep=&client_id cac_addr_zip cac_addr_zip4 rename=(cac_addr_zip=zip cac_addr_zip4=zip4))
              lookup_&curstate(in=_b_ keep=zip zip4 census_level_match census_cnty census_tract census_tract_suffix block_group);
        by zip zip4;
        if _a_ and _b_;
     run;

     proc sql;
       CREATE TABLE zip9_census_match_&curstate as
          SELECT aa.*
            FROM
               (
                SELECT a.&client_id, a.census_level_match, b.*
                  FROM zip9_matchkeys_&curstate a, census_&curstate b
                 WHERE a.census_level_match='1' and b.sumlev='871'
                   AND translate(a.zip,'+',' ') = translate(b.zip5,'+',' ')
              UNION ALL
                SELECT c.&client_id, c.census_level_match, d.*
                  FROM zip9_matchkeys_&curstate c, census_&curstate d
                 WHERE c.census_level_match='2' and d.sumlev='140'
                   AND compress(translate(c.census_cnty,'+',' ')||
                                translate(c.census_tract,'+',' ')||
                                translate(c.census_tract_suffix,'+',' ')) =
                       compress(translate(d.county,'+',' ')||
                                translate(d.tract,'+',' '))
              UNION ALL
                SELECT e.&client_id, e.census_level_match, f.*
                  FROM zip9_matchkeys_&curstate e, census_&curstate f
                 WHERE e.census_level_match='3' and f.sumlev='150'
                   AND compress(translate(e.census_cnty,'+',' ')||
                                translate(e.census_tract,'+',' ')||
                                translate(e.census_tract_suffix,'+',' ')||
                                translate(e.block_group,'+',' ')) =
                       compress(translate(f.county,'+',' ')||
                                translate(f.tract,'+',' ')||
                                translate(f.blkgrp,'+',' '))
               ) aa
       ;
       quit;
     run;
     
     proc sort data=match_zip9_&curstate(keep=&client_id cac_addr_zip) out=tried_&curstate;
        by &client_id; 
     run;

     proc sort data=zip9_census_match_&curstate(keep=&client_id) out=matched_&curstate; 
        by &client_id; 
     run;

     data failed_zip9_try_zip5_&curstate(keep=&client_id cac_addr_zip);
        merge tried_&curstate(in=_a_)
              matched_&curstate(in=_b_);
        by &client_id;
        if _a_ and not _b_;
     run;

     proc append base=match_zip5_&curstate new=failed_zip9_try_zip5_&curstate; 
     run;
     
     proc sql;
       CREATE TABLE zip5_census_match_&curstate as
           SELECT a.&client_id, '1' as census_level_match, b.*
             FROM match_zip5_&curstate a, census_&curstate b
            WHERE b.sumlev='871'
              AND translate(a.cac_addr_zip,'+',' ') = translate(b.zip5,'+',' ');
       quit;
     run;
     
   proc sort data=match_zip5_&curstate(keep=&client_id) out=tried_&curstate; 
      by &client_id; 
   run;

   proc sort data=zip5_census_match_&curstate(keep=&client_id) out=matched_&curstate; 
      by &client_id; 
   run;
     
   data failed_zip5_&curstate(keep=&client_id);
      merge tried_&curstate(in=_a_)
            matched_&curstate(in=_b_);
      by &client_id;
      if _a_ and not _b_;
   run;

   %if &nobs>0 %then %do;
      proc append base=non_matches_&curstate new=failed_zip5_&curstate;
      run;
   %end;
     
   data final_&curstate;
      set direct_census_match_&curstate(in=_a_)
          zip9_census_match_&curstate(in=_b_)
          zip5_census_match_&curstate(in=_c_)
          %if &nobs>0 %then %do;
              non_matches_&curstate(in=_d_)
          %end;
      ;
      format census_source_match $6.;
      if _a_ then census_source_match="DIRECT"; else
      if _b_ then census_source_match="ZIP9"; else
      if _c_ then census_source_match="ZIP5"; else
          %if &nobs>0 %then %do;
      if _d_ then census_source_match="NONE";
          %end;
      flag_census_match=_a_ or _b_ or _c_;
      label flag_census_match="FLAG: MATCHED TO CENSUS (THRU DIRECT, ZIP9 OR ZIP5)";
   run;

   proc sort data=final_&curstate;
      by &client_id;
   run;

   %nobs(data=zip9_census_match_&curstate);
   
   data client_with_demo_&curstate;
      merge client_with_demo_&curstate (in=_a_ drop=cac_census_2000_level)
            final_&curstate (in=_b_ %if &nobs>0 %then %do; drop=zip2 zip4 %end;
            rename=(county=census_countystate=census_statezip5=census_zip5));  ***rename fields with the same name in both datasets;
      by &client_id;
      if _a_;
      if not _b_ then do;
         census_source_match="NONE";
         flag_census_match=0;
      end;
   run;

%end;                      *----------------------------- END OF CENSUS MATCHING LOOP;

*stack *;
proc append base=client_with_demo data=client_with_demo_&curstate force;
run;

proc datasets library=work nolist;
   delete base_demo_&curstate;
quit;


ods html body="./&client_data._MATCHING_RESULTS_&curstate..htm";

%if &abort=0 %then %do;

data print;
   format text $100.;
   text = '______________________________________________________________________________________';
   output;
   text = '   No records matched in this state                                                   ';
   output;
   text = '                                                                                      ';
   output;
   text = '   Either you data is terrible, you did not clean it, or...                           ';
   output;
   text = '   you are running a geographically restricted sample through and the state field     ';
   output;
   text = '   on a handful of your records was changed by zip state.  This causes one/two        ';
   output;
   text = '   records to run through a different state with low chance of matching, which        ';
   output;
   text = '   leads to states with no matched records.                                           ';
   output;
   text = '                                                                                      ';
   output;
   text = '   SO, clean your data better - or use the supplied state parameter in the macro call.';
   output;
   text = '______________________________________________________________________________________';
   output;
run;

proc print data=print;
run;

%end;
%if &abort>0 %then %do;
proc freq data=client_with_demo_&curstate;
   title "MATCH RATE FOR &curstate";
   tables matched matched_key cac_active_flag*cac_production 
         CAC_ADDR_CDI CAC_SILH CAC_DEMO_AGE CAC_DEMO_INCOME_NARROW CAC_DEMO_KIDS_PRESENCE CAC_DEMO_MARITAL_STATUS / list missing;
run;
%end;

ods html close;

%end;                      *---------------------------- END OF STATE_NUM LOOP; 
%end;                      *-----------------------------END OF NOBS CONDITION;

proc sort data=client_with_demo;
   by &client_id;
run;

proc sort data=clin.&client_data out=client_in;
   by &client_id;
run;

data clin.&client_data._matched;
  merge client_in (in=a)
        client_with_demo (in=b drop=match_zip5 match_zip4 match_zip2 &zip5 &zip4)
        client_not_clean (in=c drop=clean:);
   by &client_id;
   if (a AND b) OR C;
   if c then do;
      matched=0;
      matched_key=.;
      cac_hh_pid=.;
      key='';
      cac_active_flag=.;
      cac_production=.;
   end;
run;

ods html body="./&client_data._MATCHING_RESULTS.htm";

proc freq data=clin.&client_data._matched;
   title 'QUALITY OF MATCHES';
   tables matched matched_key cac_active_flag*cac_production 
           CAC_ADDR_CDI CAC_SILH CAC_DEMO_AGE CAC_DEMO_INCOME_NARROW CAC_DEMO_KIDS_PRESENCE CAC_DEMO_MARITAL_STATUS / list missing;
run;

proc contents data=clin.&client_data._matched;
   title 'CONTENTS OF MATCHED DATA';
run;

ods html close;

%mend matchmaker;
