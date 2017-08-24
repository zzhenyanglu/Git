**************************************************************************;
libname dist '/project/SMILE/DATA/LOCATIONS/';
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;



data harwood;
   set sar.harwoodheights_matched (KEEP=CAC_HH_PID CAC_ADDR_ZIP CAC_ADDR_ZIP4 ORDERDATE cac_addr_latitude cac_addr_longitude
				   where=(cac_addr_longitude ^in(.,0)));
   zip9=compbl(strip(cac_addr_zip)||strip(cac_addr_zip4));
   if '01JAN12'd <= orderdate <= '31DEC12'd;
run;

data wrigley;
   informat _date yymmdd10.;
   format   _date yymmdd10.;
   set sar.wrigleyville_matched (KEEP=CAC_HH_PID CAC_ADDR_ZIP CAC_ADDR_ZIP4 ORDERDATE cac_addr_latitude cac_addr_longitude
				 where=(cac_addr_longitude ^in(.,0)));
   zip9=compbl(strip(cac_addr_zip)||strip(cac_addr_zip4));
   _date=input(strip(orderdate),yymmdd10.);
   if '01JAN12'd <= _date <= '31DEC12'd;
   drop orderdate;
   rename _date=orderdate;
run;

proc sort data=harwood nodupkey; by cac_hh_pid; run;
proc sort data=wrigley nodupkey; by cac_hh_pid; run;


data _null_;
   set harwood;
   file './harwood_map.csv' delimiter=',' dsd lrecl=1000;
   if _n_=1 then put 'pid,lat,lon';
   put cac_hh_pid cac_addr_latitude cac_addr_longitude;
run;



data _null_;
   set wrigley;
   file './wrigley_map.csv' delimiter=',' dsd lrecl=1000;
   if _n_=1 then put 'pid,lat,lon';
   put cac_hh_pid cac_addr_latitude cac_addr_longitude;
run;
