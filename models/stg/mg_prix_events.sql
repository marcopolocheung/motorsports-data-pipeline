{{ config(
    materialized='incremental',
    unique_key='track_name',
    incremental_strategy='merge'
) }}

with stg_mg_prix_events as (
  select
    {{ as_type('Times', 'int64') }} as event_count,
    nullif(trim(Track), '') as track_name,
    nullif(trim(Country), '') as country,
    _load_time
  from {{ source('motorsports_raw', 'mg_prix_events') }}
  {{ incremental_window() }}
)

select * from stg_mg_prix_events
{{ latest_per_key(['track_name']) }}
