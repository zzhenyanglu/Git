***;
* 030_score_silh.sas;
***;
%let jdsobs=max;

libname silh '/project/SILHOUETTES/DATA';
%inc "./030_score_universe_mm_change.sas";

%macro do_it(quarter=,year=,previous_quarter=,previous_year=,cacdir_loc=,codepath=PROD,email=mmattingly@cac-group.com);

%include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc";

data _NULL_;
    %Let procname = %scan(%scan(%sysfunc(sysprocessname()),2," "),1,".");
    st = reverse(substr(reverse("&procname."),1,2));
    call symput ("this_state", st);
run;
%put STATE BEING RUN HERE: &this_state;

title ' --------- VALUES FOR &PREVIOUS_YEAR &PREVIOUS_QUARTER &THIS_STATE ------------';
proc freq data=newsilh.cac_silh_&this_state;
   tables cac_silh cac_silh_social cac_silh_dig_inf;
run;


* DEFINE LIBNAMES FOR QUARTER OF DATA BEING SCORED - MEANING WHERE DOES NEW PRODUCTION LIVE;

    %if &cacdir_loc=A %then %do;                                               *** IF CURRENT PRODUCTION DATA IS IN A THEN WRITE DATA FOR NEW QUARTER TO B;
        libname _ALL_;
        libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";
        libname indiv    "/project/CACDIRECT/&cidatapath./INDIV_DEMO/B";
        libname scf      "/project/CACDIRECT/&cidatapath./SCF_MKEY/B";
        libname geo      "/project/CACDIRECT/&cidatapath./GEO/B";
        libname samp     "/project/CACDIRECT/&cidatapath./SAMPLES/B";  
        libname newsilh  "/project/CACDIRECT/&cidatapath./SILH3D/B";
    %end;
    
    %else %if &cacdir_loc=B %then %do;                                        *** IF CURRENT PRODUCTION DATA IS IN B THEN WRITE DATA FOR NEW QUARTER TO A;
              libname _ALL_; 
              libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/A";
              libname indiv    "/project/CACDIRECT/&cidatapath./INDIV_DEMO/A";
              libname scf      "/project/CACDIRECT/&cidatapath./SCF_MKEY/A";
              libname geo      "/project/CACDIRECT/&cidatapath./GEO/A";
              libname samp     "/project/CACDIRECT/&cidatapath./SAMPLES/A";          
              libname newsilh  "/project/CACDIRECT/&cidatapath./SILH3D/A";
    %end;
    libname cen2010 "/project17/CENSUS/DATA/2010/FINAL";

%silhouettes(direct=Y                                             /*** Y-scoring direct data, N-scoring input client file;          ***/
                   ,state_list=&this_state                        /*** list of states to process, enter NONE if running client file ***/
                   ,lib=NOT_NEEDED                                /**** Libname of CACdirect matched client data - must be defined  ***/
                   ,indata=NOT_NEEDED                             /**** CACdirect matched client data                               ***/
                   ,outdata=NOT_NEEDED                            /**** Output dataset name                                         ***/
                   ,email=%scan(&email,1,'@')                     /**** CAC Group email user name                                   ***/
                   ,jdsobs=&jdsobs
             );
 

proc print data=newsilh.cac_silh_&this_state (obs=1);
run;

title ' --------- VALUES FOR &YEAR &QUARTER &THIS_STATE ------------';
proc freq data=newsilh.cac_silh_&this_state;
   tables cac_silh cac_silh_social cac_silh_dig_inf;
run;

%mend do_it;

