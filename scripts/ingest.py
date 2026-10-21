"""Load immutable GCS CSV batches into append-only BigQuery raw tables.

Install requirements-bigquery.txt and configure Application Default Credentials.
CSV columns must follow models/sources.yml, including an ingestion _load_time.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re

import yaml

ROOT = Path(__file__).resolve().parents[1]


def source_schemas() -> dict:
    document = yaml.safe_load((ROOT / "models/sources.yml").read_text())
    return {table["name"]: table["columns"] for table in document["sources"][0]["tables"]}


def load_object(*, bq, gcs, bigquery, exceptions, project, dataset, location, uri, table, columns):
    """A stable job ID lets retries reuse a submitted/completed load job."""
    match = re.fullmatch(r"gs://([^/]+)/(.+\.csv)", uri)
    if not match:
        raise ValueError(f"Expected a gs://bucket/path.csv URI: {uri}")
    blob = gcs.bucket(match[1]).get_blob(match[2])
    if blob is None:
        raise FileNotFoundError(uri)
    destination = f"{project}.{dataset}.{table}"
    identity = {"destination": destination, "uri": uri, "generation": str(blob.generation),
                "schema": [(c["name"], c["data_type"]) for c in columns]}
    digest = hashlib.sha256(json.dumps(identity, sort_keys=True).encode()).hexdigest()
    job_id = f"motorsports_{digest}"
    reused = False
    try:
        job = bq.get_job(job_id, project=project, location=location)
        reused = True
    except exceptions.NotFound:
        configuration = bigquery.LoadJobConfig(
            schema=[bigquery.SchemaField(c["name"], c["data_type"],
                                        mode="REQUIRED" if c["name"] == "_load_time" else "NULLABLE")
                    for c in columns],
            source_format=bigquery.SourceFormat.CSV,
            skip_leading_rows=1,
            autodetect=False,
            allow_quoted_newlines=True,
            ignore_unknown_values=False,
            max_bad_records=0,
            write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        )
        try:
            job = bq.load_table_from_uri(uri, destination, job_id=job_id,
                                         job_config=configuration, location=location)
        except exceptions.Conflict:
            job = bq.get_job(job_id, project=project, location=location)
            reused = True
    job.result()  # Includes failures from an earlier attempt; never report a failed job as loaded.
    return {"table": destination, "uri": uri, "job_id": job_id,
            "reused_job": reused, "output_rows": job.output_rows}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--project", required=True)
    parser.add_argument("--dataset", required=True)
    parser.add_argument("--location", required=True)
    parser.add_argument("--batch", type=Path, required=True,
                        help="YAML mapping: table name -> immutable gs://.../table.csv URI")
    arguments = parser.parse_args()
    manifest = yaml.safe_load(arguments.batch.read_text())
    schemas = source_schemas()
    if not isinstance(manifest, dict) or not manifest:
        parser.error("The batch must be a nonempty table-to-URI mapping")
    if set(manifest) - set(schemas):
        parser.error(f"Unknown tables: {sorted(set(manifest) - set(schemas))}")
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", arguments.dataset):
        parser.error("Invalid BigQuery dataset identifier")
    # Lazy imports keep the local demo independent of Google libraries and credentials.
    from google.api_core import exceptions
    from google.cloud import bigquery, storage

    bq = bigquery.Client(project=arguments.project, location=arguments.location)
    gcs = storage.Client(project=arguments.project)
    for table, uri in manifest.items():
        result = load_object(bq=bq, gcs=gcs, bigquery=bigquery, exceptions=exceptions,
                             project=arguments.project, dataset=arguments.dataset,
                             location=arguments.location, uri=uri, table=table, columns=schemas[table])
        print(json.dumps(result))


if __name__ == "__main__":
    main()
