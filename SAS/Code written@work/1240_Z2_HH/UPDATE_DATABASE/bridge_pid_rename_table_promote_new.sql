set maintenance_work_mem = '48GB';

drop table if exists bridge_pid_table;

alter table bridge_pid_table_:fdate rename to bridge_pid_table;
