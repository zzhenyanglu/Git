#!/bin/sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_CA.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_OH.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_NC.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_MA.sas;

