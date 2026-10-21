with MG_Podium_Lockouts as (
  select
    season as Season,
    track_name as Track,
    rider_nation as Riders_Nation,
    class_name as Class,
    _load_time
  from {{ ref('mg_podium_lockouts') }}
)

select *
from MG_Podium_Lockouts
