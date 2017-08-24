#!/bin/csh
#master_controller.sh

#copy MASTER SAS file to all states (State will equal YYYY in master)


sed 's/YYYY/AK/' ./110_build_hh_data.sas > ./110_build_hh_data_AK.sas ;
sed 's/YYYY/AL/' ./110_build_hh_data.sas > ./110_build_hh_data_AL.sas ;
sed 's/YYYY/AR/' ./110_build_hh_data.sas > ./110_build_hh_data_AR.sas ;
sed 's/YYYY/AZ/' ./110_build_hh_data.sas > ./110_build_hh_data_AZ.sas ;
sed 's/YYYY/CA/' ./110_build_hh_data.sas > ./110_build_hh_data_CA.sas ;
sed 's/YYYY/CO/' ./110_build_hh_data.sas > ./110_build_hh_data_CO.sas ;
sed 's/YYYY/CT/' ./110_build_hh_data.sas > ./110_build_hh_data_CT.sas ;
sed 's/YYYY/DC/' ./110_build_hh_data.sas > ./110_build_hh_data_DC.sas ;
sed 's/YYYY/DE/' ./110_build_hh_data.sas > ./110_build_hh_data_DE.sas ;
sed 's/YYYY/FL/' ./110_build_hh_data.sas > ./110_build_hh_data_FL.sas ;
sed 's/YYYY/GA/' ./110_build_hh_data.sas > ./110_build_hh_data_GA.sas ;
sed 's/YYYY/HI/' ./110_build_hh_data.sas > ./110_build_hh_data_HI.sas ;
sed 's/YYYY/IA/' ./110_build_hh_data.sas > ./110_build_hh_data_IA.sas ;
sed 's/YYYY/ID/' ./110_build_hh_data.sas > ./110_build_hh_data_ID.sas ;
sed 's/YYYY/IL/' ./110_build_hh_data.sas > ./110_build_hh_data_IL.sas ;
sed 's/YYYY/IN/' ./110_build_hh_data.sas > ./110_build_hh_data_IN.sas ;
sed 's/YYYY/KS/' ./110_build_hh_data.sas > ./110_build_hh_data_KS.sas ;
sed 's/YYYY/KY/' ./110_build_hh_data.sas > ./110_build_hh_data_KY.sas ;
sed 's/YYYY/LA/' ./110_build_hh_data.sas > ./110_build_hh_data_LA.sas ;
sed 's/YYYY/MA/' ./110_build_hh_data.sas > ./110_build_hh_data_MA.sas ;
sed 's/YYYY/MD/' ./110_build_hh_data.sas > ./110_build_hh_data_MD.sas ;
sed 's/YYYY/ME/' ./110_build_hh_data.sas > ./110_build_hh_data_ME.sas ;
sed 's/YYYY/MI/' ./110_build_hh_data.sas > ./110_build_hh_data_MI.sas ;
sed 's/YYYY/MN/' ./110_build_hh_data.sas > ./110_build_hh_data_MN.sas ;
sed 's/YYYY/MO/' ./110_build_hh_data.sas > ./110_build_hh_data_MO.sas ;
sed 's/YYYY/MS/' ./110_build_hh_data.sas > ./110_build_hh_data_MS.sas ;
sed 's/YYYY/MT/' ./110_build_hh_data.sas > ./110_build_hh_data_MT.sas ;
sed 's/YYYY/NC/' ./110_build_hh_data.sas > ./110_build_hh_data_NC.sas ;
sed 's/YYYY/ND/' ./110_build_hh_data.sas > ./110_build_hh_data_ND.sas ;
sed 's/YYYY/NE/' ./110_build_hh_data.sas > ./110_build_hh_data_NE.sas ;
sed 's/YYYY/NH/' ./110_build_hh_data.sas > ./110_build_hh_data_NH.sas ;
sed 's/YYYY/NJ/' ./110_build_hh_data.sas > ./110_build_hh_data_NJ.sas ;
sed 's/YYYY/NM/' ./110_build_hh_data.sas > ./110_build_hh_data_NM.sas ;
sed 's/YYYY/NV/' ./110_build_hh_data.sas > ./110_build_hh_data_NV.sas ;
sed 's/YYYY/NY/' ./110_build_hh_data.sas > ./110_build_hh_data_NY.sas ;
sed 's/YYYY/OH/' ./110_build_hh_data.sas > ./110_build_hh_data_OH.sas ;
sed 's/YYYY/OK/' ./110_build_hh_data.sas > ./110_build_hh_data_OK.sas ;
sed 's/YYYY/OR/' ./110_build_hh_data.sas > ./110_build_hh_data_OR.sas ;
sed 's/YYYY/PA/' ./110_build_hh_data.sas > ./110_build_hh_data_PA.sas ;
sed 's/YYYY/RI/' ./110_build_hh_data.sas > ./110_build_hh_data_RI.sas ;
sed 's/YYYY/SC/' ./110_build_hh_data.sas > ./110_build_hh_data_SC.sas ;
sed 's/YYYY/SD/' ./110_build_hh_data.sas > ./110_build_hh_data_SD.sas ;
sed 's/YYYY/TN/' ./110_build_hh_data.sas > ./110_build_hh_data_TN.sas ;
sed 's/YYYY/TX/' ./110_build_hh_data.sas > ./110_build_hh_data_TX.sas ;
sed 's/YYYY/UT/' ./110_build_hh_data.sas > ./110_build_hh_data_UT.sas ;
sed 's/YYYY/VA/' ./110_build_hh_data.sas > ./110_build_hh_data_VA.sas ;
sed 's/YYYY/VT/' ./110_build_hh_data.sas > ./110_build_hh_data_VT.sas ;
sed 's/YYYY/WA/' ./110_build_hh_data.sas > ./110_build_hh_data_WA.sas ;
sed 's/YYYY/WI/' ./110_build_hh_data.sas > ./110_build_hh_data_WI.sas ;
sed 's/YYYY/WV/' ./110_build_hh_data.sas > ./110_build_hh_data_WV.sas ;
sed 's/YYYY/WY/' ./110_build_hh_data.sas > ./110_build_hh_data_WY.sas ;

chmod 777  ./110_build_hh_data*sas ;

#launch four jobs that break up largest states

nohup sh 110_launch_hh_data_1.sh &
nohup sh 110_launch_hh_data_2.sh &
nohup sh 110_launch_hh_data_3.sh &
nohup sh 110_launch_hh_data_4.sh

unix2dos /project/AHI/SCORING/DATA/CACDIRECT/rt_base_demo_mkey_??.csv
 
