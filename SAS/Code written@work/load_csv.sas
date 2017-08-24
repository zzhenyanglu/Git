filename sale "/project/ADT/DATA/RAW/COGENSIA_DATA_061115.csv";
filename item "/project/ADT/DATA/RAW/COGENSIA_ITEM_DATA_061115.csv";

libname adt "/project/ADT/DATA";

/*
data adt.COGENSIA_ITEM_DATA_061115;
infile item dlm=',' firstobs=2 missover dsd truncover lrecl=20000;

informat 
     CUST_NO   $20.
     SITE_NO   $20.
     TRANSACTION_TYPE   $20.
     ITEM_NO   $50.
     ITEM_DESCR $50.;
input
     CUST_NO   $
     SITE_NO   $
     TRANSACTION_TYPE   $
     ITEM_NO   $
     ITEM_DESCR $;
run;
*/

data adt.COGENSIA_DATA_061115(drop=CUST_START_DATE_datepart CUST_START_DATE_timepart DISCO_EFF_DATE_datepart DISCO_EFF_DATE_timepart);
infile sale dlm=',' firstobs=2 missover dsd truncover lrecl=20000;

informat 
    CUST_NO           $20.
    SITE_NO           $20.
    CUSTYPE_ID        $8.
    CUSTSTAT_ID       $8.
    CUST_START_DATE   $20.
    ZIP_CODE          $10.
    SITETYPE_DESCR    $30.
    DISCO_EFF_DATE    $20.
    END_RECREASON_ID  $20.
    DISCO_DESCR       $50.
    TENURE_MONTHS     8.
    MOSTRECENTEMAIL   $80.
    ACCOUNTTYPE       $8.
    CUSTOMER_TYPE     $20.
    PULSE             
    USAA              
    AARP              
    DELINQUENCY       $20.
    CONTRACTSTART     
    CONTRACTEND        
    TRANSACTIONTYPE   $30.
    QSP
    SGL
    PAYMENTMETHOD
    PAYMENTFREQ
    FIRESMOKE_CO
    DIST_NO           $8.
    DIST_NAME         $50.
    PULSE_TYPE        $50.
    PANEL             $50.    
    INSTALL           $50.
    RPU               8.
;

input
    CUST_NO           $
    SITE_NO           $
    CUSTYPE_ID        $
    CUSTSTAT_ID       $
    CUST_START_DATE   $
    ZIP_CODE          $
    SITETYPE_DESCR    $
    DISCO_EFF_DATE    $
    END_RECREASON_ID  $
    DISCO_DESCR       $
    TENURE_MONTHS     
    MOSTRECENTEMAIL   $
    ACCOUNTTYPE       $
    CUSTOMER_TYPE     $
    PULSE             $
    USAA              $
    AARP              $
    DELINQUENCY       $
    CONTRACTSTART     
    CONTRACTEND       
    TRANSACTIONTYPE   $
    QSP               $
    SGL               $
    PAYMENTMETHOD     $
    PAYMENTFREQ       $
    FIRESMOKE_CO      $
    DIST_NO           $
    DIST_NAME         $
    PULSE_TYPE        $
    PANEL             $    
    INSTALL           $
    RPU               
;

CUST_START_DATE_datepart = scan(CUST_START_DATE,1," ");
CUST_START_DATE_timepart = scan(CUST_START_DATE,2," ");
CUST_START_DATE_datepart_numeric = mdy(scan(CUST_START_DATE_datepart,2,"-"),scan(CUST_START_DATE_datepart,3,"-"),scan(CUST_START_DATE_datepart,1,"-"));
CUST_START_DATE_timepart_numeric = hms(scan(CUST_START_DATE_timepart,1,":"),scan(CUST_START_DATE_timepart,2,":"),scan(CUST_START_DATE_timepart,3,":"));

DISCO_EFF_DATE_datepart = scan(DISCO_EFF_DATE,1," ");
DISCO_EFF_DATE_timepart = scan(DISCO_EFF_DATE,2," ");
DISCO_EFF_DATE_datepart_numeric = mdy(scan(DISCO_EFF_DATE_datepart,2,"-"),scan(DISCO_EFF_DATE_datepart,3,"-"),scan(DISCO_EFF_DATE_datepart,1,"-"));
DISCO_EFF_DATE_timepart_numeric = hms(scan(DISCO_EFF_DATE_timepart,1,":"),scan(DISCO_EFF_DATE_timepart,2,":"),scan(DISCO_EFF_DATE_timepart,3,":"));

CONTRACTSTART_numeric = mdy(scan(CONTRACTSTART,2,"-"),scan(CONTRACTSTART,3,"-"),scan(CONTRACTSTART,1,"-"));
CONTRACTEND_numeric = mdy(scan(CONTRACTEND,2,"-"),scan(CONTRACTEND,3,"-"),scan(CONTRACTEND,1,"-"));

new_install = compress(INSTALL,'+');

run;

proc print data = adt.cogensia_data_061115 (obs=10 where=(MOSTRECENTEMAIL="DIANE@JBGARDNER.COM"));
run;


proc format; 
   value tenure_buck   
   1 = "0-6 mos" 
   2 = "7-12 mos" 
   3 = "13-18 mos" 
   4 = "19-24 mos" 
   5 = "25-30 mos" 
   6 = "31-36 mos" 
   7 = "37-42 mos" 
   8 = "43-48 mos" 
   9 = "49-54 mos"
   10 = "55-60 mos"
   11 = "60+ mos"
   other ="what the...";

   value rpu_buck   
   1 = "$0 - $25" 
   2 = "$25 - $35" 
   3 = "$35 - $45" 
   4 = "$45 - $55"  
   5 = ">$55" 
   other ="what the...";
run;


data adt.cogensia_data_061115;
   set adt.cogensia_data_061115 (drop=INSTALL);
   calculated_tenure = (DISCO_EFF_DATE_datepart_numeric - CUST_START_DATE_datepart_numeric)/30; 
   if missing(DISCO_EFF_DATE) then calculated_tenure = (20254 - CUST_START_DATE_datepart_numeric)/30; 
   if calculated_tenure <0 then calculated_tenure =.;

if 0 <= calculated_tenure <=6 then tenure_bucket =1;
if 7 <= calculated_tenure <=12 then tenure_bucket =2;
if 13 <= calculated_tenure <=18 then tenure_bucket =3;
if 19 <= calculated_tenure <=24 then tenure_bucket =4;
if 25 <= calculated_tenure <=30 then tenure_bucket =5;
if 31 <= calculated_tenure <=36 then tenure_bucket =6;
if 37 <= calculated_tenure <=42 then tenure_bucket =7;
if 43 <= calculated_tenure <=48 then tenure_bucket =8;
if 49 <= calculated_tenure <=54 then tenure_bucket =9;
if 55 <= calculated_tenure <=60 then tenure_bucket =10;
if 60 < calculated_tenure then tenure_bucket =11;

if 0 <= RPU < 25 then RPU_bucket =1;
if 25 <= RPU < 35 then RPU_bucket =2;
if 35 <= RPU < 45 then RPU_bucket =3;
if 45 <= RPU <= 55 then RPU_bucket =4;
if 55 < RPU then RPU_bucket =5;

tenure_bucket_convert = put(tenure_bucket, tenure_buck.);
RPU_bucket_convert = put(RPU_bucket, RPU_buck.);

INSTALL = new_install + 0;

run;

proc contents data = adt.cogensia_data_061115;
run;

endsas;
endsas;
endsas;
endsas;
endsas;

data adt.customers;
   set adt.cogensia_data_061115;
   format CUST_START_DATE_datepart_numeric date.;
