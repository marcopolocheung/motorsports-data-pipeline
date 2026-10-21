{{ config(
    materialized='incremental',
    unique_key='Driver',
    incremental_strategy='merge'
) }}

with stg_drivers as (
  select
    nullif(trim(Driver), '') as Driver,
    nullif(trim(Nationality), '') as Nationality,
    {{ as_type('Championships', 'int64') }} as Championships,
    {{ as_type('Race_Entries', 'int64') }} as Race_Entries,
    {{ as_type('Race_Starts', 'int64') }} as Race_Starts,
    {{ as_type('Pole_Positions', 'int64') }} as Pole_Positions,
    {{ as_type('Race_Wins', 'int64') }} as Race_Wins,
    {{ as_type('Podiums', 'int64') }} as Podiums,
    {{ as_type('Fastest_Laps', 'int64') }} as Fastest_Laps,
    {{ as_type('Points', 'float64') }} as Points,
    Active,
    nullif(trim(Championship_Years), '') as Championship_Years,
    Decade,
    Pole_Rate,
    Start_Rate,
    Win_Rate,
    Podium_Rate,
    FastLap_Rate,
    Points_Per_Entry,
    Years_Active,
    Champion,
    _load_time
  from {{ source('motorsports_raw', 'drivers') }}
  {{ incremental_window() }}
)

select * from stg_drivers
{{ latest_per_key(['Driver']) }}
