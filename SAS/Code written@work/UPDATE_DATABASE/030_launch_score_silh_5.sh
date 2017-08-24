#!/bin/sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_ID.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_MT.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_ND.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_NE.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_NM.sas;
	
