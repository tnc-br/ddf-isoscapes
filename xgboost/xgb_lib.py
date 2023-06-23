
import partition
import xgboost as xgb


def train_xgb(dataset: partition.PartitionedDataset, booster: str, rounds: int, verbose: int=0) -> xgb.XGBRegressor:
  xgb_model = xgb.XGBRegressor(n_estimators=rounds, eta=0.1, max_depth=2, objective='reg:squarederror', booster=booster)
  # split dataset into input and output columns
  X, y = dataset.train.iloc[:, :-1], dataset.train.iloc[:, -1]
  X_val, y_val = dataset.validation.iloc[:, :-1], dataset.validation.iloc[:, -1]
  print(f"Predicting: {dataset.train.columns[-1]}")
  xgb_model.fit(X, y, eval_set=[(X_val, y_val)], verbose=verbose)
  return xgb_model


def train_or_load_xgboost(basename: str, dataset: partition.PartitionedDataset, rounds: int=100000, verbose: int=0, rebuild: bool=False):
  if rebuild:
    print("Training model")
    model = train_xgb(dataset, booster='gblinear', rounds=rounds)
    with open(f"{basename}_config_xgb.json", "w") as f:
      f.write(model.get_booster().save_config())
    model.save_model(f"{basename}_xgb.json")
  else:
    print("Loading model")
    model = xgb.XGBRegressor()
    model.load_model(f"{basename}_xgb.json")
    with open(f"{basename}_config_xgb.json", "r") as f:
      model.get_booster().load_config(f.read())
  print(f"RMSE (validation): {model.evals_result()['validation_0']['rmse'][-1]}")
  return model