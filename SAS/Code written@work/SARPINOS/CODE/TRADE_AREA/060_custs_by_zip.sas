**************************************************************************;
libname dist '/project/SMILE/DATA/LOCATIONS/';
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;

proc contents data=sar.harwoodheights_matched (drop= cac:);
proc contents data=sar.wrigleyville_matched (drop= cac:);




data harwood;
   set sar.harwoodheights_matched (KEEP=CAC_HH_PID CAC_ADDR_ZIP CAC_ADDR_ZIP4 ORDERDATE);
   zip9=compbl(strip(cac_addr_zip)||strip(cac_addr_zip4));
   if '01JAN12'd <= orderdate <= '31DEC12'd;
   if cac_addr_zip4 ^in('',' ','    ','0000');
run;

data wrigley;
   informat _date yymmdd10.;
   format   _date yymmdd10.;
   set sar.wrigleyville_matched (KEEP=CAC_HH_PID CAC_ADDR_ZIP CAC_ADDR_ZIP4 ORDERDATE);
   zip9=compbl(strip(cac_addr_zip)||strip(cac_addr_zip4));
   _date=input(strip(orderdate),yymmdd10.);
   if '01JAN12'd <= _date <= '31DEC12'd;
   if cac_addr_zip4 ^in('',' ','    ','0000');
   drop orderdate;
   rename _date=orderdate;
run;

proc print data=wrigley (obs=100); var orderdate orderdate cac_hh_pid;

proc freq data=wrigley;
   tables orderdate /list missing;
run;

proc sort data=harwood; by cac_hh_pid descending cac_addr_zip4; run;
proc sort data=harwood nodupkey; by cac_hh_pid; run;
proc sort data=harwood; by zip9; run;

proc sort data=wrigley; by cac_hh_pid descending cac_addr_zip4; run;
proc sort data=wrigley nodupkey; by cac_hh_pid; run;
proc sort data=wrigley; by zip9; run;

data harwood;
   set harwood;
   by zip9;
   retain cnt;
   if first.zip9 then cnt=0;
   cnt+1;
   if last.zip9;
run;

proc sort data=harwood; by descending cnt;


data _null_;
   set harwood;
   file './harwood_zip9.csv' delimiter=',' dsd lrecl=1000;
   if _n_=1 then put 'zip9,count';
   put zip9 cnt;
run;

data wrigley;
   set wrigley;
   by zip9;
   retain cnt;
   if first.zip9 then cnt=0;
   cnt+1;
   if last.zip9;
run;

proc sort data=wrigley; by descending cnt;

data _null_;
   set wrigley;
   file './wrigley_zip9.csv' delimiter=',' dsd lrecl=1000;
   if _n_=1 then put 'zip9,count';
   put zip9 cnt;
run;
