**************************************************************************;
%include '/project/VIASAT/CODE/KDD/INC/libnames.inc';
libname samp '/project/CACDIRECT/DATA/SAMPLES/A/';
options mprint mlogic ps=1000 nocenter compress=yes;
**************************************************************************;

proc freq data=samp.base_samp_1pct;
   tables CAC_IND1_BIRTHDATE_ENH /list missing;
run;


