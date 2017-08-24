cicodepath=$1
# Previous quarter
previous_qtr=$2
# Previous year
previous_year=$3

if [ $# -eq 3 ]; then
   currdate=`date +'%d%b%Y' | tr "[:upper:]" "[:lower:]"`;
else
   currdate=$4;
fi

if [ $cicodepath = PROD ]; then cidatapath=DATA
        else cidatapath=DATA/$cicodepath
fi

cat bridge_pid_rename_table_backup_prod.sql | bridge_pid_rename_table_backup_prod_${update_year}q${update_qtr}.sql
cat bridge_pid_rename_table_promote_new.sql | dos2unix > bridge_pid_rename_table_promote_new_${update_year}q${update_qtr}.sql
cat bridge_pid_drop_old_tables.sql | dos2unix > bridge_pid_drop_old_tables_${update_year}q${update_qtr}.sql


# FL - PROMOTE bridge_pid

# bridge_pid - rename 
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f bridge_pid_rename_table_backup_prod_${update_year}q${update_qtr}.sql;
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f bridge_pid_rename_table_promote_new_${update_year}q${update_qtr}.sql;
# bridge_pid - drop
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f bridge_pid_drop_old_tables_${update_year}q${update_qtr}.sql;

  if [ ! -d /project/CACDIRECT/CODE/HISTORY/$update_year ]; then 
      mkdir /project/CACDIRECT/CODE/HISTORY/$update_year
      chmod 774 /project/CACDIRECT/CODE/HISTORY/$update_year
  fi

  if [ ! -d /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name ]; then 
      mkdir /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name
  fi

  chmod 777 /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name

  cp hh*${update_year}q${update_qtr}.sql /project/CACDIRECT/CODE/HISTORY/${update_year}/${folder_name}/.


  if [ -d /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name ]; then 
	    rm bridge_pid_rename*${update_year}q${update_qtr}.sql 
      rm bridge_pid_drop*${update_year}q${update_qtr}.sql 
  fi

  chmod 774 /project/CACDIRECT/CODE/HISTORY/$update_year/$folder_name
 
