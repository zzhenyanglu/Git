* xxx_score_vertical_segments.sas;
* This is the general macro for scoring vertical segments;
* Release: 2015 Q1 R1;

options linesize=max mprint mlogic merror;

%macro score_vertical_segments (cacdir_loc=
                                ,codepath=PROD
                                ,scr_st=             /*STATE THAT YOU WISH TO SCORE*/
                                ,testobs=            /*NUMBER OF TEST OBS TO RUN THROUGH*/
                                ,refdir=             /*DIRECTORY IN WHICH ALL OF THE MDL AND SQL FILES CAN BE FOUND*/
                                ,email=              /*DEFAULT TO mmmattingly@cogensia.com*/
                                 );

 %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc";

 * DEFINE LIBNAMES FOR QUARTER OF DATA BEING SCORED - MEANING WHERE DOES NEW PRODUCTION LIVE;

    %if &cacdir_loc=A %then %do;                                               *** IF CURRENT PRODUCTION DATA IS IN A THEN WRITE DATA FOR NEW QUARTER TO B;
        libname _ALL_;
        libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";
        libname indiv    "/project/CACDIRECT/&cidatapath./INDIV_DEMO/B";
        libname scf      "/project/CACDIRECT/&cidatapath./SCF_MKEY/B";
        libname geo      "/project/CACDIRECT/&cidatapath./GEO/B";
        libname samp     "/project/CACDIRECT/&cidatapath./SAMPLES/B";  
        libname newsilh  "/project/CACDIRECT/&cidatapath./SILH3D/B";
        libname cen2010 "/project17/CENSUS/DATA/2010/FINAL";
    %end;
    
    %else %if &cacdir_loc=B %then %do;                                        *** IF CURRENT PRODUCTION DATA IS IN B THEN WRITE DATA FOR NEW QUARTER TO A;
              libname _ALL_; 
              libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/A";
              libname indiv    "/project/CACDIRECT/&cidatapath./INDIV_DEMO/A";
              libname scf      "/project/CACDIRECT/&cidatapath./SCF_MKEY/A";
              libname geo      "/project/CACDIRECT/&cidatapath./GEO/A";
              libname samp     "/project/CACDIRECT/&cidatapath./SAMPLES/A";          
              libname newsilh  "/project/CACDIRECT/&cidatapath./SILH3D/A";
              libname cen2010 "/project17/CENSUS/DATA/2010/FINAL";
    %end; 

%let base_vars=
CAC_ADDR_CDI
CAC_CRED_TRAVEL
CAC_DEMO_ADULT_55_64_ENH
CAC_DEMO_ADULT_65_74_ENH
CAC_DEMO_AGE_ENH
CAC_DEMO_EDUCATION_ENH
CAC_DEMO_HH_TYPE_ENH
CAC_DEMO_INCOME_ENH
CAC_DEMO_INCOME_ENH 
CAC_DEMO_INCOME_NARROW_ENH
CAC_DEMO_KIDS_00_02_ENH
CAC_DEMO_NET_WORTH_ENH
CAC_DEMO_NUM_ADULTS 
CAC_DEMO_NUM_KIDS_ENH
CAC_DEMO_OCCUPATION
CAC_HOME_OWN
CAC_HOME_RES_LENGTH
CAC_INT_117 
CAC_INT_118 
CAC_INT_119 
CAC_INT_120 
CAC_INT_121 
CAC_INT_23 
CAC_INT_24 
CAC_INT_26 
CAC_INT_27 
CAC_INT_28 
CAC_INT_3 
CAC_INT_31 
CAC_INT_32
CAC_INT_33 
CAC_INT_35 
CAC_INT_39 
CAC_INT_4
CAC_INT_40 
CAC_INT_41 
CAC_INT_42
CAC_INT_46 
CAC_INT_49 
CAC_INT_5 
CAC_INT_51 
CAC_INT_52 
CAC_INT_53 
CAC_INT_54
CAC_INT_55 
CAC_INT_57 
CAC_INT_58 
CAC_INT_61 
CAC_INT_66 
CAC_INT_67 
CAC_INT_68 
CAC_INT_69 
CAC_INT_70 
CAC_INT_71 
CAC_INT_72 
CAC_INT_73 
CAC_INT_74 
CAC_INT_75 
CAC_INT_76 
CAC_INT_77 
CAC_INT_78 
CAC_INT_79
CAC_INT_MAIL_BUY
CAC_SILH
CAC_SILH_BUY_STYLE_GROUP
CAC_SILH_DIG_INF
CAC_SILH_ECOM
CAC_SILH_GEO
CAC_SILH_LIFESTAGE_GROUP
CAC_SILH_LIFESTYLE
CAC_SILH_LOYAL
CAC_SILH_PRICE
CAC_SILH_SOCIAL
CAC_SILH_SUPER
CAC_SILH_TECH;

%let geo_vars=
GEO_CAC_INT_101
GEO_CAC_INT_115
GEO_CAC_INT_118
GEO_CAC_INT_12
GEO_CAC_INT_15
GEO_CAC_INT_17
GEO_CAC_INT_21
GEO_CAC_INT_27
GEO_CAC_INT_29
GEO_CAC_INT_35
GEO_CAC_INT_36
GEO_CAC_INT_37
GEO_CAC_INT_39
GEO_CAC_INT_40
GEO_CAC_INT_42
GEO_CAC_INT_44
GEO_CAC_INT_46
GEO_CAC_INT_48
GEO_CAC_INT_58
GEO_CAC_INT_6
GEO_CAC_INT_69
GEO_CAC_INT_7;

%let cen_vars=
CEN_FACTOR3
CEN_FACTOR4
CEN_FACTOR7
CEN_FACTOR9
CEN_HHSIZE_2
CEN_HSEVAL_19
CEN_HSEVAL_5
CEN_POPED_4
CEN_POPED_6
CEN_POPLABR_22
CEN_POPRACE_16;

%let model_scores=cac_vert_steak cac_vert_fast_casual cac_vert_cdr_bar cac_vert_dessert cac_vert_coffee cac_vert_pizza cac_vert_italian cac_vert_fine_dining; 
%let model_deciles=cac_vert_decile_steak cac_vert_decile_fast_casual cac_vert_decile_cdr_bar cac_vert_decile_dessert cac_vert_decile_coffee cac_vert_decile_pizza cac_vert_decile_italian cac_vert_decile_fine_dining;    
%let modellist=steak fast_casual cdr_bar dessert coffee pizza italian fine_dining;

   data base_&scr_st;
      set base.base_demo_&scr_st (obs=&testobs 
                                  keep=&base_vars cac_hh_pid cac_addr_full cac_addr_state cac_addr_zip cac_addr_zip2 cac_addr_zip4 
                                       cac_addr_po_box_designator cac_prod_active_flag cac_name_last cac_name_first cac_addr_full cac_home_own);
   run;
   
   * APPEND GEO INTEREST DATA  *<----------------------------- START GEO APPEND;
   
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
      quit;                                                    *<----------------------------- END GEO APPEND;
   

   * APPEND CENSUS DATA IF NEEDED;      *<----------------------------- START CENSUS APPEND;
   
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
         quit;                                *<----------------------------- END CENSUS APPEND;
  
  data vert_segments_&scr_st (keep=cac_hh_pid &model_scores &model_deciles);
    set base_&scr_st;
         **** SEQUENTIALLY APPLY MODEL SPECIFIC .SQL, .MDL, AND CREATE SCORES;
         %let lpnum=0; 
         %do %while(%scan(&modellist,&lpnum+1,%str( )) ne %str( ));
            %let lpnum=%eval(&lpnum+1);
            %let model=%scan(&modellist,&lpnum);      
            %include "&refdir./&model..mdl";
            %include "&refdir./&model..sql";
         %end;
  run;
  
  proc sort data=vert_segments_&scr_st;
    by cac_hh_pid;
  run;
  
  data base.base_demo_&scr_st (sortedby=cac_hh_pid);
    merge base.base_demo_&scr_st (in=a)
          vert_segments_&scr_st  (in=b);
    by cac_hh_pid;
    if a;
    label cac_vert_steak="CAC Group Vertical Segments: Restaurants Steak Segment Score"; 
    label cac_vert_fast_casual="CAC Group Vertical Segments: Restaurants Fast Casual Segment Score"; 
    label cac_vert_cdr_bar="CAC Group Vertical Segments: Restaurants CDR Bar Segment Score";  
    label cac_vert_dessert="CAC Group Vertical Segments: Restaurants Dessert Segment Score";  
    label cac_vert_coffee="CAC Group Vertical Segments: Restaurants Coffee Segment Score";  
    label cac_vert_pizza="CAC Group Vertical Segments: Restaurants Pizza Segment Score";  
    label cac_vert_italian="CAC Group Vertical Segments: Restaurants Italian Segment Score";  
    label cac_vert_fine_dining="CAC Group Vertical Segments: Restaurants Fine Dining Segment Score"; 
    label cac_vert_decile_steak = "CAC Group Vertical Segments: Restaurants Steak Segment Decile";
    label cac_vert_decile_fast_casual = "CAC Group Vertical Segments: Restaurants Fast Casual Segment Decile"; 
    label cac_vert_decile_cdr_bar="CAC Group Vertical Segments: Restaurants CDR Bar Segment Decile";  
    label cac_vert_decile_dessert="CAC Group Vertical Segments: Restaurants Dessert Segment Decile"; 
    label cac_vert_decile_coffee="CAC Group Vertical Segments: Restaurants Coffee Segment Decile"; 
    label cac_vert_decile_pizza="CAC Group Vertical Segments: Restaurants Pizza Segment Decile"; 
    label cac_vert_decile_italian="CAC Group Vertical Segments: Restaurants Italian Segment Decile";  
    label cac_vert_decile_fine_dining="CAC Group Vertical Segments: Restaurants Fine Dining Segment Decile"; 
  run;

  title1 "Vertical Segment Scoring &scr_st &sysdate";
  proc freq data=base.base_demo_&scr_st;
    tables &model_deciles / list missing;
  run;
  
  proc contents data=base.base_demo_&scr_st;
  run;
  
%mend score_vertical_segments;
