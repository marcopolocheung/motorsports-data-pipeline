select
  Season,
  Number_of_Teams,
  Number_of_Drivers,
  Number_of_Races,
  Number_of_New_Regulations,
  Fatalities,
  Average_Car_Weight,
  Overtakes,
  DRS,
  round(
    1.0 * Fatalities / nullif(Number_of_Races, 0),
    4
  ) as fatalities_per_race,
  _load_time
from {{ ref('Safety_Fatailities') }}
