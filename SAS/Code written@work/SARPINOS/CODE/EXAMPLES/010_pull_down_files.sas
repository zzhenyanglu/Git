*;
* 010_pull_down_files.sas;
*   Project: CNE RESI PROJECT;
*   Project Manager: Mike Mattingly;
*   Author Mike Mattingly;
*   Date 7/2013;
*   Purpose Pull down customer and do not market files from FTP site, check record counts, run dos2unix;
*   Inputs;
*   Outputs;
*   Updates;
options mprint merror mlogic;

%include '/project/CNE/CODE/005_METADATA/master_constellation_includes.inc';

%let status=DEV;
%let here=/project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/&status;
%global f_exist_count;
%let f_exist_count=0;

x "rm &here/cneresi_done_1.txt";

data _null_;
  mm=put(month(today()),z2.);
  dd=put(day(today()-1),z2.);
  yyyy=year(today());
  day=put(mm,2.)||put(dd,2.)||put(yyyy,4.);
  call symput('mfiledate',put(day,10.));
run;

%global filedate;
%let filedate=%trim(&mfiledate);
    
%macro process1(email=mmattingly@cac-group.com);
* SECTION 1 PULL DOWN FILES;
    
  x "cd &here";
  
  filename ftp "&here/auto_to_cac.bat";

  data _null_;
     file ftp;
      put 'ftp -inp ftp.cac-group.com <<!';
      put 'quote user const_en@cac-group.com';
      put 'quote pass 3n3rg^';
      put "get DoNotMarket.csv";
      put "cd DailyData";
      put "mget *&filedate..csv"; 
      put "cd ../DoNotMarket";
      put "mget *.csv";
      put 'bye';
      put 'quit';
      put '!';
  run;

  x "chmod +x &here/auto_to_cac.bat";
  x "&here/auto_to_cac.bat";
  
  x "wc -l /project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/&status/*csv > /project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/&status/WC_FILES/wc_&filedate";

%mend process1;
%process1(email=mmattingly@cac-group.com);


* SECTION 2 DETERMINE IF FILES WERE RECEIVED; 
  %macro check_if_files_received(checkthisfile=,email=mmattingly@cac-group.com);

       %if %sysfunc(fileexist(&checkthisfile)) %then %do;
           %put The file &checkthisfile exists!;
           %let f_exist_count=%eval(&f_exist_count+1);
       %end;
       %else %do;
              
          filename mail80 email to=("&email") 
	                         subject="Error Message from CNE RESi Procsseing"
	                         from="webmaster@cac-group.com";
	  data _null_;
	    file mail80;
            put "The file";
            put &checkthisfile;
            put "does not exist";
            put "Please check 010_pull_down_files.log for further details";
	  run;                
      
          x "mv &here/*ENROLLS*csv /project/CNE/DATA/RAW/CUSTOMERS/NEW_FROM_PALLAVI/.";
          x "mv &here/*CUST*csv /project/CNE/DATA/RAW/CUSTOMERS/NEW_FROM_PALLAVI/.";
          x "mv &here/*cust*csv /project/CNE/DATA/RAW/CUSTOMERS/NEW_FROM_PALLAVI/.";
          x "mv &here/Ameren*csv /project/CNE/DATA/RAW/DONOTMARKET/.";
          x "mv &here/DNC*csv /project/CNE/DATA/RAW/DONOTMARKET/.";  
          x "mv &here/DoNotMarket*csv /project/CNE/DATA/RAW/DONOTMARKET/.";  
              
          endsas;
       %end;

  %mend check_if_files_received;
  %check_if_files_received(checkthisfile="/project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/DEV/CNE_cust_&filedate..csv");
  %check_if_files_received(checkthisfile="/project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/DEV/CNE_ENROLLS_&filedate..csv");
  %check_if_files_received(checkthisfile="/project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/DEV/MX_CUST_&filedate..csv");
  %check_if_files_received(checkthisfile="/project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/DEV/MX_ENROLLS_&filedate..csv");
  %check_if_files_received(checkthisfile="/project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/DEV/STP_CUST_&filedate..csv");
  %check_if_files_received(checkthisfile="/project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/DEV/USF_ENROLLS_&filedate..csv");
  %check_if_files_received(checkthisfile="/project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/DEV/Ameren.csv");
  %check_if_files_received(checkthisfile="/project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/DEV/DNCPhoneList.csv");
  %check_if_files_received(checkthisfile="/project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/DEV/DNCEmailList.csv");
  %check_if_files_received(checkthisfile="/project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/DEV/DNCD2DList.csv");
  %check_if_files_received(checkthisfile="/project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/DEV/DNCMailList.csv");
  %check_if_files_received(checkthisfile="/project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/DEV/DoNotMarket.csv ");

* SECTION 3 DETERMINE RECORD COUNTS; 
  %macro process2(email=mmattingly@cac-group.com);

      %let cne_data_receipt=0;

      data daily_log;          
          infile "/project/CNE/CODE/030_PROSPECTING_SYSTEM/100_CUSTOMER_PROCESSING/&status/WC_FILES/wc_&filedate" dsd dlm=' ' missover lrecl=32767 ;    
            informat record_cnt $10.
                     cne_full_filename $100.;

            input @1 record_cnt $char10.
                  @11 cne_full_filename $; 
 
            length cne_filename $32.;
            cne_filename=strip(scan(cne_full_filename,7,'/'));
            if cne_full_filename='total' then delete;

            format processed_date mmddyy10.;  
            processed_date=today();
 
            length job_description $32.;
            job_description="010_pull_down_files.sas";
        
            * fileprefix=strip(scan(cne_filename,1,'_'))||"_"||strip(scan(cne_filename,2,'_')); 

            length status $3.;
        
            if upcase(strip(cne_filename))="CNE_CUST_&filedate..CSV" then f_ratio=(record_cnt/150000);
             else if upcase(strip(cne_filename))="CNE_ENROLLS_&filedate..CSV" then f_ratio=(record_cnt/39000);
             else if upcase(strip(cne_filename))="MX_CUST_&filedate..CSV" then f_ratio=(record_cnt/750000);   
             else if upcase(strip(cne_filename))="MX_ENROLLS_&filedate..CSV" then f_ratio=(record_cnt/190000);
             else if upcase(strip(cne_filename))="STP_CUST_&filedate..CSV" then f_ratio=(record_cnt/130000);
             else if upcase(strip(cne_filename))="USF_ENROLLS_&filedate..CSV" then f_ratio=(record_cnt/42000);
             else if upcase(strip(cne_filename))="STP_ENROLLS_&filedate..CSV" then f_ratio=(record_cnt/33000);
         
             else if strip(cne_filename)="Ameren.csv" then f_ratio=(record_cnt/3500);
             else if strip(cne_filename)="DNCPhoneList.csv" then f_ratio=(record_cnt/836000);
             else if strip(cne_filename)="DNCEmailList.csv" then f_ratio=(record_cnt/76066);
             else if strip(cne_filename)="DNCD2DList.csv" then f_ratio=(record_cnt/105370);
             else if strip(cne_filename)="DNCMailList.csv" then f_ratio=(record_cnt/109000);   
             else if strip(cne_filename)="DoNotMarket.csv" then f_ratio=(record_cnt/945766);
         
             if cne_filename='campaign_details.csv' then delete;
         
             if .8 <= f_ratio <= 1.2 then status="OK";
              else status="BAD";

             if status="OK" then call symput('CNE_DATA_RECEIPT',"1");
    
             drop cne_full_filename;
      run;

      %put &cne_data_receipt;
  
      proc print data=daily_log;
      run;
  
      x "mv &here/*ENROLLS*csv /project/CNE/DATA/RAW/CUSTOMERS/NEW_FROM_PALLAVI/.";
      x "mv &here/*CUST*csv /project/CNE/DATA/RAW/CUSTOMERS/NEW_FROM_PALLAVI/.";
      x "mv &here/*cust*csv /project/CNE/DATA/RAW/CUSTOMERS/NEW_FROM_PALLAVI/.";
      x "mv &here/Ameren*csv /project/CNE/DATA/RAW/DONOTMARKET/.";
      x "mv &here/DNC*csv /project/CNE/DATA/RAW/DONOTMARKET/.";  
      x "mv &here/DoNotMarket*csv /project/CNE/DATA/RAW/DONOTMARKET/.";  
  
      x "dos2unix -n /project/CNE/DATA/RAW/DONOTMARKET/Ameren.csv /project/CNE/DATA/RAW/DONOTMARKET/Ameren_unix.csv";  
      x "dos2unix -n /project/CNE/DATA/RAW/DONOTMARKET/DNCPhoneList.csv /project/CNE/DATA/RAW/DONOTMARKET/DNCPhoneList_unix.csv";   
      x "dos2unix -n /project/CNE/DATA/RAW/DONOTMARKET/DNCEmailList.csv /project/CNE/DATA/RAW/DONOTMARKET/DNCEmailList_unix.csv"; 
      x "dos2unix -n /project/CNE/DATA/RAW/DONOTMARKET/DNCD2DList.csv /project/CNE/DATA/RAW/DONOTMARKET/DNCD2DList_unix.csv"; 
      x "dos2unix -n /project/CNE/DATA/RAW/DONOTMARKET/DNCMailList.csv /project/CNE/DATA/RAW/DONOTMARKET/DNCMailList_unix.csv";  
      x "dos2unix -n /project/CNE/DATA/RAW/DONOTMARKET/DoNotMarket.csv /project/CNE/DATA/RAW/DONOTMARKET/DoNotMarket_unix.csv";


    * SECTION 4 UPDATE LOG FILE;
    %if %sysfunc(exist(cdets.cne_resi_log)) %then %do;
        data cdets.cne_resi_log; 
          set cdets.cne_resi_log
              daily_log;
        run;
    %end;

    %else %do;
        data cdets.cne_resi_log;
          set daily_log;
        run;
    %end;

    ods html body="/project/CNE/CODE/030_PROSPECTING_SYSTEM/cne_resi_pull_down_files.htm";
      title1 "Summary Report for Pull Down of CNE RESi Customer Files";
      proc print data=daily_log noobs;
      run;
    ods html close;

    %if &cne_data_receipt=0 %then %do;
                 filename mail80 email to=("&email") 
	                         subject="Error Message from CNE RESi Procsseing"
	                         from="webmaster@cac-group.com"
                                 attach="/project/CNE/CODE/030_PROSPECTING_SYSTEM/cne_resi_pull_down_files.htm";
	  data _null_;
	    file mail80;
            put "Either the input file was not posted or the Record count of an input file is outside threshold";
            put "Please check cdets.cne_resi_log for details";
	  run;    

   %end;

   %else %if &cne_data_receipt=1 %then %do;
             x "touch &here/cneresi_done_1.txt";
   %end;

%mend process2;
%process2(email=mmattingly@cac-group.com);
endsas;
