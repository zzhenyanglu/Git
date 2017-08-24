
/***
AUTHOR:BRYAN ENDRES
MODIFIED: RSS
DESCRIPTION: EXPORTS HOUSEHOLD LEVEL DATA FOR IMPORT INTO INTELLISECT'S POSTGRES DATABASE
***/

/*TESTING MACRO VARIABLES*/

%let testobs = max;

/*OPTION FOR DEALING WITH MISSING NUMERIC VALUES*/
options missing='' mprint mlogic;

/*LIST OF VARIABLES TO KEEP FROM BASE_DEMO*/
%let keep_demo_prod = cac_hh_pid cac_prod_active_flag cac_qtr cac_year;
%let keep_demo_addr = cac_addr_carrier_rt cac_addr_cbsa_code cac_addr_cdi cac_addr_city cac_addr_county_code cac_addr_fips_st cac_addr_full
                 cac_addr_lat_long_ind cac_addr_latitude cac_addr_longitude cac_addr_state cac_addr_street cac_addr_zip cac_addr_zip2
                 cac_addr_zip4 cac_census_2010_block cac_census_2010_county_code cac_census_2010_match_type cac_census_2010_state_code
                 cac_census_2010_tract_block_grp;
%let keep_demo_cred_1 = cac_cred_auto_loan cac_cred_bank cac_cred_debit cac_cred_education_loan cac_cred_fin_ser_insure cac_cred_finance
                      cac_cred_financial_banking cac_cred_financial_installment cac_cred_home_mortgage cac_cred_leasing;
%let keep_demo_cred_2 = cac_cred_flag;
%let keep_demo_cred_3 = cac_cred_amex cac_cred_any cac_cred_mastercard cac_cred_visa;
%let keep_demo_cred_4 = cac_cred_catalog cac_cred_comp_electronic cac_cred_furniture cac_cred_grocery cac_cred_high_spec_retail 
                        cac_cred_high_std_retail cac_cred_home_improve cac_cred_home_office cac_cred_low_dept cac_cred_main_st_retail 
                        cac_cred_misc cac_cred_oil cac_cred_spec_apparel cac_cred_sport cac_cred_std_retail cac_cred_std_specialty 
                        cac_cred_travel cac_cred_tv_mail_ord cac_cred_warehouse;
%let keep_demo_demo = cac_demo_age_enh cac_demo_education_enh cac_demo_income_enh cac_demo_net_worth_enh cac_demo_occupation
                      cac_demo_hh_size_enh cac_demo_hh_type_enh cac_demo_num_generations_enh cac_demo_num_kids_enh
                      cac_demo_marital_status cac_demo_num_adults cac_demo_adult_18_24_enh cac_demo_adult_25_34_enh
                      cac_demo_adult_35_44_enh cac_demo_adult_45_54_enh cac_demo_adult_55_64_enh cac_demo_adult_65_74_enh
                      cac_demo_adult_75_plus_enh cac_demo_adult_unknown_enh cac_demo_kids_00_02_enh cac_demo_kids_03_05_enh
                      cac_demo_kids_06_10_enh cac_demo_kids_11_15_enh cac_demo_kids_16_17_enh cac_demo_kids_enh;
%let keep_gender = cac_ind1_gender cac_ind2_gender cac_ind3_gender cac_ind4_gender cac_ind5_gender;
%let keep_demo_em = cac_bridge_em_flag;
%let keep_demo_home = cac_home_built_year cac_home_dwell_type cac_home_own cac_home_res_length cac_home_sq_foot;
%let keep_demo_int_1 = cac_int_1: cac_int_2: cac_int_3: cac_int_4: cac_int_5: cac_int_6: cac_int_7: cac_int_8: cac_int_9: cac_int_mail_buy;
%let keep_demo_int_2 = cac_int_flag cac_int_num cac_int_pol_donor cac_int_pol_party;
%let keep_demo_name = cac_name_first cac_name_last cac_name_suffix cac_name_title;
%let keep_demo_silh = cac_silh cac_silh_buy_style_group cac_silh_dig_inf cac_silh_ecom cac_silh_geo cac_silh_lifestage
                      cac_silh_lifestage_group cac_silh_lifestyle cac_silh_loyal cac_silh_lstyle_macro cac_silh_price cac_silh_soc_inf
                      cac_silh_social cac_silh_socio_econ cac_silh_socio_group cac_silh_tech;
%let keep_vert_decile = cac_vert_decile_steak cac_vert_decile_fast_casual cac_vert_decile_cdr_bar cac_vert_decile_dessert cac_vert_decile_coffee
                        cac_vert_decile_pizza cac_vert_decile_italian cac_vert_decile_fine_dining;
%let keep_vert_model = cac_vert_steak cac_vert_fast_casual cac_vert_cdr_bar cac_vert_dessert cac_vert_coffee cac_vert_pizza cac_vert_italian cac_vert_fine_dining;
%let keep_eth = etech_group_code etech_assimilation etech_id;


/*MACRO FOR GENERATING SAS DATASET OF DATA TO EXPORT*/
%macro export_hh(qtr=, year=, email=rstoltz@cac-group.com, cac_read_dir_loc=B, cstate=XXXXXXXXXX, codepath=PROD);

    %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc";

    %if &cac_read_dir_loc=A %then %do;                                               *** IF CURRENT PRODUCTION DATA IS IN A THEN WRITE DATA FOR NEW QUARTER TO B;
      libname _ALL_;
      libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";
      libname eth      "/project/CACDIRECT/&cidatapath./ETECH/B";
      libname exp_full "/project/CACDIRECT/&cidatapath./EXPORT/FULL/B";
      libname intmdl "/project/CACDIRECT/&cidatapath./INTMDL/B";
    %end;
    
    %else %if &cac_read_dir_loc=B %then %do;                                        *** IF CURRENT PRODUCTION DATA IS IN B THEN WRITE DATA FOR NEW QUARTER TO A;
      libname _ALL_;
      libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/A";
      libname eth      "/project/CACDIRECT/&cidatapath./ETECH/A";
      libname exp_full "/project/CACDIRECT/&cidatapath./EXPORT/FULL/A";
      libname intmdl "/project/CACDIRECT/&cidatapath./INTMDL/A";
    %end;

   filename out "/project/CACDIRECT/&cidatapath./EXPORT/FULL/cac_hh_master_&cstate..csv";
   filename out_samp "/project/CACDIRECT/&cidatapath./EXPORT/SAMPLE/samp_hh_&cstate..csv";
   libname dma      '/project/CACDIRECT/DATA/DMA/A';
   
   %let states = AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT 
                  NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY DC;

   %include "/project/CACDIRECT/CODE/&cicodepath./METADATA/INCLUDES/dma_match_macro.sas";

      %do i = 1 %to 51;
         %let currnum =  %scan(&states,&i,' ');
         %put &currnum &cstate;
         %if %bquote(&cstate) ne %bquote(&currnum) %then %do; %end; %else %let num = &i;
      %end;
   
      /*SORT DATA AND KEEP ONLY NECESSARY VARIABLES*/
      proc sort data = base.base_demo_&cstate. (obs = &testobs keep = &keep_demo_prod &keep_demo_name &keep_demo_addr 
                                                                                  &keep_demo_cred_1 &keep_demo_cred_2 &keep_demo_cred_3 &keep_demo_cred_4
                                                                                  &keep_demo_demo &keep_demo_home
                                                                                  &keep_demo_int_1 &keep_demo_int_2 &keep_demo_silh
                                                                                  &keep_demo_em cac_ph_area_code cac_addr_po_box_designator
                                                                                  &keep_vert_model &keep_vert_decile &keep_gender
                                                                           where = (cac_prod_active_flag = 1 and cac_addr_po_box_designator = "")) out = export_start;
         by cac_name_last;
      run;

      /*CREATE/CHANGE VARIABLES*/
      data export_bitmasks (drop = &keep_demo_cred_1 &keep_demo_cred_3 &keep_demo_cred_4 &keep_demo_int_1 cac_addr_latitude cac_addr_longitude cac_addr_po_box_designator &keep_demo_em &keep_gender)
       for_parsimony_&cstate. (keep=cac_hh_pid cac_qtr cac_year cac_name_first cac_name_last cac_addr_full cac_addr_state cac_addr_zip);   

         /*CHANGE LENGTHS OF VARIABLES*/
         length cac_demo_income_enh $2 cac_home_sq_foot $2;
         set export_start;
         /*CREATE BITMASKS*/
         cac_cred_bitmask_loan = cat(cac_cred_auto_loan, cac_cred_bank, cac_cred_debit, cac_cred_education_loan, cac_cred_fin_ser_insure,
                              cac_cred_finance, cac_cred_financial_banking, cac_cred_financial_installment, cac_cred_home_mortgage, 
                              cac_cred_leasing);
         cac_cred_bitmask_majcc = cat(cac_cred_amex, cac_cred_any, cac_cred_mastercard, cac_cred_visa);
         cac_cred_bitmask_othcc = cat(cac_cred_catalog, cac_cred_comp_electronic, cac_cred_furniture, cac_cred_grocery, cac_cred_high_spec_retail,
                              cac_cred_high_std_retail, cac_cred_home_improve, cac_cred_home_office, cac_cred_low_dept, cac_cred_main_st_retail,
                              cac_cred_misc, cac_cred_oil, cac_cred_spec_apparel, cac_cred_sport, cac_cred_std_retail, cac_cred_std_specialty,
                              cac_cred_travel, cac_cred_tv_mail_ord, cac_cred_warehouse);
         cac_int_bitmask_animals = cat(cac_int_47, cac_int_14, cac_int_15, cac_int_16, cac_int_80);
         cac_int_bitmask_crafts = cat(cac_int_5, cac_int_29, cac_int_2, cac_int_26, cac_int_27, cac_int_28, cac_int_33, cac_int_51,
                                      cac_int_61, cac_int_41, cac_int_52, cac_int_53, cac_int_23, cac_int_24, cac_int_54);
         cac_int_bitmask_books = cat(cac_int_55, cac_int_3, cac_int_4, cac_int_56, cac_int_57, cac_int_63, cac_int_64);
         cac_int_bitmask_collectibles = cat(cac_int_1, cac_int_84, cac_int_81, cac_int_82, cac_int_83);
         cac_int_bitmask_donations = cat(cac_int_35, cac_int_66, cac_int_67, cac_int_68, cac_int_69, cac_int_70, cac_int_71, cac_int_72, cac_int_73,
                                         cac_int_74, cac_int_75, cac_int_76, cac_int_77, cac_int_78, cac_int_79);
         cac_int_bitmask_finance = cat(cac_int_85, cac_int_17, cac_int_60, cac_int_86, cac_int_19, cac_int_87, cac_int_88, cac_int_89,
                                       cac_int_90, cac_int_111, cac_int_18, cac_int_91);
         cac_int_bitmask_food = cat(cac_int_46, cac_int_49, cac_int_58, cac_int_40, cac_int_44, cac_int_42);
         cac_int_bitmask_health = cat(cac_int_6, cac_int_7, cac_int_8, cac_int_9, cac_int_10, cac_int_37, cac_int_113, cac_int_38, cac_int_62,
                                      cac_int_109, cac_int_115, cac_int_11, cac_int_12, cac_int_112, cac_int_110, cac_int_13, cac_int_30,
                                      cac_int_116);
         cac_int_bitmask_hobbies = cat(cac_int_48, cac_int_25, cac_int_59, cac_int_36, cac_int_43, cac_int_45, cac_int_50, cac_int_34, cac_int_114,
                                       cac_int_64, cac_int_65);
         cac_int_bitmask_mail = cat(cac_int_20, cac_int_21, cac_int_92, cac_int_93, cac_int_94, cac_int_95, cac_int_96, cac_int_97, cac_int_98,
                                    cac_int_99, cac_int_100, cac_int_101, cac_int_22, cac_int_mail_buy);
         cac_int_bitmask_music = cat(cac_int_102, cac_int_103, cac_int_104, cac_int_105, cac_int_106, cac_int_107, cac_int_108);
         cac_int_bitmask_travel = cat(cac_int_120, cac_int_117, cac_int_118, cac_int_31, cac_int_119, cac_int_39, cac_int_121, cac_int_32);
         /*CONVERT LAT/LON TO POINT OBJECT*/
         cac_addr_lon_lat = cat(cac_addr_longitude, ",", cac_addr_latitude);
         /*CREATE STATE CODE*/
         cac_addr_state_code = &num;
         /*CONVERT CAC_DEMO_INCOME_ENH TO NUMERIC*/
         if cac_demo_income_enh = "A" then cac_demo_income_enh = "10";
         else if cac_demo_income_enh = "B" then cac_demo_income_enh = "11";
         else if cac_demo_income_enh = "C" then cac_demo_income_enh = "12";
         else if cac_demo_income_enh = "D" then cac_demo_income_enh = "13";
         /*CONVERT CAC_HOME_SQ_FOOT TO NUMBERIC*/
         if cac_home_sq_foot = "A" then cac_home_sq_foot = "1";
         else if cac_home_sq_foot = "B" then cac_home_sq_foot = "2";
         else if cac_home_sq_foot = "C" then cac_home_sq_foot = "3";
         else if cac_home_sq_foot = "D" then cac_home_sq_foot = "4";
         else if cac_home_sq_foot = "E" then cac_home_sq_foot = "5";
         else if cac_home_sq_foot = "F" then cac_home_sq_foot = "6";
         else if cac_home_sq_foot = "G" then cac_home_sq_foot = "7";
         else if cac_home_sq_foot = "H" then cac_home_sq_foot = "8";
         else if cac_home_sq_foot = "I" then cac_home_sq_foot = "9";
         else if cac_home_sq_foot = "J" then cac_home_sq_foot = "10";
         else if cac_home_sq_foot = "K" then cac_home_sq_foot = "11";
         else if cac_home_sq_foot = "L" then cac_home_sq_foot = "12";
         else if cac_home_sq_foot = "M" then cac_home_sq_foot = "13";
         else if cac_home_sq_foot = "N" then cac_home_sq_foot = "14";
         else if cac_home_sq_foot = "Z" then cac_home_sq_foot = "";
         /*GENERATE PHONE AVAILABILITY FLAG*/
         if cac_ph_area_code = "" then cac_ph_avail_flag = 0;
         else cac_ph_avail_flag = 1;
         /*GENERATE EM AVAILABILITY FLAG*/
         if cac_bridge_em_flag = 1 then cac_em_avail_flag = 1;
         /*GENERATE COMBINED AVAILABILITY FLAG*/
         if cac_ph_avail_flag = 1 and cac_em_avail_flag = 1 then cac_comb_avail_flag = 1;
         /*GENERATE GENDER FLAGS*/
         if cac_ind1_gender = 1 or cac_ind2_gender = 1 or cac_ind3_gender = 1 or cac_ind4_gender = 1 or cac_ind5_gender = 1 then cac_male_presence_flag = 1;
         if cac_ind1_gender = 2 or cac_ind2_gender = 2 or cac_ind3_gender = 2 or cac_ind4_gender = 2 or cac_ind5_gender = 2 then cac_female_presence_flag = 1;
         if cac_ind1_gender = 3 or cac_ind2_gender = 3 or cac_ind3_gender = 3 or cac_ind4_gender = 3 or cac_ind5_gender = 3 then cac_female_presence_flag = 1;

      run;

      
    %parsimony
     (inlib=work,
     indata=for_parsimony_&cstate.,
     outlib=work,
     outdata=tsp_MKEY_&cstate.,
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


      /*SORT FOR ETHNICITY MERGE*/
      proc sort data = export_bitmasks;
         by cac_hh_pid;
      run;

      proc sort data = tsp_MKEY_&cstate.;
         by cac_hh_pid;
      run;

      proc sort data = intmdl.cog_modelscore_&cstate. (keep=CAC_HH_PID score_123_AHI01_002 decile_123_AHI01_002) out=cog_modelscore_&cstate;
         by cac_hh_pid;
      run;

      /*MERGE WITH ETHNICITY TABLE*/
      data exp_full.export_final_&cstate.;
         merge export_bitmasks (in = a)
               eth.etech_&cstate. (in = b keep = cac_hh_pid etech_group_code etech_assimilation etech_id)
               tsp_MKEY_&cstate. (in = c keep = cac_hh_pid mkey1 mkey2 mkey3 mkey4 mkey5 mkey6 mkey7)
               cog_modelscore_&cstate (in=d);
         by cac_hh_pid;
         if a;
         format mk_scf $3. st_scf $6. cac_full_fips_id $15.;
         mk_scf=substr(cac_addr_zip,1,3);
         st_scf = compress(cac_addr_state||'_'||mk_scf);
         cac_full_fips_id=compress(CAC_CENSUS_2010_STATE_CODE||CAC_CENSUS_2010_COUNTY_CODE||CAC_CENSUS_2010_TRACT_BLOCK_GRP||CAC_CENSUS_2010_BLOCK);
      run;
* Assign DMA;
 
    %dma_assigner( client_lib=exp_full
                  ,client_data=export_final_&cstate.
                  ,client_id=cac_hh_pid
                  ,client_state_var=cac_addr_state
                  ,client_zip_var=cac_addr_zip                               /* MUST BE CHARACTER */
                  ,client_county_code_var=cac_census_2010_county_code        /* MUST BE 3 BYTE CHARACTER */ 
                  ,outlib=exp_full
                  ,outdata=export_final_&cstate.
                  ,email=&email.);

   %qc(data=exp_full.export_final_&cstate.);

   %macro put_statement;
         put &keep_demo_prod &keep_demo_name cac_addr_lon_lat cac_addr_carrier_rt cac_addr_cbsa_code cac_addr_cdi cac_addr_city 
          cac_addr_county_code cac_addr_fips_st cac_addr_full cac_addr_lat_long_ind cac_addr_state cac_addr_street cac_addr_zip cac_addr_zip2 cac_addr_zip4
          cac_census_2010_block cac_census_2010_county_code cac_census_2010_match_type cac_census_2010_state_code cac_census_2010_tract_block_grp /*cac_dma*/ dma_code
          &keep_demo_demo &keep_demo_cred_2 &keep_demo_home &keep_demo_silh cac_male_presence_flag cac_female_presence_flag cac_cred_bitmask_loan cac_cred_bitmask_majcc
          cac_cred_bitmask_othcc cac_int_bitmask_animals cac_int_bitmask_crafts cac_int_bitmask_books cac_int_bitmask_collectibles cac_int_bitmask_donations
          cac_int_bitmask_finance cac_int_bitmask_food cac_int_bitmask_health cac_int_bitmask_hobbies cac_int_bitmask_mail cac_int_bitmask_music
          cac_int_bitmask_travel &keep_demo_int_2 &keep_eth cac_ph_area_code cac_em_avail_flag cac_addr_state_code cac_ph_avail_flag cac_comb_avail_flag
          &keep_vert_decile &keep_vert_model
          mkey1 mkey2 mkey3 mkey4 mkey5 mkey6 mkey7 mk_scf st_scf cac_full_fips_id score_123_AHI01_002 decile_123_AHI01_002;
   %mend put_statement;

   /*EXPORT DATA AS CSV*/
   data _null_;
      set exp_full.export_final_&cstate.;
      file out dlm=";" lrecl = 10000;
      %put_statement;
      if ranuni(12345)<=0.05 then do;
         file out_samp dlm=";" lrecl = 10000;
         %put_statement;
      end;
   run;

x "cd /project/CACDIRECT/&cidatapath./EXPORT/FULL";
x "sed -i 's/; ;/;;/g' cac_hh_master_&cstate..csv";
x "sed -i 's/; /;/g' cac_hh_master_&cstate..csv";
x "cd /project/CACDIRECT/&cidatapath./EXPORT/SAMPLE";
x "sed -i 's/; ;/;;/g' samp_hh_&cstate..csv";
x "sed -i 's/; /;/g' samp_hh_&cstate..csv";

%mend export_hh;
