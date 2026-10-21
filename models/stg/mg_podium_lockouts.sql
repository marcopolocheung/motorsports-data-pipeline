{{ config(
    materialized='incremental',
    unique_key=['season', 'track_name', 'class_name', 'rider_nation'],
    incremental_strategy='merge'
) }}

with stg_mg_podium_lockouts as (
  select
    {{ as_type('Season', 'int64') }} as season,
    nullif(trim(Track), '') as track_name,
    nullif(trim({{ adapter.quote("Riders_ Nation") }}), '') as rider_nation,
    nullif(trim(Class), '') as class_name,
    _load_time
  from {{ source('motorsports_raw', 'mg_podium_lockouts') }}
  {{ incremental_window() }}
)

select * from stg_mg_podium_lockouts
{{ latest_per_key(['season', 'track_name', 'class_name', 'rider_nation']) }}
