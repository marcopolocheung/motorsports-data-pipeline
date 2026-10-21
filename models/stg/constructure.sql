{{ config(
    materialized='incremental',
    unique_key='constructorId',
    incremental_strategy='merge'
) }}

with stg_constructure as (
  select *
  from {{ source('motorsports_raw', 'constructure') }}
  {{ incremental_window() }}
)

select * from stg_constructure
{{ latest_per_key(['constructorId']) }}
