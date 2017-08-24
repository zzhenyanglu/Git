cd /project/SARPINOS/DATA/20150629/
ftp -in 216.157.38.64 <<!
quote user const
quote pass BearDown_15
cd sarpinos_adm
bin
delete 95.csv
put sarpinos_mailable_store_95_20150629.csv  95.csv
get 95.csv return_sarpinos_mailable_store_95_20150629.csv
bye
quit
!
