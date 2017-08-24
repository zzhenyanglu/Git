\c cac_prod

set maintenance_work_mem = '24GB';

drop table if exists z2_ahi_:fdate CASCADE;

create table z2_ahi_:fdate (
   zip_plus_2 char(7) primary key not null,
   model_score float
   );


set myvars.qdate = :'fdate';
set myvars.datapath = :'cidatapath';

\t
\o 'temp.sql'

select format(
    $$\copy z2_ahi_%s from '/project/CACDIRECT/%s/z2_modelscore.csv' csv header delimiter ',' null as '' $$
    , current_setting('myvars.qdate'), current_setting('myvars.datapath')
);

\o
\i 'temp.sql'

