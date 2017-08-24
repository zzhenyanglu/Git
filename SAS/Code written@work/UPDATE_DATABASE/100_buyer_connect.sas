*========================================================================================;
* Program 100_buyerconnect.sas
  Purpose Create Individual Level files to be used for matching
  Authors Mike Mattingly   
  Input base_demo_&state
  Output woodfield_master_&state
  Edited 1/16/2013 For Q4 2012 Release MM 
  	 Run Final Data Set Thru Parsimony To Get MKEY1 and MKEY2
  	 Added cacdir_loc parameter to direct output;
*========================================================================================;
options mprint nomlogic linesize=120 ps=1000 compress = Y;

%macro buyer_connect (qtr=, year=, cacdir_loc=, thisstate= XXXX, codepath=PROD);

    %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc"; 

    %if &cacdir_loc=A %then %do;
        libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/A";
        libname scf      "/project/CACDIRECT/&cidatapath./SCF_MKEY/A";
        libname buycnc   "/project/CACDIRECT/&cidatapath./BUYER_CONNECT/A";
    %end;
    
    %else %if &cacdir_loc=B %then %do;
              libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";
              libname scf      "/project/CACDIRECT/&cidatapath./SCF_MKEY/B";
              libname buycnc   "/project/CACDIRECT/&cidatapath./BUYER_CONNECT/B";
    %end;
    
    proc sort data=scf.tsp_mkey_&thisstate out=tsp_&thisstate (keep=cac_hh_pid mkey1 mkey2);
          where cac_prod_active_flag=1;
          by cac_hh_pid;
    run;

    data buycnc.woodfield_master_&thisstate (keep=person key_substr_4 key_exact mast_latitude mast_longitude cac_hh_pid cac_active_flag
                                               cac_recno cac_production cac_name_last cac_name_first mkey1 mkey2 cac_year cac_qtr CAC_PH_AREA_CODE CAC_PH_NUMBER cac_addr_zip);
      merge base.base_demo_&thisstate (in=a keep=cac_hh_pid cac_recno cac_name_last cac_name_first cac_ind1_mi cac_production cac_active_flag  
                                                   cac_ind1_name cac_ind2_name cac_ind3_name cac_ind4_name cac_ind5_name
                                                   cac_ind3_age_enh cac_ind4_age_enh cac_ind5_age_enh cac_year cac_qtr
                                                   cac_addr_latitude cac_addr_longitude CAC_PH_AREA_CODE CAC_PH_NUMBER cac_addr_zip
                                            where=(cac_active_flag=1 and cac_production=1))

            tsp_&thisstate (in=b);

      by cac_hh_pid;
      
      if a and b;
      
      format mast_latitude mast_longitude 17.13;
      mast_latitude=cac_addr_latitude+0;
      mast_longitude=cac_addr_longitude+0;

      array names cac_name_last cac_name_first cac_ind1_name cac_ind2_name cac_ind3_name cac_ind4_name cac_ind5_name;
      
      do over names;
               names = tranwrd(names,"'","");
               names = tranwrd(names,'"',"");
               names = tranwrd(names,",","");
               names = tranwrd(names,"*","");
               names = tranwrd(names,"1","");
               names = tranwrd(names,"2","");
               names = tranwrd(names,"3","");
               names = tranwrd(names,"4","");
               names = tranwrd(names,"5","");
               names = tranwrd(names,"6","");
               names = tranwrd(names,"7","");
               names = tranwrd(names,"8","");
               names = tranwrd(names,"9","");
               names = tranwrd(names,"0","");
               names = tranwrd(names,";","");
               names = tranwrd(names," III","");
               names = tranwrd(names," DA ","");
               names = tranwrd(names,":","");
               names = tranwrd(names,"  "," ");
               names = tranwrd(names,"  "," ");
               names = tranwrd(names,"  "," ");
      end;

      if compress(cac_name_last) = '' then delete;
      
      format key_exact key_substr_4 $40.;
      
      label KEY_EXACT = 'LAST AND FIRST NAME KEY';
      label KEY_SUBSTR_4 = 'LAST AND 4 BYTES OF FIRST NAME KEY';
      label PERSON = 'PERSON NUMBER IN HOUSEHOLD';

      /***PERSON 1***/
      key_exact = compress(cac_name_last||"_"||cac_name_first);
      if length(compress(cac_name_first)) >= 4 then do;
         first_bytes = substr(cac_name_first,1,4);
         key_substr_4 = compress(cac_name_last||"_"||first_bytes);
      end;
      if key_substr_4 = '' then key_substr_4 = key_exact;
      person=1;
      output;
     
      key_exact='';
      key_substr_4='';
      first_bytes='';
 
      /***PERSON 2***/
      if cac_ind2_name ne '' then do; 
         key_exact = compress(cac_name_last||"_"||cac_ind2_name);
         if length(compress(cac_ind2_name)) >= 4 then do;
            first_bytes = substr(cac_ind2_name,1,4);
            key_substr_4 = compress(cac_name_last||"_"||first_bytes);
         end;
         if key_substr_4 = '' then key_substr_4 = key_exact;
         person=2;
         output;
       end;

      key_exact='';
      key_substr_4='';
      first_bytes='';

      /***PERSON 3***/
      age3=cac_ind3_age_enh+0;
      if cac_ind3_name ne '' and age3 ne . and age3>=16 then do; 
         key_exact = compress(cac_name_last||"_"||cac_ind3_name);
         if length(compress(cac_ind3_name)) >= 4 then do;
            first_bytes = substr(cac_ind3_name,1,4);
            key_substr_4 = compress(cac_name_last||"_"||first_bytes);
         end;
         if key_substr_4 = '' then key_substr_4 = key_exact;
         person=3;
         output;
       end;
 
      key_exact='';
      key_substr_4='';
      first_bytes='';

      /***PERSON 4***/
      age4=cac_ind4_age_enh+0;
      if cac_ind4_name ne '' and age4 ne . and age4>=16 then do; 
         key_exact = compress(cac_name_last||"_"||cac_ind4_name);
         if length(compress(cac_ind4_name)) >= 4 then do;
            first_bytes = substr(cac_ind4_name,1,4);
            key_substr_4 = compress(cac_name_last||"_"||first_bytes);
         end;
         if key_substr_4 = '' then key_substr_4 = key_exact;
         person=4;
         output;
       end;
 
      key_exact='';
      key_substr_4='';
      first_bytes='';

      /***PERSON 5***/
      age5=cac_ind5_age_enh+0;
      if cac_ind5_name ne '' and age5 ne . and age5>=16 then do; 
         key_exact = compress(cac_name_last||"_"||cac_ind5_name);
         if length(compress(cac_ind5_name)) >= 4 then do;
            first_bytes = substr(cac_ind5_name,1,4);
            key_substr_4 = compress(cac_name_last||"_"||first_bytes);
         end;
         if key_substr_4 = '' then key_substr_4 = key_exact;
         person=5;
         output;
       end;

    run;
  
    title "***~~~~~~~~~============= &thisstate ===========~~~***"; 

    proc print data=_last_ (obs=10);
    run;

    proc freq data=_last_;
      table person;
    run;
    title '';

      
      title1 "BUYER CONNNECT DATA FOR &thisstate &QTR &YEAR &CACDIR_LOC";
      proc contents data=buycnc.woodfield_master_&thisstate;
      run;
      
      proc print data=buycnc.woodfield_master_&thisstate (obs=25);
      run;

%mend buyer_connect;
