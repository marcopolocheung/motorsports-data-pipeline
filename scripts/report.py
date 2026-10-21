"""Print a compact summary of the local synthetic demo."""

import argparse
from contextlib import closing
from pathlib import Path

import duckdb


def main():
    root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--database", type=Path, default=root / "target/demo.duckdb")
    arguments = parser.parse_args()
    if not arguments.database.is_file():
        parser.error("Demo database is missing. Run dbt seed and dbt build first.")
    with closing(duckdb.connect(str(arguments.database), read_only=True)) as connection:
        examples = [
            ("Race results and weather (synthetic)",
             "select year, race_name, total_results, total_points, temperature "
             "from demo_mrt.race_weather_impact_mrt order by year, raceId"),
            ("Constructor performance (synthetic)",
             "select constructor_name, total_results, wins, total_points "
             "from demo_mrt.constructor_performance_mrt order by constructorId"),
            ("Image annotation sponsors (synthetic)",
             "select sponsor_name, unique_images from demo_mrt.image_sponsor_presence_mrt order by sponsor_name"),
        ]
        for title, query in examples:
            cursor = connection.execute(query)
            columns = [column[0] for column in cursor.description]
            rows = [[str(value) if value is not None else "null" for value in row] for row in cursor.fetchall()]
            widths = [max([len(columns[i]), *(len(row[i]) for row in rows)]) for i in range(len(columns))]
            print(f"\n{title}")
            for row in [columns, *rows]:
                print(" | ".join(value.ljust(width) for value, width in zip(row, widths)))


if __name__ == "__main__":
    main()
