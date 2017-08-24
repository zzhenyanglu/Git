* LSCORE MACRO *;
%global modelscore;
%let modelscore= 1 / (1 + (exp(-1 * (-1.924513207
+ (M_GEO_CAC_INT_27 * (3.5410857143 ))
+ (M_SOCIAL_HIGH * (0.4223883173 ))
+ (M_GEO_CAC_INT_58 * (-1.366486396 ))
+ (M_CAC_BUYSTYLE_1 * (0.1577021243 ))
+ (M_CAC_TECH_2 * (-0.281335292 ))
+ (M_GEO_CAC_INT_39 * (-1.435435924 ))
+ (M_CAC_LIFESTAGE_5 * (0.2862517373 ))
+ (M_CAC_SILHOUETTE_H5 * (0.4910283338 ))
+ (M_CAC_SILH_GEO_1 * (0.4786245922 ))
+ (M_CAC_SILH_GEO_8 * (0.5176681515 ))
+ (M_CAC_SILH_GEO_2 * (0.3351933637 ))
+ (M_CAC_SILH_GEO_6 * (0.3217941585 ))
+ (M_ADLT_65_74_1PLUS_ENH * (-0.153707088 ))
+ (M_HOH_AGE_18_24_ENH * (-0.683182929 ))
+ (M_GEO_CAC_INT_69 * (7.7326605819 ))
+ (M_CAC_LIFESTAGE_6 * (0.1850786423 ))
+ (M_ADLT_55_64_1PLUS_ENH * (0.1248519037 ))
+ (M_GEO_CAC_INT_36 * (-1.90452884 ))
+ (M_CAC_SILHOUETTE_C4 * (0.2543140317 ))
+ (M_CAC_INT_ART_HIGH * (-0.014267434 ))
))));

modelscore=&modelscore;

   if modelscore >= 0.3873466 then decile = 1;
   else if modelscore >= 0.3492884 then decile = 2;
   else if modelscore >= 0.3238237 then decile = 3;
   else if modelscore >= 0.3041473 then decile = 4;
   else if modelscore >= 0.287788 then decile = 5;
   else if modelscore >= 0.2736879 then decile = 6;
   else if modelscore >= 0.2614676 then decile = 7;
   else if modelscore >= 0.2505002 then decile = 8;
   else if modelscore >= 0.2404755 then decile = 9;
   else if modelscore >= 0.231342 then decile = 10;
   else decile = 99;


cac_vert_coffee=modelscore;
cac_vert_decile_coffee=decile;


