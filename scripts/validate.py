"""Exercise real dbt models against isolated, synthetic DuckDB data."""

from __future__ import annotations

import argparse
from contextlib import closing
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

import duckdb

ROOT = Path(__file__).resolve().parents[1]


def validate(work: Path) -> dict:
    work.mkdir(parents=True, exist_ok=True)
    database = work / "validation.duckdb"
    if database.exists():
        raise ValueError("Validation requires a fresh directory; existing data will not be overwritten.")
    environment = os.environ | {
        "DBT_DUCKDB_PATH": str(database),
        "DBT_SEND_ANONYMOUS_USAGE_STATS": "false",
        "DBT_LOG_PATH": str(work / "logs"),
    }
    artifact_path = work / "dbt"
    commands = []

    def dbt(*arguments: str) -> None:
        command = [str(Path(sys.executable).with_name("dbt")), *arguments,
                   "--profiles-dir", str(ROOT / "profiles"), "--target", "local",
                   "--target-path", str(artifact_path)]
        result = subprocess.run(command, cwd=ROOT, env=environment, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=180)
        log_name = f"{len(commands) + 1:02d}-{arguments[0]}.txt"
        (work / log_name).write_text(result.stdout)
        if result.returncode:
            raise RuntimeError(f"dbt failed; see {work / log_name}\n{result.stdout[-7000:]}")
        run_results = json.loads((artifact_path / "run_results.json").read_text())
        assert all(r["status"] in ("success", "pass") for r in run_results["results"])
        commands.append({"command": " ".join(arguments), "successful_resources": len(run_results["results"])})

    def query(sql: str, parameters=None):
        with closing(duckdb.connect(str(database))) as connection:
            return connection.execute(sql, parameters).fetchall()

    def append_version(table: str, predicate: str, replacements: str) -> None:
        # Identifiers/expressions here are constants in this test harness, never user input.
        query(f'insert into demo_raw."{table}" '
              f'select * replace ({replacements}) from demo_raw."{table}" where {predicate}')

    def snapshots():
        manifest = json.loads((artifact_path / "manifest.json").read_text())
        return {node["name"]: query(f'select * exclude (_load_time) from '
                                    f'"{node["schema"]}"."{node["alias"]}" order by all')
                for node in manifest["nodes"].values() if node["resource_type"] == "model"}

    def build(*extra):
        dbt("build", "--exclude", "resource_type:seed", *extra)

    dbt("seed")
    build()
    manifest = json.loads((artifact_path / "manifest.json").read_text())
    model_count = sum(n["resource_type"] == "model" for n in manifest["nodes"].values())
    test_count = sum(n["resource_type"] == "test" for n in manifest["nodes"].values())
    assert model_count == 40
    assert query("select total_results, total_points, temperature from demo_mrt.race_weather_impact_mrt where raceId=1001") == [(2, 43.0, 22.0)]
    assert query("select temperature from demo_mrt.race_weather_impact_mrt where raceId=1002") == [(50.0,)]
    assert query("select count(*) from demo_norm.Image_Sponsors") == [(2,)]
    assert query("select total_wins from demo_mrt.motogp_constructor_wins_mrt") == [(2,)]
    assert query("select count(*) from demo_norm.MG_Constructure") == [(2,)]
    assert query("select count(*) from demo_norm.MG_Podium_Lockouts") == [(2,)]
    assert query("select time, milliseconds, fastestLapTime from demo_stg.wc_results where resultId=2") == [(None, None, None)]
    original_image = query("select image_id from demo_tmp.tmp_image_class_prepared where image_file='apex.jpg'")[0][0]
    original_rider = query("select rider_id from demo_tmp.tmp_riders where full_name='Leo Park'")[0][0]
    checks = ["baseline aggregates and null handling", "weather fanout and year isolation",
              "multiple sponsors and MotoGP race/class grains"]

    # A correction moves an existing result between constructors; a new result is inserted.
    append_version("wc_results", "resultId=1", "10.0 as points, 2 as constructorId, '2' as position, timestamp '2026-10-03' as _load_time")
    append_version("wc_results", "resultId=3", "4 as resultId, 25.0 as points, '1' as position, timestamp '2026-10-03' as _load_time")
    # Removing a sponsor must retract the old aggregate, while retaining another sponsor.
    append_version("image_class", "image_file='apex.jpg'", "'Northstar' as sponsors_visible, timestamp '2026-10-03' as _load_time")
    append_version("image_class", "image_file='apex.jpg' and _load_time=timestamp '2026-10-01'",
                   "'aaa.jpg' as image_file, 'gs://example-fixtures/aaa.jpg' as image_gcs_uri, 'New Sponsor' as sponsors_visible, timestamp '2026-10-03' as _load_time")
    append_version("riders_info", "Riders_All_Time_in_All_Classes='Leo Park'",
                   "'Aaron Fox' as Riders_All_Time_in_All_Classes, timestamp '2026-10-03' as _load_time")
    append_version("mg_prix_winners", "Circuit='Harbor Circuit'",
                   "'Zenith Bikes' as Constructor, timestamp '2026-10-03' as _load_time")
    build()
    assert query("select count(*), sum(points) from demo_norm.WC_Results") == [(4, 68.0)]
    assert query("select total_results, total_points from demo_mrt.constructor_performance_mrt where constructorId=2") == [(2, 28.0)]
    assert query("select sponsor_name from demo_mrt.image_sponsor_presence_mrt order by sponsor_name") == [("new sponsor",), ("northstar",)]
    assert query("select Constructor, total_wins from demo_mrt.motogp_constructor_wins_mrt order by Constructor") == [("Apex Bikes", 1), ("Zenith Bikes", 1)]
    assert query("select image_id from demo_tmp.tmp_image_class_prepared where image_file='apex.jpg'")[0][0] == original_image
    assert query("select rider_id from demo_tmp.tmp_riders where full_name='Leo Park'")[0][0] == original_rider
    checks.extend(["insert and existing-key update", "changed groups and removed sponsor retractions",
                   "stable image/rider identifiers after earlier-sorting inserts"])

    # A weather-only change must refresh the race mart even when no results change.
    append_version("weather", "datetime='2025-03-02 14:00:00'", "30.0 as temperature, timestamp '2026-10-04' as _load_time")
    build()
    assert query("select total_results, total_points, temperature from demo_mrt.race_weather_impact_mrt where raceId=1001") == [(2, 28.0, 25.0)]
    checks.append("weather-only update propagation")

    before_replay = snapshots()
    build()
    assert before_replay == snapshots(), "Replaying a batch changed analytical values"
    checks.append("idempotent replay of all 40 models")

    # This arrives after the Oct 3 batch but has an Oct 2 ingestion timestamp.
    append_version("wc_results", "resultId=2", "5 as resultId, 8.0 as points, timestamp '2026-10-02' as _load_time")
    build()
    assert query("select count(*), sum(points) from demo_norm.WC_Results") == [(5, 76.0)]
    checks.append("late-arriving version inside the seven-day lookback")
    incremental = snapshots()
    build("--full-refresh")
    assert incremental == snapshots(), "Incremental results differ from a full refresh"
    checks.append("incremental/full-refresh parity across all 40 models")

    return {"engine": f"DuckDB {duckdb.__version__}", "models": model_count,
            "dbt_data_tests": test_count, "fixture_source_tables": 15,
            "checks_passed": checks, "dbt_commands": commands,
            "bigquery_execution": "Not performed; no cloud credentials or paid jobs used."}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--report", type=Path, help="Optional JSON output path")
    arguments = parser.parse_args()
    (ROOT / "target").mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="validation-", dir=ROOT / "target") as temporary:
        report = validate(Path(temporary))
        if arguments.report:
            arguments.report.parent.mkdir(parents=True, exist_ok=True)
            arguments.report.write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
