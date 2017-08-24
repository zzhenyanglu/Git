*;
* 010_carrier.sas;
*   Project: SARPINOS;
*   Project Manager: Mike Mattingly;
*   Author Rob Stoltz;
*   Date 10/13/2013;
*   Purpose Read-in CSV of carrier routes for stores and associate with new mover file read-in from 1000_NEW_MOVER in CACDIRECT;
*   11/05/2013 - Updated to dedupe on lname address zip.;

%include '/project/CACDIRECT/CODE/DEVELOPMENT/1000_NEW_MOVER/nm_master_includes.inc';
libname sarp '/project/SARPINOS/DATA';
%let email=rstoltz@cogensia.com;


x "cd /project/SARPINOS/DATA/&date./";
x "rm *htm";

data sarp.carrier_routes;
   infile "/project/SARPINOS/CODE/INCLUDES/carrier_routes_20131007.csv" dsd delimiter=',' firstobs=2;
   informat
           STORE_NUMBER $8.
           STORE_NAME $100.
           ZIP $5.
           CRTE $4.;
    input
           STORE_NUMBER $
           STORE_NAME $
           ZIP $
           CRTE $;
run;

proc contents data = sarp.carrier_routes; run;
%qc(data=sarp.carrier_routes);

proc sort data = sarp.carrier_routes;
   by zip crte;
run;

proc sort data = nm.WTNM;
   by zip crte;
run;

data sarp.WTNM_CR_&date.;
   merge nm.WTNM (in=a)
         sarp.carrier_routes (in=b);
   by zip crte;
   if a and b;
run;

%qc(data=sarp.WTNM_CR_&date.);

proc sort data = sarp.WTNM_CR_&date. (where=(MAILABLE='Y'                                     /* mailable just means it can be mailed, needs additional qualifiers */
                               and prod_active = 1                                  /* statusdate in last 30 days */
                               and (missing(POTENTIALLY_NOT_A_MOVER) or POTENTIALLY_NOT_A_MOVER ne 'Y') /* self explanatory */
                               and not(zip_4_type_code in ('G','P'))                                    /* General Delivery and PO BOXes */
                               and fname not in ('AA','AAA','AAAA','AAAAA','AAAAAA','AAAAAA','AAAAAAA','AAAAAAAA') /* glitch that Natalia is investigating */
                               and not(missing(address))                                                           /* some mailable addresses have no address, not a bug */
                               and not(missing(fname) and missing(lname))                    /*most of the names are either family names or someone typed the whole name in one box*/
                               )
                            ) out = sarp.WTNM_CR_MAILABLE_&date.;
   by lname address zip DESCENDING procdate DESCENDING statusdate fname city zip_4;
run;
    

data sarp.WTNM_CR_MAILABLE_&date. very_similar_wtf;
   set sarp.WTNM_CR_MAILABLE_&date.;
   by lname address zip DESCENDING procdate DESCENDING statusdate fname city zip_4;
   if first.zip then output sarp.WTNM_CR_MAILABLE_&date.;
   if not (first.zip_4 and last.zip_4) then output very_similar_wtf;
run;

proc print data = very_similar_wtf (obs=10); run;

%qc(data=sarp.WTNM_CR_MAILABLE_&date.);


%macro store_csvs(stores=,ftp=Y,date=);
      
   %if %sysfunc(fileexist(/project/SARPINOS/DATA/&date./))=0 %then %do;
      x "mkdir /project/SARPINOS/DATA/&date./";
   %end;

   x "cd /project/SARPINOS/DATA/&date./";
   x "rm sarpinos_mailable_store_*_&date..csv";
   x "rm sarpinos_&date..zip";
   x "rm sarpinos_qc_&date..zip";

   %if &stores = %then %do;
      
      proc sort nodupkey data = sarp.carrier_routes out=stores;
         by STORE_NUMBER;
      run;
      
      filename stores temp;
   
      data _null_;
         set stores end=eof;
         file stores;
         if _n_=1 then put '%let stores=';
         putvar =  " " || STORE_NUMBER;
         put putvar;
         if eof then put ';';
      run;

      %include stores;

   %end;

   %do curr_store=1 %to %sysfunc(countw(&stores," "));
      
      %let store=%trim(%scan(&stores,&curr_store," "));

      data sarp.WTNM_CR_MAILABLE_&store._&date.;
         set sarp.WTNM_CR_MAILABLE_&date. (where=( store_number="&store" ));
      run;
     
      %nobs(data=sarp.WTNM_CR_MAILABLE_&store._&date.);

      data _null_;
         file "/project/SARPINOS/DATA/&date./sarpinos_mailable_store_&store._&date..csv" lrecl=1000 dlm=',';
         set sarp.WTNM_CR_MAILABLE_&store._&date.;     
         if _n_=1 then put "&nobs.,%sysfunc(putn(%sysfunc(today()),mmddyy10.))";    
         if _n_=1 then put "store_number,fname,lname,address,city,state,zip,zip_4,crte";
         put STORE_NUMBER fname lname address city state zip zip_4 crte;
      run;

 
      %qc(data=sarp.WTNM_CR_MAILABLE_&store._&date.);
      
      proc freq noprint data = sarp.WTNM_CR_MAILABLE_&store._&date.;
         table store_number*store_name / out=temp;
      run;
      
      proc print data = temp (where=(count>0)); run;
      
   %end; 

   %if &ftp = Y %then %do;
   
      x "cd /project/SARPINOS/DATA/&date./";

      x "ls -l sarpinos_mailable_store_*_&date..csv > ls.txt";
      x "wc -l `find sarpinos_mailable_store_*_&date..csv -type f` > wc.txt";
   
      data ls;
         infile "/project/SARPINOS/DATA/&date./ls.txt" delimiter=' ' missover;
         informat
                 size 24.
                 file $100.
            ;
         input
              _junk1 $
              _junk2 $
              _junk3 $
              _junk4 $
              size
              _junk5 $
              _junk6 $
              _junk7 $
              file $
            ;
      run;   
      
      data wc;
         infile "/project/SARPINOS/DATA/&date./wc.txt" delimiter=' ' missover;
         informat
                 line_count 24.
                 file $100.
            ;
         input
               line_count
               file $
            ;
      run;
      
      x "rm ls.txt";
      x "rm wc.txt";
      x "zip sarpinos_&date..zip sarpinos_mailable_store_*_&date..csv";
      x "rm sarpinos_mailable_store_*_&date..csv";

      x "cd /project/SARPINOS/CODE/";
     
      x "echo %bquote('/project/SARPINOS/CODE/sftp_dl.sh  sarpinos 192.168.100.2 v06x\@ put /project/SARPINOS/DATA/&date./sarpinos_&date..zip
         /SARPINOS/sarpinos_&date..zip /project/SARPINOS/DATA/&date./return_sarpinos_&date..zip') > sftp_dl_launcher.sh";
   
      x "chmod 777 /project/SARPINOS/CODE/sftp_dl_launcher.sh";
   
      x "./sftp_dl_launcher.sh"; 
      x "rm ./sftp_dl_launcher.sh";

      x "cd /project/SARPINOS/DATA/&date./";
      x "unzip -o return_sarpinos_&date..zip";
      x "ls -l sarpinos_mailable_store_*_&date..csv > ls.txt";
      x "wc -l `find sarpinos_mailable_store_*_&date..csv -type f` > wc.txt";
   
      data ls_return;
         infile "/project/SARPINOS/DATA/&date./ls.txt" delimiter=' ' missover;
         informat
                 size_return 24.
                 file $100.
            ;
         input
              _junk1 $
              _junk2 $
              _junk3 $
              _junk4 $
              size_return
              _junk5 $
              _junk6 $
              _junk7 $
              file $
            ;
      run;   
      
      data wc_return;
         infile "/project/SARPINOS/DATA/&date./wc.txt" delimiter=' ' missover;
         informat
                 line_count_return 24.
                 file $100.
            ;
         input
               line_count_return
               file $
            ;
      run;

      x "rm ls.txt";
      x "rm wc.txt";
      x "rm sarpinos_mailable_store_*_&date..csv";

      proc sort data = ls; by file; run;
      proc sort data = wc; by file; run;
      proc sort data = ls_return; by file; run;
      proc sort data = wc_return; by file; run;

      data ls_wc_join;
         merge ls (drop= _: in=a)
               wc (in=b)
               ls_return (drop= _: in=c)
               wc_return (in=d);
         by file;
         if a and b and c and d;
      run;

      %nobs(data=ls);
      %let obs_sent=&nobs;
      
      %nobs(data=ls_return);
      %let obs_rec=&nobs;
      

      ods html file="./sarpinos_qc_&date..htm" /*style=minimal */;

           TITLE1 "QC REPORT for SARPINOS NEW MOVER LISTS";
              TITLE2 "NEW MOVER FILE DATE: &date.";
              TITLE3 "DELIVERY DATE: %sysfunc(putn(%sysfunc(today()),mmddyy10.))";
              TITLE4 "NUMBER OF STORE FILES SENT: &obs_sent";
              %if &obs_sent = &obs_rec %then %do;
                 TITLE5 "RECEIPT OF ALL FILES VERIFIED";
              %end;
              %else %do;
                 TITLE5 "RECEIPT OF ALL FILES NOT VERIFIED!!!";
              %end;
              proc sql;

               TITLE6 "FILE STATISTICS";
               select 
                  file as FILE_NAME label="FILE NAME",
                  size as SIZE_PRE label="FILE SIZE PRE-DELIVERY (BYTES)",
                  line_count as LC_PRE label="LINE COUNT PRE-DELIVERY",
                  size_return as SIZE_POST label="FILE SIZE POST-DELIVERY (BYTES)",
                  line_count_return as LC_POST label="LINE COUNT POST-DELIVERY"
               from ls_wc_join; 

      ods html close;


      filename mail1 email to=("&email") 
                             subject="Sarpinos New Mover QC for %sysfunc(putn(%sysfunc(today()),mmddyy10.))" 
                             from="webmaster@cac-group.com"
                             attach="./sarpinos_qc_&date..htm";
           
       data _null_;
         file mail1;
         put "QC Report for Sarpinos New Mover";
         put "Run Date: %sysfunc(putn(%sysfunc(today()),mmddyy10.))";
         put "New Mover Data Date: &date.";
         put "Number of Store Files Delivered: &obs_rec.";
       run;

      x "zip sarpinos_qc_&date..zip *htm";
      x "rm *htm";

   %end;





%mend store_csvs;
%store_csvs(ftp=Y,date=&date);





