cicodepath=$1

update_year=$2

update_qtr=$3

if [ $# -eq 1 ]; then
   currdate=`date +'%d%b%Y' | tr "[:upper:]" "[:lower:]"`;
else
   currdate=$4;
fi

if [ $cicodepath = PROD ]; then cidatapath=DATA
        else cidatapath=DATA/$cicodepath
fi

# import 
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -v cidatapath=$cidatapath -f hh_import_script_${update_year}q${update_qtr}.sql ;

# index 
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f hh_index_${update_year}q${update_qtr}.sql ;

# constraints.sh 
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f hh_dma_constraints_script_${update_year}q${update_qtr}.sql ;
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f hh_zip_constraints_script_${update_year}q${update_qtr}.sql ;

# vac
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f hh_vac_analyze_script_${update_year}q${update_qtr}.sql ;
