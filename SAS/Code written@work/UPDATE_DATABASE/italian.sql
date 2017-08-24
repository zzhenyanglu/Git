 * LSCORE MACRO *;
%global modelscore;
%let modelscore= 1 / (1 + (exp(-1 * (-2.672838844
+ (M_CAC_ADDR_CDI_C * (0.0696388973 ))
+ (M_CAC_BUYSTYLE_2 * (-0.223458179 ))
+ (M_CAC_DIGINF_5 * (-0.227098519 ))
+ (M_CAC_ECOM_5 * (-0.385373707 ))
+ (M_CAC_INT_BOOKS_HIGH * (0.0776915216 ))
+ (M_CAC_INT_DONATE_HIGH * (-0.297821037 ))
+ (M_CAC_INT_TRAVEL_HIGH * (0.1770565027 ))
+ (M_CAC_LIFESTAGE_3 * (-0.24352008 ))
+ (M_CAC_LIFESTAGE_17 * (-0.091677813 ))
+ (M_CAC_SILHOUETTE_F4 * (0.5658200025 ))
+ (M_CAC_SILHOUETTE_L1 * (0.4710307992 ))
+ (M_CAC_SILHOUETTE_L2 * (0.5065990183 ))
+ (M_CAC_SILH_LOYAL_5 * (0.1155943502 ))
+ (M_CAC_SOCIAL_1 * (0.3885566948 ))
+ (M_CAC_SOCIAL_9 * (0.0862074174 ))
+ (M_CAC_TECH_1 * (0.0247114418 ))
+ (M_FAM_COMP_01_ENH * (0.1969245441 ))
+ (M_GEO_CAC_INT_37 * (1.1208305434 ))
+ (M_GEO_CAC_INT_44 * (1.1981449709 ))
+ (M_GEO_CAC_INT_48 * (0.9827043332 ))
+ (M_HOH_AGE_55_64_ENH * (-0.031828871 ))
+ (M_HOH_AGE_65_74_ENH * (-0.274893637 ))
+ (M_INC_UNDER_40_ENH * (-0.77355611 ))
+ (M_INC_MID_INC_ENH * (0.0300768433 ))
))));


modelscore=&modelscore;

   if modelscore >= 0.1429956 then decile = 1;
   else if modelscore >= 0.1271009 then decile = 2;
   else if modelscore >= 0.1178013 then decile = 3;
   else if modelscore >= 0.1111812 then decile = 4;
   else if modelscore >= 0.1059422 then decile = 5;
   else if modelscore >= 0.1015969 then decile = 6;
   else if modelscore >= 0.0978851 then decile = 7;
   else if modelscore >= 0.0945886 then decile = 8;
   else if modelscore >= 0.091527 then decile = 9;
   else if modelscore >= 0.0885352 then decile = 10;
   else decile = 99;



cac_vert_italian=modelscore;
cac_vert_decile_italian=decile;
