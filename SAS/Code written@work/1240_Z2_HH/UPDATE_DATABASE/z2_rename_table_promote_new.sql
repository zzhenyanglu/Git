set maintenance_work_mem = '48GB';

drop table if exists z2_ahi;

alter table z2_ahi_:fdate rename to z2_ahi;
