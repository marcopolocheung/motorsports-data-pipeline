with split_sponsors as (
  select
    t.image_id,
    lower(trim(sponsor)) as sponsor_name,
    t._load_time
  from {{ ref('tmp_image_class_prepared') }} t,
    {{ split_sponsors() }}
  where t.sponsors_visible is not null
),
Image_Sponsors as (
  select distinct
    image_id,
    sponsor_name,
    _load_time
  from split_sponsors
  where sponsor_name != ''
    and {{ regex_contains('sponsor_name', '[A-Za-z]') }}
    and length(sponsor_name) > 1
)

select *
from Image_Sponsors
