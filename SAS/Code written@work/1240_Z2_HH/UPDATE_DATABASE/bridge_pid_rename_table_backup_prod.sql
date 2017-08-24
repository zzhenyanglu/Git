set maintenance_work_mem = '48GB';

drop table if exists old_bridge_pid_table;

alter table bridge_pid_table rename to old_bridge_pid_table;
