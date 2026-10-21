{{ config(
    materialized='incremental',
    unique_key=['rider_name', 'season', 'circuit_name', 'class_name'],
    incremental_strategy='merge'
) }}

with stg_mg_prix_winners as (
  select
    nullif(trim(Circuit), '') as circuit_name,
    nullif(trim(Class), '') as class_name,
    case when trim(Constructor) = 'None' then null else nullif(trim(Constructor), '') end as constructor,
    case when trim(Country) = 'None' then null else nullif(trim(Country), '') end as country,
    nullif(trim(Rider), '') as rider_name,
    {{ as_type('Season', 'int64') }} as season,
    _load_time
  from {{ source('motorsports_raw', 'mg_prix_winners') }}
  {{ incremental_window() }}
)

select * from stg_mg_prix_winners
{{ latest_per_key(['rider_name', 'season', 'circuit_name', 'class_name']) }}
