* 010_initalize_newmover.sas;
* Copies existing data for new moversfrom real time SQL Server to AWS PostgreSQL database;
* 06/2015 MWM;

%include "./.sql_includes.inc";

%let user=mmattingly;
%let pw=BearDown_15;
%let server=216.157.38.64;

%macro moveit(rt_table_name=,aws_table_name=);

  * GET CURRENT BUZZBOARD DATA FROM REAL TIME SERVER;
  data &rt_table_name;
     set nmsql.&rt_table_name;
  run;

  data cac_prod.&aws_table_name;
    set &rt_table_name;
  run;
  
  proc datasets lib=work;
     delete &rt_table_name;
  quit;

%put "Yeehah";

%mend moveit;

%moveit(rt_table_name=COGENSIA_MOVERS,
        aws_table_name=COGENSIA_MOVERS);
        
endsas;