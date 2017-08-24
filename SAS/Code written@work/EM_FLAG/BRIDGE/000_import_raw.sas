**********************************************************;
***Program:  000_import_raw.sas                        ***;
***Purpose:  THIS JOB UPDATE BRIDGE SAS DATASETS       ***;
***          WITH THE MOST RECENT MODIFIED RAR         ***;
***          RAW FILE IN RAW FILE FOLDER               ***;
***                                                    ***;
***Updated:  01/13/2015 FL RSS                         ***;
***Author:   FL RSS                                    ***;
***Input Data: Bridge_RAW                                 ***;
***Output Data: Bridge_SAS                                ***;
***Notes:    sm=1 means we are replacing all I/O data  ***;
***Changes:  22JAN2015 FL - File Created               ***;
***          23JAN2015 FL - File Added to CI Stream    ***;
***          13May2015 FL - Modified to unload rar     ***;
***Notes:    NOTICE:  THE Bridge RAW DATA FILE IS NOT  ***;
***          SUPPLEMENTARY TO EXISITING DATA, RATHER   ***; 
***          ITS SUBSTITUTABLE                         ***;
**********************************************************;






%macro bridge_libs;

   %include "/project/CACDIRECT/CODE/PROD/EM_FLAG/METADATA/library.inc";

   %if &bridge_prod_dir=B %then 
      %do;
         libname brg_raw "/project/CACDIRECT/DATA/EM_FLAG/BRIDGE/RAW";
         libname brg_sas "/project/CACDIRECT/DATA/EM_FLAG/BRIDGE/A";   
      %end;
   
   %else %if &bridge_prod_dir=A %then 
      %do;
         libname brg_raw "/project/CACDIRECT/DATA/EM_FLAG/BRIDGE/RAW";
         libname brg_sas "/project/CACDIRECT/DATA/EM_FLAG/BRIDGE/B"; 	 
      %end;

%mend bridge_libs;

%bridge_libs;


x "ls -t /project/CACDIRECT/DATA/EM_FLAG/BRIDGE/RAW > ./file_listing.txt";  
x "sleep 5";

filename bglst temp;
   
data bglsttemp;
   infile "./file_listing.txt";
   format filename $50.;
   input filename $;
   if index(filename,"rar") gt 0 then output;              /* 13May2015 FL: change extension to unzip rar file */
run;

 
title 'file to be imported: ';
proc print data = bglsttemp(obs=1);run;

data _null_;
   file bglst;
   set bglsttemp end=eof;
   if _n_=1 then put '%let brglst=';
   put filename;
   if eof then put ';';
run;

%include bglst;



%macro import_bridge; 
   
   %let sts = AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY;
   %let sts_len= %sysfunc(countw(&sts));
   
   filename bg_file PIPE "unrar p -cfg- /project/CACDIRECT/DATA/EM_FLAG/BRIDGE/RAW/%scan(&brglst,1,' ')" ;    /* 13May2015 FL: use unrar instead of gunzip - p means pipe  */   

   data 
        %do i=1 %to &sts_len; 
            brg_sas.bridge_%scan(&sts,&i,' ')
        %end; 
        all_obs
        ;
   infile bg_file dlm=',' firstobs=10 missover dsd truncover lrecl=20000;   /* 13May2015 FL: change from firstobs=2 to firstobs=10  */   
   
   informat 
            bridge_name_first  $25.
            bridge_name_last   $25.
            bridge_address1 $50.
            bridge_address2 $50.
            bridge_city $30.
            bridge_state $2.
            bridge_zip5 $5.
            bridge_md5email_id $50.
            ;

   format   
            bridge_name_first  $25.
            bridge_name_last   $25.
            bridge_address1 $50.
            bridge_address2 $50.
            bridge_city $30.
            bridge_state $2.
            bridge_zip5 $5.
            bridge_md5email_id $50.
            ;

   input    
            bridge_name_first  $
            bridge_name_last   $
            bridge_address1 $
            bridge_address2 $
            bridge_city $
            bridge_state $
            bridge_zip5 $
            bridge_md5email_id $
            ;

   label bridge_name_first = "First Name From Bridge";
   label bridge_name_last  = "Last Name From Bridge";
   label bridge_address1 = "Address Line 1 From Bridge";
   label bridge_address2 = "Address Line 2 From Bridge";
   label bridge_city = "Address City From Bridge";
   label bridge_state = "Address State From Bridge";
   label bridge_zip5 = "Address Zip 5 From Bridge";
   label bridge_md5email_id = "Unique ID To Append Email Addresses From Bridge";


   bridge_state =upcase(bridge_state);

   %do i=1 %to %sysfunc(countw(&sts));
       %if &i>1 %then %do; else if bridge_state="%scan(&sts,&i,' ')" then output brg_sas.bridge_%scan(&sts,&i,' '); %end;
       %else %do;               if bridge_state="%scan(&sts,&i,' ')" then output brg_sas.bridge_%scan(&sts,&i,' '); %end;
   %end; 

      output all_obs;
   run;

   %qc(data=all_obs);

   proc print data=all_obs(obs=100);run;

   %macro sortit;

      %let sts = AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY;
      %let sts_len= %sysfunc(countw(&sts));

      %do i=1 %to &sts_len;

         %let cstate = %lowcase(%qscan(&sts,&i));

         proc sort data=brg_sas.bridge_&cstate.;
            by bridge_zip5;
         run; 
  
      %end;

   %mend sortit;

   %sortit;


   x "mv ./file_listing.txt ./LOGS/file_listing_%lowcase(&sysdate).txt";
   x "mv ./qc_report_all_obs.htm ./LOGS/qc_report_all_obs_%lowcase(&sysdate).html" ;
   

   filename sendmail email to=("felixlu@cogensia.com") subject="QC REPORT OF Bridge SAS DATASETS" from="webmaster@cogensia.com" attach="./LOGS/qc_report_all_obs_%lowcase(&sysdate.).html";

   data _null_;

      file sendmail;
      put "                            QC REPORT OF BRIDGE SAS DATASETS                                    ";
      put "_____________________________________________________________________________________________";
      put "                                                                                             ";
      put "  Importing raw Bridge data has been done, the bridge SAS datasets are ready for use.        ";
      put "                                                                                             ";
      put "                                                                                             ";
      put "_____________________________________________________________________________________________";

   run; 

   x "cd /project/CACDIRECT/DATA/EM_FLAG/BRIDGE/RAW"; 
   x "mv *txt.gz OLD"; 

%mend import_bridge;

%import_Bridge;





