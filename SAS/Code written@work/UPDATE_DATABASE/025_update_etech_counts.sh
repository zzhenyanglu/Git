#!/bin/sh

#SHELL SCRIPT TO GET COUNTS OF RECORDS SENT TO ETECH

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

cidatapath=$3

# GET NUMBER OF RECORDS WRITTEN TO THE FILE FOR ETECH INTO A FILE FOR IMPORT TO EXCEL
wc -l /project/CACDIRECT/$cidatapath/ETECH/FORETECH/*.csv > etech_cnts_"${update_year}"_"${update_qtr}".txt

gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_AK.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_AL.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_AR.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_AZ.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_CA.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_CO.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_CT.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_DC.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_DE.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_FL.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_GA.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_HI.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_IA.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_ID.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_IL.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_IN.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_KS.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_KY.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_LA.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_MA.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_MD.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_ME.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_MI.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_MN.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_MO.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_MS.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_MT.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_NC.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_ND.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_NE.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_NH.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_NJ.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_NM.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_NV.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_NY.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_OH.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_OK.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_OR.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_PA.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_RI.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_SC.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_SD.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_TN.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_TX.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_UT.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_VA.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_VT.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_WA.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_WI.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_WV.csv
gzip /project/CACDIRECT/$cidatapath/ETECH/FORETECH/etech_CAC_WY.csv
