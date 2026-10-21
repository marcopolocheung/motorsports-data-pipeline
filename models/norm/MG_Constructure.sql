with MG_Constructure as (
  select
    season as Season,
    constructor as Constructor,
    class_name as Class,
    _load_time
  from {{ ref('mg_constructure') }}
  where constructor is not null
)

select *
from MG_Constructure
