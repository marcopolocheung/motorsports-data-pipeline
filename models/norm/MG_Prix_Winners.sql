with MG_Prix_Winners as (
  select
    r.rider_id,
    t.circuit_name as Circuit,
    t.class_name as Class,
    t.constructor as Constructor,
    t.country as Country,
    t.rider_name as Rider,
    t.season as Season,
    t._load_time
  from {{ ref('tmp_mg_prix_winners_constructor_mapped') }} t
  join {{ ref('tmp_riders') }} r
    on t.rider_name = r.full_name
)

select *
from MG_Prix_Winners
