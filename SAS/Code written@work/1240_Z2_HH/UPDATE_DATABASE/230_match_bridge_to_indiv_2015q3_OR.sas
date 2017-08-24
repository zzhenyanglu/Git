%MACRO coverage(cac_read_dir_loc=, codepath=, cstate=, spedis_thresh=,genders=);

   %let testobs = max;
   %let outobs=max;

   %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc";

   %if &cac_read_dir_loc=A %then %do;                                       *** IF CURRENT PRODUCTION DATA IS IN A THEN WRITE DATA FOR NEW QUARTER TO B;
      libname _ALL_;
      libname base      "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";
      libname bridge   "/project/CACDIRECT/&cidatapath./BRIDGE/B";
   %end;

   %else %if &cac_read_dir_loc=B %then %do;                                        *** IF CURRENT PRODUCTION DATA IS IN B THEN WRITE DATA FOR NEW QUARTER TO A;
      libname _ALL_;
      libname base      "/project/CACDIRECT/&cidatapath./BASE_DEMO/A"; 
      libname bridge   "/project/CACDIRECT/&cidatapath./BRIDGE/A";
   %end;

   filename outfile "/project/CACDIRECT/&cidatapath./EXPORT/BRIDGE/bridge_pid_table_&cstate..csv";

/*
   %parsimony(inlib=work, indata=clean, outlib=work, outdata=client_outdat, keep_clean=1, keep_keys=1,
              keep_pieces=0, pname_form=1, pname1=clean_name, pname2=, paddr_form=1, paddr1=clean_addr, paddr2=, pstate=&state_var, pzip=&zip5);
*/

   *not sure if the bridge sort should nodup or not, need to talk to bryan/mike;

   proc sort data=bridge.bridge_pid_&cstate. (obs=&testobs) out=bridge_pid_&cstate.;
      by cac_hh_pid;
   run;

   %macro gender(gender=);

      data scored_&gender._&cstate (keep=cac_name_last cac_hh_pid cac_bridge_md5email_id chosen: bridge: last_name_match);
         merge bridge_pid_&cstate (in=a)
               base.base_demo_&cstate (in=b obs=&testobs keep=cac_name_last cac_ind: cac_hh_pid cac_em_flag where=(substr(cac_em_flag,1,1)='1'));
         by cac_hh_pid;
         if a and b;
         format chosen_cac_ind_gender chosen_cac_ind_number chosen_spedis_score 8. chosen_match_level chosen_first_x_of_x_flag 8. 
                chosen_cac_ind_name $14. chosen_cac_ind_mi $1. chosen_cac_ind_last $20.;
         array genders cac_ind1_gender cac_ind2_gender cac_ind3_gender cac_ind4_gender cac_ind5_gender; 
         array names cac_ind1_name cac_ind2_name cac_ind3_name cac_ind4_name cac_ind5_name; 
         array mis cac_ind1_mi cac_ind2_mi cac_ind3_mi cac_ind4_mi cac_ind5_mi; 
         if not(missing(cac_ind5_name)) then count=5;
         else if not(missing(cac_ind4_name)) then count=4;
         else if not(missing(cac_ind3_name)) then count=3;
         else if not(missing(cac_ind2_name)) then count=2;
         else if not(missing(cac_ind1_name)) then count=1;
         else delete;
         
         *No indiv_demo names have spaces in them, despite some of them being made of multiple words (maryjo);
         *I recommend trying to match a single word of the bridge name to the indiv name first followed by the full name with spaces removed;
         *This is not implemented yet;

         *Since we do not have mkey on the bridge_pid_xx datasets, we need to figure out if the last name even matched on the first individual at all.;
         *Last name is the same for all individuals, so we will approximate mkey1-4 matching by using exact/fuzzy last name matching;

         *No individuals in IL were under 18, so we are safe contacting any individual;

         *individual number gets priority;
         *taking the first person for a given gender, even if the gender is inferred from the first individual;

         *Matching order;
         *0. determine if last name matches exact or at least fuzzy (equivalent to mkey1-4 assuming address must have matched);
         *0.5 process separately by gender to determine male match and female match for each bridge ID (deduped at individual level so no one is both genders);
         *1. first_name exact match;
         *2. spedis partial match score sufficient;
         *3. first_name first character match and first_x_of_x_flag (1/1, 2/2, 2/3, 3/4) with spedis tiebreaker;

         *0. determine if last name matches exact or at least fuzzy (equivalent to mkey1-4 assuming address must have matched);

         bridge_name_last=upcase(strip(bridge_name_last));
         bridge_name_first=upcase(strip(bridge_name_first));
         cac_indiv_last_exact=compress(cac_name_last,'!');
         cac_indiv_last_fuzzy1=soundex(compress(cac_name_last,'!'));
         bridge_name_last_exact=compress(bridge_name_last,'!');
         bridge_name_last_fuzzy1=soundex(compress(bridge_name_last,'!'));
         if bridge_name_last_exact = cac_indiv_last_exact or cac_indiv_last_fuzzy1 = bridge_name_last_fuzzy1 
         then do i = 1 to count;
            last_name_match=1;
            if missing(genders(i)) then genders(i) = cac_ind1_gender;
            %if &gender = M %then %do; *process next person if gender mismatch;
               if genders(i) ne 1 then continue;
            %end;
            %else %if &gender = F %then %do; *process next person if gender mismatch;
               if genders(i) = 1 or missing(genders(i)) then continue;
            %end;
            min_length = min(length(names(i)),length(bridge_name_first));
            if min_length = 1 then first_x_of_x_flag = (substr(names(i),1,1) = substr(bridge_name_first,1,1));
            else if min_length = 2 then first_x_of_x_flag =  (substr(names(i),1,2) = substr(bridge_name_first,1,2));
            else if min_length = 3 then first_x_of_x_flag = ((substr(names(i),1,1) = substr(bridge_name_first,1,1)) + (substr(names(i),2,1) = substr(bridge_name_first,2,1)) + (substr(names(i),3,1) = substr(bridge_name_first,3,1)) ) > 1;
            else first_x_of_x_flag = (   (substr(names(i),1,1) = substr(bridge_name_first,1,1)) + (substr(names(i),2,1) = substr(bridge_name_first,2,1))
                                       + (substr(names(i),3,1) = substr(bridge_name_first,3,1)) + (substr(names(i),4,1) = substr(bridge_name_first,4,1)) ) > 2;

            *1. first_name exact match;
            if names(i) = bridge_name_first and (missing(chosen_match_level) or chosen_match_level > 1) then do;
               temp_match_level = 1;            
               chosen_cac_ind_number = i;
               spedis_score=spedis(names(i),bridge_name_first);
            end;

   /*
   *originalish approach;
            *2. first_name first character match;
            else if substr(names(i),1,1) = substr(bridge_name_first,1,1)  and (missing(chosen_match_level) or chosen_match_level > 2) then do; 
               temp_match_level = 2; 
               chosen_cac_ind_number = i;
               spedis_score=spedis(names(i),bridge_name_first);
            end;
            *3. spedis partial match score sufficient;
            else if (missing(chosen_match_level) or chosen_match_level > 2) then do;
               spedis_score=spedis(names(i),bridge_name_first);
               if      spedis_score < &spedis_thresh  
                  and (spedis_score < chosen_spedis_score or missing(chosen_spedis_score)) 
               then do;
                  temp_match_level = 3;              
                  chosen_cac_ind_number = i;
               end;
            end; */
   *alternative approach;
            *2. spedis partial match score sufficient;
            else if (missing(chosen_match_level) or chosen_match_level > 1) then do;
               spedis_score=spedis(names(i),bridge_name_first);
               if      spedis_score < &spedis_thresh  
                  and (spedis_score < chosen_spedis_score or missing(chosen_spedis_score)) 
               then do;
                  temp_match_level = 2;              
                  chosen_cac_ind_number = i;
               end;
               *3. first_name first character match and first_x_of_x_flag (1/1, 2/2, 2/3, 3/4) with spedis tiebreaker;
               else if      substr(names(i),1,1) = substr(bridge_name_first,1,1)
                       /*and (spedis_score < chosen_spedis_score or missing(chosen_spedis_score))
                       and (missing(chosen_match_level) or chosen_match_level > 2) */
                       and missing(chosen_match_level) 
                       and first_x_of_x_flag
               then do;                     
                  temp_match_level = 3;              
                  chosen_cac_ind_number = i;
               end;             
            end; 
            if not(missing(temp_match_level)) then do;
               chosen_match_level = temp_match_level;
               call missing(temp_match_level);
               chosen_spedis_score = spedis_score;
               chosen_cac_ind_gender = genders(chosen_cac_ind_number);
               chosen_cac_ind_name = names(chosen_cac_ind_number);
               chosen_cac_ind_mi = mis(chosen_cac_ind_number);
               chosen_cac_ind_last = cac_name_last;
               chosen_first_x_of_x_flag=first_x_of_x_flag;
            end;
         end;
         else last_name_match=0;
      run;

      proc freq data = scored_&gender._&cstate;
         table last_name_match*chosen_cac_ind_number / missing;
         table chosen_cac_ind_number*chosen_match_level / missing;
      run;

      title "match_level 2";
      proc freq data = scored_&gender._&cstate (where=(chosen_match_level=2));
         table chosen_spedis_score / missing;
      run;

      title "match_level 3";
      proc freq data = scored_&gender._&cstate (where=(chosen_match_level=3));
         table chosen_spedis_score / missing;
      run;
      title "";
   /*
      title 'last_name_match=1 and chosen_match_level=3 and chosen_spedis_score <= 60';
      proc print data = scored_&gender._&cstate (obs=100 keep = chosen_cac_ind_name bridge_name_first chosen_match_level chosen_spedis_score last_name_match chosen_first_x_of_x_flag
                                                where=(last_name_match=1 and chosen_match_level=3 and chosen_spedis_score <= 60)); run;

      title 'last_name_match=1 and chosen_match_level=2 and chosen_spedis_score <= 60 and chosen_spedis_score >=40 and chosen_first_x_of_x_flag = 0';
      proc print data = scored_&gender._&cstate (obs=100 keep = chosen_cac_ind_name bridge_name_first chosen_match_level chosen_spedis_score last_name_match chosen_first_x_of_x_flag
                                                where=(last_name_match=1 and chosen_match_level=2 and chosen_spedis_score <= 60 and chosen_spedis_score >=40 and chosen_first_x_of_x_flag = 0)); run;

      title 'last_name_match=1 and chosen_match_level=2 and chosen_spedis_score <= 50';
      proc print data = scored_&gender._&cstate (obs=100 keep = chosen_cac_ind_name bridge_name_first chosen_match_level chosen_spedis_score last_name_match chosen_first_x_of_x_flag
                                                where=(last_name_match=1 and chosen_match_level=2 and chosen_spedis_score <= 50)); run;

      title 'last_name_match=1 and chosen_match_level=2 and chosen_spedis_score <= 40 and chosen_first_x_of_x_flag=0';
      proc print data = scored_&gender._&cstate (obs=100 keep = chosen_cac_ind_name bridge_name_first chosen_match_level chosen_spedis_score last_name_match chosen_first_x_of_x_flag
                                                where=(last_name_match=1 and chosen_match_level=2 and chosen_spedis_score <= 40 and chosen_first_x_of_x_flag=0)); run;

      title 'last_name_match=1 and chosen_match_level=2 and chosen_spedis_score >= 50';
      proc print data = scored_&gender._&cstate (obs=100 keep = chosen_cac_ind_name bridge_name_first chosen_match_level chosen_spedis_score last_name_match chosen_first_x_of_x_flag
                                                where=(last_name_match=1 and chosen_match_level=2 and chosen_spedis_score >= 50)); run;   

      title 'last_name_match=0';
      proc print data = scored_&gender._&cstate (obs=100 keep = cac_name_last bridge_name_last last_name_match where=(last_name_match=0)); run;
   */

   %mend gender;

   %if &genders=Y %then %do;

      %gender(gender=M);
      %gender(gender=F);

      data scored__&cstate.;
         set scored_M_&cstate (where=(not(missing(chosen_cac_ind_number)))) 
             scored_F_&cstate (where=(not(missing(chosen_cac_ind_number))));
      run;

/*    *Bryan will do this part in postgres;

      proc sort data = scored__&cstate.;
         by cac_bridge_md5email_id chosen_cac_ind_number;
      run;

      data scored__&cstate.;
         set scored__&cstate.;
         by cac_bridge_md5email_id;
         if first.cac_bridge_md5email_id;
      run;

*/
   %end;
   %else %do;

      %gender(gender=);

      data scored__&cstate;
         set scored__&cstate (where=(not(missing(chosen_cac_ind_number))));
      run;
   
   %end;

   %qc(data=scored__&cstate);

   data _null_;
      file outfile dlm=',' dsd lrecl=1000;
      set scored__&cstate (obs=&outobs where=(not(missing(chosen_cac_ind_number))));
      if _n_=1 then put 'cac_hh_pid,cac_bridge_md5email_id,chosen_cac_ind_number,chosen_cac_ind_gender,chosen_cac_ind_name,chosen_cac_ind_mi,chosen_cac_ind_last,' @;
      if _n_=1 then put 'chosen_spedis_score,chosen_match_level,chosen_first_x_of_x_flag';
      put cac_hh_pid cac_bridge_md5email_id chosen_cac_ind_number chosen_cac_ind_gender chosen_cac_ind_name chosen_cac_ind_mi chosen_cac_ind_last 
          chosen_spedis_score chosen_match_level chosen_first_x_of_x_flag
          ;
   run;

%mend coverage;
%coverage(cac_read_dir_loc=B, cstate=OR, codepath=DEVELOPMENT/1240_Z2_HH,spedis_thresh=35,genders=Y);
