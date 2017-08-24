#!/bin/csh
#master_controller.sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2



wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_VT.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_SD.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_ME.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_NM.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_MS.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_KY.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_AL.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_MD.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_NJ.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_OH.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_FL.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_CA.sas   ;
