libname test '/project/TRAINING/NAN/TEST';
%include "../.mover_includes.inc";
/*
%let fdate = today()-53;

proc sql;
   create table test.this_week_database as
   select a.*
   from nmsql.COGENSIA_MOVERS as a
   where cac_nm_file_dt = &fdate;
quit;
*/




proc sort data=test.dm_only_ponp (drop=udc) nodupkey out=ponp; by zip_code state; run; *** HAVE DUPES ***;
proc sort data=test.dm_only_vs_ponp (drop=udc) nodupkey out=vs_ponp; by zip_code state; run;
proc sort data=test.obtm_only_mhp (drop=udc) nodupkey out=mhp; by zip_code state; run;
proc sort data=test.obtm_only_vs_mhp (drop=udc) nodupkey out=vs_mhp; by zip_code; run;

proc sort data=test.this_week_update out=database (rename=(cac_nm_zip_code = zip_code cac_nm_state_abbreviation = state)); by cac_nm_zip_code cac_nm_state_abbreviation;run;

data test.raw_1_update;
   merge database (in=a)
         ponp (in=b);
   by zip_code state;
   if a and b;
run;


data test.raw_2_update;
   merge database (in=a)
         vs_ponp (in=b);
   by zip_code state;
   if a and b then do;
      if cac_nm_target_valuescore in ('A' 'A1H''A2H' 'B1H' 'B2H' 'C1H' 'C2H') then output test.raw_2_update;
   end;
run;


data test.raw_3_update;
   merge database (in=a)
         mhp (in=b);
   by zip_code state;
   if a and b then do ;
      if cac_nm_area_code_with_supp_appl ~='' and cac_nm_telephone_with_supp_appl ~='' then output test.raw_3_update;
   end;
run;


data test.raw_4_update;
   merge database (in=a)
         vs_mhp (in=b);
   by zip_code state;
   if a and b then do;
      if cac_nm_target_valuescore in ('A' 'A1H''A2H' 'B1H' 'B2H' 'C1H' 'C2H') and cac_nm_area_code_with_supp_appl ~='' and cac_nm_telephone_with_supp_appl ~='' then output test.raw_4_update;
   end;
run;
