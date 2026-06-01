# F1 Cost-Cap Analytics — Forecasting & Predictive Modeling

**Time-Series Forecasting · Causal Inference · ML Model Comparison**
MS Business Analytics Capstone — Lewis University, Spring 2026
Author: **Sujan Settem** · sujansettem@gmail.com

---

## My role on this project

This was a four-person capstone (Group D: Teo Verdu Nieva, Sujan Settem, Wajid Mohd, Jessica Pascal).
**I personally owned the two quantitative modeling sections** of the analysis:

- **Section D — Business Forecasting:** ARIMA baseline, ARIMAX with a regulatory regressor, and Granger causality testing.
- **Section E — Predictive Modeling:** Random Forest vs. Deep Neural Network comparison to predict constructor championship points.

The shared data layer (the SQL warehouse the team assembled the dataset in) is included as **context only** under `/sql` — it is not my individual work, and this repo is scoped to the modeling I built. Everything in `/forecasting`, `/ml`, and `/regression` reflects code and results I produced.

---

## The business question

The FIA introduced a **cost cap in 2021** to level the competitive field. I tested two things:

1. **Did it move the money?** Did the regulation *cause* a measurable shift in sponsorship revenue — not just correlate with it?
2. **Can we predict performance?** Can constructor championship points be forecast from prior-year momentum, team identity, and the cost-cap era?

Data: **11 F1 seasons (2015–2025)** — 233 races, 34 drivers, 16 constructors. Sponsorship revenue rose **$470M (2015) → $2,500M (2025), a +432% increase**, with a visible inflection when the cost cap landed in 2021.

---

## Headline results

| Metric | Result | What it means |
|---|---|---|
| **3.36%** | ARIMA baseline MAPE | 96.6% accurate 3-year revenue forecast |
| **+6.76** | ARIMAX cost-cap coefficient | Quantified upward revenue shift at the 2021 regulation |
| **F=12.05, p=0.02** | Granger causality (Lag 2) | Cost cap *causes* revenue growth, with a 2-year lag |
| **103.52 vs 134.69** | RF vs DNN RMSE | Random Forest beats the neural net on a small panel |

---

## 1. Business forecasting (`/forecasting`)

**ARIMA baseline.** `auto.arima()` selected **ARIMA(0,2,0)** on the yearly revenue series and forecast three years forward: 2026 ≈ $2.96B, 2027 ≈ $3.41B, 2028 ≈ $3.87B. **MAPE 3.36%.**

**ARIMAX upgrade.** I added the 2021 cost cap as an exogenous (0/1) regressor to isolate its effect from the underlying trend. Model: ARIMA(2,0,0) errors, **cost-cap coefficient +6.76**, AIC 140.08, MAPE 5.03%. (MAPE rises slightly vs. the baseline — the trade-off for being able to *attribute* the shift to the regulation rather than just fit the curve.)

**Granger causality.** To move from correlation to causation, I tested whether cost-cap intensity (years since 2021) precedes revenue change. **Not significant at Lag 1 (F=0.22, p=0.65); significant at Lag 2 (F=12.05, p=0.02).** Interpretation: sponsors don't recalibrate budgets instantly — there's a recognition lag plus a contract-renegotiation lag of roughly two years. Any future regulation should be modeled with a ~2-year delay before commercial effects show up.

**Per-team 2026 championship forecast.** An ARIMA loop over the top teams projects: **McLaren 640 pts (winner), Red Bull 544, Mercedes 468, Ferrari 464.**

## 2. Predictive modeling — Random Forest vs. Deep Neural Network (`/ml`)

Goal: predict constructor championship points and pick the right model architecture honestly.

Features: prior-year points, team identity, season, cost-cap era. Temporal hold-out — **train ≤ 2023 (76 rows), test ≥ 2024 (20 rows).**

| Model | Tool | RMSE | MAE |
|---|---|---|---|
| **Random Forest** (500 trees) | R `randomForest` | **103.52** | 75.30 |
| Deep Neural Network (128-64-32, ReLU, Adam) | Python `scikit-learn` | 134.69 | 95.21 |

**Random Forest wins by 31 RMSE points.** With only 76 training rows of structured tabular data, averaging 500 diverse trees (variance reduction) beats a deep network that needs far more data. The DNN comparison isn't decoration — it's the evidence that the simpler model is genuinely the better choice here.

**Feature importance:** prior-year points (21.2%) and team identity (20.6%) dominate; cost-cap era is weak (2.3%). The cap leveled spending but did **not** erase the momentum advantage of established teams.

## 3. Regression baselines (`/regression`)

Phase-1 linear models I used as a benchmark before the ensemble: spend R²=0.689, revenue R²=0.711, spend+margin R²=0.741. The Random Forest (76% variance explained) outperformed all of them — which is *why* the project moved to a tree-based model. Included here for context, not as a headline result.

---

## Key insight

The cost cap converted F1 from a budget-driven sport into a **capital-allocation** sport: the winners score highest on points-per-dollar, not on the largest balance sheet. The ARIMAX coefficient and the Granger test give statistically grounded evidence that the cap *caused* the post-2021 revenue surge, with a two-year transmission lag that matters for forward planning. The Random Forest shows championship outcomes are more predictable than linear regression suggests — and that momentum and team identity beat era-level regulatory variables as performance signals.

---

## Tools

`R` (`forecast`, `lmtest`, `randomForest`, `ggplot2`) · `Python` (`scikit-learn`) · `Tableau` · `R Markdown`

## Repository structure

```
f1-racing-bi/
├── README.md
├── forecasting/      # ARIMA + ARIMAX + Granger causality  (my work)
│   └── arimax_model.R
├── ml/               # Random Forest (R) vs Deep Neural Net (Python)  (my work)
│   ├── model_comparison.R
│   └── deep_nn.py
├── regression/       # Phase-1 linear baselines  (my work)
│   └── efficiency_regression.R
├── sql/              # Team-built data layer — context only, not my individual work
│   └── schema.sql
└── docs/
    └── F1_BI_Portfolio.pdf
```

> **Note on data & authorship:** Team capstone (Group D). The dataset was compiled by the team from public F1 financial and results sources for an academic project. The modeling code and results in `/forecasting`, `/ml`, and `/regression` are my individual contribution (Sections D and E). Documented metrics reflect the parameters and outputs from the final capstone deliverable.
