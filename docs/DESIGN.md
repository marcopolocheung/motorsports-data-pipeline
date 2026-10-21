# Design decisions

## Current-state staging over append-only raw versions

Each raw source preserves versions of a source record. `_load_time` is the ingestion timestamp, not the race date. New versions retain their source key and receive a later timestamp. Staging selects the newest version per declared key before merging it into its destination.

On subsequent runs, staging re-reads records at or above the destination's maximum `_load_time` minus `lookback_days` (default seven). The inclusive boundary reprocesses equal-timestamp arrivals and makes a retry harmless. Source history must remain available; pruning raw versions requires a separate retention design.

The raw contract prohibits conflicting versions of the same key with exactly the same ingestion timestamp. Duplicate identical records do not change the projection, but conflicting ties have no defined winner. Ingestion must supply increasing per-key timestamps. A late record outside the configured window requires a larger lookback or `--full-refresh`.

This supports inserts and corrections, not CDC deletes. Removing a row from raw storage does not remove it from an existing incremental staging table. Source deletions require a full refresh; tombstone handling is future work. Changing a natural key is a delete plus insert and follows that same limitation.

## Rebuild dependent tables for correctness

Only the 14 source-facing staging models are incremental. Three intermediate models, 16 normalized models, and seven marts rebuild each run. Driver-season records enter normalization directly from their raw source, preserving the coursework's 40-model topology.

The coursework incrementally merged aggregates using destination timestamps generated at query time. That can miss updates carrying older ingestion timestamps. It also misses the old aggregate group when a record moves between groups, or leaves a sponsor behind after its last annotation is removed. Rebuilding dependent tables computes both additions and retractions from current state.

This costs more downstream work. No cost or performance improvement is claimed. A larger deployment could implement explicit changed-key tracking, old/new group invalidation, and partition replacement after benchmarking.

## Stable identities and explicit grains

Images use an MD5 hash of their source URI, and riders use a hash of their normalized full name. These are deterministic technical identifiers, not security hashes or real-world entity resolution. Changing a URI or name creates a different identity. Sequential `row_number()` identifiers were removed because newly inserted records could renumber existing rows and break joins.

Multiple sponsor annotations survive as `(image_id, sponsor_name)` rows; sponsor names are lowercased and trimmed. They are labels, not a resolved corporate registry. MotoGP wins retain `(Rider, Season, Circuit, Class)` grain so a rider's second win in a season is counted. Constructor/class and podium/class distinctions are preserved rather than discarded to satisfy an overly narrow unique test.

The finishing-position model intentionally retains one career summary per rider, selecting the latest ingestion timestamp and then highest wins/podiums across same-time country rows. The source does not provide a stronger identity or source-priority rule.

## Independent aggregates before weather joins

Race result counts and points aggregate by race ID before joining weather. Weather aggregates by calendar year, round, and normalized race name. Year matching prevents observations from a later season being attached to an earlier race with the same round/name. Weather-only corrections propagate because the mart rebuilds.

Calendar-year matching assumes a race's weather observations fall in its recorded race year. UTC date boundaries, inconsistent race naming, and missing observations may leave weather unmatched. Missing weather remains null. No causal inference or weather-to-result prediction is performed.

## Validation boundaries

The complete graph executes against DuckDB fixtures using the same SQL models and a small set of adapter macros. BigQuery-specific functions are rendered by those macros; local execution is useful evidence of data logic, but does not validate BigQuery IAM, billing, table-scale behavior, or cloud job execution. The current BigQuery target is statically parsed without credentials.

Schema and relationship tests cover declared grains and referential integrity. Behavioral scenarios check independent expected totals, multi-observation joins, stable IDs, changed aggregate groups, and full-refresh equivalence. Append-only raw row counts are intentionally not compared to deduplicated staging row counts.

Ingestion and dbt runs should be serialized for a batch. There is no cross-table transaction, scheduler, monitoring service, concurrent-source snapshot, or deployment SLA. A failed batch may leave some sources loaded; retrying reuses their load jobs and continues. This is a reproducible portfolio pipeline rather than a managed production service.
