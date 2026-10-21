{{ config(
    materialized='incremental',
    unique_key=['round', 'name', 'datetime'],
    incremental_strategy='merge'
) }}

with stg_weather as (
  select
    temperature,
    precipitation,
    windspeed,
    round,
    nullif(trim(name), '') as name,
    {{ as_type("nullif(trim(datetime), '')", 'timestamp') }} as datetime,
    _load_time
  from {{ source('motorsports_raw', 'weather') }}
  {{ incremental_window() }}
)

select * from stg_weather
{{ latest_per_key(['round', 'name', 'datetime']) }}
