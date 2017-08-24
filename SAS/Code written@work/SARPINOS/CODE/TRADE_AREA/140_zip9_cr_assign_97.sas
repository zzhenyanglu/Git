**************************************************************************;
libname sar '/project/VIASAT/DATA/SARPINOS';
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;

%macro blah;
%let ziplist = 30303 30308 30305 30307 30306 30309 30310 30312 30313 30314 30318 30324 30327 30363;
*** PULL ZIP9 AND CARRIER ROUTE FROM BASE DEMO ***;

proc sort nodupkey data = base.base_demo_ga (keep= cac_addr_zip cac_addr_zip4 CAC_ADDR_CARRIER_RT cac_addr_latitude where=(CAC_ADDR_CARRIER_RT ~='' and cac_addr_zip4 ~='' and cac_addr_zip in (&ziplist) and cac_addr_latitude ^in(.,0))) out=store_97;
   by cac_addr_zip cac_addr_carrier_rt;
run;

data store_97;
   set store_97;
   store_number=97;
   store_name="Downtown Atlanta";
run;

data _null_;
   set store_97;
   file './sarpinos_store_carrier_routes_97.csv' delimiter=',' dsd lrecl=10000;
   if _n_=1 then put 'STORE_NUMBER,STORE_NAME,ZIP,CARRIER_ROUTE';
   put STORE_NUMBER STORE_NAME CAC_ADDR_ZIP CAC_ADDR_CARRIER_RT;
run;

%mend blah;
%blah;


