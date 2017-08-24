**************************************************************************;
libname sar '/project/VIASAT/DATA/SARPINOS';
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;

%macro blah;
%let st=il ia mn tx ks mo;

%do i=1 %to 6;
data %scan(&st,&i);
   format zip9 $9.;
   set base.base_demo_%scan(&st,&i) (keep= cac_addr_zip cac_addr_zip4 CAC_ADDR_CARRIER_RT where=(CAC_ADDR_CARRIER_RT ~='' and cac_addr_zip4 ~=''));
   zip9=compbl(compress(cac_addr_zip)||compress(cac_addr_zip4));
   zip_cr=compbl(compress(cac_addr_zip)||compress(CAC_ADDR_CARRIER_RT));
   drop cac_addr_zip cac_addr_zip4;
run;

proc sort data=%scan(&st,&i) nodupkey; by zip_cr zip9; run;

proc print data=%scan(&st,&i) (obs=10);

%end;

data stack;
   set
   %do i=1 %to 6;
      %scan(&st,&i) 
   %end;;
run;

proc freq data=stack; tables cac_addr_carrier_rt /list missing; run;

*** merge onto zip9 trade area file ***;

proc sort data=stack nodupkey; by zip9;         * SHOULD BE NO DUPS *;
proc sort data=sar.store_market_zip9; by zip9;

data store_xref bad;
   merge sar.store_market_zip9 (in=a drop=lat lon select_type)
         stack (in=b rename=(cac_addr_carrier_rt=carrier_rt));
   by zip9;
   zip5=substr(zip9,1,5);
   if a and not b then output bad;     * WE KNOW ABOUT 25 PERCENT OF ZIP9s are PO BOXES OR BIZ ZIP9s AND THIS IS EXPECTED *;
   if a and b then output store_xref;
run;

proc sort data=store_xref nodupkey; by STORE_NUMBER zip_cr; run;
proc sort data=store_xref nodupkey dupout=dups out=store_xref; by zip_cr; run;

proc print data=dups (obs=100);
title 'CARRIER ROUTES ASSIGNED TO MULTIPLE';
run;

%mend blah;
%blah;
endsas;











data il;
   set base.base_demo_il (keep= cac_addr_zip cac_addr_zip4 CAC_ADDR_CARRIER_RT where=(CAC_ADDR_CARRIER_RT ~=''));
   zip9=compbl(compress(cac_addr_zip)||compress(cac_addr_zip4));
run;

proc print data=il (obs=10);

proc sort data=il; by cac_addr_zip zip9 cac_addr_carrier_rt; run;

proc print data=il (obs=10);

data il;
   set il;
   by cac_addr_zip zip9 cac_addr_carrier_rt;
   retain cr_cnt;
   if first.cac_addr_carrier_rt then cr_cnt=0;
   cr_cnt+1;
   if last.cac_addr_carrier_rt;
run;

proc print data=il (obs=20);

proc sort data=il; by cac_addr_zip zip9 descending cr_cnt;

proc print data=il (obs=20);

proc sort data=il nodupkey; by cac_addr_zip zip9;

proc print data=il (obs=20);
