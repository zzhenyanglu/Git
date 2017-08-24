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


# Prepare SAS job to QC the V12 data update 
cat 160_qc.sas | dos2unix > 160_qc_${update_year}q${update_qtr}.sas
echo "%qc_em_coverage (quarter="${update_qtr}", year="${update_year}", email="${email_person}", cac_read_dir_loc="${read_dir}", codepath="${cicodepath}");"  >> 160_qc_${update_year}q${update_qtr}.sas
nohup wps -work /project18/SASWORK -nodms ./160_qc_${update_year}q${update_qtr}.sas

