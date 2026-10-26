# F1 Cost-Cap Analytics: Forecasting & Predictive Modeling

**Time-Series Forecasting · Predictive Precedence Testing · ML Model Comparison**
MS Business Analytics Capstone, Lewis University, Spring 2026
Author: **Sujan Settem** · sujansettem@gmail.com

---

## My role on this project

This was a three-person capstone (Group D: Teo Verdu Nieva, Sujan Settem, Wajid Mohd). **I personally owned the two quantitative modeling sections** of the analysis:

- **Section D, Business Forecasting:** ARIMA baseline, ARIMAX with a regulatory regressor, and Granger causality testing.
- **Section E, Predictive Modeling:** Random Forest vs. Deep Neural Network comparison to predict constructor championship points.

The shared data layer (the SQL warehouse the team assembled the dataset in) is included as **context only** under `/sql`. It was built collaboratively and this repo is scoped to the modeling I did. Everything in `/forecasting`, `/ml`, and `/regression` reflects modeling I owned: I built and tested the models with AI coding assistants, then chose and interpreted the results myself. I documented the methods in Word and planned the presentation's story in NotebookLM.

---

## The business question

The FIA introduced a **cost cap in 2021** to level the competitive field. I looked at two things:

1. **Did it move the money?** Did sponsorship revenue shift measurably around the regulation, and can that shift be separated from the underlying growth trend?
2. **Can we predict performance?** Can constructor championship points be forecast from prior-year momentum, team identity, and the cost-cap era?

Data: **11 F1 seasons (2015 to 2025)**, covering 233 races, 34 drivers, and 16 constructors. Sponsorship revenue rose from **$470M in 2015 to $2,500M in 2025, a +432% increase**, with a visible inflection when the cost cap landed in 2021.

---

## Headline results

| Metric | Result | What it means |
|---|---|---|
| **3.36%** | ARIMA baseline MAPE | 3-year revenue forecast, 96.6% accurate in-sample |
| **+6.76** | ARIMAX cost-cap coefficient | Size of the upward revenue shift at the 2021 regulation |
| **F=12.05, p=0.02** | Granger test (Lag 2) | Cost-cap intensity has predictive precedence over revenue growth at a 2-year lag |
| **103.52 vs 134.69** | RF vs DNN RMSE | Random Forest beats the neural net on a small panel |

---

## 1. Business forecasting (`/forecasting`)

**ARIMA baseline.** `auto.arima()` selected **ARIMA(0,2,0)** on the yearly revenue series and forecast three years forward: 2026 at roughly $2.96B, 2027 at $3.41B, 2028 at $3.87B. **MAPE 3.36%.**

**ARIMAX upgrade.** I added the 2021 cost cap as an exogenous (0/1) regressor to separate its effect from the underlying trend. Model: ARIMA(2,0,0) errors, **cost-cap coefficient +6.76**, AIC 140.08, MAPE 5.03%. MAPE rises slightly against the baseline. That is the trade-off for being able to attribute the shift to the regulation rather than only fit the curve.

**Granger test.** I tested whether cost-cap intensity (years since 2021) helps predict revenue change beyond what revenue's own history already explains. **Not significant at Lag 1 (F=0.22, p=0.65); significant at Lag 2 (F=12.05, p=0.02).**

A caveat worth stating plainly: Granger causality is a test of *predictive precedence*, not of true causation. It shows that past values of the cost-cap variable improve the forecast of revenue, which is consistent with a causal story but does not establish one. With only 11 annual observations the test is also underpowered, so treat this as suggestive rather than conclusive.

Read that way, the result still has a useful interpretation. Sponsors do not recalibrate budgets instantly. A recognition lag plus contract renegotiation of roughly two years is a plausible mechanism, and it means future regulation should be planned with a delay before commercial effects appear.

**Per-team 2026 championship forecast.** An ARIMA loop over the top teams projects: **McLaren 640 pts, Red Bull 544, Mercedes 468, Ferrari 464.**

---

## 2. Predictive modeling: Random Forest vs. Deep Neural Network (`/ml`)

Goal: predict constructor championship points, and pick the model architecture honestly rather than reaching for the fashionable one.

Features: prior-year points, team identity, season, cost-cap era. Temporal hold-out, **train up to 2023 (76 rows), test from 2024 (20 rows).**

| Model | Tool | RMSE | MAE |
|---|---|---|---|
| **Random Forest** (500 trees) | R `randomForest` | **103.52** | 75.30 |
| Deep Neural Network (128-64-32, ReLU, Adam) | Python `scikit-learn` | 134.69 | 95.21 |

**Random Forest wins by 31 RMSE points.** With only 76 training rows of structured tabular data, averaging 500 diverse trees beats a deep network that needs far more data to justify its parameter count. The DNN comparison is not decoration. It is the evidence that the simpler model is genuinely the better choice here.

The test set is 20 rows, so the RMSE gap should be read as directional rather than precise.

**Feature importance:** prior-year points (21.2%) and team identity (20.6%) dominate; cost-cap era is weak (2.3%). The cap leveled spending but did not erase the momentum advantage of established teams.

---

## 3. Regression baselines (`/regression`)

Phase-1 linear models I used as a benchmark before moving to an ensemble: spend R²=0.689, revenue R²=0.711, spend plus margin R²=0.741. The Random Forest explained 76% of variance and outperformed all of them, which is why the project moved to a tree-based model. Included for context, not as a headline result.

---

## Key insight

The cost cap pushed F1 toward being a capital-allocation problem rather than a pure spending one. Winners score highest on points per dollar, not on the largest balance sheet.

The ARIMAX coefficient sizes the revenue shift around the 2021 regulation, and the Granger test shows the cost-cap variable carries predictive information about revenue at a two-year lag. Together these are consistent with the cap driving the post-2021 revenue surge, though 11 annual observations cannot settle the question on their own.

On the prediction side, championship outcomes are more forecastable than linear regression suggests, and momentum and team identity matter more as signals than era-level regulatory variables.

---

## Tools

`R` (`forecast`, `lmtest`, `randomForest`, `ggplot2`) · `Python` (`scikit-learn`) · `Tableau` · `R Markdown`

## Repository structure

```
f1-racing-bi/
├── README.md
├── forecasting/      # ARIMA + ARIMAX + Granger test  (my work)
│   └── arimax_model.R
├── ml/               # Random Forest (R) vs Deep Neural Net (Python)  (my work)
│   ├── model_comparison.R
│   └── deep_nn.py
├── regression/       # Phase-1 linear baselines  (my work)
│   └── efficiency_regression.R
├── sql/              # Team-built data layer, context only
│   └── schema.sql
└── docs/
    └── F1_BI_Portfolio.pdf
```

> **Note on data and authorship:** Team capstone (Group D). The dataset was compiled by the team from public F1 financial and results sources for an academic project. The modeling code and results in `/forecasting`, `/ml`, and `/regression` are my individual contribution (Sections D and E). Documented metrics reflect the parameters and outputs from the final capstone deliverable.
