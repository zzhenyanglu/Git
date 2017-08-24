#!/bin/csh
#master_controller.sh

#copy MASTER SAS file to all states (State will equal XXXX in master)


sed 's/XXXX/AK/' ./100_buyer_connect.sas > ./100_buyer_connect_AK.sas ;
sed 's/XXXX/AL/' ./100_buyer_connect.sas > ./100_buyer_connect_AL.sas ;
sed 's/XXXX/AR/' ./100_buyer_connect.sas > ./100_buyer_connect_AR.sas ;
sed 's/XXXX/AZ/' ./100_buyer_connect.sas > ./100_buyer_connect_AZ.sas ;
sed 's/XXXX/CA/' ./100_buyer_connect.sas > ./100_buyer_connect_CA.sas ;
sed 's/XXXX/CO/' ./100_buyer_connect.sas > ./100_buyer_connect_CO.sas ;
sed 's/XXXX/CT/' ./100_buyer_connect.sas > ./100_buyer_connect_CT.sas ;
sed 's/XXXX/DC/' ./100_buyer_connect.sas > ./100_buyer_connect_DC.sas ;
sed 's/XXXX/DE/' ./100_buyer_connect.sas > ./100_buyer_connect_DE.sas ;
sed 's/XXXX/FL/' ./100_buyer_connect.sas > ./100_buyer_connect_FL.sas ;
sed 's/XXXX/GA/' ./100_buyer_connect.sas > ./100_buyer_connect_GA.sas ;
sed 's/XXXX/HI/' ./100_buyer_connect.sas > ./100_buyer_connect_HI.sas ;
sed 's/XXXX/IA/' ./100_buyer_connect.sas > ./100_buyer_connect_IA.sas ;
sed 's/XXXX/ID/' ./100_buyer_connect.sas > ./100_buyer_connect_ID.sas ;
sed 's/XXXX/IL/' ./100_buyer_connect.sas > ./100_buyer_connect_IL.sas ;
sed 's/XXXX/IN/' ./100_buyer_connect.sas > ./100_buyer_connect_IN.sas ;
sed 's/XXXX/KS/' ./100_buyer_connect.sas > ./100_buyer_connect_KS.sas ;
sed 's/XXXX/KY/' ./100_buyer_connect.sas > ./100_buyer_connect_KY.sas ;
sed 's/XXXX/LA/' ./100_buyer_connect.sas > ./100_buyer_connect_LA.sas ;
sed 's/XXXX/MA/' ./100_buyer_connect.sas > ./100_buyer_connect_MA.sas ;
sed 's/XXXX/MD/' ./100_buyer_connect.sas > ./100_buyer_connect_MD.sas ;
sed 's/XXXX/ME/' ./100_buyer_connect.sas > ./100_buyer_connect_ME.sas ;
sed 's/XXXX/MI/' ./100_buyer_connect.sas > ./100_buyer_connect_MI.sas ;
sed 's/XXXX/MN/' ./100_buyer_connect.sas > ./100_buyer_connect_MN.sas ;
sed 's/XXXX/MO/' ./100_buyer_connect.sas > ./100_buyer_connect_MO.sas ;
sed 's/XXXX/MS/' ./100_buyer_connect.sas > ./100_buyer_connect_MS.sas ;
sed 's/XXXX/MT/' ./100_buyer_connect.sas > ./100_buyer_connect_MT.sas ;
sed 's/XXXX/NC/' ./100_buyer_connect.sas > ./100_buyer_connect_NC.sas ;
sed 's/XXXX/ND/' ./100_buyer_connect.sas > ./100_buyer_connect_ND.sas ;
sed 's/XXXX/NE/' ./100_buyer_connect.sas > ./100_buyer_connect_NE.sas ;
sed 's/XXXX/NH/' ./100_buyer_connect.sas > ./100_buyer_connect_NH.sas ;
sed 's/XXXX/NJ/' ./100_buyer_connect.sas > ./100_buyer_connect_NJ.sas ;
sed 's/XXXX/NM/' ./100_buyer_connect.sas > ./100_buyer_connect_NM.sas ;
sed 's/XXXX/NV/' ./100_buyer_connect.sas > ./100_buyer_connect_NV.sas ;
sed 's/XXXX/NY/' ./100_buyer_connect.sas > ./100_buyer_connect_NY.sas ;
sed 's/XXXX/OH/' ./100_buyer_connect.sas > ./100_buyer_connect_OH.sas ;
sed 's/XXXX/OK/' ./100_buyer_connect.sas > ./100_buyer_connect_OK.sas ;
sed 's/XXXX/OR/' ./100_buyer_connect.sas > ./100_buyer_connect_OR.sas ;
sed 's/XXXX/PA/' ./100_buyer_connect.sas > ./100_buyer_connect_PA.sas ;
sed 's/XXXX/RI/' ./100_buyer_connect.sas > ./100_buyer_connect_RI.sas ;
sed 's/XXXX/SC/' ./100_buyer_connect.sas > ./100_buyer_connect_SC.sas ;
sed 's/XXXX/SD/' ./100_buyer_connect.sas > ./100_buyer_connect_SD.sas ;
sed 's/XXXX/TN/' ./100_buyer_connect.sas > ./100_buyer_connect_TN.sas ;
sed 's/XXXX/TX/' ./100_buyer_connect.sas > ./100_buyer_connect_TX.sas ;
sed 's/XXXX/UT/' ./100_buyer_connect.sas > ./100_buyer_connect_UT.sas ;
sed 's/XXXX/VA/' ./100_buyer_connect.sas > ./100_buyer_connect_VA.sas ;
sed 's/XXXX/VT/' ./100_buyer_connect.sas > ./100_buyer_connect_VT.sas ;
sed 's/XXXX/WA/' ./100_buyer_connect.sas > ./100_buyer_connect_WA.sas ;
sed 's/XXXX/WI/' ./100_buyer_connect.sas > ./100_buyer_connect_WI.sas ;
sed 's/XXXX/WV/' ./100_buyer_connect.sas > ./100_buyer_connect_WV.sas ;
sed 's/XXXX/WY/' ./100_buyer_connect.sas > ./100_buyer_connect_WY.sas ;

chmod 777  ./100_buyer_connect*sas ;

#launch four jobs that break up largest states

nohup sh 100_buyerconnect_1.sh  &
nohup sh 100_buyerconnect_2.sh  &
nohup sh 100_buyerconnect_3.sh  &
nohup sh 100_buyerconnect_4.sh  



