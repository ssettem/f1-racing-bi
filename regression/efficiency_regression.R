# ============================================================
# F1 Capstone — Phase 1 linear baselines (benchmark for the Random Forest)
# These OLS models set the bar the ensemble had to beat. Documented R²:
#   spend only        R² = 0.689
#   revenue only      R² = 0.711
#   spend + margin    R² = 0.741   (best linear model)
# The Random Forest (76% variance explained) outperformed all of these,
# which is WHY the project moved to a tree-based model. Context, not headline.
# Author: Sujan Settem  (Group D, Lewis University MS Business Analytics)
# ============================================================

df <- read.csv("../data/constructor_features.csv")

m_spend   <- lm(championship_points ~ total_spend_usd_m, data = df)
m_revenue <- lm(championship_points ~ total_revenue_usd_m, data = df)
m_best    <- lm(championship_points ~ total_spend_usd_m + profit_margin, data = df)

cat("R² spend only   :", round(summary(m_spend)$r.squared, 3), "\n")   # 0.689
cat("R² revenue only :", round(summary(m_revenue)$r.squared, 3), "\n") # 0.711
cat("R² spend+margin :", round(summary(m_best)$r.squared, 3), "\n")    # 0.741

# Takeaway: even the best linear model (0.741) was beaten by the Random Forest.
# Linear regression understates how predictable championship points actually are.
