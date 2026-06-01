# ============================================================
# F1 Capstone — Section E: Random Forest (R)
# Predicts constructor championship points; benchmarked in Python (see deep_nn.py).
# Author: Sujan Settem  (Group D, Lewis University MS Business Analytics)
#
# Documented results: RF 76.44% variance explained | Test RMSE 103.52 | MAE 75.30
# (Python deep neural net comparison: RMSE 134.69 -> RF preferred. See deep_nn.py.)
# ============================================================

library(readxl); library(dplyr); library(randomForest)

# ---- Feature engineering: prior-year points + team identity + cost-cap era ----
standings <- read_excel("../data/F1_Racing_DatasetforCapstone_Group-D(MAIN).xlsx",
                        sheet = "fact_constructor_standings")

rf_data <- standings %>%
  filter(!is.na(points)) %>%
  arrange(constructor_name, season) %>%
  group_by(constructor_name) %>%
  mutate(prev_year_points = lag(points, 1)) %>%
  ungroup() %>%
  filter(!is.na(prev_year_points)) %>%
  mutate(
    constructor_name = as.factor(constructor_name),
    cost_cap_era     = as.factor(ifelse(season >= 2021, "Cap Era", "Pre-Cap Era")),
    season           = as.numeric(season)
  )

# Genuine temporal hold-out
rf_train <- rf_data %>% filter(season <= 2023)   # 76 rows
rf_test  <- rf_data %>% filter(season >= 2024)   # 20 rows

# ---- Random Forest (500 trees) ----
set.seed(42)
rf_model <- randomForest(
  points ~ season + constructor_name + cost_cap_era + prev_year_points,
  data = rf_train, ntree = 500, importance = TRUE
)
print(rf_model)                                  # ~76.44% variance explained

rf_pred <- predict(rf_model, newdata = rf_test)
rmse <- sqrt(mean((rf_test$points - rf_pred)^2)) # 103.52
mae  <- mean(abs(rf_test$points - rf_pred))      # 75.30
cat("Random Forest  RMSE:", round(rmse, 2), " MAE:", round(mae, 2), "\n")

# ---- Feature importance: which drivers explain championship points? ----
print(importance(rf_model))
# prev_year_points (21.2%) and constructor_name (20.6%) dominate;
# cost_cap_era weak (2.3%) -> the cap leveled spend but not the momentum advantage.

# write.csv(as.data.frame(importance(rf_model)), "../output/rf_feature_importance.csv")
