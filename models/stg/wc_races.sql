{{ config(
    materialized='incremental',
    unique_key='raceId',
    incremental_strategy='merge'
) }}

with stg_wc_races as (
  select
    raceId,
    year,
    round,
    circuitId,
    nullif(trim(name), '') as name,
    {{ as_type('date', 'date') }} as date,
    {{ as_type('time', 'time') }} as time,
    nullif(trim(url), '') as url,
    {{ as_type('fp1_date', 'date') }} as fp1_date,
    {{ as_type('fp1_time', 'time') }} as fp1_time,
    {{ as_type('fp2_date', 'date') }} as fp2_date,
    {{ as_type('fp2_time', 'time') }} as fp2_time,
    {{ as_type('fp3_date', 'date') }} as fp3_date,
    {{ as_type('fp3_time', 'time') }} as fp3_time,
    {{ as_type('quali_date', 'date') }} as quali_date,
    {{ as_type('quali_time', 'time') }} as quali_time,
    {{ as_type('sprint_date', 'date') }} as sprint_date,
    {{ as_type('sprint_time', 'time') }} as sprint_time,
    _load_time
  from {{ source('motorsports_raw', 'wc_races') }}
  {{ incremental_window() }}
)

select * from stg_wc_races
{{ latest_per_key(['raceId']) }}
