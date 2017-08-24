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

# FL ADD 23JUL2015 
# TO CONTROL THE CAC_HH_MASTER SAMPE_HH Z2 PSQL TABLES UPDATE 
currdate=`date +'%d%b%Y' | tr "[:upper:]" "[:lower:]"`;
#
## Update Ethnic data 
#   cat 060_append_etech.sas | dos2unix > 060_ethnic_update_${update_year}q${update_qtr}.sas
#   echo  "%readin(qtr="${update_qtr}", year="${update_year}", email="${email_person} ",cacdir_loc="${write_dir}", codepath="${cicodepath}");" >>  060_ethnic_update_${update_year}q${update_qtr}.sas
#   wps -work /project18/SASWORK -nodms 060_ethnic_update_${update_year}q${update_qtr}.sas  
#
## Create samples w/ Ethnic data
#   cat 070_cacdirectsamples.sas | dos2unix > 070_cacdirectsamples_${update_year}q${update_qtr}.sas
#   echo  "%allstates(qtr="${update_qtr}",year="${update_year}",cacdir_loc="${write_dir}", ethnic=Y, geo=Y, census=Y, codepath="${cicodepath}");" >> 070_cacdirectsamples_${update_year}q${update_qtr}.sas
#   wps ./070_cacdirectsamples_${update_year}q${update_qtr}.sas
#
## Compare variable means and distributions over time
#cat 080_qc_sample_report.sas | dos2unix > 080_qc_sample_report_${update_year}q${update_qtr}.sas
#echo "%dirqc(sample=point1pct,qtr="${update_qtr}",year="${update_year}",version="${version}",red=.2,yellow=.1,email="${email_person}",cacdir_loc="${write_dir}", codepath="${cicodepath}");" >> 080_qc_sample_report_${update_year}q${update_qtr}.sas
#nohup wps ./080_qc_sample_report_${update_year}q${update_qtr}.sas
#
## Create load summary
#   cat 090_load_summary.sas | dos2unix > 090_load_summary_${update_year}q${update_qtr}.sas
#   echo  "%load_summary(year="${update_year}", qtr="${update_qtr}", cacdir_loc="${write_dir}", codepath="${cicodepath}");" >>  090_load_summary_${update_year}q${update_qtr}.sas
#   wps -work /project18/SASWORK -nodms 090_load_summary_${update_year}q${update_qtr}.sas &  
#	
#
##Create Intellimodel Datasets

#cat 170_bb_agg_base_by_bg.sas | dos2unix > 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.sas
#echo "%aggregation(cac_read_dir_loc="${read_dir}",sort_var= cac_census_2010_county_code cac_census_2010_tract_block_grp, by_var  = cac_census_2010_tract_block_grp, merge_field = matching_field, testobs = max, codepath="${cicodepath}");" >> 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.sas
#wps -work /project18/SASWORK -nodms 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.sas;

#cat 180_bb_agg_base_by_zip.sas | dos2unix > 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.sas
#echo "%aggregation(cac_read_dir_loc="${read_dir}",sort_var= cac_addr_zip, by_var  = cac_addr_zip, merge_field = matching_field, testobs = max, codepath="${cicodepath}");" >> 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.sas
#wps -work /project18/SASWORK -nodms 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.sas;

##Intelliscore Model Update
#cat 210_intelliscore.sas | dos2unix > 210_intelliscore_${update_year}q${update_qtr}.sas;
#echo "%im_master_score (scr_st=XXXXXXXXXX, testobs=,refdir=/project/INTELLIMODEL/CODE,email="${email_person}", cac_read_dir_loc="${read_dir}",codepath="${cicodepath}");" >> 210_intelliscore_${update_year}q${update_qtr}.sas
#
#sed 's/XXXXXXXXXX/AK/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_AK.sas ;
#sed 's/XXXXXXXXXX/AL/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_AL.sas ;
#sed 's/XXXXXXXXXX/AR/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_AR.sas ;
#sed 's/XXXXXXXXXX/AZ/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_AZ.sas ;
#sed 's/XXXXXXXXXX/CA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_CA.sas ;
#sed 's/XXXXXXXXXX/CO/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_CO.sas ;
#sed 's/XXXXXXXXXX/CT/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_CT.sas ;
#sed 's/XXXXXXXXXX/DC/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_DC.sas ;
#sed 's/XXXXXXXXXX/DE/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_DE.sas ;
#sed 's/XXXXXXXXXX/FL/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_FL.sas ;
#sed 's/XXXXXXXXXX/GA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_GA.sas ;
#sed 's/XXXXXXXXXX/HI/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_HI.sas ;
#sed 's/XXXXXXXXXX/IA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_IA.sas ;
#sed 's/XXXXXXXXXX/ID/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_ID.sas ;
#sed 's/XXXXXXXXXX/IL/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_IL.sas ;
#sed 's/XXXXXXXXXX/IN/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_IN.sas ;
#sed 's/XXXXXXXXXX/KS/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_KS.sas ;
#sed 's/XXXXXXXXXX/KY/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_KY.sas ;
#sed 's/XXXXXXXXXX/LA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_LA.sas ;
#sed 's/XXXXXXXXXX/MA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_MA.sas ;
#sed 's/XXXXXXXXXX/MD/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_MD.sas ;
#sed 's/XXXXXXXXXX/ME/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_ME.sas ;
#sed 's/XXXXXXXXXX/MI/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_MI.sas ;
#sed 's/XXXXXXXXXX/MN/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_MN.sas ;
#sed 's/XXXXXXXXXX/MO/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_MO.sas ;
#sed 's/XXXXXXXXXX/MS/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_MS.sas ;
#sed 's/XXXXXXXXXX/MT/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_MT.sas ;
#sed 's/XXXXXXXXXX/NC/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_NC.sas ;
#sed 's/XXXXXXXXXX/ND/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_ND.sas ;
#sed 's/XXXXXXXXXX/NE/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_NE.sas ;
#sed 's/XXXXXXXXXX/NH/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_NH.sas ;
#sed 's/XXXXXXXXXX/NJ/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_NJ.sas ;
#sed 's/XXXXXXXXXX/NM/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_NM.sas ;
#sed 's/XXXXXXXXXX/NV/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_NV.sas ;
#sed 's/XXXXXXXXXX/NY/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_NY.sas ;
#sed 's/XXXXXXXXXX/OH/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_OH.sas ;
#sed 's/XXXXXXXXXX/OK/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_OK.sas ;
#sed 's/XXXXXXXXXX/OR/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_OR.sas ;
#sed 's/XXXXXXXXXX/PA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_PA.sas ;
#sed 's/XXXXXXXXXX/RI/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_RI.sas ;
#sed 's/XXXXXXXXXX/SC/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_SC.sas ;
#sed 's/XXXXXXXXXX/SD/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_SD.sas ;
#sed 's/XXXXXXXXXX/TN/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_TN.sas ;
#sed 's/XXXXXXXXXX/TX/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_TX.sas ;
#sed 's/XXXXXXXXXX/UT/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_UT.sas ;
#sed 's/XXXXXXXXXX/VA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_VA.sas ;
#sed 's/XXXXXXXXXX/VT/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_VT.sas ;
#sed 's/XXXXXXXXXX/WA/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_WA.sas ;
#sed 's/XXXXXXXXXX/WI/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_WI.sas ;
#sed 's/XXXXXXXXXX/WV/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_WV.sas ;
#sed 's/XXXXXXXXXX/WY/' ./210_intelliscore_${update_year}q${update_qtr}.sas > ./210_intelliscore_${update_year}q${update_qtr}_WY.sas ;
#
#chmod 777  ./210_intelliscore_${update_year}q${update_qtr}*sas;
#chmod 764  ./210*sh;
#
#nohup sh 210_intelliscore_launcher_1.sh $update_year $update_qtr &
#nohup sh 210_intelliscore_launcher_2.sh $update_year $update_qtr &
#nohup sh 210_intelliscore_launcher_3.sh $update_year $update_qtr &
#nohup sh 210_intelliscore_launcher_4.sh $update_year $update_qtr 
#nohup sh 210_intelliscore_launcher_5.sh $update_year $update_qtr
#
## FL ADDED 09JUL2015
## START - 220_export_hh_by_state
#
#cat 220_export_hh_by_state.sas | dos2unix > 220_export_hh_by_state_${update_year}q${update_qtr}.sas
#echo  "%export_hh(qtr="${update_qtr}", year="${update_year}", email="${email_person}", cac_read_dir_loc="${read_dir}", cstate=XXXXXXXXXX, codepath="${cicodepath}");" >>  220_export_hh_by_state_${update_year}q${update_qtr}.sas
#
#sed 's/XXXXXXXXXX/AK/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_AK.sas ;
#sed 's/XXXXXXXXXX/AL/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_AL.sas ;
#sed 's/XXXXXXXXXX/AR/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_AR.sas ;
#sed 's/XXXXXXXXXX/AZ/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_AZ.sas ;
#sed 's/XXXXXXXXXX/CA/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_CA.sas ;
#sed 's/XXXXXXXXXX/CO/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_CO.sas ;
#sed 's/XXXXXXXXXX/CT/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_CT.sas ;
#sed 's/XXXXXXXXXX/DC/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_DC.sas ;
#sed 's/XXXXXXXXXX/DE/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_DE.sas ;
#sed 's/XXXXXXXXXX/FL/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_FL.sas ;
#sed 's/XXXXXXXXXX/GA/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_GA.sas ;
#sed 's/XXXXXXXXXX/HI/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_HI.sas ;
#sed 's/XXXXXXXXXX/IA/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_IA.sas ;
#sed 's/XXXXXXXXXX/ID/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_ID.sas ;
#sed 's/XXXXXXXXXX/IL/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_IL.sas ;
#sed 's/XXXXXXXXXX/IN/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_IN.sas ;
#sed 's/XXXXXXXXXX/KS/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_KS.sas ;
#sed 's/XXXXXXXXXX/KY/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_KY.sas ;
#sed 's/XXXXXXXXXX/LA/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_LA.sas ;
#sed 's/XXXXXXXXXX/MA/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_MA.sas ;
#sed 's/XXXXXXXXXX/MD/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_MD.sas ;
#sed 's/XXXXXXXXXX/ME/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_ME.sas ;
#sed 's/XXXXXXXXXX/MI/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_MI.sas ;
#sed 's/XXXXXXXXXX/MN/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_MN.sas ;
#sed 's/XXXXXXXXXX/MO/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_MO.sas ;
#sed 's/XXXXXXXXXX/MS/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_MS.sas ;
#sed 's/XXXXXXXXXX/MT/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_MT.sas ;
#sed 's/XXXXXXXXXX/NC/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_NC.sas ;
#sed 's/XXXXXXXXXX/ND/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_ND.sas ;
#sed 's/XXXXXXXXXX/NE/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_NE.sas ;
#sed 's/XXXXXXXXXX/NH/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_NH.sas ;
#sed 's/XXXXXXXXXX/NJ/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_NJ.sas ;
#sed 's/XXXXXXXXXX/NM/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_NM.sas ;
#sed 's/XXXXXXXXXX/NV/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_NV.sas ;
#sed 's/XXXXXXXXXX/NY/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_NY.sas ;
#sed 's/XXXXXXXXXX/OH/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_OH.sas ;
#sed 's/XXXXXXXXXX/OK/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_OK.sas ;
#sed 's/XXXXXXXXXX/OR/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_OR.sas ;
#sed 's/XXXXXXXXXX/PA/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_PA.sas ;
#sed 's/XXXXXXXXXX/RI/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_RI.sas ;
#sed 's/XXXXXXXXXX/SC/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_SC.sas ;
#sed 's/XXXXXXXXXX/SD/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_SD.sas ;
#sed 's/XXXXXXXXXX/TN/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_TN.sas ;
#sed 's/XXXXXXXXXX/TX/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_TX.sas ;
#sed 's/XXXXXXXXXX/UT/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_UT.sas ;
#sed 's/XXXXXXXXXX/VA/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_VA.sas ;
#sed 's/XXXXXXXXXX/VT/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_VT.sas ;
#sed 's/XXXXXXXXXX/WA/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_WA.sas ;
#sed 's/XXXXXXXXXX/WI/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_WI.sas ;
#sed 's/XXXXXXXXXX/WV/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_WV.sas ;
#sed 's/XXXXXXXXXX/WY/' ./220_export_hh_by_state_${update_year}q${update_qtr}.sas > ./220_export_hh_by_state_${update_year}q${update_qtr}_WY.sas ;
#
#chmod 777  ./220_export_hh_by_state_${update_year}q${update_qtr}*sas ;
#
#nohup sh 220_launch_update_1.sh $update_year $update_qtr &
#nohup sh 220_launch_update_2.sh $update_year $update_qtr & 
#nohup sh 220_launch_update_3.sh $update_year $update_qtr 
#nohup sh 220_launch_update_5.sh $update_year $update_qtr &
#nohup sh 220_launch_update_4.sh $update_year $update_qtr
#
#cat /project/CACDIRECT/${cidatapath}/EXPORT/FULL/cac_hh_master_??.csv > /project/CACDIRECT/${cidatapath}/EXPORT/FULL/cac_hh_master.csv;
#cat /project/CACDIRECT/${cidatapath}/EXPORT/SAMPLE/samp_hh_??.csv > /project/CACDIRECT/${cidatapath}/EXPORT/SAMPLE/samp_hh.csv;
#
#pigz -f /project/CACDIRECT/${cidatapath}/EXPORT/FULL/cac_hh_master.csv;
#pigz -f /project/CACDIRECT/${cidatapath}/EXPORT/SAMPLE/samp_hh.csv;
#

#cat 230_match_bridge_to_indiv.sas | dos2unix > 230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas
#echo  "%coverage(cac_read_dir_loc="${read_dir}", cstate=XXXXXXXXXX, codepath="${cicodepath}",spedis_thresh=35,genders=Y);" >>  230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas
#
#sed 's/XXXXXXXXXX/AK/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_AK.sas ;
#sed 's/XXXXXXXXXX/AL/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_AL.sas ;
#sed 's/XXXXXXXXXX/AR/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_AR.sas ;
#sed 's/XXXXXXXXXX/AZ/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_AZ.sas ;
#sed 's/XXXXXXXXXX/CA/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_CA.sas ;
#sed 's/XXXXXXXXXX/CO/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_CO.sas ;
#sed 's/XXXXXXXXXX/CT/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_CT.sas ;
#sed 's/XXXXXXXXXX/DC/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_DC.sas ;
#sed 's/XXXXXXXXXX/DE/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_DE.sas ;
#sed 's/XXXXXXXXXX/FL/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_FL.sas ;
#sed 's/XXXXXXXXXX/GA/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_GA.sas ;
#sed 's/XXXXXXXXXX/HI/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_HI.sas ;
#sed 's/XXXXXXXXXX/IA/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_IA.sas ;
#sed 's/XXXXXXXXXX/ID/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_ID.sas ;
#sed 's/XXXXXXXXXX/IL/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_IL.sas ;
#sed 's/XXXXXXXXXX/IN/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_IN.sas ;
#sed 's/XXXXXXXXXX/KS/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_KS.sas ;
#sed 's/XXXXXXXXXX/KY/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_KY.sas ;
#sed 's/XXXXXXXXXX/LA/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_LA.sas ;
#sed 's/XXXXXXXXXX/MA/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_MA.sas ;
#sed 's/XXXXXXXXXX/MD/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_MD.sas ;
#sed 's/XXXXXXXXXX/ME/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_ME.sas ;
#sed 's/XXXXXXXXXX/MI/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_MI.sas ;
#sed 's/XXXXXXXXXX/MN/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_MN.sas ;
#sed 's/XXXXXXXXXX/MO/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_MO.sas ;
#sed 's/XXXXXXXXXX/MS/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_MS.sas ;
#sed 's/XXXXXXXXXX/MT/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_MT.sas ;
#sed 's/XXXXXXXXXX/NC/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_NC.sas ;
#sed 's/XXXXXXXXXX/ND/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_ND.sas ;
#sed 's/XXXXXXXXXX/NE/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_NE.sas ;
#sed 's/XXXXXXXXXX/NH/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_NH.sas ;
#sed 's/XXXXXXXXXX/NJ/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_NJ.sas ;
#sed 's/XXXXXXXXXX/NM/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_NM.sas ;
#sed 's/XXXXXXXXXX/NV/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_NV.sas ;
#sed 's/XXXXXXXXXX/NY/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_NY.sas ;
#sed 's/XXXXXXXXXX/OH/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_OH.sas ;
#sed 's/XXXXXXXXXX/OK/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_OK.sas ;
#sed 's/XXXXXXXXXX/OR/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_OR.sas ;
#sed 's/XXXXXXXXXX/PA/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_PA.sas ;
#sed 's/XXXXXXXXXX/RI/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_RI.sas ;
#sed 's/XXXXXXXXXX/SC/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_SC.sas ;
#sed 's/XXXXXXXXXX/SD/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_SD.sas ;
#sed 's/XXXXXXXXXX/TN/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_TN.sas ;
#sed 's/XXXXXXXXXX/TX/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_TX.sas ;
#sed 's/XXXXXXXXXX/UT/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_UT.sas ;
#sed 's/XXXXXXXXXX/VA/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_VA.sas ;
#sed 's/XXXXXXXXXX/VT/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_VT.sas ;
#sed 's/XXXXXXXXXX/WA/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_WA.sas ;
#sed 's/XXXXXXXXXX/WI/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_WI.sas ;
#sed 's/XXXXXXXXXX/WV/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_WV.sas ;
#sed 's/XXXXXXXXXX/WY/' ./230_match_bridge_to_indiv_${update_year}q${update_qtr}.sas > ./230_match_bridge_to_indiv_${update_year}q${update_qtr}_WY.sas ;
#
#chmod 777  ./230_match_bridge_to_indiv_${update_year}q${update_qtr}*sas ;

#launch five jobs that break up largest states

#nohup sh 230_launch_update_1.sh $update_year $update_qtr &
#nohup sh 230_launch_update_2.sh $update_year $update_qtr &
#nohup sh 230_launch_update_3.sh $update_year $update_qtr 
#nohup sh 230_launch_update_5.sh $update_year $update_qtr &
#nohup sh 230_launch_update_4.sh $update_year $update_qtr

#mv -f /project/CACDIRECT/$cidatapath/EXPORT/BRIDGE/bridge_pid_table_IL.csv /project/CACDIRECT/$cidatapath/EXPORT/BRIDGE/bridge_pid_table.csv ;
#sed -i '1d' /project/CACDIRECT/$cidatapath/EXPORT/BRIDGE/bridge_pid_table_??.csv ;
#cat /project/CACDIRECT/$cidatapath/EXPORT/BRIDGE/bridge_pid_table_??.csv >> /project/CACDIRECT/$cidatapath/EXPORT/BRIDGE/bridge_pid_table.csv;
#rm  /project/CACDIRECT/$cidatapath/EXPORT/BRIDGE/bridge_pid_table_??.csv ;

## FL ADDED 23JUL2015
## UPDATE PSQL TABLES FROM VINCE 

#cat hh_import_script.sql | dos2unix > hh_import_script_${update_year}q${update_qtr}.sql
#cat hh_index.sql | dos2unix > hh_index_${update_year}q${update_qtr}.sql
#cat hh_dma_constraints_script.sql | dos2unix > hh_dma_constraints_script_${update_year}q${update_qtr}.sql
#cat hh_zip_constraints_script.sql | dos2unix > hh_zip_constraints_script_${update_year}q${update_qtr}.sql
#cat hh_vac_analyze_script.sql | dos2unix > hh_vac_analyze_script_${update_year}q${update_qtr}.sql
#
#cat samp_import_script.sql | dos2unix > samp_import_script_${update_year}q${update_qtr}.sql
#cat samp_index.sql | dos2unix > samp_index_${update_year}q${update_qtr}.sql
#cat samp_dma_constraints_script.sql | dos2unix > samp_dma_constraints_script_${update_year}q${update_qtr}.sql
#cat samp_zip_constraints_script.sql | dos2unix > samp_zip_constraints_script_${update_year}q${update_qtr}.sql
#cat samp_vac_analyze_script.sql | dos2unix > samp_vac_analyze_script_${update_year}q${update_qtr}.sql
#
cat z2_import_script.sql | dos2unix > z2_import_script_${update_year}q${update_qtr}.sql
cat z2_vac_analyze_script.sql | dos2unix > z2_vac_analyze_script_${update_year}q${update_qtr}.sql

cat buzzboard_import.sql | dos2unix > buzzboard_import_${update_year}q${update_qtr}.sql

cat bridge_pid_import_script.sql | dos2unix > bridge_pid_import_script_${update_year}q${update_qtr}.sql
cat bridge_pid_vac_analyze_script.sql | dos2unix > bridge_pid_vac_analyze_script_${update_year}q${update_qtr}.sql


# END - UPDATE PSQL TABLES FROM VINCE 
# FL ADDED 23JUL2015

# FL COMMENTED OUT 
# /project/CACDIRECT/CODE/${cicodepath}/UPDATE_DATABASE/upload_samp.sh $cicodepath;
# /project/CACDIRECT/CODE/${cicodepath}/UPDATE_DATABASE/upload_hh.sh $cicodepath; 

# END - 220_export_hh_by_state
# FL ADDED 9JUL2015

#nohup samp_update_controller.sh $cicodepath ${update_year} ${update_qtr} $currdate &
nohup z2_update_controller.sh $cicodepath ${update_year} ${update_qtr} $currdate &
#nohup hh_update_controller.sh $cicodepath ${update_year} ${update_qtr} $currdate 
nohup buzzboard_update_controller.sh $cicodepath ${update_year} ${update_qtr} $currdate 
nohup bridge_pid_update_controller.sh $cicodepath ${update_year} ${update_qtr} $currdate 

# Cleanup and lock down

  if [ ! -d /project/CACDIRECT/CODE/HISTORY/$update_year ]; then 
      mkdir /project/CACDIRECT/CODE/HISTORY/$update_year
      chmod 774 /project/CACDIRECT/CODE/HISTORY/$update_year
  fi

  if [ ! -d /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name ]; then 
      mkdir /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name
  fi

  chmod 777 /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name

#  cp 010_update_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 010_update_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 020_make_valid_scf_format_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 030_score_silh_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 030_score_silh_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 040_merge_silh3d_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 040_merge_silh3d_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 045_score_vertical_segments_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 045_score_vertical_segments_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 050_master_dom_silh3d_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 050_master_dom_silh3d_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 060_ethnic_update_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 070_cacdirectsamples_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 080_qc_sample_report_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 090_load_summary_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 100_buyer_connect_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 100_buyer_connect_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 120_build_z2_data_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 150_em_coverage_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 150_em_coverage_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 155_em_coverage_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 155_em_coverage_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 160_qc* /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 190_geoagg_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 210_intelliscore_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 190_geoagg_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp 210_intelliscore_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#
#  # FL ADDED 09JUL2015
#  cp 220_export_hh_by_state_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/${update_year}/${folder_name}/.
#  cp 220_export_hh_by_state_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/${update_year}/${folder_name}/. 
#  # FL ADDED 09JUL2015


  # FL ADDED 23JUL2015
#  cp hh*${update_year}q${update_qtr}.sql /project/CACDIRECT/CODE/HISTORY/${update_year}/${folder_name}/.
#  cp samp*${update_year}q${update_qtr}.sql /project/CACDIRECT/CODE/HISTORY/${update_year}/${folder_name}/.
  cp z2*${update_year}q${update_qtr}.sql /project/CACDIRECT/CODE/HISTORY/${update_year}/${folder_name}/.
  cp buzzboard_import_${update_year}q${update_qtr}.sql /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.  
  cp bridge_pid_*${update_year}q${update_qtr}.sql /project/CACDIRECT/CODE/HISTORY/${update_year}/${folder_name}/.
  cp *_copy.sql /project/CACDIRECT/CODE/HISTORY/${update_year}/${folder_name}/.
  # FL ADDED 23JUL2015

#  cp *.htm /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp *.html /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp etech_cnts_${update_year}_${update_qtr}.txt /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp append_etech_${update_year}_${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp append_etech_${update_year}_${update_qtr}_?.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp data_storage_base_${update_year}_${update_qtr}.pdm /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp data_storage_etech_${update_year}_${update_qtr}.pdm /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp data_storage_geo_${update_year}_${update_qtr}.pdm /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp data_storage_indiv_${update_year}_${update_qtr}.pdm /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp cacdirect_load_summary_${update_year}_${update_qtr}.pdm /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp *sh /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
#  cp *inc /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.

  if [ -d /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name ]; then 
      
#        rm 010_update_${update_year}q${update_qtr}_??.??? 
#        rm 010_update_${update_year}q${update_qtr}.???
#        rm 020_make_valid_scf_format_${update_year}q${update_qtr}.??? 
#        rm 030_score_silh_${update_year}q${update_qtr}_??.???
#        rm 030_score_silh_${update_year}q${update_qtr}.???
#        rm 040_merge_silh3d_${update_year}q${update_qtr}_??.??? 
#        rm 045_score_vertical_segments_${update_year}q${update_qtr}.???
#        rm 045_score_vertical_segments_${update_year}q${update_qtr}_??.???
#        rm 050_master_dom_silh3d_${update_year}q${update_qtr}_??.??? 
#        rm 070_cacdirectsamples_${update_year}q${update_qtr}.???
#        rm 080_qc_sample_report_${update_year}q${update_qtr}.??? 
#        rm 090_load_summary_${update_year}q${update_qtr}.??? 
#        rm 100_buyer_connect_${update_year}q${update_qtr}_??.??? 
#        rm *.htm
#        rm wc_??.txt
#        rm keepers_??.sas
#        rm etech_cnts_${update_year}_${update_qtr}.txt 
        rm 120_build_z2_data_${update_year}q${update_qtr}.???
#        rm 050_master_dom_silh3d_${update_year}q${update_qtr}.???
#        rm 100_buyer_connect_${update_year}q${update_qtr}.???
#        rm 040_merge_silh3d_${update_year}q${update_qtr}.???
#        rm 060_ethnic_update_${update_year}q${update_qtr}.???
#        rm 150_em_coverage_${update_year}q${update_qtr}_??.???
#        rm 150_em_coverage_${update_year}q${update_qtr}.???
#        rm 155_em_coverage_${update_year}q${update_qtr}_??.???
#        rm 155_em_coverage_${update_year}q${update_qtr}.???
#        rm 160_qc_${update_year}q${update_qtr}.???
#        rm 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.???
#        rm 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.???
#        rm 190_geoagg_${update_year}q${update_qtr}.???
#        rm 210_intelliscore_${update_year}q${update_qtr}.???
#        rm 190_geoagg_${update_year}q${update_qtr}_??.???
#        rm 210_intelliscore_${update_year}q${update_qtr}_??.???
#
#        # FL ADDED 09JUL2015
#        rm 220_export_hh_by_state_${update_year}q${update_qtr}_??.??? 
#        rm 220_export_hh_by_state_${update_year}q${update_qtr}.???
#        # FL ADDED 09JUL2015
        
        # FL ADDED 23JUL2015
#        rm hh*${update_year}q${update_qtr}.sql 
#        rm samp*${update_year}q${update_qtr}.sql 
        rm z2*${update_year}q${update_qtr}.sql 
        rm buzzboard_import_${update_year}q${update_qtr}.sql
        rm bridge_pid_*${update_year}q${update_qtr}.sql
        rm *_copy.sql
        # FL ADDED 23JUL2015

#        rm append_etech_${update_year}_${update_qtr}_*.???
#        rm *_load_summary_${update_year}_${update_qtr}.pdm
#        rm data_storage_base_${update_year}_${update_qtr}.pdm 
#	rm data_storage_etech_${update_year}_${update_qtr}.pdm 
#	rm data_storage_geo_${update_year}_${update_qtr}.pdm 
#        rm data_storage_indiv_${update_year}_${update_qtr}.pdm
#        rm /project17/CACDIRECT/$cidatapath/ETECH/FORETECH/*.gz
#        rm /project17/CACDIRECT/$cidatapath/ETECH/FORETECH/*.sas7bdat
#        rm /project17/CACDIRECT/$cidatapath/ETECH/FROMETECH/etech_CAC_Combine_Encoded.csv     
  fi
  
chmod 774 /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name

# BASE DEMO
  chmod 664 /project/CACDIRECT/$cidatapath/BASE_DEMO/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/BASE_DEMO/B/*.*

# BUYER CONNECT
  chmod 664 /project/CACDIRECT/$cidatapath/BUYER_CONNECT/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/BUYER_CONNECT/B/*.*

# CAC B2B
  chmod 664 /project/CACDIRECT/$cidatapath/CACB2B/*.*

# DDNC
  chmod 664 /project/CACDIRECT/$cidatapath/DDNC/*.*

# DOM SILH
  chmod 664 /project/CACDIRECT/$cidatapath/DOM_SILH/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/DOM_SILH/B/*.*

# ETECH
  chmod 664 /project/CACDIRECT/$cidatapath/ETECH/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/ETECH/B/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/ETECH/FORETECH/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/ETECH/FROMETECH/*.*

# GEO
  chmod 664 /project/CACDIRECT/$cidatapath/GEO/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/GEO/B/*.*

# INDIV DEMO
  chmod 664 /project/CACDIRECT/$cidatapath/INDIV_DEMO/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/INDIV_DEMO/B/*.*

# JOB HISTORY
  chmod 664 /project/CACDIRECT/$cidatapath/JOB_HISTORY/*.*

# RAW
  chmod 664 /project/CACDIRECT/$cidatapath/RAW/*.*

# RECODES
  chmod 664 /project/CACDIRECT/$cidatapath/RECODES/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/RECODES/B/*.*

# SAMPLES
  chmod 664 /project/CACDIRECT/$cidatapath/SAMPLES/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/SAMPLES/B/*.*

# SCF MKEY
  chmod 664 /project/CACDIRECT/$cidatapath/SCF_MKEY/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/SCF_MKEY/B/*.*

# SILH3D
  chmod 664 /project/CACDIRECT/$cidatapath/SILH3D/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/SILH3D/B/*.*

# INTMDL
  chmod 664 /project/CACDIRECT/$cidatapath/INTMDL/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/INTMDL/B/*.*

# V12
  chmod 664 /project/CACDIRECT/$cidatapath/V12/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/V12/B/*.*

# BRIDGE
  chmod 664 /project/CACDIRECT/$cidatapath/BRIDGE/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/BRIDGE/B/*.*

# GEOAGG
  chmod 664 /project/CACDIRECT/$cidatapath/GEOAGG/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/GEOAGG/B/*.*

# AIL EXPORT
  chmod 664 /project/CACDIRECT/$cidatapath/EXPORT/FULL/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/EXPORT/FULL/B/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/EXPORT/FULL/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/EXPORT/SAMPLE/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/EXPORT/BRIDGE/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/EXPORT/BUZZBOARD/*.*

  chmod 664 /project/CACDIRECT/CODE/$cicodepath/UPDATE_DATABASE/*.*
  chmod +x /project/CACDIRECT/CODE/$cicodepath/UPDATE_DATABASE/*.sh

  chmod 664 /project/CACDIRECT/ADMIN/*.*
  chmod 664 /project/CACDIRECT/ADMIN/PRODUCTION_DOCUMENTATION/*.*

echo "HONEY BADGER DOES NOT GIVE A SHIT"   
echo "Sweet chiaiaiaiaiaiaiaiaiaiaiaiaiaiaiailed ooooooooooooooooooooooooooooooooooooooooo minnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnne"  
   
exit 0

