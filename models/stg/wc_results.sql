{{ config(
    materialized='incremental',
    unique_key='resultId',
    incremental_strategy='merge'
) }}

with stg_wc_results as (
  select
    resultId,
    raceId,
    driverId,
    constructorId,
    {{ as_type("nullif(trim(number), '')", 'int64') }} as number,
    grid,
    {{ as_type("nullif(trim(position), '')", 'int64') }} as position,
    nullif(trim(positionText), '') as positionText,
    positionOrder,
    points,
    laps,
    nullif(nullif(trim(time), ''), concat(chr(92), 'N')) as time,
    {{ as_type("nullif(nullif(trim(milliseconds), ''), '\\\\N')", 'int64') }} as milliseconds,
    {{ as_type("nullif(nullif(trim(fastestLap), ''), '\\\\N')", 'int64') }} as fastestLap,
    {{ as_type("nullif(nullif(trim(rank), ''), '\\\\N')", 'int64') }} as rank,
    nullif(nullif(trim(fastestLapTime), ''), concat(chr(92), 'N')) as fastestLapTime,
    {{ as_type("nullif(nullif(trim(fastestLapSpeed), ''), '\\\\N')", 'float64') }} as fastestLapSpeed,
    statusId,
    _load_time
  from {{ source('motorsports_raw', 'wc_results') }}
  {{ incremental_window() }}
)

select * from stg_wc_results
{{ latest_per_key(['resultId']) }}
