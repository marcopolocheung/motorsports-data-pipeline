# BigQuery runbook

The BigQuery target uses the same model graph as the local demo. The historical coursework ran in BigQuery; the corrected portfolio edition has been executed against DuckDB and statically parsed with `dbt-bigquery`. A live BigQuery run of this edition is not claimed.

## Configure a separate environment

Use an existing GCP project with billing and the BigQuery API enabled. Choose a location compatible with your GCS bucket and existing raw datasets. The `US` default is only an example; it does not migrate regional data.

```bash
source .venv/bin/activate
python -m pip install -r requirements-bigquery.txt
gcloud auth application-default login

export BQ_PROJECT='your-gcp-project'
export BQ_LOCATION='US'
export BQ_DATASET='motorsports_portfolio'
export BQ_RAW_DATASET='motorsports_portfolio_raw'
```

`profiles/profiles.yml` contains environment-variable references only. Credentials stay in Application Default Credentials, outside the repository. The source dataset is configured independently from the output prefix. Output datasets are `${BQ_DATASET}_stg`, `${BQ_DATASET}_tmp`, `${BQ_DATASET}_norm`, and `${BQ_DATASET}_mrt`. Avoid pointing them at existing coursework outputs: grains, ID types, and downstream materializations changed.

Create the raw dataset if necessary:

```bash
bq --location="$BQ_LOCATION" mk --dataset "$BQ_PROJECT:$BQ_RAW_DATASET"
```

The executing identity needs read access to GCS input objects, BigQuery job creation, and write access to the chosen datasets. dbt can create its output datasets when the identity has permission. This repository does not provision roles, buckets, services, or schedules.

## Prepare input CSVs

`models/sources.yml` is the column contract for all 15 raw tables. CSV columns must be in that declared order and use those types. Use a header row, UTF-8 encoding, standard CSV quoting, and empty fields for nulls. Do not upload the local fixture seeds as historical racing data.

`_load_time` is required on every row and represents ingestion time in UTC. Updated records keep the same source key and use a strictly later `_load_time`. Race date and weather-observation time remain separate fields. Retain earlier raw versions so dbt can reconstruct current state. Conflicting versions of the same key must not share a timestamp.

Upload batches to immutable object paths such as `gs://your-bucket/batches/2026-10-20-001/wc_results.csv`. Do not overwrite an object while it is loading. BigQuery loads reference a GCS path, not a pinned generation; immutable paths are therefore a precondition of this command.

Create a local batch manifest listing the tables you are loading:

```yaml
wc_results: gs://your-bucket/batches/2026-10-20-001/wc_results.csv
weather: gs://your-bucket/batches/2026-10-20-001/weather.csv
```

An initial build requires all 15 raw source tables. Later batches may update a subset.

```bash
python scripts/ingest.py \
  --project "$BQ_PROJECT" \
  --dataset "$BQ_RAW_DATASET" \
  --location "$BQ_LOCATION" \
  --batch /path/to/batch.yml
```

The command uses declared schemas, requires ingestion timestamps, appends versions, rejects malformed CSV rows, and prints job IDs. It derives each load job ID from the destination, object path, object generation, and schema. A retry or concurrent submission reuses that job instead of appending the same object again. Failed jobs remain failures and require a corrected batch at a new immutable path.

This retry protection lasts while BigQuery retains the job metadata; it is not a permanent external ingestion ledger. Loading identical content under a different path creates a new job. Repeated identical raw versions are deduplicated in staging, but avoid them to prevent wasted storage and ambiguous conflicting timestamps. Ingestion is atomic per table, not across all tables in a batch.

## Validate and build

```bash
# Parses project structure without querying BigQuery:
dbt parse --profiles-dir profiles --target bigquery

# Checks connectivity/credentials, then executes paid warehouse work:
dbt debug --profiles-dir profiles --target bigquery
dbt build --profiles-dir profiles --target bigquery --full-refresh

# After loading a subsequent immutable batch:
dbt build --profiles-dir profiles --target bigquery
```

Local CSV seeds are disabled for the BigQuery target. The initial full refresh establishes the new grains and hash identifiers. Subsequent runs incrementally merge staging and rebuild downstream tables. Serialize ingestion and dbt runs for a batch; concurrent source changes are not snapshot-isolated across the graph.

The profile caps each dbt query at one billion bytes billed. This is a per-query guard, not a total spend cap, and it does not apply to the separate ingestion client. Inspect BigQuery job statistics before increasing it. The project has no measured cloud-cost or latency claims.

For a late-arriving version outside the default seven-day window:

```bash
dbt build --profiles-dir profiles --target bigquery --vars '{lookback_days: 30}'
# Or reconstruct all current state after source deletions or older corrections:
dbt build --profiles-dir profiles --target bigquery --full-refresh
```

`lookback_days` accepts 0–365. Deletions and natural-key changes require a full refresh because the raw contract contains no tombstones.

Generate documentation after a successful build:

```bash
dbt docs generate --profiles-dir profiles --target bigquery
dbt docs serve --profiles-dir profiles --target bigquery
```
