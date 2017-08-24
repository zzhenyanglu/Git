#!/bin/csh
#master_controller.sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2



wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_AK.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_RI.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_WV.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_KS.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_OK.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_CO.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_MA.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_VA.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_IL.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_TX.sas   ;

