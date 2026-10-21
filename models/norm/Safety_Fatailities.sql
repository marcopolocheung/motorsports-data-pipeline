with Safety_Fatailities as (
  select
    Season,
    Number_of_Teams,
    Number_of_Drivers,
    Number_of_Races,
    Number_of_New_Regulations,
    New_Regulations_Impacting_Aerodynamics,
    Fatalities,
    Average_Car_Weight,
    DRS,
    Overtakes,
    'safety_fatailities' as _data_source,
    _load_time
  from {{ ref('safety_fatailities') }}
  where Season is not null
)

select * from Safety_Fatailities
