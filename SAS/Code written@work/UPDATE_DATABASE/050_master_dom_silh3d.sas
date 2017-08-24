* 090_master_dom_silh3d.sas;
* AUTHOR: IPB;
* EDITED: MWM 1/2013 FOR MIGRATION TO VINCE;

%macro geosil(testobs = max, cacdirect_dir=, thisstate= XXXX, codepath=PROD);
   options mprint;

   %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc"; 
   
       %if &cacdirect_dir=A %then %do;
           libname base     "/project17/CACDIRECT/&cidatapath./BASE_DEMO/A";
           libname newsilh  "/project17/CACDIRECT/&cidatapath./SILH3D/A";
           libname domsilh  "/project17/CACDIRECT/&cidatapath./DOM_SILH/A";
       %end;
       
       %else %if &cacdirect_dir=B %then %do;
                 libname base     "/project17/CACDIRECT/&cidatapath./BASE_DEMO/B";
                 libname newsilh  "/project17/CACDIRECT/&cidatapath./SILH3D/B";
                 libname domsilh  "/project17/CACDIRECT/&cidatapath./DOM_SILH/B";
       %end;


   data &thisstate (drop=CAC_ADDR_ZIP4 CAC_PROD_ACTIVE_FLAG );
      set  base.base_demo_&thisstate (obs=&testobs KEEP = CAC_SILH CAC_ADDR_ZIP CAC_ADDR_ZIP4 CAC_PROD_ACTIVE_FLAG WHERE=(CAC_PROD_ACTIVE_FLAG=1 and CAC_SILH not in('' 'XX'))) ;
      format zip9 $9. scf $9. zip7 $9. zip5 $9.;
      if length(strip(cac_addr_zip4)) = 4 then zip9=compress(CAC_ADDR_ZIP||CAC_ADDR_ZIP4);
      if length(zip9) >= 7 then zip7 = compress(substr(zip9,1,7)||"CC");
      zip5 = compress(CAC_ADDR_ZIP||"BBBB");
      scf = compress(substr(CAC_ADDR_ZIP,1,3)||"AAAAAA");
   run;

      proc freq data = &thisstate  NOPRINT ;
         where strip(scf) ne '';
         tables scf/ list  out = all_scfs;
      run;
      proc print data = all_scfs;
      run;

      filename scfs temp;
      data _NULL_;
         set all_scfs end = eof;
         file scfs;
         if _N_=1 then put '%let scfs =';
         put scf;
         if eof then put ';';
      run;
      %include scfs;
      %put SCFs in &thisstate: &scfs;
      %nobs (data = all_scfs);
      %put Number of SCFs in &thisstate: &nobs;
      %do x = 1 %to &nobs;
      

         title "-------------------- Freq output to &thisstate._&x -------------------";
         proc freq data = &thisstate  NOPRINT ;
            where strip(CAC_SILH) ne '' and scf = "%scan(&scfs,&x.)";
            tables zip9 * CAC_SILH / list missing out = zip9;
            tables zip7 * CAC_SILH / list missing out = zip7;
            tables zip5 * CAC_SILH / list missing out = zip5;
            tables scf * CAC_SILH / list missing out = scf;
         run;


         data all;
            set scf  (in=a where=(scf  ne ''))
                zip5 (in=b where=(zip5 ne ''))
                zip7 (in=c where=(zip7 ne ''))
                zip9 (in=d where=(zip9 ne ''))
            ;
            format geo_zip_id $9.;
            if a then do;
               geo_match_level='3';
               geo_zip_id = scf;
            end;
            else if b then do;
               geo_match_level='5';
               geo_zip_id = zip5;
            end;
            else if c then do;
               geo_match_level='7';
               geo_zip_id = zip7;
            end;
            else if d then do;
               geo_match_level='9';
               geo_zip_id = zip9;
            end;
         run;

         proc sort data = all;
            by DESCENDING geo_zip_id DESCENDING count;
         run;
      
         data dom_sil_&thisstate._&x (keep=geo_match_level geo_zip_id top_sil override_source  ); 
            format  top_3 top_5 top_7 $2.;
      
            set all ;
            by DESCENDING geo_zip_id DESCENDING count;
            retain killer ;
            retain top_3 top_5 top_7 ;
            array tops (*) top_7 top_5 top_3;
            array nums (3) _temporary_ (7 5 3);
      
      
            if      first.geo_zip_id and geo_match_level = '3' then do; top_3 = ''; top_5 = ''; top_7 = ''; end;
            else if first.geo_zip_id and geo_match_level = '5' then do;             top_5 = ''; top_7 = ''; end;
            else if first.geo_zip_id and geo_match_level = '7' then                             top_7 = '';
      
      
            if first.geo_zip_id = 1 and last.geo_zip_id = 1 then do;
               top_sil = CAC_SILH;
               if geo_match_level = '3'       then top_3 = top_sil;
               else if geo_match_level = '5'  then top_5 = top_sil;
               else if geo_match_level = '7'  then top_7 = top_sil;
               output;
            end;

            top_sil = lag(CAC_SILH);
            last_count = lag(count);
      
            if first.geo_zip_id then killer = 1;
            else killer = killer + 1;
            if killer > 2 then delete;
            if killer = 2 then do;
               if count = last_count then top_sil = 'XX';
               do i = 1 to 3;
                  if top_sil in('' 'XX') then do; 
                     top_sil = tops(i);
                     override_source = nums(i);
                  end;
               end;
               if geo_match_level = '3'       then top_3 = top_sil;
               else if geo_match_level = '5'  then top_5 = top_sil;
               else if geo_match_level = '7'  then top_7 = top_sil;
               geo_zip_id = compress(geo_zip_id,"A,B,C");
               output;
            end;
         run;
  
      %end; *** x loop of scfs ;

      data domsilh.dom_sil_3D_&thisstate ;
         set %do y = 1 %to &nobs;  dom_sil_&thisstate._&y %end;;
      run;


      title "-------------------- all_&thisstate - FINAL OUTPUT!!! -------------------"; 
      proc format ; value $xx  missing = 'Missing' 'XX'='Missing' other = 'OK!!!'; quit;

      proc freq data =  domsilh.dom_sil_3D_&thisstate;
         format top_sil $xx.;
         table geo_match_level*override_source*top_sil/list missing;
      run;
      proc contents data = domsilh.dom_sil_3D_&thisstate;
      run;
      title;


%mend geosil;


