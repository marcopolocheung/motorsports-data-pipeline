{{ config(
    materialized='incremental',
    unique_key='image_gcs_uri',
    incremental_strategy='merge'
) }}

with stg_image_class as (
  select
    team_folder,
    image_file,
    image_gcs_uri,
    case tire_compound_confidence when 'None' then null else tire_compound_confidence end as tire_compound_confidence,
    case primary_color when 'None' then null else primary_color end as primary_color,
    case tire_compound when 'None' then null else tire_compound end as tire_compound,
    case sponsors_visible when 'None' then null else sponsors_visible end as sponsors_visible,
    _load_time
  from {{ source('motorsports_raw', 'image_class') }}
  {{ incremental_window() }}
)

select * from stg_image_class
{{ latest_per_key(['image_gcs_uri']) }}
