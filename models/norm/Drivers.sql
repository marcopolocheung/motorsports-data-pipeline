with Drivers as (
  select
    Driver as driver_name,
    Nationality,
    Championships,
    Race_Entries,
    Race_Starts,
    Pole_Positions,
    Race_Wins,
    Podiums,
    Fastest_Laps,
    Points,
    Active,
    Championship_Years,
    Decade,
    Pole_Rate,
    Start_Rate,
    Win_Rate,
    Podium_Rate,
    FastLap_Rate,
    Points_Per_Entry,
    Years_Active,
    Champion,
    'drivers' as _data_source,
    _load_time
  from {{ ref('drivers') }}
  where Driver is not null
)

select * from Drivers
