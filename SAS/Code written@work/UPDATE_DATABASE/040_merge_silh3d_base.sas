***;
* 040_merge_silh3d_base.sas;
* MERGE SILH3D TO BASE DEMO;
***;
options linesize=max;

%let test_obs=max;

%let add_list=
CAC_SILH_BUY_STYLE_GROUP
CAC_SILH_BUY_STYLE_RANK_1
CAC_SILH_BUY_STYLE_RANK_2
CAC_SILH_BUY_STYLE_RANK_3
CAC_SILH_BUY_STYLE_RANK_4
CAC_SILH_BUY_STYLE_RANK_5
CAC_SILH_BUY_STYLE_RANK_6
CAC_SILH_BUY_STYLE_1
CAC_SILH_DIG_INF
CAC_SILH_ECOM
CAC_SILH_GEO
CAC_SILH_LIFESTAGE
CAC_SILH_LIFESTAGE_GROUP
CAC_SILH_LIFESTYLE
CAC_SILH_LOYAL
CAC_SILH_LSTYLE_MACRO
CAC_SILH_PRICE
CAC_SILH_SOCIAL
CAC_SILH_SOCIO_ECON
CAC_SILH_SOCIO_GROUP
CAC_SILH_SUPER
CAC_SILH_TECH
CAC_SILH;

%macro append_silh3d  (qtr=, year=, cacdirect_dir=, test=, cstate=XXXX, codepath=PROD);

   %include "/project/CACDIRECT/CODE/&codepath./METADATA/library.inc"; 

    %if &cacdirect_dir=A %then %do;
        libname base     "/project17/CACDIRECT/&cidatapath./BASE_DEMO/A";
        libname newsilh  "/project17/CACDIRECT/&cidatapath./SILH3D/A";
    %end;
    
    %else %if &cacdirect_dir=B %then %do;
              libname base     "/project17/CACDIRECT/&cidatapath./BASE_DEMO/B";
              libname newsilh  "/project17/CACDIRECT/&cidatapath./SILH3D/B";
    %end;

        proc sort data=newsilh.cac_silh_&cstate out=silh3d_&cstate (keep=cac_hh_pid &add_list);
          by cac_hh_pid;
        run;
    
        %if &test=Y %then %do;
             data base_demo_&cstate (sortedby=cac_hh_pid);
        %end;

        %if &test=N %then %do;
            data base.base_demo_&cstate (sortedby=cac_hh_pid);
        %end;

               merge base.base_demo_&cstate (in=a)
                 silh3d_&cstate (in=b);
                
                 by cac_hh_pid;
                
                 if a;

                  *CAC_SILH_SOC_INF ADDED Q4 2012 TOP 2 DECILES OF EITHER SILH_SOCIAL OR SILH_DIG_INF;
                   CAC_SILH_SOC_INF=(CAC_SILH_SOCIAL in (1,2) or CAC_SILH_DIG_INF in (1,2));

                  label CAC_SILH_SOC_INF="CAC Group Silhouettes 3D: Social Influencer";                   
		  label CAC_SILH = "CAC Group Silhouettes 1.0: Silhouette Dimension";
		  
		  
		  
		  
		  
		  label CAC_SILH = "CAC Group Silhouettes 3D: Silhouette Dimension";
		  label CAC_SILH_BUY_STYLE_GROUP = "CAC Group Silhouettes 3D: Buying Style Group";
		  label CAC_SILH_BUY_STYLE_RANK_1 = "CAC Group Silhouettes 3D: Buying Style Group Rank 1";
		  label CAC_SILH_BUY_STYLE_RANK_2 = "CAC Group Silhouettes 3D: Buying Style Group Rank 2";
		  label CAC_SILH_BUY_STYLE_RANK_3 = "CAC Group Silhouettes 3D: Buying Style Group Rank 3";
		  label CAC_SILH_BUY_STYLE_RANK_4 = "CAC Group Silhouettes 3D: Buying Style Group Rank 4";
		  label CAC_SILH_BUY_STYLE_RANK_5 = "CAC Group Silhouettes 3D: Buying Style Group Rank 5";
		  label CAC_SILH_BUY_STYLE_RANK_6 = "CAC Group Silhouettes 3D: Buying Style Group Rank 6";
		  label CAC_SILH_DIG_INF = "CAC Group Silhouettes 3D: Digital Influencer Dimension";
		  label CAC_SILH_ECOM = "CAC Group Silhouettes 3D: eCommerce Attitudes Dimension";
		  label CAC_SILH_GEO = "CAC Group Silhouettes 3D: Geo Dimension";
		  label CAC_SILH_LIFESTAGE = "CAC Group Silhouettes 3D: Lifestage Dimension";
		  label CAC_SILH_LIFESTAGE_GROUP = "CAC Group Silhouettes 3D: Lifestage Group";
		  label CAC_SILH_LIFESTYLE = "CAC Group Silhouettes 3D: Lifestyle Dimension Individual HH Level";
		  label CAC_SILH_LOYAL = "CAC Group Silhouettes 3D: Loyalty Dimension";
		  label CAC_SILH_LSTYLE_MACRO = "CAC Group Silhouettes 3D: Lifestyle Combined";
		  label CAC_SILH_PRICE = "CAC Group Silhouettes 3D: Price Dimension";
		  label CAC_SILH_SOCIAL = "CAC Group Silhouettes 3D: Social Networking/Media Engagement Dimension";
		  label CAC_SILH_SOCIO_ECON = "CAC Group Silhouettes 3D: Socio Economic Dimension";
		  label CAC_SILH_SOCIO_GROUP = "CAC Group Silhouettes 3D: Social Group Dimension";
		  label CAC_SILH_SUPER = "CAC Group Silhouettes 3D: Super Group";
		  label CAC_SILH_TECH = "CAC Group Silhouettes 3D: Technology Attitudes Dimension";
		  label CAC_SILH_BUY_STYLE_1="CAC Group Silhouettes 3D: Buying Style Group Score 1";
		  label CAC_SILH_BUY_STYLE_1="CAC Group Silhouettes 3D: Buying Style Group Score 1";
		  
               run;
	    
	        title1 "&cstate AFTER UPDATE";
 
                %if &test=Y %then %do;
                    proc freq data=base_demo_&cstate;
                      tables 	CAC_SILH_BUY_STYLE_GROUP
				CAC_SILH_BUY_STYLE_RANK_1
				CAC_SILH_BUY_STYLE_RANK_2
				CAC_SILH_BUY_STYLE_RANK_3
				CAC_SILH_BUY_STYLE_RANK_4
				CAC_SILH_BUY_STYLE_RANK_5
				CAC_SILH_BUY_STYLE_RANK_6
				CAC_SILH_DIG_INF
				CAC_SILH_ECOM
				CAC_SILH_GEO
				CAC_SILH_LIFESTAGE
				CAC_SILH_LIFESTAGE_GROUP
				CAC_SILH_LIFESTYLE
				CAC_SILH_LOYAL
				CAC_SILH_LSTYLE_MACRO
				CAC_SILH_PRICE
				CAC_SILH_SOCIAL
				CAC_SILH_SOCIO_ECON
				CAC_SILH_SOCIO_GROUP
				CAC_SILH_SUPER
				CAC_SILH_TECH
				CAC_SILH
                                CAC_SILH_SOC_INF
                                CAC_DEMO_HH_TYPE_ENH;
                    run;
                    
                   proc means data=base_demo_&cstate;
                     var CAC_SILH_BUY_STYLE_1;
                   run;
                
                   proc contents data=base_demo_&cstate;
                   run;
                %end;
    
                %if &test=N %then %do;
                    proc freq data=base.base_demo_&cstate;
                      tables 	CAC_SILH_BUY_STYLE_GROUP
				CAC_SILH_BUY_STYLE_RANK_1
				CAC_SILH_BUY_STYLE_RANK_2
				CAC_SILH_BUY_STYLE_RANK_3
				CAC_SILH_BUY_STYLE_RANK_4
				CAC_SILH_BUY_STYLE_RANK_5
				CAC_SILH_BUY_STYLE_RANK_6
				CAC_SILH_DIG_INF
				CAC_SILH_ECOM
				CAC_SILH_GEO
				CAC_SILH_LIFESTAGE
				CAC_SILH_LIFESTAGE_GROUP
				CAC_SILH_LIFESTYLE
				CAC_SILH_LOYAL
				CAC_SILH_LSTYLE_MACRO
				CAC_SILH_PRICE
				CAC_SILH_SOCIAL
				CAC_SILH_SOCIO_ECON
				CAC_SILH_SOCIO_GROUP
				CAC_SILH_SUPER
				CAC_SILH_TECH
				CAC_SILH
                                CAC_SILH_SOC_INF
                                CAC_DEMO_HH_TYPE_ENH;
                    run;
                    
                   proc means data=base.base_demo_&cstate;
                     var CAC_SILH_BUY_STYLE_1;
                   run;
                    
                    proc contents data=base.base_demo_&cstate;
                    run;
                %end;

%mend append_silh3d;


