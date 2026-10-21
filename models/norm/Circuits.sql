with Circuits as (
  select
    circuit as circuit_name,
    city,
    country,
    Track_Length_km,
    Turns,
    Direction,
    Circuit_Type,
    First_Grand_Prix,
    Last_Grand_Prix,
    Races,
    Best_Lap_Timing,
    Best_Lap_Driver,
    Best_Lap_Year,
    Best_Lap_Time,
    high_speed_sector_ratio,
    overtaking_difficulty,
    track_archetype,
    _data_source,
    _load_time
  from {{ ref('circuits') }}
  where circuit is not null
)

select * from Circuits
