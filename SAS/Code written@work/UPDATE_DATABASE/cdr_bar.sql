* LSCORE MACRO *;
%global modelscore;
%let modelscore= 1 / (1 + (exp(-1 * (-6.177691111
+ (T_M_INCOME * (0.0960915229 ))
+ (T_M_GEO_CAC_INT_37 * (0.0566636529 ))
+ (M_CAC_ECOM_5 * (-0.293584122 ))
+ (T_M_GEO_CAC_INT_101 * (0.0579029787 ))
+ (T_M_GEO_CAC_INT_17 * (0.029243878 ))
+ (T_CEN_POPRACE_16 * (0.0548208124 ))
+ (T_M_GEO_CAC_INT_27 * (-0.038152557 ))
+ (T_CEN_POPLABR_22 * (0.03366851 ))
+ (M_FAM_COMP_01_ENH * (0.1818800578 ))
+ (M_HOME_OWNER * (-0.110475958 ))
+ (M_GEO_CAC_INT_42 * (-0.81593472 ))
+ (M_CAC_DIGINF_1 * (0.2867059225 ))
+ (M_NUM_PERS_6PLUS_ENH * (-0.135317631 ))
+ (T_M_GEO_CAC_INT_21 * (0.0297784035 ))
+ (CEN_POPED_4 * (0.7604292791 ))
+ (M_CAC_ECOM_4 * (0.1017389266 ))
+ (M_INC_OVER_100_ENH * (-0.127195332 ))
+ (M_HOH_AGE_25_44_ENH * (0.2803483692 ))
))));


modelscore=&modelscore;
   if modelscore >= 0.2246711 then decile = 1;
   else if modelscore >= 0.1998613 then decile = 2;
   else if modelscore >= 0.1831865 then decile = 3;
   else if modelscore >= 0.1698743 then decile = 4;
   else if modelscore >= 0.1584018 then decile = 5;
   else if modelscore >= 0.1479093 then decile = 6;
   else if modelscore >= 0.1380691 then decile = 7;
   else if modelscore >= 0.1286808 then decile = 8;
   else if modelscore >= 0.1196172 then decile = 9;
   else if modelscore >= 0.1108446 then decile = 10;
   else decile = 99;


cac_vert_cdr_bar=modelscore;
cac_vert_decile_cdr_bar=decile;

