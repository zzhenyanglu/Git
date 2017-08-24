cicodepath=$1

if [ $# -eq 1 ]; then
   currdate=`date +'%d%b%Y' | tr "[:upper:]" "[:lower:]"`;
else
   currdate=$2;
fi


if [ $cicodepath = PROD ]; then cidatapath=DATA
        else cidatapath=DATA/$cicodepath
fi


# rename 
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f /project/CACDIRECT/CODE/${cicodepath}/Z2_IMPORT_SCRIPTS/rename_table_backup_prod.sql;
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f /project/CACDIRECT/CODE/${cicodepath}/Z2_IMPORT_SCRIPTS/rename_table_promote_new.sql;

# drop
#psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f /project/CACDIRECT/CODE/${cicodepath}/Z2_IMPORT_SCRIPTS/drop_aborted_tables.sql;
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f /project/CACDIRECT/CODE/${cicodepath}/Z2_IMPORT_SCRIPTS/drop_old_tables.sql;

