{{ config(
    materialized='incremental',
    unique_key=['rider_name', 'country'],
    incremental_strategy='merge'
) }}

with stg_mg_finishing_positions as (
  select
    nullif(trim(Rider), '') as rider_name,
    {{ as_type('Victories', 'int64') }} as victories,
    {{ as_type('NumberofSecond', 'int64') }} as second_place_count,
    {{ as_type('NumberofThird', 'int64') }} as third_place_count,
    {{ as_type('Numberof4th', 'int64') }} as fourth_place_count,
    {{ as_type('Numberof5th', 'int64') }} as fifth_place_count,
    {{ as_type('Numberof6th', 'int64') }} as sixth_place_count,
    nullif(trim(Country), '') as country,
    _load_time
  from {{ source('motorsports_raw', 'mg_finishing_positions') }}
  {{ incremental_window() }}
)

select * from stg_mg_finishing_positions
{{ latest_per_key(['rider_name', 'country']) }}
