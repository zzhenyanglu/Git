
/* LAST UPDATE V12  DATE: 20JAN2015 FOLDER: A - v12 only */
/* MUST BE CONFIRMED BEFORE RUN IT   */

%let v12_prod_dir = B;        /*  A or B IS THE READ FOLDER */ 
%let bridge_prod_dir = B;     /*  A or B IS THE READ FOLDER */

%macro emcodedir;
%global emcodedir emdatadir;
%let emcodedir=PROD;

%if %bquote(&emcodedir)=PROD %then %let emdatadir=DATA;
%else %let emdatadir=DATA/&cicodepath.;
%mend emcodedir;
%emcodedir;

/* V12 FOLDER */
/* V12 FOLDER */
/* V12 FOLDER */

%macro v12_libs(v12_prod_dir=);

   %if &v12_prod_dir=A %then 
      %do;
         libname v12_raw "/project/CACDIRECT/&emdatadir./EM_FLAG/V12/RAW";
         libname v12_sas "/project/CACDIRECT/&emdatadir./EM_FLAG/V12/A";   
      %end;
   
   %else %if &v12_prod_dir=B %then 
      %do;
         libname v12_raw "/project/CACDIRECT/&emdatadir./EM_FLAG/V12/RAW";
         libname v12_sas "/project/CACDIRECT/&emdatadir./EM_FLAG/V12/B"; 	 
      %end;

   %else %then 
      %do;
         %put "ERROR: v12_prod_dir MUST BE A or B!";
         %abort;
      %end;

%mend v12_libs;

%v12_libs(v12_prod_dir=&v12_prod_dir);


/* BRIDGE FOLDER  */
/* BRIDGE FOLDER  */
/* BRIDGE FOLDER  */

%macro bridge_libs(dir=);

   %if &bridge_prod_dir=A %then 
      %do;
         libname brg_raw "/project/CACDIRECT/&emdatadir./EM_FLAG/BRIDGE/RAW";
         libname brg_sas "/project/CACDIRECT/&emdatadir./EM_FLAG/BRIDGE/A";  
      %end;
   
   %else %if &bridge_prod_dir=B %then 
      %do;
	 libname brg_raw "/project/CACDIRECT/&emdatadir./EM_FLAG/BRIDGE/RAW";
         libname brg_sas "/project/CACDIRECT/&emdatadir./EM_FLAG/BRIDGE/B";	 
      %end;

   %else %then 
      %do;
         %put "ERROR: bridge_prod_dir MUST BE A or B!";
         %abort;
      %end;

%mend bridge_libs;

%bridge_libs(dir=&bridge_prod_dir);
