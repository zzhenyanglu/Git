#!/bin/csh
#020_wrap_it_up.sh

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
# Folder name
folder_name=$8
#version
version=$9
# Code Path For Prod VS Dev Runs
cicodepath=${10}
if [ $cicodepath = PROD ]; then cidatapath=DATA
        else cidatapath=DATA/$cicodepath
fi

#Intelliscore Model Update
cat 210_intelliscore.sas | dos2unix > 210_intelliscore_${update_year}q${update_qtr}.sas;
echo "%im_master_score (scr_st=XXXXXXXXXX, testobs=,refdir=/project/INTELLIMODEL/CODE,email="${email_person}", cac_read_dir_loc="${read_dir}",codepath="${cicodepath}");" >> 210_intelliscore_${update_year}q${update_qtr}.sas

sed 's/XXXXXXXXXX/AK/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_AK.sas ;
sed 's/XXXXXXXXXX/AL/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_AL.sas ;
sed 's/XXXXXXXXXX/AR/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_AR.sas ;
sed 's/XXXXXXXXXX/AZ/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_AZ.sas ;
sed 's/XXXXXXXXXX/CA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_CA.sas ;
sed 's/XXXXXXXXXX/CO/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_CO.sas ;
sed 's/XXXXXXXXXX/CT/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_CT.sas ;
sed 's/XXXXXXXXXX/DC/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_DC.sas ;
sed 's/XXXXXXXXXX/DE/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_DE.sas ;
sed 's/XXXXXXXXXX/FL/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_FL.sas ;
sed 's/XXXXXXXXXX/GA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_GA.sas ;
sed 's/XXXXXXXXXX/HI/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_HI.sas ;
sed 's/XXXXXXXXXX/IA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_IA.sas ;
sed 's/XXXXXXXXXX/ID/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_ID.sas ;
sed 's/XXXXXXXXXX/IL/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_IL.sas ;
sed 's/XXXXXXXXXX/IN/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_IN.sas ;
sed 's/XXXXXXXXXX/KS/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_KS.sas ;
sed 's/XXXXXXXXXX/KY/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_KY.sas ;
sed 's/XXXXXXXXXX/LA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_LA.sas ;
sed 's/XXXXXXXXXX/MA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_MA.sas ;
sed 's/XXXXXXXXXX/MD/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_MD.sas ;
sed 's/XXXXXXXXXX/ME/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_ME.sas ;
sed 's/XXXXXXXXXX/MI/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_MI.sas ;
sed 's/XXXXXXXXXX/MN/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_MN.sas ;
sed 's/XXXXXXXXXX/MO/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_MO.sas ;
sed 's/XXXXXXXXXX/MS/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_MS.sas ;
sed 's/XXXXXXXXXX/MT/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_MT.sas ;
sed 's/XXXXXXXXXX/NC/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_NC.sas ;
sed 's/XXXXXXXXXX/ND/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_ND.sas ;
sed 's/XXXXXXXXXX/NE/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_NE.sas ;
sed 's/XXXXXXXXXX/NH/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_NH.sas ;
sed 's/XXXXXXXXXX/NJ/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_NJ.sas ;
sed 's/XXXXXXXXXX/NM/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_NM.sas ;
sed 's/XXXXXXXXXX/NV/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_NV.sas ;
sed 's/XXXXXXXXXX/NY/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_NY.sas ;
sed 's/XXXXXXXXXX/OH/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_OH.sas ;
sed 's/XXXXXXXXXX/OK/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_OK.sas ;
sed 's/XXXXXXXXXX/OR/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_OR.sas ;
sed 's/XXXXXXXXXX/PA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_PA.sas ;
sed 's/XXXXXXXXXX/RI/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_RI.sas ;
sed 's/XXXXXXXXXX/SC/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_SC.sas ;
sed 's/XXXXXXXXXX/SD/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_SD.sas ;
sed 's/XXXXXXXXXX/TN/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_TN.sas ;
sed 's/XXXXXXXXXX/TX/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_TX.sas ;
sed 's/XXXXXXXXXX/UT/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_UT.sas ;
sed 's/XXXXXXXXXX/VA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_VA.sas ;
sed 's/XXXXXXXXXX/VT/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_VT.sas ;
sed 's/XXXXXXXXXX/WA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_WA.sas ;
sed 's/XXXXXXXXXX/WI/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_WI.sas ;
sed 's/XXXXXXXXXX/WV/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_WV.sas ;
sed 's/XXXXXXXXXX/WY/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_WY.sas ;

chmod 777  ./210_intelliscore_${update_year}q${update_qtr}*sas;
chmod 764  ./210*sh;

#nohup sh 210_intelliscore_launcher_1.sh $update_year $update_qtr &
#nohup sh 210_intelliscore_launcher_2.sh $update_year $update_qtr &
#nohup sh 210_intelliscore_launcher_3.sh $update_year $update_qtr &
#nohup sh 210_intelliscore_launcher_4.sh $update_year $update_qtr 
nohup sh 210_intelliscore_launcher_5.sh $update_year $update_qtr 

