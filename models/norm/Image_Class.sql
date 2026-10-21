with Image_Class as (
  select
    image_id,
    team_folder,
    image_file,
    image_gcs_uri,
    tire_compound_confidence,
    primary_color,
    tire_compound,
    _load_time
  from {{ ref('tmp_image_class_prepared') }}
)

select * from Image_Class
