with WC_Races as (
  select
    raceId,
    year,
    round,
    circuitId,
    name as race_name,
    date,
    time,
    url,
    fp1_date,
    fp1_time,
    fp2_date,
    fp2_time,
    fp3_date,
    fp3_time,
    quali_date,
    quali_time,
    sprint_date,
    sprint_time,
    'wc_races' as _data_source,
    _load_time
  from {{ ref('wc_races') }}
  where raceId is not null
)

select * from WC_Races
