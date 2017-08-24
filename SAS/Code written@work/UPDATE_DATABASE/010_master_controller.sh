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

# Get raw file counts

nohup sh 005_raw_counts.sh $cidatapath

# Prepare SAS job to update the data

cat 010_update.sas | dos2unix > 010_update_${update_year}q${update_qtr}.sas
echo  "%update_db (qtr="${update_qtr}", year="${update_year}", email="${email_person}", cac_read_dir_loc="${read_dir}", cstate=XXXXXXXXXX, codepath="${cicodepath}");" >>  010_update_${update_year}q${update_qtr}.sas

sed 's/XXXXXXXXXX/AK/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_AK.sas ;
sed 's/XXXXXXXXXX/AL/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_AL.sas ;
sed 's/XXXXXXXXXX/AR/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_AR.sas ;
sed 's/XXXXXXXXXX/AZ/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_AZ.sas ;
sed 's/XXXXXXXXXX/CA/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_CA.sas ;
sed 's/XXXXXXXXXX/CO/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_CO.sas ;
sed 's/XXXXXXXXXX/CT/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_CT.sas ;
sed 's/XXXXXXXXXX/DC/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_DC.sas ;
sed 's/XXXXXXXXXX/DE/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_DE.sas ;
sed 's/XXXXXXXXXX/FL/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_FL.sas ;
sed 's/XXXXXXXXXX/GA/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_GA.sas ;
sed 's/XXXXXXXXXX/HI/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_HI.sas ;
sed 's/XXXXXXXXXX/IA/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_IA.sas ;
sed 's/XXXXXXXXXX/ID/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_ID.sas ;
sed 's/XXXXXXXXXX/IL/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_IL.sas ;
sed 's/XXXXXXXXXX/IN/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_IN.sas ;
sed 's/XXXXXXXXXX/KS/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_KS.sas ;
sed 's/XXXXXXXXXX/KY/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_KY.sas ;
sed 's/XXXXXXXXXX/LA/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_LA.sas ;
sed 's/XXXXXXXXXX/MA/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_MA.sas ;
sed 's/XXXXXXXXXX/MD/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_MD.sas ;
sed 's/XXXXXXXXXX/ME/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_ME.sas ;
sed 's/XXXXXXXXXX/MI/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_MI.sas ;
sed 's/XXXXXXXXXX/MN/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_MN.sas ;
sed 's/XXXXXXXXXX/MO/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_MO.sas ;
sed 's/XXXXXXXXXX/MS/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_MS.sas ;
sed 's/XXXXXXXXXX/MT/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_MT.sas ;
sed 's/XXXXXXXXXX/NC/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_NC.sas ;
sed 's/XXXXXXXXXX/ND/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_ND.sas ;
sed 's/XXXXXXXXXX/NE/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_NE.sas ;
sed 's/XXXXXXXXXX/NH/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_NH.sas ;
sed 's/XXXXXXXXXX/NJ/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_NJ.sas ;
sed 's/XXXXXXXXXX/NM/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_NM.sas ;
sed 's/XXXXXXXXXX/NV/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_NV.sas ;
sed 's/XXXXXXXXXX/NY/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_NY.sas ;
sed 's/XXXXXXXXXX/OH/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_OH.sas ;
sed 's/XXXXXXXXXX/OK/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_OK.sas ;
sed 's/XXXXXXXXXX/OR/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_OR.sas ;
sed 's/XXXXXXXXXX/PA/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_PA.sas ;
sed 's/XXXXXXXXXX/RI/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_RI.sas ;
sed 's/XXXXXXXXXX/SC/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_SC.sas ;
sed 's/XXXXXXXXXX/SD/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_SD.sas ;
sed 's/XXXXXXXXXX/TN/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_TN.sas ;
sed 's/XXXXXXXXXX/TX/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_TX.sas ;
sed 's/XXXXXXXXXX/UT/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_UT.sas ;
sed 's/XXXXXXXXXX/VA/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_VA.sas ;
sed 's/XXXXXXXXXX/VT/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_VT.sas ;
sed 's/XXXXXXXXXX/WA/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_WA.sas ;
sed 's/XXXXXXXXXX/WI/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_WI.sas ;
sed 's/XXXXXXXXXX/WV/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_WV.sas ;
sed 's/XXXXXXXXXX/WY/' ./010_update_${update_year}q${update_qtr}.sas > ./010_update_${update_year}q${update_qtr}_WY.sas ;

chmod 777  ./010_update_${update_year}q${update_qtr}*sas ;

#launch five jobs that break up largest states

nohup sh 010_launch_update_1.sh $update_year $update_qtr &
nohup sh 010_launch_update_2.sh $update_year $update_qtr &
nohup sh 010_launch_update_3.sh $update_year $update_qtr 
nohup sh 010_launch_update_5.sh $update_year $update_qtr &
nohup sh 010_launch_update_4.sh $update_year $update_qtr


# Create valid scf formats from updated data

cat 020_make_valid_scf_format.sas | dos2unix > 020_make_valid_scf_format_${update_year}q${update_qtr}.sas
echo  "%sortstack (start_st=1, end_st=51, qtr="${update_qtr}", year="${update_year}", write_directory="${write_dir}", codepath="${cicodepath}");" >> 020_make_valid_scf_format_${update_year}q${update_qtr}.sas
wps -work /project18/SASWORK -nodms 020_make_valid_scf_format_${update_year}q${update_qtr}.sas;

# Prep data for Ethnic append by Ethnic Technologies (ETECH)
nohup sh 025_update_etech_counts.sh $update_year $update_qtr $cidatapath &

# Silhouette processing (score, merge, find geo dominant)

# Score
cat 030_score_silh.sas | dos2unix > 030_score_silh_${update_year}q${update_qtr}.sas
echo  "%do_it(quarter="${update_qtr}", year="${update_year}", email="${email_person}", previous_quarter="${previous_qtr}", previous_year="${previous_year}",cacdir_loc="${read_dir}", codepath="${cicodepath}");" >> 030_score_silh_${update_year}q${update_qtr}.sas

cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_AK.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_AL.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_AR.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_AZ.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_CA.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_CO.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_CT.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_DC.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_DE.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_FL.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_GA.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_HI.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_IA.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_ID.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_IL.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_IN.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_KS.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_KY.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_LA.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_MA.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_MD.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_ME.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_MI.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_MN.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_MO.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_MS.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_MT.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_NC.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_ND.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_NE.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_NH.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_NJ.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_NM.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_NV.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_NY.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_OH.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_OK.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_OR.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_PA.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_RI.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_SC.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_SD.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_TN.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_TX.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_UT.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_VA.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_VT.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_WA.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_WI.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_WV.sas
cp 030_score_silh_${update_year}q${update_qtr}.sas ./030_score_silh_${update_year}q${update_qtr}_WY.sas

nohup sh 030_launch_score_silh_1.sh $update_year $update_qtr &
nohup sh 030_launch_score_silh_2.sh $update_year $update_qtr
nohup sh 030_launch_score_silh_3.sh $update_year $update_qtr &
nohup sh 030_launch_score_silh_4.sh $update_year $update_qtr
nohup sh 030_launch_score_silh_5.sh $update_year $update_qtr &
nohup sh 030_launch_score_silh_6.sh $update_year $update_qtr
nohup sh 030_launch_score_silh_7.sh $update_year $update_qtr &
nohup sh 030_launch_score_silh_8.sh $update_year $update_qtr
nohup sh 030_launch_score_silh_9.sh $update_year $update_qtr
nohup sh 030_launch_score_silh_10.sh $update_year $update_qtr

# Merge Silh onto base demo datasets

cat 040_merge_silh3d_base.sas | dos2unix > 040_merge_silh3d_${update_year}q${update_qtr}.sas
echo  "%append_silh3d(qtr="${update_qtr}", year="${update_year}", cacdirect_dir="${write_dir}", test=N, cstate=XXXX, codepath="${cicodepath}");" >> 040_merge_silh3d_${update_year}q${update_qtr}.sas

sed 's/XXXX/AK/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_AK.sas ;
sed 's/XXXX/AL/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_AL.sas ;
sed 's/XXXX/AR/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_AR.sas ;
sed 's/XXXX/AZ/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_AZ.sas ;
sed 's/XXXX/CA/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_CA.sas ;
sed 's/XXXX/CO/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_CO.sas ;
sed 's/XXXX/CT/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_CT.sas ;
sed 's/XXXX/DC/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_DC.sas ;
sed 's/XXXX/DE/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_DE.sas ;
sed 's/XXXX/FL/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_FL.sas ;
sed 's/XXXX/GA/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_GA.sas ;
sed 's/XXXX/HI/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_HI.sas ;
sed 's/XXXX/IA/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_IA.sas ;
sed 's/XXXX/ID/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_ID.sas ;
sed 's/XXXX/IL/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_IL.sas ;
sed 's/XXXX/IN/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_IN.sas ;
sed 's/XXXX/KS/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_KS.sas ;
sed 's/XXXX/KY/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_KY.sas ;
sed 's/XXXX/LA/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_LA.sas ;
sed 's/XXXX/MA/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_MA.sas ;
sed 's/XXXX/MD/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_MD.sas ;
sed 's/XXXX/ME/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_ME.sas ;
sed 's/XXXX/MI/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_MI.sas ;
sed 's/XXXX/MN/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_MN.sas ;
sed 's/XXXX/MO/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_MO.sas ;
sed 's/XXXX/MS/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_MS.sas ;
sed 's/XXXX/MT/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_MT.sas ;
sed 's/XXXX/NC/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_NC.sas ;
sed 's/XXXX/ND/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_ND.sas ;
sed 's/XXXX/NE/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_NE.sas ;
sed 's/XXXX/NH/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_NH.sas ;
sed 's/XXXX/NJ/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_NJ.sas ;
sed 's/XXXX/NM/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_NM.sas ;
sed 's/XXXX/NV/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_NV.sas ;
sed 's/XXXX/NY/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_NY.sas ;
sed 's/XXXX/OH/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_OH.sas ;
sed 's/XXXX/OK/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_OK.sas ;
sed 's/XXXX/OR/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_OR.sas ;
sed 's/XXXX/PA/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_PA.sas ;
sed 's/XXXX/RI/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_RI.sas ;
sed 's/XXXX/SC/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_SC.sas ;
sed 's/XXXX/SD/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_SD.sas ;
sed 's/XXXX/TN/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_TN.sas ;
sed 's/XXXX/TX/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_TX.sas ;
sed 's/XXXX/UT/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_UT.sas ;
sed 's/XXXX/VA/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_VA.sas ;
sed 's/XXXX/VT/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_VT.sas ;
sed 's/XXXX/WA/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_WA.sas ;
sed 's/XXXX/WI/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_WI.sas ;
sed 's/XXXX/WV/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_WV.sas ;
sed 's/XXXX/WY/' 040_merge_silh3d_${update_year}q${update_qtr}.sas > 040_merge_silh3d_${update_year}q${update_qtr}_WY.sas ;

chmod 777  ./040_merge_silh3d_*sas ;

nohup sh 040_launch_merge_silh3d_base_1.sh $update_year $update_qtr &
nohup sh 040_launch_merge_silh3d_base_2.sh $update_year $update_qtr 
nohup sh 040_launch_merge_silh3d_base_3.sh $update_year $update_qtr &
nohup sh 040_launch_merge_silh3d_base_4.sh $update_year $update_qtr 
nohup sh 040_launch_merge_silh3d_base_5.sh $update_year $update_qtr 

#Vertical Segments
cat 045_score_vertical_segments.sas | dos2unix > 045_score_vertical_segments_${update_year}q${update_qtr}.sas;
echo  "%score_vertical_segments(cacdir_loc="${read_dir}", codepath="${cicodepath}", scr_st=XXXXXXXXXX, testobs=max, refdir=/project/CACDIRECT/CODE/"${cicodepath}"/UPDATE_DATABASE, email="${email_person}");" >>  045_score_vertical_segments_${update_year}q${update_qtr}.sas

sed 's/XXXXXXXXXX/AK/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_AK.sas ;
sed 's/XXXXXXXXXX/AL/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_AL.sas ;
sed 's/XXXXXXXXXX/AR/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_AR.sas ;
sed 's/XXXXXXXXXX/AZ/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_AZ.sas ;
sed 's/XXXXXXXXXX/CA/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_CA.sas ;
sed 's/XXXXXXXXXX/CO/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_CO.sas ;
sed 's/XXXXXXXXXX/CT/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_CT.sas ;
sed 's/XXXXXXXXXX/DC/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_DC.sas ;
sed 's/XXXXXXXXXX/DE/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_DE.sas ;
sed 's/XXXXXXXXXX/FL/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_FL.sas ;
sed 's/XXXXXXXXXX/GA/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_GA.sas ;
sed 's/XXXXXXXXXX/HI/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_HI.sas ;
sed 's/XXXXXXXXXX/IA/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_IA.sas ;
sed 's/XXXXXXXXXX/ID/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_ID.sas ;
sed 's/XXXXXXXXXX/IL/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_IL.sas ;
sed 's/XXXXXXXXXX/IN/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_IN.sas ;
sed 's/XXXXXXXXXX/KS/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_KS.sas ;
sed 's/XXXXXXXXXX/KY/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_KY.sas ;
sed 's/XXXXXXXXXX/LA/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_LA.sas ;
sed 's/XXXXXXXXXX/MA/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_MA.sas ;
sed 's/XXXXXXXXXX/MD/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_MD.sas ;
sed 's/XXXXXXXXXX/ME/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_ME.sas ;
sed 's/XXXXXXXXXX/MI/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_MI.sas ;
sed 's/XXXXXXXXXX/MN/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_MN.sas ;
sed 's/XXXXXXXXXX/MO/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_MO.sas ;
sed 's/XXXXXXXXXX/MS/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_MS.sas ;
sed 's/XXXXXXXXXX/MT/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_MT.sas ;
sed 's/XXXXXXXXXX/NC/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_NC.sas ;
sed 's/XXXXXXXXXX/ND/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_ND.sas ;
sed 's/XXXXXXXXXX/NE/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_NE.sas ;
sed 's/XXXXXXXXXX/NH/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_NH.sas ;
sed 's/XXXXXXXXXX/NJ/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_NJ.sas ;
sed 's/XXXXXXXXXX/NM/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_NM.sas ;
sed 's/XXXXXXXXXX/NV/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_NV.sas ;
sed 's/XXXXXXXXXX/NY/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_NY.sas ;
sed 's/XXXXXXXXXX/OH/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_OH.sas ;
sed 's/XXXXXXXXXX/OK/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_OK.sas ;
sed 's/XXXXXXXXXX/OR/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_OR.sas ;
sed 's/XXXXXXXXXX/PA/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_PA.sas ;
sed 's/XXXXXXXXXX/RI/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_RI.sas ;
sed 's/XXXXXXXXXX/SC/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_SC.sas ;
sed 's/XXXXXXXXXX/SD/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_SD.sas ;
sed 's/XXXXXXXXXX/TN/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_TN.sas ;
sed 's/XXXXXXXXXX/TX/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_TX.sas ;
sed 's/XXXXXXXXXX/UT/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_UT.sas ;
sed 's/XXXXXXXXXX/VA/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_VA.sas ;
sed 's/XXXXXXXXXX/VT/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_VT.sas ;
sed 's/XXXXXXXXXX/WA/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_WA.sas ;
sed 's/XXXXXXXXXX/WI/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_WI.sas ;
sed 's/XXXXXXXXXX/WV/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_WV.sas ;
sed 's/XXXXXXXXXX/WY/' ./045_score_vertical_segments_${update_year}q${update_qtr}.sas > ./045_score_vertical_segments_${update_year}q${update_qtr}_WY.sas ;

chmod 777  ./045_score_vertical_segments_${update_year}q${update_qtr}*sas;
chmod 764  ./045*sh;

#launch five jobs that break up largest states

nohup sh 045_score_vertical_segments_launcher_1.sh $update_year $update_qtr &
nohup sh 045_score_vertical_segments_launcher_2.sh $update_year $update_qtr &
nohup sh 045_score_vertical_segments_launcher_3.sh $update_year $update_qtr &
nohup sh 045_score_vertical_segments_launcher_4.sh $update_year $update_qtr 
nohup sh 045_score_vertical_segments_launcher_5.sh $update_year $update_qtr 

# Create samples w/o Ethnic data
cat 070_cacdirectsamples.sas | dos2unix > 070_cacdirectsamples_${update_year}q${update_qtr}.sas
echo  "%allstates(qtr="${update_qtr}",year="${update_year}",cacdir_loc="${write_dir}", ethnic=N, geo=Y, census=Y, codepath="${cicodepath}");" >> 070_cacdirectsamples_${update_year}q${update_qtr}.sas
nohup wps ./070_cacdirectsamples_${update_year}q${update_qtr}.sas

# Compare variable means and distributions over time
cat 080_qc_sample_report.sas | dos2unix > 080_qc_sample_report_${update_year}q${update_qtr}.sas
echo "%dirqc(sample=point1pct,qtr="${update_qtr}",year="${update_year}",version="${version}",red=.2,yellow=.1,email="${email_person}",cacdir_loc="${write_dir}", codepath="${cicodepath}");" >> 080_qc_sample_report_${update_year}q${update_qtr}.sas
nohup wps ./080_qc_sample_report_${update_year}q${update_qtr}.sas

# silh3d
cat 050_master_dom_silh3d.sas | dos2unix > 050_master_dom_silh3d_${update_year}q${update_qtr}.sas
echo  "%geosil(testobs=max,cacdirect_dir="${write_dir}", thisstate=XXXX, codepath="${cicodepath}");" >> 050_master_dom_silh3d_${update_year}q${update_qtr}.sas

sed 's/XXXX/AK/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_AK.sas ;
sed 's/XXXX/AL/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_AL.sas ;
sed 's/XXXX/AR/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_AR.sas ;
sed 's/XXXX/AZ/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_AZ.sas ;
sed 's/XXXX/CA/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_CA.sas ;
sed 's/XXXX/CO/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_CO.sas ;
sed 's/XXXX/CT/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_CT.sas ;
sed 's/XXXX/DC/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_DC.sas ;
sed 's/XXXX/DE/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_DE.sas ;
sed 's/XXXX/FL/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_FL.sas ;
sed 's/XXXX/GA/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_GA.sas ;
sed 's/XXXX/HI/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_HI.sas ;
sed 's/XXXX/IA/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_IA.sas ;
sed 's/XXXX/ID/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_ID.sas ;
sed 's/XXXX/IL/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_IL.sas ;
sed 's/XXXX/IN/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_IN.sas ;
sed 's/XXXX/KS/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_KS.sas ;
sed 's/XXXX/KY/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_KY.sas ;
sed 's/XXXX/LA/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_LA.sas ;
sed 's/XXXX/MA/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_MA.sas ;
sed 's/XXXX/MD/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_MD.sas ;
sed 's/XXXX/ME/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_ME.sas ;
sed 's/XXXX/MI/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_MI.sas ;
sed 's/XXXX/MN/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_MN.sas ;
sed 's/XXXX/MO/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_MO.sas ;
sed 's/XXXX/MS/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_MS.sas ;
sed 's/XXXX/MT/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_MT.sas ;
sed 's/XXXX/NC/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_NC.sas ;
sed 's/XXXX/ND/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_ND.sas ;
sed 's/XXXX/NE/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_NE.sas ;
sed 's/XXXX/NH/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_NH.sas ;
sed 's/XXXX/NJ/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_NJ.sas ;
sed 's/XXXX/NM/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_NM.sas ;
sed 's/XXXX/NV/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_NV.sas ;
sed 's/XXXX/NY/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_NY.sas ;
sed 's/XXXX/OH/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_OH.sas ;
sed 's/XXXX/OK/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_OK.sas ;
sed 's/XXXX/OR/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_OR.sas ;
sed 's/XXXX/PA/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_PA.sas ;
sed 's/XXXX/RI/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_RI.sas ;
sed 's/XXXX/SC/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_SC.sas ;
sed 's/XXXX/SD/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_SD.sas ;
sed 's/XXXX/TN/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_TN.sas ;
sed 's/XXXX/TX/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_TX.sas ;
sed 's/XXXX/UT/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_UT.sas ;
sed 's/XXXX/VA/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_VA.sas ;
sed 's/XXXX/VT/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_VT.sas ;
sed 's/XXXX/WA/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_WA.sas ;
sed 's/XXXX/WI/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_WI.sas ;
sed 's/XXXX/WV/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_WV.sas ;
sed 's/XXXX/WY/' 050_master_dom_silh3d_${update_year}q${update_qtr}.sas > 050_master_dom_silh3d_${update_year}q${update_qtr}_WY.sas ;

chmod 777  050_master_dom_silh3d_${update_year}q${update_qtr}*sas ;

#launch four jobs that break up largest states

nohup sh 050_launch_dom_silh3d_1.sh $update_year $update_qtr & 
nohup sh 050_launch_dom_silh3d_2.sh $update_year $update_qtr & 
nohup sh 050_launch_dom_silh3d_3.sh $update_year $update_qtr &
nohup sh 050_launch_dom_silh3d_4.sh $update_year $update_qtr &

# Create Buyer Connect data
cat 100_buyer_connect.sas | dos2unix > 100_buyer_connect_${update_year}q${update_qtr}.sas
echo   "%buyer_connect (qtr="${update_qtr}", year="${update_year}", cacdir_loc="${write_dir}", thisstate= XXXX, codepath="${cicodepath}");" >> 100_buyer_connect_${update_year}q${update_qtr}.sas

sed 's/XXXX/AK/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_AK.sas ;
sed 's/XXXX/AL/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_AL.sas ;
sed 's/XXXX/AR/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_AR.sas ;
sed 's/XXXX/AZ/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_AZ.sas ;
sed 's/XXXX/CA/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_CA.sas ;
sed 's/XXXX/CO/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_CO.sas ;
sed 's/XXXX/CT/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_CT.sas ;
sed 's/XXXX/DC/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_DC.sas ;
sed 's/XXXX/DE/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_DE.sas ;
sed 's/XXXX/FL/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_FL.sas ;
sed 's/XXXX/GA/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_GA.sas ;
sed 's/XXXX/HI/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_HI.sas ;
sed 's/XXXX/IA/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_IA.sas ;
sed 's/XXXX/ID/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_ID.sas ;
sed 's/XXXX/IL/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_IL.sas ;
sed 's/XXXX/IN/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_IN.sas ;
sed 's/XXXX/KS/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_KS.sas ;
sed 's/XXXX/KY/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_KY.sas ;
sed 's/XXXX/LA/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_LA.sas ;
sed 's/XXXX/MA/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_MA.sas ;
sed 's/XXXX/MD/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_MD.sas ;
sed 's/XXXX/ME/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_ME.sas ;
sed 's/XXXX/MI/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_MI.sas ;
sed 's/XXXX/MN/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_MN.sas ;
sed 's/XXXX/MO/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_MO.sas ;
sed 's/XXXX/MS/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_MS.sas ;
sed 's/XXXX/MT/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_MT.sas ;
sed 's/XXXX/NC/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_NC.sas ;
sed 's/XXXX/ND/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_ND.sas ;
sed 's/XXXX/NE/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_NE.sas ;
sed 's/XXXX/NH/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_NH.sas ;
sed 's/XXXX/NJ/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_NJ.sas ;
sed 's/XXXX/NM/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_NM.sas ;
sed 's/XXXX/NV/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_NV.sas ;
sed 's/XXXX/NY/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_NY.sas ;
sed 's/XXXX/OH/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_OH.sas ;
sed 's/XXXX/OK/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_OK.sas ;
sed 's/XXXX/OR/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_OR.sas ;
sed 's/XXXX/PA/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_PA.sas ;
sed 's/XXXX/RI/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_RI.sas ;
sed 's/XXXX/SC/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_SC.sas ;
sed 's/XXXX/SD/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_SD.sas ;
sed 's/XXXX/TN/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_TN.sas ;
sed 's/XXXX/TX/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_TX.sas ;
sed 's/XXXX/UT/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_UT.sas ;
sed 's/XXXX/VA/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_VA.sas ;
sed 's/XXXX/VT/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_VT.sas ;
sed 's/XXXX/WA/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_WA.sas ;
sed 's/XXXX/WI/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_WI.sas ;
sed 's/XXXX/WV/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_WV.sas ;
sed 's/XXXX/WY/' ./100_buyer_connect_${update_year}q${update_qtr}.sas > ./100_buyer_connect_${update_year}q${update_qtr}_WY.sas ;

chmod 777  ./100_buyer_connect*sas ;

#launch four jobs that break up largest states

nohup sh 100_buyerconnect_1.sh $update_year $update_qtr & 
nohup sh 100_buyerconnect_2.sh $update_year $update_qtr & 
nohup sh 100_buyerconnect_3.sh $update_year $update_qtr & 
nohup sh 100_buyerconnect_4.sh $update_year $update_qtr & 


cat 120_build_z2_data.sas | dos2unix > 120_build_z2_data_${update_year}q${update_qtr}.sas
echo   "%breeze (cacdir_loc="${write_dir}", stst=1, endst=51, codepath="${cicodepath}");" >> 120_build_z2_data_${update_year}q${update_qtr}.sas
nohup wps ./120_build_z2_data_${update_year}q${update_qtr}.sas

# Prepare SAS job to update V12 data
cat 150_em_coverage.sas | dos2unix > 150_em_coverage_${update_year}q${update_qtr}.sas
echo  "%coverage(cstate=XXXXXXXXXX, email=${email_person}, year=${update_year}, quarter=${update_qtr}, cac_read_dir_loc=${read_dir}, codepath=${cicodepath});" >>  150_em_coverage_${update_year}q${update_qtr}.sas

sed 's/XXXXXXXXXX/AK/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_AK.sas ;
sed 's/XXXXXXXXXX/AL/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_AL.sas ;
sed 's/XXXXXXXXXX/AR/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_AR.sas ;
sed 's/XXXXXXXXXX/AZ/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_AZ.sas ;
sed 's/XXXXXXXXXX/CA/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_CA.sas ;
sed 's/XXXXXXXXXX/CO/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_CO.sas ;
sed 's/XXXXXXXXXX/CT/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_CT.sas ;
sed 's/XXXXXXXXXX/DC/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_DC.sas ;
sed 's/XXXXXXXXXX/DE/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_DE.sas ;
sed 's/XXXXXXXXXX/FL/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_FL.sas ;
sed 's/XXXXXXXXXX/GA/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_GA.sas ;
sed 's/XXXXXXXXXX/HI/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_HI.sas ;
sed 's/XXXXXXXXXX/IA/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_IA.sas ;
sed 's/XXXXXXXXXX/ID/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_ID.sas ;
sed 's/XXXXXXXXXX/IL/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_IL.sas ;
sed 's/XXXXXXXXXX/IN/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_IN.sas ;
sed 's/XXXXXXXXXX/KS/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_KS.sas ;
sed 's/XXXXXXXXXX/KY/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_KY.sas ;
sed 's/XXXXXXXXXX/LA/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_LA.sas ;
sed 's/XXXXXXXXXX/MA/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_MA.sas ;
sed 's/XXXXXXXXXX/MD/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_MD.sas ;
sed 's/XXXXXXXXXX/ME/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_ME.sas ;
sed 's/XXXXXXXXXX/MI/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_MI.sas ;
sed 's/XXXXXXXXXX/MN/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_MN.sas ;
sed 's/XXXXXXXXXX/MO/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_MO.sas ;
sed 's/XXXXXXXXXX/MS/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_MS.sas ;
sed 's/XXXXXXXXXX/MT/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_MT.sas ;
sed 's/XXXXXXXXXX/NC/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_NC.sas ;
sed 's/XXXXXXXXXX/ND/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_ND.sas ;
sed 's/XXXXXXXXXX/NE/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_NE.sas ;
sed 's/XXXXXXXXXX/NH/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_NH.sas ;
sed 's/XXXXXXXXXX/NJ/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_NJ.sas ;
sed 's/XXXXXXXXXX/NM/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_NM.sas ;
sed 's/XXXXXXXXXX/NV/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_NV.sas ;
sed 's/XXXXXXXXXX/NY/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_NY.sas ;
sed 's/XXXXXXXXXX/OH/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_OH.sas ;
sed 's/XXXXXXXXXX/OK/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_OK.sas ;
sed 's/XXXXXXXXXX/OR/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_OR.sas ;
sed 's/XXXXXXXXXX/PA/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_PA.sas ;
sed 's/XXXXXXXXXX/RI/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_RI.sas ;
sed 's/XXXXXXXXXX/SC/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_SC.sas ;
sed 's/XXXXXXXXXX/SD/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_SD.sas ;
sed 's/XXXXXXXXXX/TN/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_TN.sas ;
sed 's/XXXXXXXXXX/TX/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_TX.sas ;
sed 's/XXXXXXXXXX/UT/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_UT.sas ;
sed 's/XXXXXXXXXX/VA/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_VA.sas ;
sed 's/XXXXXXXXXX/VT/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_VT.sas ;
sed 's/XXXXXXXXXX/WA/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_WA.sas ;
sed 's/XXXXXXXXXX/WI/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_WI.sas ;
sed 's/XXXXXXXXXX/WV/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_WV.sas ;
sed 's/XXXXXXXXXX/WY/' ./150_em_coverage_${update_year}q${update_qtr}.sas > ./150_em_coverage_${update_year}q${update_qtr}_WY.sas ;


chmod 777  ./150_em_coverage_${update_year}q${update_qtr}*sas;

#launch five jobs that break up largest states

nohup sh 150_em_coverage_launcher_1.sh $update_year $update_qtr &
nohup sh 150_em_coverage_launcher_2.sh $update_year $update_qtr &
nohup sh 150_em_coverage_launcher_3.sh $update_year $update_qtr &
nohup sh 150_em_coverage_launcher_4.sh $update_year $update_qtr &
nohup sh 150_em_coverage_launcher_5.sh $update_year $update_qtr 

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


# Prepare SAS job to QC the V12 data update 
cat 160_qc.sas | dos2unix > 160_qc_${update_year}q${update_qtr}.sas
echo "%qc_em_coverage (quarter="${update_qtr}", year="${update_year}", email="${email_person}", cac_read_dir_loc="${read_dir}", codepath="${cicodepath}");"  >> 160_qc_${update_year}q${update_qtr}.sas
nohup wps -work /project18/SASWORK -nodms ./160_qc_${update_year}q${update_qtr}.sas

#Geoagg
cat 190_geoagg.sas | dos2unix > 190_geoagg_${update_year}q${update_qtr}.sas
echo "%geoagg (st=XXXXXXXXXX, cac_read_dir_loc="${read_dir}", codepath="${cicodepath}");"  >> 190_geoagg_${update_year}q${update_qtr}.sas

sed 's/XXXXXXXXXX/AK/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_AK.sas ;
sed 's/XXXXXXXXXX/AL/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_AL.sas ;
sed 's/XXXXXXXXXX/AR/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_AR.sas ;
sed 's/XXXXXXXXXX/AZ/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_AZ.sas ;
sed 's/XXXXXXXXXX/CA/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_CA.sas ;
sed 's/XXXXXXXXXX/CO/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_CO.sas ;
sed 's/XXXXXXXXXX/CT/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_CT.sas ;
sed 's/XXXXXXXXXX/DC/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_DC.sas ;
sed 's/XXXXXXXXXX/DE/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_DE.sas ;
sed 's/XXXXXXXXXX/FL/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_FL.sas ;
sed 's/XXXXXXXXXX/GA/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_GA.sas ;
sed 's/XXXXXXXXXX/HI/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_HI.sas ;
sed 's/XXXXXXXXXX/IA/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_IA.sas ;
sed 's/XXXXXXXXXX/ID/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_ID.sas ;
sed 's/XXXXXXXXXX/IL/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_IL.sas ;
sed 's/XXXXXXXXXX/IN/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_IN.sas ;
sed 's/XXXXXXXXXX/KS/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_KS.sas ;
sed 's/XXXXXXXXXX/KY/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_KY.sas ;
sed 's/XXXXXXXXXX/LA/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_LA.sas ;
sed 's/XXXXXXXXXX/MA/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_MA.sas ;
sed 's/XXXXXXXXXX/MD/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_MD.sas ;
sed 's/XXXXXXXXXX/ME/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_ME.sas ;
sed 's/XXXXXXXXXX/MI/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_MI.sas ;
sed 's/XXXXXXXXXX/MN/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_MN.sas ;
sed 's/XXXXXXXXXX/MO/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_MO.sas ;
sed 's/XXXXXXXXXX/MS/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_MS.sas ;
sed 's/XXXXXXXXXX/MT/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_MT.sas ;
sed 's/XXXXXXXXXX/NC/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_NC.sas ;
sed 's/XXXXXXXXXX/ND/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_ND.sas ;
sed 's/XXXXXXXXXX/NE/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_NE.sas ;
sed 's/XXXXXXXXXX/NH/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_NH.sas ;
sed 's/XXXXXXXXXX/NJ/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_NJ.sas ;
sed 's/XXXXXXXXXX/NM/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_NM.sas ;
sed 's/XXXXXXXXXX/NV/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_NV.sas ;
sed 's/XXXXXXXXXX/NY/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_NY.sas ;
sed 's/XXXXXXXXXX/OH/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_OH.sas ;
sed 's/XXXXXXXXXX/OK/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_OK.sas ;
sed 's/XXXXXXXXXX/OR/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_OR.sas ;
sed 's/XXXXXXXXXX/PA/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_PA.sas ;
sed 's/XXXXXXXXXX/RI/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_RI.sas ;
sed 's/XXXXXXXXXX/SC/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_SC.sas ;
sed 's/XXXXXXXXXX/SD/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_SD.sas ;
sed 's/XXXXXXXXXX/TN/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_TN.sas ;
sed 's/XXXXXXXXXX/TX/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_TX.sas ;
sed 's/XXXXXXXXXX/UT/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_UT.sas ;
sed 's/XXXXXXXXXX/VA/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_VA.sas ;
sed 's/XXXXXXXXXX/VT/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_VT.sas ;
sed 's/XXXXXXXXXX/WA/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_WA.sas ;
sed 's/XXXXXXXXXX/WI/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_WI.sas ;
sed 's/XXXXXXXXXX/WV/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_WV.sas ;
sed 's/XXXXXXXXXX/WY/' ./190_geoagg_${update_year}q${update_qtr}.sas > ./190_geoagg_${update_year}q${update_qtr}_WY.sas ;

chmod 777  ./190_geoagg_${update_year}q${update_qtr}*sas;

#launch five jobs that break up largest states

nohup sh 190_geoagg_launcher_1.sh $update_year $update_qtr &
nohup sh 190_geoagg_launcher_2.sh $update_year $update_qtr &
nohup sh 190_geoagg_launcher_3.sh $update_year $update_qtr &
nohup sh 190_geoagg_launcher_4.sh $update_year $update_qtr &
nohup sh 190_geoagg_launcher_5.sh $update_year $update_qtr 

exit 0
