#!/bin/sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_LA.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_OR.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_AR.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_ME.sas;
wps -work /project18/SASWORK -nodms 030_score_silh_${update_year}q${update_qtr}_DE.sas;

