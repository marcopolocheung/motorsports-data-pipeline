with MG_Finishing_Positions as (
  select
    r.rider_id,
    t.rider_name as Rider,
    t.victories as Victories,
    t.second_place_count as NumberofSecond,
    t.third_place_count as NumberofThird,
    t.fourth_place_count as Numberof4th,
    t.fifth_place_count as Numberof5th,
    t.sixth_place_count as Numberof6th,
    t.country as Country,
    t._load_time
  from {{ ref('mg_finishing_positions') }} t
  join {{ ref('tmp_riders') }} r
    on t.rider_name = r.full_name
)

select *
from MG_Finishing_Positions
qualify row_number() over (partition by rider_id order by _load_time desc, Victories desc, NumberofSecond desc, NumberofThird desc) = 1
