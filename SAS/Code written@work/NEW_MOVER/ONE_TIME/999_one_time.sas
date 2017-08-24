%include "./.mover_includes.inc";

   proc sql;
      title 'NUMBER OF RECORDS OVERLAP';
      select count(distinct a.CAC_NM_ID) into :overlap
      from nmsql.COGENSIA_MOVERS as a, nmsas.update_valuescore_&tdate as b
      where a.CAC_NM_CONTRACTED_ADDR = b.CAC_NM_CONTRACTED_ADDR
        and a.CAC_NM_FIPS_STATE_CODE = b.CAC_NM_FIPS_STATE_CODE
        and a.CAC_NM_ZIP_CODE = b.CAC_NM_ZIP_CODE
        and (a.CAC_NM_CONTRACTED_NAME = b.CAC_NM_CONTRACTED_NAME
          or a.CAC_NM_CONTRACTED_NAME = b.CAC_NM_CONTRACTED_NAME_2);
   quit;        

   %put NUMBER OF RECORDS OVERLAP: &overlap;


proc sort data=nmsql.COGENSIA_MOVERS out=movers;
   by CAC_NM_CONTRACTED_ADDR CAC_NM_CONTRACTED_NAME cac_nm_fips_state_code cac_nm_zip_code;
run;

proc sort data=nmsas.update_valuescore_&tdate nodupkey out=update_1;
   by CAC_NM_CONTRACTED_ADDR CAC_NM_CONTRACTED_NAME cac_nm_fips_state_code cac_nm_zip_code;
run;

data movers (drop=new_cac_nm_target_valuescore);
   merge movers (in=a)
         update_1 (in=b drop=CAC_NM_CONTRACTED_NAME_2);
   by CAC_NM_CONTRACTED_ADDR CAC_NM_CONTRACTED_NAME cac_nm_fips_state_code cac_nm_zip_code;
   format update_flag 1.;
   if a and b then do;
      cac_nm_target_valuescore = new_cac_nm_target_valuescore;
      update_flag = 1;
   end;
   if a then output movers;
run;

proc freq data=movers;table update_flag;run;

proc sort data=nmsas.update_valuescore_&tdate nodupkey out=update_2;
   by CAC_NM_CONTRACTED_ADDR CAC_NM_CONTRACTED_NAME_2 cac_nm_fips_state_code cac_nm_zip_code;
run;

data movers (drop=new_cac_nm_target_valuescore);
   merge movers (in=a)
         update_2 (in=b drop=CAC_NM_CONTRACTED_NAME rename=(CAC_NM_CONTRACTED_NAME_2 = CAC_NM_CONTRACTED_NAME));
   by CAC_NM_CONTRACTED_ADDR CAC_NM_CONTRACTED_NAME cac_nm_fips_state_code cac_nm_zip_code;
   format update_flag 1.;
   if a and b then do;
      cac_nm_target_valuescore = new_cac_nm_target_valuescore;
      update_flag = 1;
   end;
   if a then output movers;
run;

proc freq data=movers;table update_flag;run;

data movers;
   set movers (drop=update_flag);
run;

proc contents data=movers;run;




