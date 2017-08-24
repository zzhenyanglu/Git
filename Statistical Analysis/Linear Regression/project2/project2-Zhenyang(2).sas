data paper;
input White Yellow;
datalines;

0.103 0.092
0.103 0.099
0.098 0.110
0.101 0.118
0.101 0.103
0.094 0.101
0.096 0.100
0.095 0.102
0.115 0.111
0.011 0.014
0.190 0.184
0.079 0.089
0.094 0.097
0.010 0.012
0.098 0.095
0.097 0.133
0.101 0.102
0.108 0.100
0.097 0.099
0.099 0.104
0.099 0.103
0.095 0.102
0.100 0.103
0.094 0.105
0.104 0.100 
0.098 0.101
0.103 0.109
0.095 0.100
0.096 0.101
;
data subset;
set paper;
keep White Yellow diff;
if White > 0.05;
if Yellow > 0.05;
diff = White - Yellow;


proc print data = subset; 

label White = 'Thickness of white paper'
      Yellow = 'Thickness of yellow paper';

proc univariate plots;
   var White;
   probplot White;
 
proc univariate plots;
   var Yellow;
   probplot Yellow;
 
proc ttest h0=0;
   paired White * Yellow;

data reformat;
set subset;
keep Color Thickness;
brand = 'WT';
thickness = White;
output;

brand = 'YW';
thickness = Yellow;
output;

proc print data = reformat;
 
proc ttest;
   class brand;
   var thickness;

run;
