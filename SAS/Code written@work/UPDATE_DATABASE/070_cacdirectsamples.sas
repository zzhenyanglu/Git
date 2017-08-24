*========================================================================================;
* Program 070_cacdirect_samples.sas
  Purpose Creates .1%, 1%, and 5% Samples of the CAC Direct database of only production and active records    
  Authors Joel Shiltz, Mike Mattingly
  Design Loops thru states to create respective sample dataset 
         Runs a QC report on the .1% sample            
         Temporary datasets are used to accomodate WPS and PROC APPEND
         Final datasets are writted to samp library in seperate step
  Updated: 5/7/2012 MM Corrected Missing Geo Variables when appened at State Level
           5/7/2012 MM Added in Ethnic Data
           5/11/2012 MM Added Census Data
           11/29/2012 MM Amended Census Matching to new xref table
           4/30/2013 MM Amended to add allow for selection if Ethnic, Geo, and Census data are desired
*========================================================================================;
options mprint linesize=max;

%macro allstates(qtr=,year=,cacdir_loc=B, ethnic=N, geo=Y, census=Y, codepath=PROD);

   %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc"; 

    %if &cacdir_loc=A %then %do;                                               
        libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/A";
        libname geo      "/project/CACDIRECT/&cidatapath./GEO/A";
        libname samp     "/project/CACDIRECT/&cidatapath./SAMPLES/A";      
        libname et       "/project/CACDIRECT/&cidatapath./ETECH/A";
    %end;
    
    %else %if &cacdir_loc=B %then %do;                                      
          libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";
          libname geo      "/project/CACDIRECT/&cidatapath./GEO/B";
          libname samp     "/project/CACDIRECT/&cidatapath./SAMPLES/B";      
          libname et       "/project/CACDIRECT/&cidatapath./ETECH/B";
    %end;
 
%let st_num = 51;

%let state_list = AK AL AR AZ CA CO CT DC DE FL GA 
                HI IA ID IL IN KS KY LA MA MD ME
                MI MN MO MS MT NC ND NE NH NJ NM
                NV NY OH OK OR PA RI SC SD TN TX
                UT VA VT WA WI WV WY;

%if %sysfunc(exist(samp.base_samp_5pct)) = 1 %then %do;
   proc datasets library = samp;
     delete base_samp_5pct base_samp_1pct base_samp_point1pct;
   run;
%end;

%do pickst=1 %to &st_num;   **** BEGIN STATE LOOP;
    %let st=%scan(&state_list,%eval(&pickst));
    
    %let droplist= CAC_ADDR_CARRIER_RT CAC_ADDR_CBSA_CODE CAC_ADDR_CENSOR_CD CAC_ADDR_COUNTY_CODE CAC_ADDR_DLV_PT_CODE CAC_ADDR_DSF_SEASONAL CAC_ADDR_DSF_TYPE
                   CAC_ADDR_FIPS_ST CAC_ADDR_FRAC CAC_ADDR_ID CAC_ADDR_LAT_LONG_IND CAC_ADDR_LOT_CODE CAC_ADDR_NUM CAC_ADDR_PO_BOX_DESIGNATOR CAC_ADDR_PO_ROUTE_NUM
                   CAC_ADDR_QUALITY CAC_ADDR_SECOND_UNIT CAC_ADDR_STREET CAC_ADDR_STREET_PRE CAC_ADDR_STREET_SUFF CAC_ADDR_STREET_SUFF_DIR CAC_ADDR_TYPE
                   CAC_DELIVERABILITY_DATE CAC_HH_VERIFICATION_DATE CAC_NUM_SOURCES CAC_QTR ;
    
	    data base;
	       set base.base_demo_&st  (drop=&droplist where=(cac_production=1 and cac_active_flag=1));
	    run;

	    proc sort data=base;
	     by cac_silh;
	    run;

	    data base;
	       set base;
	       if mod(_n_,20)=7 then output;
	    run;
	    
   %if &ethnic=Y %then %do; ************ BEGIN ETHNIC APPEND;
   
 	    proc sort data=base;
	      by cac_hh_pid;
	    run;
	    
	    proc sort data=et.etech_&st out=etech;
	      by cac_hh_pid;
	    run;
	    
	    data base;
	      merge base (in=a)
		    etech (in=b);
	      by cac_hh_pid;
	      if a and b;
	    run;
	    
   %end;   ***************************** END ETHNIC APPEND;


   %if &geo=Y %then %do; ************** BEGIN GEO INTERESTS;
    
	    proc sort data=base;
	       by cac_addr_zip2;
	    run;
    
	    proc sort data=geo.geo_interest_&st;
	       by cac_addr_zip2;
	    run;

	    data samp_&st(drop=newzip) zip_&st (rename=(cac_addr_zip2=hold));
	       merge base (in=a)
		     geo.geo_interest_&st (in=b drop= cac_addr_state cac_addr_zip);
	       by cac_addr_zip2;
	       cac_geo_match=1;
	       if a and b and geo_cac_int_1^=. then output samp_&st;
	       else if a then do;
		  cac_geo_match=0;
		  newzip=compress(cac_addr_zip || 'XX');
		  output zip_&st;
	       end;
	    run;

	    data zip_found_&st (drop=cac_addr_zip2 newzip rename=(hold=cac_addr_zip2))  state_&st(drop=cac_addr_zip2 geo_cac:);
	       merge zip_&st (in=a rename=(newzip=cac_addr_zip2) drop=geo_cac_int:)
		     geo.geo_interest_&st (in=b drop= cac_addr_state cac_addr_zip);
	       by cac_addr_zip2;
	       cac_geo_match=2;
	       if a and b and geo_cac_int_1^=. then output zip_found_&st;
	       else if a then do;
		  cac_geo_match=0;
		  newzip='XXXXXXX';
		  output state_&st;
	       end;
	    run;

	    data state_found_&st (drop=cac_addr_zip2 rename=(hold=cac_addr_zip2));
	       merge state_&st (in=a rename=(newzip=cac_addr_zip2))
		     geo.geo_interest_&st (in=b drop= cac_addr_state cac_addr_zip);
	       by cac_addr_zip2;
	       cac_geo_match=3;
	       if a and b;
	    run;
   
	    proc append base = samp_5pct_&st data=samp_&st force;
	    proc append base = samp_5pct_&st data=zip_found_&st force;
	    proc append base = samp_5pct_&st data=state_found_&st force; run;

   %end; ****************************** END GEO INTERESTS;
   
   %if census=Y %then %do; ************ BEGIN CENSUS;
    
	    proc sort data = samp_5pct_&st;
	      by cac_addr_zip cac_addr_zip4;
	    run;

	    data  m_cen_zip9_&st 
		 nm_cen_zip9_&st;
	       merge samp_5pct_&st               (in=a)
		     cen2010.cac_census_xref_&st (in=b);
	       by cac_addr_zip cac_addr_zip4;
	       if a and b then do;
		  cac_census_match=1;
		  cac_census_match_level='ZIP9';
		  output m_cen_zip9_&st; 
	       end;
	       else if a and not b then output nm_cen_zip9_&st;
	    run;

	    proc sort data=nm_cen_zip9_&st;
	       by cac_addr_zip;
	    run;

	    data cen_xref_&st;
	      set cen2010.cac_census_xref_&st (where=(cac_addr_zip4 eq ''));
	    run;

	    proc sort data=cen_xref_&st;
	      by cac_addr_zip;
	    run;

	    data m_cen_zip5_&st 
		 nm_cen_zip_&st;
	       merge nm_cen_zip9_&st (in=a drop=cac_census_id)
		     cen_xref_&st    (in=b keep=cac_census_id cac_addr_zip);        
	       by cac_addr_zip;
	       if a and b then do;
		  cac_census_match=1;
		  cac_census_match_level='ZIP5';
		  output m_cen_zip5_&st;
	       end;

	       else if a and not b then do;
		    cac_census_match=0;
		    output nm_cen_zip_&st;
	       end;

	    run;

	    data client_with_cen_id_&st;
	      set m_cen_zip9_&st 
		  m_cen_zip5_&st;
	    run;

	    proc sort data=client_with_cen_id_&st;
	      by cac_census_id;
	    run;

	    data client_with_census_&st;
	       merge client_with_cen_id_&st       (in=a)
		     cen2010.cac_census_final_&st (in=b keep=cac_census_id cen_:);
	       by cac_census_id;
	       if a and b;
	    run;

	    data samp_5pct_&st;
	       set client_with_census_&st 
		   nm_cen_zip_&st;
	    run;       

   %end;   ****************  END CENSUS;
    
   * STACK FINAL STATE SET INTO BASE SAMPLE AND CLEANUP TEMPORARY DATASETS;
    proc append base = base_samp_5pct data = samp_5pct_&st force; run;

    proc datasets lib=work;
      delete samp_&st;
      delete zip_found_&st;
      delete state_found_&st;
      delete samp_5pct_&st;
      delete client_with_census_&st;
      delete m_cen_zip9_&st; 
      delete nm_cen_zip9_&st;
      delete m_cen_zip5_&st;
      delete nm_cen_zip_&st;
      delete samp_5pct_&st;
      delete client_with_census_&st;
      delete client_with_cen_id_&st;
    run;
    quit;

%end;   **** END STATE LOOP;

*** 5% SAMPLE COMPLETE, NOW PULL OFF 1% AND .1% SAMPLE;

    proc contents data = base_samp_5pct;
    run;
    proc means data = base_samp_5pct; 
    run;

    data samp.base_samp_1pct;
      set base_samp_5pct;
      if mod(_n_,5) = 3;
    run;

    data samp.base_samp_point1pct;
      set base_samp_5pct;
      if mod(_n_,50) = 13;
    run;

    proc datasets nolist;
     copy in=work out=samp;
     select base_samp_5pct;
    quit;
    run;

   %qc(data=samp.base_samp_point1pct);

%mend; 

