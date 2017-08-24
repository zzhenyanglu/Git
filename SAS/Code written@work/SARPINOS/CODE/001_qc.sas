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


%macro wtnm_cr_mailable(date=&date.);

   %if %sysfunc(fileexist(/project/SARPINOS/DATA/&date./))=0 %then %do;
      x "mkdir /project/SARPINOS/DATA/&date./";
   %end;
   x "cd /project/SARPINOS/DATA/&date./";

   data carrier_routes;
      infile "/project/SARPINOS/CODE/INCLUDES/carrier_routes_20131007_translated_for_new_stores.csv" dsd delimiter=',' firstobs=2;
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
   
   proc contents data = carrier_routes; run;
   %qc(data=carrier_routes);
   
   proc sort data = carrier_routes;
      by zip crte;
   run;
   
   proc sort data = nm.WTNM;
      by zip crte;
   run;
   
   data WTNM_CR_&date.;
      merge nm.WTNM (in=a)
            carrier_routes (in=b);
      by zip crte;
      if a and b;
   run;
   
   %qc(data=WTNM_CR_&date.);

   
   proc sort data = WTNM_CR_&date. (where=(MAILABLE='Y'                                     /* mailable just means it can be mailed, needs additional qualifiers */
                                  and prod_active = 1                                  /* statusdate in last 30 days */
                                  and (missing(POTENTIALLY_NOT_A_MOVER) or POTENTIALLY_NOT_A_MOVER ne 'Y') /* self explanatory */
                                  and not(zip_4_type_code in ('G','P'))                                    /* General Delivery and PO BOXes */
                                  and fname not in ('AA','AAA','AAAA','AAAAA','AAAAAA','AAAAAA','AAAAAAA','AAAAAAAA') /* glitch that Natalia is investigating */
                                  and not(missing(address))                                                           /* some mailable addresses have no address, not a bug */
                                  and not(missing(fname) and missing(lname))                    /*most of the names are either family names or someone typed the whole name in one box*/
                                  and not(missing(house_number)) and not(missing(street_name))
                                  )
                               ) out = sarp.WTNM_CR_MAILABLE_&date.;
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

%macro prints;
   %let fields = fname house_number income lname;
   %let testobs= 20;

   %do i = 1 %to %sysfunc(countw(&fields," "));
      %let field = %scan(&fields,&i," ");
      title "Print of Full File Missing &field";
      proc print data = WTNM_CR_&date. (where=(missing(&field)) obs=&testobs); run;
      title "Print of Mailable File Missing &field";
      proc print data = sarp.WTNM_CR_MAILABLE_&date. (where=(missing(&field)) obs=&testobs); run;
   %end;

%mend prints; %prints;


%flat (data = sarp.WTNM_CR_MAILABLE_&date., path=./ , outfile=mailable, idvar = procdate);

%mend wtnm_cr_mailable;

%wtnm_cr_mailable(date=&date.);
