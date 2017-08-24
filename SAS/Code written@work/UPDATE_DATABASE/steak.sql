* LSCORE MACRO *;
%global modelscore;
%let modelscore= 1 / (1 + (exp(-1 * (-9.10247985
+ (CEN_HHSIZE_2 * (1.2482731488 ))
+ (CEN_HSEVAL_19 * (0.0941125559 ))
+ (M_CAC_BUYSTYLE_3 * (-0.715238592 ))
+ (M_CAC_ECOM_5 * (-0.353048254 ))
+ (M_CAC_LIFESTAGE_5 * (0.2528541277 ))
+ (M_CAC_LIFESTYLE_8 * (-0.19460389 ))
+ (M_CAC_LIFESTYLE_13 * (0.1399278053 ))
+ (M_CAC_SILHOUETTE_G3 * (0.4062186032 ))
+ (M_CAC_SILHOUETTE_I1 * (-0.961385868 ))
+ (M_CAC_SILHOUETTE_L1 * (0.0827877171 ))
+ (M_CAC_SILH_GEO_2 * (0.2714652527 ))
+ (M_FAM_COMP_02_ENH * (0.1402374746 ))
+ (M_FAM_COMP_10_ENH * (1.406256806 ))
+ (M_OCC_MANAGEMENT * (0.2052690447 ))
+ (M_OCC_PROF_TECH * (0.1864632232 ))
+ (T_CEN_FACTOR3 * (0.1158432567 ))
+ (T_CEN_FACTOR4 * (0.1546043002 ))
+ (T_CEN_FACTOR7 * (0.0873543774 ))
+ (T_CEN_FACTOR9 * (0.0906688578 ))
+ (T_M_GEO_CAC_INT_7 * (0.0520461841 ))
+ (T_M_GEO_CAC_INT_118 * (0.0966218295 ))
+ (T_M_INCOME * (0.1390066409 ))
))));



modelscore=&modelscore;

   if modelscore >= 0.1901589 then decile = 1;
   else if modelscore >= 0.1618536 then decile = 2;
   else if modelscore >= 0.1448517 then decile = 3;
   else if modelscore >= 0.132502 then decile = 4;
   else if modelscore >= 0.1226589 then decile = 5;
   else if modelscore >= 0.1144262 then decile = 6;
   else if modelscore >= 0.1072794 then decile = 7;
   else if modelscore >= 0.1009212 then decile = 8;
   else if modelscore >= 0.0951721 then decile = 9;
   else if modelscore >= 0.0898641 then decile = 10;
   else decile = 99;



cac_vert_steak=modelscore;
cac_vert_decile_steak=decile;


