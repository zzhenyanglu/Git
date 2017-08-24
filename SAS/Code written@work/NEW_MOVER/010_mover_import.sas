%include "./.mover_includes.inc";

***STEP 1: GET LIST OF FILES TO IMPORT***;

   x "ls /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW > ./file_listing.txt";
   x "sleep 5";

   filename nmlst temp;
   data nmlsttemp;
      infile "./file_listing.txt";
      format filename $50.;
      input filename $;
      if index(filename,"gz") gt 0 and index(filename,"txt") gt 0 /* and substr(upcase(strip(filename)),1,2)="N0" */ then output;
   run;

   %nobs(data=nmlsttemp);
   %let pknobs=&nobs;

   data _null_;
      file nmlst;
      set nmlsttemp end=eof;
      if _n_=1 then put '%let nmlst=';
      put filename;
      if eof then put ';';
   run;

   %include nmlst;

%put LIST TO IMPORT: &nmlst;

proc sql;
   select max(cac_nm_id) into :max_id
   from nmsql.COGENSIA_MOVERS;
quit;

%put MAXIMUM ID: &max_id;

***STEP 2: IMPORT FILES***;

%macro importme;

   %do pk=1 %to &pknobs;

      filename myfile PIPE "gzip -dc /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/%scan(&nmlst,&pk,' ')" lrecl=184;
      data file&pk;
         infile myfile truncover;
         input @1 cac_nm_contracted_name $40.
               @41 cac_nm_contracted_addr $40.
               @81 cac_nm_city $13.
               @94 cac_nm_fips_state_code $2.
               @96 cac_nm_zip_code $5.
               @101 cac_nm_zipplus_4 $4.
               @105 cac_nm_delivery_point_code $3.
               @108 cac_nm_state_abbreviation $2.
               @110 cac_nm_carrier_route $4.
               @114 cac_nm_distance_of_move $4.
               @118 cac_nm_dpv_flag $1.
               @119 cac_nm_hh_move_date $6.
               @125 cac_nm_file_dt yymmdd8.
               @133 cac_nm_indiv_two_year_age_band $6.
               @139 cac_nm_gender $1.
               @140 cac_nm_marital_status $1.
               @141 cac_nm_marital_status_within_hh $1.
               @142 cac_nm_number_of_adults_in_hh $2.
               @144 cac_nm_number_of_kids_in_hh $1.
               @145 cac_nm_pet_owner $1.
               @146 cac_nm_dwelling_addr_type $1.
               @147 cac_nm_cen_home_value $3.
               @150 cac_nm_cen_inc_code_new_addr $3.
               @153 cac_nm_cen_inc_code_new_addr_r $3.
               @156 cac_nm_cen_inc_code_prev_addr $3.
               @159 cac_nm_cen_inc_code_prev_addr_r $3.
               @162 cac_nm_county_code $3.
               @165 cac_nm_county_code_old_addr $3.
               @168 cac_nm_hh_age $2.
               @170 cac_nm_target_valuescore $3.
               @173 cac_nm_target_inc $1.
               @174 cac_nm_homeowner_renter_code $1.
               @175 cac_nm_area_code_with_supp_appl $3.
               @178 cac_nm_telephone_with_supp_appl $7.;
         cac_nm_import_date=today();
      run;

      proc print data=file&pk (obs=10);
         title "IMPORT: &pk";
      run;

   %end;

   data nmsas.new_mover_&tdate;
      set %do pk=1 %to &pknobs;
             file&pk
          %end;;
      cac_nm_id=&max_id+_n_;
   run;

   %qc(data=nmsas.new_mover_&tdate);

%mend importme;
%importme;
