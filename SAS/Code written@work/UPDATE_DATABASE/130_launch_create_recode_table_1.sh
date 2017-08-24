#!/bin/csh
#master_controller.sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_IL.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_NJ.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_IN.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_WI.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_FL.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_AL.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_LA.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_OR.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_AR.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_ME.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_DE.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_DC.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_ID.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_MT.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_NE.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_NV.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_NM.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_ND.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_UT.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_WY.sas;
