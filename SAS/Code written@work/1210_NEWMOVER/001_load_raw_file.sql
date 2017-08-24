/* BACKUP cogensia_movers */
DROP TABLE IF EXISTS cogensia_movers_bak;

CREATE TABLE cogensia_movers_bak(like cogensia_movers);

INSERT INTO cogensia_movers_bak select * from cogensia_movers;


/* CREATE DATA TABLE TO CONTAIN QC INFO */

drop table if exists newmover_update_qc;

create table newmover_update_qc
(
description	         varchar(60),
counts                   numeric(8),
or_date                  date                     
);

/* QC */
insert into newmover_update_qc values('Min File Date before new data was read in',null,(select min(cac_nm_file_dt) from cogensia_movers));
insert into newmover_update_qc values('Number of observations before new data was read in',(SELECT COUNT(*) from cogensia_movers),null);
insert into newmover_update_qc values('Max id before data was read in',(SELECT max(cac_nm_id) from cogensia_movers),null);


/* CREATE DATA TABLE TO CONTAIN THE RAW DATA */

drop table if exists newmovers_list;

create table newmovers_list 
(
raw_line	         varchar(200)
);


/* LOAD THE NEW MOVER ;OST FOR THE CURRENT WEEK */
\copy newmovers_list from '/project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/New_Mover_Install_WE.txt';

alter table newmovers_list add column CAC_NM_CONTRACTED_NAME	          varchar(40);
alter table newmovers_list add column CAC_NM_CONTRACTED_ADDR           varchar(40);
alter table newmovers_list add column CAC_NM_CITY	                  varchar(13);
alter table newmovers_list add column cac_nm_fips_state_code           varchar(2);
alter table newmovers_list add column cac_nm_zip_code                  varchar(5);
alter table newmovers_list add column cac_nm_zipplus_4                 varchar(4);
alter table newmovers_list add column cac_nm_delivery_point_code       varchar(3);
alter table newmovers_list add column cac_nm_state_abbreviation        varchar(2);
alter table newmovers_list add column cac_nm_carrier_route             varchar(4);
alter table newmovers_list add column cac_nm_distance_of_move          varchar(4);
alter table newmovers_list add column cac_nm_dpv_flag                  varchar(1);
alter table newmovers_list add column cac_nm_hh_move_date              varchar(6);
alter table newmovers_list add column cac_nm_file_dt_raw               varchar(8);
alter table newmovers_list add column cac_nm_file_dt                   date;
alter table newmovers_list add column cac_nm_indiv_two_year_age_band   varchar(6);
alter table newmovers_list add column cac_nm_gender                    varchar(1);
alter table newmovers_list add column cac_nm_marital_status            varchar(1);
alter table newmovers_list add column cac_nm_marital_status_within_hh  varchar(1);
alter table newmovers_list add column cac_nm_number_of_adults_in_hh    varchar(2);
alter table newmovers_list add column cac_nm_number_of_kids_in_hh      varchar(1);
alter table newmovers_list add column cac_nm_pet_owner                 varchar(1);
alter table newmovers_list add column cac_nm_dwelling_addr_type        varchar(1);
alter table newmovers_list add column cac_nm_cen_home_value            varchar(3);
alter table newmovers_list add column cac_nm_cen_inc_code_new_addr     varchar(3);
alter table newmovers_list add column cac_nm_cen_inc_code_new_addr_r   varchar(3);
alter table newmovers_list add column cac_nm_cen_inc_code_prev_addr    varchar(3);
alter table newmovers_list add column cac_nm_cen_inc_code_prev_addr_r  varchar(3);
alter table newmovers_list add column cac_nm_county_code               varchar(3);
alter table newmovers_list add column cac_nm_county_code_old_addr      varchar(3);
alter table newmovers_list add column cac_nm_hh_age                    varchar(2);
alter table newmovers_list add column cac_nm_target_valuescore         varchar(3);
alter table newmovers_list add column cac_nm_target_inc                varchar(1);
alter table newmovers_list add column cac_nm_homeowner_renter_code     varchar(1);
alter table newmovers_list add column CAC_NM_IMPORT_DATE               date;    
alter table newmovers_list add column cac_nm_area_code_with_supp_appl  varchar(3);
alter table newmovers_list add column cac_nm_telephone_with_supp_appl  varchar(7);

/* CREATE FIELDS FOR NEW MOVERS DATA TABLE */
update newmovers_list set CAC_NM_CONTRACTED_NAME             = trim(both ' ' from substring(raw_line from 1 for 40));
update newmovers_list set CAC_NM_CONTRACTED_ADDR             = trim(both ' ' from substring(raw_line from 41 for 40));
update newmovers_list set CAC_NM_CITY                        = trim(both ' ' from substring(raw_line from 81 for 13));
update newmovers_list set cac_nm_fips_state_code             = trim(both ' ' from substring(raw_line from 94 for 2));
update newmovers_list set cac_nm_zip_code                    = trim(both ' ' from substring(raw_line from 96 for 5));
update newmovers_list set cac_nm_zipplus_4                   = trim(both ' ' from substring(raw_line from 101 for 4));
update newmovers_list set cac_nm_delivery_point_code         = trim(both ' ' from substring(raw_line from 105 for 3));
update newmovers_list set cac_nm_state_abbreviation          = trim(both ' ' from substring(raw_line from 108 for 2));
update newmovers_list set cac_nm_carrier_route               = trim(both ' ' from substring(raw_line from 110 for 4));
update newmovers_list set cac_nm_distance_of_move	        = trim(both ' ' from substring(raw_line from 114 for 4));
update newmovers_list set cac_nm_dpv_flag                    = trim(both ' ' from substring(raw_line from 118 for 1));
update newmovers_list set cac_nm_hh_move_date                = trim(both ' ' from substring(raw_line from 119 for 6));
update newmovers_list set cac_nm_file_dt_raw                 = trim(both ' ' from substring(raw_line from 125 for 8));
update newmovers_list set cac_nm_file_dt                     = to_date(cac_nm_file_dt_raw,'yyyymmdd');
update newmovers_list set cac_nm_indiv_two_year_age_band     = trim(both ' ' from substring(raw_line from 133 for 6));
update newmovers_list set cac_nm_gender                      = trim(both ' ' from substring(raw_line from 139 for 1));
update newmovers_list set cac_nm_marital_status              = trim(both ' ' from substring(raw_line from 140 for 1));
update newmovers_list set cac_nm_marital_status_within_hh    = trim(both ' ' from substring(raw_line from 141 for 1));
update newmovers_list set cac_nm_number_of_adults_in_hh      = trim(both ' ' from substring(raw_line from 142 for 2));
update newmovers_list set cac_nm_number_of_kids_in_hh        = trim(both ' ' from substring(raw_line from 144 for 1));
update newmovers_list set cac_nm_pet_owner                   = trim(both ' ' from substring(raw_line from 145 for 1));
update newmovers_list set cac_nm_dwelling_addr_type          = trim(both ' ' from substring(raw_line from 146 for 1));
update newmovers_list set cac_nm_cen_home_value              = trim(both ' ' from substring(raw_line from 147 for 3));
update newmovers_list set cac_nm_cen_inc_code_new_addr       = trim(both ' ' from substring(raw_line from 150 for 3));
update newmovers_list set cac_nm_cen_inc_code_new_addr_r     = trim(both ' ' from substring(raw_line from 153 for 3));
update newmovers_list set cac_nm_cen_inc_code_prev_addr      = trim(both ' ' from substring(raw_line from 156 for 3));
update newmovers_list set cac_nm_cen_inc_code_prev_addr_r    = trim(both ' ' from substring(raw_line from 159 for 3));
update newmovers_list set cac_nm_county_code                 = trim(both ' ' from substring(raw_line from 162 for 3));
update newmovers_list set cac_nm_county_code_old_addr        = trim(both ' ' from substring(raw_line from 165 for 3));
update newmovers_list set cac_nm_hh_age                      = trim(both ' ' from substring(raw_line from 168 for 2));
update newmovers_list set cac_nm_target_valuescore           = trim(both ' ' from substring(raw_line from 170 for 3));
update newmovers_list set cac_nm_target_inc                  = trim(both ' ' from substring(raw_line from 173 for 1));
update newmovers_list set cac_nm_homeowner_renter_code       = trim(both ' ' from substring(raw_line from 174 for 1));
update newmovers_list set CAC_NM_IMPORT_DATE                 = current_date;
update newmovers_list set cac_nm_area_code_with_supp_appl    = trim(both ' ' from substring(raw_line from 175 for 3));
update newmovers_list set cac_nm_telephone_with_supp_appl    = trim(both ' ' from substring(raw_line from 178 for 7));

/* DELETE STAGING FIELDS */
alter table newmovers_list drop column raw_line;
alter table newmovers_list drop column cac_nm_file_dt_raw;

/* QC */
insert into newmover_update_qc values('Number of observations new observations imported',(select count(*) from newmovers_list),null);

/* STACK COGENSIA_MOVERS AND newmovers_list UPDATE TOGETHER */
insert into cogensia_movers (cac_nm_contracted_name,cac_nm_contracted_addr,cac_nm_city,cac_nm_fips_state_code,cac_nm_zip_code,cac_nm_zipplus_4,cac_nm_delivery_point_code,cac_nm_state_abbreviation,cac_nm_carrier_route,
                             cac_nm_distance_of_move,cac_nm_dpv_flag,cac_nm_hh_move_date,cac_nm_file_dt,cac_nm_indiv_two_year_age_band,cac_nm_gender,cac_nm_marital_status,cac_nm_marital_status_within_hh,
                             cac_nm_number_of_adults_in_hh,cac_nm_number_of_kids_in_hh,cac_nm_pet_owner,cac_nm_dwelling_addr_type,cac_nm_cen_home_value,cac_nm_cen_inc_code_new_addr,cac_nm_cen_inc_code_new_addr_r,
                             cac_nm_cen_inc_code_prev_addr,cac_nm_cen_inc_code_prev_addr_r,cac_nm_county_code,cac_nm_county_code_old_addr,cac_nm_hh_age,cac_nm_target_valuescore,cac_nm_target_inc,cac_nm_homeowner_renter_code,
                             cac_nm_import_date,cac_nm_area_code_with_supp_appl,cac_nm_telephone_with_supp_appl,cac_nm_id) 
select cac_nm_contracted_name,cac_nm_contracted_addr,cac_nm_city,cac_nm_fips_state_code,cac_nm_zip_code,cac_nm_zipplus_4,cac_nm_delivery_point_code,cac_nm_state_abbreviation,cac_nm_carrier_route,cac_nm_distance_of_move,
       cac_nm_dpv_flag,cac_nm_hh_move_date,cac_nm_file_dt,cac_nm_indiv_two_year_age_band,cac_nm_gender,cac_nm_marital_status,cac_nm_marital_status_within_hh,cac_nm_number_of_adults_in_hh,cac_nm_number_of_kids_in_hh,
       cac_nm_pet_owner,cac_nm_dwelling_addr_type,cac_nm_cen_home_value,cac_nm_cen_inc_code_new_addr,cac_nm_cen_inc_code_new_addr_r,cac_nm_cen_inc_code_prev_addr,cac_nm_cen_inc_code_prev_addr_r,cac_nm_county_code,
       cac_nm_county_code_old_addr,cac_nm_hh_age,cac_nm_target_valuescore,cac_nm_target_inc,cac_nm_homeowner_renter_code,cac_nm_import_date,cac_nm_area_code_with_supp_appl,cac_nm_telephone_with_supp_appl,
       nextval('cac_nm_sequence') 
from newmovers_list;

/* QC: HOW MANY OBSOLETE RECORDS WE HAVE FOR THE CURRENT UPDATE */
insert into newmover_update_qc values('number of observations deleted due to bad dates',(SELECT COUNT(*) from cogensia_movers where (current_date - cac_nm_file_dt) > 180  ),null);

/* DELETE OBSOLETE RECORDS */
delete from cogensia_movers where (current_date - cac_nm_file_dt) > 180  ;

/* QC */
insert into newmover_update_qc values('Number of observations left after deleted dates',(SELECT COUNT(*) from cogensia_movers),null);

/* DEDUP BY CAC_NM_CONTRACTED_NAME AND CAC_NM_CONTRACTED_ADDR  */
create table cogensia_movers_stage(like cogensia_movers);
insert into cogensia_movers_stage select distinct on (CAC_NM_CONTRACTED_NAME, CAC_NM_CONTRACTED_ADDR) * from cogensia_movers;
drop table if exists cogensia_movers;
alter table cogensia_movers_stage rename to cogensia_movers;

/* QC */
insert into newmover_update_qc values('Number of observations left after deduping',(SELECT COUNT(*) from cogensia_movers),null);
insert into newmover_update_qc values('Min File Date after new data was read in',null,(select min(cac_nm_file_dt) from cogensia_movers));
insert into newmover_update_qc values('Max id after data was read in',(SELECT max(cac_nm_id) from cogensia_movers),null);
insert into newmover_update_qc values('Total number of obs now in sql',(SELECT count(*) from cogensia_movers),null);

