%macro geoagg(st=,codepath=,cac_read_dir_loc=);

   %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc";

   %if &cac_read_dir_loc=A %then %do;
      libname _ALL_;
      libname base      "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";
      libname geoagg     "/project/CACDIRECT/&cidatapath./GEOAGG/B";
   %end;

   %else %if &cac_read_dir_loc=B %then %do;
      libname _ALL_;
      libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/A";
      libname geoagg     "/project/CACDIRECT/&cidatapath./GEOAGG/A";
   %end;

%let geo= zip7 zip5;

*** CATEGORICAL VARIABLES - MODE FILL ***;
%let cat_vars=
CAC_ADDR_CDI
CAC_DEMO_ADULT_18_24_ENH
CAC_DEMO_ADULT_25_34_ENH
CAC_DEMO_ADULT_35_44_ENH
CAC_DEMO_ADULT_45_54_ENH
CAC_DEMO_ADULT_55_64_ENH
CAC_DEMO_ADULT_65_74_ENH
CAC_DEMO_ADULT_75_PLUS_ENH
CAC_DEMO_ADULT_UNKNOWN_ENH
CAC_DEMO_AGE_ENH
CAC_DEMO_EDUCATION_ENH
CAC_DEMO_HH_TYPE_ENH
CAC_DEMO_INCOME_ENH
CAC_DEMO_INCOME_NARROW_ENH
CAC_DEMO_KIDS_00_02_ENH
CAC_DEMO_KIDS_03_05_ENH
CAC_DEMO_KIDS_06_10_ENH
CAC_DEMO_KIDS_11_15_ENH
CAC_DEMO_KIDS_16_17_ENH
CAC_DEMO_MARITAL_STATUS
CAC_DEMO_NET_WORTH_ENH
CAC_DEMO_OCCUPATION
CAC_HOME_DWELL_TYPE
CAC_HOME_OWN
CAC_HOME_RES_LENGTH
CAC_HOME_SQ_FOOT
CAC_INT_MAIL_BUY
CAC_INT_MAIL_DONOR
CAC_INT_POL_DONOR
CAC_INT_POL_PARTY
CAC_SILH
CAC_SILH_BUY_STYLE_GROUP
CAC_SILH_ECOM
CAC_SILH_GEO
CAC_SILH_LIFESTAGE
CAC_SILH_LIFESTAGE_GROUP
CAC_SILH_LIFESTYLE
CAC_SILH_LSTYLE_MACRO
CAC_SILH_SOCIO_ECON
CAC_SILH_SOCIO_GROUP
CAC_SILH_TECH
CAC_VALUE_SCORE_ALL_ENH
CAC_VALUE_SCORE_AUTO_FINANCE_ENH
CAC_VALUE_SCORE_BANK_CARD_ENH
CAC_VALUE_SCORE_RETAIL_ENH

;

*** CONTINUOUS VARIABLES - MEAN FILL ***;
%let con_vars=

CAC_DEMO_HH_SIZE_ENH
CAC_DEMO_NARROW_INC_NUM
CAC_DEMO_NUM_ADULTS
CAC_DEMO_NUM_GENERATIONS_ENH
CAC_DEMO_NUM_KIDS_ENH
CAC_DEMO_PPL_PER_SQ_FT
CAC_DEMO_SQUARE_FEET
CAC_HOME_EQUITY_AVAIL
CAC_HOME_MARKET_VAL
CAC_HOME_MTG
CAC_HOME_MTG_AMT_ORIG
CAC_HOME_MTG_SECOND
CAC_HOME_PRICE_PER_SQ_FT
CAC_HOME_SALE_PRICE
CAC_HOME_SQ_FOOT_NUM
CAC_HOME_VALUATION_ENH
CAC_SILH_BUY_STYLE_1
;


%let ord_vars=
CAC_SILH_BUY_STYLE_RANK_1
CAC_SILH_BUY_STYLE_RANK_2
CAC_SILH_BUY_STYLE_RANK_3
CAC_SILH_BUY_STYLE_RANK_4
CAC_SILH_BUY_STYLE_RANK_5
CAC_SILH_BUY_STYLE_RANK_6
CAC_SILH_DIG_INF
CAC_SILH_LOYAL
CAC_SILH_PRICE
CAC_SILH_SOCIAL
;

*** BINARY VARIABLES - =1 IF AREA MEAN > 0.50 ***;
%let bin_vars=

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
CAC_CRED_OIL
CAC_CRED_SPEC_APPAREL
CAC_CRED_SPORT
CAC_CRED_STD_RETAIL
CAC_CRED_STD_SPECIALTY
CAC_CRED_TRAVEL
CAC_CRED_TV_MAIL_ORD
CAC_CRED_VISA
CAC_CRED_WAREHOUSE
CAC_DEMO_KIDS_ENH
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


;

%let bin_labels=%nrstr(
American Express Credit Card~
Any Credit Card~
Other Credit Auto Loans~
Bankcard~
Catalog Showroom Credit Card~
Computer Electronic Credit Card~
Debit Card~
Other Credit Education Student Loans~
Other Credit Financial Services Insurance~
Finance Credit Card~
Other Credit Financial Services Banking~
Other Credit Financial Services Installment~
Credit Active~
Furniture Credit Card~
Grocery Credit Card~
Upscale Spec Retail Card~
Upscale Retail Credit Card~
Home Improvement Credit Card~
Other Credit Mortgage Home Mortgage~
Home Office Supply Credit Card~
Other Credit Leasing~
Low End Department Store Credit Card~
Main Street Retail Credit Card~
Mastercard Credit Card~
Miscellaneous Credit Card~
Oil Gas Credit Card~
Specialty Apparel Credit Card~
Sporting Goods Credit Card~
Standard Retail Card~
Standard Specialty Card~
Travel Entertainment Creditcard~
Tv Mail Order Credit Card~
Visa Credit Card~
Membership Warehouse Credit Card~
Presence of Children Enhanced~
Collectibles~
Fitness Exercise~
Mail Order Magazines All~
Mail Order Womens Plus All~
Christian Or Gospel All~
Classical All~
Country All~
Jazz All~
Music Any All~
R And B Music All~
Rock N Roll All~
Nutrition And Diet All~
Skiing Snowboarding~
Vitamins And Supplements All~
Online Household All~
Swimming Pool All~
Hunting Big Game All~
Nascar All~
Running Jogging All~
Yoga Pilates All~
Business Travel All~
Cruise Ship Vacation All~
Leisure Travel All~
Sports And Recreation~
Timeshare All~
Traveler All~
Walking For Health~
Own A Cat~
Own A Dog~
Pets~
Electronics~
Science Technology~
Investments~
Collectibles Art Antique~
Any Mail Order~
Home Furnishing Mail Order~
Videos Dvd Mail Order~
Self Improvement Courses~
Sewing Knitting~
Contests Sweepstakes~
Crafts~
Cultural Arts Events~
Gardening~
Career Advancement Courses~
Bible Devotional~
Weight Control~
International Travel~
Usa Travel~
Home Improvement Diy~
Motorcycle Riding~
Donate To Charitable Causes~
Fashion~
Golf~
Hunting Shooting~
Rv Travel~
Books Reading~
Gourmet Foods~
Photography~
Wines~
Gambling~
Natural Foods~
Grandchildren~
Baking All~
Bird Feeding Watching All~
Cigar Smoking All~
Cooking All~
Automotive Work~
Hobbies Any All~
Home Study Courses All~
Quilting All~
Scrapbooking All~
Woodworking All~
Best Selling Fiction All~
Books Reading All~
Childrens Books All~
Cooking Culinary All~
Country Lifestyle All~
Boating Sailing~
Entertainment All~
Interior Decorating All~
Medical Or Health All~
Military All~
Romance All~
World News All~
Donor Active Military All~
Donor Alzheimers All~
Donor Animal Welfare All~
Donor Arts Or Cultural All~
Camping Hiking~
Donor Cancer All~
Donor Catholic All~
Donor Childrens All~
Donor Humanitarian All~
Donor Native American All~
Donor Other Religious All~
Donor Political Conservative All~
Donor Political Liberal All~
Donor Veteran All~
Donor World Relief All~
Cycling~
Wildlife Environmental Causes All~
Collectibles Dolls All~
Collectibles Figurines All~
Collectibles Stamps All~
Collectibles Coin All~
Burial Insurance All~
Insurance All~
Juvenile Life Insurance All~
Life Insurance All~
Medicare Coverage All~
Fishing~
Mutual Funds All~
Stocks Or Bonds All~
Mail Order Apparel All~
Mail Order Big & Tall All~
Mail Order Books All~
Mail Order Childrens Products All~
Mail Order Food All~
Mail Order Gifts All~
Mail Order Health And Beauty Products All~
Mail Order Jewelry All~)
;




   data &st;
      set base.base_demo_&st. ( keep=&cat_vars &con_vars &bin_vars &ord_vars 
                                 cac_addr_zip cac_addr_zip4 cac_addr_state 
                                 cac_prod_active_flag where=(cac_prod_active_flag=1 and cac_addr_zip~=''));
   
      if NOT missing(cac_addr_zip4) then zip7=cac_addr_zip||substr(cac_addr_zip4,1,2);
      zip5 = compress(CAC_ADDR_ZIP);
      scf = compress(substr(CAC_ADDR_ZIP,1,3));

      /******* CAC_DEMO_NUM_GENERATIONS_ENH is not numeric ************/
      _CAC_DEMO_NUM_GENERATIONS_ENH=CAC_DEMO_NUM_GENERATIONS_ENH*1;
      DROP CAC_DEMO_NUM_GENERATIONS_ENH;
      RENAME _CAC_DEMO_NUM_GENERATIONS_ENH=CAC_DEMO_NUM_GENERATIONS_ENH;
      label _CAC_DEMO_NUM_GENERATIONS_ENH='Number of Generations in Household Enhanced';
   run;




*** CATEGORICAL VARIBLES ***;


      proc freq data=&st NOPRINT ; 
         %do j=1 %to %sysfunc(countw(&cat_vars));
         %do i=1 %to %sysfunc(countw(&geo));
            tables %scan(&geo,&i) * %scan(&cat_vars,&j) / nopercent list missing out = out_&i._&j;
         %end;
         %end;
      run;

      %do j=1 %to %sysfunc(countw(&cat_vars));
      %do i=1 %to %sysfunc(countw(&geo));
         proc sort data=out_&i._&j; by %scan(&geo,&i) DESCENDING count; run;
         proc sort data=out_&i._&j (drop=count percent) nodupkey; by %scan(&geo,&i); run;

      %end;
      %end;

   %do i=1 %to %sysfunc(countw(&geo));
   data cat_%scan(&geo,&i);
      merge %do j=1 %to %sysfunc(countw(&cat_vars));
        out_&i._&j 
      %end;;
      by %scan(&geo,&i);
   run;

   proc sort data=cat_%scan(&geo,&i);
      by %scan(&geo,&i);
   run;
   %end;



*** CONTINUOUS VARIABLES ***;

   %do i=1 %to %sysfunc(countw(&geo));
   proc means data=&st  noprint;
      var &con_vars;
      class %scan(&geo,&i);
      output out=con_%scan(&geo,&i);; 
   run;

   data con_%scan(&geo,&i) (keep=%scan(&geo,&i) &con_vars);
      set con_%scan(&geo,&i) (keep=%scan(&geo,&i) _type_ _stat_ &con_vars. where=(_type_=1 and _stat_="MEAN"));
      %do k=1 %to %sysfunc(countw(&con_vars));
         if %scan(&con_vars,&k)^=cac_demo_ppl_per_sq_ft and %scan(&con_vars,&k)^=cac_silh_buy_style_1 then %scan(&con_vars,&k)=round(%scan(&con_vars,&k),1);
      %end;
   run;

   proc sort data=con_%scan(&geo,&i); by %scan(&geo,&i); run;
   %end;


*** ORDINAL CATEGORICAL VARIABLES ***;

   %do i=1 %to %sysfunc(countw(&geo));
   proc means data=&st  MEDIAN noprint;
      var &ord_vars;
      class %scan(&geo,&i);
      output out=ord_%scan(&geo,&i);; 
   run;

   data ord_%scan(&geo,&i) (keep=%scan(&geo,&i) &ord_vars);
      set ord_%scan(&geo,&i) (keep=%scan(&geo,&i) _type_ _stat_ &ord_vars. where=(_type_=1 and _stat_="MEDIAN"));
      %do k=1 %to %sysfunc(countw(&ord_vars));
         %scan(&ord_vars,&k)=floor(%scan(&ord_vars,&k));
      %end;
   run;

   proc sort data=ord_%scan(&geo,&i); by %scan(&geo,&i); run;
   %end;



*** BINARY VARIABLES ***;

*** BINARY VARIABLES ***;
   %do i=1 %to %sysfunc(countw(&geo));
      proc sort data=&st (keep=%scan(&geo,&i) &bin_vars) out=bin_%scan(&geo,&i); by %scan(&geo,&i); run;

      data bin_%scan(&geo,&i);
         set bin_%scan(&geo,&i);
         by %scan(&geo,&i);
         array oldbin &bin_vars;
         array newbin %do l=1 %to %sysfunc(countw(&bin_vars)); r_%scan(&bin_vars,&l) %end;;
         array finbin %do l=1 %to %sysfunc(countw(&bin_vars)); f_%scan(&bin_vars,&l) %end;;
         retain cnt newbin;
         if first.%scan(&geo,&i) then do;
            cnt=0;
            do over newbin;
	       newbin=0;
            end;
         end;
         cnt+1;
         do over newbin;
            newbin+oldbin;
         end;
         if last.%scan(&geo,&i);
         do over newbin;
            if newbin/cnt > .5 then finbin=1; 
            else finbin=0;
         end; 
         DROP &bin_vars r_: cnt;
      run;   
         
   proc sort data=bin_%scan(&geo,&i); by %scan(&geo,&i); run;

   %end;


*** MERGE CAT CON BIN AND ORD VARIABLES TOGETHER ***;

   %do i=1 %to %sysfunc(countw(&geo));
   data &st._%scan(&geo,&i);
      merge cat_%scan(&geo,&i) (in=a)
            con_%scan(&geo,&i) (in=b)
    	    bin_%scan(&geo,&i) (in=c)
            ord_%scan(&geo,&i) (in=d);
      by %scan(&geo,&i);
      if a or b or c or d;
      RENAME
         %do l=1 %to %sysfunc(countw(&bin_vars));
             f_%scan(&bin_vars,&l)=%scan(&bin_vars,&l)
         %end;;
      LABEL
            %do m=1 %to %sysfunc(countw(&bin_vars));
                f_%scan(&bin_vars,&m)="%scan(&bin_labels,&m,~)"
            %end;; 
   run;
   %end;

   proc sort data=&st._zip7 NODUPKEY; by zip7; run;
   proc sort data=&st._zip5 NODUPKEY; by zip5; run;
   
*** STACK DIFFERENT GEO LEVELS TOGETHER ***;

   data geoagg.geo_demo_&st ;
      format MATCH_ZIP2 $7. CAC_ADDR_GEO_MATCH_LEVEL $5.;
      length MATCH_ZIP2 $7  CAC_ADDR_GEO_MATCH_LEVEL $5 ;
         set &st._zip7 (in=a where=(zip7 ~='')) 
             &st._zip5 (in=b where=(zip5 ~=''));
      if a then do;
         CAC_ADDR_GEO_MATCH_LEVEL='ZIP+2';
         MATCH_ZIP2=zip7;
      end;
      else if b then do;
         CAC_ADDR_GEO_MATCH_LEVEL='ZIP';
         MATCH_ZIP2 =compress(zip5||'XX');
      end;
      label CAC_ADDR_GEO_MATCH_LEVEL='Level of Geo Aggregation' MATCH_ZIP2='Geomatching ZIP/ZIP+2';
      drop zip:; 

      /********************** Variables that need different treatment **************/
      cac_int_num = sum(of cac_int_1-cac_int_121);
      IF CAC_DEMO_NUM_KIDS_ENH > 0 then CAC_DEMO_KIDS_ENH=1; else CAC_DEMO_KIDS_ENH=0; 
      cac_silh_super=substr(cac_silh,1,1);
      CAC_SILH_SOC_INF=(CAC_SILH_SOCIAL in (1,2) OR CAC_SILH_DIG_INF in (1,2)) ; 

      label CAC_SILH_SOC_INF='CAC Group Silhouettes 3D: Social Influencer';
      label cac_silh_super='CAC Group Silhouettes 3D: Super Group';
      label cac_int_num='Number Of Individual HH Interests';
      /***************************************************************************/
   run;

   proc sort data=geoagg.geo_demo_&st NODUPKEY;
      by MATCH_ZIP2;
   run;

   title "-------- Geoaggregation Level for &st------------";
   proc freq data=geoagg.geo_demo_&st;
      tables CAC_ADDR_GEO_MATCH_LEVEL  / missing;
   run;

   proc datasets lib=work nolist;
      delete cat_&geo con_&geo bin_&geo &st;
   quit;


%mend geoagg;
