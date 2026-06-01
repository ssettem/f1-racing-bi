# Data

The dataset was compiled by the Group D team from public Formula 1 financial and
race-results sources, covering **11 seasons (2015–2025)** — 233 races, 34 drivers,
16 constructors. It was held in a shared SQL Server galaxy-schema warehouse
(see `../sql/schema.sql`, team-built, context only).

Source workbook (team file): `F1_Racing_DatasetforCapstone_Group-D(MAIN).xlsx`
Sheets used by my modeling scripts:

- `fact_sponsorship` — season-level sponsorship revenue ($470M in 2015 → $2,500M in 2025)
- `fact_constructor_standings` — constructor championship points by season

The Python script (`../ml/deep_nn.py`) and the regression baseline read a flat
`constructor_features.csv` export (one row per constructor-season with prior-year points).

Raw source data is not redistributed here. The scripts document the methodology and
modeling parameters used to produce the project's reported results.
