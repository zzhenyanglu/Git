/home/software/wps/bin/wps  -log '/project/CACDIRECT/CODE/PROD/NEW_MOVER/010_mover_import.log' '/project/CACDIRECT/CODE/PROD/NEW_MOVER/010_mover_import.sas'
sleep 15
/home/software/wps/bin/wps  -log '/project/CACDIRECT/CODE/PROD/NEW_MOVER/020_update_import.log' '/project/CACDIRECT/CODE/PROD/NEW_MOVER/020_update_import.sas'
sleep 15
/home/software/wps/bin/wps  -log '/project/CACDIRECT/CODE/PROD/NEW_MOVER/030_mover_processing.log' '/project/CACDIRECT/CODE/PROD/NEW_MOVER/030_mover_processing.sas'
sleep 15
/home/software/wps/bin/wps  -log '/project/CACDIRECT/CODE/PROD/NEW_MOVER/040_cleanup.log' '/project/CACDIRECT/CODE/PROD/NEW_MOVER/040_cleanup.sas'
