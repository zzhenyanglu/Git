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
psql --host=ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com --port=5432 --username=ais --dbname=cac_prod -v fdate=$currdate -v cidatapath=$cidatapath -f buzzboard_import_${update_year}q${update_qtr}.sql;

