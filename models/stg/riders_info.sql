{{ config(
    materialized='incremental',
    unique_key='rider_name',
    incremental_strategy='merge'
) }}

with stg_riders_info as (
  select
    nullif(trim(Riders_All_Time_in_All_Classes), '') as rider_name,
    {{ as_type('Victories', 'int64') }} as victories,
    {{ as_type('second_places', 'int64') }} as second_place_count,
    {{ as_type('third_places', 'int64') }} as third_place_count,
    {{ as_type('Pole_positions_from_74_to_2022', 'int64') }} as pole_positions_through_2022,
    {{ as_type('Race_fastest_lap_to_2022', 'int64') }} as fastest_laps_through_2022,
    {{ as_type('World_Championships', 'int64') }} as world_championships,
    _load_time
  from {{ source('motorsports_raw', 'riders_info') }}
  {{ incremental_window() }}
)

select * from stg_riders_info
{{ latest_per_key(['rider_name']) }}
