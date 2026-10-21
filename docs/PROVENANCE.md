# Contributions and provenance

This is a curated derivative of the CS 333E Spring 2026 motorsports coursework repository, developed by Marco Cheung and Pranav Pudu at UT Austin. It is not a claim of sole authorship.

Source repository: `https://github.com/cs333e-spring2026/cs333e-pranav` (private).

Source snapshot: `c131647d9d8a1ef4cc2b3e10c19246eacf5d316c`.

The inherited model and macro code comes from `final_project/f1_data/`. Raw column names/types were recovered from `project10/f1_data/target/catalog.json`. The complete course repository, submission artifacts, and generated build history are intentionally omitted.

## Coursework contributions

| Contributor | Evidence in the upstream history | Scope supported by that evidence |
| --- | --- | --- |
| Marco Cheung (`marcopolocheung`) | `c8606e5`, `be233c3` | dbt staging and normalization models and supporting project artifacts |
| Marco Cheung | `cf58dc5`, `e844487`, `d3c4064`, `117a905` | Earlier notebooks, circuit-data fixes, and normalization submissions |
| Marco Cheung | `19b7c86`, `c131647` | Lineage and final presentation artifacts |
| Pranav Pudu (`PranavPudu1`) | `16a2c5f`, `3646492` | Normalized-layer tests, mart integration, deduplication, and project fixes |
| Pranav Pudu | `1a2b2fc` | Final incremental conversion, change-data ingestion notebook, synthetic change CSVs, and duplicate checks |

Commit attribution describes repository evidence and does not establish who wrote every line or capture all collaboration. The upstream repository also includes earlier scaffold/coursework commits from `tarumishra9498` and Sai Surya. The final presentation names Marco and Pranav; its incremental-project slides credit Pranav. Public sharing of the shared coursework was confirmed by Marco before this repository was published.

## Portfolio edition

The portfolio edition was prepared for Marco with Codex assistance. New work includes configuration parameterization, the DuckDB execution path, independently invented fixtures, a Python GCS ingestion command adapted from the notebook workflow, behavioral tests and CI, documentation, and the correctness changes listed in [DESIGN.md](DESIGN.md).

The original incremental implementation is credited to Pranav. The 40-model count and seven marts describe the team project's architecture; they should not be presented as 40 models written independently by Marco. New automated engineering work should also be described as assisted work rather than retroactively attributed to the coursework.

The upstream agent-use disclosure is preserved in [COURSEWORK_AGENT_DISCLOSURE.md](COURSEWORK_AGENT_DISCLOSURE.md). It is the original final-project author's account of that workflow, not a statement that Marco performed those steps.

## Data and licensing

The historical project used F1/MotoGP datasets from Kaggle and other providers. This repository redistributes none of those historical records or images. `fixtures/` contains only invented demonstration records. The source schemas and inherited transformations retain their coursework names for traceability, including the misspellings `Constructure` and `Safety_Fatailities`.

The upstream repository has no declared software license. This derivative preserves attribution and does not add a license granting rights over inherited code. Public availability should not be interpreted as an unrestricted redistribution license. Contact the contributors to establish reuse terms beyond reviewing this portfolio.
