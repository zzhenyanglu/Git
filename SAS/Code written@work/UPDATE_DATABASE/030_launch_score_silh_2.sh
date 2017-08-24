#!/bin/sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_TX.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_PA.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_GA.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_WA.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_MO.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_MN.sas;


