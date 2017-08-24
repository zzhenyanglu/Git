**************************************************************************;
libname sar '/project/VIASAT/DATA/SARPINOS';
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;

%macro blah;
%let ziplist = 55107 55120 55076 55118 55075 55101;
*RSS 31MAR2015 - Removed following rows from carrier_routes base csv:
STORE_NUMBER	STORE_NAME	ZIP	CARRIER_ROUTE
62	Eagan Sarpinos	55118	C020
62	Eagan Sarpinos	55118	C026
62	Eagan Sarpinos	55120	C003
62	Eagan Sarpinos	55120	C009
62	Eagan Sarpinos	55120	C041
62	Eagan Sarpinos	55120	C069
;
*** PULL ZIP9 AND CARRIER ROUTE FROM BASE DEMO ***;

proc sort nodupkey data = base.base_demo_mn (keep= cac_addr_zip cac_addr_zip4 CAC_ADDR_CARRIER_RT cac_addr_latitude where=(CAC_ADDR_CARRIER_RT ~='' and cac_addr_zip4 ~='' and cac_addr_zip in (&ziplist) and cac_addr_latitude ^in(.,0))) out=store_95;
   by cac_addr_zip cac_addr_carrier_rt;
run;

data store_95;
   set store_95;
   store_number=95;
   store_name="West Saint Paul";
run;

data _null_;
   set store_95;
   file './sarpinos_store_carrier_routes_95.csv' delimiter=',' dsd lrecl=10000;
   if _n_=1 then put 'STORE_NUMBER,STORE_NAME,ZIP,CARRIER_ROUTE';
   put STORE_NUMBER STORE_NAME CAC_ADDR_ZIP CAC_ADDR_CARRIER_RT;
run;

%mend blah;
%blah;


