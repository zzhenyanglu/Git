%macro deciles(datain=,score_var=,fmtprefix=);

proc univariate data=&datain;
  var &score_var;
   output out=tmp_&score_var pctlpts=100 90 80 70 60 50 40 30 20 10 pctlpre=&fmtprefix;
   * WPS cannot execute the line below, awesom;
   *pctlpre=&fmtprefix pctlpts=100 to 10 by -10;
run;

proc print data=tmp_&score_var;
run;

data tmp_&fmtprefix;
   set tmp_&score_var;
   drop &fmtprefix.: d; 
   array &fmtprefix._decile(*) &fmtprefix.:;
   fmtname="DECL_&fmtprefix";
   do d=1 to 10;
    
   	  start=.;
   	    
          if d=1 then do;
         	 start=&fmtprefix._decile(d+1);
     	     end=.;
     	     sexcl = ' ';
     	  end;
   
          if 1< d <10 then do; 
     	     start = &fmtprefix._decile(d+1); 
     	     end=&fmtprefix._decile(d);
             sexcl = 'Y'; 
          end; 
   
     	  if d=10 then do;
     	     end=&fmtprefix._decile(d);
             sexcl = 'Y'; 
     	  end;
   
          select (d); 
             when ( 1) hlo = 'H'; *** HIGH;
             when (10) hlo = 'L'; *** LOW;
             otherwise hlo = ' '; 
          end;
               
          label = put(d,z2.);
          modprefx="&fmtprefix.";
   
     	  if end > start or hlo='H' then output;
   
    end; 
         
run;

     %*** DECLARE FORMAT FOR CURRENT DDECILES;
     proc format cntlin=tmp_&fmtprefix;
     run;
      
     %*** PRINT THE FORMATS FOR VALIDATION;
     proc format;
       select DECL:;
     run;

	 data &datain;
	   set &datain;
	   decile_&score_var=put(&score_var,DECL_&fmtprefix..);
     run;

%mend deciles;
