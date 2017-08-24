* LSCORE MACRO *;
%global modelscore;
%let modelscore= 1 / (1 + (exp(-1 * (-2.903547251
+ (M_CAC_BUYSTYLE_4 * (-0.249744116 ))
+ (M_CAC_DIGINF_10 * (-0.704118523 ))
+ (M_CAC_LIFESTAGE_11 * (0.979006243 ))
+ (M_CAC_LIFESTYLE_11 * (0.2807473498 ))
+ (M_CAC_SILHOUETTE_A4 * (0.1838915716 ))
+ (M_CAC_SILHOUETTE_B2 * (-0.044903937 ))
+ (M_CAC_SILHOUETTE_C4 * (-0.864676715 ))
+ (M_CAC_SILHOUETTE_F5 * (-0.204587657 ))
+ (M_CAC_SILHOUETTE_G1 * (0.1339928079 ))
+ (M_CAC_SILHOUETTE_H5 * (0.3271820473 ))
+ (M_CAC_SILH_GEO_6 * (0.2359148044 ))
+ (M_CAC_SILH_PRICE_1 * (0.280603499 ))
+ (M_CAC_SOCIAL_1 * (0.2912709847 ))
+ (M_CAC_SOCIAL_2 * (0.1382579975 ))
+ (M_GEO_CAC_INT_12 * (-0.670737031 ))
+ (M_GEO_CAC_INT_15 * (3.4994865224 ))
+ (M_GEO_CAC_INT_29 * (-3.159960538 ))
+ (M_HOH_AGE_55_64_ENH * (-0.150267569 ))
+ (M_LOR * (-0.012312626 ))
+ (M_SOCIAL_LOW * (-0.682150076 ))
+ (M_INC_UNDER_40_ENH * (-0.441642855 ))
+ (M_INC_MID_INC_ENH * (0.1499879948 ))
+ (M_FAM_NOT_SINGLE * (-0.237549003 ))
))));

modelscore=&modelscore;

   if modelscore >= 0.1199318 then decile = 1;
   else if modelscore >= 0.100304 then decile = 2;
   else if modelscore >= 0.0882842 then decile = 3;
   else if modelscore >= 0.0792966 then decile = 4;
   else if modelscore >= 0.071891 then decile = 5;
   else if modelscore >= 0.0653939 then decile = 6;
   else if modelscore >= 0.059424 then decile = 7;
   else if modelscore >= 0.0537179 then decile = 8;
   else if modelscore >= 0.0480392 then decile = 9;
   else if modelscore >= 0.0421898 then decile = 10;
   else decile = 99;

cac_vert_pizza=modelscore;
cac_vert_decile_pizza=decile;


