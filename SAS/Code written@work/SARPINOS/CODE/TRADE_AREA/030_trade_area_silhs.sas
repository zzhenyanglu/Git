**************************************************************************;
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;

data sar.wrigleyville_trade;
   set base.base_demo_il (where=(cac_prod_active_flag in(1,2) and cac_addr_zip in('60640','60613','60660','60625','60618')));
run;


data sar.harwoodheights_trade;
   set base.base_demo_il (where=(cac_prod_active_flag in(1,2) and cac_addr_zip in('60634','60630','60656','60706','60631','60068','60646','60641','60176','60707')));
run;


proc sort data=sar.harwoodheights_trade; by CAC_HH_PID; run;
proc sort data=sar.wrigleyville_trade; by CAC_HH_PID; run;
proc sort data=sar.wrigleyville_matched_nodups; by cac_hh_pid;
proc sort data=sar.harwoodheights_matched_nodups; by cac_hh_pid;

data wrigley;
   merge sar.wrigleyville_trade (in=a)
         sar.wrigleyville_matched_nodups (in=b);
   BY CAC_HH_PID;
   IF A AND NOT B;
RUN;

data harwood;
   merge sar.harwoodheights_trade (in=a)
         sar.harwoodheights_matched_nodups (in=b);
   BY CAC_HH_PID;
   IF A AND NOT B;
RUN;

proc freq data=wrigley;
   tables cac_silh /list missing;
proc freq data=sar.wrigleyville_matched_nodups;
   tables cac_silh /list missing;

proc freq data=harwood;
   tables cac_silh /list missing;
proc freq data=sar.harwoodheights_matched_nodups;
   tables cac_silh /list missing;
run;
