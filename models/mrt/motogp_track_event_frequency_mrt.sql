select
  Track,
  Country,
  sum(Times) as total_events,
  current_timestamp as _load_time
from {{ ref('MG_Prix_Events') }}
group by
  Track,
  Country
