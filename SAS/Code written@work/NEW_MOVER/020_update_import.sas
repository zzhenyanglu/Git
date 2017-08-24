%include "./.mover_includes.inc";

***STEP 1: GET LIST OF FILES TO IMPORT***;

   x "ls /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/VALUESCORE_UPDATE/ > ./file_listing_update.txt";
   x "sleep 5";

   filename nmlst temp;
   data nmlsttemp;
      infile "./file_listing_update.txt";
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

***STEP 2: IMPORT FILES***;

%macro importme;

   %do pk=1 %to &pknobs;

      filename myfile PIPE "gzip -dc /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/VALUESCORE_UPDATE/%scan(&nmlst,&pk,' ')" lrecl=184;
      data file&pk. (drop=_:);
         infile myfile truncover;
         input @1 cac_nm_contracted_name $40.
               @41 cac_nm_contracted_addr $40.
               @81 _cac_nm_city $13.
               @94 cac_nm_fips_state_code $2.
               @96 cac_nm_zip_code $5.
               @101 _cac_nm_zipplus_4 $4.
               @105 _cac_nm_delivery_point_code $3.
               @108 _cac_nm_state_abbreviation $2.
               @110 _cac_nm_carrier_route $4.
               @114 cac_nm_file_dt yymmdd8.
               @122 _cac_nm_hh_move_date $6.
               @128 new_cac_nm_target_valuescore $3.
               @131 _cac_nm_target_inc $1.
               @132 _cac_nm_homeowner_renter_code $1.
               @133 _cac_nm_dwelling_addr_type $1.
               @134 _cac_nm_area_code_with_supp_appl $3.
               @137 _cac_nm_telephone_with_supp_appl $7.;
         _cac_name_1 = scan(cac_nm_contracted_name,1,' ');
         _cac_name_2 = scan(cac_nm_contracted_name,-1,' ');
         if _cac_name_2="SR" or _cac_name_2= "JR" then _cac_name_2 = scan(cac_nm_contracted_name,-2,' ');
         format cac_nm_contracted_name_2 $40.;
         cac_nm_contracted_name_2 = catx(" ",_cac_name_1,_cac_name_2);
      run;

      proc print data=file&pk (obs=10);
         title "IMPORT: &pk";
      run;

   %end;

   data nmsas.update_valuescore_&tdate;
      set %do pk=1 %to &pknobs;
             file&pk
          %end;;
   run;

   proc freq data=nmsas.update_valuescore_&tdate;
      format cac_nm_file_dt date9.;
      table cac_nm_file_dt;
   run;

   data nmsas.update_valuescore_&tdate;
      set nmsas.update_valuescore_&tdate (drop=cac_nm_file_dt);
   run;

   %qc(data=nmsas.update_valuescore_&tdate);

   proc contents data=nmsas.update_valuescore_&tdate;run;

%mend importme;
%importme;

endsas;
