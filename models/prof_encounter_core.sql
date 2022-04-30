with encounter_dates as(
  select
    encounter_id
    ,bene_mbi_id as patient_id
    ,min(clm_from_dt) as encounter_start_date
    ,max(clm_thru_dt) as encounter_end_date
    ,cast(sum(clm_line_cvrd_pd_amt) as float) as paid_amount
  from {{ ref('prof_claims_final')}}
  group by 
    encounter_id
    ,bene_mbi_id
)
,encounter_stage as(
select
	cast(e.encounter_id as varchar) as encounter_id
  , cast(e.patient_id as varchar) as patient_id
  , cast(case clm_type_cd
		when '72' then 'office visit'
  		when '71' then 'dme'
  end as varchar) as encounter_type
  , cast(e.encounter_start_date as varchar) as encounter_start_date
  , cast(e.encounter_end_date as varchar) as encounter_end_date
  , cast(NULL as varchar) as admit_type_code
  , cast(NULL as varchar) as admit_type_description
  , cast(NULL as varchar) as admit_source_code
  , cast(NULL as varchar) as admit_source_description
  , cast(NULL as varchar) as discharge_disposition_code
  , cast(NULL as varchar) as discharge_disposition_description
  , cast(f.rndrg_prvdr_npi_num as varchar) as physician_npi
  , cast(NULL as varchar) as location
  , cast(NULL as varchar) as facility_npi
  , cast(NULL as varchar) as ms_drg
  , cast(e.paid_amount as varchar) as paid_amount
  , cast('cclf' as varchar) as data_source
  , cast(row_number() over (partition by f.encounter_id order by f.cur_clm_uniq_id) as int) as row_number
from {{ ref('prof_claims_final')}} f
inner join encounter_dates e
	on f.encounter_id = e.encounter_id
)

select 
 cast(encounter_id as varchar) as encounter_id
, cast(patient_id as varchar) as patient_id
, cast(encounter_type as varchar) as encounter_type
, cast(encounter_start_date as date) as encounter_start_date
, cast(encounter_end_date as date) as encounter_end_date
, cast(admit_source_code as varchar) as admit_source_code
, cast(admit_source_description as varchar) as admit_source_description
, cast(admit_type_code as varchar) as admit_type_code
, cast(admit_type_description as varchar) as admit_type_description
, cast(discharge_disposition_code as varchar) as discharge_disposition_code
, cast(discharge_disposition_description as varchar) as discharge_disposition_description
, cast(physician_npi as varchar) as physician_npi
, cast(location as varchar) as location
, cast(facility_npi as varchar) as facility_npi 
, cast(ms_drg as varchar) as ms_drg
, cast(paid_amount as float) as paid_amount
, cast(data_source as varchar) as data_source
from encounter_stage 
where row_number = 1