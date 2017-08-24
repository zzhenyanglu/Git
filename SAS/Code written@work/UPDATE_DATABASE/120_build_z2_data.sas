*********************************************************************************;
***Program: 120_build_z2_data.sas                                             ***;
***Purpose: create z2 scoring dataset for AHI data                            ***;
***Author:  jschiltz mmattingly                                               ***;
***MacroVars: quart - YYYY_Q# of scoring - set at the beginning of a quarter  ***;
***           stst  - number of the first state to process                    ***;
***                 - ordering of states based on list at bottom of code      ***;
***           endst - number of the last  state to process                    ***;
***                 - ordering of states based on list at bottom of code      ***;
*********************************************************************************;

libname ahicacd '/project/AHI/SCORING/DATA/CACDIRECT';

options nomprint nomlogic;
options ps=3000;
%global stst endst;
options compress=yes;

%macro breeze (cacdir_loc=,stst=1, endst=51, codepath=PROD);

    %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc"; 

    %if &cacdir_loc=A %then %do;
        libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/A";
        libname geo      "/project/CACDIRECT/&cidatapath./GEO/A";  
    %end;
    
    %else %if &cacdir_loc=B %then %do;                                       
              libname base     "/project/CACDIRECT/&cidatapath./BASE_DEMO/B";            
              libname geo      "/project/CACDIRECT/&cidatapath./GEO/B";
    %end;
    
        %let sts = AK AL AR AZ CA CO CT DC DE FL 
                   GA HI IA ID IL IN KS KY LA MA
                   MD ME MI MN MO MS MT NC ND NE 
                   NH NJ NM NV NY OH OK OR PA RI
                   SC SD TN TX UT VA VT WA WI WV
               WY;
               
   %do current_state = &stst %to &endst;

       %let st=%scan(&sts, &current_state);

	%put ***~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~***;
	%put ***~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~***;
	%put ***~~~~~~~~~~          START PROCESSING STATE = &st                  ~~~~~~~~~~~***;
	%put ***~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~***;
	%put ***~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~***;

	title " ***~~~~~~~~~~                PROCESSING STATE = &st              ~~~~~~~~~~~***";
	
	%let geo_list=CAC_ADDR_STATE CAC_ADDR_ZIP CAC_ADDR_ZIP2 GEO_CAC_INT_27 GEO_CAC_INT_118 GEO_CAC_INT_45;	
	%let census_list=CAC_CENSUS_ID CEN_HSECOST_5 CEN_FAMINC_68 CEN_HSETENR_22 CEN_HSETENR_23 CEN_POPED_7 CEN_POPOCC_17 CEN_POPRACE_90 ;
	
	data z2_&st;
	  set geo.geo_interest_&st (keep=&geo_list where=(substr(cac_addr_zip2,6,2) ne 'XX'));
	run;
	
	proc sort data=z2_&st;
	  by cac_addr_zip;
	run;
	
        data cen_xref_&st;
          set cen2010.cac_census_xref_&st (where=(cac_addr_zip4 eq ''));
        run;

        proc sort data=cen_xref_&st;
          by cac_addr_zip;
        run;
	
	data z2_&st;
	   merge z2_&st (in=a)
	         cen_xref_&st (in=b keep=cac_census_id cac_addr_zip);        
	       by cac_addr_zip;
	       cac_census_match=0;
	       if a and b then do;
	          cac_census_match=1;
	          cac_census_match_level='ZIP5';
	       end;
               if a then output;
        run;

        proc freq data=z2_&st;
          tables cac_census_match / missing;
        run;

        proc print data=z2_&st;
         where cac_census_match=0;
         var cac_addr_zip cac_addr_zip2;
        run;

        title1 "CENSUS MATCH &ST";
        proc sort data=z2_&st;
          by cac_census_id; 
        run;

        data z2_&st;
          merge z2_&st (in=a)
                cen2010.cac_census_final_&st (in=b keep=&census_list);
	          
          by cac_census_id;

		/***SCORE MODEL: RECODES***/
   		M_GEO_CAC_INT_27=GEO_CAC_INT_27;
      		M_GEO_CAC_INT_118=GEO_CAC_INT_118;
    		M_GEO_CAC_INT_45=GEO_CAC_INT_45;
 
                
		/***SCORE MODEL: OUTLIERS: NO OUTIERS CODE GENERATED THIS TIME GD***/
         

                /***SCORE MODEL: MISSFILLS***/
               if missing(CEN_HSECOST_5) then CEN_HSECOST_5 = 0.0660067833 ;
               if missing(CEN_FAMINC_68) then CEN_FAMINC_68 = 0.0432108559  ; 
               if missing(CEN_HSETENR_22) then CEN_HSETENR_22 = 0.030599919 ;
               if missing(CEN_HSETENR_23) then CEN_HSETENR_23 = 0.0139558524 ;
               if missing(CEN_POPED_7) then CEN_POPED_7 = 0.2207940436 ;
               if missing(CEN_POPOCC_17) then CEN_POPOCC_17 = 0.1119432276 ;
               if missing(CEN_POPRACE_90) then CEN_POPRACE_90 = 0.1919381165 ;
  		
		/***SCORE MODEL: TRANSFORMATIONS***/
		
	
		***  RECODE FOR VARIABLE T_M_GEO_CAC_INT_27 ***;
                 
		T_M_GEO_CAC_INT_27 =100*(   0.019588043542661+(M_GEO_CAC_INT_27*(  -0.175813347762333))+((M_GEO_CAC_INT_27**2)*(   2.268245130251350))+
				   ((M_GEO_CAC_INT_27**3)*(  -6.890682125543570))+((M_GEO_CAC_INT_27**4)*(   6.754223813116200)));
				    label t_M_GEO_CAC_INT_27 ='Z2: Cultural/Arts Events - transformed';
		
                
                ***  RECODE FOR VARIABLE T_CEN_FAMINC_68 ***;
   		
		T_CEN_FAMINC_68 =100*(   0.025295067941204+(CEN_FAMINC_68*(   0.040721136375489))+((CEN_FAMINC_68**2)*(  -0.192585681830397))+
				((CEN_FAMINC_68**3)*(   0.514754163604569))+((CEN_FAMINC_68**4)*(  -0.361353530665879)));
			        label t_CEN_FAMINC_68 ='FAMILIES INCOME: % SINGLE WITHOUT CHILDREN <18 FAMILIES INCOME > $200,000 - transformed';
		
                
                ***  RECODE FOR VARIABLE T_CEN_HSETENR_22  ***;
   		
		T_CEN_HSETENR_22 =100*(   0.026510586111006+(CEN_HSETENR_22*(  -0.066401261191710))+((CEN_HSETENR_22**2)*(   0.626798996194241))+
				  ((CEN_HSETENR_22**3)*(  -1.436627664763220))+((CEN_HSETENR_22**4)*(   0.873124206672812)));
				  label t_CEN_HSETENR_22 ='HOUSING UNITS TENURE RENT. OCCUPIED: % RENTER OCCUPIED HOUSEHOLDER MOVED INTO UNIT 1980-1989 - transformed';
	
                
                ***  RECODE FOR VARIABLE T_CEN_HSETENR_23 ***;
      		
		T_CEN_HSETENR_23 =100*(   0.026671647761918+(CEN_HSETENR_23*(  -0.025938641248820))+((CEN_HSETENR_23**2)*(  -0.238832932435679))+
				  ((CEN_HSETENR_23**3)*(   0.822668279270640))+((CEN_HSETENR_23**4)*(  -0.564393310446602)));
				  label t_CEN_HSETENR_23 ='HOUSING UNITS TENURE RENT. OCCUPIED: % RENTER OCCUPIED HOUSEHOLDER MOVED INTO UNIT 1970-1979 - transformed';
		
                ***  RECODE FOR VARIABLE T_CEN_POPED_7***;

                T_CEN_POPED_7 =100*(   0.016546269008309+(CEN_POPED_7*(   0.021438015772559))+((CEN_POPED_7**2)*(   0.232588351192164))+
                               ((CEN_POPED_7**3)*(  -0.552134129061539))+((CEN_POPED_7**4)*(   0.295465362733796)));
                               label t_CEN_POPED_7 ='POPULATION EDUCATION: % ADULTS 25+ WITH GRADUATE DEGREE - transformed';

                
                ***  RECODE FOR VARIABLE T_CEN_POPOCC_17 ***;
    		
		T_CEN_POPOCC_17 =100*(   0.029123269863283+(CEN_POPOCC_17*(  -0.075944865335002))+((CEN_POPOCC_17**2)*(   0.415670223751023))+
				((CEN_POPOCC_17**3)*(  -0.546308745299452))+((CEN_POPOCC_17**4)*(   0.212025268451096)));
				label t_CEN_POPOCC_17 ='POPULATION OCCUPATION: % EMPLOYED IN EDUCATIONAL SERVICES - transformed';
		
                
                ***  RECODE FOR VARIABLE T_CEN_POPRACE_90 ***;
	        T_CEN_POPRACE_90 =100*(   0.015629795357691+(CEN_POPRACE_90*(   0.085359348349304))+((CEN_POPRACE_90**2)*(  -0.169272789044356))+
				  ((CEN_POPRACE_90**3)*(   0.229083965316897))+((CEN_POPRACE_90**4)*(  -0.165309856334871)));
				  label t_CEN_POPRACE_90 ='POPULATION RACE AGE: % WHITE POPULATION 65+ YEARS OLD - transformed';
                
                ***  RECODE FOR VARIABLE T_M_GEO_CAC_INT_118 ***;
                
		T_M_GEO_CAC_INT_118 =100*(   0.023611111844218+(M_GEO_CAC_INT_118*(   0.180431992944975))+((M_GEO_CAC_INT_118**2)*(  -1.473138131960770))+
				     ((M_GEO_CAC_INT_118**3)*(   3.607543429326770))+((M_GEO_CAC_INT_118**4)*(  -2.823525135378450)));
				     label t_M_GEO_CAC_INT_118 ='Z2: Cruise Ship Vacation - transformed';


	        /***SCORE MODEL: EQUATION***/
       		modelscore= 1 / (1 + (exp(-1 * (-12.27995923
 		+ (T_M_GEO_CAC_INT_27 * (0.2086744859 ))
		+ (CEN_HSECOST_5 * (0.2082274012 ))
		+ (T_CEN_FAMINC_68 * (0.151426436 ))
		+ (T_CEN_HSETENR_22 * (0.3809911613 ))
		+ (T_CEN_HSETENR_23 * (0.4660111353 ))
		+ (T_CEN_POPED_7 * (0.2318021097 ))
		+ (T_CEN_POPOCC_17 * (0.2147656387 ))
		+ (T_CEN_POPRACE_90 * (0.288924153 ))
		+ (T_M_GEO_CAC_INT_118 * (0.3983347639 ))
		+ (M_GEO_CAC_INT_45 * (0.9013366252 ))
		))));

	/***END SCORE MODEL ****/

	       if a then output;
        run;

	options errors=1 nolabel;
		
	title1 "z2_&st Means &st";
	proc means data=z2_&st;
	run;

	proc append base=z2_final data=z2_&st force; run;
	
	
   %end;      *** CURRENT STATE LOOP;
   
   data ahicacd.z2_final;
        set z2_final (keep=cac_addr_zip2 modelscore);
   run;

   proc means data=ahicacd.z2_final n nmiss mean min max std;
      var modelscore;
   run;
   
   proc sort data=ahicacd.z2_final out=z2_final;
     by cac_addr_zip2;
   run;
   
   data _null_;
     file '/project/AHI/SCORING/DATA/CACDIRECT/z2_modelscore.csv' lrecl=5000 dsd;
     set z2_final;
     if _N_=1 then put "ZIP_PLUS_2,MODEL_SCORE";
     put cac_addr_zip2 modelscore;
   run;
   
   x "unix2dos -o /project/AHI/SCORING/DATA/CACDIRECT/z2_modelscore.csv /project/AHI/SCORING/DATA/CACDIRECT/z2_modelscore.csv";
   x "/project/CACDIRECT/CODE/&codepath./UPDATE_DATABASE/upload_z2.sh";
   
%mend breeze;

