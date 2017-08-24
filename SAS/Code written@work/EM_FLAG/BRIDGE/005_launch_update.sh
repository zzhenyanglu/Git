#!/bin/sh
#005_launch_update.sh

currdate=`date +'%d%b%Y' | tr "[:upper:]" "[:lower:]"`;
nohup /home/software/wps/bin/wps -log "/project/CACDIRECT/CODE/PROD/EM_FLAG/BRIDGE/LOGS/000_import_raw_${currdate}.log" -print "/project/CACDIRECT/CODE/PROD/EM_FLAG/BRIDGE/LOGS/000_import_raw_${currdate}.lst" /project/CACDIRECT/CODE/PROD/EM_FLAG/BRIDGE/000_import_raw.sas
