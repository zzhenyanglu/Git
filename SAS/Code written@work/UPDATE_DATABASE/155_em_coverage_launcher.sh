#!/bin/csh
#010_master_controller.sh

# Update year YYYY
update_year=$1
# Update quarter 1 2 3 4 
update_qtr=$2
# Current Production data
read_dir=$3
# Directory to rite new production data
write_dir=$4
# Who to email results to
email_person=$5
# Previous quarter
previous_qtr=$6
# Previous year
previous_year=$7
# Version
version=$8
# Code Path For Prod VS Dev Runs
cicodepath=$9

if [ $cicodepath = PROD ]; then cidatapath=DATA
        else cidatapath=DATA/$cicodepath
fi


# Prepare SAS job to update bridge data
cat 155_em_coverage.sas | dos2unix > 155_em_coverage_${update_year}q${update_qtr}.sas
echo  "%coverage(cstate=XXXXXXXXXX, email=${email_person}, year=${update_year}, quarter=${update_qtr}, cac_read_dir_loc=${read_dir}, codepath=${cicodepath});" >>  155_em_coverage_${update_year}q${update_qtr}.sas


sed 's/XXXXXXXXXX/AK/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_AK.sas ;
sed 's/XXXXXXXXXX/AL/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_AL.sas ;
sed 's/XXXXXXXXXX/AR/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_AR.sas ;
sed 's/XXXXXXXXXX/AZ/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_AZ.sas ;
sed 's/XXXXXXXXXX/CA/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_CA.sas ;
sed 's/XXXXXXXXXX/CO/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_CO.sas ;
sed 's/XXXXXXXXXX/CT/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_CT.sas ;
sed 's/XXXXXXXXXX/DC/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_DC.sas ;
sed 's/XXXXXXXXXX/DE/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_DE.sas ;
sed 's/XXXXXXXXXX/FL/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_FL.sas ;
sed 's/XXXXXXXXXX/GA/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_GA.sas ;
sed 's/XXXXXXXXXX/HI/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_HI.sas ;
sed 's/XXXXXXXXXX/IA/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_IA.sas ;
sed 's/XXXXXXXXXX/ID/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_ID.sas ;
sed 's/XXXXXXXXXX/IL/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_IL.sas ;
sed 's/XXXXXXXXXX/IN/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_IN.sas ;
sed 's/XXXXXXXXXX/KS/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_KS.sas ;
sed 's/XXXXXXXXXX/KY/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_KY.sas ;
sed 's/XXXXXXXXXX/LA/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_LA.sas ;
sed 's/XXXXXXXXXX/MA/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_MA.sas ;
sed 's/XXXXXXXXXX/MD/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_MD.sas ;
sed 's/XXXXXXXXXX/ME/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_ME.sas ;
sed 's/XXXXXXXXXX/MI/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_MI.sas ;
sed 's/XXXXXXXXXX/MN/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_MN.sas ;
sed 's/XXXXXXXXXX/MO/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_MO.sas ;
sed 's/XXXXXXXXXX/MS/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_MS.sas ;
sed 's/XXXXXXXXXX/MT/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_MT.sas ;
sed 's/XXXXXXXXXX/NC/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_NC.sas ;
sed 's/XXXXXXXXXX/ND/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_ND.sas ;
sed 's/XXXXXXXXXX/NE/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_NE.sas ;
sed 's/XXXXXXXXXX/NH/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_NH.sas ;
sed 's/XXXXXXXXXX/NJ/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_NJ.sas ;
sed 's/XXXXXXXXXX/NM/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_NM.sas ;
sed 's/XXXXXXXXXX/NV/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_NV.sas ;
sed 's/XXXXXXXXXX/NY/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_NY.sas ;
sed 's/XXXXXXXXXX/OH/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_OH.sas ;
sed 's/XXXXXXXXXX/OK/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_OK.sas ;
sed 's/XXXXXXXXXX/OR/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_OR.sas ;
sed 's/XXXXXXXXXX/PA/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_PA.sas ;
sed 's/XXXXXXXXXX/RI/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_RI.sas ;
sed 's/XXXXXXXXXX/SC/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_SC.sas ;
sed 's/XXXXXXXXXX/SD/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_SD.sas ;
sed 's/XXXXXXXXXX/TN/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_TN.sas ;
sed 's/XXXXXXXXXX/TX/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_TX.sas ;
sed 's/XXXXXXXXXX/UT/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_UT.sas ;
sed 's/XXXXXXXXXX/VA/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_VA.sas ;
sed 's/XXXXXXXXXX/VT/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_VT.sas ;
sed 's/XXXXXXXXXX/WA/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_WA.sas ;
sed 's/XXXXXXXXXX/WI/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_WI.sas ;
sed 's/XXXXXXXXXX/WV/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_WV.sas ;
sed 's/XXXXXXXXXX/WY/' ./155_em_coverage_${update_year}q${update_qtr}.sas > ./155_em_coverage_${update_year}q${update_qtr}_WY.sas ;


chmod 777  ./155_em_coverage_${update_year}q${update_qtr}*sas;

#launch five jobs that break up largest states

nohup sh 155_em_coverage_launcher_1.sh $update_year $update_qtr &
nohup sh 155_em_coverage_launcher_2.sh $update_year $update_qtr &
nohup sh 155_em_coverage_launcher_3.sh $update_year $update_qtr &
nohup sh 155_em_coverage_launcher_4.sh $update_year $update_qtr &
nohup sh 155_em_coverage_launcher_5.sh $update_year $update_qtr 


