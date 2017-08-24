**************************************************************************************************;
*PURPOSE: Read in ADT data;
*AUTHOR:  FELIX LU ;
*HISTORY: 06-18-2015 - created;
**************************************************************************************************;
%macro hi;
filename sale "/project/ADT/DATA/RAW/COGENSIA_DATA_061115.csv";
filename item "/project/ADT/DATA/RAW/COGENSIA_ITEM_DATA_061115.csv";
%include "/project/ADT/CODE/LOAD_RAW_DATA/name_cleanse.mac";

libname adt "/project/ADT/DATA";

%let date = '02JUN15'd;

data adt /*(drop= _:)*/;
   infile sale dlm=',' firstobs=2 missover dsd truncover lrecl=20000;
   informat 
      cust_id               $20.
      site_id               $20.
      cust_type_id          $8.
      cust_stat_id          $8.
      _CUST_START_DATE      $20.
      _ZIP                  $10.
      _SITE_TYPE_DESC       $30.
      _DISCO_EFF_DATE       $20.
      _DISCONNECT_CODE      $20.
      _DISCONNECT_DESC      $50.
      tenure_months         8.
      email                 $80.
      account_type          $8.
      system_type           $20.
      _PULSE                $7.
      USAA                  
      AARP                  
      _DELINQUENCY          $20.
      _CONTRACTSTART         
      _CONTRACTEND           
      _TRANS_TYPE           $30.
      _QSP                  $7.
      _SGL                  $7.
      _PAYMENT_METHOD       $7.
      _PAYMENT_FREQ         $7.
      _FIRE_SMOKE_CO        $7.
      dist_no               $8.
      dist_name             $50.
      _PULSE_TYPE           $50.
      PANEL                 $50.    
      _INSTALL              $50.
      RPU                   8.
      ;
   input
      cust_id               $
      site_id               $
      cust_type_id          $
      cust_stat_id          $
      _CUST_START_DATE      $
      _ZIP                  $
      _SITE_TYPE_DESC       $
      _DISCO_EFF_DATE       $
      _DISCONNECT_CODE      $
      _DISCONNECT_DESC      $
      tenure_months         
      email                 $
      account_type          $
      system_type           $
      _PULSE                $
      USAA                  
      AARP                  
      _DELINQUENCY          $
      _CONTRACTSTART         
      _CONTRACTEND           
      _TRANS_TYPE           $
      _QSP                  $
      _SGL                  $
      _PAYMENT_METHOD       $
      _PAYMENT_FREQ         $
      _FIRE_SMOKE_CO        $
      dist_no               $
      dist_name             $
      _PULSE_TYPE           $
      PANEL                 $    
      _INSTALL              $
      RPU                   
      ;

   %name_cleanse(cleanlist=_ZIP);
/*CHANGE NAMES FOR MISSINGS*/
   if missing(_SITE_TYPE_DESC) then site_type_desc='Unknown                 ';
   else site_type_desc=_SITE_TYPE_DESC;
   if _DISCONNECT_CODE='FRQ' then disconnect_code='FREQ                ';
   else if (missing(_DISCONNECT_CODE) and not(missing(disconnect_date))) then disconnect_code='Unknown                        ';
   else if (missing(_DISCONNECT_CODE) and missing(disconnect_date)) then disconnect_code='Connected                      ';
   else disconnect_code=_DISCONNECT_CODE;
   if (missing(_DISCONNECT_DESC) and disconnect_code='FREQ') then disconnect_desc='Frequency Change              ';
   else if missing(_DISCONNECT_DESC) then disconnect_desc='Connected                 ';
   else disconnect_desc=_DISCONNECT_DESC;
   if missing(_DELINQUENCY) then delinquency='Not Delinquent                      ';
   else delinquency=_DELINQUENCY;
   if missing(_TRANS_TYPE) then trans_type='Unknown                    ';
   else trans_type=_TRANS_TYPE;
   if missing(_QSP) then QSP='Unknown                      ';
   else QSP=_QSP;
   if missing(_SGL) then SGL='Unknown                      ';
   else SGL=_SGL;
   if missing(_PAYMENT_FREQ) then payment_freq='Unknown                      ';
   else payment_freq=_PAYMENT_FREQ;
   if missing(_FIRE_SMOKE_CO) then fire_smoke_co='Unknown                      ';
   else fire_smoke_co=_FIRE_SMOKE_CO;
   if missing(_PULSE) then pulse='Unknown                      ';
   else pulse=_PULSE;
   if (missing(_PULSE_TYPE) and pulse='Y') then pulse_type='Unknown                      ';
   else if (missing(_PULSE_TYPE) and pulse='N') then pulse_type='Not Pulse Subscriber                      ';
   else pulse_type=_PULSE_TYPE;
   if missing(_PAYMENT_METHOD) then payment_method='Unknown';
   else payment_method=_PAYMENT_METHOD;



/*FIX DATE ISSUES*/
   _CUST_START_DATE1 = scan(_CUST_START_DATE,1," ");
   CUST_START_TIME = scan(_CUST_START_DATE,2," ");
   cust_start_date = mdy(scan(_CUST_START_DATE1,2,"-"),scan(_CUST_START_DATE1,3,"-"),scan(_CUST_START_DATE1,1,"-"));
   _DISCO_EFF_DATE1 = scan(_DISCO_EFF_DATE,1," ");
   DISCO_EFF_TIME = scan(_DISCO_EFF_DATE,2," ");
   disconnect_date = mdy(scan(_DISCO_EFF_DATE1,2,"-"),scan(_DISCO_EFF_DATE1,3,"-"),scan(_DISCO_EFF_DATE1,1,"-"));
   contract_start_date = mdy(scan(_CONTRACTSTART,2,"-"),scan(_CONTRACTSTART,3,"-"),scan(_CONTRACTSTART,1,"-"));
   contract_end_date = mdy(scan(_CONTRACTEND,2,"-"),scan(_CONTRACTEND,3,"-"),scan(_CONTRACTEND,1,"-"));
/*FIX INSTALL ISSUES*/
   _INSTALL1=compress(_INSTALL,',');
   _INSTALL2=compress(_INSTALL1,'+');
   install = _INSTALL2 + 0;
/*FIX ZIP CODE*/
   zip = substr(_ZIP,1,5);
   zip4 = substr(_ZIP,6,4);

/*CREATE RESIDENTIAL FLAG*/
   if site_type_desc in ('Unknown' 'RESI - NO SVC' 'RESI - Residential' 'SUB - RESI') then resi_flag=1;
   else resi_flag=0;

/*ADJUST TRANS_TYPE*/

   if _TRANS_TYPE in ('E1-RESALE' 'E2-RESALE' 'E3-RESALE' 'RESALE') then trans_type='RESALE';
   else trans_type=_TRANS_TYPE;
   
/*CREATE ACTIVE FLAG*/   
   if (not(missing(contract_start_date)) and missing(disconnect_date)) OR (not(missing(disconnect_date)) and trans_type in ('CONVERSION' 'PARTIAL_DISCO' 'REINSTATEMENT')) then active_cust=1;
   else if (not(missing(contract_start_date)) and not(missing(disconnect_date))) then active_cust=0;
   else active_cust=.;

/*CREATE TENURE VARIABLES*/
*CUSTOMER LIFE TIME TENURE DAYS;
*DAYS SINCE CONTRACT STARTED;
*DAYS UNTIL CONTRACT ENDS;
   if active_cust=1 then do;
      cust_lt_tenure_days = &date. - cust_start_date;
      days_since_contract_start = &date. - contract_start_date;
      days_until_contract_end = contract_end_date - &date.;
      days_since_contract_ended = .; 
      days_til_disconnected = .;
      cust_lt_tenure_months = cust_lt_tenure_days / 30;
   end;
   else if active_cust=0 then do;
      cust_lt_tenure_days= disconnect_date - cust_start_date;
      days_since_contract_start =.;
      days_til_disconnected = contract_start_date - disconnect_date;
      days_until_contract_end = .;
      days_since_contract_ended = disconnect_date - contract_end_date;
   end;
   else do;
      cust_lt_tenure_days=.;
      days_since_contract_start=.;
      days_until_contract_end=.;
   end;
  
  cust_lt_tenure_months = cust_lt_tenure_days / 30;
  cust_lt_tenure_years = cust_lt_tenure_days / 365;
  months_until_end_date = days_until_contract_end / 30;
  years_until_end_date = days_until_contract_end / 365;

run;

proc freq data = adt;
   tables _INSTALL _INSTALL1 _INSTALL2 install/ list missing;
run;

data fix_dates;
   set adt;
   format cust_start_date disconnect_date contract_start_date contract_end_date date.;
run;

   *if cust_lt_tenure_days < 0 then cust_lt_tenure_days = .;
   *CUSTOMER LIFE TIME TENURE MONTHS;
 
data fix_dates1;
   set fix_dates;   
   *if cust_lt_tenure_months < 0 then cust_lt_tenure_months = .;
   *contract_start_b4_cust_start=. are custs with missing contract_start_date;
   if active_cust ne . then do;
      if contract_start_date < cust_start_date then contract_start_b4_cust_start=1;
      else contract_start_b4_cust_start=0;
   end;
   else if active_cust=. then contract_start_b4_cust_start=.;
   if active_cust=0 then do;
      if disconnect_date < contract_start_date then cont_strt_b4_disc_date=1;
      else cont_strt_b4_disc_date=0;
   end;
/*
*ALL CUSTOMERS WITH MISSING CONTRACT START DATE ALSO HAVE MISSING CONTRACT END DATE;
   if missing(contract_start_date) then miss_contract_start=1;
   else miss_contract_start=0;
   if missing(contract_end_date) then miss_contract_end=1;
   else miss_contract_end=0;
*/
   if missing(contract_start_date) then miss_contract_date=1;
   else miss_contract_date=0;
run;

data adt.customer;
   set fix_dates1;
run;

endsas;
endsas;
endsas;
endsas;
endsas;

*-------------------------------------------------------------------------;
*BEGIN INVESTIGATING DATA;
*-------------------------------------------------------------------------;


proc sort nodupkey data = fix_dates1 out = tempit dupout=cust_dups;
   by cust_id site_id;
run;
/*
proc print data=cust_dups (obs=10 where=(not(missing(email))));
run;

*freq of active customers;
proc freq data = fix_dates1;
   tables active_cust / list missing;
run;

*all customers missing a contract start date are missing the payment method;
proc freq data = fix_dates1;
   tables payment_method / list missing;
   where miss_contract_date=1;
run;
*/
proc print data = fix_dates1 (obs=10);
run;
/*
proc contents data = fix_dates1;
run;

*years_until_end_date: check up on these negative values for years_until_end_date -- code problem or issue with the data?;
*contract_start_b4_cust_start: custs with contract start date before cust start date;
*payment_method: need to investigate customers with missing payment method that have contract start/end dates;
*miss_contract_date: if missing contract start date then also missing contract end date;
proc freq data = fix_dates1;
   tables years_until_end_date contract_start_b4_cust_start payment_method miss_contract_date / list missing;
run;

*this person's contract end date is before their contract start date. Their disconnect date is 6 years after their contract end date. What the heck?;
proc print data = fix_dates1 (obs=10 where=(years_until_end_date=-6));
run;

title '******** contract_start_b4_cust_start=1 print -- contract start date is before customer start date where not missing contract start date ********';
proc print data=fix_dates1 (obs=15 where=(contract_start_b4_cust_start=1));
run;
*/
*19K have cust_start_date of July 28 2013, the rest are scattered. Remove the ones with July 28 2013 start date and print to investigate.;
title '*********** freq of cust start date for obs with contract start date before customer start date ***********';
proc freq data = fix_dates1;
   tables cust_start_date / list missing;
   where contract_start_b4_cust_start=1;
run;

title '************* contract start before cust start, cust start date NE 28JUL13 *************';
proc print data = fix_dates1 (obs=10 where=(contract_start_b4_cust_start=1 and cust_start_date ne '28JUL13'd));
run;

*fixed definition of active_cust, should be correct now.;
title '********** active_cust=1 print -- disconnected custs have a contract end date ********';
proc print data = fix_dates1 (obs=10 where=(active_cust=1));
run;

title '********** disconnect date after contract start date ****************';
proc freq data = fix_dates1;
   tables cont_strt_b4_disc_date / list missing;
run;
proc freq data = fix_dates1;
   tables cust_start_date / list missing;
   where cont_strt_b4_disc_date=1;
run;
/*
title '********* missing payment_method print -- did they disconnect before contract start date? ************';
proc print data = fix_dates1 (obs=15 where=(payment_method='' and not(missing(contract_start_date))));
run;
*/
proc sort data = fix_dates1 out = temp;
   by active_cust;
run;

proc freq data = temp;
   tables payment_method / list missing;
   by active_cust;
run;

proc freq data = fix_dates1;
   tables cust_lt_tenure_years / list missing;
   where active_cust=0;
run;

*title '********* missing payment method for active and inactive custs only *************';
proc print data = fix_dates1 (obs=10 where=(active_cust=0 and payment_method=''));
run;

*all obs with missing contract dates have missing payment method;
title '************ payment method freq where not missing contract start date ************';
proc freq data = fix_dates1;
   tables payment_method / list missing;
   where miss_contract_date=0;
run;

proc freq data = fix_dates1;
   tables cust_stat_id site_type_desc/ list missing;
run;

%mend hi;
%hi;