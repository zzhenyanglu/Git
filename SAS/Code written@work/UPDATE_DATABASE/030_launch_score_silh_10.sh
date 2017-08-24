#!/bin/sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_OK.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_KS.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_RI.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_VT.sas;




