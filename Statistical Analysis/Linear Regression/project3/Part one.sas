data flour;
input Weight Nbags; 
title Flour;

datalines;
 5050   100
10249   205
20000   450
 7420   150
24685   500
10206   200
 7325   150
 4958   100
 7162   150
24000   500
 4900   100
14501   300
28000   600
17002   400
16100   400
;

proc print data = flour;
title Flour ;

proc means ;
var Weight Nbags;

proc reg corr data=flour;

model Nbags = Weight / noint;
plot Nbags*Weight r.*p. r.*nqq.;

proc reg;
model Nbags = Weight;
plot Nbags*Weight r.*p. r.*nqq.;
;



run;
quit;
