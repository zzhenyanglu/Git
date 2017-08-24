**************************************************************************;
libname dist '/project/SMILE/DATA/LOCATIONS/';
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;

proc contents data=sar.wrigleyville;

proc sort data=sar.wrigleyville_matched; by CAC_HH_PID descending lifetimeordercount; run;
proc sort data=sar.harwoodheights_matched; by CAC_HH_PID descending lifetimeordercount;run;

proc sort data=sar.wrigleyville_matched (where=(cac_hh_pid ^in('.',' ','','                          .') and cac_prod_active_flag in(1,2))) nodupkey
	       out=sar.wrigleyville_matched_nodups; BY CAC_HH_PID; RUN;

proc sort data=sar.harwoodheights_matched (where=(cac_hh_pid ^in('.',' ','','                          .') and cac_prod_active_flag in(1,2))) nodupkey
	       out=sar.harwoodheights_matched_nodups; BY CAC_HH_PID; RUN;

proc freq order=freq data=sar.wrigleyville_matched_nodups;
   tables cac_addr_zip lifetimeordercount /list missing;
run;

proc freq order=freq data=sar.harwoodheights_matched_nodups;
   tables cac_addr_zip lifetimeordercount /list missing;
run;

