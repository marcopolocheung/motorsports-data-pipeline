with Riders_Info as (
  select
    r.rider_id,
    t.rider_name as Riders_All_Time_in_All_Classes,
    t.victories as Victories,
    t.second_place_count as second_places,
    t.third_place_count as third_places,
    t.pole_positions_through_2022 as Pole_positions_from_74_to_2022,
    t.fastest_laps_through_2022 as Race_fastest_lap_to_2022,
    t.world_championships as World_Championships,
    t._load_time
  from {{ ref('riders_info') }} t
  join {{ ref('tmp_riders') }} r
    on t.rider_name = r.full_name
)

select * from Riders_Info
