#!/bin/sh

# Update year YYYY
update_year=$1
# Update month abbrev
update_qtr=$2

wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_CA.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_OH.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_NC.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_MA.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_OK.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_KS.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_RI.sas;
wps -work /project18/SASWORK -nodms 210_intelliscore_${update_year}q${update_qtr}_VT.sas;
