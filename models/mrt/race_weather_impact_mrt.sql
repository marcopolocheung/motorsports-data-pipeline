-- Aggregate independent one-to-many inputs before joining them to a race.
-- Weather is matched by year as well as round/name to avoid mixing seasons.
with results as (
  select
    raceId,
    count(*) as total_results,
    round(avg({{ as_type('position', 'float64') }}), 2) as avg_finish_position,
    sum(points) as total_points
  from {{ ref('WC_Results') }}
  group by raceId
), weather as (
  select
    extract(year from datetime) as weather_year,
    round as race_round,
    lower(trim(race_name)) as race_name,
    round(avg(temperature), 2) as temperature,
    round(avg(precipitation), 2) as precipitation,
    round(avg(windspeed), 2) as windspeed
  from {{ ref('Weather') }}
  group by weather_year, race_round, lower(trim(race_name))
)
select
  r.raceId,
  r.year,
  r.race_name,
  w.temperature,
  w.precipitation,
  w.windspeed,
  res.total_results,
  res.avg_finish_position,
  res.total_points,
  current_timestamp as _load_time
from {{ ref('WC_Races') }} r
join results res on r.raceId = res.raceId
left join weather w
  on r.year = w.weather_year
  and r.round = w.race_round
  and lower(trim(r.race_name)) = w.race_name
