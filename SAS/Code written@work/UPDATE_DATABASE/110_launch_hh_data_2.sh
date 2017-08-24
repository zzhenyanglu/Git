#!/bin/csh
#master_controller.sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

nohup wps ./110_build_hh_data_${update_year}q${update_qtr}_PA.sas;
nohup wps ./110_build_hh_data_${update_year}q${update_qtr}_GA.sas;
nohup wps ./110_build_hh_data_${update_year}q${update_qtr}_WA.sas;
nohup wps ./110_build_hh_data_${update_year}q${update_qtr}_MO.sas;
nohup wps ./110_build_hh_data_${update_year}q${update_qtr}_TX.sas;
nohup wps ./110_build_hh_data_${update_year}q${update_qtr}_MN.sas;
nohup wps ./110_build_hh_data_${update_year}q${update_qtr}_KY.sas;
nohup wps ./110_build_hh_data_${update_year}q${update_qtr}_IA.sas;
nohup wps ./110_build_hh_data_${update_year}q${update_qtr}_WV.sas;
nohup wps ./110_build_hh_data_${update_year}q${update_qtr}_HI.sas;
nohup wps ./110_build_hh_data_${update_year}q${update_qtr}_AK.sas;
