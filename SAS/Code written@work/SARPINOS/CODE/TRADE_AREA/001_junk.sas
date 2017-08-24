**************************************************************************;
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;

%let zips=
'50263'
;

%let zip9=
'502630001',
'502630121',
'502630721',
'502631005',
'502631101',
'502632102',
'502632103',
'502632500',
'502633503',
'502633504',
'502635000',
'502635003',
'502635005',
'502635006',
'502635008',
'502635009',
'502635010',
'502635013',
'502635014',
'502635015',
'502635016',
'502635018',
'502635021',
'502636000',
'502636019',
'502636021',
'502636032',
'502636033',
'502637000',
'502637001',
'502637002',
'502637003',
'502637004',
'502637005',
'502637006',
'502637073',
'502637090',
'502637091',
'502637097',
'502637100',
'502637507',
'502637519',
'502637523',
'502637524',
'502637525',
'502637526',
'502637527',
'502637528',
'502637529',
'502637530',
'502637537',
'502637551',
'502637563',
'502637567',
'502637700',
'502637701',
'502637702',
'502637703',
'502637704',
'502637705',
'502637706',
'502637709',
'502637711',
'502637712',
'502637713',
'502637717',
'502637720',
'502637729',
'502637733',
'502637734',
'502637735',
'502638010',
'502638042',
'502638110',
'502638112',
'502638171',
'502638172',
'502638178',
'502638179',
'502638185',
'502638191',
'502638197',
'502638250',
'502638259',
'502638275',
'502638286',
'502638290',
'502638299',
'502638314',
'502638320',
'502638328',
'502638340',
'502638343',
'502638352',
'502638353',
'502638361',
'502638365',
'502638373',
;

data check;
   set base.base_demo_ia (keep= cac_addr_zip cac_addr_zip4 CAC_ADDR_CARRIER_RT where=(/* CAC_ADDR_CARRIER_RT ~='' */ cac_addr_zip in(&zips)));
   zip9=compbl(compress(cac_addr_zip)||compress(cac_addr_zip4));
   drop cac_addr_zip cac_addr_zip4;
   *if zip9 in(&zip9);
run;

proc sort data=check nodupkey; by zip9;
proc print data=check;

endsas;
proc print data=sar.harwoodheights_matched (where=(cac_hh_pid='60018|3221067930|1117744694'));


