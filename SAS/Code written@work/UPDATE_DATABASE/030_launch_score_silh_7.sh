#!/bin/sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_KY.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_IA.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_WV.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_HI.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_AK.sas;

