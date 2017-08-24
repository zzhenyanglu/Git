#!/bin/csh
#master_controller.sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

wps -work /project18/SASWORK -nodms 010_update_${update_year}q${update_qtr}_FL.sas;
wps -work /project18/SASWORK -nodms 010_update_${update_year}q${update_qtr}_IL.sas;
wps -work /project18/SASWORK -nodms 010_update_${update_year}q${update_qtr}_NJ.sas;
wps -work /project18/SASWORK -nodms 010_update_${update_year}q${update_qtr}_IN.sas;
wps -work /project18/SASWORK -nodms 010_update_${update_year}q${update_qtr}_WI.sas;
wps -work /project18/SASWORK -nodms 010_update_${update_year}q${update_qtr}_AL.sas;
wps -work /project18/SASWORK -nodms 010_update_${update_year}q${update_qtr}_LA.sas;
wps -work /project18/SASWORK -nodms 010_update_${update_year}q${update_qtr}_OR.sas;
wps -work /project18/SASWORK -nodms 010_update_${update_year}q${update_qtr}_AR.sas;
wps -work /project18/SASWORK -nodms 010_update_${update_year}q${update_qtr}_ME.sas;
wps -work /project18/SASWORK -nodms 010_update_${update_year}q${update_qtr}_DE.sas;


