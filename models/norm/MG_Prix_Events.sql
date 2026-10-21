with MG_Prix_Events as (
  select
    track_name as Track,
    event_count as Times,
    country as Country,
    _load_time
  from {{ ref('mg_prix_events') }}
)

select * from MG_Prix_Events
