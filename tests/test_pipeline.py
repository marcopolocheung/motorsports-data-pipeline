import json

from scripts.validate import validate


def test_pipeline_changes_match_a_full_refresh(tmp_path):
    """Run actual dbt MERGEs and verify independently specified business outcomes."""
    report = validate(tmp_path)
    assert report["models"] == 40
    assert len(report["checks_passed"]) == 10
    (tmp_path / "report.json").write_text(json.dumps(report, indent=2) + "\n")
