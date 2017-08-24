**********************************************************;
***Program:  000_import_raw.sas                        ***;
***Purpose:  THIS JOB UPDATE V12 SAS DATASETS          ***;
***          WITH THE MOST RECENT MODIFIED GZIPPED     ***;
***          RAW FILE IN RAW FILE FOLDER               ***;
***                                                    ***;
***Updated:  01/13/2015 FL RSS                         ***;
***Author:   FELIX LU RSS                              ***;
***Input Data: V12_RAW                                 ***;
***Output Data: V12_SAS                                ***;
***Notes:    sm=1 means we are replacing all I/O data  ***;
***Changes:  22JAN2015 FL - File Created               ***;
***          23JAN2015 FL - File Added to CI Stream    ***;
***          17FEB2015 FL - Labeled the v12 fields     ***;
***Notes:    NOTICE THAT THE V12 RAW DATA FILE IS NOT  ***;
***          SUPPLEMENTARY TO EXISITING DATA, RATHER   ***; 
***          ITS SUBSTITUTABLE                         ***;
**********************************************************;


%include "/project/CACDIRECT/CODE/PROD/EM_FLAG/METADATA/library.inc";

/* SWAP DIRs TO WRITE V12 RAW DATA */

%macro v12_libs;

   %if &v12_prod_dir=B %then 
      %do;
         libname v12_raw "/project/CACDIRECT/DATA/EM_FLAG/V12/RAW";
         libname v12_sas "/project/CACDIRECT/DATA/EM_FLAG/V12/A";   
      %end;
   
   %else %if &v12_prod_dir=A %then 
      %do;
         libname v12_raw "/project/CACDIRECT/DATA/EM_FLAG/V12/RAW";
         libname v12_sas "/project/CACDIRECT/DATA/EM_FLAG/V12/B"; 	 
      %end;

   %else %then 
      %do;
         %put "ERROR: v12_prod_dir MUST BE A or B!"; 
         %abort;
      %end;

%mend v12_libs;

%v12_libs;


x "ls -t /project/CACDIRECT/DATA/EM_FLAG/V12/RAW > ./file_listing.txt";  
x "sleep 5";

filename v12lst temp;
   
data v12lsttemp;
   infile "./file_listing.txt";
   format filename $50.;
   input filename $;
   if index(filename,"gz") gt 0 and index(filename,"txt") gt 0 then output;
run;

/* PRINT OUT THE FILE TO BE IMPORTED */
 
title 'file to be imported: ';
proc print data = v12lsttemp(obs=1);run;

data _null_;
   file v12lst;
   set v12lsttemp end=eof;
   if _n_=1 then put '%let v12lst=';
   put filename;
   if eof then put ';';
run;


%include v12lst;


%nobs(data=v12lsttemp);
%let v12_nobs=&nobs;


%macro import_v12; 

   filename v12_file PIPE "gzip -dc /project/CACDIRECT/DATA/EM_FLAG/V12/RAW/%scan(&v12lst,1,' ')" lrecl=2000; 

   %let sts = AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY;
   %let sts_len= %sysfunc(countw(&sts));

   data %do i=1 %to &sts_len; 
            v12_sas.v12_%scan(&sts,&i,' ')
        %end; 
        all_obs
        ;
 
   infile v12_file missover dlm='|' firstobs=1 missover dsd truncover;
   
   
   informat v12_sequence_id $50.
            v12_name_first  $25.
            v12_name_last   $25.
            v12_address1 $50.
            v12_address2 $50.
            v12_city $30.
            v12_state $2.
            v12_zip5 $5.
            v12_zip4 $4.
            ;

   format   v12_sequence_id $50.
            v12_name_first  $25.
            v12_name_last   $25.
            v12_address1 $50.
            v12_address2 $50.
            v12_city $30.
            v12_state $2.
            v12_zip5 $5.
            v12_zip4 $4.
            ;

   input    v12_sequence_id $
            v12_name_first  $
            v12_name_last   $
            v12_address1 $
            v12_address2 $
            v12_city $
            v12_state $
            v12_zip5 $
            v12_zip4 $
            ;

   v12_cac_id = _n_;

   label v12_name_first = "First Name From V12";
   label v12_name_last  = "Last Name From V12";
   label v12_address1 = "Address Line 1 From V12";
   label v12_address2 = "Address Line 2 From V12";
   label v12_city = "Address City From V12";
   label v12_state = "Address State From V12";
   label v12_zip5 = "Address Zip 5 From V12";
   label v12_zip4 = "Address Zip 4 From V12";
   label v12_sequence_id = "Unique ID To Append Email Addresses From V12";

   %do i=1 %to %sysfunc(countw(&sts));
       %if &i>1 %then %do; else if v12_state="%scan(&sts,&i,' ')" then output v12_sas.v12_%scan(&sts,&i,' '); %end;
       %else %do;               if v12_state="%scan(&sts,&i,' ')" then output v12_sas.v12_%scan(&sts,&i,' '); %end;
   %end; 

   output all_obs;
   run;

   %qc(data=all_obs);

   proc print data=all_obs(obs=100);run;


   /* SORT IT THE SAS DATASETS BY ZIP5  */ 

   %macro sortit;

      %let sts = AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY;
      %let sts_len= %sysfunc(countw(&sts));

      %do i=1 %to &sts_len;

         %let cstate = %lowcase(%qscan(&sts,&i));

         proc sort data=v12_sas.v12_&cstate.;
            by v12_zip5;
         run; 
  
      %end;

   %mend sortit;

   %sortit;


   x "mv ./file_listing.txt ./LOGS/file_listing_%lowcase(&sysdate).txt";
   x "mv qc_report_all_obs.htm ./LOGS/qc_report_all_obs_%lowcase(&sysdate).htm" ;
   


   filename sendmail email to=("felixlu@cogensia.com") subject="QC REPORT OF V12 SAS DATASETS" from="webmaster@cogensia.com" attach="./LOGS/qc_report_all_obs_%lowcase(&sysdate).htm";

   data _null_;

      file sendmail;
      put "                            QC REPORT OF V12 SAS DATASETS                                    ";
      put "_____________________________________________________________________________________________";
      put "                                                                                             ";
      put "  Importing raw V12 data has been done, the V12 SAS datasets are ready for use.              ";
      put "                                                                                             ";
      put "                                                                                             ";
      put "_____________________________________________________________________________________________";

   run; 

   x "cd /project/CACDIRECT/DATA/EM_FLAG/V12/RAW"; 
   x "mv *txt.gz OLD"; 

%mend import_v12;

%import_V12;
