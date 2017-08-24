cicodepath=$1
# Previous quarter
update_qtr=$2
# Previous year
update_year=$3
# Folder name
folder_name=$4

if [ $# -eq 4 ]; then
   currdate=`date +'%d%b%Y' | tr "[:upper:]" "[:lower:]"`;
else
   currdate=$5;
fi

if [ $cicodepath = PROD ]; then cidatapath=DATA
        else cidatapath=DATA/$cicodepath
fi

#cat hh_rename_table_backup_prod.sql | dos2unix > hh_rename_table_backup_prod_${update_year}q${update_qtr}.sql
#cat hh_rename_table_promote_new.sql | dos2unix > hh_rename_table_promote_new_${update_year}q${update_qtr}.sql
#cat hh_make_national_counts.sql | dos2unix > hh_make_national_counts_${update_year}q${update_qtr}.sql
#cat hh_drop_aborted_tables.sql | dos2unix > hh_drop_aborted_tables_${update_year}q${update_qtr}.sql
#cat hh_drop_old_tables.sql | dos2unix > hh_drop_old_tables_${update_year}q${update_qtr}.sql

#cat samp_rename_table_backup_prod.sql | dos2unix > samp_rename_table_backup_prod_${update_year}q${update_qtr}.sql
#cat samp_rename_table_promote_new.sql | dos2unix > samp_rename_table_promote_new_${update_year}q${update_qtr}.sql
#cat samp_drop_old_tables.sql | dos2unix > samp_drop_old_tables_${update_year}q${update_qtr}.sql
#cat samp_drop_aborted_tables.sql | dos2unix > samp_drop_aborted_tables_${update_year}q${update_qtr}.sql

#cat z2_rename_table_backup_prod.sql | dos2unix > z2_rename_table_backup_prod_${update_year}q${update_qtr}.sql
#cat z2_rename_table_promote_new.sql | dos2unix > z2_rename_table_promote_new_${update_year}q${update_qtr}.sql
#cat z2_drop_old_tables.sql | dos2unix > z2_drop_old_tables_${update_year}q${update_qtr}.sql
#cat z2_drop_aborted_tables.sql | dos2unix > z2_drop_aborted_tables_${update_year}q${update_qtr}.sql

#cat buzzboard_rename_table_backup_prod.sql | dos2unix > buzzboard_rename_table_backup_prod_${update_year}q${update_qtr}.sql
#cat buzzboard_rename_table_promote_new.sql | dos2unix > buzzboard_rename_table_promote_new_${update_year}q${update_qtr}.sql
#cat buzzboard_drop_old_tables.sql | dos2unix > buzzboard_drop_old_tables_${update_year}q${update_qtr}.sql

#cat bridge_pid_rename_table_backup_prod.sql | dos2unix > bridge_pid_rename_table_backup_prod_${update_year}q${update_qtr}.sql
#cat bridge_pid_rename_table_promote_new.sql | dos2unix > bridge_pid_rename_table_promote_new_${update_year}q${update_qtr}.sql
#cat bridge_pid_drop_old_tables.sql | dos2unix > bridge_pid_drop_old_tables_${update_year}q${update_qtr}.sql


# FL - PROMOTE HH

# HH - rename 
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f hh_rename_table_backup_prod_${update_year}q${update_qtr}.sql;
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f hh_rename_table_promote_new_${update_year}q${update_qtr}.sql;
# HH - drop
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f hh_drop_aborted_tables_${update_year}q${update_qtr}.sql;
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f hh_drop_old_tables_${update_year}q${update_qtr}.sql;
# HH - make national counts 
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f hh_make_national_counts_${update_year}q${update_qtr}.sql;


# FL - PROMOTE SAMP

# SAMP - rename 
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f samp_rename_table_backup_prod_${update_year}q${update_qtr}.sql;
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f samp_rename_table_promote_new_${update_year}q${update_qtr}.sql;
# SAMP - drop
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f samp_drop_aborted_tables_${update_year}q${update_qtr}.sql;
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f samp_drop_old_tables_${update_year}q${update_qtr}.sql


# FL - PROMOTE Z2

# Z2 - rename 
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f z2_rename_table_backup_prod_${update_year}q${update_qtr}.sql;
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f z2_rename_table_promote_new_${update_year}q${update_qtr}.sql;
# Z2 - drop
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f z2_drop_aborted_tables_${update_year}q${update_qtr}.sql;
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f z2_drop_old_tables_${update_year}q${update_qtr}.sql;


# FL - PROMOTE BUZZBOARD

# BUZZBOARD - rename 
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f buzzboard_rename_table_backup_prod_${update_year}q${update_qtr}.sql;
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f buzzboard_rename_table_promote_new_${update_year}q${update_qtr}.sql;
# BUZZBOARD - drop
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f buzzboard_drop_old_tables_${update_year}q${update_qtr}.sql;


# FL - PROMOTE bridge_pid

# bridge_pid - rename 
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f bridge_pid_rename_table_backup_prod_${update_year}q${update_qtr}.sql;
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f bridge_pid_rename_table_promote_new_${update_year}q${update_qtr}.sql;
# bridge_pid - drop
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f bridge_pid_drop_old_tables_${update_year}q${update_qtr}.sql;


  if [ ! -d /project/CACDIRECT/CODE/HISTORY/$update_year ]; then 
      mkdir /project/CACDIRECT/CODE/HISTORY/$update_year
      chmod 774 /project/CACDIRECT/CODE/HISTORY/$update_year
  fi

  if [ ! -d /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name ]; then 
      mkdir /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name
  fi

  chmod 777 /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name

  cp hh*${update_year}q${update_qtr}.sql /project/CACDIRECT/CODE/HISTORY/${update_year}/${folder_name}/.
  cp samp*${update_year}q${update_qtr}.sql /project/CACDIRECT/CODE/HISTORY/${update_year}/${folder_name}/.
  cp z2*${update_year}q${update_qtr}.sql /project/CACDIRECT/CODE/HISTORY/${update_year}/${folder_name}/.
  cp buzzboard*${update_year}q${update_qtr}.sql /project/CACDIRECT/CODE/HISTORY/${update_year}/${folder_name}/.
  cp bridge_pid_*${update_year}q${update_qtr}.sql /project/CACDIRECT/CODE/HISTORY/${update_year}/${folder_name}/.

  if [ -d /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name ]; then 
	rm hh*${update_year}q${update_qtr}.sql 
        rm samp*${update_year}q${update_qtr}.sql 
        rm z2*${update_year}q${update_qtr}.sql
        rm buzzboard*${update_year}q${update_qtr}.sql 
        rm bridge_pid_*${update_year}q${update_qtr}.sql 
  fi

  chmod 774 /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name

  # FL  CLEAN UP DATA 29JUL2015
  #rm /project/CACDIRECT/${cidatapath}/EXPORT/Z2/z2_modelscore.csv.gzip
  #rm /project/CACDIRECT/${cidatapath}/EXPORT/SAMPLE/samp_hh.csv.gzip
  #rm /project/CACDIRECT/${cidatapath}/EXPORT/FULL/cac_hh_master.csv.gzip
  #rm /project/CACDIRECT/${cidatapath}/EXPORT/BUZZBOARD/buzzboard_cen_us_avg.csv.gzip
  #rm /project/CACDIRECT/${cidatapath}/EXPORT/BUZZBOARD/buzzboard_zip_level.csv.gzip
  #rm /project/CACDIRECT/${cidatapath}/EXPORT/BUZZBOARD/buzzboard_cen_level.csv.gzip
  #rm /project/CACDIRECT/${cidatapath}/EXPORT/BRIDGE/bridge_pid_table.csv.gzip
    
  #pigz -N /project/CACDIRECT/${cidatapath}/EXPORT/Z2/z2_modelscore.csv
  #pigz -N /project/CACDIRECT/${cidatapath}/EXPORT/SAMPLE/samp_hh.csv
  #pigz -N /project/CACDIRECT/${cidatapath}/EXPORT/FULL/cac_hh_master.csv
  pigz -N /project/CACDIRECT/${cidatapath}/EXPORT/BUZZBOARD/buzzboard_cen_us_avg.csv
  pigz -N /project/CACDIRECT/${cidatapath}/EXPORT/BUZZBOARD/buzzboard_zip_level.csv
  pigz -N /project/CACDIRECT/${cidatapath}/EXPORT/BUZZBOARD/buzzboard_cen_level.csv
  pigz -N /project/CACDIRECT/${cidatapath}/EXPORT/BRIDGE/bridge_pid_table.csv


