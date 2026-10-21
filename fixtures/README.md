# Synthetic fixtures

These 15 CSVs contain invented records, not historical racing data. Column names and types match the coursework source contracts in `models/sources.yml`; `schema.yml` fixes the DuckDB seed types so numeric-looking strings and nulls do not change type between runs.

The baseline deliberately includes two constructors, the same Grand Prix in two different years, multiple weather observations for one race, multiple sponsor labels on an image, multiple classes for a MotoGP constructor/track, and multiple wins by the same rider in a season. `scripts/validate.py` adds corrections and new records in an isolated database.

The `gs://example-fixtures/` strings identify imaginary images. They are metadata values only; no objects are downloaded and no images are distributed. `_load_time` values describe invented ingestion batches, separately from race dates.
