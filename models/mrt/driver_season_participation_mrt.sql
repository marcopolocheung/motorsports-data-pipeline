select
  d.driver_name,
  d.Nationality as nationality,
  count(distinct s.Season) as total_seasons,
  min(s.Season) as first_season,
  max(s.Season) as last_season,
  d.Championships as championships,
  d.Race_Wins as race_wins,
  d.Podiums as podiums,
  d.Points as career_points,
  d.Years_Active as years_active,
  d.Active as active_now,
  d.Champion as champion,
  current_timestamp as _load_time
from {{ ref('Drivers') }} d
join {{ ref('Driver_Seasons') }} s
  on lower(trim(d.driver_name)) = lower(trim(s.driver_name))
group by
  d.driver_name,
  nationality,
  championships,
  race_wins,
  podiums,
  career_points,
  years_active,
  active_now,
  champion
