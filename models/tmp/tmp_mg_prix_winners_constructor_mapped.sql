with tmp_mg_prix_winners_constructor_mapped as (
  select
    circuit_name,
    class_name,
    case constructor
      when 'Bultaco-Minarelli' then 'Bultaco'
      when 'Chevallier-Yamaha' then 'Chevallier'
      when 'FTR Honda' then 'Honda'
      when 'Kalex KTM' then 'Kalex'
      when 'MBA/Garelli' then 'MBA'
      when 'HD-Yamaha' then 'Yamaha'
      else constructor
    end as constructor,
    country,
    rider_name,
    season,
    _load_time
  from {{ ref('mg_prix_winners') }}
)

select *
from tmp_mg_prix_winners_constructor_mapped
