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

# Update Ethnic data 
   cat 060_append_etech.sas | dos2unix > 060_ethnic_update_${update_year}q${update_qtr}.sas
   echo  "%readin(qtr="${update_qtr}", year="${update_year}", email="${email_person} ",cacdir_loc="${write_dir}", codepath="${cicodepath}");" >>  060_ethnic_update_${update_year}q${update_qtr}.sas
   wps -work /project18/SASWORK -nodms 060_ethnic_update_${update_year}q${update_qtr}.sas  

# Create samples w/ Ethnic data
   cat 070_cacdirectsamples.sas | dos2unix > 070_cacdirectsamples_${update_year}q${update_qtr}.sas
   echo  "%allstates(qtr="${update_qtr}",year="${update_year}",cacdir_loc="${write_dir}", ethnic=Y, geo=Y, census=Y, codepath="${cicodepath}");" >> 070_cacdirectsamples_${update_year}q${update_qtr}.sas
   wps ./070_cacdirectsamples_${update_year}q${update_qtr}.sas

# Compare variable means and distributions over time
cat 080_qc_sample_report.sas | dos2unix > 080_qc_sample_report_${update_year}q${update_qtr}.sas
echo "%dirqc(sample=point1pct,qtr="${update_qtr}",year="${update_year}",version="${version}",red=.2,yellow=.1,email="${email_person}",cacdir_loc="${write_dir}", codepath="${cicodepath}");" >> 080_qc_sample_report_${update_year}q${update_qtr}.sas
nohup wps ./080_qc_sample_report_${update_year}q${update_qtr}.sas

# Create load summary
   cat 090_load_summary.sas | dos2unix > 090_load_summary_${update_year}q${update_qtr}.sas
   echo  "%load_summary(year="${update_year}", qtr="${update_qtr}", cacdir_loc="${write_dir}", codepath="${cicodepath}");" >>  090_load_summary_${update_year}q${update_qtr}.sas
   wps -work /project18/SASWORK -nodms 090_load_summary_${update_year}q${update_qtr}.sas &  


# Create modeling recodes
cat 140_pull_down_and_sample_rt_data.sas | dos2unix > 140_pull_down_and_sample_rt_data_${update_year}q${update_qtr}.sas
echo "%doit(codepath="${cicodepath}");" >> 140_pull_down_and_sample_rt_data_${update_year}q${update_qtr}.sas
wps -work /project18/SASWORK -nodms 140_pull_down_and_sample_rt_data_${update_year}q${update_qtr}.sas;

#Create Intellimodel Datasets

cat 170_bb_agg_base_by_bg.sas | dos2unix > 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.sas
echo "%aggregation(sort_var= cac_census_2010_county_code cac_census_2010_tract_block_grp, by_var  = cac_census_2010_tract_block_grp, merge_field = matching_field, testobs = max, codepath="${cicodepath}");" >> 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.sas
wps -work /project18/SASWORK -nodms 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.sas;

cat 180_bb_agg_base_by_zip.sas | dos2unix > 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.sas
echo "%aggregation(sort_var= cac_addr_zip, by_var  = cac_addr_zip, merge_field = matching_field, testobs = max, codepath="${cicodepath}");" >> 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.sas
wps -work /project18/SASWORK -nodms 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.sas;

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

nohup sh 210_intelliscore_launcher_1.sh $update_year $update_qtr &
nohup sh 210_intelliscore_launcher_2.sh $update_year $update_qtr &
nohup sh 210_intelliscore_launcher_3.sh $update_year $update_qtr &
nohup sh 210_intelliscore_launcher_4.sh $update_year $update_qtr 
nohup sh 210_intelliscore_launcher_5.sh $update_year $update_qtr 

# Cleanup and lock down

  if [ ! -d /project/CACDIRECT/CODE/HISTORY/$update_year ]; then 
      mkdir /project/CACDIRECT/CODE/HISTORY/$update_year
      chmod 774 /project/CACDIRECT/CODE/HISTORY/$update_year
  fi

  if [ ! -d /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name ]; then 
      mkdir /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name
  fi

  chmod 777 /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name

  cp 010_update_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 010_update_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 020_make_valid_scf_format_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 030_score_silh_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 030_score_silh_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 040_merge_silh3d_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 040_merge_silh3d_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 045_score_vertical_segments_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 045_score_vertical_segments_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 050_master_dom_silh3d_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 050_master_dom_silh3d_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 060_ethnic_update_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 070_cacdirectsamples_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 080_qc_sample_report_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 090_load_summary_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 100_buyer_connect_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 100_buyer_connect_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 120_build_z2_data_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 140_pull_down_and_sample_rt_data* /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 150_em_coverage_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 150_em_coverage_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 155_em_coverage_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 155_em_coverage_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 160_qc* /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 190_geoagg_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 210_intelliscore_${update_year}q${update_qtr}.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 190_geoagg_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp 210_intelliscore_${update_year}q${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp *.htm /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp *.html /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp etech_cnts_${update_year}_${update_qtr}.txt /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp append_etech_${update_year}_${update_qtr}_??.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp append_etech_${update_year}_${update_qtr}_?.??? /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp data_storage_base_${update_year}_${update_qtr}.pdm /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp data_storage_etech_${update_year}_${update_qtr}.pdm /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp data_storage_geo_${update_year}_${update_qtr}.pdm /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp data_storage_indiv_${update_year}_${update_qtr}.pdm /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp cacdirect_load_summary_${update_year}_${update_qtr}.pdm /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp *sh /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.
  cp *inc /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.

  if [ -d /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name ]; then 
      
        rm 010_update_${update_year}q${update_qtr}_??.??? 
        rm 010_update_${update_year}q${update_qtr}.???
        rm 020_make_valid_scf_format_${update_year}q${update_qtr}.??? 
        rm 030_score_silh_${update_year}q${update_qtr}_??.???
        rm 030_score_silh_${update_year}q${update_qtr}.???
        rm 040_merge_silh3d_${update_year}q${update_qtr}_??.??? 
        rm 045_score_vertical_segments_${update_year}q${update_qtr}.???
        rm 045_score_vertical_segments_${update_year}q${update_qtr}_??.???
        rm 050_master_dom_silh3d_${update_year}q${update_qtr}_??.??? 
        rm 070_cacdirectsamples_${update_year}q${update_qtr}.???
        rm 080_qc_sample_report_${update_year}q${update_qtr}.??? 
        rm 090_load_summary_${update_year}q${update_qtr}.??? 
        rm 100_buyer_connect_${update_year}q${update_qtr}_??.??? 
        rm 130_create_recode_table_${update_year}q${update_qtr}_*.???
        rm 140_pull_down_and_sample_rt_data_${update_year}q${update_qtr}*.???
        rm *.htm
        rm wc_??.txt
        rm keepers_??.sas
        rm etech_cnts_${update_year}_${update_qtr}.txt 
        rm ethnic_update_${update_year}q${update_qtr}.txt
        rm 120_build_z2_data_${update_year}q${update_qtr}.???
        rm 050_master_dom_silh3d_${update_year}q${update_qtr}.???
        rm 100_buyer_connect_${update_year}q${update_qtr}.???
        rm 040_merge_silh3d_${update_year}q${update_qtr}.???
        rm 060_ethnic_update_${update_year}q${update_qtr}.???
        rm 150_em_coverage_${update_year}q${update_qtr}_??.???
        rm 150_em_coverage_${update_year}q${update_qtr}.???
        rm 155_em_coverage_${update_year}q${update_qtr}_??.???
        rm 155_em_coverage_${update_year}q${update_qtr}.???
        rm 160_qc_${update_year}q${update_qtr}.???
        rm 170_bb_agg_base_by_bg_${update_year}q${update_qtr}.???
        rm 180_bb_agg_base_by_zip_${update_year}q${update_qtr}.???
        rm 190_geoagg_${update_year}q${update_qtr}.???
        rm 210_intelliscore_${update_year}q${update_qtr}.???
        rm 190_geoagg_${update_year}q${update_qtr}_??.???
        rm 210_intelliscore_${update_year}q${update_qtr}_??.???
        rm append_etech_${update_year}_${update_qtr}_*.???
        rm *_load_summary_${update_year}_${update_qtr}.pdm
        rm data_storage_base_${update_year}_${update_qtr}.pdm 
	      rm data_storage_etech_${update_year}_${update_qtr}.pdm 
	      rm data_storage_geo_${update_year}_${update_qtr}.pdm 
        rm data_storage_indiv_${update_year}_${update_qtr}.pdm
        rm /project17/CACDIRECT/$cidatapath/ETECH/FORETECH/*.gz
        rm /project17/CACDIRECT/$cidatapath/ETECH/FORETECH/*.sas7bdat
        rm /project17/CACDIRECT/$cidatapath/ETECH/FROMETECH/etech_CAC_Combine_Encoded.csv     
  fi
  
chmod 774 /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name/.

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

  chmod 664 /project/CACDIRECT/CODE/$cicodepath/UPDATE_DATABASE/*.*
  chmod +x /project/CACDIRECT/CODE/$cicodepath/UPDATE_DATABASE/*.sh

  chmod 664 /project/CACDIRECT/ADMIN/*.*
  chmod 664 /project/CACDIRECT/ADMIN/PRODUCTION_DOCUMENTATION/*.*

echo "HONEY BADGER DOES NOT GIVE A SHIT"   
echo "Sweet chiaiaiaiaiaiaiaiaiaiaiaiaiaiaiailed ooooooooooooooooooooooooooooooooooooooooo minnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnne"  
   
exit 0

