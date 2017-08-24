*;
* 010_carrier.sas;
*   Project: SARPINOS;
*   Project Manager: Mike Mattingly;
*   Author Rob Stoltz;
*   Date 10/13/2013;
*   Purpose Read-in CSV of carrier routes for stores and associate with new mover file read-in from 1000_NEW_MOVER in CACDIRECT;
*   11/05/2013 - Updated to dedupe on lname address zip.;
*   11/20/2014 - Migrated to Epsilon NM Data on RT server;

%include '/project/CACDIRECT/CODE/DEVELOPMENT/1000_NEW_MOVER/nm_master_includes.inc';
%include '/project/CACDIRECT/CODE/PROD/METADATA/INCLUDES/mover_includes.inc';   
			
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


%macro wtnm_cr_mailable(date=&date., maxdate_lastfile='01NOV2014'd);
*20141201 is next;
   %if %sysfunc(fileexist(/project/SARPINOS/DATA/&date./))=0 %then %do;
      x "mkdir /project/SARPINOS/DATA/&date./";
   %end;
   x "cd /project/SARPINOS/DATA/&date./";

   data sarp.carrier_routes;
      infile "/project/SARPINOS/CODE/INCLUDES/carrier_routes_20141120_translated_for_all_stores.csv" dsd delimiter=',' firstobs=2;
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

   proc sort data = nmsql.cogensia_movers out=cogensia_movers;
      by CAC_NM_ZIP_CODE CAC_NM_CARRIER_ROUTE;
   run;
   
   data sarp.WTNM_CR_&date.;
      merge cogensia_movers (in=a keep=CAC_NM_CARRIER_ROUTE CAC_NM_CITY CAC_NM_CONTRACTED_ADDR CAC_NM_CONTRACTED_NAME CAC_NM_DWELLING_ADDR_TYPE CAC_NM_DPV_FLAG 
                                       CAC_NM_FILE_DT CAC_NM_STATE_ABBREVIATION CAC_NM_ZIP_CODE CAC_NM_ZIPPLUS_4) 
            sarp.carrier_routes (in=b rename=(zip=CAC_NM_ZIP_CODE crte=CAC_NM_CARRIER_ROUTE));
      by CAC_NM_ZIP_CODE CAC_NM_CARRIER_ROUTE;
      if a and b  
           and not(missing(CAC_NM_CONTRACTED_ADDR) or missing(CAC_NM_CONTRACTED_NAME))
           and index(compress(CAC_NM_CONTRACTED_ADDR," -_"),"POBOX")=0
           and (CAC_NM_DWELLING_ADDR_TYPE = '1' or CAC_NM_DWELLING_ADDR_TYPE = '2')
           and CAC_NM_DPV_FLAG = 'Y'
           and &maxdate_lastfile.   <  CAC_NM_FILE_DT
           AND not(missing(CAC_NM_ZIPPLUS_4));  /*CAC_NM_FILE_DT not on last file*/
   run;

   %qc(data=sarp.WTNM_CR_&date.);

   *FELIX: USE PARSIMONY TO OBTAIN FIRST AND LAST NAME FROM CAC_NM_CONTRACTED_NAME;
   
   %parsimony(inlib=sarp, 
              indata=WTNM_CR_&date., 
              outlib=WORK, 
              outdata=WTNM_CR_MAILABLE_&date., 
              keep_clean=1, 
              keep_keys =0, 
              pname_form=1,
              pname1=CAC_NM_CONTRACTED_NAME, 
              paddr_form=1, 
              paddr1=CAC_NM_CONTRACTED_ADDR, 
              pstate=CAC_NM_STATE_ABBREVIATION, 
              pzip=CAC_NM_ZIP_CODE);
   
   proc sort data =WTNM_CR_MAILABLE_&date. (rename = (parse_name_first=CAC_NM_PARSE_NAME_FIRST  parse_name_last=CAC_NM_PARSE_NAME_LAST) );
      by CAC_NM_PARSE_NAME_LAST CAC_NM_CONTRACTED_ADDR CAC_NM_ZIP_CODE DESCENDING CAC_NM_FILE_DT CAC_NM_PARSE_NAME_FIRST CAC_NM_CITY CAC_NM_ZIPPLUS_4;
   run;
   
   data sarp.WTNM_CR_MAILABLE_&date.(drop = parse_addr_full parse_name_middle parse_name_suffix parse_name_title ) very_similar_wtf;
      set WTNM_CR_MAILABLE_&date.;    
      by CAC_NM_PARSE_NAME_LAST CAC_NM_CONTRACTED_ADDR CAC_NM_ZIP_CODE DESCENDING CAC_NM_FILE_DT CAC_NM_PARSE_NAME_FIRST CAC_NM_CITY CAC_NM_ZIPPLUS_4;
      if first.CAC_NM_ZIP_CODE then output sarp.WTNM_CR_MAILABLE_&date.;
      if not (first.CAC_NM_ZIPPLUS_4 and last.CAC_NM_ZIPPLUS_4) then output very_similar_wtf;
   run;

   /*BEGIN RSS 03DEC2014*/   
   /*ONETIME MODIFICATION TO ACCOMODATE CHANGE FROM INFUTOR TO EPSILON*/
   /*ONETIME MODIFICATION TO ACCOMODATE CHANGE FROM INFUTOR TO EPSILON*/
   /*ONETIME MODIFICATION TO ACCOMODATE CHANGE FROM INFUTOR TO EPSILON*/
   /*ONETIME MODIFICATION TO ACCOMODATE CHANGE FROM INFUTOR TO EPSILON*/
   /*NEEDED TO REMOVE DUPLICATES BY COMPARING TO LAST MONTH*/

   data nov (drop=fname lname);
      set sarp.wtnm_cr_mailable_20141103;
      format CAC_NM_PARSE_NAME_FIRST CAC_NM_PARSE_NAME_LAST $25. addr_5 $5.;
      CAC_NM_PARSE_NAME_FIRST = fname;
      CAC_NM_PARSE_NAME_LAST = lname;
      addr_5 = substr(address,1,5);
   run;
   
   proc sort nodupkey data = nov;
      by CAC_NM_PARSE_NAME_FIRST CAC_NM_PARSE_NAME_LAST addr_5;
   run;
   
   data wtnm_cr_mailable_&date.;
      set sarp.wtnm_cr_mailable_&date.;
      format addr_5 $5.;
      addr_5 = substr(CAC_NM_CONTRACTED_ADDR,1,5);
   run;
   
   proc sort data = wtnm_cr_mailable_&date.;
      by CAC_NM_PARSE_NAME_FIRST CAC_NM_PARSE_NAME_LAST addr_5;
   run;
   
   data sarp.wtnm_cr_mailable_&date. (drop=addr_5);
      merge wtnm_cr_mailable_&date. (in=a)
            nov (in=b keep = CAC_NM_PARSE_NAME_FIRST CAC_NM_PARSE_NAME_LAST addr_5);
      by CAC_NM_PARSE_NAME_FIRST CAC_NM_PARSE_NAME_LAST addr_5;
      if a and not b;
   run;

   /*END RSS 03DEC2014*/   

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
         put STORE_NUMBER CAC_NM_PARSE_NAME_FIRST CAC_NM_PARSE_NAME_LAST CAC_NM_CONTRACTED_ADDR CAC_NM_CITY CAC_NM_STATE_ABBREVIATION CAC_NM_ZIP_CODE CAC_NM_ZIPPLUS_4 CAC_NM_CARRIER_ROUTE;
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
/*   %send_csv(store=&store_list,date=&date.);  */
%send_qc;


