libname haha "/project/DS_DEV/DATA/TO_BRAD";
options mlogic mprint;

%let st_lst =AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY;
%let st_lst_len= %sysfunc(countw(&st_lst));

%macro haha();


%do i=1 %to &st_lst_len;

%let cstate = %lowcase(%qscan(&st_lst,&i)); 


proc sql ; create table NAICS_54181001_&i. as select 
               B2B_COMPANY_NAME, 
               B2B_ADDR_FULL,
               B2B_ADDR_STATE, 
               B2B_ADDR_ZIP5, 
               B2B_ADDR_CITY, 
               B2B_800_PHONE_NUM, 
               B2B_PHONE_NUM, 
               B2B_NAICS_CODE,
               B2B_NAICS_CODE_DESCRIP, 
               B2B_NAICS1, 
               B2B_NAICS1_DESCRIP, 
               B2B_NAICS2, 
               B2B_NAICS2_DESCRIP, 
               B2B_NAICS3, 
               B2B_NAICS3_DESCRIP, 
               B2B_NAICS4, 
               B2B_NAICS4_DESCRIP,
               B2B_BUSINESS_STATUS_CODE, 
               B2B_EMPLOYEE_SIZE, 
               B2B_SALES_VOLUME,
               B2B_FIRST_YEAR_CCYY,
               B2B_CONTACT_LAST_NAME,
               B2B_CONTACT_FIRST_NAME,
               B2B_CONTACT_TITLE, 
               B2B_CONTACT_TITLE_CODE,
               B2B_PRIMARY_SIC,
               B2B_PRIMARY_SIC_DESCRIP,
               ( (CASE WHEN missing(B2B_SECOND_CONTACT) then 0 else 1 end)+ (CASE WHEN missing(B2B_THIRD_CONTACT) then 0 else 1 end)+ (CASE WHEN missing(B2B_FOURTH_CONTACT) then 0 else 1 end)+
                 (CASE WHEN missing(B2B_FIFTH_CONTACT) then 0 else 1 end)+ (CASE WHEN missing(B2B_SIXTH_CONTACT) then 0 else 1 end)+1) as total_contacts   

from b2b.cac_b2b_&cstate. where B2B_NAICS_CODE = "54181001" or 
                                B2B_NAICS1     = "54181001" or 
                                B2B_NAICS2     = "54181001" or 
                                B2B_NAICS3     = "54181001" or 
                                B2B_NAICS4     = "54181001"; quit;


/* 2 */
proc sql ; create table NAICS_722511_&i. as select 
               B2B_COMPANY_NAME, 
               B2B_ADDR_FULL,
               B2B_ADDR_STATE, 
               B2B_ADDR_ZIP5, 
               B2B_ADDR_CITY, 
               B2B_800_PHONE_NUM, 
               B2B_PHONE_NUM, 
               B2B_SIC_CODE, 
               B2B_SIC_DESCRIP,
               B2B_SECONDARY_SIC_CODE1,
               B2B_SECONDARY_SIC_DESCRIP1,
               B2B_SECONDARY_SIC_CODE2,
               B2B_SECONDARY_SIC_DESCRIP2,
               B2B_SECONDARY_SIC_CODE3,
               B2B_SECONDARY_SIC_DESCRIP3,
               B2B_SECONDARY_SIC_CODE4,
               B2B_SECONDARY_SIC_DESCRIP4,
               B2B_NAICS_CODE,
               B2B_NAICS_CODE_DESCRIP, 
               B2B_NAICS1, 
               B2B_NAICS1_DESCRIP, 
               B2B_NAICS2, 
               B2B_NAICS2_DESCRIP, 
               B2B_NAICS3, 
               B2B_NAICS3_DESCRIP, 
               B2B_NAICS4, 
               B2B_NAICS4_DESCRIP,
               B2B_EMPLOYEE_SIZE, 
               B2B_SALES_VOLUME,
               B2B_FIRST_YEAR_CCYY,
               B2B_CONTACT_LAST_NAME,
               B2B_CONTACT_FIRST_NAME,
               B2B_CONTACT_TITLE, 
               B2B_BUSINESS_STATUS_CODE,
               B2B_CONTACT_TITLE_CODE,
               B2B_PRIMARY_SIC,
               B2B_PRIMARY_SIC_DESCRIP, 
               
               ( (CASE WHEN missing(B2B_SECOND_CONTACT) then 0 else 1 end)+ (CASE WHEN missing(B2B_THIRD_CONTACT) then 0 else 1 end)+ (CASE WHEN missing(B2B_FOURTH_CONTACT) then 0 else 1 end)+
                 (CASE WHEN missing(B2B_FIFTH_CONTACT) then 0 else 1 end)+ (CASE WHEN missing(B2B_SIXTH_CONTACT) then 0 else 1 end)+1) as total_contacts   

               from b2b.cac_b2b_&cstate. where (B2B_BUSINESS_STATUS_CODE ="1") and ( B2B_NAICS_CODE like "722511%" or B2B_PRIMARY_SIC like "5812%" or B2B_PRIMARY_SIC like "5813%" or B2B_NAICS1 like "722511%" or 
                                                                                     B2B_NAICS2 like "722511%"  or  B2B_NAICS3 like "722511%" or  B2B_NAICS4 like "722511%" or B2B_SECONDARY_SIC_CODE1 like "5812%" or
                                                                                     B2B_SECONDARY_SIC_CODE1 like "5813%" or B2B_SECONDARY_SIC_CODE2 like "5812%" or B2B_SECONDARY_SIC_CODE2 like "5813%" or 
                                                                                     B2B_SECONDARY_SIC_CODE3 like "5812%" or B2B_SECONDARY_SIC_CODE3 like "5813%" or B2B_SECONDARY_SIC_CODE4 like "5812%" or 
                                                                                     B2B_SECONDARY_SIC_CODE4 like "5813%")                                                                                      

              ; quit;
%end;



   data haha.NAICS_54181001;
      set 
      %do i=1 %to &st_lst_len;
          NAICS_54181001_&i.
      %end;
      ;
   run;

   data haha.NAICS_722511;
      set 
      %do i=1 %to &st_lst_len;
           NAICS_722511_&i.
      %end;
      ;
   run;

%mend;


%haha;


/*

filename file1 '/project/DS_DEV/DATA/TO_BRAD/NAICS_54181001_1.pdm';

data _null_;
   set haha.NAICS_54181001;
   file file1 dlm='|' dsd;
   if _n_=1 then put "B2B_COMPANY_NAME|B2B_ADDR_FULL|B2B_ADDR_STATE|B2B_ADDR_ZIP5|B2B_ADDR_CITY|B2B_800_PHONE_NUM|
put B2B_PHONE_NUM|B2B_NAICS_CODE|B2B_NAICS_CODE_DESCRIP|B2B_NAICS1|B2B_NAICS1_DESCRIP|B2B_NAICS2|
B2B_NAICS2_DESCRIP|B2B_NAICS3|B2B_NAICS3_DESCRIP|B2B_NAICS4|B2B_NAICS4_DESCRIP|B2B_BUSINESS_STATUS_CODE|
B2B_EMPLOYEE_SIZE|B2B_SALES_VOLUME|B2B_FIRST_YEAR_CCYY|B2B_CONTACT_LAST_NAME|B2B_CONTACT_FIRST_NAME|
B2B_CONTACT_TITLE|B2B_CONTACT_TITLE_CODE|B2B_PRIMARY_SIC|B2B_PRIMARY_SIC_DESCRIP|total_contacts";
   put B2B_COMPANY_NAME B2B_ADDR_FULL B2B_ADDR_STATE B2B_ADDR_ZIP5 B2B_ADDR_CITY B2B_800_PHONE_NUM B2B_PHONE_NUM
       B2B_NAICS_CODE B2B_NAICS_CODE_DESCRIP B2B_NAICS1 B2B_NAICS1_DESCRIP B2B_NAICS2 B2B_NAICS2_DESCRIP B2B_NAICS3 
       B2B_NAICS3_DESCRIP B2B_NAICS4 B2B_NAICS4_DESCRIP B2B_BUSINESS_STATUS_CODE B2B_EMPLOYEE_SIZE B2B_SALES_VOLUME 
       B2B_FIRST_YEAR_CCYY B2B_CONTACT_LAST_NAME B2B_CONTACT_FIRST_NAME B2B_CONTACT_TITLE B2B_CONTACT_TITLE_CODE 
       B2B_PRIMARY_SIC B2B_PRIMARY_SIC_DESCRIP total_contacts	;
run;

filename file2 '/project/DS_DEV/DATA/TO_BRAD/NAICS_722511_1.pdm';

data _null_;
   set haha.NAICS_722511;
   file file2 dlm='|' dsd;
   if _n_=1 then put "B2B_COMPANY_NAME|B2B_ADDR_FULL|B2B_ADDR_STATE|B2B_ADDR_ZIP5|B2B_ADDR_CITY|B2B_800_PHONE_NUM|
B2B_PHONE_NUM|B2B_SIC_CODE|B2B_SIC_DESCRIP|B2B_SECONDARY_SIC_CODE1|B2B_SECONDARY_SIC_DESCRIP1|
B2B_SECONDARY_SIC_CODE2|B2B_SECONDARY_SIC_DESCRIP2|	B2B_SECONDARY_SIC_CODE3|B2B_SECONDARY_SIC_DESCRIP3|
B2B_SECONDARY_SIC_CODE4|B2B_SECONDARY_SIC_DESCRIP4|B2B_NAICS_CODE|B2B_NAICS_CODE_DESCRIP|B2B_NAICS1|
B2B_NAICS1_DESCRIP|B2B_NAICS2|B2B_NAICS2_DESCRIP|B2B_NAICS3|B2B_NAICS3_DESCRIP|B2B_NAICS4|B2B_NAICS4_DESCRIP|
B2B_EMPLOYEE_SIZE|B2B_SALES_VOLUME|B2B_FIRST_YEAR_CCYY|B2B_CONTACT_LAST_NAME|B2B_CONTACT_FIRST_NAME|B2B_CONTACT_TITLE|
B2B_BUSINESS_STATUS_CODE|B2B_CONTACT_TITLE_CODE|B2B_PRIMARY_SIC|B2B_PRIMARY_SIC_DESCRIP|total_contacts";
   put B2B_COMPANY_NAME	B2B_ADDR_FULL B2B_ADDR_STATE B2B_ADDR_ZIP5	
       B2B_ADDR_CITY B2B_800_PHONE_NUM B2B_PHONE_NUM B2B_SIC_CODE
       B2B_SIC_DESCRIP B2B_SECONDARY_SIC_CODE1 B2B_SECONDARY_SIC_DESCRIP1
       B2B_SECONDARY_SIC_CODE2 B2B_SECONDARY_SIC_DESCRIP2 B2B_SECONDARY_SIC_CODE3	
       B2B_SECONDARY_SIC_DESCRIP3 B2B_SECONDARY_SIC_CODE4 B2B_SECONDARY_SIC_DESCRIP4 
       B2B_NAICS_CODE B2B_NAICS_CODE_DESCRIP B2B_NAICS1	B2B_NAICS1_DESCRIP 
       B2B_NAICS2 B2B_NAICS2_DESCRIP B2B_NAICS3 B2B_NAICS3_DESCRIP B2B_NAICS4	
       B2B_NAICS4_DESCRIP B2B_EMPLOYEE_SIZE B2B_SALES_VOLUME B2B_FIRST_YEAR_CCYY 
       B2B_CONTACT_LAST_NAME B2B_CONTACT_FIRST_NAME B2B_CONTACT_TITLE B2B_BUSINESS_STATUS_CODE 
       B2B_CONTACT_TITLE_CODE B2B_PRIMARY_SIC B2B_PRIMARY_SIC_DESCRIP total_contacts;
run;
*/

