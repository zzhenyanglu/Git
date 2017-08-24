********************************************************************************************;
* Program: tls_test_readin_lf.sas
* Purpose: import raw txt files into sas datasets
********************************************************************************************;

%macro parsimony(inlib=, indata=, outlib=, outdata=, client_match=);

options mprint ps=9999;

   %let suff = JR SR SENIOR PHD PROF PROFESSOR I II III IV V DDS MD CPA CAPTAIN CAPT ESQ LLD RET RN DO ;
   %let suff_char ='JR' 'SR' 'SENIOR' 'PHD' 'PROF' 'PROFESSOR' 'I' 'II' 'III' 'IV' 'V' 'DDS' 'MD' 'CPA' 'CAPTAIN' 'CAPT' 'ESQ' 'LLD' 'RET' 'RN' 'DO';
   %let prefix='MR' 'MRS' 'MS' 'MISS' 'DOCTOR' 'DR' 'CAPTAIN' 'CAPT' 'CPT' 'LT' '1LT' 'FATHER' 'REV' 'REVEREND' 'SGT' 'MAJ' 'MAJOR' 'COL' 'COLONEL' 
               'GEN' 'GENERAL' 'GOV' 'GOVERNOR' 'HON' 'HONOR' 'LTCOL' 'MSGT' 'RABBI' 'SISTER' 'ADM' 'ADMORAL' 'ATTY' 'ATTORNEY' 'BROTHER' 'CHIEF' 'ELDER';
   %let pre_sur='AM' 'DA' 'DE' 'DEL' 'DELLA' 'DEN' 'DER' 'DES' 'DETTO' 'DI' 'DIT' 'DOS' 'DU' 'LA' 'LAS' 'LE' 'LI' 'LO' 'OP' 'SAINT' 'ST' 'TAN' 'TE' 'TEN' 'TER'
        	'UIT' 'UYT' 'VAN' 'VER'	'VOM' 'VON' 'VULGO' 'ZU' 'ZUM' 'ZUR' 'MC' 'MAC' ;
   %let numbers='0' '1' '2' '3' '4' '5' '6' '7' '8' '9';
   %let roadtype='LOOP' 'TRL' 'CROSSING' 'RD' 'ROAD' 'RAOD' 'STREET' 'AVE' 'AV' 'ST' 'AVENUE' 'AVEN' 'LANE' 'LN'
                 'DR' 'DRIVE' 'CT' 'CRT' 'COURT' 'WAY' 'PLACE' 'PL' 'PARKWAY' 'PKW' 'PKWY' 'HIGHWAY' 'HIHGWAY' 'HGIHWAY' 'HWY' 'CIRCLE' 'CIR'
                 'TER' 'TERR' 'TRCE' 'TERRACE' 'BLVD' 'BOULEVARD' 'BLVRD' 'TURNPIKE' 'TPKE' 'STR' 'JUNCTION' 'ROUTE';
   %let direction='N' 'S' 'E' 'W' 'NE' 'SE' 'NW' 'SW' 'EAST' 'NORTH' 'SOUTH' 'WEST' 'NORTHWEST' 'NORTHEAST' 'SOUTHWEST' 'SOUTHEAST';
   %let units='LOT' 'UNIT' 'APT' 'APARTMENT' 'BLDG' 'FL' 'FLOOR' 'REAR' 'FLR' '#' 'TRAILER' 'CONDO' 'TRLR' 'STE' 'SUITE' 'FLOOR1' 'FLOOR2' 'FLOOR3'
              'FL1' 'FL2' 'FL3' 'FLR1' 'FLR2' 'FLR3' 'FL#1' 'FL#2' 'FL#3' 'BASEMENT' 'BSMT' 'APT#' '1FL' '2FL' 'UPSTAIRS' 'REAR1' 'REAR2';
   %let po='PO ' 'P.O' 'P O' 'PO.' 'RR ' 'RT ' 'RUR' 'POS';
   %let letter='A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z';
   %let unnum='1' '2' '3' '4' '5' '6' '7' '8' '9' '0' 'FIRST' 'SECOND' 'THIRD' 'FOURTH' 'GARDEN' '1ST' '2ND' '3RD' '4TH' 'TOP' 'BOTTOM' 'BASEMENT';
   %let dirout='EAST' 'NORTH' 'WEST' 'SOUTH' 'NORTHWEST' 'NORTHEAST' 'SOUTHWEST' 'SOUTHEAST' 'N' 'S' 'E' 'W';
   %let states= 'AL' 'HI' 'MA' 'NM' 'SD' 'AK' 'ID' 'MI' 'NY' 'TN'  'AZ' 'IL' 'MN' 'NC' 'TX' 'AR' 'IN' 'MS' 'ND' 'UT'
                'CA' 'IA' 'MO' 'OH' 'VT' 'CO' 'KS' 'MT' 'OK' 'VA' 'CT' 'KY' 'NE' 'OR' 'WA' 'DE' 'LA' 'NV' 'PA' 'WV'
                'FL' 'ME' 'NH' 'RI' 'WI' 'GA' 'MD' 'NJ' 'SC' 'WY' 'DC';

proc format;
   value $suffix
      'ROUTE'='ROUTE   '
      'AV'='AVE'
      'AVEN'='AVE'
      'AVENUE'='AVE'
      'BOULEVARD'='BLVD'
      'BLVRD'='BLVD'
      'CIRCLE'='CIR'
      'COURT'='CT'
      'CRT'='CT'
      'DRIVE'='DR'
      'HIGHWAY'='HWY'
      'LANE'='LN'
      'PARKWAY'='PKWY'
      'PLACE'='PL'
      'ROAD'='RD'
      'RAOD'='RD'
      'TERRACE'='TER'
      'TERR'='TER'
      'TRCE'='TER'
      'TURNPIKE'='TPKE'
      'STR'='ST'
      'STREET'='ST';
   value $direct
      'EAST'='E'
      'NORTH'='N'
      'SOUTH'='S'
      'WEST'='W'
      'NORTHWEST'='NW'
      'NORTHEAST'='NE'
      'SOUTHWEST'='SW'
      'SOUTHEAST'='SE';
   value $apt
      'APARTMENT'='APT'
      'TRAILER'='TRLR      ';
run;

/***
**** ------ JDS CHANGE 4/7/2012:  wasnt working when inlib was defined in macro call:  
                                  think this was only working in matching because used work library so resolved to nothing:
                                  with inlib defined, turns into LIBDATASETNAME not LIB.DATASETNAME ;
*proc sort data=&inlib.&indata. out=temp;    
***/
proc sort data=&inlib..&indata. out=temp;
    by &zip5; *CAC_addr_zip;
run;

********************************;
* PURPOSE: CREATE A DATASET
* WITH OUR PARSED NAME AND
* ADDRESS AND THE CACDIRECT
* NAME AND ADDRESS ALONG WITH 
* FLAG MASTER MATCH AND QUALITY
* OF MATCH AND TWO ID FIELDS
********************************;

data temp;
   set temp;
* CREATE FULL ADDRESS AND NAME *;
%if &client_match=Y %then %do;
   cacdir_full_addr=clean_addr;
%end;
%else %if &client_match ne Y %then %do;
   mk_zip=CAC_addr_zip;
   cacdir_full_addr=compbl(strip(CAC_addr_num)||" "||strip(CAC_addr_frac)||" "||strip(CAC_addr_street_pre)||" "||
                          strip(CAC_addr_street)||" "||
                          strip(CAC_addr_street_suff)||" "||strip(CAC_addr_street_suff_dir)||
                        " "||strip(CAC_addr_second_unit)||" "||strip(CAC_ADDR_po_route_num)||" "||strip(CAC_ADDR_po_box_designator));
   cacdir_full_name=compbl(strip(CAC_P1_NAME)||" "||strip(CAC_name_last));
   state=CAC_addr_state;
%end;
%if &client_match=Y %then %do;
   cacdir_full_name=clean_name;
%end;
   mk_scf=substr(mk_zip,1,3);
   st_scf = compress(state||'_'||mk_scf);

* USE PARSING LOGIC *;

*###########################*;
*###########################*;
* SECTION1: PARSE NAMES
*###########################*;
*###########################*;

  length title suffix $10 first_name mi_name last_name $30 ;

  name_up=upcase(left(strip(compbl((cacdir_full_name)))));

* IF LAST NAME HAS A COMMA AND A SUFFIX THEN CHANGE IT SO THERE IS NO COMMA *;

   %do pasnum=1 %to 21;
       if scan(name_up,-1,',') = "%scan(&suff,&pasnum)" then name_up=tranwrd(name_up,",%scan(&suff,&pasnum)"," %scan(&suff,&pasnum)");
   %end;

* NOW COMPRESS OUT THE COMMA AND COUNT THE NUMBER OF WORDS *;

  name_c=compress(name_up,".',*");
  namect=countw(name_c);

* GET FIVE NAMES *;

format name1-name5 $24.;
array nm{5} name1-name5;
   do psnm=1 to 5;
      nm{psnm}=scan(name_c,psnm,' ');
   end;

* IF SUFFIX IS IN THE LAST WORD THEN DEFINE SUFFIX *;

   if scan(name_c,-1,' ') in (&suff_char) then suffix=scan(name_c,-1,' ');
   else suffix=' ';

* CREATE TITLE FIRST_NAME MI NAME LAST_NAME SUFFIX BASED ON NUMBER OF WORDS IN FULL NAME FIELD *;

if namect =1 then do;
   title=' ';
   first_name=' ';
   mi_name=' ';
   last_name=name1;
   suffix=' ';
end;

  
if namect =2 then do;
   title=' ';
   first_name=name1;
   mi_name=' ';
   last_name=name2;
   suffix=' ';
end;

if namect=3 then do;
    if name1 in(&prefix) and name2 not in(&pre_sur)  then do; 
      title=name1;
      first_name=name2;
      mi_name=' ';
      last_name=name3;
      suffix=' ';
    end;
    if name1 in(&prefix) and name2 in(&pre_sur)  then do; 
      title=name1;
      first_name=' ';
      mi_name=' ';
      last_name=strip(name2)||' '||strip(name3);
      suffix=' ';
    end;
    if name1 not in(&prefix) and (name2 not in(&pre_sur) or name3 not in(&suff_char)) then do; 
      title=' ';
      first_name=name1;
      mi_name=name2;
      last_name=name3;
      suffix=' ';
    end;
    if name1 not in(&prefix) and name2 in(&pre_sur) then do; 
      title=' ';
      first_name=name1;
      mi_name=' ';
      last_name=strip(name2)||' '||strip(name3);
      suffix=' ';
    end;
    if name1 not in(&prefix) and name3 in(&suff_char) then do; 
      title=' ';
      first_name=name1;
      mi_name=' ';
      last_name=name2;
      suffix=name3;
    end;
    if name1 not in(&prefix) and length(name1)=1 and length(name2)=1 then do; 
      title=' ';
      first_name=strip(name1)||' '||strip(name2);
      mi_name=' ';
      last_name=name3;
      suffix=' ';
    end;
end;

if namect=4 then do;
    if name1 in(&prefix) and name4 not in(&suff_char) then do; 
      title=name1;
      first_name=name2;
      mi_name=name3;
      last_name=name4;
      suffix=' ';
    end;   
    if name1 in(&prefix) and name4 in(&suff_char) then do; 
      title=name1;
      first_name=name2;
      mi_name=' ';
      last_name=name3;
      suffix=name4;
    end;    
    if name1 in(&prefix) and name3 in(&pre_sur) then do; 
      title=name1;
      first_name=name2;
      mi_name=' ';
      last_name=strip(name3)||' '||strip(name4);
      suffix=' ';
    end;    
    if name1 in(&prefix) and name2 in('&','AND') then do; 
      title=' ';
      first_name=strip(name1)||' '||strip(name2)||' '||strip(name3);
      mi_name=' ';
      last_name=(name4);
      suffix=' ';
    end;  
    if name1 in(&prefix) and length(name2) =1 and length(name3)=1 then do; 
      title=name1;
      first_name=strip(name1)||' '||strip(name2);
      mi_name=' ';
      last_name=(name4);
      suffix=' ';
    end;  
if name1 not in(&prefix) and name4 not in(&suff_char) then do; 
      title=' ';
      first_name=name1;
      mi_name=strip(name2)||' '||strip(name3);
      last_name=name4;
      suffix=' ';
    end;      
    if name1 not in(&prefix) and name4 in(&suff_char) then do; 
      title=' ';
      first_name=name1;
      mi_name=name2;
      last_name=name3;
      suffix=name4;
    end;    
    if name1 not in(&prefix) and name3 in(&pre_sur) then do; 
      title=' ';
      first_name=name1;
      mi_name=name2;
      last_name=strip(name3)||' '||strip(name4);
      suffix=' ';
    end; 
    if name1 not in(&prefix) and name3 not in(&pre_sur) and name4 not in(&suff_char) then do; 
      title=' ';
      first_name=name1;
      mi_name=name2;
      last_name=strip(name3)||' '||strip(name4);
      suffix=' ';
    end; 
    if name1 not in(&prefix) and name2 in('&','AND') then do; 
      title=' ';
      first_name=strip(name1)||' '||strip(name2)||' '||strip(name3);
      mi_name=' ';
      last_name=(name4);
      suffix=' ';
    end;
     if name1 not in(&prefix) and length(name2) =1 and length(name3)=1 and name4 in(&suff_char) then do; 
      title=' ';
      first_name=strip(name1)||' '||strip(name2);
      mi_name=' ';
      last_name=(name3);
      suffix=name4;
    end; 
    if name1 not in(&prefix) and length(name2) =1 and length(name3)=1 and name3 in(&pre_sur) then do; 
      title=' ';
      first_name=strip(name1)||' '||strip(name2);
      mi_name=' ';
      last_name=strip(name3)||' '||strip(name4);
      suffix=' ';
    end;  
    if name1 not in(&prefix) and length(name2) =1 and length(name3)=1 and name3 not in(&pre_sur) then do; 
      title=' ';
      first_name=strip(name1)||' '||strip(name2);
      mi_name=name3;
      last_name=name4;
      suffix=' ';
    end;                    
end;

if namect= 5 then do;
    if name1 in(&prefix) and name5 in(&suff_char) then do;
       title=name1;
       first_name=name2;
       mi_name=name3;
       last_name=name4;
       suffix=name5;
    end;
    if name1 in(&prefix) and name5 not in(&suff_char) then do;
       title=name1;
       first_name=name2;
       mi_name=name3;
       last_name=strip(name4)||' '||strip(name5);
       suffix=' ';  
    end;
    if name1 in(&prefix) and name4 in(&pre_sur) then do;
       title=name1;
       first_name=name2;
       mi_name=name3;
       last_name=strip(name4)||' '||strip(name5);
       suffix=' ';  
    end;
    if name1 in(&prefix) and  name3 in('&','AND') then do;
       title=name1;
       first_name=strip(name2)||' '||strip(name3)||' '||strip(name4);
       mi_name=' ';
       last_name=name5;
       suffix=' ';
    end;
    if name1 in(&prefix) and name5 not in(&suff_char) and length(name2)=1 and length(name3)=1 then do;
       title=name1;
       first_name=strip(name2)||' '||strip(name3);
       mi_name=' ';
       last_name=strip(name4)||' '||strip(name5);
       suffix=' ';
    end;
    if name1 in(&prefix) and name5 in(&suff_char) and length(name2)=1 and length(name3)=1 then do;
       title=name1;
       first_name=strip(name2)||' '||strip(name3);
       mi_name=' ';
       last_name=name4;
       suffix=name5;
    end;
    if name1 in(&prefix) and name4 in(&pre_sur) and length(name2)=1 and length(name3)=1 then do;
       title=name1;
       first_name=strip(name2)||' '||strip(name3);
       mi_name=' ';
       last_name=strip(name4)||' '||strip(name5);
       suffix=' ';
    end;
    if name1 not in(&prefix) and name4 not in(&pre_sur) and name5 in(&suff_char) then do; 
       title=' ';
       first_name=name1;
       mi_name=strip(name2)||' '||strip(name3);
       last_name=name4;
       suffix=name5;
    end; 
    if name1 not in(&prefix) and name4 not in(&pre_sur) and name5 not in(&suff_char) and length(name4) ne 1 then do; 
       title=' ';
       first_name=name1;
       mi_name=strip(name2)||' '||strip(name3);
       last_name=strip(name4)||' '||strip(name5);
       suffix=' ';
    end; 
    if name1 not in(&prefix) and name4 not in(&pre_sur) and name5 not in(&suff_char) and length(name4) = 1 then do; 
       title=' ';
       first_name=name1;
       mi_name=strip(name2)||' '||strip(name3)||' '||strip(name4);
       last_name=name5;
       suffix=' ';
    end; 
    if name1 not in(&prefix) and name4 in(&pre_sur) then do; 
       title=' ';
       first_name=name1;
       mi_name=strip(name2)||' '||strip(name3);
       last_name=strip(name4)||' '||strip(name5);
       suffix=' ';
    end; 
    if name1 not in(&prefix) and name5 in(&suff_char) and name3 in(&pre_sur) then do; 
       title=' ';
       first_name=name1;
       mi_name=name2;
       last_name=strip(name3)||' '||strip(name4);
       suffix=name5;
    end;
    if name1 not in(&prefix) and name2 in('&','AND') and name5 in(&suff_char) then do;
       first_name=strip(name1)||' '||strip(name2)||' '||strip(name3);
       mi_name=' ';
       last_name=name4;
       suffix=name5;
    end;
    if name1 not in(&prefix) and name2 in('&','AND') and name4 in(&pre_sur) then do;
       first_name=strip(name1)||' '||strip(name2)||' '||strip(name3);
       mi_name=' ';
       last_name=strip(name4)||' '||strip(name5);
       suffix=' ';
    end;
    if name1 not in(&prefix) and name5 in(&suff_char) and length(name1)=1 and length(name2)=1 then do;
       title=' '; 
       first_name=strip(name1)||' '||strip(name2);
       mi_name=name3;
       last_name=name4;
       suffix=name5;
    end;
    if name1 not in(&prefix) and name5 in(&suff_char) and length(name1)=1 and length(name2)=1 and name3 in (&pre_sur) then do;
       title=' '; 
       first_name=strip(name1)||' '||strip(name2);
       mi_name=' ';
       last_name=strip(name3)||' '||strip(name4);
       suffix=name5;
    end;
end;
 

*###############################*;
*###############################*;
* SECTION2: PARSE ADDRESSES
*###############################*;
*###############################*;

      clean_addr=strip(cacdir_full_addr);

* GET RID OF SPECIAL CHARACTERS EXCEPT FOR FRACTIONS LIKE 1/2 *;

   new_addr=compress(upcase(strip(clean_addr)),".'*@^~,!$%()&-+=");
   if index(new_addr,'/')>0 and indexw(new_addr,'1/2')=0 then new_addr=compress(upcase(strip(new_addr)),"/");

   addr_length=countw(new_addr,' ');

   if addr_length=1 then new_addr_street=new_addr;
   else if addr_length gt 1 then do;

* GETS NUMBER IF ADDRESS STARTS WITH A NUMBER *;

   if substr(new_addr,1,1) in (&numbers) then new_addr_num=scan(new_addr,1,' ');

* CREATES A PO ADDRESS FOR PO BOXES AND RURAL ROUTES *;

   if length(new_addr) ge 3 then do;
      if substr(new_addr,1,3) in (&po) then new_addr_po=new_addr;
   end;

   if new_addr_po='' then do;


* DEALS WITH ADDRESSES LIKE 1 NORTH STREET *;

   if new_addr_num ne '' and scan(new_addr,-1,' ') in (&roadtype) and addr_length=3 and scan(new_addr,2,' ') in (&dirout) then do;
      new_addr_street=scan(new_addr,2,' ');
      new_addr_street_suffix=scan(new_addr,3,' ');
   end;

   else if new_addr_num='' or scan(new_addr,-1,' ') not in (&roadtype) or scan(new_addr,2,' ') ne scan(new_addr,-2,' ') or scan(new_addr,2,' ') not in (&dirout) then do;

* IF THE LAST WORD STARTS WITH A # SIGN THEN IT CREATES A UNIT NUMBER. THEN LOOKS *;
* FOR STREET TYPE AND STREET NAME GIVEN PREVIOUS CONDITION *;

   pas1=scan(new_addr, -1,' ');
   lenpas=length(pas1);

       if lenpas ge 3 then do;
          if substr(scan(new_addr, -1,' '),1,3)='APT' then do;
          new_addr_unit_number=scan(new_addr,-1,' ');
             if scan(new_addr,-2,' ') in (&roadtype) then do;
                new_addr_street_suffix=scan(new_addr,-2,' ');
                if addr_length=4 then new_addr_street=scan(new_addr,-3,' ');
                else if addr_length=5 then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' ')));
             end;
             else if scan(new_addr,-2,' ') not in (&roadtype) then do;
                if addr_length=3 then new_addr_street=scan(new_addr,-2,' ');
                else if addr_length=4 then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' ')));
             end;          
          end;
      end;
      if substr(scan(new_addr, -1,' '),1,1)='#' then do;
          new_addr_unit_number=scan(new_addr,-1,' ');
             if scan(new_addr,-2,' ') in (&roadtype) then do;
                new_addr_street_suffix=scan(new_addr,-2,' ');
                if addr_length=4 then new_addr_street=scan(new_addr,-3,' ');
                else if addr_length=5 then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' ')));
             end;
             else if scan(new_addr,-2,' ') not in (&roadtype) then do;
                if addr_length=3 then new_addr_street=scan(new_addr,-2,' ');
                else if addr_length=4 then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' ')));
             end;          
      end;


   drop pas1 lenpas;

* LOOKS TO SEE IF THE SECOND TO LAST WORD IS A TYPE OF UNIT, CALLS THE LAST WORD A UNIT NUMBER *;
* IF THIS IS THE CASE, LOOKS TO SEE IF THE THIRD TO LAST WORD IS A ROAD TYPE, IF SO CALLS THAT *;
* WORD THE SUFFIX AND THE PREVIOUS THE STREET NAME BUT IF NOT THEN IT CALLS THE THIRD TO LAST WORD THE STREET NAME *;

   format new_addr_unit_type $10.;

   stupid="     |";

   if scan(new_addr, -2,' ') in (&units) or strip(substr(strip(scan(new_addr,-2,' ')||stupid),1,4)) in ('UNIT' 'TRLR') or strip(substr(strip(scan(new_addr,-2,' ')||stupid),1,3))='APT' then do;
      new_addr_unit_type=scan(new_addr, -2,' ');
      new_addr_unit_number=scan(new_addr, -1,' ');
         if scan(new_addr,-3,' ') in (&roadtype) then do;
             new_addr_street_suffix=scan(new_addr,-3,' ');
            if addr_length=5 then new_addr_street=scan(new_addr, -4,' ');
            else if addr_length=6 then do;
               if scan(new_addr,2,' ') in (&direction) then do;
                  new_addr_pre_directional=scan(new_addr,2,' ');
                  new_addr_street=scan(new_addr,3,' ');
               end;
               if scan(new_addr,2,' ') not in (&direction) then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' ')));
            else if addr_length=7 then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' ')));
            else if addr_length=8 then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' '))||" "||strip(scan(new_addr,5,' ')));
            end;
         end;
         else if scan(new_addr,-3,' ') not in (&roadtype) then do;
            if scan(new_addr,-3,' ') in (&direction) then do;
               new_addr_street_post_direction=scan(new_addr,-3,' ');
                  if scan(new_addr,-4,' ') in (&roadtype) then do;
                     new_addr_street_suffix=scan(new_addr,-4,' ');
                     if addr_length=6 then do;
                        new_addr_street=scan(new_addr,2,' ');
                     end;
                     if addr_length=7 then new_addr_street=compbl(scan(new_addr,2,' ')||" "||scan(new_addr,3,' '));
                  end;
                  else if scan(new_addr,-4,' ') not in (&roadtype) then do;
                     if addr_length=5 then new_addr_street=scan(new_addr,2,' ');
                     else if addr_length=6 then new_addr_street=compbl(scan(new_addr,2,' ')||" "||scan(new_addr,3,' '));
                     else if addr_length=7 then do;
                        if scan(new_addr,2,' ') in (&direction) then do;
                           new_addr_pre_directional=scan(new_addr,2,' ');
                           new_addr_street=compbl(strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' ')));
                        end;
                        else if scan(new_addr,2) not in (&direction) then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' ')));
                     end;
                  end;
            end;
            else if scan(new_addr,-3,' ') not in (&direction) then do;
               if addr_length=4 then new_addr_street=scan(new_addr,2,' ');
               else if addr_length=5 then do;
                  if scan(new_addr,2,' ') in (&direction) then do;
                     new_addr_pre_directional=scan(new_addr,2,' ');
                     new_addr_street=scan(new_addr,3,' ');
                  end;
                  else if scan(new_addr,2,' ') not in (&direction) then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' ')));
               end;
               else if addr_length=6 then do;
                  if scan(new_addr,2) in (&direction) then new_addr_street=compbl(strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' ')));
                  else if scan(new_addr,2) not in (&direction) then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' ')));
               end;
               else if addr_length=7 then do;
                  if scan(new_addr,2) in (&direction) then do;
                     new_addr_pre_directional=scan(new_addr,2,' ');
                     new_addr_street=compbl(strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' '))||" "||strip(scan(new_addr,5,' ')));
                  end;
                  else if scan(new_addr,2) not in (&direction) then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' '))||" "||strip(scan(new_addr,5)));
               end;
            end;

         end;
   end;

* UNIT TYPE IN THIRD TO LAST WORD *;

   if addr_length ge 3 then do;

   if scan(new_addr,-3,' ') in (&units) or strip(substr(strip(scan(new_addr,-3,' ')||stupid),1,4)) in ('UNIT' 'TRLR') or strip(substr(strip(scan(new_addr,-3,' ')||stupid),1,3))='APT' then do;
      new_addr_unit_type=scan(new_addr,-3, ' ');
      new_addr_unit_number=compbl(scan(new_addr,-2,' ')||" "||scan(new_addr,-1,' '));
         if scan(new_addr,-4,' ') in (&roadtype) then do;
            if addr_length=6 then new_addr_street=scan(new_addr,2);
            else if addr_length=7 then new_addr_street=compbl(scan(new_addr,2,' ')||" "||scan(new_addr,3,' '));
        end;
        else if scan(new_addr,-4,' ') not in (&roadtype) then do;
           if addr_length=5 then new_addr_street=scan(new_addr,2);
           else if addr_length=6 then new_addr_street=compbl(scan(new_addr,2,' ')||" "||scan(new_addr,3,' '));
        end;
   end;

   end;

* LOOKS TO SEE IF THE LAST WORD IS A TYPE OF UNIT, SEES IF THE PREV *;
* WORD IS A UNIT NUMBER, CHECKS PREV WORDS FOR ROAD TYPE AND STREET NAMES *;

   if ((scan(new_addr,-1,' ') in (&units) or strip(substr(strip(scan(new_addr,-1,' ')||stupid),1,4)) in ('UNIT' 'TRLR') or strip(substr(strip(scan(new_addr,-1,' ')||stupid),1,3))='APT')) and scan(new_addr,-1,' ') ne new_addr_unit_number then do;
      new_addr_unit_type=scan(new_addr,-1,' ');
         if scan(new_addr,-2,' ') in (&unnum) then do;
            new_addr_unit_number=scan(new_addr,-2,' ');
               if scan(new_addr,-3,' ') in (&roadtype) then do;
                  new_addr_street_suffix=scan(new_addr,-3,' ');
                  if addr_length=5 then new_addr_street=scan(new_addr,-4,' ');
                  else if addr_length=6 then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' ')));
               end;
               else new_addr_street=scan(new_addr,-3,' ');
         end;
         else if scan(new_addr,-2,' ') not in (&unnum) then do;
            if scan(new_addr,-2,' ') in (&roadtype) then do;
               new_addr_street_suffix=scan(new_addr,-2,' ');
                  if addr_length=4 then new_addr_street=scan(new_addr,-3,' ');
                  else if addr_length=5 then new_addr_street=compbl(strip(scan(new_addr,-4,' '))||" "||strip(scan(new_addr,-3,' ')));
            end;
            else if scan(new_addr,-2,' ') not in (&roadtype) then new_addr_street=scan(new_addr,-2,' ');
         end;
   end;

   drop stupid;

* LOOKS TO SEE IF THE SECOND WORD IS DIRECTIONAL, NAMES WORD AFTER THE *;
* STREET AND NAMES THE STREET SUFFIX *;

   if scan(new_addr, 2,' ') in (&direction) then do;
       new_addr_pre_directional=scan(new_addr, 2,' ');

          if scan(new_addr,4,' ') in (&roadtype) then do;
             new_addr_street=scan(new_addr, 3,' ');
             new_addr_street_suffix=scan(new_addr,4,' ');

                if scan(new_addr, -1,' ') in (&direction) and new_addr_unit_number ne scan(new_addr, -1,' ') then new_addr_street_post_direction=scan(new_addr, -1,' ');
                else if substr(scan(new_addr,-1,' '),1,1) in (&numbers) and scan(new_addr,-2,' ') not in (&units) then new_addr_road_number=scan(new_addr,-1,' ');
          end;

          else if scan(new_addr,5,' ') in (&roadtype) then do;
             new_addr_street=compbl(strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' ')));
             new_addr_street_suffix=scan(new_addr,5,' ');
          end;

          else if addr_length=3 then new_addr_street=scan(new_addr,3,' ');

          else if addr_length=4 then new_addr_street=compbl(strip(scan(new_addr,3))||" "||strip(scan(new_addr,4)));

          else if scan(new_addr,-1,' ') in (&direction) and addr_length=5 then do;
             new_addr_street_post_direction=scan(new_addr,-1,' ');
             new_addr_street=compbl(scan(new_addr,3,' ')||" "||scan(new_addr,4,' '));
          end;

          else if scan(new_addr, -1,' ') not in (&direction) and addr_length=4 then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' ')));

   end;

   else if scan(new_addr, 2,' ') not in (&direction) then do;

* LOOKS TO SEE IF LAST WORD IS A ROAD TYPE THEN NAMES THE STREET SUFFIX AND STREET *;

   if scan(new_addr,-1,' ') in (&roadtype) and addr_length ne 2 then do;
      new_addr_street_suffix=scan(new_addr,-1,' ');

      if addr_length=3 then new_addr_street=scan(new_addr,-2,' ');

      else if addr_length=4 then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' ')));
      else if addr_length=5 and scan(new_addr,2,' ') in (&direction) then new_addr_street=compbl(strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' ')));
      else if addr_length=5 and scan(new_addr,2,' ') not in (&direction) then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' ')));
      else if addr_length=6 and scan(new_addr,2,' ') in (&direction) then new_addr_street=compbl(strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' '))||" "||strip(scan(new_addr,5,' ')));
      else if addr_length=6 and scan(new_addr,2,' ') not in (&direction) then
         new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' '))||" "||strip(scan(new_addr,5,' ')));
   end;
* IF LAST WORD BEGINS WITH A NUMBER AND UNIT NUMBER NOT DEFINED THEN *;
* CALLS IT A ROAD NUMBER, LOOKS FOR STREET SUFFIX AND STREET NAME *;

   if substr(scan(new_addr, -1,' '),1,1) in (&numbers) and new_addr_unit_number='' then do;
      new_addr_road_number=scan(new_addr, -1,' ');
         if scan(new_addr,-2,' ') in (&roadtype) and scan(new_addr,-2,' ')=scan(new_addr,3,' ') then do;
            new_addr_street_suffix=scan(new_addr,-2,' ');
            new_addr_street=scan(new_addr,-3,' ');
         end;
         else if scan(new_addr,-2,' ') in (&roadtype) and scan(new_addr,-2,' ')=scan(new_addr,4,' ') then do;
            new_addr_street_suffix=scan(new_addr,-3,' ');
            new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' ')));
         end;
         else if addr_length=3 then new_addr_street=scan(new_addr,-2,' ');
   end;

* IF STREET AND SUFFIX BLANK THEN LOOKS FOR DIRECTIONAL IN LAST WORD, DEFINES *;
* POST DIRECTIONAL AND LOOKS FOR STREET AND STREET SUFFIX *;

   if new_addr_street=new_addr_street_suffix='' then do;
      if scan(new_addr, -1,' ') in (&direction) then do;
         new_addr_street_post_direction=scan(new_addr, -1,' ');
            if scan(new_addr,-2,' ') in (&roadtype) then do;
               new_addr_street_suffix=scan(new_addr,-2,' ');
               if addr_length=4 then new_addr_street=scan(new_addr,-3,' ');
               else if addr_length=5 then new_addr_street=compbl(strip(scan(new_addr,-4,' '))||" "||strip(scan(new_addr,-3,' ')));
            end;

            else if substr(scan(new_addr,-2,' '),1,1) in (&numbers) then do;
               new_addr_road_number=scan(new_addr,-2,' ');
                  if scan(new_addr,-3,' ') in (&roadtype) and addr_length ne 4 then do;
                     new_addr_street_suffix=scan(new_addr,-3,' ');
                     new_addr_street=scan(new_addr,-4,' ');
                  end;
                  else if scan(new_addr,-3,' ') in ('ROUTE' 'HIGHWAY') and addr_length=4 then new_addr_street=scan(new_addr,2,' ');
                  else if addr_length=4 then new_addr_street=scan(new_addr,-2,' ');
                  else if addr_length=5 then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' ')));
            end;

            else if addr_length=3 then new_addr_street=scan(new_addr,2,' ');
            else if addr_length=4 then new_addr_street=compbl(strip(scan(new_addr,-3,' '))||" "||strip(scan(new_addr,-2,' ')));
            else if addr_length=5 then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' ')));
      end;
      else if scan(new_addr, -1,' ') not in (&direction) and scan(new_addr,-2,' ')=scan(new_addr,3,' ') then
         new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' '))||" "||strip(scan(new_addr,4,' ')));
   end;

* IF THERE ARE ONLY TWO WORDS AND THE ADDRESS NUMBER IS DEFINED THEN CREATES THE SECOND WORD TO BE THE STREET *;

   if new_addr_street=new_addr_street_suffix='' and new_addr_num ne '' and addr_length=2 then new_addr_street=scan(new_addr,-1,' ');

* ALLOWS FOR STREETS SUCH AS AVENUE A *;

   if new_addr_street=new_addr_street_suffix='' and new_addr_num ne '' and substr(scan(new_addr,-1,' '),1,1) in (&letter) and scan(new_addr,-2,' ') in ('AVENUE' 'AVE') then
      new_addr_street=compbl(strip(scan(new_addr,-2,' '))||" "||strip(scan(new_addr,-1,' ')));

   else if new_addr_street=new_addr_street_suffix='' and new_addr_num ne '' and addr_length=3 then new_addr_street=compbl(strip(scan(new_addr,2,' '))||" "||strip(scan(new_addr,3,' ')));

end;
end;
end;
end;

* CHANGES ADDRESSES WITH NO NUMBER TO JUST BE THE ORIGINAL ADDRESS BUT WITHOUT SPECIAL CHARACTERS *;

   if indexc(new_addr,"0123456789")=0 then new_addr_street=new_addr;

* PUT STATE ROUTE AND OTHER SIMILAR INTO ONE STREET ADDRESS FIELD *;

   if (new_addr_street='STATE' and new_addr_street_suffix in ('ROUTE' 'HIGHWAY')) or (new_addr_street='COUNTY' and new_addr_street_suffix in('ROAD' 'ROUTE' 'RD' 'HIGHWAY')) or
      (new_addr_street='US' and new_addr_street_suffix in('HIGHWAY' 'HWY' 'ROUTE')) or (new_addr_street='&state' and new_addr_street_suffix in ('ROUTE' 'HIGHWAY')) then do;
      new_addr_street=compbl(new_addr_street||" "||new_addr_street_suffix||" "||new_addr_road_number);
      new_addr_road_number='';
      new_addr_street_suffix='';
   end;

* GETS RID OF SUFFIX IF IT IS THE ROAD NUMBER *;

   if new_addr_street_suffix=new_addr_road_number then new_addr_street_suffix='';

* PUTS ROUTE WITH NUMBER TO CREATE STREET NAME *;

   if (new_addr_street='ROUTE' and new_addr_street_suffix='' and new_addr_road_number ne '') then do;
      new_addr_street=compbl(new_addr_street||" "||new_addr_road_number);
      new_addr_road_number='';
   end;

* DEALS WITH JUST ONE LETTER IN FRONT OF STREET NAME *;

   if countw(new_addr_street,' ')=2 and scan(new_addr_street,1,' ') in (&letter) and new_addr_pre_directional='' then do;
      new_addr_pre_directional=scan(new_addr_street,1,' ');
      new_addr_street=scan(new_addr_street,2,' ');
   end;

* DEAL WITH FRACTIONS *;

   if length(new_addr_street) ge 3 then do;

   if substr(new_addr_street,1,3)='1/2' then do;
      new_addr_fraction=scan(new_addr_street,1,' ');
         if countw(new_addr_street,' ')=2 then new_addr_street=scan(new_addr_street,2,' ');
         else if countw(new_addr_street,' ')=3 then new_addr_street=compbl(scan(new_addr_street,2,' ')||" "||scan(new_addr_street,3,' '));
         else if countw(new_addr_street,' ')=4 then do;
            if scan(new_addr_street,2,' ') in (&direction) then do;
               new_addr_pre_directional=scan(new_addr_street,2,' ');
               new_addr_street=compbl(scan(new_addr_street,3,' ')||" "||scan(new_addr_street,4,' '));
            end;
            else if scan(new_addr_street,2,' ') not in (&direction) then new_addr_street=compbl(scan(new_addr_street,2,' ')||" "||scan(new_addr_street,3,' ')||" "||scan(new_addr_street,4,' '));
         end;
   end;

   end;

* ROAD NAMES LIKE UNITY OR APARTMENT DR *;

   if new_addr_unit_number=new_addr_street_suffix then new_addr_unit_number='';

* FORMAT SUFFIX, DIRECTIONS AND UNIT TYPES *;

   new_addr_street_suffix=strip(put(new_addr_street_suffix, $suffix.));
   new_addr_pre_directional=put(new_addr_pre_directional, $direct.);
   new_addr_unit_type=strip(put(new_addr_unit_type, $apt.));

* DROP SOME UNNECESSARY FIELDS *;

   drop clean: name_up name_c namect psnm addr_length;

* CREATE A FULL ADDRESS FIELD *;

   if new_addr_street='' and new_addr_po ne '' then new_addr_street=new_addr_po;

* CREATE FUZZY AND EXACT *;
   street_exact=new_addr_street;
   street_fuzzy1=soundex(compress(street_exact,'!'));

     if substr(new_addr_street,1,1) in (&numbers) then street_fuzzy1=new_addr_street;
     else if length(new_addr_street) ge 3 then do;
        if compbl(upcase(substr(new_addr_street, 1, 3))) in (&po) then street_fuzzy1=new_addr_street;
     end;
     else if length(new_addr_street) ge 3 then do;
        if upcase(substr(new_addr_street,1,3)) eq 'AVE' then street_fuzzy1=new_addr_street; 
     end;
     else if length(street_fuzzy1) lt 3 then street_fuzzy1=new_addr_street;

   new_SUB_name=length(last_name);

   if new_SUB_name < 7 then 
      do until (length(last_name) = 7);
          last_name=trim(last_name)||'!';
      end;
   last_name_exact=compress(last_name,'!');
   last_name_fuzzy1=soundex(compress(last_name,'!'));
run;



data &outlib..&outdata. %if &client_match ne Y %then %do; (keep=CAC_PRODUCTION CAC_ACTIVE_FLAG CAC_QTR MK_SCF st_scf CAC_HH_PID MKEY1 MKEY2 MKEY3 MKEY4 MKEY5 MKEY6 MKEY7) %end;
                        %else %if &client_match=Y %then %do; (drop=new_: street: cacdir_full: title first: mi: last: name:) %end;;
   length MKEY1 $1329 MKEY2 $529 MKEY3 $329 MKEY4 $329 MKEY5 $499 MKEY6 $699 MKEY7 $499;
   set temp;
* MOST FIELDS AND ZIP *;
/* BOTH ARE EXACT */
MKEY1=  compress(last_name_exact || new_addr_pre_directional || new_addr_num || new_addr_fraction || street_exact || new_addr_street_suffix || new_addr_street_post_direction || new_addr_unit_number || mk_zip); 
/* BOTH ARE EXACT */
MKEY2=  compress(last_name_exact || new_addr_num || street_exact|| new_addr_unit_number || mk_zip);
/* BOTH ARE EXACT */
MKEY3=  compress(last_name_exact || new_addr_num || street_exact || mk_zip); 
/* FUZZY LAST NAMES AND FUZZY STREETS */
MKEY4=  compress(last_name_fuzzy1 || new_addr_num || street_fuzzy1 || mk_zip); 
* ADDRESS ONLY MATCH KEYS *;
MKEY5=  compress(new_addr_num || street_exact|| new_addr_unit_number ||mk_zip);
MKEY6=  compress(new_addr_num || new_addr_pre_directional || street_exact|| new_addr_unit_number ||mk_zip);
MKEY7=  compress(new_addr_num || street_fuzzy1 || new_addr_unit_number ||mk_zip);



%mend parsimony;

