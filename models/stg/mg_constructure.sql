{{ config(
    materialized='incremental',
    unique_key=['constructor', 'season', 'class_name'],
    incremental_strategy='merge'
) }}

with stg_mg_constructure as (
  select
    {{ as_type('Season', 'int64') }} as season,
    nullif(trim(Constructor), '') as constructor,
    nullif(trim(Class), '') as class_name,
    _load_time
  from {{ source('motorsports_raw', 'mg_constructure') }}
  {{ incremental_window() }}
)

select * from stg_mg_constructure
{{ latest_per_key(['constructor', 'season', 'class_name']) }}
