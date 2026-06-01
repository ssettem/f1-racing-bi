# ============================================================
# F1 Capstone — Section E: Deep Neural Network vs Random Forest
# Cross-validates the model choice: does a deep net beat the ensemble?
# Author: Sujan Settem  (Group D, Lewis University MS Business Analytics)
#
# Documented results (same features + same train/test split as the R model):
#   Random Forest (sklearn, 500 trees)      RMSE 103.52   MAE 75.30
#   Deep Neural Network (128-64-32, ReLU)   RMSE 134.69   MAE 95.21
#   -> Random Forest preferred: with 76 training rows, variance reduction
#      from averaging trees beats a deep net that needs far more data.
# ============================================================

import pandas as pd
import numpy as np
from sklearn.neural_network import MLPRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.metrics import mean_squared_error, mean_absolute_error

# ---- Data: one row per constructor-season with prior-year points ----
df = pd.read_csv("../data/constructor_features.csv")
df["cost_cap_era"] = (df["season"] >= 2021).astype(int)

features = ["season", "cost_cap_era", "prev_year_points", "constructor_name"]
X, y = df[features], df["points"]

# Genuine temporal hold-out: train <= 2023 (76 rows), test >= 2024 (20 rows)
train = df["season"] <= 2023
X_train, X_test = X[train], X[~train]
y_train, y_test = y[train], y[~train]

preprocessor = ColumnTransformer([
    ("num", StandardScaler(), ["season", "cost_cap_era", "prev_year_points"]),
    ("cat", OneHotEncoder(handle_unknown="ignore"), ["constructor_name"]),
])

# ---- Deep Neural Network ----
deep_nn = Pipeline([
    ("preprocess", preprocessor),
    ("mlp", MLPRegressor(
        hidden_layer_sizes=(128, 64, 32), activation="relu", solver="adam",
        learning_rate_init=0.005, max_iter=3000, early_stopping=True,
        validation_fraction=0.15, n_iter_no_change=50, random_state=42)),
])

# ---- Random Forest baseline ----
rf = Pipeline([
    ("preprocess", preprocessor),
    ("rf", RandomForestRegressor(n_estimators=500, random_state=42)),
])

for name, model in [("Random Forest", rf), ("Deep Neural Network", deep_nn)]:
    model.fit(X_train, y_train)
    pred = model.predict(X_test)
    rmse = np.sqrt(mean_squared_error(y_test, pred))
    mae = mean_absolute_error(y_test, pred)
    print(f"{name:22s}  RMSE {rmse:6.2f}   MAE {mae:6.2f}")

# Conclusion: RF wins by ~31 RMSE points. The DNN comparison is the evidence
# that the simpler ensemble is genuinely superior on this small structured panel.
