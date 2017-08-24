
#!/bin/csh
#master_controller.sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_ND.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_DE.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_ID.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_NV.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_OR.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_WI.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_AZ.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_MO.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_GA.sas   ;
wps -work /project18/SASWORK -nodms 190_geoagg_${update_year}q${update_qtr}_NY.sas   ;

                                                                                
