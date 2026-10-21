with Driver_Seasons as (
  select
    Driver as driver_name,
    Season,
    'driver_seasons' as _data_source,
    _load_time
  from {{ source('motorsports_raw', 'driver_seasons') }}
  where Driver is not null
    and Season is not null
)

select * from Driver_Seasons
{{ latest_per_key(['driver_name', 'Season']) }}
