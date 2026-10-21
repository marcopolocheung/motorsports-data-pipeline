with image_class_prepared as (
  select
    {{ dbt.hash('image_gcs_uri') }} as image_id,
    case
      when trim(regexp_replace(team_folder, '(?i)(F1 car|Formula 1 Car)', '')) = 'Red Bull Racing'
        then 'Red Bull'
      else trim(regexp_replace(team_folder, '(?i)(F1 car|Formula 1 Car)', ''))
    end as team_folder,
    image_file,
    image_gcs_uri,
    tire_compound_confidence,
    primary_color,
    tire_compound,
    sponsors_visible,
    _load_time
  from {{ ref('image_class') }}
)

select *
from image_class_prepared
