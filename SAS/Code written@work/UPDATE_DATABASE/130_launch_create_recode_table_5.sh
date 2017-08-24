#!/bin/csh
#master_controller.sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_5pct.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_1pct.sas;
nohup wps ./130_create_recode_table_${update_year}q${update_qtr}_point1pct.sas;

