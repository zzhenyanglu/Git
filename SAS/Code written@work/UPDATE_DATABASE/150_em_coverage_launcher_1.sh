#!/bin/csh
#master_controller.sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_WY.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_MT.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_NH.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_UT.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_AR.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_MN.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_LA.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_IN.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_NC.sas   ;
wps -work /project18/SASWORK -nodms 150_em_coverage_${update_year}q${update_qtr}_PA.sas   ;

