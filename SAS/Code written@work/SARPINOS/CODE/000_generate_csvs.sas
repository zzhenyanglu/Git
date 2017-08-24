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
libname mysqllib mysql user=usr_srp password=FNyCV89hHErLDB7K database=sarpinos server=216.157.38.64 port=3306; 

%macro update_date_cut;

   proc sql;
      connect to mysql  (user=usr_srp password=FNyCV89hHErLDB7K server=216.157.38.64 
        database=sarpinos port=3306); 
      execute(update tbl_transaction
         set date_cut = sysdate() 
         where date_cut is null and date_requested is not null) by mysql;
      execute(commit) by mysql;
      disconnect from mysql;
   quit;

%mend update_date_cut;


%macro wtnm_cr_mailable(date=&date., maxdate_lastfile=20140831);
*20141031 is next;
   %if %sysfunc(fileexist(/project/SARPINOS/DATA/&date./))=0 %then %do;
      x "mkdir /project/SARPINOS/DATA/&date./";
   %end;
   x "cd /project/SARPINOS/DATA/&date./";

   data sarp.carrier_routes;
      infile "/project/SARPINOS/CODE/INCLUDES/carrier_routes_20140903_translated_for_all_stores.csv" dsd delimiter=',' firstobs=2;
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
      statusdate_num = mdy(substr(statusdate,5,2),substr(statusdate,7,2),substr(statusdate,1,4));
   run;
   
   %qc(data=sarp.WTNM_CR_&date.);

   %let maxdate_lastfile = %sysfunc(mdy(%substr(&maxdate_lastfile,5,2),%substr(&maxdate_lastfile,7,2),%substr(&maxdate_lastfile,1,4)));

   proc sort data = sarp.WTNM_CR_&date. (where=(MAILABLE='Y'                                     /* mailable just means it can be mailed, needs additional qualifiers */
                                  and prod_active = 1                                /* statusdate in last 30 days*/
                                  and &maxdate_lastfile.   <  statusdate_num  /*statusdate not on last file*/
                                  and (missing(POTENTIALLY_NOT_A_MOVER) or POTENTIALLY_NOT_A_MOVER ne 'Y') /* self explanatory */
                                  and not(zip_4_type_code in ('G','P'))                                    /* General Delivery and PO BOXes */
                                  and fname not in ('AA','AAA','AAAA','AAAAA','AAAAAA','AAAAAA','AAAAAAA','AAAAAAAA') /* glitch that Natalia is investigating */
                                  and not(missing(address))                                                           /* some mailable addresses have no address, not a bug */
                                  and not(missing(fname) and missing(lname))                    /*most of the names are either family names or someone typed the whole name in one box*/
                                  and not(missing(house_number)) and not(missing(street_name))
                                  and not(dwelling='M' and (dpv ne 'Y' or missing(unit_number)))
                                  )
                               ) out = sarp.WTNM_CR_MAILABLE_&date. (drop=statusdate_num);
      by lname house_number street_name zip DESCENDING procdate DESCENDING statusdate fname city zip_4;
   run;
       
   data sarp.WTNM_CR_MAILABLE_&date. very_similar_wtf;
      set sarp.WTNM_CR_MAILABLE_&date.;
      by lname house_number street_name zip DESCENDING procdate DESCENDING statusdate fname city zip_4;
      if first.zip then output sarp.WTNM_CR_MAILABLE_&date.;
      if not (first.zip_4 and last.zip_4) then output very_similar_wtf;
   run;
   
   proc print data = very_similar_wtf (obs=10); run;
   
   %qc(data=sarp.WTNM_CR_MAILABLE_&date.);

%mend wtnm_cr_mailable;

%macro make_csvs(stores=,ftp=Y,date=);
      
   %if %sysfunc(fileexist(/project/SARPINOS/DATA/&date./))=0 %then %do;
      x "mkdir /project/SARPINOS/DATA/&date./";
   %end;

   x "cd /project/SARPINOS/DATA/&date./";
   x "rm sarpinos_mailable_store_*_&date..csv";

   %if &stores = %then %do;
      /*
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
      */
      endsas;
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
      
      %send_csv(store=&store, date=&date);

   %end; 

%mend make_csvs;


%macro send_csv(store=,date=);

   x "cd /project/SARPINOS/DATA/&date./";
   x "ls -l sarpinos_mailable_store_&store._&date..csv > ls.txt";
   x "wc -l `find sarpinos_mailable_store_&store._&date..csv -type f` > wc.txt";

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

      data ls_all;
         set ls    
         %if %sysfunc(exist(ls_all))=1 %then %do; ls_all %end;
         ;
      run;

      data wc_all;
         set wc    
         %if %sysfunc(exist(wc_all))=1 %then %do; wc_all %end;
         ;
      run;

      x "cd /project/SARPINOS/CODE/";
   
      filename ftp "/project/SARPINOS/CODE/ftp_script.sh";
      data _null_;
         file ftp;
         put "cd /project/SARPINOS/DATA/&date./";
         putvar="sarpinos_mailable_store_&store._&date..csv";
         put 'ftp -in 216.157.38.64 <<!';
         put 'quote user const';
         put 'quote pass BearDown_15';
         put 'cd sarpinos_adm';
         put 'bin';
         put "delete &store..csv";
         put 'put ' putvar " &store..csv";
         put "get &store..csv return_sarpinos_mailable_store_&store._&date..csv";
         put 'bye';
         put 'quit';
         put '!';
      run;

         x "chmod a+wrx /project/SARPINOS/CODE/ftp_script.sh";
         x "/project/SARPINOS/CODE/ftp_script.sh";   

   x "cd /project/SARPINOS/DATA/&date./";

   x "zip sarpinos_&date..zip sarpinos_mailable_store_&store._&date..csv";
   x "rm sarpinos_mailable_store_&store._&date..csv";

   x "ls -l  return_sarpinos_mailable_store_&store._&date..csv > ls.txt";
   x "wc -l `find return_sarpinos_mailable_store_&store._&date..csv -type f` > wc.txt";

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
      if index(file,"return_")>0 then file = substr(file,8,length(file)-7);
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
      if index(file,"return_")>0 then file = substr(file,8,length(file)-7);
   run;

   x "rm ls.txt";
   x "rm wc.txt";

   data ls_return_all;
      set ls_return    
      %if %sysfunc(exist(ls_return_all))=1 %then %do; ls_return_all %end;
      ;
   run;

   data wc_return_all;
      set wc_return    
      %if %sysfunc(exist(wc_return_all))=1 %then %do; wc_return_all %end;
      ;
   run;

   x "zip sarpinos_&date..zip return_sarpinos_mailable_store_&store._&date..csv";
   x "rm return_sarpinos_mailable_store_&store._&date..csv";


%mend send_csv;


%macro send_qc;

   proc sort data = ls_all; by file; run;
   proc sort data = wc_all; by file; run;
   proc sort data = ls_return_all; by file; run;
   proc sort data = wc_return_all; by file; run;

   data ls_wc_join;
      merge ls_all (drop= _: in=a)
            wc_all (in=b)
            ls_return_all (drop= _: in=c)
            wc_return_all (in=d);
      by file;
      if a and b and c and d;
   run;

   %nobs(data=ls_all);
   %let obs_sent=&nobs;
   
   %nobs(data=ls_return_all);
   %let obs_rec=&nobs;

   %let qc = ./sarpinos_qc_&date._;

   %let j=1;
   %do %while (%sysfunc(fileexist(&qc.&j..zip))=1);
      %let j = %eval(&j + 1);
   %end;   

   ods html file="&qc.&j..htm" /*style=minimal */;

        TITLE1 "QC REPORT for SARPINOS NEW MOVER LISTS";
           TITLE2 "NEW MOVER FILE DATE: &date.";
           TITLE3 "DELIVERY DATE: %sysfunc(putn(%sysfunc(today()),mmddyy10.))";
           TITLE4 "NUMBER OF STORE FILES SENT: &obs_sent";
           %if &obs_sent = &obs_rec %then %do;
              TITLE5 "RECEIPT OF ALL FILES VERIFIED";
           %end;
           %else %do;
              TITLE5 "!!!RECEIPT OF ALL FILES NOT VERIFIED!!! DATE_CUT NOT UPDATED! FIX THIS!!!";
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
                          attach="&qc.&j..htm";
        
    data _null_;
      file mail1;
      %if  not(&obs_sent = &obs_rec) %then %do;
      put "!!!RECEIPT OF ALL FILES NOT VERIFIED!!! DATE_CUT NOT UPDATED! FIX THIS!!!";
      %end;
      put "QC Report for Sarpinos New Mover";
      put "Run Date: %sysfunc(putn(%sysfunc(today()),mmddyy10.))";
      put "New Mover Data Date: &date.";
      put "Number of Store Files Delivered: &obs_rec.";
    run;

   x "zip &qc.&j..zip *htm";
   x "rm *htm";

   %if &obs_sent = &obs_rec %then %do;
      %update_date_cut;
   %end;

   x "cp -p /project/SARPINOS/CODE/000_generate_csvs.sas /project/SARPINOS/CODE/000_generate_csvs_&j..sas";
   x "cp -p /project/SARPINOS/CODE/000_generate_csvs.log /project/SARPINOS/CODE/000_generate_csvs_&j..log";
   x "cp -p /project/SARPINOS/CODE/000_generate_csvs.lst /project/SARPINOS/CODE/000_generate_csvs_&j..lst";
   x "zip -j &qc.&j..zip /project/SARPINOS/CODE/000*_&j.*";
   x "rm /project/SARPINOS/CODE/000*_&j.*";

%mend send_qc;

%macro get_stores;

   %global store_list;
   %let store_list=;

   proc sql;
      create table stores as 
      select b.srp_id from (
            select * from  mysqllib.tbl_transaction where not(missing(date_requested)) and missing(date_cut)
            ) a
      join mysqllib.tbl_store b on a.store_id = b.id;
   quit;

   %let dupe_stores =;

   proc sort data = stores;
      by srp_id; 
   run;

   data _null_;
      set stores;
      by srp_id;
      if first.srp_id then call symput("store_list",symget("store_list")||" "||srp_id);
      else call symput("dupe_stores",symget("dupe_stores")||" "||srp_id);
   run;

   %if %length(&dupe_stores)>0 %then %do;

      filename mail1 email to=("&email") 
                          subject="Sarpinos New Mover Duplicate Transactions" 
                          from="webmaster@cac-group.com";

      data _null_;
         file mail1;
         put "Stores %cmpres(&dupe_stores) had duplicate transaction requests.  All requests for a store will be treated as current and as one request!";
      run;

   %end;
   
%put &store_list;

%mend get_stores;

%get_stores;
%wtnm_cr_mailable(date=&date.);
%make_csvs(stores=&store_list,ftp=Y,date=&date.);
%send_qc;
%*send_csvs(date=&date.);


endsas;













%macro send_csvs(date=);

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
              TITLE5 "!!!RECEIPT OF ALL FILES NOT VERIFIED!!! DATE_CUT NOT UPDATED! FIX THIS!!!";
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
      %if  not(&obs_sent = &obs_rec) %then %do;
      put "!!!RECEIPT OF ALL FILES NOT VERIFIED!!! DATE_CUT NOT UPDATED! FIX THIS!!!";
      %end;
      put "QC Report for Sarpinos New Mover";
      put "Run Date: %sysfunc(putn(%sysfunc(today()),mmddyy10.))";
      put "New Mover Data Date: &date.";
      put "Number of Store Files Delivered: &obs_rec.";
    run;

   x "zip sarpinos_qc_&date..zip *htm";
   x "rm *htm";

   %if &obs_sent = &obs_rec %then %do;
      %update_date_cut;
   %end;


%mend send_csvs;
