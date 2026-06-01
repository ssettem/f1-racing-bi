# ============================================================
# F1 Capstone — Section D: Business Forecasting
# ARIMA baseline -> ARIMAX (cost-cap regressor) -> Granger causality
# Author: Sujan Settem  (Group D, Lewis University MS Business Analytics)
#
# Documented results:
#   ARIMA(0,2,0) baseline MAPE 3.36%  | 2026=$2.96B 2027=$3.41B 2028=$3.87B
#   ARIMAX cost-cap coef +6.76, AIC 140.08, MAPE 5.03%
#   Granger Lag 1: F=0.22  p=0.6515 (not sig) | Lag 2: F=12.05 p=0.0203 (sig)
# ============================================================

library(readxl); library(dplyr); library(forecast); library(lmtest); library(ggplot2)

# ---- 1. Load and aggregate yearly sponsorship revenue (2015–2025) ----
sponsorship <- read_excel("../data/F1_Racing_DatasetforCapstone_Group-D(MAIN).xlsx",
                          sheet = "fact_sponsorship")

yearly_revenue <- sponsorship %>%
  group_by(season) %>%
  summarise(total_revenue_m = sum(revenue_m)) %>%
  arrange(season)                                   # 11 rows: $470M (2015) -> $2,500M (2025)

revenue_ts <- ts(yearly_revenue$total_revenue_m, start = 2015, frequency = 1)

# ---- 2. ARIMA baseline (Phase 2) ----
arima_model    <- auto.arima(revenue_ts)            # selects ARIMA(0,2,0)
arima_forecast <- forecast(arima_model, h = 3, level = 95)
print(arima_forecast)                               # 2026=2956, 2027=3412, 2028=3868
cat("ARIMA baseline MAPE:", round(accuracy(arima_model)[, "MAPE"], 2), "%\n")  # 3.36%

# ---- 3. ARIMAX: add the 2021 cost cap as an exogenous regulatory shock ----
cost_cap_dummy <- ifelse(yearly_revenue$season >= 2021, 1, 0)   # 0 pre-2021, 1 from 2021

arimax_model <- auto.arima(revenue_ts, xreg = cost_cap_dummy)   # ARIMA(2,0,0) errors
summary(arimax_model)
cat("Cost-cap coefficient:", round(coef(arimax_model)["xreg"], 2), "\n")  # +6.76

future_dummy   <- c(1, 1, 1)                        # cost cap stays active
arimax_forecast <- forecast(arimax_model, xreg = future_dummy, h = 3, level = c(80, 95))
print(arimax_forecast)
cat("ARIMAX MAPE:", round(accuracy(arimax_model)[, "MAPE"], 2), "%\n")    # 5.03%

# ---- 4. Granger causality: does the cost cap PRECEDE revenue change? ----
years_since_cap <- pmax(yearly_revenue$season - 2020, 0)         # 0..0,1,2,3,4,5 intensity
granger_data <- data.frame(revenue = yearly_revenue$total_revenue_m,
                           cap_intensity = years_since_cap)

print(grangertest(revenue ~ cap_intensity, order = 1, data = granger_data))  # F=0.22  p=0.65
print(grangertest(revenue ~ cap_intensity, order = 2, data = granger_data))  # F=12.05 p=0.02
# -> Null rejected at Lag 2: cost cap Granger-causes revenue with a ~2-year transmission lag.

# ---- 5. Per-team 2026 championship forecast (ARIMA loop) ----
standings <- read_excel("../data/F1_Racing_DatasetforCapstone_Group-D(MAIN).xlsx",
                        sheet = "fact_constructor_standings")
top_teams <- c("Mercedes", "Red Bull Racing", "Ferrari", "McLaren")

forecast_team <- function(team_name) {
  td <- standings %>% filter(constructor_name == team_name) %>% arrange(season)
  fc <- forecast(auto.arima(ts(td$points, start = min(td$season), frequency = 1)), h = 1)
  data.frame(Team = team_name, Forecast_2026 = round(as.numeric(fc$mean), 0))
}
championship_2026 <- do.call(rbind, lapply(top_teams, forecast_team)) %>%
  arrange(desc(Forecast_2026))
print(championship_2026)            # McLaren 640, Red Bull 544, Mercedes 468, Ferrari 464

# ---- 6. Export for Tableau dashboards ----
# write.csv(arimax_forecast, "../output/sponsorship_forecast_2026_2028.csv", row.names = FALSE)
# write.csv(championship_2026, "../output/championship_forecast_2026.csv", row.names = FALSE)
