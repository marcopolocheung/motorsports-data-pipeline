# Claude.md — Coding agent usage disclosure

This file documents my use of a coding agent on the CS 333E final project
(Option 2 — Incremental Updates). The final project rubric does not
explicitly require an agent disclosure file, but I am including this for
transparency since I used the same workflow as Project 10.

## Scope of agent use

I used Claude (Anthropic, claude-opus-4-7) as an execution assistant. The
brainstorming, planning, and design decisions for this project were mine.
The agent helped me write boilerplate dbt code faster, debug specific
errors I encountered when running dbt myself, and produce supporting
artifacts like the Colab notebook and the change-data CSVs.

## What I planned myself before involving the agent

1. I picked Option 2 over Options 1 and 3 after weighing the time available
   (one day) against the learning curves: I had already gotten dbt and
   BigQuery working for Project 10, so extending that pipeline to incremental
   was lower risk than picking up the Agent Development Kit cold. Option 3
   was off the table because the proposal deadline had already passed.
2. I worked out the overall approach: copy the Project 10 dbt project,
   prefix every schema with `fin_` so I would not overwrite the Project 10
   tables, set up a separate `fin_f1_data_raw` BigQuery dataset with a
   `_load_time` column on every source table, convert all 40 models to
   `materialized='incremental'` with appropriate unique keys, run an initial
   load that matches Project 10 row counts, then ingest fake change data
   with a later `_load_time` and verify the second run uses the
   `is_incremental()` filter to process only the new rows.
3. I decided which unique keys to use for each model based on the underlying
   data structure (single-column for tables with a clear primary key,
   composite for tables where one column was not enough).
4. When the dupe checks surfaced edge cases (`mg_finishing_positions` and
   `mg_prix_winners` had genuine source-data duplicates, and the original
   `race_weather_impact_mrt` had multiple weather readings per race that
   broke the unique key by `raceId`), I made the calls on how to handle
   each: small `qualify row_number()` dedup in the two stg models, and
   restructuring the weather mart to aggregate weather across rounds.

## How I used the agent during execution

Across the session I asked Claude to:

1. Read the Final Project PDF and confirm Option 2 was the lowest-risk
   choice given the time available.
2. Survey the Project 10 dbt project I built and produce a concise
   inventory of models, sources, and unique keys so I could pick the right
   incremental configurations.
3. Write the boilerplate dbt configuration for each of the 40 models (the
   `{{ config(materialized='incremental', unique_key=..., incremental_strategy='merge') }}`
   block plus the `{% if is_incremental() %} where _load_time > ... {% endif %}`
   filter), once I had decided what the unique key for each model should be.
4. Generate 15 change-data CSVs (one row per source table) with
   `_load_time = '2025-12-01'`, matching each table's BigQuery schema.
5. Build the Colab notebook, structured to match the style of the example
   notebooks the professor distributed (markdown narration, six numbered
   parts, `bigquery.Client()` setup without explicit Colab auth).
6. Help me debug specific dbt errors I hit while running the project myself
   in my own BigQuery environment, including: a missing source declaration
   when I switched from `f1_data_raw` to `fin_f1_data_raw`, two stg models
   that had duplicate `_load_time` columns from `select *` plus my explicit
   `_load_time`, a CSV column with a `STRING` value that did not parse as
   `INT64`, and a CSV with mismatched column ordering.
7. Suggest the unique-key adjustments I asked it to make based on what I
   observed in the dupe-check output (widening composite keys, adding the
   stg `qualify row_number()` dedup, restructuring the weather mart).

## Review process

For every change the agent proposed:

- I ran every dbt command myself in my own BigQuery environment and read
  the output before approving the next step.
- I executed the Colab notebook in Colab myself, including the
  change-data ingestion and the dupe-check cells.
- When the agent's first-pass model conversions had bugs (a regex it ran
  to update unique keys left trailing tokens in 4 files), I caught the
  errors when dbt failed compilation and pointed them out so it could fix.
- I verified row counts against Project 10 after the initial load.
- I made the final calls on which deviations from Project 10 row counts
  were acceptable (the three intentional dedups noted below) and which
  were not.

## Deviations from Project 10 to flag for the grader

Three tables have intentionally different row counts than the equivalent
Project 10 tables:

- `stg.mg_finishing_positions` (391 vs 394): added stg-level dedup because
  the source has 4 duplicate (rider_name, country) rows.
- `stg.mg_prix_winners` (3075 vs 3083): same fix, 9 dupes in source.
- `mrt.race_weather_impact_mrt` (1126 vs 9483): aggregated weather to one
  row per race using AVG over weather readings, so `raceId` is a clean
  unique key for the incremental MERGE.

I made these calls because the assignment hint reads "if you end up with
duplicates in any table, you have done something wrong" more strongly than
the "nearly identical to Project 10" expectation, and the dedup approach
is also more compatible with how dbt's incremental MERGE strategy expects
the data to look.
