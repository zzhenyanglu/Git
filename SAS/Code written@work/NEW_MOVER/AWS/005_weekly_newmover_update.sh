#!/bin/bash

set code_version = PROD # OR PROD

if [ $code_version = PROD ]; then code_path=/project/CACDIRECT/CODE/PROD/NEW_MOVER/AWS/
        else code_path=/project/CACDIRECT/CODE/DEVELOPMENT/1210_NEWMOVER/
fi


# UNGZIP RAW FILES
unpigz --keep -q /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/New_Mover_Install_WE_$(date +'%m-%d-%Y').txt.gz
unpigz --keep -q /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/VALUESCORE_UPDATE/Constellation_TNM_FULL_WE_$(date --date="-49 days" +'%m-%d-%y').txt.gz


# RENAME
mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/New_Mover_Install_WE_$(date +'%m-%d-%Y').txt /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/New_Mover_Install_WE.txt
mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/VALUESCORE_UPDATE/Constellation_TNM_FULL_WE_$(date --date="-49 days" +'%m-%d-%y').txt /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/VALUESCORE_UPDATE/Constellation_TNM_FULL_WE.txt


# RUN THE SQL SCRIPTS ON AWS ACCORDINGLY
psql -h ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com -U newmover --port=5432 dbname=cac_prod -f ${code_path}001_load_raw_file.sql 
psql -h ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com -U newmover --port=5432 dbname=cac_prod -f ${code_path}002_update_value_score.sql 
psql -h ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com -U newmover --port=5432 dbname=cac_prod -f ${code_path}003_cleanup.sql


# CLEANUP
mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/New_Mover_Install_WE_$(date +'%m-%d-%Y').txt.gz /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/IMPORTED/
mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/VALUESCORE_UPDATE/Constellation_TNM_FULL_WE_$(date --date="-49 days" +'%m-%d-%y').txt.gz /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/IMPORTED/
mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/New_Mover_Install_WE.txt /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/IMPORTED
mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/VALUESCORE_UPDATE/Constellation_TNM_FULL_WE.txt /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/IMPORTED/


# DOCUMENTATION
mv ${code_path}LOGS/qc_newmover_update_.csv ${code_path}LOGS/qc_newmover_update_$(date +'%m-%d-%Y').csv 

# SEND EMAIL
python ${code_path}004_qc_email.py
