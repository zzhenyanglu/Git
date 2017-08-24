***;
* 090_load_summary.sas;
***;

libname jhis "/project/CACDIRECT/&cidatapath./JOB_HISTORY";

%macro load_summary (year=,qtr=,cacdir_loc=A, codepath=PROD);

    %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc";

   filename baselist pipe "ls -l /project/CACDIRECT/&cidatapath./BASE_DEMO/&cacdir_loc";
   data base;
      infile baselist missover;
      input mode :$10. nlinks :$4. user :$9. group :$8. size  mon :$3. day :$2.  timestamp :$5. name :$32.;
      length datetime $20.;
      datetime=mon||" "||day||" "||timestamp;
      file "./data_storage_base_&year._&qtr..pdm" dlm="|";
      if _n_=1 then do;
        put "size|datetime|filename";
      end;
      put size datetime name;
   run;
   filename indlist pipe "ls -l /project/CACDIRECT/&cidatapath./INDIV_DEMO/&cacdir_loc";
   data indiv;
      infile indlist missover;
      input mode :$10. nlinks :$4. user :$9. group :$8. size  mon :$3. day :$2.  timestamp :$5. name :$32.;
      length datetime $20.;
      datetime=mon||" "||day||" "||timestamp;
      file "./data_storage_indiv_&year._&qtr..pdm" dlm="|";
      if _n_=1 then do;
        put "size|datetime|filename";
      end;
      put size datetime name;
   run;
   filename geolist pipe "ls -l /project/CACDIRECT/&cidatapath./GEO/&cacdir_loc";
   data geo;
      infile geolist missover;
      input mode :$10. nlinks :$4. user :$9. group :$8. size  mon :$3. day :$2.  timestamp :$5. name :$32.;
      length datetime $20.;
      datetime=mon||" "||day||" "||timestamp;
      file "./data_storage_geo_&year._&qtr..pdm" dlm="|";
      if _n_=1 then do;
        put "size|datetime|filename";
      end;
      put size datetime name;
   run;
   filename etlist pipe "ls -l /project/CACDIRECT/&cidatapath./ETECH/FORETECH";
   data etech;
      infile etlist missover;
      input mode :$10. nlinks :$4. user :$9. group :$8. size  mon :$3. day :$2.  timestamp :$5. name :$32.;
      length datetime $20.;
      datetime=mon||" "||day||" "||timestamp;
      file "./data_storage_etech_&year._&qtr..pdm" dlm="|";
      if _n_=1 then do;
        put "size|datetime|filename";
      end;
      put size datetime name;
   run;

  filename loadsum "./cacdirect_load_summary_&year._&qtr..pdm";
  
  data _null_;
   set 	jhis.cac_direct_counts_ak (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_AL (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_AR (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_AZ (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_CA (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_CO (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_CT (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_DC (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_DE (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_FL (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_GA (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_HI (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_IA (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_ID (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_IL (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_IN (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_KS (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_KY (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_LA (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_MA (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_MD (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_ME (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_MI (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_MN (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_MO (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_MS (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_MT (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_NC (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_ND (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_NE (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_NH (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_NJ (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_NM (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_NV (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_NY (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_OH (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_OK (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_OR (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_PA (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_RI (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_SC (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_SD (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_TN (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_TX (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_UT (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_VA (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_VT (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_WA (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_WI (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_WV (where=(cac_year=&year and cac_qtr=&qtr))
	jhis.cac_direct_counts_WY (where=(cac_year=&year and cac_qtr=&qtr));
	
   file loadsum dlm="|" dsd ;
   if _N_ = 1 then do;
       put "state_number|state|raw_file_record_count|base_demo_records|indiv_demo_records|geo_interest_records|insert_records|update_records|
inactive_records|deleted_records|job_start_date|job_start_time|job_end_date|job_end_time";
   end;
   put state_number state raw_file_record_count base_demo_records indiv_demo_records geo_interest_records insert_records update_records inactive_records
       deleted_records job_start_date job_start_time job_end_date job_end_time;
   run;
%mend load_summary;

