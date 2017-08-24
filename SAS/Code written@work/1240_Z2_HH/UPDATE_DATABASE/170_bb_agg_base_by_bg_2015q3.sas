*;
* 170_bb_agg_base_by_bg.sas;
* Aggregates base demo by census block group to create aggregates for buzz board profile app;
*;

* LOCATION OF CURRENT SQL DATABASE SUPPORTING THE PROFILE APP;
* PEER 1 CAC_DIRECT;
/*
%let user=mmattingly;
%let pw=BearDown_15;
%let server=216.157.38.64;
libname peer1 ODBC NOPROMPT="UID=&user;pwd=&pw;DSN=MSSQL;SERVER=&server;DATABASE=CAC_DIRECT;" readbuff=10000 insertbuff=10000 dbcommit=10000;
*/

proc format;
value $silh_value
'A1'=1
'A2'=2
'A3'=3
'A4'=4
'A5'=5
'A6'=6
'B1'=7
'B2'=8
'B3'=9
'B4'=10
'C1'=11
'C2'=12
'C3'=13
'C4'=14
'C5'=15
'D1'=16
'D2'=17
'D3'=18
'D4'=19
'D5'=20
'E1'=21
'E2'=22
'E3'=23
'E4'=24
'F1'=25
'F2'=26
'F3'=27
'F4'=28
'F5'=29
'F6'=30
'F7'=31
'G1'=32
'G2'=33
'G3'=34
'H1'=35
'H2'=36
'H3'=37
'H4'=38
'H5'=39
'I1'=40
'I2'=41
'I3'=42
'I4'=43
'I5'=44
'J1'=45
'J2'=46
'J3'=47
'J4'=48
'K1'=49
'K2'=50
'K3'=51
'K4'=52
'L1'=53
'L2'=54
'L3'=55
'L4'=56
'L5'=57
'L6'=58
'XX'=59
;
run;


%macro aggregation(cac_read_dir_loc=,sort_var=,by_var=,merge_field=,testobs=,codepath=PROD); 
  
   %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc";

   %if &cac_read_dir_loc=A %then %do;                                       *** IF CURRENT PRODUCTION DATA IS IN A THEN WRITE DATA FOR NEW QUARTER TO B;
      libname _ALL_;
      libname base      "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";
      libname for_rts  "/project/CACDIRECT/&cidatapath./REAL_TIME/B";
      libname cen2010 "/project17/CENSUS/DATA/2010/FINAL";
   %end;

   %else %if &cac_read_dir_loc=B %then %do;                                        *** IF CURRENT PRODUCTION DATA IS IN B THEN WRITE DATA FOR NEW QUARTER TO A;
      libname _ALL_;
      libname base      "/project/CACDIRECT/&cidatapath./BASE_DEMO/A"; 
      libname for_rts  "/project/CACDIRECT/&cidatapath./REAL_TIME/A";
      libname cen2010 "/project17/CENSUS/DATA/2010/FINAL";
   %end;

   filename file_1 "/project/CACDIRECT/&cidatapath./EXPORT/BUZZBOARD/buzzboard_cen_level.csv";
   filename file_2 "/project/CACDIRECT/&cidatapath./EXPORT/BUZZBOARD/buzzboard_cen_us_avg.csv";

   *------------------------------------------------------------------------------------------------------------------------------------*;
   *------ Define States and get state count -------------------------------------------------------------------------------------------*;
   *------------------------------------------------------------------------------------------------------------------------------------*;
   %let states = AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT 
                 NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY DC;
   %***let states = VT; 

   data _NULL_; array x(*) &states; call symput("numstates",dim(x)); run;

   %do ipb = 1 %to &numstates;
      *------------------------------------------------------------------------------------------------------------------------------------*;
      *------ Grab ConsumerIntellibase Data!!!! -------------------------------------------------------------------------------------------*;
      *------------------------------------------------------------------------------------------------------------------------------------*;
      proc sort data = base.base_demo_%scan(&states,&ipb.) (obs=&testobs
                                                            keep=cac_census_2010_county_code cac_census_2010_tract_block_grp cac_silh cac_addr_latitude cac_addr_longitude 
								 cac_silh_dig_inf cac_silh_buy_style_group cac_silh_social cac_silh_soc_inf
                                                            )
                 out = base_demo_%scan(&states,&ipb.);
         by &sort_var;
      run;

      data base_demo_%scan(&states,&ipb.) (keep=matching_field avg_lat avg_lon silh_: cac_silh_buy_style_group_3-cac_silh_buy_style_group_5 avg_cac_silh_social avg_cac_silh_dig_inf
						sum_cac_silh_social sum_cac_silh_dig_inf sum_cac_silh_soc_inf counts_hh avg_cac_silh_soc_inf);
         set base_demo_%scan(&states,&ipb.); 
         by &sort_var;
         *array silh(59) _temporary_ (1-59);
         array silh_counts (59) silh_1-silh_59 ;
         array buy_style(7) cac_silh_buy_style_group_1-cac_silh_buy_style_group_7;
         retain silh_: sum_lat sum_lon counter tot_hh sum_cac_silh_social sum_cac_silh_dig_inf sum_cac_silh_soc_inf;
         format matching_field $32.;

         if first.&by_var then do;
            sum_lat=0;
            sum_lon=0;
	    sum_cac_silh_social=0;
	    sum_cac_silh_dig_inf=0;
            sum_cac_silh_soc_inf=0;
            counter = 0;
	    counts_hh=0;
            do p=1 to 59;
               silh_counts(p)=0;
            end;
            do q=1 to 7;
               buy_style(q)=0;
	    end;
         end;
   
         if cac_addr_latitude not in (0 .) and cac_addr_longitude not in(0 .) then counter+1;
	 counts_hh+1;
         sum_lat+cac_addr_latitude;
         sum_lon+cac_addr_longitude;
	 sum_cac_silh_social+cac_silh_social;
	 sum_cac_silh_dig_inf+cac_silh_dig_inf;
         sum_cac_silh_soc_inf+cac_silh_soc_inf;

         silh_counts(put(CAC_SILH,silh_value.)+0)+1;

         %do b=1 %to 7;
            if cac_silh_buy_style_group=&b then buy_style(&b)+1; 
         %end;

      
         if last.&by_var then do;
            matching_field =compress(CAC_CENSUS_2010_COUNTY_CODE||CAC_CENSUS_2010_TRACT_BLOCK_GRP);
            avg_lat=sum_lat/counter;
            avg_lon=sum_lon/counter;
	    avg_cac_silh_social=round(sum_cac_silh_social/counts_hh,.01);
	    avg_cac_silh_dig_inf=round(sum_cac_silh_dig_inf/counts_hh,.01);
	    avg_cac_silh_soc_inf=round(sum_cac_silh_soc_inf/counts_hh,.01);

            output;
         end;
         drop p q;
      run;
      proc sort data = base_demo_%scan(&states,&ipb.);
         by &merge_field ;
      run;

      *------------------------------------------------------------------------------------------------------------------------------------*;
      *------ Grab Census Data!!!! --------------------------------------------------------------------------------------------------------*;
      *------------------------------------------------------------------------------------------------------------------------------------*;
      data cen_%scan(&states,&ipb.) (drop   = cen_hsevac_4 cen_hhrel_4 cen_hsevac_4 cen_hhrel_4 county tract blkgrp cen_hsevac_4 cen_hhrel_4 
                                     rename = (cen_popage_2 = median_age cen_hhinc_2=median_income));
         set cen2010.cac_census_final_%scan(&states,&ipb.) (keep= county blkgrp tract cen_count_pop cen_count_fam cen_count_hh cen_popage_2 cen_hhinc_2 cen_hsevac_4 cen_hhrel_4);
         format matching_field $32.;
         matching_field =compress(COUNTY||TRACT||BLKGRP,'.," "');
	 with_children = cen_hhrel_4;
	 owner_occupied = cen_hsevac_4;
         *with_children  = round(cen_count_hh*cen_hsevac_4,1);
         *owner_occupied = round(cen_count_hh*cen_hhrel_4 ,1);
      run;
      proc sort NODUPKEY  data = cen_%scan(&states,&ipb.) ;
         by &merge_field  ;
      run;
      *------------------------------------------------------------------------------------------------------------------------------------*;
      *------ Put intellibase rollup and cen together -------------------------------------------------------------------------------------*;
      *------------------------------------------------------------------------------------------------------------------------------------*;
      data for_buzzboard_%scan(&states,&ipb.);
         merge cen_%scan(&states,&ipb.)       (in=a)
               base_demo_%scan(&states,&ipb.) (in=b);
         by &merge_field ;
         if a and b;
         state = "%scan(&states,&ipb.)";
      run;


   %end; *numstates loop;
   *------------------------------------------------------------------------------------------------------------------------------------*;
   *------ Stack the States and do some Diags ------------------------------------------------------------------------------------------*;
   *------------------------------------------------------------------------------------------------------------------------------------*;
   
   data for_rts.buzzboard_cen_level;
      set %do v = 1 %to &numstates; for_buzzboard_%scan(&states,&v.) %end; ;
      if matching_field="" then delete;
      uni_matching_field=compbl(matching_field||state);
   run;
   title '--------------------  for_rts.buzzboard_cen_level --------------------------------------';
   proc means data =  for_rts.buzzboard_cen_level ;
   run;
   proc freq data =  for_rts.buzzboard_cen_level ;
      table state;
   run;
   proc print data =  for_rts.buzzboard_cen_level (obs=100);
   run;

   data _null_ ;
      set for_rts.buzzboard_cen_level;
      file file_1 dsd dlm=',' lrecl=20000;
      put CEN_COUNT_FAM CEN_COUNT_HH CEN_COUNT_POP avg_cac_silh_dig_inf avg_cac_silh_soc_inf avg_cac_silh_social avg_lat avg_lon 
          cac_silh_buy_style_group_3 cac_silh_buy_style_group_4 cac_silh_buy_style_group_5 counts_hh matching_field median_age 
          median_income owner_occupied silh_1 silh_2 silh_3 silh_4 silh_5 silh_6 silh_7 silh_8 silh_9 silh_10 silh_11 silh_12 
          silh_13 silh_14 silh_15 silh_16 silh_17 silh_18 silh_19 silh_20 silh_21 silh_22 silh_23 silh_24 silh_25 silh_26 silh_27 
          silh_28 silh_29 silh_30 silh_31 silh_32 silh_33 silh_34 silh_35 silh_36 silh_37 silh_38 silh_39 silh_40 silh_41 silh_42 
          silh_43 silh_44 silh_45 silh_46 silh_47 silh_48 silh_49 silh_50 silh_51 silh_52 silh_53 silh_54 silh_55 silh_56 silh_57 
          silh_58 silh_59 state sum_cac_silh_dig_inf sum_cac_silh_soc_inf sum_cac_silh_social uni_matching_field with_children;
   run;

   *------------------------------------------------------------------------------------------------------------------------------------*;
   *------ Build the US Average table to drive indices ---------------------------------------------------------------------------------*;
   *------------------------------------------------------------------------------------------------------------------------------------*;
   data for_rts.buzzboard_cen_us_avg (keep=&merge_field avg:);
      set for_rts.buzzboard_cen_level end = eof;
      array tots (*) t_with_children t_owner_occupied  t_median_age t_median_income;
      array rows (*) with_children owner_occupied median_age median_income;
      array avgs (*) avg_with_children avg_owner_occupied avg_median_age avg_median_income;

      array s_rows (*) silh_1-silh_59  ;
      array s_tots (*) s1-s59  ;
      array s_avgs (*) avg_s1-avg_s59;

      array b_rows (*) cac_silh_buy_style_group_3-cac_silh_buy_style_group_5;
      array b_tots (*) b3-b5;
      array b_avgs (*) avg_buy_style_group_3-avg_buy_style_group_5;




      retain tot_hh s1-s59 b3-b5 t_: N  t_with_children t_owner_occupied t_median_age t_median_income 0 tot_counts_hh tot_social tot_dig_inf tot_soc_inf;

      tot_counts_hh+counts_hh;
      tot_hh + cen_count_hh;
      do i = 1 to dim(tots);
         tots(i) = tots(i) + (cen_count_hh*rows(i));
      end;
      do i = 1 to dim(s_rows);
         s_tots(i) = s_tots(i) + s_rows(i);
      end;
      do i = 1 to dim(b_rows);
         b_tots(i) = b_tots(i) + b_rows(i);
      end;

      tot_social+sum_cac_silh_social;
      tot_dig_inf+sum_cac_silh_dig_inf;
      tot_soc_inf+sum_cac_silh_soc_inf;

      if eof then do;
         do j = 1 to dim(tots);
            avgs(j) = tots(j) /tot_hh;
         end;
         do k = 1 to dim(s_rows);
            s_avgs(k) = s_tots(k) / sum(of s1-s59);
         end;
         do t = 1 to dim(b_rows);
            b_avgs(t) = b_tots(t) / sum(of b3-b5);
         end;
         avg_median_income = avg_median_income *1000;
	 avg_cac_silh_social=tot_social/tot_counts_hh;
	 avg_cac_silh_dig_inf=tot_dig_inf/tot_counts_hh;
	 avg_cac_silh_soc_inf=tot_soc_inf/tot_counts_hh;
         output;
      end;
   run;
   title '--------------------  for_rts.buzzboard_cen_us_avg --------------------------------------';
   proc means data =  for_rts.buzzboard_cen_us_avg ;
   run;
   proc print data =  for_rts.buzzboard_cen_us_avg (obs=100);
   run; title;

   data _null_;
      set  for_rts.buzzboard_cen_us_avg;
      file file_2 dsd dlm=',' lrecl=20000;
      put avg_buy_style_group_3 avg_buy_style_group_4 avg_buy_style_group_5 avg_cac_silh_dig_inf avg_cac_silh_soc_inf 
          avg_cac_silh_social avg_lat avg_lon avg_median_age avg_median_income avg_owner_occupied avg_s1 avg_s2 avg_s3 
          avg_s4 avg_s5 avg_s6 avg_s7 avg_s8 avg_s9 avg_s10 avg_s11 avg_s12 avg_s13 avg_s14 avg_s15 avg_s16 avg_s17 avg_s18
          avg_s19 avg_s20 avg_s21 avg_s22 avg_s23 avg_s24 avg_s25 avg_s26 avg_s27 avg_s28 avg_s29 avg_s30 avg_s31 avg_s32 avg_s33
          avg_s34 avg_s35 avg_s36 avg_s37 avg_s38 avg_s39 avg_s40 avg_s41 avg_s42 avg_s43 avg_s44 avg_s45 avg_s46 avg_s47 avg_s48 
          avg_s49 avg_s50 avg_s51 avg_s52 avg_s53 avg_s54 avg_s55 avg_s56 avg_s57 avg_s58 avg_s59 avg_with_children matching_field;
   run;



%mend aggregation;
%aggregation(cac_read_dir_loc=B,sort_var= cac_census_2010_county_code cac_census_2010_tract_block_grp, by_var  = cac_census_2010_tract_block_grp, merge_field = matching_field, testobs = max, codepath=DEVELOPMENT/1240_Z2_HH);
