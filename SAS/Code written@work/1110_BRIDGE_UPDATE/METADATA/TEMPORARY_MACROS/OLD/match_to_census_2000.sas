*============================================================================================
 match_to_census.sas
 
 Match a client file to census data AFTER MATCHING IT TO CACDIRECT
 - For records that match, we have block group, county, tract
 - For records that do not match, we have Zip9, Zip5 and State
 
 Part of CACDirect 2.0

 Disclaimer: This program will only work properly if Census data is unique... 
  at the zip5 level for sumlev=871
  at the county-tract level for sumlev=140
  at the county-tract-blkgrp level for sumlev=150 
 
 CAR 8-25-10 Added keep= and force= options to the macro
             (not sure why force option in proc append would ever be needed, but it was
              coded in a program called match_to_census2.sas in this directory.  Adding
              it as an option here so we dont need to maintain 2 separate programs)
 CAR 8-26-10 Do not apply a keep statement if &keep = %str()
=============================================================================================;

%macro match_to_census(
   id=,
   projprf=,
   clib=,
   client_data=,
   client_zip5=,
   client_zip4=,
   client_st=,
   stlst=,
   keep=,   /* DO NOT INCLUDE the vars (sumlev state zip5 county tract blkgrp census_001) in your keep= list */
            /* They are automatically part of the keep= list, and we DO NOT want to list them twice!!!!!!!!! */
   force=N, /* Set force=Y to add force= option to proc append of final_&st to census_matched_all            */
            /* force option allows append to occur if vars are different or have different types or lengths  */
   census_lib=,
   z9_lib=);
   
   libname client "&clib";
   libname cen "&census_lib";
   libname z9 "&z9_lib";

/* stlst not populated */
%if %length(&stlst)=0 %then %do;

***Code taken from writeem2 to get distinct states;

%let taba=%upcase(&projprf._client_)%;
proc contents data=client._ALL_ out=tempc noprint; run;

proc sql noprint;
     select distinct substr(memname,1,length(memname)-4) into :tbla separated by ' '
     from tempc
     where memname like "&taba";
quit;
%put &tbla;
***End v2.0;
                                                                                                                                        
%if %symexist(tbla)=1 %then %do;                                                                                                        
    ***get table count, write out to "counta" variable;                                                                                 
    %macro wca(lista);                                                                                                                  
           %global counta;                                                                                                              
           %let counta=0;                                                                                                               
           %do %while(%qscan(&lista,&counta+1,%str( )) ne %str());                                                                      
               %let counta=%eval(&counta+1);                                                                                            
           %end;                                                                                                                        
    %mend wca;                                                                                                                          
    %wca(&tbla);                                                                                                                        
                                                                                                                                        
    %do _ii=1 %to &counta;                                                                                                              
        %let sta=%scan(&tbla,&_ii);                                                                                                     
                                                                                                                                        
        data _null_;                                                                                                                    
             pos=index("&sta", "CLIENT_");                                                                                              
             state=compress(substr("&sta",pos+7,2));                                                                           
             call symput("wst", state);                                                                                                 
        run;                                                                                                                            
                                                                                                                                        
        %put &sta &wst;  

        %let st=%cmpres(&wst);

        data _null_;
             stlst='AK AL AR AZ CA CO CT DC DE FL GA
                   HI IA ID IL IN KS KY LA MA MD ME
                   MI MN MO MS MT NC ND NE NH NJ NM
                   NV NY OH OK OR PA RI SC SD TN TX
                   UT VA VT WA WI WV WY';
             if index(stlst, "&st")>0 then cont=1;
             call symput("cont", cont);
        run;

        %if &cont=1 %then %do;

        %put "/*================= Working on &st ==================*/";
     
     *======================================================================================;
     ***TEMP TEMP TEMP until duplicates in census data are removed (see Scot, Craig or Cara);
     *======================================================================================;
 
     %if &keep = %str() %then %do;
       proc sort data=cen.census_&st out=temp; 
          by sumlev zip5 county tract blkgrp descending census_001; 
          ***census_001=total population -- good way to pick best record;
       run;
     %end;
     %else %do;
       proc sort data=cen.census_&st(keep=sumlev state zip5 county tract blkgrp census_001 &keep) out=temp; 
          by sumlev zip5 county tract blkgrp descending census_001; 
          ***census_001=total population -- good way to pick best record;
       run;     
     %end;
     
     data census_&st;
        set temp;
        by sumlev zip5 county tract blkgrp;
        if first.blkgrp then output;
     run;
     *======================================================================================;
     ***TEMP TEMP TEMP end;
     *======================================================================================;

     data match_direct_&st(keep=&id census_level_match zip zip4 census_cnty census_tract census_tract_suffix block_group)
          match_zip9_&st(keep=&id zip zip4)
          match_zip5_&st(keep=&id zip)
          non_matches_&st(keep=&id);
        set client.&client_data._matched
           (keep=&id census_level_match zip zip4 census_cnty census_tract census_tract_suffix block_group
                 &client_st &client_zip5 &client_zip4
           where=(&client_st="&st"));
        if census_level_match in ('1','2','3') then output match_direct_&st;
        else do;
           ***use client file zips if master zips do not exist;
           if compress(zip)='' then zip=&client_zip5;
           %if %length(&client_zip4) > 0 %then %do;
               if compress(zip4)='' then zip4=&client_zip4;
           %end; 
           
           if length(compress(zip4))=4 then output match_zip9_&st; 
           else if length(compress(zip))=5 then output match_zip5_&st;
           else output non_matches_&st;  ***no identifying information exists to match;
        end;
     run;
     
     proc sql;
       CREATE TABLE direct_census_match_&st as
          SELECT aa.*
            FROM
               (
                SELECT a.&id, a.census_level_match, b.*
                  FROM match_direct_&st a, census_&st b
                 WHERE a.census_level_match='1' and b.sumlev='871'
                   AND translate(a.zip,'+',' ') = translate(b.zip5,'+',' ')
              UNION ALL
                SELECT c.&id, c.census_level_match, d.*
                  FROM match_direct_&st c, census_&st d
                 WHERE c.census_level_match='2' and d.sumlev='140'
                   AND compress(translate(c.census_cnty,'+',' ')||
                                translate(c.census_tract,'+',' ')||
                                translate(c.census_tract_suffix,'+',' ')) =
                       compress(translate(d.county,'+',' ')||
                                translate(d.tract,'+',' '))
              UNION ALL
                SELECT e.&id, e.census_level_match, f.*
                  FROM match_direct_&st e, census_&st f
                 WHERE e.census_level_match='3' and f.sumlev='150'
                   AND compress(translate(e.census_cnty,'+',' ')||
                                translate(e.census_tract,'+',' ')||
                                translate(e.census_tract_suffix,'+',' ')||
                                translate(e.block_group,'+',' ')) =
                       compress(translate(f.county,'+',' ')||
                                translate(f.tract,'+',' ')||
                                translate(f.blkgrp,'+',' '))
               ) aa
       ;
       quit;
     run;
     
     proc sort data=match_direct_&st(keep=&id zip zip4) out=tried_&st; by &id; run;
     proc sort data=direct_census_match_&st(keep=&id) out=matched_&st; by &id; run;
     
     data failed_direct_try_zip9_&st(keep=&id zip zip4);
        merge tried_&st(in=_a_)
              matched_&st(in=_b_);
        by &id;
        if _a_ and not _b_;
     run;
     
     proc append base=match_zip9_&st new=failed_direct_try_zip9_&st; run;
     
     proc sort data=match_zip9_&st; by zip zip4; run;
     proc sort data=z9.zip9_census_lookup_&st out=lookup_&st; by zip zip4; run;
     
     data zip9_matchkeys_&st;
        merge match_zip9_&st(in=_a_ keep=&id zip zip4)
              lookup_&st(in=_b_ keep=zip zip4 census_level_match census_cnty census_tract census_tract_suffix block_group);
        by zip zip4;
        if _a_ and _b_;
     run;
     
     proc sql;
       CREATE TABLE zip9_census_match_&st as
          SELECT aa.*
            FROM
               (
                SELECT a.&id, a.census_level_match, b.*
                  FROM zip9_matchkeys_&st a, census_&st b
                 WHERE a.census_level_match='1' and b.sumlev='871'
                   AND translate(a.zip,'+',' ') = translate(b.zip5,'+',' ')
              UNION ALL
                SELECT c.&id, c.census_level_match, d.*
                  FROM zip9_matchkeys_&st c, census_&st d
                 WHERE c.census_level_match='2' and d.sumlev='140'
                   AND compress(translate(c.census_cnty,'+',' ')||
                                translate(c.census_tract,'+',' ')||
                                translate(c.census_tract_suffix,'+',' ')) =
                       compress(translate(d.county,'+',' ')||
                                translate(d.tract,'+',' '))
              UNION ALL
                SELECT e.&id, e.census_level_match, f.*
                  FROM zip9_matchkeys_&st e, census_&st f
                 WHERE e.census_level_match='3' and f.sumlev='150'
                   AND compress(translate(e.census_cnty,'+',' ')||
                                translate(e.census_tract,'+',' ')||
                                translate(e.census_tract_suffix,'+',' ')||
                                translate(e.block_group,'+',' ')) =
                       compress(translate(f.county,'+',' ')||
                                translate(f.tract,'+',' ')||
                                translate(f.blkgrp,'+',' '))
               ) aa
       ;
       quit;
     run;
     
     proc sort data=match_zip9_&st(keep=&id zip) out=tried_&st; by &id; run;
     proc sort data=zip9_census_match_&st(keep=&id) out=matched_&st; by &id; run;
     
     data failed_zip9_try_zip5_&st(keep=&id zip);
        merge tried_&st(in=_a_)
              matched_&st(in=_b_);
        by &id;
        if _a_ and not _b_;
     run;
     
     proc append base=match_zip5_&st new=failed_zip9_try_zip5_&st; run;
     
     proc sql;
       CREATE TABLE zip5_census_match_&st as
           SELECT a.&id, '1' as census_level_match, b.*
             FROM match_zip5_&st a, census_&st b
            WHERE b.sumlev='871'
              AND translate(a.zip,'+',' ') = translate(b.zip5,'+',' ');
       quit;
     run;
     
     proc sort data=match_zip5_&st(keep=&id) out=tried_&st; by &id; run;
     proc sort data=zip5_census_match_&st(keep=&id) out=matched_&st; by &id; run;
     
     data failed_zip5_&st(keep=&id);
        merge tried_&st(in=_a_)
              matched_&st(in=_b_);
        by &id;
        if _a_ and not _b_;
     run;
     
     proc append base=non_matches_&st new=failed_zip5_&st; run;
     
     data final_&st;
        set direct_census_match_&st(in=_a_)
            zip9_census_match_&st(in=_b_)
            zip5_census_match_&st(in=_c_)
            non_matches_&st(in=_d_);
        format census_source_match $6.;
        if _a_ then census_source_match="DIRECT"; else
        if _b_ then census_source_match="ZIP9"; else
        if _c_ then census_source_match="ZIP5"; else
        if _d_ then census_source_match="NONE";
        flag_census_match=_a_ or _b_ or _c_;
        label flag_census_match="FLAG: MATCHED TO CENSUS (THRU DIRECT, ZIP9 OR ZIP5)";
     run;
    
     %if &force=Y %then %do;
       proc append base=census_matched_all new=final_&st force; run;
     %end;
     %else %do;
       proc append base=census_matched_all new=final_&st; run;     
     %end;
     *======================================================================================;
     ***PROC DATASETS TO REMOVE WORK FILES AFTER STATE APPENDEED to census_matched_all -- MPF 8/29/2008************;
     *======================================================================================;

     proc datasets library=work nolist;
     delete final_&st direct_census_match_&st zip9_census_match_&st zip5_census_match_&st non_matches_&st lookup_&st census_&st match_direct_&st;
     run; 

     
   %end; /*cont loop*/
   %end; /*state counter*/  
   %end; /*%symexist(tbla)=1*/
%end;    /*length(&stlst)=0*/

/* stlst populated */
%if %length(&stlst)>0 %then %do;
   %let i=1;
   %do %until (%length(%scan(&stlst,&i))=0);
     %let st=%scan(&stlst,&i);
     
     *======================================================================================;
     ***TEMP TEMP TEMP until duplicates in census data are removed (see Scot, Craig or Cara);
     *======================================================================================;
     %if &keep = %str() %then %do;
       proc sort data=cen.census_&st out=temp; 
          by sumlev zip5 county tract blkgrp descending census_001; 
          ***census_001=total population -- good way to pick best record;
       run;
     %end;
     %else %do;
       proc sort data=cen.census_&st(keep=sumlev state zip5 county tract blkgrp census_001 &keep) out=temp; 
          by sumlev zip5 county tract blkgrp descending census_001; 
          ***census_001=total population -- good way to pick best record;
       run;     
     %end;
     
     data census_&st;
        set temp;
        by sumlev zip5 county tract blkgrp;
        if first.blkgrp then output;
     run;
     *======================================================================================;
     ***TEMP TEMP TEMP end;
     *======================================================================================;

     data match_direct_&st(keep=&id census_level_match zip zip4 census_cnty census_tract census_tract_suffix block_group)
          match_zip9_&st(keep=&id zip zip4)
          match_zip5_&st(keep=&id zip)
          non_matches_&st(keep=&id);
        set client.&client_data._matched
           (keep=&id census_level_match zip zip4 census_cnty census_tract census_tract_suffix block_group
                 &client_st &client_zip5 &client_zip4
           where=(&client_st="&st"));
        if census_level_match in ('1','2','3') then output match_direct_&st;
        else do;
           ***use client file zips if master zips do not exist;
           if compress(zip)='' then zip=&client_zip5;
           %if %length(&client_zip4) > 0 %then %do;
               if compress(zip4)='' then zip4=&client_zip4;
           %end; 
           
           if length(compress(zip4))=4 then output match_zip9_&st; 
           else if length(compress(zip))=5 then output match_zip5_&st;
           else output non_matches_&st;  ***no identifying information exists to match;
        end;
     run;

     proc sql;
       CREATE TABLE direct_census_match_&st as
          SELECT aa.*
            FROM
               (
                SELECT a.&id, a.census_level_match, b.*
                  FROM match_direct_&st a, census_&st b
                 WHERE a.census_level_match='1' and b.sumlev='871'
                   AND translate(a.zip,'+',' ') = translate(b.zip5,'+',' ')
              UNION ALL
                SELECT c.&id, c.census_level_match, d.*
                  FROM match_direct_&st c, census_&st d
                 WHERE c.census_level_match='2' and d.sumlev='140'
                   AND compress(translate(c.census_cnty,'+',' ')||
                                translate(c.census_tract,'+',' ')||
                                translate(c.census_tract_suffix,'+',' ')) =
                       compress(translate(d.county,'+',' ')||
                                translate(d.tract,'+',' '))
              UNION ALL
                SELECT e.&id, e.census_level_match, f.*
                  FROM match_direct_&st e, census_&st f
                 WHERE e.census_level_match='3' and f.sumlev='150'
                   AND compress(translate(e.census_cnty,'+',' ')||
                                translate(e.census_tract,'+',' ')||
                                translate(e.census_tract_suffix,'+',' ')||
                                translate(e.block_group,'+',' ')) =
                       compress(translate(f.county,'+',' ')||
                                translate(f.tract,'+',' ')||
                                translate(f.blkgrp,'+',' '))
               ) aa
       ;
       quit;
     run;
     *** DELETED WHAT APPEARS TO BE RANDOM ASTERIX SLASH HANGING COMMENT -- AWESOME ***;
     
     proc sort data=match_direct_&st(keep=&id zip zip4) out=tried_&st; by &id; run;
     proc sort data=direct_census_match_&st(keep=&id) out=matched_&st; by &id; run;
     
     data failed_direct_try_zip9_&st(keep=&id zip zip4);
        merge tried_&st(in=_a_)
              matched_&st(in=_b_);
        by &id;
        if _a_ and not _b_;
     run;
     
     proc append base=match_zip9_&st new=failed_direct_try_zip9_&st; run;
     
     proc sort data=match_zip9_&st; by zip zip4; run;
     proc sort data=z9.zip9_census_lookup_&st out=lookup_&st; by zip zip4; run;
     
     data zip9_matchkeys_&st;
        merge match_zip9_&st(in=_a_ keep=&id zip zip4)
              lookup_&st(in=_b_ keep=zip zip4 census_level_match census_cnty census_tract census_tract_suffix block_group);
        by zip zip4;
        if _a_ and _b_;
     run;

     proc sql;
       CREATE TABLE zip9_census_match_&st as
          SELECT aa.*
            FROM
               (
                SELECT a.&id, a.census_level_match, b.*
                  FROM zip9_matchkeys_&st a, census_&st b
                 WHERE a.census_level_match='1' and b.sumlev='871'
                   AND translate(a.zip,'+',' ') = translate(b.zip5,'+',' ')
              UNION ALL
                SELECT c.&id, c.census_level_match, d.*
                  FROM zip9_matchkeys_&st c, census_&st d
                 WHERE c.census_level_match='2' and d.sumlev='140'
                   AND compress(translate(c.census_cnty,'+',' ')||
                                translate(c.census_tract,'+',' ')||
                                translate(c.census_tract_suffix,'+',' ')) =
                       compress(translate(d.county,'+',' ')||
                                translate(d.tract,'+',' '))
              UNION ALL
                SELECT e.&id, e.census_level_match, f.*
                  FROM zip9_matchkeys_&st e, census_&st f
                 WHERE e.census_level_match='3' and f.sumlev='150'
                   AND compress(translate(e.census_cnty,'+',' ')||
                                translate(e.census_tract,'+',' ')||
                                translate(e.census_tract_suffix,'+',' ')||
                                translate(e.block_group,'+',' ')) =
                       compress(translate(f.county,'+',' ')||
                                translate(f.tract,'+',' ')||
                                translate(f.blkgrp,'+',' '))
               ) aa
       ;
       quit;
     run;
     
     proc sort data=match_zip9_&st(keep=&id zip) out=tried_&st; by &id; run;
     proc sort data=zip9_census_match_&st(keep=&id) out=matched_&st; by &id; run;
     
     data failed_zip9_try_zip5_&st(keep=&id zip);
        merge tried_&st(in=_a_)
              matched_&st(in=_b_);
        by &id;
        if _a_ and not _b_;
     run;

     proc append base=match_zip5_&st new=failed_zip9_try_zip5_&st; run;
     
     proc sql;
       CREATE TABLE zip5_census_match_&st as
           SELECT a.&id, '1' as census_level_match, b.*
             FROM match_zip5_&st a, census_&st b
            WHERE b.sumlev='871'
              AND translate(a.zip,'+',' ') = translate(b.zip5,'+',' ');
       quit;
     run;
     
     proc sort data=match_zip5_&st(keep=&id) out=tried_&st; by &id; run;
     proc sort data=zip5_census_match_&st(keep=&id) out=matched_&st; by &id; run;
     
     data failed_zip5_&st(keep=&id);
        merge tried_&st(in=_a_)
              matched_&st(in=_b_);
        by &id;
        if _a_ and not _b_;
     run;
     
     proc append base=non_matches_&st new=failed_zip5_&st; run;
     
     data final_&st;
        set direct_census_match_&st(in=_a_)
            zip9_census_match_&st(in=_b_)
            zip5_census_match_&st(in=_c_)
            non_matches_&st(in=_d_);
        format census_source_match $6.;
        if _a_ then census_source_match="DIRECT"; else
        if _b_ then census_source_match="ZIP9"; else
        if _c_ then census_source_match="ZIP5"; else
        if _d_ then census_source_match="NONE";
        flag_census_match=_a_ or _b_ or _c_;
        label flag_census_match="FLAG: MATCHED TO CENSUS (THRU DIRECT, ZIP9 OR ZIP5)";
     run;

     %if &force=Y %then %do;
       proc append base=census_matched_all new=final_&st force; run;
     %end;
     %else %do;
       proc append base=census_matched_all new=final_&st; run;     
     %end;

     proc datasets library=work nolist;
     delete final_&st direct_census_match_&st zip9_census_match_&st zip5_census_match_&st non_matches_&st lookup_&st census_&st match_direct_&st;
     run; 
     
     %let i=%eval(&i+1);
   %end;  
%end;    /*length(&stlst)>0*/
   %*spltsort(inpfile=client.&client_data._matched, sortvars=&id, pieces=20, outfile=_direct);  *already sorted;
   %spltsort(inpfile=census_matched_all, sortvars=&id, pieces=20, outfile=_census);   
   
   data client.&client_data._matched_cen;
      merge client.&client_data._matched(in=_a_ drop=census_level_match)
            _census(in=_b_ 
              rename=(county=census_county
                      state=census_state
                      zip5=census_zip5));  ***rename fields with the same name in both datasets;
      by &id;
      if _a_;
      if not _b_ then do;
         census_source_match="NONE";
         flag_census_match=0;
      end;
   run;

%mend;