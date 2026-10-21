# Recorded validation

Validated on October 20, 2026 (America/Chicago), with Python 3.12.8, dbt-core 1.11.8, dbt-duckdb 1.10.1, and DuckDB 1.4.3. The checked-in [machine-readable report](validation.json) records the end-to-end scenario results.

| Check | Result | Boundary |
| --- | --- | --- |
| Local baseline build | 40 models and 133 data tests passed | Synthetic data, no cloud services |
| End-to-end change scenarios | 10 behavioral checks passed | Six builds of the complete model graph |
| Python regression suite | 5 tests passed | Includes one complete dbt scenario and four ingestion retry/failure tests |
| BigQuery target | dbt parse passed with dbt-bigquery 1.11.1 | Project/configuration parsing only; no BigQuery SQL execution |
| Dependency consistency | `pip check` passed | Local demo environment |

## Independently checked outcomes

- Two race results worth 43 points remain two results and 43 points after joining two weather observations. Temperature averages to 22°C.
- The same race name/round in a different year keeps its separate 50°C weather measurement.
- Multiple sponsor labels, constructor classes, podium classes, and race wins per rider survive normalization.
- Source null markers become SQL nulls.
- An existing result updates without duplicating its key, and a new result is inserted.
- Moving a result to another constructor updates the old and new groups. Removing a sponsor removes its obsolete aggregate.
- Adding earlier-sorting rider/image records does not change existing IDs.
- A weather-only correction reaches the race mart without any result-table change.
- Replaying the build preserves analytical values across all 40 models.
- A late-arriving version inside the lookback is processed. All final analytical rows match a full refresh.

Snapshot comparisons exclude the operational `_load_time` column because marts rebuild with a new execution timestamp. Source-ingestion times and all analytical columns are otherwise retained in the comparisons where applicable.

## Reproduce

```bash
python -m pytest -q
python scripts/validate.py --report target/validation.json
dbt parse --profiles-dir profiles --target bigquery
```

The first two commands are alternative ways to run the same end-to-end scenario; pytest also tests the ingestion command's retry/error paths using mocked clients. A live GCS/BigQuery ingestion run, BigQuery MERGE execution, warehouse-scale performance, and production deployment have not been validated for this edition.
