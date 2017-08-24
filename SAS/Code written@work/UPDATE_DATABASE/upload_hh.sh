# Code Path For Prod VS Dev Runs
cicodepath=$1
if [ $cicodepath = PROD ]; then cidatapath=DATA
        else cidatapath=DATA/$cicodepath
fi

/project/CACDIRECT/CODE/${cicodepath}/UPDATE_DATABASE/sftp_script.sh ec2-user 52.24.168.156 S0uth_D@k0t@! put /project/CACDIRECT/${cidatapath}/EXPORT/FULL/cac_hh_master.csv.gz /data
