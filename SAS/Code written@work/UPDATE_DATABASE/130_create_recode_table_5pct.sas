***;
* 130_master_create_recode_table_samp.sas;
* This program creates CACdirect sample datasets with standard variables for modeling;
* BJW, MM 4/2013;
* FIRST RAN IN PRODUCTION FOR Q2, 2013;
***;
%inc './integer_vars.inc';

%macro recode(testobs = max, cacdirect_dir=, this_samp= 5pct);
   options mprint;
   
    %if &cacdirect_dir=A %then %do;
        libname base     "/project17/CACDIRECT/DATA/BASE_DEMO/A";
        libname m_table  "/project17/CACDIRECT/DATA/RECODES/A";
        libname samp      "/project17/CACDIRECT/DATA/SAMPLES/A";
    %end;
    
    %if &cacdirect_dir=B %then %do;
              libname base     "/project17/CACDIRECT/DATA/BASE_DEMO/B";
              libname m_table  "/project17/CACDIRECT/DATA/RECODES/B";
              libname samp      "/project17/CACDIRECT/DATA/SAMPLES/B";
    %end;

   data m_table.m_recodes_&this_samp(keep=cac_hh_pid M_:);
      length &integer_vars 3.;
      set samp.base_samp_&this_samp(obs=&testobs);
      %cacdirect_recode(demos= Y
                     ,home= Y
                     ,geo= Y
                     ,interests= Y
                     ,credit= Y
                     ,life_events=Y
                     ,segments_old=Y
                     ,segments_new= Y
                     ,enhanced=Y
                     ,non_enhanced=N
                     );
   run;   

   proc contents data=m_table.m_recodes_&this_samp;
   run;

   proc print data=m_table.m_recodes_&this_samp(obs=10);
   run;

   proc sort data=m_table.m_recodes_&this_samp;
      by cac_hh_pid;
   run;


%mend recode;

%recode(testobs = max, cacdirect_dir=A, this_samp= 5pct);
