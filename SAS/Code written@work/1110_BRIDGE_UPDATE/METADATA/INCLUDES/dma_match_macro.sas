* DMA assigner;
* Assigns DMA to code client data;

%include "/project/CACDIRECT/CODE/&cicodepath./METADATA/INCLUDES/dma_name.inc";

%macro dma_assigner(
                    client_lib=
                   ,client_data=
                   ,client_id=
                   ,client_state_var=
                   ,client_zip_var=               /* MUST BE CHARACTER */
                   ,client_county_code_var=       /* MUST BE 3 BYTE CHARACTER */
                   ,email=
                   ,outlib=
                   ,outdata=);


    data set_up;
       set &client_lib..&client_data (keep=&client_id &client_zip_var &client_county_code_var);
       length scf $3.;
       scf=substr(&client_zip_var,1,3);
       length zip $5.;
       zip=substr(&client_zip_var,1,5);
       length county_code $3.;
       county_code=&client_county_code_var;
    run;
   
    proc sort data=set_up;
      by zip county_code;
    run;

    proc sort data=dma.all_zip_countys out=zip_co;
      where zip ne '' and county_code ne '';
      by zip county_code;
    run;

    data matched_zip_co non_matched_zip_co (drop=dma_code dma_assigned match_level_id match_level);
       merge set_up (in=a)
             zip_co (in=b keep=zip county_code dma_code match_level match_level_id);   
       by zip county_code;
       dma_assigned=0;
       if a and b then do;
          if dma_code ne '' then dma_assigned=1;
          if dma_assigned=1 then  output matched_zip_co;
             else if dma_assigned=0 then output non_matched_zip_co; 
       end;
       else if a and not b then do;
               output non_matched_zip_co;
       end;
    run;

    proc sort data=non_matched_zip_co;
       by zip;
    run;
  
    proc sort data=dma.all_zip_countys out=zip;
      where zip ne '' and county_code eq '';
      by zip;  
    run;
   
    data matched_zip non_matched_zip (drop=dma_code dma_assigned match_level_id match_level);
      merge non_matched_zip_co (in=a)
            zip (in=b keep=zip dma_code match_level match_level_id);
      by zip;
      dma_assigned=0;
      if a and b then do;
         if dma_code ne '' then dma_assigned=1;
         if dma_assigned=1 then  output matched_zip;
            else if dma_assigned=0 then output non_matched_zip;
       end;
       else if a and not b then do;
               output non_matched_zip;
       end;
    run;
 
    proc sort data=non_matched_zip;
      by scf;
    run;

    proc sort data=dma.all_zip_countys out=scf;
      by scf;
    run;

    data matched_scf non_matched_scf;
      merge non_matched_zip (in=a)
            scf (in=b keep=scf dma_code match_level match_level_id);
      by scf;
      dma_assigned=0;
      if a and b then do;
         if dma_code ne '' then dma_assigned=1;
         if dma_assigned=1 then  output matched_scf;
            else if dma_assigned=0 then output non_matched_scf;
       end;
       else if a and not b then do;
               output non_matched_scf;
       end;
    run;

    data all;
      set matched_zip_co
          matched_zip
          matched_scf
          non_matched_scf;
    run;

    proc sort data=all;
       by &client_id match_level;
    run;

    data all;
       set all;
       by &client_id match_level;
       if first.&client_id then output;
    run;

    proc sort data=all;
      by &client_id;
    run;
 
    proc sort data=&client_lib..&client_data out=client;
      by &client_id;
    run;


    data &outlib..&outdata;
      merge client (in=a)
            all (in=b keep=&client_id dma_code match_level match_level_id dma_assigned);
      by &client_id;
      if a; 
        dma=dma_code+0;
        length dma_name $43.;
        dma_name=put(dma,dma_name.);
        drop dma;
    run;

    proc datasets lib=work;
       delete client;
       delete all;
       delete matched_zip_co;
       delete matched_zip;
       delete matched_scf;
       delete non_matched_scf;
    quit;

    ods html body="./Cogensia_DMA_Assignment.htm";

       title1 "DMA Asssignment for &outlib..&outdata";
       proc freq data=&outlib..&outdata order=freq;
         tables match_level * match_level_id / list missing;
         tables dma_code * dma_name / list missing;
       run;
       
       title1 "You have records not matched to a DMA";
       proc freq data=&outlib..&outdata order=freq;
          where match_level='';
          tables &client_state_var * &client_zip_var / list missing;
       run;

    ods html close;

    filename mail1 email to=("&email") 
                             subject="Cogensia DMA Assignment" 
                             from="webmaster@cac-group.com"
                             attach="./Cogensia_DMA_Assignment.htm";
        
    data _null_;
      file mail1;
      put "Your DMA assignment for &outlib..&outdata has completed.";
      put "DMA name is DMA_NAME and DMA code is DMA_CODE on &outlib..&outdata";
    run;

%mend;
