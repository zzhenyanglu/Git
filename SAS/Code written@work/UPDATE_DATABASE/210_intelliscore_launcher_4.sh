#!/bin/sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_NY.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_MI.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_VA.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_TN.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_AZ.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_MD.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_CO.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_SC.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_CT.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_MS.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_NH.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_SD.sas;
