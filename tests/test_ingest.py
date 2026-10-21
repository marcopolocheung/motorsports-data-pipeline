from types import SimpleNamespace
from unittest.mock import Mock

import pytest

from scripts.ingest import load_object


class NotFound(Exception):
    pass


class Conflict(Exception):
    pass


def clients():
    bq, gcs = Mock(), Mock()
    gcs.bucket.return_value.get_blob.return_value.generation = 7
    job = Mock(output_rows=2)
    bq.get_job.return_value = job
    bq.load_table_from_uri.return_value = job
    return bq, gcs, job


def load(bq, gcs):
    return load_object(
        bq=bq, gcs=gcs,
        bigquery=SimpleNamespace(LoadJobConfig=lambda **kwargs: kwargs,
                                 SchemaField=lambda *args, **kwargs: (args, kwargs),
                                 SourceFormat=SimpleNamespace(CSV="CSV"),
                                 WriteDisposition=SimpleNamespace(WRITE_APPEND="WRITE_APPEND")),
        exceptions=SimpleNamespace(NotFound=NotFound, Conflict=Conflict),
        project="example-project", dataset="motorsports_raw", location="US",
        uri="gs://example-bucket/batch-001/wc_results.csv", table="wc_results",
        columns=[{"name": "_load_time", "data_type": "TIMESTAMP"}],
    )


def test_retry_reuses_existing_load_without_appending_again():
    bq, gcs, job = clients()
    assert load(bq, gcs)["reused_job"]
    bq.load_table_from_uri.assert_not_called()
    job.result.assert_called_once()


def test_new_generation_has_a_distinct_job_identity():
    bq, gcs, job = clients()
    bq.get_job.side_effect = NotFound
    first = load(bq, gcs)
    configuration = bq.load_table_from_uri.call_args.kwargs["job_config"]
    assert configuration["autodetect"] is False
    assert configuration["max_bad_records"] == 0
    assert configuration["write_disposition"] == "WRITE_APPEND"
    gcs.bucket.return_value.get_blob.return_value.generation = 8
    assert load(bq, gcs)["job_id"] != first["job_id"]


def test_concurrent_submission_reuses_the_winning_job():
    bq, gcs, job = clients()
    bq.get_job.side_effect = [NotFound(), job]
    bq.load_table_from_uri.side_effect = Conflict
    assert load(bq, gcs)["reused_job"]
    job.result.assert_called_once()


def test_failed_existing_job_is_reported_as_failure():
    bq, gcs, job = clients()
    job.result.side_effect = RuntimeError("malformed CSV")
    with pytest.raises(RuntimeError, match="malformed CSV"):
        load(bq, gcs)
    bq.load_table_from_uri.assert_not_called()
