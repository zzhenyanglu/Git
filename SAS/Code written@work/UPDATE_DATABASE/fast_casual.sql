* LSCORE MACRO *;
%global modelscore;
%let modelscore= 1 / (1 + (exp(-1 * (-4.840667392
+ (T_M_INCOME * (0.0806478032 ))
+ (M_SOCIAL_LOW * (-0.319845049 ))
+ (M_CAC_SILH_PRICE_5 * (-0.333501101 ))
+ (T_M_GEO_CAC_INT_6 * (0.0740671361 ))
+ (M_FAM_COMP_16_ENH * (1.0309702898 ))
+ (M_CAC_SOCIAL_1 * (0.4223144967 ))
+ (M_CAC_LIFESTAGE_16 * (-0.861392744 ))
+ (M_HOH_AGE_75PLUS_ENH * (-0.447500688 ))
+ (T_CEN_HSEVAL_5 * (0.0609931817 ))
+ (M_HOH_AGE_35_54_ENH * (0.1569500174 ))
+ (M_OCC_PROF_TECH * (0.1616126136 ))
+ (M_CAC_SILHOUETTE_B2 * (0.2722022164 ))
+ (T_M_GEO_CAC_INT_115 * (0.0415720287 ))
+ (M_KID_00_02_PRES_ENH * (0.1706058827 ))
+ (M_NET_WORTH_500_750_ENH * (0.1322722515 ))
+ (M_EDU_COLLEGE_ENH * (0.1891179026 ))
))));


modelscore=&modelscore;

   if modelscore >= 0.1940846 then decile = 1;
   else if modelscore >= 0.166415 then decile = 2;
   else if modelscore >= 0.1490024 then decile = 3;
   else if modelscore >= 0.1361779 then decile = 4;
   else if modelscore >= 0.1259447 then decile = 5;
   else if modelscore >= 0.1173258 then decile = 6;
   else if modelscore >= 0.1097806 then decile = 7;
   else if modelscore >= 0.1029785 then decile = 8;
   else if modelscore >= 0.0967497 then decile = 9;
   else if modelscore >= 0.0909738 then decile = 10;
   else decile = 99;


cac_vert_fast_casual=modelscore;
cac_vert_decile_fast_casual=decile;


