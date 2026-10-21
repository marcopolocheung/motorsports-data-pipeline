# Model lineage

Generated from the validated local dbt manifest. The same dependency graph is used for BigQuery. Raw inputs are sources, not additional models.

```mermaid
flowchart LR
  subgraph stg[STG models]
    model_motorsports_drivers["drivers"]
    model_motorsports_wc_races["wc_races"]
    model_motorsports_mg_finishing_positions["mg_finishing_positions"]
    model_motorsports_constructure["constructure"]
    model_motorsports_image_class["image_class"]
    model_motorsports_circuits["circuits"]
    model_motorsports_weather["weather"]
    model_motorsports_wc_results["wc_results"]
    model_motorsports_mg_constructure["mg_constructure"]
    model_motorsports_mg_podium_lockouts["mg_podium_lockouts"]
    model_motorsports_riders_info["riders_info"]
    model_motorsports_safety_fatailities["safety_fatailities"]
    model_motorsports_mg_prix_events["mg_prix_events"]
    model_motorsports_mg_prix_winners["mg_prix_winners"]
  end
  subgraph tmp[TMP models]
    model_motorsports_tmp_mg_prix_winners_constructor_mapped["tmp_mg_prix_winners_constructor_mapped"]
    model_motorsports_tmp_riders["tmp_riders"]
    model_motorsports_tmp_image_class_prepared["tmp_image_class_prepared"]
  end
  subgraph norm[NORM models]
    model_motorsports_Drivers["Drivers"]
    model_motorsports_MG_Podium_Lockouts["MG_Podium_Lockouts"]
    model_motorsports_WC_Results["WC_Results"]
    model_motorsports_MG_Constructure["MG_Constructure"]
    model_motorsports_MG_Prix_Winners["MG_Prix_Winners"]
    model_motorsports_Constructure["Constructure"]
    model_motorsports_MG_Prix_Events["MG_Prix_Events"]
    model_motorsports_Image_Sponsors["Image_Sponsors"]
    model_motorsports_Riders_Info["Riders_Info"]
    model_motorsports_Safety_Fatailities["Safety_Fatailities"]
    model_motorsports_Image_Class["Image_Class"]
    model_motorsports_Circuits["Circuits"]
    model_motorsports_Weather["Weather"]
    model_motorsports_WC_Races["WC_Races"]
    model_motorsports_MG_Finishing_Positions["MG_Finishing_Positions"]
    model_motorsports_Driver_Seasons["Driver_Seasons"]
  end
  subgraph mrt[MRT models]
    model_motorsports_race_weather_impact_mrt["race_weather_impact_mrt"]
    model_motorsports_safety_trends_mrt["safety_trends_mrt"]
    model_motorsports_motogp_track_event_frequency_mrt["motogp_track_event_frequency_mrt"]
    model_motorsports_image_sponsor_presence_mrt["image_sponsor_presence_mrt"]
    model_motorsports_driver_season_participation_mrt["driver_season_participation_mrt"]
    model_motorsports_constructor_performance_mrt["constructor_performance_mrt"]
    model_motorsports_motogp_constructor_wins_mrt["motogp_constructor_wins_mrt"]
  end
  source_motorsports_motorsports_raw_circuits[("raw.circuits")]
  source_motorsports_motorsports_raw_constructure[("raw.constructure")]
  source_motorsports_motorsports_raw_drivers[("raw.drivers")]
  source_motorsports_motorsports_raw_driver_seasons[("raw.driver_seasons")]
  source_motorsports_motorsports_raw_wc_races[("raw.wc_races")]
  source_motorsports_motorsports_raw_wc_results[("raw.wc_results")]
  source_motorsports_motorsports_raw_weather[("raw.weather")]
  source_motorsports_motorsports_raw_image_class[("raw.image_class")]
  source_motorsports_motorsports_raw_mg_constructure[("raw.mg_constructure")]
  source_motorsports_motorsports_raw_mg_finishing_positions[("raw.mg_finishing_positions")]
  source_motorsports_motorsports_raw_mg_podium_lockouts[("raw.mg_podium_lockouts")]
  source_motorsports_motorsports_raw_mg_prix_events[("raw.mg_prix_events")]
  source_motorsports_motorsports_raw_mg_prix_winners[("raw.mg_prix_winners")]
  source_motorsports_motorsports_raw_riders_info[("raw.riders_info")]
  source_motorsports_motorsports_raw_safety_fatailities[("raw.safety_fatailities")]
  source_motorsports_motorsports_raw_drivers --> model_motorsports_drivers
  source_motorsports_motorsports_raw_wc_races --> model_motorsports_wc_races
  source_motorsports_motorsports_raw_mg_finishing_positions --> model_motorsports_mg_finishing_positions
  source_motorsports_motorsports_raw_constructure --> model_motorsports_constructure
  source_motorsports_motorsports_raw_image_class --> model_motorsports_image_class
  source_motorsports_motorsports_raw_circuits --> model_motorsports_circuits
  source_motorsports_motorsports_raw_weather --> model_motorsports_weather
  source_motorsports_motorsports_raw_wc_results --> model_motorsports_wc_results
  source_motorsports_motorsports_raw_mg_constructure --> model_motorsports_mg_constructure
  source_motorsports_motorsports_raw_mg_podium_lockouts --> model_motorsports_mg_podium_lockouts
  source_motorsports_motorsports_raw_riders_info --> model_motorsports_riders_info
  source_motorsports_motorsports_raw_safety_fatailities --> model_motorsports_safety_fatailities
  source_motorsports_motorsports_raw_mg_prix_events --> model_motorsports_mg_prix_events
  source_motorsports_motorsports_raw_mg_prix_winners --> model_motorsports_mg_prix_winners
  model_motorsports_drivers --> model_motorsports_Drivers
  model_motorsports_mg_podium_lockouts --> model_motorsports_MG_Podium_Lockouts
  model_motorsports_wc_results --> model_motorsports_WC_Results
  model_motorsports_mg_constructure --> model_motorsports_MG_Constructure
  model_motorsports_tmp_mg_prix_winners_constructor_mapped --> model_motorsports_MG_Prix_Winners
  model_motorsports_tmp_riders --> model_motorsports_MG_Prix_Winners
  model_motorsports_constructure --> model_motorsports_Constructure
  model_motorsports_mg_prix_events --> model_motorsports_MG_Prix_Events
  model_motorsports_tmp_image_class_prepared --> model_motorsports_Image_Sponsors
  model_motorsports_riders_info --> model_motorsports_Riders_Info
  model_motorsports_tmp_riders --> model_motorsports_Riders_Info
  model_motorsports_safety_fatailities --> model_motorsports_Safety_Fatailities
  model_motorsports_tmp_image_class_prepared --> model_motorsports_Image_Class
  model_motorsports_circuits --> model_motorsports_Circuits
  model_motorsports_weather --> model_motorsports_Weather
  model_motorsports_wc_races --> model_motorsports_WC_Races
  model_motorsports_mg_finishing_positions --> model_motorsports_MG_Finishing_Positions
  model_motorsports_tmp_riders --> model_motorsports_MG_Finishing_Positions
  source_motorsports_motorsports_raw_driver_seasons --> model_motorsports_Driver_Seasons
  model_motorsports_mg_prix_winners --> model_motorsports_tmp_mg_prix_winners_constructor_mapped
  model_motorsports_mg_finishing_positions --> model_motorsports_tmp_riders
  model_motorsports_tmp_mg_prix_winners_constructor_mapped --> model_motorsports_tmp_riders
  model_motorsports_riders_info --> model_motorsports_tmp_riders
  model_motorsports_image_class --> model_motorsports_tmp_image_class_prepared
  model_motorsports_WC_Results --> model_motorsports_race_weather_impact_mrt
  model_motorsports_Weather --> model_motorsports_race_weather_impact_mrt
  model_motorsports_WC_Races --> model_motorsports_race_weather_impact_mrt
  model_motorsports_Safety_Fatailities --> model_motorsports_safety_trends_mrt
  model_motorsports_MG_Prix_Events --> model_motorsports_motogp_track_event_frequency_mrt
  model_motorsports_Image_Sponsors --> model_motorsports_image_sponsor_presence_mrt
  model_motorsports_Image_Class --> model_motorsports_image_sponsor_presence_mrt
  model_motorsports_Drivers --> model_motorsports_driver_season_participation_mrt
  model_motorsports_Driver_Seasons --> model_motorsports_driver_season_participation_mrt
  model_motorsports_WC_Results --> model_motorsports_constructor_performance_mrt
  model_motorsports_Constructure --> model_motorsports_constructor_performance_mrt
  model_motorsports_MG_Prix_Winners --> model_motorsports_motogp_constructor_wins_mrt
```

Regenerate dbt documentation after model changes to inspect the current graph: `dbt docs generate --profiles-dir profiles` followed by `dbt docs serve --profiles-dir profiles`.
