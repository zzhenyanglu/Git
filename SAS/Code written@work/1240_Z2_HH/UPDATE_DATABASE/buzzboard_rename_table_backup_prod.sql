set maintenance_work_mem = '48GB';

drop table if exists old_buzzboard_cen_us_avg;
drop table if exists OLD_BUZZBOARD_ZIP_LEVEL;
drop table if exists OLD_BUZZBOARD_CEN_LEVEL;

alter table buzzboard_cen_us_avg rename to old_buzzboard_cen_us_avg;
alter table BUZZBOARD_ZIP_LEVEL rename to OLD_BUZZBOARD_ZIP_LEVEL;
alter table BUZZBOARD_CEN_LEVEL rename to OLD_BUZZBOARD_CEN_LEVEL;

