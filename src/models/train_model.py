import argparse
import pandas as pd
import numpy as np
import joblib
import mlflow
import mlflow.sklearn
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import mean_absolute_error, r2_score, mean_squared_error
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.linear_model import LinearRegression
import xgboost as xgb
import yaml
import logging
from contextlib import nullcontext
from mlflow.tracking import MlflowClient
import platform
import sklearn

# -----------------------------
# Configure logging
# -----------------------------
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# -----------------------------
# Argument parser
# -----------------------------
def parse_args():
    parser = argparse.ArgumentParser(description="Train and register final model from config.")
    parser.add_argument("--config", type=str, required=True, help="Path to model_config.yaml")
    parser.add_argument("--data", type=str, required=True, help="Path to processed CSV dataset")
    parser.add_argument("--models-dir", type=str, required=True, help="Directory to save trained model")
    parser.add_argument("--mlflow-tracking-uri", type=str, default=None, help="MLflow tracking URI")
    return parser.parse_args()

# -----------------------------
# Load model from config
# -----------------------------
def get_model_instance(name, params):
    model_map = {
        'LinearRegression': LinearRegression,
        'RandomForest': RandomForestRegressor,
        'GradientBoosting': GradientBoostingRegressor,
        'XGBoost': xgb.XGBRegressor
    }
    if name not in model_map:
        raise ValueError(f"Unsupported model: {name}")
    return model_map[name](**params)

# -----------------------------
# Main logic
# -----------------------------
def main(args):
    # Load config
    with open(args.config, 'r') as f:
        config = yaml.safe_load(f)
    model_cfg = config['model']

    # Disable MLflow for Airflow execution
    use_mlflow = args.mlflow_tracking_uri is not None
    if use_mlflow:
        mlflow.set_tracking_uri(args.mlflow_tracking_uri)
        mlflow.set_experiment(model_cfg['name'])

    # Load data
    data = pd.read_csv(args.data)
    target = model_cfg['target_variable']

    # Use all features except the target variable
    X = data.drop(columns=[target])
    y = data[target]
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # Get model
    model = get_model_instance(model_cfg['best_model'], model_cfg['parameters'])

    # Start MLflow run (if enabled)
    mlflow_context = mlflow.start_run(run_name="enhanced_training_v2") if use_mlflow else nullcontext()
    with mlflow_context:
        logger.info(f"Training enhanced model: {model_cfg['best_model']}")
        
        # Perform cross-validation
        cv_scores = cross_val_score(model, X_train, y_train, cv=5, scoring='r2')
        cv_mean = float(np.mean(cv_scores))
        cv_std = float(np.std(cv_scores))
        
        # Train final model
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)

        # Calculate enhanced metrics
        mae = float(mean_absolute_error(y_test, y_pred))
        mse = float(mean_squared_error(y_test, y_pred))
        rmse = float(np.sqrt(mse))
        r2 = float(r2_score(y_test, y_pred))

        # Log params and enhanced metrics (if MLflow enabled)
        if use_mlflow:
            mlflow.log_params(model_cfg['parameters'])
            mlflow.log_metrics({
                'mae': mae,
                'mse': mse, 
                'rmse': rmse,
                'r2': r2,
                'cv_r2_mean': cv_mean,
                'cv_r2_std': cv_std
            })
            mlflow.sklearn.log_model(model, "tuned_model")

        # Save model locally
        model_name = model_cfg['name']
        save_path = f"{args.models_dir}/trained/{model_name}.pkl"
        joblib.dump(model, save_path)
        logger.info(f"Saved enhanced model to: {save_path}")
        logger.info(f"Enhanced metrics - MAE: {mae:.2f}, RMSE: {rmse:.2f}, R²: {r2:.4f}, CV R²: {cv_mean:.4f}±{cv_std:.4f}")

if __name__ == "__main__":
    args = parse_args()
    main(args)
# Enhanced model with cross-validation
# Added RMSE and MSE metrics
# Improved model evaluation
