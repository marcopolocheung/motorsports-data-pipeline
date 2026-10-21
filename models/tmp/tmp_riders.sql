with riders_union as (
  select distinct rider_name as full_name, _load_time
  from {{ ref('mg_finishing_positions') }}
  where rider_name is not null

  union distinct

  select distinct rider_name as full_name, _load_time
  from {{ ref('tmp_mg_prix_winners_constructor_mapped') }}
  where rider_name is not null

  union distinct

  select distinct rider_name as full_name, _load_time
  from {{ ref('riders_info') }}
  where rider_name is not null
),
tmp_riders as (
  select
    {{ dbt.hash('full_name') }} as rider_id,
    full_name,
    max(_load_time) as _load_time
  from riders_union
  group by full_name
)

select *
from tmp_riders
