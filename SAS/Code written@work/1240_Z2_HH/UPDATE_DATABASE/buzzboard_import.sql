/*
drop table if exists buzzboard_zip_level_bak;
drop table if exists buzzboard_cen_us_avg_bak;
drop table if exists BUZZBOARD_CEN_LEVEL_bak;

CREATE TABLE buzzboard_zip_level_bak(like buzzboard_zip_level);
INSERT INTO buzzboard_zip_level_bak select * from buzzboard_zip_level;

CREATE TABLE buzzboard_cen_us_avg_bak(like buzzboard_cen_us_avg);
INSERT INTO buzzboard_cen_us_avg_bak select * from buzzboard_cen_us_avg;

CREATE TABLE BUZZBOARD_CEN_LEVEL_bak(like BUZZBOARD_CEN_LEVEL);
INSERT INTO BUZZBOARD_CEN_LEVEL_bak select * from BUZZBOARD_CEN_LEVEL;

drop table if exists buzzboard_zip_level;
drop table if exists buzzboard_cen_us_avg;
drop table if exists BUZZBOARD_CEN_LEVEL;
*/


drop table if exists buzzboard_cen_us_avg_:fdate CASCADE;
drop table if exists BUZZBOARD_ZIP_LEVEL_:fdate CASCADE;
drop table if exists BUZZBOARD_CEN_LEVEL_:fdate CASCADE;

CREATE TABLE buzzboard_cen_us_avg_:fdate 
(
avg_buy_style_group_3   	numeric,
avg_buy_style_group_4    	numeric,
avg_buy_style_group_5    	numeric,
avg_cac_silh_dig_inf    	numeric,
avg_cac_silh_soc_inf     	numeric,
avg_cac_silh_social     	numeric,
avg_lat                 	numeric,
avg_lon                  	numeric,
avg_median_age	                numeric,
avg_median_income         	numeric,
avg_owner_occupied      	numeric,
avg_s1                   	numeric,
avg_s2                   	numeric,
avg_s3                         	numeric,
avg_s4                  	numeric,
avg_s5	                        numeric,
avg_s6                        	numeric,
avg_s7	                        numeric,
avg_s8                   	numeric,
avg_s9	                        numeric,
avg_s10	                        numeric,
avg_s11                     	numeric,
avg_s12                  	numeric,
avg_s13                 	numeric,
avg_s14                   	numeric,
avg_s15                    	numeric,
avg_s16                  	numeric,
avg_s17                  	numeric,
avg_s18                  	numeric,
avg_s19                  	numeric,
avg_s20                  	numeric,
avg_s21	                        numeric,
avg_s22                  	numeric,
avg_s23                  	numeric,
avg_s24                  	numeric,
avg_s25                  	numeric,
avg_s26                  	numeric,
avg_s27                  	numeric,
avg_s28                  	numeric,
avg_s29                         numeric,
avg_s30                  	numeric,
avg_s31	                        numeric,
avg_s32	                        numeric,
avg_s33	                        numeric,
avg_s34	                        numeric,
avg_s35	                        numeric,
avg_s36	                      	numeric,
avg_s37	                      	numeric,
avg_s38	                      	numeric,
avg_s39	                      	numeric,
avg_s40	                      	numeric,
avg_s41	                      	numeric,
avg_s42	                      	numeric,
avg_s43	                      	numeric,
avg_s44		                numeric,
avg_s45		                numeric,
avg_s46	                      	numeric,
avg_s47	                      	numeric,
avg_s48	                      	numeric,
avg_s49		                numeric,
avg_s50	                      	numeric,
avg_s51	                      	numeric,
avg_s52	                      	numeric,
avg_s53	                      	numeric,
avg_s54	                      	numeric,
avg_s55	                      	numeric,
avg_s56	                      	numeric,
avg_s57	                      	numeric,
avg_s58	                      	numeric,
avg_s59	                      	numeric,
avg_with_children           	numeric,
matching_field	                integer
);



CREATE TABLE BUZZBOARD_ZIP_LEVEL_:fdate 
(	
CAC_ADDR_ZIP4	                 varchar(4),
CEN_COUNT_FAM	               	 numeric,
CEN_COUNT_HH		         numeric,
CEN_COUNT_POP		      	 numeric,
avg_cac_silh_dig_inf	         numeric,
avg_cac_silh_soc_inf	    	 numeric,
avg_cac_silh_social	     	 numeric,
avg_lat	                         numeric,
avg_lon	                         numeric,
cac_silh_buy_style_group_3     	 numeric,
cac_silh_buy_style_group_4	 numeric,
cac_silh_buy_style_group_5	 numeric,
counts_hh	                 numeric,
matching_field	                 varchar(5),
median_age	                 numeric,
median_income	                 numeric,
owner_occupied	                 numeric,
silh_1                           numeric,
silh_2	                         numeric,
silh_3	                         numeric,
silh_4	                         numeric,
silh_5	                         numeric,
silh_6	                         numeric,
silh_7	                         numeric,
silh_8                  	 numeric,
silh_9	                         numeric,
silh_10	                         numeric,
silh_11	                         numeric,
silh_12           	         numeric,
silh_13	                         numeric,
silh_14	                         numeric,
silh_15	                         numeric,
silh_16	                         numeric,
silh_17	                         numeric,
silh_18	                         numeric,
silh_19	                         numeric,
silh_20	                         numeric,
silh_21	                         numeric,
silh_22	                         numeric,
silh_23	                         numeric,
silh_24	                         numeric,
silh_25	                         numeric,
silh_26	                         numeric,
silh_27	                         numeric,
silh_28	                         numeric,
silh_29	                         numeric,
silh_30	                         numeric,
silh_31	                         numeric,
silh_32	                         numeric,
silh_33	                         numeric,
silh_34	                         numeric,
silh_35	                         numeric,
silh_36	                         numeric,
silh_37	                         numeric,
silh_38	                         numeric,
silh_39	                         numeric,
silh_40	                         numeric,
silh_41	                         numeric,
silh_42	                         numeric,
silh_43	                         numeric,
silh_44	                         numeric,
silh_45	                         numeric,
silh_46	                         numeric,
silh_47	                         numeric,
silh_48	                         numeric,
silh_49	                         numeric,
silh_50	                         numeric,
silh_51	                         numeric,
silh_52	                         numeric,
silh_53	                         numeric,
silh_54	                         numeric,
silh_55	                         numeric,
silh_56 	                 numeric,
silh_57	                         numeric,
silh_58	                         numeric,
silh_59	                         numeric,
state	                         varchar(2),
sum_cac_silh_dig_inf	         numeric,
sum_cac_silh_soc_inf	         numeric,
sum_cac_silh_social	         numeric,
with_children	                 numeric
);


CREATE TABLE BUZZBOARD_CEN_LEVEL_:fdate 
(	
CEN_COUNT_FAM	                  numeric,
CEN_COUNT_HH	                  numeric,
CEN_COUNT_POP	                  numeric,
avg_cac_silh_dig_inf	          numeric,
avg_cac_silh_soc_inf           	  numeric,
avg_cac_silh_social	          numeric,
avg_lat	                          numeric,
avg_lon	                          numeric,
cac_silh_buy_style_group_3	  numeric,
cac_silh_buy_style_group_4 	  numeric,
cac_silh_buy_style_group_5  	  numeric,
counts_hh	                  numeric,
matching_field	                  varchar(32),
median_age	                  numeric,
median_income 	                  numeric,
owner_occupied	                  numeric,
silh_1	                          numeric,
silh_2	                          numeric,
silh_3	                          numeric,
silh_4                            numeric,
silh_5	                          numeric,
silh_6                    	  numeric,
silh_7	                          numeric,
silh_8	                          numeric,
silh_9	                          numeric,
silh_10	                          numeric,
silh_11	                          numeric,
silh_12	                          numeric,
silh_13	                          numeric,
silh_14	                          numeric,
silh_15	                          numeric,
silh_16	                          numeric,
silh_17	                          numeric,
silh_18	                          numeric,
silh_19	                          numeric,
silh_20	                          numeric,
silh_21	                          numeric,
silh_22	                          numeric,
silh_23	                          numeric,
silh_24	                          numeric,
silh_25	                          numeric,
silh_26	                          numeric,
silh_27	                          numeric,
silh_28	                          numeric,
silh_29	                          numeric,
silh_30	                          numeric,
silh_31	                          numeric,
silh_32	                          numeric,
silh_33	                          numeric,
silh_34	                          numeric,
silh_35	                          numeric,
silh_36	                          numeric,
silh_37	                          numeric,
silh_38	                          numeric,
silh_39	                          numeric,
silh_40	                          numeric,
silh_41	                          numeric,
silh_42	                          numeric,
silh_43	                          numeric,
silh_44	                          numeric,
silh_45	                          numeric,
silh_46	                          numeric,
silh_47	                          numeric,
silh_48	                          numeric,
silh_49	                          numeric,
silh_50	                          numeric,
silh_51	                          numeric,
silh_52	                          numeric,
silh_53	                          numeric,
silh_54                           numeric,
silh_55	                          numeric,
silh_56	                          numeric,
silh_57	                          numeric,
silh_58	                          numeric,
silh_59	                          numeric,
state	                          varchar(2),
sum_cac_silh_dig_inf	          numeric,
sum_cac_silh_soc_inf	          numeric,
sum_cac_silh_social	          numeric,
uni_matching_field	          varchar(34),
with_children	                  numeric
);



set myvars.qdate = :'fdate';
set myvars.datapath = :'cidatapath';

\t
\o 'buzzboard_cen_us_avg_copy.sql'

select format(
    $$\copy buzzboard_cen_us_avg_%s from '/project/CACDIRECT/%s/EXPORT/BUZZBOARD/buzzboard_cen_us_avg.csv' csv delimiter ',' null as '' $$
    , current_setting('myvars.qdate'), current_setting('myvars.datapath')
);

\o
\i 'buzzboard_cen_us_avg_copy.sql'



\o 'buzzboard_zip_level_copy.sql'

select format(
    $$\copy BUZZBOARD_ZIP_LEVEL_%s from '/project/CACDIRECT/%s/EXPORT/BUZZBOARD/buzzboard_zip_level.csv' csv delimiter ',' null as '' $$
    , current_setting('myvars.qdate'), current_setting('myvars.datapath')
);

\o
\i 'buzzboard_zip_level_copy.sql'



set myvars.qdate = :'fdate';
set myvars.datapath = :'cidatapath';

\o 'buzzboard_cen_level_copy.sql'

select format(
    $$\copy BUZZBOARD_CEN_LEVEL_%s from '/project/CACDIRECT/%s/EXPORT/BUZZBOARD/buzzboard_cen_level.csv' csv delimiter ',' null as '' $$
    , current_setting('myvars.qdate'), current_setting('myvars.datapath')
);

\o
\i 'buzzboard_cen_level_copy.sql'


vacuum analyze buzzboard_cen_us_avg_:fdate;
vacuum analyze BUZZBOARD_CEN_LEVEL_:fdate;
vacuum analyze buzzboard_zip_level_:fdate;
