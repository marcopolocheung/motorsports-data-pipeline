with WC_Results as (
  select
    resultId,
    raceId,
    driverId,
    constructorId,
    number,
    grid,
    position,
    positionText,
    positionOrder,
    points,
    laps,
    time,
    milliseconds,
    fastestLap,
    rank,
    fastestLapTime,
    fastestLapSpeed,
    statusId,
    'wc_results' as _data_source,
    _load_time
  from {{ ref('wc_results') }}
  where resultId is not null
)

select * from WC_Results
