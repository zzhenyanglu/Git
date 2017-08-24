**************************************************************************;
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;

proc contents data=sar.harwoodheights_matched (keep=cac_hh_pid orderdate cac_silh);

data harwood;
   *informat date date.;
   *format   date date.;
   set sar.harwoodheights_matched (KEEP=CAC_HH_PID orderdate cac_silh);
   cac_hh_pid=strip(cac_hh_pid);
   if cac_hh_pid ^in('','.',' ');
   *date=input(strip(orderdate),date.);
   if '01DEC12'd <= orderdate <= '31DEC12'd;
run;


proc sort data=harwood; by cac_hh_pid; run;

/*
data harwood2;
   set harwood;
   by cac_hh_pid;
   retain count;
   if first.cac_hh_pid then count=0;
   count+1;
   if last.cac_hh_pid;
run;
*/

proc contents data=harwood;
proc print data=harwood (obs=100);


proc freq data=harwood;
   title 'Harwood Heights Orders Last 30 Days';
   tables orderdate cac_silh /list missing;

run;

proc sort data=harwood nodupkey; by cac_hh_pid; run;

proc freq data=harwood;
   title 'Harwood Heights Customers Last 30 Days';
   tables cac_silh /list missing;

run;


proc freq data=sar.harwoodheights_trade;
   title 'Harwood Heights Trade Area';
   tables cac_silh /list missing; run;


proc freq data=sar.harwoodheights_matched_nodups;
   title 'Harwood Heights All Customers';
   tables cac_silh /list missing; run;












endsas;
data harwood;
   informat orderdate mmddyy10.;
   format   orderdate mmddyy10.;
   set sar.harwoodheights_matched (KEEP=CAC_HH_PID lastorderdate cac_silh where=(lastorderdate ^in('',' ','.','1899-12-30 00:00:00.000')));
   cac_hh_pid=strip(cac_hh_pid);
   if cac_hh_pid ^in('','.',' ');
   orderdate=input(strip(tranwrd(lastorderdate,"12:00 AM","")),mmddyy10.);
   drop lastorderdate;
   if '26JAN13'd <= orderdate <= '25FEB13'd;
run;


proc sort data=harwood; by cac_hh_pid; run;

/*
data harwood2;
   set harwood;
   by cac_hh_pid;
   retain count;
   if first.cac_hh_pid then count=0;
   count+1;
   if last.cac_hh_pid;
run;
*/

proc contents data=harwood;
proc print data=harwood (obs=100);


proc freq data=harwood;
   title 'Harwood Heights Orders Last 30 Days';
   tables orderdate cac_silh /list missing;

run;

proc freq data=sar.harwoodheights_trade;
   title 'Harwood Heights Trade Area';
   tables cac_silh /list missing; run;


proc freq data=sar.harwoodheights_matched_nodups;
   title 'Harwood Heights All Customers';
   tables cac_silh /list missing; run;


endsas;

proc sort data=sar.harwoodheights_trade; by CAC_HH_PID; run;
proc sort data=sar.harwoodheights_matched_nodups; by cac_hh_pid;

data harwood;
   merge sar.harwoodheights_trade (in=a)
         sar.harwoodheights_matched_nodups (in=b);
   BY CAC_HH_PID;
   IF A AND NOT B;
RUN;


proc freq data=harwood;
   tables cac_silh /list missing;


proc freq data=sar.harwoodheights_matched_nodups;
   tables cac_silh /list missing;
run;
