* LSCORE MACRO *;
%global modelscore;
%let modelscore= 1 / (1 + (exp(-1 * (-3.720608434
+ (CEN_POPED_6 * (0.8990478162 ))
+ (T_M_GEO_CAC_INT_40 * (0.0099540791 ))
+ (M_CAC_ECOM_5 * (-0.346461791 ))
+ (T_CEN_HSEVAL_5 * (0.0307264365 ))
+ (M_CRED_TRAVEL * (0.344796281 ))
+ (M_EDU_COLLEGE_ENH * (0.3324548174 ))
+ (M_NET_WORTH_OVER_1MM_ENH * (0.3335788603 ))
+ (M_CAC_LIFESTYLE_4 * (0.29176439 ))
+ (T_M_GEO_CAC_INT_27 * (0.0277419691 ))
+ (M_MAIL_BUY_SINGLE * (0.1902859543 ))
+ (M_CAC_ADDR_CDI_D * (-0.423884496 ))
+ (M_SOCIAL_LOW * (-0.248934035 ))
+ (M_CAC_INT_FOOD_HIGH * (0.2413327738 ))
+ (M_CAC_SILHOUETTE_K3 * (-1.277914907 ))
+ (M_CAC_SILH_SUPER_E * (0.0741838733 ))
+ (M_OCC_PROF_TECH * (0.1970078933 ))
+ (M_CAC_SILHOUETTE_H5 * (0.4786389552 ))
+ (M_CAC_SILH_PRICE_5 * (0.1712697762 ))
+ (M_INC_UNDER_30_ENH * (-0.704591026 ))
+ (M_INC_OVER_75_ENH * (0.2651687435 ))
+ (M_ADLT_55_64_1PLUS_ENH * (-0.172670719 ))
))));


modelscore=&modelscore;

   if modelscore >= 0.2424482 then decile = 1;
   else if modelscore >= 0.2043601 then decile = 2;
   else if modelscore >= 0.1809855 then decile = 3;
   else if modelscore >= 0.16431 then decile = 4;
   else if modelscore >= 0.16431 then decile = 5;
   else if modelscore >= 0.1514409 then decile = 6;
   else if modelscore >= 0.1408714 then decile = 7;
   else if modelscore >= 0.1318099 then decile = 8;
   else if modelscore >= 0.1237753 then decile = 9;
   else if modelscore >= 0.1099328 then decile = 10;
   else decile = 99;


cac_vert_fine_dining=modelscore;
cac_vert_decile_fine_dining=decile;



