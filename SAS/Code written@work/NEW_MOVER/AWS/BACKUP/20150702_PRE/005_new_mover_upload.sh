#!/bin/bash

# UNGZIP RAW FILES
unpigz --keep -q /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/New_Mover_Install_WE_$(date +'%m-%d-%Y').txt.gz
unpigz --keep -q /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/VALUESCORE_UPDATE/Constellation_TNM_FULL_WE_$(date --date="-49 days" +'%m-%d-%y').txt.gz


# RENAME
mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/New_Mover_Install_WE_$(date +'%m-%d-%Y').txt /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/New_Mover_Install_WE.txt
mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/VALUESCORE_UPDATE/Constellation_TNM_FULL_WE_$(date --date="-49 days" +'%m-%d-%y').txt /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/VALUESCORE_UPDATE/Constellation_TNM_FULL_WE.txt


# RUN THE SQL SCRIPTS ON AWS ACCORDINGLY
psql -h ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com -U ais --port=5432 dbname=cac_prod -f /project/CACDIRECT/CODE/DEVELOPMENT/1210_NEWMOVER/001_load_raw_file
psql -h ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com -U ais --port=5432 dbname=cac_prod -f /project/CACDIRECT/CODE/DEVELOPMENT/1210_NEWMOVER/002_update_value_score
psql -h ail-postgres.cxj89kwq46vz.us-west-2.rds.amazonaws.com -U ais --port=5432 dbname=cac_prod -f /project/CACDIRECT/CODE/DEVELOPMENT/1210_NEWMOVER/003_cleanup


# CLEANUP
mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/New_Mover_Install_WE_$(date +'%m-%d-%Y').txt.gz /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/IMPORTED/
mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/VALUESCORE_UPDATE/Constellation_TNM_FULL_WE_$(date --date="-49 days" +'%m-%d-%y').txt.gz /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/IMPORTED/
mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/New_Mover_Install_WE.txt /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/IMPORTED
mv /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/VALUESCORE_UPDATE/Constellation_TNM_FULL_WE.txt /project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/IMPORTED/


# DOCUMENTATION
mv /project/CACDIRECT/CODE/DEVELOPMENT/1210_NEWMOVER/LOGS/qc_newmover_update_.csv /project/CACDIRECT/CODE/DEVELOPMENT/1210_NEWMOVER/LOGS/qc_newmover_update_$(date +'%m-%d-%Y').csv 

# SEND EMAIL
python /project/CACDIRECT/CODE/DEVELOPMENT/1210_NEWMOVER/004_qc_email.py
