%include "../.mover_includes.inc";

libname test '/project/TRAINING/NAN/TEST';

   proc sql;
      create table test.database_new as
      select a.*
      from nmsql.COGENSIA_MOVERS as a
      where a.cac_nm_file_dt = 20114;*20107;
   quit;        
