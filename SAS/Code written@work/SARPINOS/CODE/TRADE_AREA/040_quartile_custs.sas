**************************************************************************;
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
%include '/project/VIASAT/CODE/TNT/INC/quartile.sas';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;

/*
data wrigley;
   set sar.wrigleyville_matched_nodups (where=(cac_prod_active_flag in(1,2) and cac_addr_zip in('60640','60613','60660','60625','60618')));
   newvar=input(lifetimeordercount,5.);
   drop lifetimeordercount;
   rename newvar=lifetimeordercount;
run;

data harwood;
   set sar.harwoodheights_matched_nodups (where=(cac_prod_active_flag in(1,2) and cac_addr_zip in('60634','60630','60656','60706','60631','60068','60646','60641','60176','60707')));
run;


%quartile(data=wrigley,var=lifetimeordercount,testobs=max,outfile=q_wrigley.txt);
%quartile(data=harwood,var=lifetimeordercount,testobs=max,outfile=q_harwood.txt);

*/

data wrigley;
   set sar.wrigleyville_matched_nodups (where=(cac_prod_active_flag in(1,2) and cac_addr_zip in('60640','60613','60660','60625','60618')));
   newvar=input(lifetimeordercount,5.);
   drop lifetimeordercount;
   rename newvar=lifetimeordercount;
   if lifetimeordercount>7 then top_custs=1; else top_custs=0;
run;

data harwood;
   set sar.harwoodheights_matched_nodups (where=(cac_prod_active_flag in(1,2) and cac_addr_zip in('60634','60630','60656','60706','60631','60068','60646','60641','60176','60707')));
   if lifetimeordercount>7 then top_custs=1; else top_custs=0;
run;

proc freq data=wrigley (where=(top_custs=1));
   tables cac_silh /list missing;

proc freq data=wrigley (where=(top_custs=0));
   tables cac_silh /list missing;

proc freq data=harwood (where=(top_custs=1));
   tables cac_silh /list missing;

proc freq data=harwood (where=(top_custs=0));
   tables cac_silh /list missing;
