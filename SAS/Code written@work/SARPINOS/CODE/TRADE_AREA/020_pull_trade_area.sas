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

