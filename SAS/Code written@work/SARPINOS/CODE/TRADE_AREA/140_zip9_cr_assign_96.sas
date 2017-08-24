**************************************************************************;
libname sar '/project/VIASAT/DATA/SARPINOS';
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;

%macro blah;
%let ziplist = 33301 33304 33305 33306 33316 33315 33312 33311 33308 33334 33004;
*** PULL ZIP9 AND CARRIER ROUTE FROM BASE DEMO ***;
proc sort nodupkey data = base.base_demo_fl (keep= cac_addr_zip cac_addr_zip4 CAC_ADDR_CARRIER_RT cac_addr_latitude where=(CAC_ADDR_CARRIER_RT ~='' and cac_addr_zip4 ~='' and cac_addr_zip in (&ziplist) and cac_addr_latitude ^in(.,0))) out=store_96;
   by cac_addr_zip cac_addr_carrier_rt;
run;

data store_96;
   set store_96;
   store_number=96;
   store_name="Fort Lauderdale";
run;

data _null_;
   set store_96;
   file './sarpinos_store_carrier_routes_96.csv' delimiter=',' dsd lrecl=10000;
   if _n_=1 then put 'STORE_NUMBER,STORE_NAME,ZIP,CARRIER_ROUTE';
   put STORE_NUMBER STORE_NAME CAC_ADDR_ZIP CAC_ADDR_CARRIER_RT;
run;

%mend blah;
%blah;








