\c cac_prod

set maintenance_work_mem = '24GB';

drop table if exists cac_hh_master_:fdate CASCADE;

create table cac_hh_master_:fdate (
   cac_hh_pid varchar(30) PRIMARY KEY,
   cac_prod_active_flag char(1),
   cac_qtr char(1),
   cac_year int,
   cac_name_first varchar(14),
   cac_name_last varchar(20),
   cac_name_suffix varchar(2),
   cac_name_title varchar(4),
   cac_addr_lat_lon point,
   cac_addr_carrier_rt varchar(4),
   cac_addr_cbsa_code varchar(5),
   cac_addr_cdi char(1),
   cac_addr_city varchar(13),
   cac_addr_county_code varchar(3),
   cac_addr_fips_st int,
   cac_addr_full varchar(100),
   cac_addr_lat_long_ind char(1),
   cac_addr_state char(2),
   cac_addr_street varchar(28),
   cac_addr_zip int,
   cac_addr_zip2 int,
   cac_addr_zip4 int,
   cac_census_2010_block varchar(3),
   cac_census_2010_county_code varchar(3),
   cac_census_2010_match_type char(1),
   cac_census_2010_state_code char(2),
   cac_census_2010_tract_block_grp varchar(7),
   cac_dma int,
   cac_demo_age_enh int,
   cac_demo_education_enh int,
   cac_demo_income_enh int,
   cac_demo_net_worth_enh int,
   cac_demo_occupation int,
   cac_demo_hh_size_enh int,
   cac_demo_hh_type_enh int,
   cac_demo_num_generations_enh int,
   cac_demo_num_kids_enh int,
   cac_demo_marital_status int,
   cac_demo_num_adults int,
   cac_demo_adult_18_24_enh int,
   cac_demo_adult_25_34_enh int,
   cac_demo_adult_35_44_enh int,
   cac_demo_adult_45_54_enh int,
   cac_demo_adult_55_64_enh int,
   cac_demo_adult_65_74_enh int,
   cac_demo_adult_75_plus_enh int,
   cac_demo_adult_unknown_enh int,
   cac_demo_kids_00_02_enh int,
   cac_demo_kids_03_05_enh int,
   cac_demo_kids_06_10_enh int,
   cac_demo_kids_11_15_enh int,
   cac_demo_kids_16_17_enh int,
   cac_demo_kids_enh boolean,
   cac_cred_flag boolean,
   cac_home_built_year int,
   cac_home_dwell_type int,
   cac_home_own int,
   cac_home_res_length int,
   cac_home_sq_foot int,
   cac_silh char(2),
   cac_silh_buy_style_group int,
   cac_silh_dig_inf int,
   cac_silh_ecom int,
   cac_silh_geo int,
   cac_silh_lifestage varchar(3),
   cac_silh_lifestage_group int,
   cac_silh_lifestyle int,
   cac_silh_loyal int,
   cac_silh_lstyle_macro int,
   cac_silh_price int,
   cac_silh_soc_inf int,
   cac_silh_social int,
   cac_silh_socio_econ int,
   cac_silh_socio_group int,
   cac_silh_tech int,
   cac_male_presence_flag boolean,
   cac_female_presence_flag boolean,
   cac_cred_bitmask_loan bit(10),
   cac_cred_bitmask_majcc bit(4),
   cac_cred_bitmask_othcc bit(19),
   cac_int_bitmask_animals bit(5),
   cac_int_bitmask_crafts bit(15),
   cac_int_bitmask_books bit(7),
   cac_int_bitmask_collectibles bit(5),
   cac_int_bitmask_donations bit(15),
   cac_int_bitmask_finance bit(12),
   cac_int_bitmask_food bit(6),
   cac_int_bitmask_health bit(18),
   cac_int_bitmask_hobbies bit(11),
   cac_int_bitmask_mail bit(14),
   cac_int_bitmask_music bit(7),
   cac_int_bitmask_travel bit(8),
   cac_int_flag boolean,
   cac_int_num int,
   cac_int_pol_donor int,
   cac_int_pol_party int,
   etech_group_code char(1),
   etech_assimilation int,
   etech_id int,
   cac_ph_area_code int,
   cac_em_avail_flag boolean,
   cac_addr_state_code int,
   cac_ph_avail_flag boolean,
   cac_comb_avail_flag boolean,
   cac_vert_decile_steak int,
   cac_vert_decile_fast_casual int,
   cac_vert_decile_cdr_bar int,
   cac_vert_decile_dessert int,
   cac_vert_decile_coffee int,
   cac_vert_decile_pizza int,
   cac_vert_decile_italian int,
   cac_vert_decile_fine_dining int,
   cac_vert_steak float,
   cac_vert_fast_casual float,
   cac_vert_cdr_bar float,
   cac_vert_dessert float,
   cac_vert_coffee float,
   cac_vert_pizza float,
   cac_vert_italian float,
   cac_vert_fine_dining float,
   mkey1 text,
   mkey2 text,
   mkey3 text,
   mkey4 text,
   mkey5 text,
   mkey6 text,
   mkey7 text,
   mk_scf char(3),
   st_scf char(6),
   cac_full_fips_id varchar(15),
   score_123_AHI01_002 float,
   decile_123_AHI01_002 int
   );

create table cac_hh_master_partition_1_:fdate (check(cac_addr_state_code = 1)) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_2_:fdate (check(cac_addr_state_code = 2)) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_3_:fdate (check(cac_addr_state_code = 3)) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_4_:fdate (check(cac_addr_state_code = 4 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_5_:fdate (check(cac_addr_state_code = 5 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_6_:fdate (check(cac_addr_state_code = 6 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_7_:fdate (check(cac_addr_state_code = 7 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_8_:fdate (check(cac_addr_state_code = 8 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_9_:fdate (check(cac_addr_state_code = 9 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_10_:fdate (check(cac_addr_state_code = 10 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_11_:fdate (check(cac_addr_state_code = 11 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_12_:fdate (check(cac_addr_state_code = 12 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_13_:fdate (check(cac_addr_state_code = 13 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_14_:fdate (check(cac_addr_state_code = 14 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_15_:fdate (check(cac_addr_state_code = 15 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_16_:fdate (check(cac_addr_state_code = 16 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_17_:fdate (check(cac_addr_state_code = 17 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_18_:fdate (check(cac_addr_state_code = 18 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_19_:fdate (check(cac_addr_state_code = 19 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_20_:fdate (check(cac_addr_state_code = 20 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_21_:fdate (check(cac_addr_state_code = 21 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_22_:fdate (check(cac_addr_state_code = 22 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_23_:fdate (check(cac_addr_state_code = 23 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_24_:fdate (check(cac_addr_state_code = 24 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_25_:fdate (check(cac_addr_state_code = 25 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_26_:fdate (check(cac_addr_state_code = 26 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_27_:fdate (check(cac_addr_state_code = 27 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_28_:fdate (check(cac_addr_state_code = 28 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_29_:fdate (check(cac_addr_state_code = 29 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_30_:fdate (check(cac_addr_state_code = 30 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_31_:fdate (check(cac_addr_state_code = 31 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_32_:fdate (check(cac_addr_state_code = 32 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_33_:fdate (check(cac_addr_state_code = 33 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_34_:fdate (check(cac_addr_state_code = 34 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_35_:fdate (check(cac_addr_state_code = 35 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_36_:fdate (check(cac_addr_state_code = 36 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_37_:fdate (check(cac_addr_state_code = 37 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_38_:fdate (check(cac_addr_state_code = 38 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_39_:fdate (check(cac_addr_state_code = 39 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_40_:fdate (check(cac_addr_state_code = 40 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_41_:fdate (check(cac_addr_state_code = 41 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_42_:fdate (check(cac_addr_state_code = 42 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_43_:fdate (check(cac_addr_state_code = 43 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_44_:fdate (check(cac_addr_state_code = 44 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_45_:fdate (check(cac_addr_state_code = 45 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_46_:fdate (check(cac_addr_state_code = 46 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_47_:fdate (check(cac_addr_state_code = 47 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_48_:fdate (check(cac_addr_state_code = 48 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_49_:fdate (check(cac_addr_state_code = 49 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_50_:fdate (check(cac_addr_state_code = 50 )) inherits (cac_hh_master_:fdate);
create table cac_hh_master_partition_51_:fdate (check(cac_addr_state_code = 51 )) inherits (cac_hh_master_:fdate);

CREATE OR REPLACE FUNCTION cac_hh_master_partition_trigger_:fdate()
RETURNS TRIGGER AS $$
DECLARE
   tname varchar(100); 
BEGIN
   FOR i in 1..51 LOOP
      tname := 'cac_hh_master_partition_' || i || '_' || current_setting('myvars.qdate');
      if ( NEW.cac_addr_state_code = i ) then 
         EXECUTE 'insert into ' ||  tname || ' VALUES ($1.*);' USING NEW;
         exit;
      end if;
   END LOOP;
   return null;
end;
$$
language plpgsql;

set myvars.qdate = :'fdate';
set myvars.datapath = :'cidatapath';

CREATE TRIGGER cac_hh_master_trigger_:fdate
   BEFORE INSERT ON cac_hh_master_:fdate
   FOR EACH ROW EXECUTE PROCEDURE cac_hh_master_partition_trigger_:fdate();
\t

\o 'hh_copy.sql'

select format(
    $$\copy cac_hh_master_%s from '/project/CACDIRECT/%s/cac_hh_master.csv' csv delimiter ';' null as '' $$
    , current_setting('myvars.qdate'), current_setting('myvars.datapath')
);

\o
\i 'hh_copy.sql'

