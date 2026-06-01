/* ============================================================
   F1 Racing Capstone — Shared Data Layer (TEAM-BUILT, CONTEXT ONLY)
   Galaxy (fact-constellation) schema for SQL Server
   11 seasons (2015–2025) · 233 races · 34 drivers · 16 constructors

   NOTE: This warehouse was assembled by the Group D team to hold the dataset.
   It is NOT my individual contribution — it is included only to show the
   structure my forecasting and ML models (see /forecasting, /ml, /regression)
   were built on top of. My work is the modeling, not this schema.
   Group D · MS Business Analytics Capstone, Lewis University
   ============================================================ */

/* ---------- CONFORMED DIMENSIONS ---------- */

CREATE TABLE dim_season (
    season_key      INT IDENTITY(1,1) PRIMARY KEY,
    year            INT NOT NULL,
    cost_cap_active BIT NOT NULL,          -- 1 from 2021 onward
    cost_cap_usd_m  DECIMAL(8,2) NULL      -- e.g. 145.00
);

CREATE TABLE dim_constructor (
    constructor_key INT IDENTITY(1,1) PRIMARY KEY,
    name            VARCHAR(80) NOT NULL,
    nationality     VARCHAR(50),
    power_unit      VARCHAR(50)
);

CREATE TABLE dim_circuit (
    circuit_key     INT IDENTITY(1,1) PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    country         VARCHAR(60),
    lap_length_km   DECIMAL(5,3)
);

CREATE TABLE dim_driver (
    driver_key      INT IDENTITY(1,1) PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    nationality     VARCHAR(50)
);

CREATE TABLE dim_regulation (
    regulation_key  INT IDENTITY(1,1) PRIMARY KEY,
    name            VARCHAR(100),          -- e.g. 'FIA Financial Regulations 2021'
    category        VARCHAR(50),           -- Financial / Technical / Sporting
    effective_year  INT
);

CREATE TABLE dim_date (
    date_key        INT PRIMARY KEY,
    full_date       DATE,
    year            INT,
    quarter         TINYINT,
    month           TINYINT
);

/* (Additional conformed dims: dim_engine_supplier, dim_sponsor,
   dim_team_principal, dim_tyre_compound — abbreviated here.) */

/* ---------- FACT TABLES ---------- */

CREATE TABLE fact_constructor_season (
    constructor_key     INT NOT NULL REFERENCES dim_constructor(constructor_key),
    season_key          INT NOT NULL REFERENCES dim_season(season_key),
    championship_points INT,
    final_position      INT,
    total_revenue_usd_m DECIMAL(10,2),
    total_spend_usd_m   DECIMAL(10,2),
    spend_efficiency    AS (championship_points * 1.0 / NULLIF(total_spend_usd_m,0)),
    CONSTRAINT pk_fcs PRIMARY KEY (constructor_key, season_key)
);

CREATE TABLE fact_financials (
    constructor_key     INT NOT NULL REFERENCES dim_constructor(constructor_key),
    season_key          INT NOT NULL REFERENCES dim_season(season_key),
    sponsorship_usd_m   DECIMAL(10,2),
    rnd_spend_usd_m     DECIMAL(10,2),
    operational_usd_m   DECIMAL(10,2),
    cap_headroom_usd_m  DECIMAL(10,2),
    CONSTRAINT pk_ff PRIMARY KEY (constructor_key, season_key)
);

CREATE TABLE fact_race_result (
    driver_key      INT NOT NULL REFERENCES dim_driver(driver_key),
    constructor_key INT NOT NULL REFERENCES dim_constructor(constructor_key),
    circuit_key     INT NOT NULL REFERENCES dim_circuit(circuit_key),
    season_key      INT NOT NULL REFERENCES dim_season(season_key),
    finish_position INT,
    points_scored   INT,
    fastest_lap     BIT
);

/* (Further facts: fact_qualifying, fact_pit_stop, fact_compliance,
   fact_sponsorship_deal — same conformed-dimension pattern.) */

/* ---------- PERFORMANCE: indexing for the 20s -> <1s win ---------- */
CREATE NONCLUSTERED INDEX ix_fcs_season
    ON fact_constructor_season (season_key) INCLUDE (championship_points, total_revenue_usd_m);

CREATE NONCLUSTERED INDEX ix_ff_season
    ON fact_financials (season_key) INCLUDE (sponsorship_usd_m, rnd_spend_usd_m);

/* ---------- EXAMPLE ANALYTICAL QUERY ---------- */
-- Revenue & spend efficiency before vs. after the 2021 cost cap
SELECT  c.name                              AS constructor,
        s.cost_cap_active,
        AVG(fcs.total_revenue_usd_m)        AS avg_revenue_m,
        AVG(fcs.spend_efficiency)           AS avg_spend_efficiency
FROM    fact_constructor_season fcs
JOIN    dim_constructor c ON c.constructor_key = fcs.constructor_key
JOIN    dim_season      s ON s.season_key      = fcs.season_key
GROUP BY c.name, s.cost_cap_active
ORDER BY constructor, s.cost_cap_active;
