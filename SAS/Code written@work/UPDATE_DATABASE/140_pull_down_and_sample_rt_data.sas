* 140_pull_down_and_sample_rt.sas;
* CREATES THE DATA FOR THE INTELLIBASE REALTIME QLICKVIEW SELECTION TOOL;
* CREATES THE SAMPLE_FOR_QV_DEMO TABLE IN SQL SERVER DATABASE;

* PEER 1 CAC_DIRECT;
%let user=mmattingly;
%let pw=BearDown_15;
%let server=216.157.38.64;

%macro doit(codepath=PROD);

   %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc";

   %include "/project/CACDIRECT/CODE/&cicodepath./METADATA/INCLUDES/zipcty_by_dma.inc";
   %include "/project/CACDIRECT/CODE/&cicodepath./UPDATE_DATABASE/decile_macro.sas";
   
   libname rtserv ODBC NOPROMPT="UID=&user;pwd=&pw;DSN=MSSQL;SERVER=&server;DATABASE=CAC_DIRECT;" readbuff=10000 insertbuff=10000 dbcommit=10000;
   
   %let pkobs=max;
   
   proc sql;
      drop table rtserv.sample_for_qv_demo;
   quit;
   
   data base_from_server;
      set rtserv.base_demo_all2 (obs=&pkobs where=(cac_prod_active_flag=1));
      cac_census_2010_county_code=substr(CAC_FULL_FIPS_ID,3,3);
      ZIPCOUNTY = compress(CAC_ADDR_ZIP || CAC_CENSUS_2010_COUNTY_CODE );
      format DMA BEST12.;
      DMA=put(compress(ZIPCOUNTY),$zipctydma.)+0;
      if DMA=. then DMA=0;
   run;
   
   proc sort data=base_from_server;
      by dma cac_silh;
   run;
   
   proc freq data=base_from_server;
      title 'BEFORE SAMPLING';
      tables dma cac_silh /list missing;
   run;
   
   proc surveyselect data=base_from_server out=testing method=srs samprate=.01;
      strata dma cac_silh;
   run;
   
   proc freq data=testing;
      title 'SAMPLE';
      tables dma cac_silh /list missing;
   run;
   
   %qc(data=testing,maxlevel=100);
   
   %deciles(datain=testing,score_var=model_score,fmtprefix=combo);
   
   data rtserv.sample_for_qv_demo;
      set testing (drop=dma zipcounty cac_census_2010_county_code samplingweight selectionprob rename=(decile_model_score=model_decile));
   run;
   
   proc means data=rtserv.sample_for_qv_demo;
      class model_decile;
      var model_score;
   run;
   
   endsas;

%mend doit;
