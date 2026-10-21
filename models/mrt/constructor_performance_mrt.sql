select
  c.constructorId,
  c.name as constructor_name,
  c.nationality,
  count(r.resultId) as total_results,
  countif(r.position = 1) as wins,
  countif(r.position <= 3) as podiums,
  round(avg({{ as_type("r.position", "float64") }}), 2) as avg_finish_position,
  sum(r.points) as total_points,
  current_timestamp as _load_time
from {{ ref('WC_Results') }} r
join {{ ref('Constructure') }} c
  on r.constructorId = c.constructorId
group by
  c.constructorId,
  constructor_name,
  c.nationality
