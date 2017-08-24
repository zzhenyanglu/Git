**************************************************************************;
libname sar '/project/VIASAT/DATA/SARPINOS';
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;

proc sort data=via.zip9_latlon_ref; by zip9;
proc sort data=sar.store_area_zip9_radius; by zip9;

data rest;
   merge via.zip9_latlon_ref (in=a)
         sar.store_area_zip9_radius (in=b KEEP=zip9);
   by zip9;
   if not b;
   st=substr(zip9,1,2);
   if st in('60','61','62','55','56');
run;

data _null_;
   set rest;
   file '/project/VIASAT/DATA/SARPINOS/sarpinos_for_join.csv' delimiter=',' dsd lrecl=1000;
   if _n_=1 then put 'ZIP,LAT,LON';
   put zip9 lat lon;
run;
