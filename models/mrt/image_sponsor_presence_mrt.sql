select
  s.sponsor_name,
  count(*) as appearance_count,
  count(distinct s.image_id) as unique_images,
  round(avg({{ as_type('c.tire_compound_confidence', 'float64') }}), 3) as avg_confidence,
  current_timestamp as _load_time
from {{ ref('Image_Sponsors') }} s
join {{ ref('Image_Class') }} c
  on s.image_id = c.image_id
group by
  s.sponsor_name
