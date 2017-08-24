
#!/bin/csh
#master_controller.sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_OH.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_NC.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_MA.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_OK.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_KS.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_RI.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_VT.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_CA.sas;
