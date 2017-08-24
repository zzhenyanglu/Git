#!/bin/csh
#master_controller.sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_NY.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_MI.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_VA.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_TN.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_AZ.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_MD.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_CO.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_SC.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_CT.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_MS.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_NH.sas;
nohup wps ./100_buyer_connect_${update_year}q${update_qtr}_SD.sas;
