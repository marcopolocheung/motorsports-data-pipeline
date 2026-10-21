select
  Season,
  Constructor,
  count(*) as total_wins,
  current_timestamp as _load_time
from {{ ref('MG_Prix_Winners') }}
where Constructor is not null
group by
  Season,
  Constructor
