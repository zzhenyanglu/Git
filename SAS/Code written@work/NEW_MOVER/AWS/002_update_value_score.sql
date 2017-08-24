/* NEW MOVER AWS PROCESS NL 20150622 */


/* IMPORT WEEKLY NEW MOVER VALUE SCORE FILE */

DROP TABLE IF EXISTS cogensia_movers_vs;

CREATE TABLE value_score_raw (
	full_file CHAR(150)
);

\COPY value_score_raw FROM '/project/CACDIRECT/DATA/NEW_MOVER/EPSILON/RAW/VALUESCORE_UPDATE/Constellation_TNM_FULL_WE.txt';
insert into newmover_update_qc values('Number of records in this week update file',(SELECT count(*) from value_score_raw));

CREATE TABLE cogensia_movers_vs (
	CAC_NM_CONTRACTED_ADDR	  varchar(40),
	CAC_NM_CONTRACTED_NAME	  varchar(40),
	CAC_NM_FILE_DT            date,
	CAC_NM_FIPS_STATE_CODE	  varchar(2),
	CAC_NM_TARGET_VALUESCORE  varchar(3),
	CAC_NM_ZIP_CODE           varchar(5),
	_CAC_NM_NAME_1		  		  varchar(40),
	_CAC_NM_NAME_2            varchar(40),
	CAC_NM_CONTRACTED_NAME_2  varchar(40)
);

INSERT INTO cogensia_movers_vs (
	CAC_NM_CONTRACTED_ADDR,
	CAC_NM_CONTRACTED_NAME,
	CAC_NM_FILE_DT,
	CAC_NM_FIPS_STATE_CODE,
	CAC_NM_TARGET_VALUESCORE,
	CAC_NM_ZIP_CODE,
	_CAC_NM_NAME_1,
	_CAC_NM_NAME_2
	)
SELECT 
	TRIM(TRAILING ' ' FROM SUBSTRING(full_file,41,40)),
	TRIM(TRAILING ' ' FROM SUBSTRING(full_file,1,40)),
	CAST(SUBSTRING(full_file,114,8) AS DATE),
	SUBSTRING(full_file,94,2),
	SUBSTRING(full_file,128,3),
	SUBSTRING(full_file,96,5),
	SPLIT_PART(TRIM(TRAILING ' ' FROM SUBSTRING(full_file,1,40)),' ',1),
	SPLIT_PART(TRIM(TRAILING ' ' FROM SUBSTRING(full_file,1,40)),' ',3)
FROM value_score_raw;


UPDATE cogensia_movers_vs
SET _CAC_NM_NAME_2 = SPLIT_PART(CAC_NM_CONTRACTED_NAME,' ',2)
WHERE _CAC_NM_NAME_2 = '' OR _CAC_NM_NAME_2 IN ('SR', 'JR');

UPDATE cogensia_movers_vs
SET CAC_NM_CONTRACTED_NAME_2 = CONCAT(_CAC_NM_NAME_1,' ',_CAC_NM_NAME_2);

DROP TABLE IF EXISTS value_score_raw;

insert into newmover_update_qc values('Number of records in both update file and database', (SELECT count(*) FROM cogensia_movers AS A, cogensia_movers_vs AS B
																															WHERE A.CAC_NM_CONTRACTED_ADDR = B.CAC_NM_CONTRACTED_ADDR
																															AND A.cac_nm_fips_state_code = B.CAC_NM_FIPS_STATE_CODE
																															AND A.CAC_NM_ZIP_CODE = B.CAC_NM_ZIP_CODE
																															AND (A.CAC_NM_CONTRACTED_NAME = B.CAC_NM_CONTRACTED_NAME
 																															OR A.CAC_NM_CONTRACTED_NAME = B.CAC_NM_CONTRACTED_NAME_2)),null);

insert into newmover_update_qc values('Number of records with different value score before update', (SELECT count(*) FROM cogensia_movers AS A, cogensia_movers_vs AS B
																																		WHERE A.CAC_NM_CONTRACTED_ADDR = B.CAC_NM_CONTRACTED_ADDR
																																		AND A.CAC_NM_FIPS_STATE_CODE = B.CAC_NM_FIPS_STATE_CODE
																																		AND A.CAC_NM_ZIP_CODE = B.CAC_NM_ZIP_CODE
																																		AND (A.CAC_NM_CONTRACTED_NAME = B.CAC_NM_CONTRACTED_NAME
 																																		OR A.CAC_NM_CONTRACTED_NAME = B.CAC_NM_CONTRACTED_NAME_2)
 																																		AND A.CAC_NM_TARGET_VALUESCORE != B.CAC_NM_TARGET_VALUESCORE),null);

insert into newmover_update_qc values('The Min date can be matched to value score dataset', null,(SELECT min(cac_nm_import_date) FROM cogensia_movers AS A, cogensia_movers_vs AS B
																															WHERE A.CAC_NM_CONTRACTED_ADDR = B.CAC_NM_CONTRACTED_ADDR
																															AND A.cac_nm_fips_state_code = B.CAC_NM_FIPS_STATE_CODE
																															AND A.CAC_NM_ZIP_CODE = B.CAC_NM_ZIP_CODE
																															AND (A.CAC_NM_CONTRACTED_NAME = B.CAC_NM_CONTRACTED_NAME
 																															OR A.CAC_NM_CONTRACTED_NAME = B.CAC_NM_CONTRACTED_NAME_2)));
																								
/* UPDATE VALUE SCROE TO THE NEW MOVER INSTALL FILE */

UPDATE cogensia_movers as A
SET CAC_NM_TARGET_VALUESCORE = B.CAC_NM_TARGET_VALUESCORE
FROM cogensia_movers_vs AS B
WHERE A.CAC_NM_CONTRACTED_ADDR = B.CAC_NM_CONTRACTED_ADDR
AND A.cac_nm_fips_state_code = B.CAC_NM_FIPS_STATE_CODE
AND A.cac_nm_zip_code = B.CAC_NM_ZIP_CODE
AND (A.CAC_NM_CONTRACTED_NAME = B.CAC_NM_CONTRACTED_NAME
 OR  A.CAC_NM_CONTRACTED_NAME = B.CAC_NM_CONTRACTED_NAME_2); 

/* QC */

insert into newmover_update_qc values('Number of records with different value score after update', (SELECT count(*) FROM cogensia_movers AS A, cogensia_movers_vs AS B
																																		WHERE A.CAC_NM_CONTRACTED_ADDR = B.CAC_NM_CONTRACTED_ADDR
																																		AND A.CAC_NM_FIPS_STATE_CODE = B.CAC_NM_FIPS_STATE_CODE
																																		AND A.CAC_NM_ZIP_CODE = B.CAC_NM_ZIP_CODE
																																		AND (A.CAC_NM_CONTRACTED_NAME = B.CAC_NM_CONTRACTED_NAME
 																																		OR A.CAC_NM_CONTRACTED_NAME = B.CAC_NM_CONTRACTED_NAME_2)
 																																		AND A.CAC_NM_TARGET_VALUESCORE != B.CAC_NM_TARGET_VALUESCORE),null);
