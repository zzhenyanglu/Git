*========================================================================================;
* Program 020_make_valid_scf_format.sas
  Purpose Create a format of valid state scf combinations for use in Matching Process
          Run after Direct Database has been updated and new match key files exits
  Author  Mike Mattingly 
  Design  Input: scf.TSP_MKEY_&cstate
          Output: /.valid_st_scf.sas        
*========================================================================================;

%macro sortstack (start_st=, end_st=, qtr=, year=, write_directory=B, codepath=PROD);

   %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc"; 

    %let sts = AK AL AR AZ CA CO CT DC DE FL 
               GA HI IA ID IL IN KS KY LA MA
               MD ME MI MN MO MS MT NC ND NE 
               NH NJ NM NV NY OH OK OR PA RI
               SC SD TN TX UT VA VT WA WI WV
               WY;

    %if &write_directory=A %then %do;                                               *** IF CURRENT PRODUCTION DATA IS IN A THEN WRITE DATA FOR NEW QUARTER TO B;
        libname _ALL_;
        libname scf      "/project/CACDIRECT/&cidatapath./SCF_MKEY/A";
    %end;
    
    %else %if &write_directory=B %then %do;                                        *** IF CURRENT PRODUCTION DATA IS IN B THEN WRITE DATA FOR NEW QUARTER TO A;
              libname _ALL_;
              libname scf      "/project/CACDIRECT/&cidatapath./SCF_MKEY/B";
    %end;

    %do current_state = &start_st %to &end_st;
     
       %let cstate=%scan(&sts, &current_state);
       
       proc sort data=scf.TSP_MKEY_&cstate out=tsp_mkey_&cstate (keep=st_scf) nodupkey;
         by ST_SCF;
       run;  
       
       proc append base=all_mkeys data=tsp_mkey_&cstate force;
       run;
       
   %end;
   
   filename fmts './valid_st_scf.sas';
      data _null_;
         set all_mkeys end=eof;
         _st_scf="'"||strip(st_scf)||"'";
         file fmts;
         if _n_=1 then put 'proc format; value $val_st_scf';
          put _st_scf "='V'";
         if eof then put "other='I'; run;";
   run;
   
%mend sortstack;
