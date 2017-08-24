#!/bin/sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_FL.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_IL.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_NJ.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_IN.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_WI.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_AL.sas;


