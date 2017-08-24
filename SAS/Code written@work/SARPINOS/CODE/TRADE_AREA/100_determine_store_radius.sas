**************************************************************************;
libname sar '/project/VIASAT/DATA/SARPINOS';
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;

/*
data via.zip9_latlon_ref;
   infile '/project/VIASAT/DATA/zip9_latlon_ref.csv' delimiter=',' dsd missover lrecl=1000 firstobs=2;
   informat zip9 $9.
  	    lat  BEST8.
	    lon  BEST8.;
   format   zip9 $9.
  	    lat  BEST8.
	    lon  BEST8.;
   input zip9 lat lon;
run;

proc print data=via.zip9_latlon_ref (obs=20);
proc print data=via.zip9_latlon_ref (firstobs=100000 obs=100020);

data sar.stores;
   infile '/project/VIASAT/DATA/SARPINOS/stores.csv' delimiter=',' dsd missover lrecl=32000 firstobs=2;
   informat store_number 8.
  	    store_name $50.
	    address    $50.
	    city       $30.
	    state      $2.
	    zip        $5.
            lat	       BEST8.
	    lon        BEST8.
	    radius_flag 1.;
   format   store_number 8.
  	    store_name $50.
	    address    $50.
	    city       $30.
	    state      $2.
	    zip        $5.
            lat	       BEST8.
	    lon        BEST8.
	    radius_flag 1.;
   input store_number store_name address city state zip lat lon radius_flag;
run;

proc print data=sar.stores;
*/

%macro doit;
%let maxobs=max;

%include './store_radius_inc.txt';

data store9;
   set via.zip9_latlon_ref;
   zip=substr(zip9,1,5);
   if zip in('55318','55315','55386','55331','55379','55317');
   store=9;
   drop zip;
run;


data sar.store_area_zip9_radius;
   set via.zip9_latlon_ref (obs=&maxobs);
   array lats  (29) (&lats);
   array lons  (29) (&lons);
   %do i=1 %to 29;   
         d_%scan(&store,&i)=3959*arcos((sin(lat/57.3)*sin(lats&i/57.3))+(cos(lat/57.3)*cos(lats&i/57.3)*cos((lons&i/57.3)-(lon/57.3))));
         drop lats&i lons&i;
   %end;
      array list(*)
         %do i=1 %to 29;
            d_%scan(&store,&i)
         %end;;
      closest = vname(list[whichn(min(of list[*]), of list[*])]);
      store=input(compress(closest,'d_'),8.);
      distance=min(of list[*]);
      DROP d_: closest;
      if store in(2,13,14) then do;
         radius = 2.0;
         if distance <= radius;
      end;
      else if store in(3,18,27) then do;
         radius = 2.5;
         if distance <= radius;
      end;
      else if store in(4,10,11,16,17,20,22,23,24,25,32,33,34,36,38,43,44,45,46) then do;
         radius = 3;
         if distance <= radius;
      end;
      else if store in(7) then do;
         radius = 3.5;
         if distance <= radius;
      end;
      else if store in(5,8,12) then do;
         radius = 4;
         if distance <= radius;
      end;
      distance=round(distance,.1);
run;

data sar.store_area_zip9_radius;
   set sar.store_area_zip9_radius
       store9;

proc sort data=sar.store_area_zip9_radius nodupkey; by zip9;

proc print data=sar.store_area_zip9_radius (obs=1000);

proc contents data=sar.store_area_zip9_radius;

proc freq data=sar.store_area_zip9_radius;
   tables distance store /list missing;

%mend doit;
%doit;



                                                                                                            
                                                                                                                       
run;   



