
%macro Get_Welcome 
(                camp_id =,table_info=,prior_his=,curr_his=,store_sel=,current_date=,outfile=,auditlist=)
/ store source des="Get_Welcome macro";


/* Customer filters */
proc sql;
create table cust_filter as
select a.TVR_Card_Id,
	   a.Individual_Given_Name,
	   a.Individual_Family_Name,
	   a.TVR_Prgrm_Enrollment_Dt,
	   a.TVR_Prgrm_Customer_Type,
	   a.TVR_DIY_VIP_Ind,
	   a.TVR_DIY_VIP_Override_Ind,
	   a.tvr_segment_name,
	   a.TVR_HH_Master_Prgrm_Card_Id,
	   a.TVR_Prgrm_Comm_Type_Name,
	   a.Primary_Store_Number,
	   a.Street_Addr_Line_1_Text,
	   a.Street_Addr_Line_2_Text,
	   a.City_Name,
	   a.Territory_Name,
	   a.Postal_Code,
	   a.Individual_Program_Type,
	   a.HH_Master_Flag,
	   a.Indiv_Master_Flag,
	   a.Individual_Party_Id,
	   a.Individual_Id,
	   a.HouseHold_Party_Id,
	   a.Household_Id,
	   (case when a.primary_store_number eq . then 1 else 0 end) as missing_store_flag,
	   count(a.HH_Master_Flag) as Master_cnt,
	   case TVR_Prgrm_Comm_Type_Name
	     when 'C' then 1
		 else 0 
		end as comm_type_flag 
from &table_info a
;
quit;

proc print data=cust_filter(obs=10); run;

proc freq data=cust_filter;
table TVR_Prgrm_Comm_Type_Name*comm_type_flag Primary_Store_Number*Master_cnt;
/*/ nocol norow nopercent;*/
run;

/****************************************************************************/
/********************* Remove Prior Campaign History (2 Steps)***************/
/****************************************************************************/
/* 1) Aimia Prior Campaign History - tvr_HH_Master_Prgrm_Card_Id*/
proc sql;
create table prior_history as
select a.*,
       (case when a.TVR_HH_Master_Prgrm_Card_Id = b.TVR_HH_Master_Prgrm_Card_Id then 1 else 0 end) as prior_flag
from cust_filter a
    left join &prior_his b on a.TVR_HH_Master_Prgrm_Card_Id = b.TVR_HH_Master_Prgrm_Card_Id;
quit;

proc print data=prior_history(obs=10); 
where prior_flag eq 0; 
title 'Not in prior campaign';
run;

proc freq data=prior_history; table prior_flag; run;

/* 2) Current Month Campaign Selection */
proc sql;
create table curr_history as
select a.*,
       (case when a.TVR_HH_Master_Prgrm_Card_Id = b.TVR_HH_Master_Prgrm_Card_Id then 1 else 0 end) as curr_flag
from prior_history a
    left join &curr_his b on a.TVR_HH_Master_Prgrm_Card_Id = b.TVR_HH_Master_Prgrm_Card_Id;
quit;

proc print data=curr_history(obs=10); 
where curr_flag eq 0; 
title 'Not in current campaign';
run;

proc freq data=curr_history; table curr_flag; run;

/* Valid Store List */
proc sql;
create table valid_store as
select a.primary_store_number as store_number,
       a.TVR_Card_Id,
	   a.Individual_Given_Name,
	   a.Individual_Family_Name,
	   a.TVR_Prgrm_Enrollment_Dt,
	   a.TVR_Prgrm_Customer_Type,
	   a.TVR_DIY_VIP_Ind,
	   a.TVR_DIY_VIP_Override_Ind,
	   a.tvr_segment_name,
	   a.TVR_HH_Master_Prgrm_Card_Id,
	   a.TVR_Prgrm_Comm_Type_Name,
	   a.Street_Addr_Line_1_Text,
	   a.Street_Addr_Line_2_Text,
	   a.City_Name,
	   a.Territory_Name,
	   a.Individual_Program_Type,
	   a.Postal_Code,
	   a.HH_Master_Flag,
	   a.Indiv_Master_Flag,
	   a.Individual_Party_Id,
	   a.Individual_Id,
	   a.HouseHold_Party_Id,
	   a.Household_Id,
	   a.missing_store_flag,
	   a.comm_type_flag,
	   a.prior_flag,
	   a.curr_flag,
       b.Campaign_Id,
	   &camp_id as Campaign_Mgmt_Id,
	   B.Region_Code,
	   B.INHOME_DATE,
	   b.Sequence_id,
	   0 as reward_amt,
	(case when a.primary_store_number = b.store_number then 1 else 0 end) as store_flag
from curr_history a
left join &store_sel b on a.primary_store_number = b.store_number
;
quit;


proc sql;
	create table storelist as
	select store_number, store_flag, count(distinct TVR_HH_Master_Prgrm_Card_Id) as hhct
	from valid_store 
	group by store_number, store_flag
	order by store_number, store_flag;
quit;

proc print data=storelist;
title 'Stores Participation totals'; 
run;


/* Campaign Specific Logic */
data camp_enroll;
 set valid_store;
 	new_month = intnx('month',&current_date,-4);
 	format new_month date9.;
	nonqual_flag = 1;
	if (tvr_prgrm_enrollment_dt >= new_month and tvr_prgrm_enrollment_dt <= &current_date) then nonqual_flag = 0;
	version_id = 1;   
	if store_number in (18968,18969,18970,18971,18972,19298) and Region_Code = 'B' then  version_id = 2; /* WFC Stores */   
    if store_number in (3513,3247,3254,3593) and Region_Code = 'A' then version_id = 3; /*Cape Code or otherwise known as Campbell */

	if Individual_Program_Type eq "C" then consumer_flag = 1;
	run;

proc freq data=camp_enroll; table nonqual_flag tvr_segment_name Region_Code*version_id; run;

proc sql;
create table waterfall_tots_DM as 
	select 
		count(*) as Total_TVR_Card_ct, 
		count(distinct tvr_card_id) as Unique_TVR_Card_ct,
	    count(distinct household_id) as HH_ct,
		sum(case when comm_type_flag = 1 then 1 else 0 end) as remove_comm_type_C,
		sum(case when comm_type_flag = 0 and missing_store_flag = 1 then 1 else 0 end) as remove_miss_store_C,
		sum(case when comm_type_flag = 0 and missing_store_flag = 0 and prior_flag = 1 then 1 else 0 end) as remove_prior_history,
		sum(case when comm_type_flag = 0 and missing_store_flag = 0 and prior_flag = 0 and curr_flag = 1 then 1 else 0 end) as remove_curr_history,
		sum(case when comm_type_flag = 0 and missing_store_flag = 0 and prior_flag = 0 and curr_flag = 0 and store_flag = 0 then 1 else 0 end) as remove_store_opt_out,
		sum(case when comm_type_flag = 0 and missing_store_flag = 0 and prior_flag = 0 and curr_flag = 0 and store_flag = 1 and nonqual_flag = 1 then 1 else 0 end) as remove_nonqual,
		sum(case when comm_type_flag = 0 and missing_store_flag = 0 and prior_flag = 0 and curr_flag = 0 and store_flag = 0 and nonqual_flag = 0 and consumer_flag eq 0 then 1 else 0 end) as remove_consumer,
		sum(case when comm_type_flag = 0 and missing_store_flag = 0 and prior_flag = 0 and curr_flag = 0 and store_flag = 1 and nonqual_flag = 0 and consumer_flag eq 1 then 1 else 0 end) as valid_mail_ct
	from camp_enroll; 
quit;

proc transpose data=waterfall_tots_DM 
               out=waterfall_tots_DM;
run;

data &auditlist; 
set waterfall_tots_DM; 
rename Col1=count _Name_ = Data_step; 
run;

title 'Waterfall Chart for Welcome selection';

proc print data=waterfall_tots_DM; run; 
 
data &outfile; set camp_enroll;
	if (comm_type_flag = 0) and (missing_store_flag = 0) and (prior_flag = 0)
		and (curr_flag = 0) and (store_flag = 1) and (nonqual_flag = 0) and (consumer_flag = 1);
run;
%mend; 

