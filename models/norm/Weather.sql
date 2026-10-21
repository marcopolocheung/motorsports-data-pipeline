with Weather as (
  select
    round,
    name as race_name,
    datetime,
    temperature,
    precipitation,
    windspeed,
    'weather' as _data_source,
    _load_time
  from {{ ref('weather') }}
  where round is not null
    and name is not null
    and datetime is not null
)

select * from Weather
