*========================================================================================;
* Program 200_data_model.sas
  Purpose Make the Data Dictionary for CAC Direct 3.0 
  Authors Mike Mattingly
*========================================================================================;
*========================================================================================;
options mprint nomlogic linesize=120;

libname base '/project/CACDIRECT/DATA/BASE_DEMO/B';

proc contents data=base.base_demo_AK noprint out=contents_base_demo;
run;

data contents_base_demo (drop=type varnum);
 length name $32.;
 set contents_base_demo (keep=name type length varnum label);
 name=upcase(name);
 length format $9. category $20.; 
  if type=1 then format='Numeric';
   else format = 'Character';
  if substr(name,1,8)='CAC_ADDR' then category='Address';
   else if substr(name,1,9) in ('CAC_D_IND','CAC_H_IND') then category ='Demo Indicator';
   else if substr(name,1,6)='CAC_LE' then category='CAC Life Events';
   else if substr(name,1,10)='CAC_CENSUS' then category='Census';
   else if substr(name,1,8)='CAC_CRED' then category='Credit';
   else if substr(name,1,8)='CAC_DEMO' then category='Demo';
   else if substr(name,1,8)='CAC_HOME' then category='Home';
   else if substr(name,1,7)='CAC_IND' or name ='CAC_HH_PID_IND' then category='Individual';
   else if substr(name,1,7)='CAC_INT' then category='Interests';
   else if substr(name,1,6)='CAC_MV' then category='Motor Vehicles';
   else if substr(name,1,8)='CAC_NAME' then category='Name';
   else if substr(name,1,6)='CAC_PH' then category='Phone';
   else if name in ('CAC_ACTIVE_FLAG', 'CAC_DELIVERABILITY_DATE', 'CAC_HH_PID', 'CAC_HH_VERIFICATION_DATE', 'CAC_NICHES', 'CAC_NUM_SOURCES',
                    'CAC_PRODUCTION', 'CAC_QTR', 'CAC_YEAR', 'CAC_RECNO', 'CAC_RECORD_QUALITY','CAC_PROD_ACTIVE_FLAG') then category ='Production';

   else if name in ('CAC_LS_LEVEL_FLAG', 'CAC_SILH', 'CAC_SILH_LIFEDRIVER', 'CAC_SILH_LIFESTAGE', 'CAC_SILH_LIFESTAGE_MACRO', 'CAC_SILH_LIFESTYLE',
                    'CAC_SILH_LIFESTYLE_MACRO') then category='Silh';
   else if substr(name,1,8)='CAC_TRIG' then category='Trigger';
   else if substr(name,1,9)='CAC_VALUE' then category='Valuescore';
   if name in ('CAC_GEO_MATCH','LE_TEST_FLAG') then delete;
   if substr(name,1,8)='CAC_SILH' then category='Silh';
run;

proc print data=contents_base_demo;
 where category eq '';
run;

proc sort data=contents_base_demo;
  by category name;
run;

proc print data=contents_base_demo;
  var name label;
run;
