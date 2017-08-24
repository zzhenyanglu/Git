set maintenance_work_mem = '48GB';

drop table if exists buzzboard_cen_us_avg;
drop table if exists BUZZBOARD_ZIP_LEVEL;
drop table if exists BUZZBOARD_CEN_LEVEL;

alter table buzzboard_cen_us_avg_:fdate rename to buzzboard_cen_us_avg;
alter table BUZZBOARD_ZIP_LEVEL_:fdate rename to BUZZBOARD_ZIP_LEVEL;
alter table BUZZBOARD_CEN_LEVEL_:fdate rename to BUZZBOARD_CEN_LEVEL;

