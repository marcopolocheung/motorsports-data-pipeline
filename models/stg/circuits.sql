{{ config(
    materialized='incremental',
    unique_key='circuit',
    incremental_strategy='merge'
) }}

with stg_circuits as (
  select
    {{ location_part(0) }} as circuit,
    {{ location_part(1) }} as city,
    {{ location_part(2) }} as country,
    Track_Length_km,
    Turns,
    Direction,
    Circuit_Type,
    First_Grand_Prix,
    Last_Grand_Prix,
    Races,
    Best_Lap_Timing,
    Best_Lap_Driver,
    Best_Lap_Year,
    Best_Lap_Time,
    high_speed_sector_ratio,
    overtaking_difficulty,
    track_archetype,
    _data_source,
    _load_time
  from {{ source('motorsports_raw', 'circuits') }}
  {{ incremental_window() }}
)

select * from stg_circuits
{{ latest_per_key(['circuit']) }}
