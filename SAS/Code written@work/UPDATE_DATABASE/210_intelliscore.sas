* xxx_score_model.sas;
* Scores all productionalized intellimodel models;
* Creates cog_modelscore_<state> SAS datasets;
* Sections;

 %macro im_master_score(scr_st=             /*STATE THAT YOU WISH TO SCORE*/
                    ,testobs=               /*NUMBER OF TEST OBS TO RUN THROUGH*/
                    ,refdir=                /*DIRECTORY IN WHICH ALL OF THE MDL AND SQL FILES CAN BE FOUND*/
                    ,email=                 /*DEFAULT TO mmmattingly@cogensia.com*/
                    ,cac_read_dir_loc=
                    ,codepath=
                    );

    options linesize=max mprint mlogic merror;
   
    %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc";
            
    %if &cac_read_dir_loc=A %then %do;                                               *** IF CURRENT PRODUCTION DATA IS IN A THEN WRITE DATA FOR NEW QUARTER TO B;
        libname _ALL_;
        libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";
        libname geo      "/project/CACDIRECT/&cidatapath./GEO/B";
        libname cen2010 "/project17/CENSUS/DATA/2010/FINAL";
        libname intmdl      "/project/CACDIRECT/&cidatapath./INTMDL/B";
    %end;
    
    %else %if &cac_read_dir_loc=B %then %do;                                        *** IF CURRENT PRODUCTION DATA IS IN B THEN WRITE DATA FOR NEW QUARTER TO A;
              libname _ALL_;
              libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/A";
              libname geo      "/project/CACDIRECT/&cidatapath./GEO/A";
              libname cen2010 "/project17/CENSUS/DATA/2010/FINAL";
              libname intmdl      "/project/CACDIRECT/&cidatapath./INTMDL/A";
    %end;

   * LIBNAME FOR RAW DMA DATA;
   libname dma "/project/CACDIRECT/&cidatapath./DMA/A";
    
    %include '/project/INTELLIMODEL/CODE/@INCLUDES/intellimodel_master_includes.inc';
    %include "/project/CACDIRECT/CODE/&cicodepath./METADATA/INCLUDES/dma_match_macro.sas";

    %let modelname = &cog_client_id._&cog_model_id.;
  
    %let base_vars=;
    %let geo_vars=;
    %let cen_vars=;
    %let invars_num=;
    %let invars_char=;
    %let scores=;
    
    %PUT SCORE DATE: &sysdate;
   
 * Section 1: Get list of models to score and variable lists for models;
 * Source: SQL table COG_CLIENT_MODEL_DESCRIPTION;
 * Criteria: distinct cog_model_id where cog_model_status_id=1;

   proc sql ;
     select distinct(strip(put(cog_client_id,3.)||"_"||cog_model_id)) into :modellist separated by ' ' 
       from g05.cog_client_model_description
       where cog_model_status_id=1;   

     select distinct(cog_model_id) into :modelqclist separated by ' ' 
       from g05.cog_client_model_description
       where cog_model_status_id=1;
       
     select distinct(strip(b.cog_parent_varname)) into :base_vars separated by ' '
       from g05.cog_client_model_description a, 
            g05.cog_client_model_variables b
      where a.cog_model_id=b.cog_model_id
        and b.cog_variable_source='BASE_DEMO';
   
     select distinct(strip(cog_parent_varname)) into :cen_vars separated by ' '
       from g05.cog_client_model_description a, 
            g05.cog_client_model_variables b
      where a.cog_model_id=b.cog_model_id
        and b.cog_variable_source='CENSUS';
   
     select distinct(strip(cog_parent_varname)) into :geo_vars separated by ' '
       from g05.cog_client_model_description a, 
            g05.cog_client_model_variables b
      where a.cog_model_id=b.cog_model_id
        and b.cog_variable_source='GEO_INTEREST';
   
     select distinct(strip(cog_parent_varname)) into :invars_num separated by ' '
       from g05.cog_client_model_description a, 
            g05.cog_client_model_variables b
      where a.cog_model_id=b.cog_model_id
        and b.cog_variable_type='NUMERIC'
        and b.cog_model_var_use ne 'SCORE';
   
     select count(distinct(strip(cog_parent_varname))) into :cntnum
       from g05.cog_client_model_description a, 
            g05.cog_client_model_variables b
      where a.cog_model_id=b.cog_model_id
        and b.cog_variable_type='NUMERIC'
        and b.cog_model_var_use ne 'SCORE';
   
     select distinct(strip(cog_parent_varname)) into :invars_char separated by ' '
       from g05.cog_client_model_description a, 
            g05.cog_client_model_variables b
      where a.cog_model_id=b.cog_model_id
        and b.cog_variable_type='CHARACTER'
        and b.cog_model_var_use ne 'SCORE';
   
    select count(distinct(strip(cog_parent_varname))) into :cntchar
      from g05.cog_client_model_description a, 
            g05.cog_client_model_variables b
      where a.cog_model_id=b.cog_model_id
        and b.cog_variable_type='CHARACTER'
        and b.cog_model_var_use ne 'SCORE';
   
     select distinct(strip(cog_model_varname)) into :scores separated by ' '
       from g05.cog_client_model_description a, 
            g05.cog_client_model_variables b
      where a.cog_model_id=b.cog_model_id
        and b.cog_variable_type='CHARACTER'
        and b.cog_model_var_use ne 'SCORE';
   
   quit;
   
   %let invars=&invars_num &invars_char;
   
   %put BASE VARS: &base_vars;
   %put CENSUS VARS: &cen_vars;
   %put GEO VARS: &geo_vars;
   %put MODEL LIST: &modellist;
   %put NUMERIC INVARS: &invars_num;
   %put NUMBER NUMERIC INVARS: &cntnum;
   %put CHAR INVARS: &invars_char;
   %put NUMBER CHAR INVARS: &cntchar;
   %put INVARS: &invars;
   %put SCORES: &scores;
   
   
   %let default_vars=cac_prod_active_flag cac_addr_longitude cac_addr_latitude cac_addr_po_box_designator
                     cac_hh_pid cac_addr_full cac_addr_city cac_addr_state cac_addr_zip cac_addr_zip4 cac_name_first cac_name_last cac_addr_zip2
                     cac_home_own cac_h_ind_home_own cac_value_score_all_enh cac_home_dwell_type cac_demo_income_enh cac_demo_income_narrow_enh
                     cac_demo_hh_size_enh cac_home_sq_foot_num cac_demo_kids_enh cac_demo_education_enh cac_demo_occupation 
                     cac_home_market_val cac_demo_age_enh cac_home_res_length cac_demo_marital_status cac_demo_num_kids_enh cac_ind1_age_enh cac_demo_kids_enh
                     cac_silh cac_silh_super cac_silh_dig_inf cac_silh_social cac_silh_loyal cac_silh_ecom 
                     cac_value_score_all_enh cac_addr_zip cac_addr_latitude cac_addr_longitude cac_addr_city cac_addr_state cac_census_2010_county_code;
   
   *SET DEFAULT OBS TO MAX*;
   
   %if %qscan(&testobs,1,%str( ))= %str() %then %do;
      %let testobs=max;
%end;
   
   
 * Section 2: Get data to score model;
 * Source: base_demo, geo_interest, census;
 * Criteria: production active only; 
 * Output: base_&scr_st;
   
   data base_&scr_st;
      set base.base_demo_&scr_st (obs=&testobs keep=&default_vars &base_vars where=(cac_addr_po_box_designator eq ''
                                                                                     and cac_prod_active_flag=1  
                                                                                        and (cac_name_last ne '' and cac_name_first ne '') 
                                                                                             and cac_addr_full ne ''));
   run;
   
   *DEDUP*;
   proc sort data=base_&scr_st;
      by cac_addr_full cac_addr_state cac_addr_zip descending cac_home_own;
   run;
   
   data base_&scr_st;
      set base_&scr_st;
      by cac_addr_full cac_addr_state cac_addr_zip descending cac_home_own;
      if first.cac_addr_zip then output;
   run;
   
   * APPEND GEO INTEREST DATA IF NEEDED
   %if %qscan(&geo_vars,1,%str( )) ne %str() %then %do;   *<----------------------------- START GEO APPEND;
   
      proc sort data=base_&scr_st;
         by cac_hh_pid;
      run;
   
      proc sort data=base_&scr_st (keep=cac_hh_pid cac_addr_zip2 cac_addr_zip) out=client_z2_&scr_st ;
         by cac_addr_zip2;
      run;
   
      proc sort data=geo.geo_interest_&scr_st (keep=cac_addr_zip2 cac_addr_zip &geo_vars geo_cac_int_1) out=geo_interest_&scr_st;
         by cac_addr_zip2;
      run;
   
      data client_z2_found_&scr_st (drop=newzip) zip_&scr_st (drop=geo: rename=(cac_addr_zip2=hold));
         format cac_addr_zip2 $7.;
         merge client_z2_&scr_st (in=a)
               geo_interest_&scr_st (in=b);
         by cac_addr_zip2;
         cac_geo_match=1;
         if substr(cac_addr_zip2,6,2)='XX' then cac_geo_match=2;
         if a and b and geo_cac_int_1^=. then output client_z2_found_&scr_st;
         else if a then do;
            cac_geo_match=0;
            format newzip $7.;
            newzip=strip(compress(cac_addr_zip || 'XX'));
            output zip_&scr_st;
         end;
      run;
   
      proc sort data=zip_&scr_st;
          by newzip;
      run;
   
      data client_zip_found_&scr_st (drop=cac_addr_zip2 newzip rename=(hold=cac_addr_zip2)) state_&scr_st (drop=cac_addr_zip2 geo: );
         format cac_addr_zip2 $7.;
         merge zip_&scr_st (in=a rename=(newzip=cac_addr_zip2))
               geo_interest_&scr_st (in=b);
         by cac_addr_zip2;
         cac_geo_match=2;
         if a and b and geo_cac_int_1^=. then output client_zip_found_&scr_st;
         else if a then do;
            cac_geo_match=0;
            newzip='XXXXXXX';
            output state_&scr_st;
         end;
      run;
   
      data client_state_found_&scr_st (drop=cac_addr_zip2 rename=(hold=cac_addr_zip2));
         merge state_&scr_st (in=a rename=(newzip=cac_addr_zip2))
               geo_interest_&scr_st (in=b);
         by cac_addr_zip2;
         cac_geo_match=3;
         if a and b;
      run;
   
      data client_z2_final_&scr_st;
         set client_z2_found_&scr_st (keep=cac_hh_pid cac_geo_match geo_:) 
             client_zip_found_&scr_st  (keep=cac_hh_pid cac_geo_match geo_:)
             client_state_found_&scr_st (keep=cac_hh_pid cac_geo_match geo_:);
      run;
   
      proc sort data=client_z2_final_&scr_st;
         by cac_hh_pid;
      run;
   
      data base_&scr_st (sortedby=cac_hh_pid);
         merge base_&scr_st (in=a)
               client_z2_final_&scr_st (in=b);
         by cac_hh_pid;
         if a;
      run;
   
      proc datasets library=work nolist;
         delete client_z2_final_&scr_st 
                client_z2_found_&scr_st 
                client_zip_found_&scr_st 
                client_state_found_&scr_st 
                client_z2_&scr_st;
      quit;
   
   %end;                                                       *<----------------------------- END GEO APPEND;
   

   * APPEND CENSUS DATA IF NEEDED;  
   %if %qscan(&cen_vars,1,%str( )) ne %str() %then %do;        *<----------------------------- START CENSUS APPEND;
   
      *MERGE ON ZIP ZIP4 WHERE POSSIBLE*;
         proc sort data=base_&scr_st;
            by cac_addr_zip cac_addr_zip4;
         run;
   
         data m_cen_zip9_&scr_st nm_cen_zip9_&scr_st;
            merge base_&scr_st (in=a)
                  cen2010.cac_census_xref_&scr_st (in=b);
            by cac_addr_zip cac_addr_zip4;
            if a and b then do;
               cac_census_match=1;
               cac_census_match_level='ZIP9';
               output m_cen_zip9_&scr_st; 
            end;
            else if a and not b then output nm_cen_zip9_&scr_st;
         run;
   
         proc sort data=nm_cen_zip9_&scr_st; 
            by cac_addr_zip;
         run;
   
      *MERGE ON ZIP WHERE NOT MERGED ON ZIP ZIP4*;
         data cen_xref_&scr_st;
           set cen2010.cac_census_xref_&scr_st (where=(cac_addr_zip4 eq ''));
         run;
   
         proc sort data=cen_xref_&scr_st;
           by cac_addr_zip;
         run;
   
         data m_cen_zip5_&scr_st nm_cen_zip_&scr_st;
            merge nm_cen_zip9_&scr_st (in=a drop=cac_census_id)
                  cen_xref_&scr_st (in=b keep=cac_census_id cac_addr_zip);  
            by cac_addr_zip;
            if a and b then do;
               cac_census_match=1;
               cac_census_match_level='ZIP5';
               output m_cen_zip5_&scr_st;
            end;
            else if a and not b then do;
                 cac_census_match=0;
                 output nm_cen_zip_&scr_st;
            end;
         run;
   
      *STACK ZIP9 AND ZIP5 RECORDS BACK TOGETHER*;
         data client_with_cen_id_&scr_st;
           set m_cen_zip9_&scr_st
               m_cen_zip5_&scr_st;
         run;
   
         proc sort data=client_with_cen_id_&scr_st;
           by cac_census_id;
         run;
   
         data client_with_census_&scr_st;
            merge client_with_cen_id_&scr_st (in=a)
                  cen2010.cac_census_final_&scr_st (in=b keep=cac_census_id &cen_vars);
            by cac_census_id;
            if a and b;
         run;
   
         data base_&scr_st;
            set client_with_census_&scr_st 
                nm_cen_zip_&scr_st;
         run;
   
         proc datasets lib=work nolist; 
            delete cen_xref_&scr_st;
            delete m_cen_zip9_&scr_st;
            delete nm_cen_zip9_&scr_st;
            delete m_cen_zip5_&scr_st;
            delete nm_cen_zip_&scr_st;
            delete client_with_cen_id_&scr_st;
            delete client_with_census_&scr_st;
         quit;
   
   %end;                                        *<----------------------------- END CENSUS APPEND;

 * Section 3: QC input data;
 * Source: base_&scr_st;
 
   ods html body="./Intellimodel_input_data_QC_&scr_st._&sysdate..htm";

   %if &cntnum >0 %then %do;
       options nolabel; 
       title1 "INTELLIMODEL &SYSDATE. INPUT DATA";
       
         proc univariate noprint data=base_&scr_st;
       				var &invars_num;
       				output out=input_means_&sysdate
       				mean=   mean1 - mean%eval(&cntnum)
       				n=      nobs1 - nobs%eval(&cntnum)
       				nmiss=  nmis1 - nmis%eval(&cntnum)
       				std=    std1 - std1%eval(&cntnum)
       				median= med1 - med%eval(&cntnum)
       				min=    min1 - min%eval(&cntnum)
       				max=    max1 - max%eval(&cntnum);
	 run;
       
       
         data all_means;
              score_date="&sysdate";
              score_state="&scr_st";
       	  set input_means_&sysdate;
                 length variable $50;
       	   %do i=1 %to &cntnum;
       	      variable = "%scan(&invars_num, &i)";
              nobs = nobs&i;
       	      nmiss = nmis&i;
       	      mean = mean&i;
              std = std&i;
       	      med = med&i;
       	      min = min&i;
       	      max = max&i;
       	      output;
       	      keep variable score_date score_state nobs nmiss mean std med min max;
       	   %end;
          run;
          
          proc print data=all_means noobs;
          run;
   %end;
   
   %if &cntchar >0 %then %do;
   
       proc freq data=base_&scr_st;
         %do current_var = 1 %to &cntchar;
             %let c_var=%scan(&invars_char,&current_var);
             tables &c_var / out=freq_&current_var noprint missing;
         %end;
       run; 
   
         %do current_var = 1 %to &cntchar;
             %let c_var=%scan(&invars_char,&current_var);
        
             data freq_&current_var; 
              score_date="&sysdate";
              score_state="&scr_st";
              length variable $50.;
              length value $32.;
              set freq_&current_var;
              value=put(&c_var,32.);
              variable="&c_var";
              drop &c_var;
             run;
             
             proc append base=input_freqs data=freq_&current_var force;
	     run;
        %end;
        
        proc print data=input_freqs noobs;
        run;
   %end;

   
  ods html close; 
  
 * Section 4: Score the models and assign decile;
 * Source: base_&scr_st;
 * Criteria: production active only; 
 * Output: cog_model_&scr_st;
 
  data cog_modelscore_&scr_st;
    set base_&scr_st;
   
      **** IF THERE ARE NUMERIC VARIABLES IN THE MODEL;
         %if &cntnum > 0 %then %do;
            *** ARRAY OF NUMERIC VARIABLES;
            array invars_num &invars_num;
            *** TEMPORARY ARRAY TO HOLD ORIGINAL VALUES OF NUMERIC VARIABLES;
            array origvars_num[&cntnum] /*_temporary_ */;
            **** INITIALIZE ORIG_VARS TO ORIGINAL VALUES OF INPUT VARIABLES;
            do varnum = 1 to &cntnum;
               origvars_num(varnum)=invars_num(varnum);
            end;
         %end; 
   
      **** IF THERE ARE CHARACTER VARIABLES IN THE MODEL;
         %if &cntchar > 0 %then %do;
            *** ARRAY OF CHAR VARIABLES;
            array invars_char $ &invars_char;
            *** TEMPORARY ARRAY TO HOLD VALUES OF ORIGINAL CHAR VARIABLES;
            array origvars_char[&cntchar] $ /*_temporary_*/; 
            **** INITIALIZE ORIG_VARS TO ORIGINAL VALUES OF INPUT VARIABLES;
            do varnum = 1 to &cntchar;
               origvars_char(varnum)=invars_char(varnum);
            end;
         %end; 
   
      **** SEQUENTIALLY APPLY MODEL SPECIFIC .SQL, .MDL, AND CREATE SCORES;
         %let lpnum=0; 
         %do %while(%scan(&modellist,&lpnum+1,%str( )) ne %str( ));
            %let lpnum=%eval(&lpnum+1);
            %let model=%scan(&modellist,&lpnum);
            
            %include "&refdir./&model./&model..mdl";
            %include "&refdir./&model./&model..sql";
       
            *** RESTORE ORIGINAL VALUES TO VARIABLES;
               %if &cntnum > 0 %then %do;
                   do varnum = 1 to &cntnum;
                      invars_num(varnum)=origvars_num(varnum);
                   end;
               %end;
               %if &cntchar > 0 %then %do;
                  do varnum = 1 to &cntchar;
                     invars_char(varnum)=origvars_char(varnum);
                  end;
               %end;
         %end;
   run;
   
 * Section 4: QC;
 * Source:;
 * Criteria:;  
 
  %let intmdl=0; 
       %do %while(%scan(&modelqclist,&intmdl+1,%str( )) ne %str( ));
             %let intmdl=%eval(&intmdl+1);
             %let thismodel=%scan(&modelqclist,&intmdl);
             %let thismodel2=%scan(&modellist,&intmdl);
             
             ods html body="./Intellimodel_output_data_QC_&scr_st._&sysdate..htm";
                                      
             proc sql noprint;
                select distinct(strip(b.cog_model_varname)) into :model_vars separated by ' '
	           from g05.cog_client_model_description a, 
	                g05.cog_client_model_variables b
	           where a.cog_model_id=b.cog_model_id
                     and b.COG_MODEL_VAR_USE = 'SCORING' 
                     and a.cog_model_id="&thismodel";
                                          
                select count(distinct(strip(cog_model_varname))) into :cntmodvars
                  from g05.cog_client_model_description a, 
	                g05.cog_client_model_variables b
	           where a.cog_model_id=b.cog_model_id
                     and b.COG_MODEL_VAR_USE = 'SCORING' 
                     and a.cog_model_id="&thismodel";    
             quit;
             
             proc univariate noprint data=cog_modelscore_&scr_st;
       				var &model_vars;
       				output out=model_var_means
       				mean=   mean1 - mean%eval(&cntmodvars)
       				n=      nobs1 - nobs%eval(&cntmodvars)
       				nmiss=  nmis1 - nmis%eval(&cntmodvars)
       				std=    std1 - std1%eval(&cntmodvars)
       				median= med1 - med%eval(&cntmodvars)
       				min=    min1 - min%eval(&cntmodvars)
       				max=    max1 - max%eval(&cntmodvars);
	     run;
              
             data model_var_means (keep=cog_model_id score_date score_state model_variable non_missing_observations missing_observations mean_value standard_deviation);
               cog_model_id="&thismodel";
               score_date="&sysdate.";;
               score_state="&scr_st";
       	       set model_var_means;
                   length model_variable $50;
       	       %do i=1 %to &cntnum;
       	           model_variable = "%scan(&invars_num, &i)";
                   n = nobs&i;
       	           nmiss = nmis&i;
       	           mean = mean&i;
                   std = std&i;
       	           med = med&i;
       	           min = min&i;
       	           max = max&i;
       	           output;
       	           rename n=non_missing_observations nmiss=missing_observations mean=mean_value std=standard_deviation;
       	       %end;
             run;  
             
             proc sql;
                delete from g05.COG_CLIENT_MODEL_VARIABLE_MEANS where cog_model_id="&thismodel" and score_date="&sysdate";

                insert into g05.COG_CLIENT_MODEL_VARIABLE_MEANS 		
                select COG_MODEL_ID,
                       SCORE_DATE,
                       SCORE_STATE,
                       MODEL_VARIABLE,
                       NON_MISSING_OBSERVATIONS,
                       MISSING_OBSERVATIONS,
                       MEAN_VALUE,
                       STANDARD_DEVIATION
                  from model_var_means
                  where cog_model_id="&thismodel" and score_date="&sysdate";
             quit;
             
             title1 "Intellimodel &thismodel score and Model Variable by &thismodel decile &sysdate."; 
             proc print data=model_var_means noobs;
             run;                         
             
             proc means data=cog_modelscore_&scr_st n nmiss mean std min max noprint;
                class decile_&thismodel2;
                var score_&thismodel2.;
                output out = decile_stats (drop=_type_ _freq_);
             run;            
                          
             proc transpose data=decile_stats out=transposed_decile_stats name=model_score;
               where not missing(decile_&thismodel2);
               by decile_&thismodel2;
               id _stat_;
             run;
             
             data final_decile_stats (keep=cog_model_id score_date score_state decile count mean_modelscore min_modelscore max_modelscore);
               cog_model_id="&thismodel";
	       score_date="&sysdate.";
               score_state="&scr_st";
               set transposed_decile_stats (rename=(decile_&thismodel2=decile n=count mean=mean_modelscore min=min_modelscore max=max_modelscore)); 
             run;	  
             
             proc print data=final_decile_stats noobs;
             run;  
             
             proc sql;
                delete from g05.COG_CLIENT_MODEL_DECILES where cog_model_id="thismodel2" and score_date="&sysdate";

                insert into g05.COG_CLIENT_MODEL_DECILES	
                select COG_MODEL_ID,
                       SCORE_DATE,
                       SCORE_STATE,
                       DECILE,
                       COUNT,
                       MEAN_MODELSCORE,
                       MIN_MODELSCORE,
                       MAX_MODELSCORE
                  from final_decile_stats 
                  where cog_model_id="thismodel2" and score_date="&sysdate";
             quit;
             
             proc datasets lib=work nolist;
               delete model_var_means;
               delete decile_stats;
               delete transposed_decile_stats;
             quit;                   
                          
             ods html close; 
       %end;
       
* Master QC tables here....;    

* Generate decile _N_ average score state date historically;
  
* Output final dataset;
    proc sort data=cog_modelscore_&scr_st out=intmdl.cog_modelscore_&scr_st (keep=cac_hh_pid score_: decile_: cac_home_own cac_home_dwell_type cac_demo_income_enh cac_ind1_age_enh cac_demo_kids_enh cac_demo_marital_status cac_silh
                                                                                  cac_value_score_all_enh cac_addr_zip cac_addr_latitude cac_addr_longitude cac_addr_city cac_addr_state cac_census_2010_county_code);
      by cac_hh_pid;
    run;

* Assign DMA;
 
    %dma_assigner( client_lib=intmdl
                  ,client_data=cog_modelscore_&scr_st
                  ,client_id=cac_hh_pid
                  ,client_state_var=cac_addr_state
                  ,client_zip_var=cac_addr_zip                               /* MUST BE CHARACTER */
                  ,client_county_code_var=cac_census_2010_county_code        /* MUST BE 3 BYTE CHARACTER */	
                  ,outlib=intmdl
                  ,outdata=cog_modelscore_&scr_st
                  ,email=&email.);

  ods html body="./Intellimodel_contents_&scr_st._&sysdate..htm";  
  
    title1 "Contents of final COG_MODEL_SCORE_&SCR_ST";
    proc contents data=intmdl.cog_modelscore_&scr_st;
    run;
    
  ods html close; 
  
 *  Cleanup;
      proc datasets lib=work nolist;
        delete cog_modelscore_&scr_st;
      quit;

 * Section 5: Email;

    filename mail1 email to=("&email") 
                              subject="Intellmodel Scoring Update Complete &scr_st &sysdate." 
                              from="webmaster@cac-group.com"
                              attach=("./Intellimodel_input_data_QC_&scr_st._&sysdate..htm"
                                      "./Intellimodel_output_data_QC_&scr_st._&sysdate..htm"
                                      "./Intellimodel_contents_&scr_st._&sysdate..htm");
                              
                              
    data _null_;
       file mail1;
       put "Intellimodel Scoring Process Complete for &scr_st &sysdate.";
       put "Please see input and output QC for variable distribution and model score by decile";
    run;
 
 %mend im_master_score;



