set maintenance_work_mem = '48GB';

drop table if exists old_z2_ahi;

alter table z2_ahi rename to old_z2_ahi;
