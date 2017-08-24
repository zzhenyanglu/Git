**************************************************************************;
libname sar '/project/VIASAT/DATA/SARPINOS';
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;


data sar.store_area_zip9_borders;
   infile '/project/VIASAT/DATA/SARPINOS/sarpinos_spatial_join_out.csv' delimiter=',' dsd missover lrecl=1000 firstobs=2;
   informat lat			BEST8.
	    lon 		BEST8.
	    zip9 		$9.
            store_number 	8.;
   format   lat			BEST8.
	    lon 		BEST8.
	    zip9 		$9.
            store_number   	8.;
   input zip9 lat lon store_number;
   if store_number ~=0;
run;

proc contents data=sar.store_area_zip9_borders;

proc freq data=sar.store_area_zip9_borders;
   tables store_number /list missing;
run;

proc print data=sar.store_area_zip9_borders (obs=20);
proc print data=sar.store_area_zip9_borders (firstobs=20000 obs=20020);


data stack;
   set sar.store_area_zip9_borders (in=a)
       sar.store_area_zip9_radius (in=b KEEP=store lat lon zip9 rename=(store=store_number));
   if a then select_type='BOUNDARY';
   if b then select_type='RADIUS';
run;

proc sort data=stack nodupkey; by zip9; run;
proc sort data=stack; by store_number;
proc sort data=sar.stores; by store_number;

data sar.store_market_zip9;
   merge stack (in=a)
         sar.stores (in=b KEEP=store_number store_name);
   by store_number;
   if a;
run;

proc contents data=sar.store_market_zip9;
proc freq data=sar.store_market_zip9; tables store_number*store_name select_type /list missing;
proc print data=sar.store_market_zip9 (obs=20);

data _null_;
   set sar.store_market_zip9;
   file '/project/VIASAT/DATA/SARPINOS/sarpinos_store_market_zip9.csv' delimiter=',' dsd lrecl=1000;
   if _n_=1 then put 'STORE_NUMBER,STORE_NAME,ZIP9,SELECT_TYPE';
   put store_number store_name zip9 select_type;
run;




