%macro parsimony(inlib=, indata=, outlib=, outdata=, keep_clean=1, keep_keys=1, keep_pieces=0, pname_form=, pname1=, pname2=, paddr_form=, paddr1=, paddr2=, pstate=, pzip=);
*==============================================================================================*;
*  Macro:  	Parsimony
   Purpose: 	Standarize and parse name/address elements 
                Create matchkeys for CACdirect matching
   Created:	4/19/2012
   Author:	Patty Seeburger, Lisa Fales, Joel Schiltz
   Sections:	1) COMPILE LISTS/FORMATS
		2) PREP NAME/ADDR
		3) PARSE NAMES    
		4) PARSE ADDRESS 
		5) CREATE KEYS   
*==============================================================================================*;

*-----------------------------------------*;
* 1) COMPILE LISTS/FORMATS
*-----------------------------------------*;
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
              'FL1' 'FL2' 'FL3' 'FLR1' 'FLR2' 'FLR3' 'FL#1' 'FL#2' 'FL#3' 'BASEMENT' 'BSMT' 'APT#' '1FL' '2FL' 'UPSTAIRS' 'REAR1' 'REAR2' '#APT' '#UNIT' '##';
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

data &outlib..&outdata
    (drop= name_up name_c namect psnm addr_length stupid pas1 lenpas name1 name2 name3 name4 name5 new_SUB_name mk_scf paddr pname st_scf
           street_exact street_fuzzy1 new_addr plast_name_exact plast_name_fuzzy1 pfirst_name plast_name mi_name suffix title
           new:
           %if &keep_clean=0 %then %do;
               parse_name: parse_addr_full
           %end;
           %if &keep_pieces=0 %then %do;
               parse_addr_p:
           %end;
           %if &keep_keys=0 %then %do;
               mkey1 mkey2 mkey3 mkey4 mkey5 mkey6 mkey7
           %end;
    );
   set &inlib..&indata;
*-----------------------------------------*;
* 2) PREP NAME/ADDR
*-----------------------------------------*;
   %if &paddr_form=2 %then %do;
      paddr=upcase(compbl(strip(&paddr1)||" "||strip(&paddr2)));
   %end;
   %else %if &paddr_form=1 %then %do;
      paddr=upcase(strip(&paddr1));
   %end;
   * PUTS NAME FIELDS TOGETHER IF THERE ARE TWO NAME FIELDS *;
   %if &pname_form=2 %then %do;
      pname=upcase(compbl(strip(&pname1)||" "||strip(&pname2)));
   %end;
   %else %if &pname_form=1 %then %do;
      pname=upcase(strip(&pname1));
   %end;
   mk_scf=substr(&pzip,1,3);
   st_scf = compress(&pstate||'_'||mk_scf);
*-----------------------------------------*;
* 3) PARSE NAMES   
*-----------------------------------------*;
   length title suffix $10 pfirst_name mi_name plast_name $30 ;
   name_up=upcase(left(strip(compbl((pname)))));
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
      pfirst_name=' ';
      mi_name=' ';
      plast_name=name1;
      suffix=' ';
   end;
   if namect =2 then do;
      title=' ';
      pfirst_name=name1;
      mi_name=' ';
      plast_name=name2;
      suffix=' ';
   end;
   if namect=3 then do;
      if name1 in(&prefix) and name2 not in(&pre_sur)  then do; 
         title=name1;
         pfirst_name=name2;
         mi_name=' ';
         plast_name=name3;
         suffix=' ';
      end;
      if name1 in(&prefix) and name2 in(&pre_sur)  then do; 
         title=name1;
         pfirst_name=' ';
         mi_name=' ';
         plast_name=strip(name2)||' '||strip(name3);
         suffix=' ';
      end;
      if name1 not in(&prefix) and (name2 not in(&pre_sur) or name3 not in(&suff_char)) then do; 
         title=' ';
         pfirst_name=name1;
         mi_name=name2;
         plast_name=name3;
         suffix=' ';
      end;
      if name1 not in(&prefix) and name2 in(&pre_sur) then do; 
         title=' ';
         pfirst_name=name1;
         mi_name=' ';
         plast_name=strip(name2)||' '||strip(name3);
         suffix=' ';
      end;
      if name1 not in(&prefix) and name3 in(&suff_char) then do; 
         title=' ';
         pfirst_name=name1;
         mi_name=' ';
         plast_name=name2;
         suffix=name3;
      end;
      if name1 not in(&prefix) and length(name1)=1 and length(name2)=1 then do; 
         title=' ';
         pfirst_name=strip(name1)||' '||strip(name2);
         mi_name=' ';
         plast_name=name3;
         suffix=' ';
      end;
   end;
   if namect=4 then do;
      if name1 in(&prefix) and name4 not in(&suff_char) then do; 
         title=name1;
         pfirst_name=name2;
         mi_name=name3;
         plast_name=name4;
         suffix=' ';
      end;   
      if name1 in(&prefix) and name4 in(&suff_char) then do; 
         title=name1;
         pfirst_name=name2;
         mi_name=' ';
         plast_name=name3;
         suffix=name4;
      end;    
      if name1 in(&prefix) and name3 in(&pre_sur) then do; 
         title=name1;
         pfirst_name=name2;
         mi_name=' ';
         plast_name=strip(name3)||' '||strip(name4);
         suffix=' ';
      end;    
      if name1 in(&prefix) and name2 in('&','AND') then do; 
         title=' ';
         pfirst_name=strip(name1)||' '||strip(name2)||' '||strip(name3);
         mi_name=' ';
         plast_name=(name4);
         suffix=' ';
      end;  
      if name1 in(&prefix) and length(name2) =1 and length(name3)=1 then do; 
         title=name1;
         pfirst_name=strip(name1)||' '||strip(name2);
         mi_name=' ';
         plast_name=(name4);
         suffix=' ';
      end;  
      if name1 not in(&prefix) and name4 not in(&suff_char) then do; 
         title=' ';
         pfirst_name=name1;
         mi_name=strip(name2)||' '||strip(name3);
         plast_name=name4;
         suffix=' ';
      end;      
      if name1 not in(&prefix) and name4 in(&suff_char) then do; 
         title=' ';
         pfirst_name=name1;
         mi_name=name2;
         plast_name=name3;
         suffix=name4;
      end;    
      if name1 not in(&prefix) and name3 in(&pre_sur) then do; 
         title=' ';
         pfirst_name=name1;
         mi_name=name2;
         plast_name=strip(name3)||' '||strip(name4);
         suffix=' ';
      end; 
      if name1 not in(&prefix) and name3 not in(&pre_sur) and name4 not in(&suff_char) then do; 
         title=' ';
         pfirst_name=name1;
         mi_name=name2;
         plast_name=strip(name3)||' '||strip(name4);
         suffix=' ';
      end; 
      if name1 not in(&prefix) and name2 in('&','AND') then do; 
         title=' ';
         pfirst_name=strip(name1)||' '||strip(name2)||' '||strip(name3);
         mi_name=' ';
         plast_name=(name4);
         suffix=' ';
      end;
      if name1 not in(&prefix) and length(name2) =1 and length(name3)=1 and name4 in(&suff_char) then do; 
         title=' ';
         pfirst_name=strip(name1)||' '||strip(name2);
         mi_name=' ';
         plast_name=(name3);
         suffix=name4;
     end; 
     if name1 not in(&prefix) and length(name2) =1 and length(name3)=1 and name3 in(&pre_sur) then do; 
         title=' ';
         pfirst_name=strip(name1)||' '||strip(name2);
         mi_name=' ';
         plast_name=strip(name3)||' '||strip(name4);
         suffix=' ';
     end;  
     if name1 not in(&prefix) and length(name2) =1 and length(name3)=1 and name3 not in(&pre_sur) then do; 
         title=' ';
         pfirst_name=strip(name1)||' '||strip(name2);
         mi_name=name3;
         plast_name=name4;
         suffix=' ';
     end;                    
   end;
   if namect= 5 then do;
      if name1 in(&prefix) and name5 in(&suff_char) then do;
          title=name1;
          pfirst_name=name2;
          mi_name=name3;
          plast_name=name4;
          suffix=name5;
      end;
      if name1 in(&prefix) and name5 not in(&suff_char) then do;
          title=name1;
          pfirst_name=name2;
          mi_name=name3;
          plast_name=strip(name4)||' '||strip(name5);
          suffix=' ';  
      end;
      if name1 in(&prefix) and name4 in(&pre_sur) then do;
          title=name1;
          pfirst_name=name2;
          mi_name=name3;
          plast_name=strip(name4)||' '||strip(name5);
          suffix=' ';  
      end;
      if name1 in(&prefix) and  name3 in('&','AND') then do;
          title=name1;
          pfirst_name=strip(name2)||' '||strip(name3)||' '||strip(name4);
          mi_name=' ';
          plast_name=name5;
          suffix=' ';
      end;
      if name1 in(&prefix) and name5 not in(&suff_char) and length(name2)=1 and length(name3)=1 then do;
          title=name1;
          pfirst_name=strip(name2)||' '||strip(name3);
          mi_name=' ';
          plast_name=strip(name4)||' '||strip(name5);
          suffix=' ';
      end;
      if name1 in(&prefix) and name5 in(&suff_char) and length(name2)=1 and length(name3)=1 then do;
          title=name1;
          pfirst_name=strip(name2)||' '||strip(name3);
          mi_name=' ';
          plast_name=name4;
          suffix=name5;
      end;
      if name1 in(&prefix) and name4 in(&pre_sur) and length(name2)=1 and length(name3)=1 then do;
          title=name1;
          pfirst_name=strip(name2)||' '||strip(name3);
          mi_name=' ';
          plast_name=strip(name4)||' '||strip(name5);
          suffix=' ';
      end;
      if name1 not in(&prefix) and name4 not in(&pre_sur) and name5 in(&suff_char) then do; 
          title=' ';
          pfirst_name=name1;
          mi_name=strip(name2)||' '||strip(name3);
          plast_name=name4;
          suffix=name5;
      end; 
      if name1 not in(&prefix) and name4 not in(&pre_sur) and name5 not in(&suff_char) and length(name4) ne 1 then do; 
          title=' ';
          pfirst_name=name1;
          mi_name=strip(name2)||' '||strip(name3);
          plast_name=strip(name4)||' '||strip(name5);
          suffix=' ';
      end; 
      if name1 not in(&prefix) and name4 not in(&pre_sur) and name5 not in(&suff_char) and length(name4) = 1 then do; 
          title=' ';
          pfirst_name=name1;
          mi_name=strip(name2)||' '||strip(name3)||' '||strip(name4);
          plast_name=name5;
          suffix=' ';
     end; 
     if name1 not in(&prefix) and name4 in(&pre_sur) then do; 
          title=' ';
          pfirst_name=name1;
          mi_name=strip(name2)||' '||strip(name3);
          plast_name=strip(name4)||' '||strip(name5);
          suffix=' ';
      end; 
      if name1 not in(&prefix) and name5 in(&suff_char) and name3 in(&pre_sur) then do; 
          title=' ';
          pfirst_name=name1;
          mi_name=name2;
          plast_name=strip(name3)||' '||strip(name4);
          suffix=name5;
      end;
      if name1 not in(&prefix) and name2 in('&','AND') and name5 in(&suff_char) then do;
          pfirst_name=strip(name1)||' '||strip(name2)||' '||strip(name3);
          mi_name=' ';
          plast_name=name4;
          suffix=name5;
      end;
      if name1 not in(&prefix) and name2 in('&','AND') and name4 in(&pre_sur) then do;
          pfirst_name=strip(name1)||' '||strip(name2)||' '||strip(name3);
          mi_name=' ';
          plast_name=strip(name4)||' '||strip(name5);
          suffix=' ';
      end;
      if name1 not in(&prefix) and name5 in(&suff_char) and length(name1)=1 and length(name2)=1 then do;
          title=' '; 
          pfirst_name=strip(name1)||' '||strip(name2);
          mi_name=name3;
          plast_name=name4;
          suffix=name5;
      end;
      if name1 not in(&prefix) and name5 in(&suff_char) and length(name1)=1 and length(name2)=1 and name3 in (&pre_sur) then do;
          title=' '; 
          pfirst_name=strip(name1)||' '||strip(name2);
          mi_name=' ';
          plast_name=strip(name3)||' '||strip(name4);
          suffix=name5;
      end;
   end;
*-----------------------------------------*;
* 3) PARSE ADDRESS   
*-----------------------------------------*;
   * GET RID OF SPECIAL CHARACTERS EXCEPT FOR FRACTIONS LIKE 1/2 *;
   new_addr=compress(upcase(strip(paddr)),".'*@^~,!$%()&-+=");
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
               if ((scan(new_addr,-1,' ') in (&units) or strip(substr(strip(scan(new_addr,-1,' ')||stupid),1,4)) in ('UNIT' 'TRLR') or 
                              strip(substr(strip(scan(new_addr,-1,' ')||stupid),1,3))='APT')) and scan(new_addr,-1,' ') ne new_addr_unit_number then do;
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
   new_SUB_name=length(plast_name);
   if new_SUB_name < 7 then do until (length(plast_name) = 7);
          plast_name=trim(plast_name)||'!';
   end;
   plast_name_exact=compress(plast_name,'!');
   plast_name_fuzzy1=soundex(compress(plast_name,'!'));
*---------------------------------------*;
* 4) CREATE KEYS
*---------------------------------------*;
   lengtH mkey1 $1329 mkey2 $529 mkey3 $329 mkey4 $329 mkey5 $499 mkey6 $699 mkey7 $499;
   /* BOTH ARE EXACT */
   mkey1=  compress(plast_name_exact || new_addr_pre_directional || new_addr_num || new_addr_fraction || street_exact || new_addr_street_suffix || new_addr_street_post_direction || new_addr_unit_number || &pzip); 
   /* BOTH ARE EXACT */
   mkey2=  compress(plast_name_exact || new_addr_num || street_exact|| new_addr_unit_number || &pzip);
   /* BOTH ARE EXACT */
   mkey3=  compress(plast_name_exact || new_addr_num || street_exact || &pzip); 
   /* FUZZY LAST NAMES AND FUZZY STREETS */
   mkey4=  compress(plast_name_fuzzy1 || new_addr_num || street_fuzzy1 || &pzip); 
   * ADDRESS ONLY MATCH KEYS *;
   mkey5=  compress(new_addr_num || street_exact|| new_addr_unit_number ||&pzip);
   mkey6=  compress(new_addr_num || new_addr_pre_directional || street_exact|| new_addr_unit_number ||&pzip);
   mkey7=  compress(new_addr_num || street_fuzzy1 || new_addr_unit_number ||&pzip);
*---------------------------------------*;
* 5) RENAME NAME/ADDRESS
*---------------------------------------*;
   format parse_name_first parse_name_last parse_name_middle $25. parse_name_title parse_name_suffix $10. parse_addr_full $100.
          parse_addr_p1_num parse_addr_p2_fraction parse_addr_p3_pre_dir parse_addr_p5_suff parse_addr_p6_post_dir parse_addr_p7_unit_type
          parse_addr_p8_unit_num $10. parse_addr_p4_street $25.;
   parse_addr_full=compbl(strip(new_addr_num)||" "||strip(new_addr_fraction)||" "||strip(new_addr_pre_directional)||" "||strip(new_addr_street)||" "||
                          strip(new_addr_street_suffix)||" "||strip(new_addr_street_post_direction)||" "||strip(new_addr_unit_type)||" "||strip(new_addr_unit_number));
   parse_addr_p1_num=new_addr_num;
   parse_addr_p2_fraction=new_addr_fraction;
   parse_addr_p3_pre_dir=new_addr_pre_directional;
   parse_addr_p4_street=new_addr_street ;
   parse_addr_p5_suff=new_addr_street_suffix;
   parse_addr_p6_post_dir=new_addr_street_post_direction;
   parse_addr_p7_unit_type=new_addr_unit_type;
   parse_addr_p8_unit_num=new_addr_unit_number;
   parse_name_first=pfirst_name;
   parse_name_last=plast_name_exact;
   parse_name_middle=mi_name;
   parse_name_suffix=suffix;
   parse_name_title=title;
run;

%mend parsimony;

