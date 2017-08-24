/* 
libname smile "/project/DS_DEV/DATA";


proc sql noprint; select facilities_zip into: zip_list separated by " " from smile.zip_list;quit;

%let sts_len= %sysfunc(countw(&zip_list));

%macro haha;

%do i=1 %to &sts_len;
   
            %let zip = %qscan(&zip_list,&i);
            %let state = %sysfunc(zipstate(&zip));

            proc sql; create table smile.zip_&i as select * from smile.universe_1 where ZIPCITYDISTANCE(&zip, CAC_NM_ZIP_CODE) <5.1 and
                                                                           CAC_NM_STATE_ABBREVIATION = "&state";quit;

%end;

%mend;

%haha;
*/



libname smile "/project/DS_DEV/DATA";


%macro haha;

proc sql; select facilities_zip into: zip_list separated by " " from smile.zip_list;quit;

          data report;
             zipcode = 0;
             counts = 0;
          run;

%let sts_len= %sysfunc(countw(&zip_list));

%do i=1 %to &sts_len;

          %let zip = %qscan(&zip_list,&i);

          proc sql; select count(*) into: this_count from smile.zip_&i;quit;

          data this_report;
             zipcode = &zip;
             counts = &this_count;
          run;
  
          data report;
            set report
                this_report;
          run;
          

%end;

proc print data=report;run;


%mend;

%haha;
