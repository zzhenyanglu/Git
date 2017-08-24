*;
* 180_bb_agg_base_by_zip.sas;
* Aggregates base demo to ZIP to create aggregates for buzz board profile app;
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

   filename file_3 "/project/CACDIRECT/&cidatapath./EXPORT/BUZZBOARD/buzzboard_zip_level.csv";

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
                                                            keep=cac_addr_zip cac_census_2010_county_code cac_census_2010_tract_block_grp cac_silh cac_addr_latitude cac_addr_longitude 
								 cac_silh_dig_inf cac_silh_buy_style_group cac_silh_social cac_silh_soc_inf
							    )
                 out = base_demo_%scan(&states,&ipb.);
         by &sort_var;
      run;

      data base_demo_%scan(&states,&ipb.) (keep=matching_field avg_lat avg_lon silh_: cac_silh_buy_style_group_3-cac_silh_buy_style_group_5 avg_cac_silh_social avg_cac_silh_dig_inf
						sum_cac_silh_social sum_cac_silh_dig_inf counts_hh sum_cac_silh_soc_inf avg_cac_silh_soc_inf);
         set base_demo_%scan(&states,&ipb.); 
         by &sort_var;
         *array silh(59) _temporary_ (1-59);
         array silh_counts (59) silh_1-silh_59 ;
         array buy_style(7) cac_silh_buy_style_group_1-cac_silh_buy_style_group_7;
         retain silh_: sum_lat sum_lon counter tot_hh sum_cac_silh_social sum_cac_silh_dig_inf sum_cac_silh_soc_inf;

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
            matching_field =cac_addr_zip;
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
      proc sort data=cen2010.cac_census_xref_%scan(&states,&ipb.) out=census_xref_%scan(&states,&ipb.);
         by cac_census_id;
      run;

      proc  sort NODUPKEY data=cen2010.cac_census_final_%scan(&states,&ipb.) out=census_%scan(&states,&ipb.);
         by cac_census_id;
      run;

      data cen_%scan(&states,&ipb.) (drop   = cac_census_id cac_addr_zip cen_hsevac_4 cen_hhrel_4 cen_hsevac_4 cen_hhrel_4 county tract blkgrp cen_hsevac_4 cen_hhrel_4 
                                     rename = (cen_popage_2 = median_age cen_hhinc_2=median_income));
         merge census_%scan(&states,&ipb.)(in=a keep= cac_census_id county blkgrp tract cen_count_pop cen_count_fam cen_count_hh cen_popage_2 cen_hhinc_2 cen_hsevac_4 cen_hhrel_4)
	       census_xref_%scan(&states,&ipb.)(in=b);
         by cac_census_id;
         matching_field =cac_addr_zip;
	 with_children  = cen_hhrel_4;
	 owner_occupied = cen_hsevac_4;
      run;
      proc sort NODUPKEY  data = cen_%scan(&states,&ipb.)(where=(CAC_ADDR_ZIP4=""));
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

      *------------------------------------------------------------------------------------------------------------------------------------*;
      *------ Dump the Junk ---------------------------------------------------------------------------------------------------------------*;
      *------------------------------------------------------------------------------------------------------------------------------------*;
      proc datasets NOLIST library = work;
         delete  cen_%scan(&states,&ipb.) base_demo_%scan(&states,&ipb.);
      run;

   %end; *numstates loop;
   *------------------------------------------------------------------------------------------------------------------------------------*;
   *------ Stack the States and do some Diags ------------------------------------------------------------------------------------------*;
   *------------------------------------------------------------------------------------------------------------------------------------*;
   
   data for_rts.buzzboard_zip_level;
      set %do v = 1 %to &numstates; for_buzzboard_%scan(&states,&v.) %end; ;
      if matching_field="" then delete;
   run;
   title '--------------------  for_rts.buzzboard_zip_level --------------------------------------';
   proc means data =  for_rts.buzzboard_zip_level ;
   run;
   proc freq data =  for_rts.buzzboard_zip_level ;
      table state;
   run;
   proc print data =  for_rts.buzzboard_zip_level (obs=100);
   run;

   data _null_;
      set  for_rts.buzzboard_zip_level;
      file file_3 dsd dlm=',' lrecl=20000;
      put CAC_ADDR_ZIP4 CEN_COUNT_FAM CEN_COUNT_HH CEN_COUNT_POP avg_cac_silh_dig_inf avg_cac_silh_soc_inf avg_cac_silh_social avg_lat avg_lon 
          cac_silh_buy_style_group_3 cac_silh_buy_style_group_4	cac_silh_buy_style_group_5 counts_hh matching_field median_age median_income 
          owner_occupied silh_1 silh_2 silh_3 silh_4 silh_5 silh_6 silh_7 silh_8 silh_9 silh_10 silh_11 silh_12 silh_13 silh_14 silh_15 
          silh_16 silh_17 silh_18 silh_19 silh_20 silh_21 silh_22 silh_23 silh_24 silh_25 silh_26 silh_27 silh_28	
          silh_29 silh_30 silh_31 silh_32 silh_33 silh_34 silh_35 silh_36 silh_37 silh_38 silh_39 silh_40 silh_41 silh_42 silh_43 silh_44	
          silh_45 silh_46 silh_47 silh_48 silh_49 silh_50 silh_51 silh_52 silh_53 silh_54 silh_55 silh_56 silh_57 silh_58 silh_59 state	
          sum_cac_silh_dig_inf sum_cac_silh_soc_inf sum_cac_silh_social with_children;
   run;


%mend aggregation;
