/* INITIATE COGENSIA_MOVERS TABLE AS OF 06/22/2015  */



drop table if exists cogensia_movers;
drop sequence if exists cac_nm_sequence;

create sequence cac_nm_sequence start 1;

create table cogensia_movers 
(
CAC_NM_AREA_CODE_WITH_SUPP_APPL	       varchar(3),
CAC_NM_CARRIER_ROUTE	               varchar(4),
CAC_NM_CEN_HOME_VALUE	               varchar(3),
CAC_NM_CEN_INC_CODE_NEW_ADDR	       varchar(3),
CAC_NM_CEN_INC_CODE_NEW_ADDR_R	       varchar(3),
CAC_NM_CEN_INC_CODE_PREV_ADDR	       varchar(3),
CAC_NM_CEN_INC_CODE_PREV_ADDR_R	       varchar(3),
CAC_NM_CITY	                       varchar(13),
CAC_NM_CONTRACTED_ADDR	               varchar(40),
CAC_NM_CONTRACTED_NAME	               varchar(40),
CAC_NM_COUNTY_CODE	               varchar(3),
CAC_NM_COUNTY_CODE_OLD_ADDR	       varchar(3),
CAC_NM_DELIVERY_POINT_CODE	       varchar(3),
CAC_NM_DISTANCE_OF_MOVE	               varchar(4),
CAC_NM_DPV_FLAG	                       varchar(1),
CAC_NM_DWELLING_ADDR_TYPE	       varchar(1),
CAC_NM_FILE_DT                         date,
CAC_NM_FIPS_STATE_CODE	               varchar(2),
CAC_NM_GENDER	                       varchar(1),
CAC_NM_HH_AGE	                       varchar(2),
CAC_NM_HH_MOVE_DATE	               varchar(6),
CAC_NM_HOMEOWNER_RENTER_CODE	       varchar(1),
CAC_NM_ID                              serial primary key,
CAC_NM_IMPORT_DATE                     date,
CAC_NM_INDIV_TWO_YEAR_AGE_BAND	       varchar(6),
CAC_NM_MARITAL_STATUS	               varchar(1),
CAC_NM_MARITAL_STATUS_WITHIN_HH	       varchar(1),
CAC_NM_NUMBER_OF_ADULTS_IN_HH	       varchar(2),
CAC_NM_NUMBER_OF_KIDS_IN_HH	       varchar(1),
CAC_NM_PET_OWNER	               varchar(1),
CAC_NM_STATE_ABBREVIATION	       varchar(2),
CAC_NM_TARGET_INC	               varchar(1),
CAC_NM_TARGET_VALUESCORE	       varchar(3),
CAC_NM_TELEPHONE_WITH_SUPP_APPL	       varchar(7),
CAC_NM_ZIPPLUS_4	               varchar(4),
CAC_NM_ZIP_CODE	                       varchar(5)
);

\copy cogensia_movers from '/project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/IMPORTED/cogensia_movers_06222015.csv' with (format csv, header, delimiter ',');


update cogensia_movers set CAC_NM_ID                 = nextval('cac_nm_sequence');
