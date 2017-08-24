\c cac_prod

set maintenance_work_mem = '24GB';

drop table if exists bridge_pid_table_:fdate;

create table bridge_pid_table_:fdate (
   cac_hh_pid varchar(30),
   cac_bridge_md5email_id text,
   chosen_cac_ind_number smallint,	
   chosen_cac_ind_gender smallint,	
   chosen_cac_ind_name text,
   chosen_cac_ind_mi text,
   chosen_cac_ind_last text,
   chosen_spedis_score smallint,
   chosen_match_level smallint,
   chosen_first_x_of_x_flag boolean
   );

set myvars.qdate = :'fdate';
set myvars.datapath = :'cidatapath';


/*
\copy bridge_pid_table_27jul2015 from '/project/CACDIRECT/DATA/DEVELOPMENT/1110_BRIDGE_UPDATE/TESTING/bridge_pid_table_head.csv' csv header delimiter ',' null as '' ;
*/

\o 'bridge_pid_copy.sql'

select format(
    $$\copy bridge_pid_table_%s from '/project/CACDIRECT/%s/EXPORT/BRIDGE/bridge_pid_table.csv' csv header delimiter ',' null as '' $$
    , current_setting('myvars.qdate'), current_setting('myvars.datapath')
);

\o
\i 'bridge_pid_copy.sql'

