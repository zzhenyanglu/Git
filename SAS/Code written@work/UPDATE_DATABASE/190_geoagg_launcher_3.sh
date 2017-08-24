#!/bin/csh
#master_controller.sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2



wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_DC.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_HI.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_NE.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_IA.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_CT.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_SC.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_WA.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_TN.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_MI.sas   ;
