* LSCORE MACRO *;
%global modelscore;
%let modelscore= 1 / (1 + (exp(-1 * (-2.020156387
+ (M_FAM_COMP_01_ENH * (0.164048495 ))
+ (M_GEO_CAC_INT_46 * (0.6330108111 ))
+ (M_FAM_COMP_12_ENH * (-0.32368366 ))
+ (M_LOR * (-0.010563729 ))
+ (M_CAC_LIFESTAGE_9 * (0.2173967857 ))
+ (M_CAC_SILHOUETTE_J3 * (0.6168915739 ))
+ (M_GEO_CAC_INT_40 * (-1.748192779 ))
+ (M_CAC_TECH_2 * (-0.273108677 ))
+ (M_FAM_COMP_03_ENH * (0.4844080973 ))
+ (M_GEO_CAC_INT_35 * (1.2021342107 ))
+ (M_CAC_SILHOUETTE_A3 * (0.3586843781 ))
+ (M_CAC_INT_FOOD_HIGH * (0.1634308726 ))
+ (M_CAC_LIFESTAGE_17 * (-0.268984819 ))
+ (M_FAM_COMP_02_ENH * (-0.135125014 ))
+ (M_CAC_LIFESTAGE_15 * (0.3667164561 ))
+ (M_CAC_SILHOUETTE_B1 * (0.2922590031 ))
+ (M_CAC_SILHOUETTE_L2 * (-0.358611795 ))
+ (M_CAC_SILHOUETTE_J4 * (-0.604277434 ))
+ (M_CAC_SILH_PRICE_5 * (-0.074830233 ))
+ (M_CAC_SILHOUETTE_G2 * (-0.309629045 ))
+ (M_NET_WORTH_100_150_ENH * (0.1456273559 ))
+ (M_CAC_ECOM_4 * (0.1743705143 ))
+ (M_CAC_SILHOUETTE_H2 * (0.2935568793 ))
+ (M_CAC_SILH_GEO_8 * (-0.149165065 ))
+ (M_INC_UNDER_40_ENH * (-0.427057004 ))
))));


modelscore=&modelscore;

   if modelscore >= 0.2226801 then decile = 1;
   else if modelscore >= 0.1980342 then decile = 2;
   else if modelscore >= 0.1832588 then decile = 3;
   else if modelscore >= 0.1725503 then decile = 4;
   else if modelscore >= 0.1640324 then decile = 5;
   else if modelscore >= 0.1568872 then decile = 6;
   else if modelscore >= 0.1506938 then decile = 7;
   else if modelscore >= 0.145188 then decile = 8;
   else if modelscore >= 0.1402066 then decile = 9;
   else if modelscore >= 0.1356158 then decile = 10;
   else decile = 99;


cac_vert_dessert=modelscore;
cac_vert_decile_dessert=decile;



