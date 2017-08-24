**************************************************************************;
libname sar '/project/VIASAT/DATA/SARPINOS';
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;

%macro blah;
%let st=il ia mn tx ks mo;


*** PULL ZIP9 AND CARRIER ROUTE FROM BASE DEMO ***;
%do i=1 %to 6;
data %scan(&st,&i);
   format zip9 $9.;
   set base.base_demo_%scan(&st,&i) (keep= cac_addr_zip cac_addr_zip4 CAC_ADDR_CARRIER_RT CAC_ADDR_LATITUDE CAC_ADDR_LONGITUDE where=(CAC_ADDR_CARRIER_RT ~='' and cac_addr_zip4 ~='' and cac_addr_latitude ^in(.,0)));
   zip9=compbl(compress(cac_addr_zip)||compress(cac_addr_zip4));
   drop cac_addr_zip4;
run;

proc print data=%scan(&st,&i) (obs=10);

%end;

data stack;
   set
   %do i=1 %to 6;
      %scan(&st,&i) 
   %end;;
run;


*** MERGE ONTO ZIP9s AND CARRIER ROUTES TO STORE NUMBER ***;

proc sort data=stack; by zip9;  
proc sort data=sar.store_market_zip9; by zip9;

data store bad;
   merge sar.store_market_zip9 (in=a keep=zip9 store_number store_name)
         stack                 (in=b);
   by zip9;
   if a and not b then output bad;     * WE KNOW ABOUT 25 PERCENT OF ZIP9s are PO BOXES OR BIZ ZIP9s AND THIS IS EXPECTED *;
   if a and b then output store;
run;

*** CREATE LAT LON CENTROIDS FOR EACH CARRIER ROUTE ***;
proc sort data=store (KEEP=cac_addr_zip cac_addr_carrier_rt cac_addr_latitude cac_addr_longitude) out=latlon; by cac_addr_zip cac_addr_carrier_rt; run;

data latlon;
   format lat_cnt BEST12.
          lon_cnt BEST12.
          lat     BEST12.
          lon     BEST12.;
   set latlon;
   by cac_addr_zip cac_addr_carrier_rt;
   retain tot lat_cnt lon_cnt;
   if first.cac_addr_carrier_rt then do;
	tot=0;
	lat_cnt=0;
	lon_cnt=0;
   end;
   tot+1;
   lat_cnt+cac_addr_latitude;
   lon_cnt+cac_addr_longitude;
   if last.cac_addr_carrier_rt;
   lat=lat_cnt/tot;
   lon=lon_cnt/tot;
   KEEP cac_addr_zip cac_addr_carrier_rt lat lon;
run;

proc sort data=latlon nodupkey; by cac_addr_zip cac_addr_carrier_rt; run;

proc print data=latlon (obs=20);
title 'LAT AND LON CENTROIDS FOR EACH CARRIER ROUTE';
run;


*** ROLLUP TO STORE ZIP CARRIER ROUTE TO GET NUMBER OF ADDRESSES IN EACH STORE_CARRIER_ROUTE COMBO ***;
proc sort data=store (DROP=cac_addr_l:); by STORE_NUMBER cac_addr_zip cac_addr_carrier_rt; run;

proc print data=store (obs=100);
title 'PRE ROLLUP PRINT';
run;

data store;
   set store;
   by store_number cac_addr_zip cac_addr_carrier_rt;
   retain store_cnt;
   if first.cac_addr_carrier_rt then store_cnt=0;
   store_cnt+1;
   if last.cac_addr_carrier_rt;
run;

proc print data=store (obs=20);
title 'POST ROLLUP PRINT';
run;

*** ASSIGN CARRIER ROUTE TO STORE WHERE MOST ADDRESSES FALL ***;
proc sort data=store; by cac_addr_zip cac_addr_carrier_rt descending store_cnt; run;

proc print data=store (obs=20);
title 'PRINT SORTED BY ZIP_CARRIERROUTE AND DESCENDING COUNT BY STORE'; 
run;

proc sort data=store nodupkey; by cac_addr_zip cac_addr_carrier_rt; run;

proc print data=store (obs=20);
title 'PRINT AFTER NODUP SORT ON ZIP_CARRIERROUTE';
run;

*** MERGE ON LAT LON CENTROIDS***;
data sar.store_xref;
   merge store  (in=a)
         latlon (in=b);
   by cac_addr_zip cac_addr_carrier_rt;
   if a and b;
run;

proc sort data=sar.store_xref; by store_number; run;

proc print data=sar.store_xref (obs=10);

proc contents data=sar.store_xref;

data _null_;
   set sar.store_xref;
   file './sarpinos_store_carrier_routes.csv' delimiter=',' dsd lrecl=10000;
   if _n_=1 then put 'STORE_NUMBER,STORE_NAME,ZIP,CARRIER_ROUTE,LAT,LON';
   put STORE_NUMBER STORE_NAME CAC_ADDR_ZIP CAC_ADDR_CARRIER_RT LAT LON;
run;

%mend blah;
%blah;








