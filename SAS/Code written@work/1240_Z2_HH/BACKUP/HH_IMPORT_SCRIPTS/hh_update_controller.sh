cicodepath=$1

if [ $# -eq 1 ]; then
   currdate=`date +'%d%b%Y' | tr "[:upper:]" "[:lower:]"`;
else
   currdate=$2;
fi

if [ $cicodepath = PROD ]; then cidatapath=DATA
        else cidatapath=DATA/$cicodepath
fi

# import 
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -v cidatapath=$cidatapath -f /project/CACDIRECT/CODE/${cicodepath}/HH_IMPORT_SCRIPTS/import_script.sql ;

# index 
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f /project/CACDIRECT/CODE/${cicodepath}/HH_IMPORT_SCRIPTS/index.sql ;

# constraints.sh 
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f /project/CACDIRECT/CODE/${cicodepath}/HH_IMPORT_SCRIPTS/dma_constraints_script.sql ;
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f /project/CACDIRECT/CODE/${cicodepath}/HH_IMPORT_SCRIPTS/zip_constraints_script.sql ;

# vac
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -f /project/CACDIRECT/CODE/${cicodepath}/HH_IMPORT_SCRIPTS/vac_analyze_script.sql ;
