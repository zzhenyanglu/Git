*========================================================================================;
* Program 080_qc_sample_report.sas
  Purpose Create the QC Sample Report for CACdirect 3.0 
          Compares means and distributions from Current Quarter 
               to Prior Quarter 
               and Current Quarter to Original Load
  Authors Mike Mattingly
*========================================================================================;
options mprint nomlogic linesize=max;

%macro dirqc(sample=point1pct,qtr=,year=,version=,red=.2,yellow=.1,email=,cacdir_loc=,codepath=PROD);

%include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc"; 

%if &qtr=1 %then %do;
    %if &version=1 %then %do;
        %let prior_qtr=4;
        %let prior_year=%eval(&year-1);
        %let prior_version=2;
    %end;
    %if &version=2 %then %do;
        %let prior_qtr=1;
        %let prior_year=&year;
        %let prior_version=1;
    %end;
%end;

%else %if &qtr ^= 1 %then  %do;
    %let prior_qtr=%eval(&qtr-1);
    %let prior_year=&year;
    %if &version=1 %then %do;
        %let prior_version=2;
    %end;
    %if &version=2 %then %do;
        %let prior_version=1;
    %end;
%end;

%put "quarter=&qtr";
%put "prior quarter=&prior_qtr";
%put "year=&year";
%put "prior year=&prior_year";
%put "prior quarter=&prior_qtr";
%put "version=&version";
%put "prior_version=&prior_version";


%let current_year=&year;
%let current_qtr=&qtr;

data _null_;
  call symput('report_date',put(today(),mmddyy10.));
run;

libname orig  "/project/CACDIRECT/&cidatapath./SAMPLES/2012/Q3";
   
    %if &cacdir_loc=A %then %do;
        libname prior "/project/CACDIRECT/&cidatapath./SAMPLES/B";
        libname samp  "/project/CACDIRECT/&cidatapath./SAMPLES/A";
    %end;

    %else %if &cacdir_loc=B %then %do;
              libname prior "/project/CACDIRECT/&cidatapath./SAMPLES/A";
              libname samp  "/project/CACDIRECT/&cidatapath./SAMPLES/B";
    %end;

%let num_vars_orig=
CAC_CRED_AMEX
CAC_CRED_ANY
CAC_CRED_AUTO_LOAN
CAC_CRED_BANK
CAC_CRED_CATALOG
CAC_CRED_COMP_ELECTRONIC
CAC_CRED_DEBIT
CAC_CRED_EDUCATION_LOAN
CAC_CRED_FIN_SER_INSURE
CAC_CRED_FINANCE
CAC_CRED_FINANCIAL_BANKING
CAC_CRED_FINANCIAL_INSTALLMENT
CAC_CRED_FLAG
CAC_CRED_FURNITURE
CAC_CRED_GROCERY
CAC_CRED_HIGH_SPEC_RETAIL
CAC_CRED_HIGH_STD_RETAIL
CAC_CRED_HOME_IMPROVE
CAC_CRED_HOME_MORTGAGE
CAC_CRED_HOME_OFFICE
CAC_CRED_LEASING
CAC_CRED_LOW_DEPT
CAC_CRED_MAIN_ST_RETAIL
CAC_CRED_MASTERCARD
CAC_CRED_MISC
CAC_CRED_MORTGAGE_INCOME_INDEX
CAC_CRED_MORTGAGE_INCOME_INDEX_2
CAC_CRED_OIL
CAC_CRED_SPEC_APPAREL
CAC_CRED_SPORT
CAC_CRED_STD_RETAIL
CAC_CRED_STD_SPECIALTY
CAC_CRED_TRAVEL
CAC_CRED_TV_MAIL_ORD
CAC_CRED_VISA
CAC_CRED_WAREHOUSE
CAC_INT_1
CAC_INT_10
CAC_INT_100
CAC_INT_101
CAC_INT_102
CAC_INT_103
CAC_INT_104
CAC_INT_105
CAC_INT_106
CAC_INT_107
CAC_INT_108
CAC_INT_109
CAC_INT_11
CAC_INT_110
CAC_INT_111
CAC_INT_112
CAC_INT_113
CAC_INT_114
CAC_INT_115
CAC_INT_116
CAC_INT_117
CAC_INT_118
CAC_INT_119
CAC_INT_12
CAC_INT_120
CAC_INT_121
CAC_INT_13
CAC_INT_14
CAC_INT_15
CAC_INT_16
CAC_INT_17
CAC_INT_18
CAC_INT_19
CAC_INT_2
CAC_INT_20
CAC_INT_21
CAC_INT_22
CAC_INT_23
CAC_INT_24
CAC_INT_25
CAC_INT_26
CAC_INT_27
CAC_INT_28
CAC_INT_29
CAC_INT_3
CAC_INT_30
CAC_INT_31
CAC_INT_32
CAC_INT_33
CAC_INT_34
CAC_INT_35
CAC_INT_36
CAC_INT_37
CAC_INT_38
CAC_INT_39
CAC_INT_4
CAC_INT_40
CAC_INT_41
CAC_INT_42
CAC_INT_43
CAC_INT_44
CAC_INT_45
CAC_INT_46
CAC_INT_47
CAC_INT_48
CAC_INT_49
CAC_INT_5
CAC_INT_50
CAC_INT_51
CAC_INT_52
CAC_INT_53
CAC_INT_54
CAC_INT_55
CAC_INT_56
CAC_INT_57
CAC_INT_58
CAC_INT_59
CAC_INT_6
CAC_INT_60
CAC_INT_61
CAC_INT_62
CAC_INT_63
CAC_INT_64
CAC_INT_65
CAC_INT_66
CAC_INT_67
CAC_INT_68
CAC_INT_69
CAC_INT_7
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
CAC_INT_8
CAC_INT_80
CAC_INT_81
CAC_INT_82
CAC_INT_83
CAC_INT_84
CAC_INT_85
CAC_INT_86
CAC_INT_87
CAC_INT_88
CAC_INT_89
CAC_INT_9
CAC_INT_90
CAC_INT_91
CAC_INT_92
CAC_INT_93
CAC_INT_94
CAC_INT_95
CAC_INT_96
CAC_INT_97
CAC_INT_98
CAC_INT_99
CAC_HOME_SALE_PRICE
GEO_CAC_INT_1
GEO_CAC_INT_2
GEO_CAC_INT_3
GEO_CAC_INT_4
GEO_CAC_INT_5
GEO_CAC_INT_6
GEO_CAC_INT_7
GEO_CAC_INT_8
GEO_CAC_INT_9
GEO_CAC_INT_10
GEO_CAC_INT_11
GEO_CAC_INT_12
GEO_CAC_INT_13
GEO_CAC_INT_14
GEO_CAC_INT_15
GEO_CAC_INT_16
GEO_CAC_INT_17
GEO_CAC_INT_18
GEO_CAC_INT_19
GEO_CAC_INT_20
GEO_CAC_INT_21
GEO_CAC_INT_22
GEO_CAC_INT_23
GEO_CAC_INT_24
GEO_CAC_INT_25
GEO_CAC_INT_26
GEO_CAC_INT_27
GEO_CAC_INT_28
GEO_CAC_INT_29
GEO_CAC_INT_30
GEO_CAC_INT_31
GEO_CAC_INT_32
GEO_CAC_INT_33
GEO_CAC_INT_34
GEO_CAC_INT_35
GEO_CAC_INT_36
GEO_CAC_INT_37
GEO_CAC_INT_38
GEO_CAC_INT_39
GEO_CAC_INT_40
GEO_CAC_INT_41
GEO_CAC_INT_42
GEO_CAC_INT_43
GEO_CAC_INT_44
GEO_CAC_INT_45
GEO_CAC_INT_46
GEO_CAC_INT_47
GEO_CAC_INT_48
GEO_CAC_INT_49
GEO_CAC_INT_50
GEO_CAC_INT_51
GEO_CAC_INT_52
GEO_CAC_INT_53
GEO_CAC_INT_54
GEO_CAC_INT_55
GEO_CAC_INT_56
GEO_CAC_INT_57
GEO_CAC_INT_58
GEO_CAC_INT_59
GEO_CAC_INT_60
GEO_CAC_INT_61
GEO_CAC_INT_62
GEO_CAC_INT_63
GEO_CAC_INT_64
GEO_CAC_INT_65
GEO_CAC_INT_66
GEO_CAC_INT_67
GEO_CAC_INT_68
GEO_CAC_INT_69
GEO_CAC_INT_70
GEO_CAC_INT_71
GEO_CAC_INT_72
GEO_CAC_INT_73
GEO_CAC_INT_74
GEO_CAC_INT_75
GEO_CAC_INT_76
GEO_CAC_INT_77
GEO_CAC_INT_78
GEO_CAC_INT_79
GEO_CAC_INT_80
GEO_CAC_INT_81
GEO_CAC_INT_82
GEO_CAC_INT_83
GEO_CAC_INT_84
GEO_CAC_INT_85
GEO_CAC_INT_86
GEO_CAC_INT_87
GEO_CAC_INT_88
GEO_CAC_INT_89
GEO_CAC_INT_90
GEO_CAC_INT_91
GEO_CAC_INT_92
GEO_CAC_INT_93
GEO_CAC_INT_94
GEO_CAC_INT_95
GEO_CAC_INT_96
GEO_CAC_INT_97
GEO_CAC_INT_98
GEO_CAC_INT_99
GEO_CAC_INT_100
GEO_CAC_INT_101
GEO_CAC_INT_102
GEO_CAC_INT_103
GEO_CAC_INT_104
GEO_CAC_INT_105
GEO_CAC_INT_106
GEO_CAC_INT_107
GEO_CAC_INT_108
GEO_CAC_INT_109
GEO_CAC_INT_110
GEO_CAC_INT_111
GEO_CAC_INT_112
GEO_CAC_INT_113
GEO_CAC_INT_114
GEO_CAC_INT_115
GEO_CAC_INT_116
GEO_CAC_INT_117
GEO_CAC_INT_118
GEO_CAC_INT_119
GEO_CAC_INT_120
GEO_CAC_INT_121
;

%let num_vars_nonorig =
cac_vert_cdr_bar
cac_vert_coffee
cac_vert_decile_cdr_bar
cac_vert_decile_coffee
cac_vert_decile_dessert
cac_vert_decile_fast_casual
cac_vert_decile_fine_dining
cac_vert_decile_italian
cac_vert_decile_pizza
cac_vert_decile_steak
cac_vert_dessert
cac_vert_fast_casual
cac_vert_fine_dining
cac_vert_italian
cac_vert_pizza
cac_vert_steak
;

%let freq_vars=
CAC_SILH_BUY_STYLE_GROUP
CAC_SILH_DIG_INF
CAC_SILH_ECOM
CAC_SILH_GEO
CAC_SILH_LIFESTAGE_GROUP
CAC_SILH_LIFESTYLE
CAC_SILH_LOYAL
CAC_SILH_PRICE
CAC_SILH_SOCIAL
CAC_SILH_SOCIO_ECON
CAC_SILH_SOCIO_GROUP
CAC_SILH_TECH
CAC_SILH_LOYAL
CAC_PROD_ACTIVE_FLAG
CAC_DEMO_MARITAL_STATUS
CAC_DEMO_NARROW_INC_NUM
CAC_DEMO_NUM_ADULTS
CAC_DEMO_OCCUPATION
CAC_HOME_DWELL_TYPE
CAC_HOME_OWN
CAC_HOME_RES_LENGTH
CAC_IND1_GENDER
CAC_IND1_RELATIONSHIP
CAC_IND2_GENDER
CAC_IND2_RELATIONSHIP
CAC_IND3_GENDER
CAC_IND3_RELATIONSHIP
CAC_IND4_GENDER
CAC_IND4_RELATIONSHIP
CAC_IND5_GENDER
CAC_IND5_RELATIONSHIP
CAC_ADDR_CDI
CAC_D_IND_MARITAL_STATUS
CAC_D_IND_NUM_ADULTS
CAC_H_IND_HOME_OWN
CAC_H_IND_RES_LENGTH
CAC_HOME_SQ_FOOT
CAC_SILH
CAC_SILH_SUPER
CAC_SILH_LIFESTYLE
;

%let enhanced_vars=
CAC_DEMO_ADULT_18_24_ENH
CAC_DEMO_ADULT_25_34_ENH
CAC_DEMO_ADULT_35_44_ENH
CAC_DEMO_ADULT_35_44_INF_ENH
CAC_DEMO_ADULT_45_54_ENH
CAC_DEMO_ADULT_45_64_INF_ENH
CAC_DEMO_ADULT_55_64_ENH
CAC_DEMO_ADULT_65_74_ENH
CAC_DEMO_ADULT_65_PLUS_INF_ENH
CAC_DEMO_ADULT_75_PLUS_ENH
CAC_DEMO_ADULT_UNDER_35_INF_ENH
CAC_DEMO_ADULT_UNKNOWN_ENH
CAC_DEMO_AGE_ENH
CAC_DEMO_HH_SIZE_ENH
CAC_DEMO_HH_TYPE_ENH
CAC_DEMO_KIDS_00_02_ENH
CAC_DEMO_KIDS_03_05_ENH
CAC_DEMO_KIDS_06_10_ENH
CAC_DEMO_KIDS_11_15_ENH
CAC_DEMO_KIDS_16_17_ENH
CAC_DEMO_KIDS_ENH
CAC_DEMO_NUM_GENERATIONS_ENH
CAC_DEMO_NUM_KIDS_ENH
CAC_DEMO_INCOME_INDEX_ENH
CAC_H_IND_HOME_VALUATION_ENH
CAC_HOME_VALUATION_ENH
CAC_DEMO_NET_WORTH_ENH
CAC_D_IND_AGE_ENH
CAC_D_IND_HH_SIZE_ENH
CAC_D_IND_KIDS_ENH
CAC_IND1_AGE_ENH
CAC_IND2_AGE_ENH
CAC_IND3_AGE_ENH
CAC_IND4_AGE_ENH
CAC_IND5_AGE_ENH
CAC_VALUE_SCORE_ALL_ENH
CAC_VALUE_SCORE_AUTO_FINANCE_ENH
CAC_VALUE_SCORE_BANK_CARD_ENH
CAC_VALUE_SCORE_RETAIL_ENH
CAC_DEMO_EDUCATION_ENH
CAC_DEMO_D_IND_EDUCATION_ENH
CAC_DEMO_INCOME_ENH
CAC_DEMO_INCOME_INF_ENH
CAC_DEMO_INCOME_NARROW_ENH
CAC_DEMO_DOB_CHILD_1_IND_ENH
CAC_DEMO_DOB_CHILD_2_IND_ENH
CAC_DEMO_DOB_CHILD_3_IND_ENH
CAC_DEMO_DOB_CHILD_4_IND_ENH
CAC_DEMO_DOB_CHILD_1_ENH
CAC_DEMO_DOB_CHILD_2_ENH
CAC_DEMO_DOB_CHILD_3_ENH
CAC_DEMO_DOB_CHILD_4_ENH
CAC_DEMO_GENDER_CHILD_1_ENH
CAC_DEMO_GENDER_CHILD_2_ENH
CAC_DEMO_GENDER_CHILD_3_ENH
CAC_DEMO_GENDER_CHILD_4_ENH
;

%let all_freq_vars=%sysfunc(catx(%str( ), &freq_vars,&enhanced_vars));
%let num_freq_vars=%sysfunc(countw(&freq_vars));
%let num_all_freq_vars=%sysfunc(countw(&all_freq_vars));

%macro mean_it (datain=,qtr=,year=,release=);
         %if &year = 2012 %then %let num_vars=&num_vars_orig;
         %else %let num_vars=%sysfunc(catx(%str( ), &num_vars_orig,&num_vars_nonorig));
         %let num_numeric_vars=%sysfunc(countw(&num_vars));

        
         proc univariate noprint data=&datain;
				var &num_vars ;
				output out=direct_means_&year._&qtr._&release
				mean=   mean1 - mean%eval(&num_numeric_vars)
				n=      nobs1 - nobs%eval(&num_numeric_vars)
				nmiss=  nmis1 - nmis%eval(&num_numeric_vars)
				std=    std1 - std1%eval(&num_numeric_vars)
				median= med1 - med%eval(&num_numeric_vars)
				min=    min1 - min%eval(&num_numeric_vars)
				max=    max1 - max%eval(&num_numeric_vars)
			;
			run;

	data all_means_&year._&qtr._&release;
	  set direct_means_&year._&qtr._&release;
          length variable $50;
	  %do i=1 %to &num_numeric_vars;
	      variable = "%scan(&num_vars, &i)";
              nobs = nobs&i;
	      nmiss = nmis&i;
	      mean = mean&i;
              std = std&i;
	      med = med&i;
	      min = min&i;
	      max = max&i;
	      output;
	      keep variable nobs nmiss mean std med min max;
	%end;
       run;
%mend mean_it;

%mean_it(datain=orig.base_samp_point1pct,qtr=1,year=2012,release=0);
%mean_it(datain=prior.base_samp_point1pct,qtr=&prior_qtr,year=&prior_year,release=&prior_version);
%mean_it(datain=samp.base_samp_point1pct,qtr=&qtr,year=&year,release=&version);

  proc sort data=all_means_2012_1_0;
   by variable;
  run;
  proc sort data=all_means_&prior_year._&prior_qtr._&prior_version;
   by variable;
  run;
  proc sort data=all_means_&current_year._&current_qtr._&version;
    by variable;
  run;
  data means;
    length status_orig $6. status_prior $6.;
    merge all_means_2012_1_0 (in=a rename=(mean=orig_mean))
          all_means_&prior_year._&prior_qtr._&prior_version (in=b rename=(mean=prior_mean))
          all_means_&current_year._&current_qtr._&version  (in=c rename=(mean=current_mean));
    by variable;

    if orig_mean ^= 0 then do;
       if (abs(current_mean-orig_mean))/orig_mean > &red then status_orig='RED';
           else if (abs(current_mean-orig_mean))/orig_mean > &yellow then status_orig='YELLOW';
           else status_orig='GREEN';
    end;

    if prior_mean ^= 0 then do;
       if (abs(current_mean-prior_mean))/prior_mean > &red then status_prior='RED';
           else if (abs(current_mean-prior_mean))/prior_mean > &yellow then status_prior='YELLOW';
           else status_prior='GREEN';
    end;
  run;


%macro freq_it (datain=,qtr=,year=,release=);
 
  %if &year=2012 %then %do;
    proc freq data=&datain;
      %do current_var = 1 %to &num_freq_vars;
          %let c_var=%scan(&freq_vars,&current_var);
          tables &c_var / out=freq_&current_var noprint missing;
      %end;
    run; 

      %do current_var = 1 %to &num_freq_vars;
          %let c_var=%scan(&freq_vars,&current_var);
     
          data freq_&current_var; 
           length variable $50.;
           length value $32.;
           set freq_&current_var;
           value=put(&c_var,32.);
           variable="&c_var";
           quarter=&qtr;
           year=&year;
           drop &c_var;
          run;
          
          proc append base=all_freqs_&year._&qtr._&release data=freq_&current_var force;
	  run;

       %end;
  %end;

  %if &year ne 2012 %then %do;
    proc freq data=&datain;
      %do current_var = 1 %to &num_all_freq_vars;
          %let c_var=%scan(&all_freq_vars,&current_var);
          tables &c_var / out=freq_&current_var noprint missing;
      %end;
 
       %do current_var = 1 %to &num_all_freq_vars;
           %let c_var=%scan(&all_freq_vars,&current_var);
     
          data freq_&current_var; 
           length variable $50.;
           length value $32.;
           set freq_&current_var;
           value=put(&c_var,32.);
           variable="&c_var";
           quarter=&qtr;
           year=&year;
           drop &c_var;
          run;
          
          proc append base=all_freqs_&year._&qtr._&release data=freq_&current_var force;
	  run;

       %end;
  %end;

%mend freq_it;

%freq_it(datain=orig.base_samp_point1pct,qtr=1,year=2012,release=0);
%freq_it(datain=prior.base_samp_point1pct,qtr=&prior_qtr,year=&prior_year,release=&prior_version);
%freq_it(datain=samp.base_samp_point1pct,qtr=&qtr,year=&year,release=&version);

  proc sort data=all_freqs_2012_1_0;
   by variable value;
  run;
  proc sort data=all_freqs_&prior_year._&prior_qtr._&prior_version;
   by variable value;
  run;
  proc sort data=all_freqs_&current_year._&current_qtr._&version;
    by variable value;
  run;
  data freqs;
    length status_orig $6. status_prior $6.;
    merge all_freqs_2012_1_0 (in=a rename=(count=orig_count percent=orig_percent))
          all_freqs_&prior_year._&prior_qtr._&prior_version (in=b rename=(count=prior_count percent=prior_percent))
          all_freqs_&current_year._&current_qtr._&version   (in=c rename=(count=current_count percent=current_percent));
    by variable value;

    if orig_percent ^= 0 then do;
       if (abs(current_percent-orig_percent))/orig_percent > &red then status_orig='RED';
           else if (abs(current_percent-orig_percent))/orig_percent > &yellow then status_orig='YELLOW';
           else status_orig='GREEN';
    end;

    if prior_percent ^= 0 then do;
       if (abs(current_percent-prior_percent))/prior_percent > &red then status_prior='RED';
           else if (abs(current_percent-prior_percent))/prior_percent > &yellow then status_prior='YELLOW';
           else status_prior='GREEN';
   end;
  run;

  proc sort data=freqs nodupkeys;
   by variable value;
  run;

%nobs(data=samp.base_samp_point1pct);
%let current_obs=&nobs;
%nobs(data=prior.base_samp_point1pct);
%let prior_obs=&nobs;
%nobs(data=orig.base_samp_point1pct);
%let orig_obs=&nobs;

 data record_counts;
   orig_obs=&orig_obs;
   prior_obs=&prior_obs;
   current_obs=&current_obs;
 run;

  ods html file="./CACdirect_QC_Report_&current_year._q&current_qtr._v&version..htm" /*style=minimal */;
  
  TITLE1 "QC REPORT for %upcase(&sample)";
    TITLE2 "RUN DATE: &REPORT_DATE";

    proc sql;

     TITLE3 "RECORD COUNTS";

     select 
           orig_obs as ORIGINAL_N label="ORIGINAL N (2012 Q1)",
           prior_obs as PRIOR_N label="PRIOR N (&prior_year &prior_qtr &prior_version)",
           current_obs as CURRENT_N label="CURRENT N (&current_year &current_qtr Version:&version)"
      from record_counts; 

     TITLE3 "VARIABLE MEANS";

     select
           variable as VARIABLE label="",
           orig_mean as ORIG_MEAN label="ORIG MEAN (2012 Q1)",
           prior_mean as PRIOR_MEAN label="PRIOR MEAN (&prior_year Q&prior_qtr V&prior_version)",
           current_mean as CURRENT_MEAN label="CURRENT MEAN (&current_year Q&current_qtr Version:&version)",
           status_orig as STATUS_ORIG,
           status_prior as STATUS_PRIOR
      from means
     order by variable;

    TITLE3 "VARIABLE DISTRIBUTIONS";
   	
    select 
          variable as VARIABLE label="",
          value as VALUE label="",
          orig_count as ORIG_COUNT label="ORIG COUNT (2012 Q1)",
          orig_percent/100 as ORIG_PERCENT format=percent5.1 label="ORIG PERCENT (2012 Q1)",
          prior_count as PRIOR_COUNT label="PRIOR COUNT (&prior_year Q&prior_qtr V&prior_version)",
          prior_percent/100 as PRIOR_PERCENT format=percent5.1 label="PRIOR PERCENT (&prior_year Q&prior_qtr V&prior_version)",
          current_count as CURRENT_COUNT label="CURRENT COUNT (&current_year Q&current_qtr Version:&version)",
          current_percent/100 as CURRENT_PERCENT format=percent5.1 label="CURRENT PERCENT (&current_year Q&current_qtr Version:&version)",
          status_orig as STATUS_ORIG,
          status_prior as STATUS_PRIOR
      from freqs
    order by variable;

  quit;

filename mail1 email to=("&email") 
                          subject="CACdirect 3.0 QC for &year Quarter &qtr Version:&version" 
                          from="webmaster@cac-group.com"
                          attach="./CACdirect_QC_Report_&year._q&qtr._v&version..htm";
        
    data _null_;
      file mail1;
      put "QC Sample Report for CACdirect 3.0 &year quarter &qtr version &version attached.";
    run;

%mend dirqc;
