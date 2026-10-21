with Constructure as (
  select
    constructorId,
    constructorRef,
    name,
    nationality,
    url,
    _load_time
  from {{ ref('constructure') }}
)

select * from Constructure
