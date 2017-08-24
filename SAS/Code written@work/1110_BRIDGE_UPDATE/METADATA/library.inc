******************************************************************************;
* MASTER CONTROLLER FOR ENABLING CACDIRECT PROCESSING/MATCHING;
* Updated: 4/19/2012 - JS  
* Updated: 5/1/2012 - MM ADDED JOB_HISTORY LIB                     
* Updated: 5/4/2012 - MM ADDED CEN2010                                        
* Updated: 5/7/2012 - MM ADDED BUYCNC
* Updated: 5/7/2012 - MM Changed DEV to point to project17 from project17
* Updated: 7/9/2012 - MM Removed BAK since it no longer required
* Updated: 7/11/2012 - MM Added NCOA_KILL
* Updated: 7/12/2012 - MM Added FORET
******************************************************************************;

*------------------LIBRARIES------------------;


**** MACRO DIRECT_LIBS DEFINES LIBRARIES FOR PRODUCTION CACDIRECT DATA;
**** MM 1/2013;
**** MACRO TAKES 3 PARAMETERS: 1) CAC_DIRECT_PROD_DIR: (A|B) USED TO DETERMINE WHERE DATA IS READ FROM;
****                                                    A = PROJECT17/A/..;
****                                                    B = PROJECT17/B/..;
****                           2) YEAR: YEAR OF PRODUCTION DATA;
****                           3)  QTR:  QTR OF PRODUCTION DATA;
**** NEW MACRO CALL CREATED UPDATED UPON THE COMPLETION OF CACDIRECT UPDATE;
**** HISTORICAL MACROS CALLS LEFT FOR HISTORICAL REFERENCE;

%macro direct_libs (cac_direct_prod_dir=,year=,qtr=); 

   %global cicodepath cidatapath;
   %let cicodepath=DEVELOPMENT/1110_BRIDGE_UPDATE;

   %if %bquote(&cicodepath)=PROD %then %let cidatapath=DATA;
   %else %let cidatapath=DATA/&cicodepath.;

   %if &cac_direct_prod_dir=A %then %do;
       libname base    "/project17/CACDIRECT/&cidatapath./BASE_DEMO/A";
       libname indiv   "/project17/CACDIRECT/&cidatapath./INDIV_DEMO/A";
       libname scf     "/project17/CACDIRECT/&cidatapath./SCF_MKEY/A";
       libname process "/project17/CACDIRECT/&cidatapath./PROCESS";
       libname geo     "/project17/CACDIRECT/&cidatapath./GEO/A";
       libname easi    "/project17/CENSUS/DATA/2010/EASI";
       libname cen2010 "/project17/CENSUS/DATA/2010/FINAL";
       libname cen2000 "/project17/CENSUS/DATA/FINAL";
       libname samp    "/project/CACDIRECT/&cidatapath./SAMPLES/A";
       libname dev     "/project17/CACDIRECT/&cidatapath./DEVELOPMENT";
       libname et      "/project17/CACDIRECT/&cidatapath./ETECH/A";
       libname jhs     "/project17/CACDIRECT/&cidatapath./JOB_HISTORY";
       libname buycnc  "/project17/CACDIRECT/&cidatapath./BUYER_CONNECT/A";
       libname foret    "/project17/CACDIRECT/&cidatapath./ETECH/FORETECH";
       libname newsilh  "/project17/CACDIRECT/&cidatapath./SILH3D/A";
       libname ddnc     "/project17/CACDIRECT/&cidatapath./DDNC";
       libname domsilh  "/project17/CACDIRECT/&cidatapath./DOM_SILH/A";
       libname intmdl   "/project/CACDIRECT/&cidatapath./INTMDL/A";
       libname for_rts  "/project/CACDIRECT/&cidatapath./REAL_TIME/A";
       libname v12   "/project/CACDIRECT/&cidatapath./V12/A";
       libname bridge   "/project/CACDIRECT/&cidatapath./BRIDGE/A";
       libname geoagg   "/project/CACDIRECT/&cidatapath./GEOAGG/A";
   %end;

   %if &cac_direct_prod_dir=B %then %do;
       libname base    "/project17/CACDIRECT/&cidatapath./BASE_DEMO/B";
       libname indiv   "/project17/CACDIRECT/&cidatapath./INDIV_DEMO/B";
       libname scf     "/project17/CACDIRECT/&cidatapath./SCF_MKEY/B";
       libname process "/project17/CACDIRECT/&cidatapath./PROCESS";
       libname geo     "/project17/CACDIRECT/&cidatapath./GEO/B";
       libname easi    "/project17/CENSUS/DATA/2010/EASI";
       libname cen2010 "/project17/CENSUS/DATA/2010/FINAL";
       libname cen2000 "/project17/CENSUS/DATA/FINAL";
       libname samp    "/project/CACDIRECT/&cidatapath./SAMPLES/B";
       libname dev     "/project17/CACDIRECT/&cidatapath./DEVELOPMENT";
       libname et      "/project17/CACDIRECT/&cidatapath./ETECH/B";
       libname jhis    "/project17/CACDIRECT/&cidatapath./JOB_HISTORY";
       libname buycnc  "/project17/CACDIRECT/&cidatapath./BUYER_CONNECT/B";
       libname foret    "/project17/CACDIRECT/&cidatapath./ETECH/FORETECH";
       libname newsilh  "/project17/CACDIRECT/&cidatapath./SILH3D/B";
       libname ddnc     "/project17/CACDIRECT/&cidatapath./DDNC";
       libname domsilh  "/project17/CACDIRECT/&cidatapath./DOM_SILH/B";
       libname intmdl   "/project/CACDIRECT/&cidatapath./INTMDL/B";
       libname for_rts  "/project/CACDIRECT/&cidatapath./REAL_TIME/B";
       libname v12   "/project/CACDIRECT/&cidatapath./V12/B";
       libname bridge   "/project/CACDIRECT/&cidatapath./BRIDGE/B";
       libname geoagg   "/project/CACDIRECT/&cidatapath./GEOAGG/B";
   %end;

%mend direct_libs;
%direct_libs(cac_direct_prod_dir=A, year=2015, qtr=2);

* LIBNAME FOR RAW DMA DATA;
libname dma "/project/CACDIRECT/&cidatapath./DMA/A";

    *------CLIENT MATCHMAKER----*

%let sts = AK AL AR AZ CA CO CT DC DE FL 
           GA HI IA ID IL IN KS KY LA MA
           MD ME MI MN MO MS MT NC ND NE 
           NH NJ NM NV NY OH OK OR PA RI
           SC SD TN TX UT VA VT WA WI WV
           WY;
%let person = 1 2 3 4 5;

********************;
*INFILE STATEMENTS *;
********************;
%inc "/project17/CACDIRECT/CODE/&cicodepath./METADATA/INCLUDES/tsp_infile_04062015.txt";   *--- for input of TSP install;
%inc "/project17/CACDIRECT/CODE/&cicodepath./METADATA/INCLUDES/tsp_label_020112.txt";
%inc "/project17/CACDIRECT/CODE/&cicodepath./METADATA/INCLUDES/geo_label_01132015.txt"; 
%inc "/project17/CACDIRECT/CODE/&cicodepath./METADATA/INCLUDES/ind_label_032212.txt"; 

************;
* FORMATS;
************;
%inc "/project17/CACDIRECT/CODE/&cicodepath./METADATA/INCLUDES/cdif.sas";
%inc "/project17/CACDIRECT/CODE/&cicodepath./METADATA/INCLUDES/direct_format.sas"; 
%inc "/project17/CACDIRECT/CODE/&cicodepath./METADATA/INCLUDES/valid_st_scf.sas";    *--- for matching*;

************;
* DATA PREP FOR MODELING;
************;
%inc "/project17/CACDIRECT/CODE/&cicodepath./METADATA/INCLUDES/cacdirect_modeling_recodes.inc";
%inc "/project17/CACDIRECT/CODE/&cicodepath./METADATA/INCLUDES/cacdirect_missfill.inc";
