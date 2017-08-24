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

#Create Intellimodel Datasets

cat 170_bb_agg_base_by_bg.sas | dos2unix > 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.sas
echo "%aggregation(sort_var= cac_census_2010_county_code cac_census_2010_tract_block_grp, by_var  = cac_census_2010_tract_block_grp, merge_field = matching_field, testobs = 1000, codepath="${cicodepath}");" >> 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.sas
wps -work /project18/SASWORK -nodms 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.sas;

cat 180_bb_agg_base_by_zip.sas | dos2unix > 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.sas
echo "%aggregation(sort_var= cac_addr_zip, by_var  = cac_addr_zip, merge_field = matching_field, testobs = 1000, codepath="${cicodepath}");" >> 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.sas
wps -work /project18/SASWORK -nodms 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.sas;

# Cleanup and lock down

  if [ ! -d /project/CACDIRECT/CODE/HISTORY/$update_year ]; then 
      mkdir /project/CACDIRECT/CODE/HISTORY/$update_year
      chmod 774 /project/CACDIRECT/CODE/HISTORY/$update_year
  fi

  if [ ! -d /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name ]; then 
      mkdir /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name
  fi

  chmod 777 /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name

  cp 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.

  if [ -d /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name ]; then 
     rm 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.???
     rm 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.???
  fi
  
chmod 774 /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.

# INTMDL
  chmod 664 /project/CACDIRECT/$cidatapath/INTMDL/A/*.*
  chmod 664 /project/CACDIRECT/$cidatapath/INTMDL/B/*.*

echo "HONEY BADGER DOES NOT GIVE A SHIT"   
echo "Sweet chiaiaiaiaiaiaiaiaiaiaiaiaiaiaiailed ooooooooooooooooooooooooooooooooooooooooo minnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnne"  
   
exit 0

