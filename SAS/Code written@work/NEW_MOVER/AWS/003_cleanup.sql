/* put QC table into a csv file to be sent out with email */
\copy newmover_update_qc to '/project/CACDIRECT/CODE/PROD/NEW_MOVER/AWS/LOGS/qc_newmover_update_.csv' delimiter ',' csv header null ' ';

/* CLEAN UP */
drop table if exists newmovers_list;
drop table if exists cogensia_movers_vs;
drop table if exists newmover_update_qc;



