set maintenance_work_mem = '48GB';

drop table if exists samp_hh cascade;
drop table if exists samp_hh_partition_1;
drop table if exists samp_hh_partition_2;
drop table if exists samp_hh_partition_3;
drop table if exists samp_hh_partition_4;
drop table if exists samp_hh_partition_5;
drop table if exists samp_hh_partition_6;
drop table if exists samp_hh_partition_7;
drop table if exists samp_hh_partition_8;
drop table if exists samp_hh_partition_9;
drop table if exists samp_hh_partition_10;
drop table if exists samp_hh_partition_11;
drop table if exists samp_hh_partition_12;
drop table if exists samp_hh_partition_13;
drop table if exists samp_hh_partition_14;
drop table if exists samp_hh_partition_15;
drop table if exists samp_hh_partition_16;
drop table if exists samp_hh_partition_17;
drop table if exists samp_hh_partition_18;
drop table if exists samp_hh_partition_19;
drop table if exists samp_hh_partition_20;
drop table if exists samp_hh_partition_21;
drop table if exists samp_hh_partition_22;
drop table if exists samp_hh_partition_23;
drop table if exists samp_hh_partition_24;
drop table if exists samp_hh_partition_25;
drop table if exists samp_hh_partition_26;
drop table if exists samp_hh_partition_27;
drop table if exists samp_hh_partition_28;
drop table if exists samp_hh_partition_29;
drop table if exists samp_hh_partition_30;
drop table if exists samp_hh_partition_31;
drop table if exists samp_hh_partition_32;
drop table if exists samp_hh_partition_33;
drop table if exists samp_hh_partition_34;
drop table if exists samp_hh_partition_35;
drop table if exists samp_hh_partition_36;
drop table if exists samp_hh_partition_37;
drop table if exists samp_hh_partition_38;
drop table if exists samp_hh_partition_39;
drop table if exists samp_hh_partition_40;
drop table if exists samp_hh_partition_41;
drop table if exists samp_hh_partition_42;
drop table if exists samp_hh_partition_43;
drop table if exists samp_hh_partition_44;
drop table if exists samp_hh_partition_45;
drop table if exists samp_hh_partition_46;
drop table if exists samp_hh_partition_47;
drop table if exists samp_hh_partition_48;
drop table if exists samp_hh_partition_49;
drop table if exists samp_hh_partition_50;
drop table if exists samp_hh_partition_51;


alter table samp_hh_:fdate rename to samp_hh;
alter table samp_hh_partition_1_:fdate rename to samp_hh_partition_1;
alter table samp_hh_partition_2_:fdate rename to samp_hh_partition_2;
alter table samp_hh_partition_3_:fdate rename to samp_hh_partition_3;
alter table samp_hh_partition_4_:fdate rename to samp_hh_partition_4;
alter table samp_hh_partition_5_:fdate rename to samp_hh_partition_5;
alter table samp_hh_partition_6_:fdate rename to samp_hh_partition_6;
alter table samp_hh_partition_7_:fdate rename to samp_hh_partition_7;
alter table samp_hh_partition_8_:fdate rename to samp_hh_partition_8;
alter table samp_hh_partition_9_:fdate rename to samp_hh_partition_9;
alter table samp_hh_partition_10_:fdate rename to samp_hh_partition_10;
alter table samp_hh_partition_11_:fdate rename to samp_hh_partition_11;
alter table samp_hh_partition_12_:fdate rename to samp_hh_partition_12;
alter table samp_hh_partition_13_:fdate rename to samp_hh_partition_13;
alter table samp_hh_partition_14_:fdate rename to samp_hh_partition_14;
alter table samp_hh_partition_15_:fdate rename to samp_hh_partition_15;
alter table samp_hh_partition_16_:fdate rename to samp_hh_partition_16;
alter table samp_hh_partition_17_:fdate rename to samp_hh_partition_17;
alter table samp_hh_partition_18_:fdate rename to samp_hh_partition_18;
alter table samp_hh_partition_19_:fdate rename to samp_hh_partition_19;
alter table samp_hh_partition_20_:fdate rename to samp_hh_partition_20;
alter table samp_hh_partition_21_:fdate rename to samp_hh_partition_21;
alter table samp_hh_partition_22_:fdate rename to samp_hh_partition_22;
alter table samp_hh_partition_23_:fdate rename to samp_hh_partition_23;
alter table samp_hh_partition_24_:fdate rename to samp_hh_partition_24;
alter table samp_hh_partition_25_:fdate rename to samp_hh_partition_25;
alter table samp_hh_partition_26_:fdate rename to samp_hh_partition_26;
alter table samp_hh_partition_27_:fdate rename to samp_hh_partition_27;
alter table samp_hh_partition_28_:fdate rename to samp_hh_partition_28;
alter table samp_hh_partition_29_:fdate rename to samp_hh_partition_29;
alter table samp_hh_partition_30_:fdate rename to samp_hh_partition_30;
alter table samp_hh_partition_31_:fdate rename to samp_hh_partition_31;
alter table samp_hh_partition_32_:fdate rename to samp_hh_partition_32;
alter table samp_hh_partition_33_:fdate rename to samp_hh_partition_33;
alter table samp_hh_partition_34_:fdate rename to samp_hh_partition_34;
alter table samp_hh_partition_35_:fdate rename to samp_hh_partition_35;
alter table samp_hh_partition_36_:fdate rename to samp_hh_partition_36;
alter table samp_hh_partition_37_:fdate rename to samp_hh_partition_37;
alter table samp_hh_partition_38_:fdate rename to samp_hh_partition_38;
alter table samp_hh_partition_39_:fdate rename to samp_hh_partition_39;
alter table samp_hh_partition_40_:fdate rename to samp_hh_partition_40;
alter table samp_hh_partition_41_:fdate rename to samp_hh_partition_41;
alter table samp_hh_partition_42_:fdate rename to samp_hh_partition_42;
alter table samp_hh_partition_43_:fdate rename to samp_hh_partition_43;
alter table samp_hh_partition_44_:fdate rename to samp_hh_partition_44;
alter table samp_hh_partition_45_:fdate rename to samp_hh_partition_45;
alter table samp_hh_partition_46_:fdate rename to samp_hh_partition_46;
alter table samp_hh_partition_47_:fdate rename to samp_hh_partition_47;
alter table samp_hh_partition_48_:fdate rename to samp_hh_partition_48;
alter table samp_hh_partition_49_:fdate rename to samp_hh_partition_49;
alter table samp_hh_partition_50_:fdate rename to samp_hh_partition_50;
alter table samp_hh_partition_51_:fdate rename to samp_hh_partition_51;