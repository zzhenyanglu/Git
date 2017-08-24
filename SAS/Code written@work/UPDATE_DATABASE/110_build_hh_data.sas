*********************************************************************************;
***Program: 110_build_detail_data.sas                                         ***;
***Purpose: create scoring datasets for AHI data                              ***;
***         to score records that match detailed data                         ***;
***         files created at scf level for faster processing                  ***;
***Author:  jschiltz mmattingly                                               ***;
***Libraries: cacd = cacdirect data                                           ***;
***KeyDates:created-7/20/2006                                                 ***;
***         updated-8/07/2006 - cut to SCF level                              ***;
***                           - model algorithm updated - NICHES              ***;
***         updated-3/07/2006 - added step 1A                                 ***;
***                           - changed libnames to reference new cacdirect   ***;
***                           - added sql join to merge master demos & hhprim ***;
***                           - changed _int variables to new variable names  ***;
***         updated 10/25/2012- converted to CACdirect 3.0                    ***;
***         updated 4/9/2013  - removed sections allowing code to loop        ***;
***                                through scfs.                              ***;
***                           - updated by BJW to output state spec. .csv's   ***;
***Steps:   1. State level processing                                         ***;
***         1A. Create zip2 general file if AK runs - only want to create once***;
***             NOT DONE                                                      ***;
***         2. Delete existing scf level files                                ***;
***         3. Define data needed for remainder of processing                 ***;
***                                                                           ***;
***         4. Process base demo geo int census  - output scf files           ***;
***         5. Score Model                                                    ***;
***         6. Join select and master files - score model - output scf level  ***;
***         7. Loop though 51 states                                          ***;
***IMPORTANT: will DELETE all scf     level files in the existing directory   ***;
***              and recreate - are you SURE you want to do this              ***;
***MacroVars: quart - YYYY_Q# of scoring - set at the beginning of a quarter  ***;
***           del   - option to delete existing scored datasets               ***;
***                 - IMPORTANT - if running multiple processes to build all  ***;
***                               files - this flag should be Y for the very  ***;
***                               first job and N for ALL OTHER JOBS          ***;
*********************************************************************************;
options mprint nomlogic noquotelenmax linesize=max;
options compress=yes;

%let test_obs=max;

%macro quarterly (cacdir_loc=A, thisstate= YYYY, codepath=PROD);

    %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc"; 

    %if &cacdir_loc=A %then %do;
        libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/A";
        libname geo      "/project/CACDIRECT/&cidatapath./GEO/A";  
    %end;
    
    %else %if &cacdir_loc=B %then %do;                                       
              libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";            
              libname geo      "/project/CACDIRECT/&cidatapath./GEO/B";
    %end;

	%put ***~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~***;
	%put ***~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~***;
	%put ***~~~~~~~~~~          START PROCESSING STATE = &thisstate           ~~~~~~~~~~~***;
	%put ***~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~***;
	%put ***~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~***;

	title " ***~~~~~~~~~~                PROCESSING STATE = &thisstate        ~~~~~~~~~~~***";     

	%let base_demo_list=
				cac_addr_full
				cac_addr_lot_code
				cac_addr_num
				cac_addr_second_unit
				cac_addr_state
				cac_addr_street
				cac_addr_zip
				cac_addr_zip2
				cac_addr_zip4
                                cac_addr_fips_st
                                cac_addr_county_code
                                cac_census_2010_block
                                cac_census_2010_county_code
                                cac_census_2010_state_code
                                cac_census_2010_tract_block_grp
                                cac_census_2010_block
				cac_hh_pid
				cac_name_first
				cac_name_last
				cac_demo_adult_25_34_enh
				cac_demo_adult_55_64_enh
				cac_demo_adult_75_plus_enh
				cac_demo_age_enh
				cac_demo_education_enh
				cac_demo_hh_size_enh
				cac_demo_hh_type_enh
				cac_demo_income_enh
				cac_demo_income_narrow_enh
				cac_demo_kids_enh
				cac_demo_marital_status
				cac_demo_num_kids_enh
				cac_demo_occupation
				cac_home_dwell_type
				cac_home_own
				cac_home_res_length
				cac_ind1_gender
				cac_int_mail_donor
				cac_silh
				cac_silh cac_silh_loyal
				cac_silh_lifestage_group
				cac_silh_lifestyle
				cac_silh_price
				cac_silh_social
				cac_silh_super
				
				cac_active_flag
				cac_prod_active_flag
				cac_production
				cac_qtr
				cac_year
                                CAC_IND2_AGE_ENH
                                CAC_DEMO_HH_TYPE_ENH
                                CAC_DEMO_ADULT_55_64_ENH
                                CAC_DEMO_HH_TYPE_ENH
                                CAC_INT_31
                                CAC_INT_7
                                CAC_INT_27; 



	 %let geo_interest_list=GEO_CAC_INT_27 GEO_CAC_INT_78 GEO_CAC_INT_118;

	 %let census_list=CEN_HHSIZE_4 cac_addr_zip cac_addr_zip4;

	*****4.  LIMIT BASE DEMO FILE - ADD GEO INTEREST AND CENSUS DATA - CREATE MKEYS FOR CLIENT MATCHING - SPLIT STATE INTO SCF FILES*****;
	    data base;
	       set base.base_demo_&thisstate  (keep=&base_demo_list obs=&test_obs);
	    run;

	    proc sort data=base; 
	      by cac_addr_zip2; 
	    run;

	    proc sort data=geo.geo_interest_&thisstate out=geo_interest_&thisstate (keep=&geo_interest_list geo_cac_int_1 cac_addr_zip2 cac_addr_zip cac_addr_state);
	       by cac_addr_zip2;
	    run;

	    data base_&thisstate(drop=newzip) zip_&thisstate (rename=(cac_addr_zip2=hold));
	       merge base (in=a)
		     geo_interest_&thisstate (in=b drop=cac_addr_state cac_addr_zip);
	       by cac_addr_zip2;
	       cac_geo_match=1;
	       if a and b and geo_cac_int_1^=. then output base_&thisstate;
	       else if a then do;
		  cac_geo_match=0;
		  format newzip $7.;
		  newzip=compress(cac_addr_zip || 'XX');
		  output zip_&thisstate;
	       end;
	    run;

            proc sort data=zip_&thisstate;
              by newzip;
            run;
            
	    data zip_found_&thisstate (drop=cac_addr_zip2 newzip rename=(hold=cac_addr_zip2))  state_&thisstate(drop=cac_addr_zip2 &geo_interest_list);
	       merge zip_&thisstate (in=a rename=(newzip=cac_addr_zip2) drop=&geo_interest_list geo_cac_int_1)
		     geo_interest_&thisstate (in=b drop= cac_addr_state cac_addr_zip);
	       by cac_addr_zip2;
	       cac_geo_match=2;
	       if a and b and geo_cac_int_1^=. then output zip_found_&thisstate;
	       else if a then do;
		  cac_geo_match=0;
		  newzip='XXXXXXX';
		  output state_&thisstate;
	       end;
	    run;	    

	    data state_found_&thisstate (drop=cac_addr_zip2 rename=(hold=cac_addr_zip2));
	       merge state_&thisstate (in=a rename=(newzip=cac_addr_zip2) drop=geo_cac_int_1)
		     geo_interest_&thisstate (in=b drop= cac_addr_state cac_addr_zip);
	       by cac_addr_zip2;
	       cac_geo_match=3;
	       if a and b;
	    run;

	    proc append base = done_&thisstate data=base_&thisstate force;
	    proc append base = done_&thisstate data=zip_found_&thisstate force;
	    proc append base = done_&thisstate data=state_found_&thisstate force;
	    run;

	    proc sort data = done_&thisstate;
	      by cac_addr_zip cac_addr_zip4;
	    run;
	    
	    data m_cen_zip9_&thisstate nm_cen_zip9_&thisstate;
	                merge done_&thisstate (in=a)
	                      cen2010.cac_census_xref_&thisstate (in=b);
	                by cac_addr_zip cac_addr_zip4;
	                if a and b then do;
	                   cac_census_match=1;
	                   cac_census_match_level='ZIP9';
	                   output m_cen_zip9_&thisstate; 
	                end;
	    
	                else if a and not b then output nm_cen_zip9_&thisstate;
	    
            run;

            proc sort data=nm_cen_zip9_&thisstate; 
              by cac_addr_zip;
            run;

            data cen_xref_&thisstate;
              set cen2010.cac_census_xref_&thisstate (where=(cac_addr_zip4 eq ''));
            run;

            proc sort data=cen_xref_&thisstate;
              by cac_addr_zip;
            run;

            data m_cen_zip5_&thisstate nm_cen_zip_&thisstate;
              merge nm_cen_zip9_&thisstate (in=a drop=cac_census_id)
                    cen_xref_&thisstate (in=b keep=cac_census_id cac_addr_zip);        
              by cac_addr_zip;
            
               if a and b then do;
                  cac_census_match=1;
                  cac_census_match_level='ZIP5';
                  output m_cen_zip5_&thisstate;
               end;
     
               else if a and not b then do;
                    cac_census_match=0;
                    output nm_cen_zip_&thisstate;
               end;

            run;

            data client_with_cen_id_&thisstate;
              set m_cen_zip9_&thisstate m_cen_zip5_&thisstate;
            run;
  
            proc sort data=client_with_cen_id_&thisstate;
             by cac_census_id;
            run;

            data done_&thisstate;
              merge client_with_cen_id_&thisstate (in=a)
                    cen2010.cac_census_final_&thisstate (in=b keep=cac_census_id cen_:);
              by cac_census_id;
              if a and b;
            run;

            data done_&thisstate;
              set done_&thisstate
                  nm_cen_zip_&thisstate;
            run;

	    proc datasets lib=work;
	      delete base;
	      delete geo_interest_&thisstate; 
	      delete cac_census_final_&thisstate;
	      delete samp_&thisstate;
	      delete zip_found_&thisstate;
	      delete state_found_&thisstate;
	      delete samp_5_pct_&thisstate;
	      delete cac_census_final_&thisstate
	      delete cen_xref_&thisstate;
	      delete m_cen_zip9_&thisstate;
	      delete nm_cen_zip9_&thisstate;
	      delete m_cen_zip5_&thisstate;
	      delete nm_cen_zip_&thisstate;
	      delete client_with_cen_id_&thisstate;
              delete client_with_census_&thisstate;
	    run;
	    quit;

	    %parsimony
		 (inlib=work,
		 indata=done_&thisstate,
		 outlib=work,
		 outdata=done_&thisstate,
		 keep_clean=0,
		 keep_keys=1,
		 keep_pieces=0,
		 pname_form=2,
		 pname1=cac_name_first,
		 pname2=cac_name_last,
		 paddr_form=1,
		 paddr1=cac_addr_full,
		 paddr2=,
		 pstate=cac_addr_state,
		 pzip=cac_addr_zip);

	    proc contents data=done_&thisstate;
	    run;

	    proc print data=done_&thisstate (obs=10);
	    run;


	   options errors=0;
	   *****5.  SCORE MODEL -  OUTPUT ZIP LEVEL FILES*****;
	   data mt&thisstate (keep=cac_census_match cac_census_match_level cac_geo_match) 
		&thisstate._ds (keep=cac_hh_pid cac_addr_state cac_prod_active_flag cac_production cac_qtr cac_year mk_scf cac_active_flag mkey1 mkey2 mkey3 mkey4 mkey5 mkey6 mkey7 st_scf 
		              cac_demo_age_enh cac_demo_education_enh cac_demo_hh_size_enh cac_demo_income_narrow_enh cac_demo_kids_enh cac_demo_marital_status cac_demo_occupation cac_home_own cac_home_res_length 
		              cac_silh cac_silh_social cac_name_last cac_addr_street cac_addr_full cac_addr_zip cac_addr_num cac_addr_lot_code cac_addr_second_unit model_score cac_full_fips_id
                              CAC_HOME_RES_LENGTH cac_int_31 CAC_DEMO_OCCUPATION CAC_IND2_AGE_ENH cac_int_7 CAC_DEMO_HH_TYPE_ENH CAC_DEMO_NET_WORTH_ENH cac_int_27 CAC_DEMO_ADULT_55_64_ENH CAC_DEMO_HH_TYPE_ENH CAC_INT_MAIL_DONOR);

		set done_&thisstate;
		
	        mk_scf=substr(cac_addr_zip,1,3);
                st_scf = compress(cac_addr_state||'_'||mk_scf);

                length cac_full_fips_id $15.;
                cac_full_fips_id=CAC_CENSUS_2010_STATE_CODE||CAC_CENSUS_2010_COUNTY_CODE||CAC_CENSUS_2010_TRACT_BLOCK_GRP||CAC_CENSUS_2010_BLOCK;

		/***SCORE MODEL: RECODES***/

                M_LOR_0_6MOS=((CAC_HOME_RES_LENGTH=1));
  		M_OCC_DOCTOR=((CAC_DEMO_OCCUPATION=1));
         	M_P2_AGE_45_54_ENH=(45 le CAC_IND2_AGE_ENH le 54);
                M_FAM_COMP_04_ENH=((CAC_DEMO_HH_TYPE_ENH=4));
  		M_ADLT_55_64_1PLUS_ENH=((CAC_DEMO_ADULT_55_64_ENH) not in (.,0));
                M_FAM_COMP_14_ENH=((CAC_DEMO_HH_TYPE_ENH=14));
             
                
		/***SCORE MODEL:OUTLIERS, NO OUTLIERS CODE WAS GENERATED GD***/

		/***SCORE MODEL: MISSFILLS ***/
		if missing(CAC_DEMO_NET_WORTH_ENH) then CAC_DEMO_NET_WORTH_ENH =8;
                if missing(M_LOR_0_6MOS) then M_LOR_0_6MOS=0;
    		if missing(M_OCC_DOCTOR) then M_OCC_DOCTOR=0;
   		if missing(M_P2_AGE_45_54_ENH) then M_P2_AGE_45_54_ENH=0;
   		if missing(M_FAM_COMP_04_ENH) then M_FAM_COMP_04_ENH=0;
   		if missing(M_ADLT_55_64_1PLUS_ENH) then M_ADLT_55_64_1PLUS_ENH=0;
   		if missing(M_FAM_COMP_14_ENH) then M_FAM_COMP_14_ENH=0;

		/***SCORE MODEL: TRANSFORMATIONS, NO TRANSFORMED VARIABLES USED IN THIS MODEL GD***/ 


		/***SCORE MODEL: EQUATION***/

		model_score= 1 / (1 + (exp(-1 * (-8.054097611
		+ (M_LOR_0_6MOS * (-0.613616035 ))
		+ (CAC_INT_31 * (0.4728162013 ))
		+ (M_OCC_DOCTOR * (0.7738191162 ))
		+ (M_P2_AGE_45_54_ENH * (-0.78959764 ))
		+ (CAC_INT_7 * (-0.513836777 ))
		+ (M_FAM_COMP_04_ENH * (0.3732058957 ))
		+ (CAC_DEMO_NET_WORTH_ENH * (0.2831168041 ))
		+ (CAC_INT_27 * (0.1545962853 ))
		+ (M_ADLT_55_64_1PLUS_ENH * (-0.806478831 ))
		+ (M_FAM_COMP_14_ENH * (0.5374092284 ))
		))));

		   /***END SCORE MODEL ****/

		   /***OUTPUT SCF LEVEL FILE***/

		   output &thisstate._ds;

		   /***OUTPUT MATCHED STATS FOR REVIEW***/
		   output mt&thisstate;
	   run;

	   options errors=1;

	   proc append base=match_test data=mt&thisstate force;
	   run;

	title2 "***BASE DEMO, GEO INT, CENSUS MATCH RATE - STATE=&thisstate***";
	proc freq data=match_test;
	   table cac_census_match cac_census_match_level cac_geo_match / list missing;
	run;
	title2;
	title;

	
	%put ***~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~***;
	%put ***~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~***;
	%put ***~~~~~~~~~~            END PROCESSING STATE = &thisstate                  ~~~~~~~~~~~***;
	%put ***~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~***;
	%put ***~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~***;
	
        proc contents data=&thisstate._ds;
        run;

        proc means data= &thisstate._ds n nmiss min max mean std;
           var model_score;
        run;

        *****6.  OUTPUT STATE SPECIFIC CSV FILES  *****;
           data _null_;
              set &thisstate._ds;
              file "/project17/CLIENT/AHI/SCORING/DATA/CACDIRECT/rt_base_demo_with_mkey_&thisstate..csv" dlm=',' dsd dropover lrecl=32767;
              if _N_=1 then do;
                 put "CAC_HH_PID,CAC_ADDR_STATE,CAC_PROD_ACTIVE_FLAG,CAC_PRODUCTION,CAC_QTR,CAC_YEAR,MK_SCF,CAC_ACTIVE_FLAG,MKEY1,MKEY2,MKEY3,MKEY4,MKEY5,MKEY6,MKEY7,ST_SCF," @;
                 put "CAC_DEMO_AGE,CAC_DEMO_EDUCATION,CAC_DEMO_HH_SIZE,CAC_DEMO_INCOME_NARROW,CAC_DEMO_KIDS_PRESENCE,CAC_DEMO_MARITAL_STATUS,CAC_DEMO_OCCUPATION," @;
                 put "CAC_HOME_OWN,CAC_HOME_RES_LENGTH,CAC_SILH,CAC_SILH1,CAC_SILH_SOCIAL,CAC_NAME_LAST,CAC_ADDR_STREET,CAC_ADDR_FULL,CAC_ADDR_ZIP,CAC_ADDR_NUM,CAC_ADDR_LOT_CODE,CAC_ADDR_SECOND_UNIT,MODEL_SCORE," @;
                 put "CAC_FULL_FIPS_ID";
             end;

              file "/project17/CLIENT/AHI/SCORING/DATA/CACDIRECT/rt_base_demo_with_mkey_&thisstate..csv" dlm=',' dsd dropover lrecl=32767;
              cac_silh1=1;
              put CAC_HH_PID CAC_ADDR_STATE CAC_PROD_ACTIVE_FLAG CAC_PRODUCTION CAC_QTR CAC_YEAR MK_SCF CAC_ACTIVE_FLAG MKEY1 MKEY2 MKEY3 MKEY4 MKEY5 MKEY6 MKEY7 ST_SCF 
                  CAC_DEMO_AGE_ENH CAC_DEMO_EDUCATION_ENH CAC_DEMO_HH_SIZE_ENH CAC_DEMO_INCOME_NARROW_ENH CAC_DEMO_KIDS_ENH CAC_DEMO_MARITAL_STATUS CAC_DEMO_OCCUPATION CAC_HOME_OWN CAC_HOME_RES_LENGTH 
                  CAC_SILH CAC_SILH1 CAC_SILH_SOCIAL CAC_NAME_LAST CAC_ADDR_STREET CAC_ADDR_FULL CAC_ADDR_ZIP CAC_ADDR_NUM CAC_ADDR_LOT_CODE CAC_ADDR_SECOND_UNIT MODEL_SCORE 
                  CAC_FULL_FIPS_ID;
	   run;

           *x "unix2dos /project/AHI/SCORING/DATA/CACDIRECT/rt_base_demo_with_mkey_&thisstate..csv"; 
	
           proc datasets library=work kill nolist;
	   quit;

%mend quarterly;

