{{ config(
    materialized='incremental',
    unique_key='Season',
    incremental_strategy='merge'
) }}

with stg_safety_fatailities as (
  select *
  from {{ source('motorsports_raw', 'safety_fatailities') }}
  {{ incremental_window() }}
)

select * from stg_safety_fatailities
{{ latest_per_key(['Season']) }}
