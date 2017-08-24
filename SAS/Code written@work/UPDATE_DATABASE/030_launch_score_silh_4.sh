#!/bin/sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_NY.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_MI.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_VA.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_TN.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_AZ.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_MD.sas;

