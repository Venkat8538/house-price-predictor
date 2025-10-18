import pandas as pd
import numpy as np
import joblib
import xgboost as xgb
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, r2_score
import logging
import os
import sys

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

if __name__ == "__main__":
    # SageMaker processing environment
    input_path = "/opt/ml/processing/input"
    model_path = "/opt/ml/processing/output"
    
    logger.info(f"Looking for CSV files in: {input_path}")
    
    # Find CSV file in input directory
    input_files = [f for f in os.listdir(input_path) if f.endswith('.csv')]
    if not input_files:
        logger.error("No CSV files found in training input directory")
        sys.exit(1)
    
    data_file = os.path.join(input_path, input_files[0])
    logger.info(f"Loading data from: {data_file}")
    
    # Load and train model
    data = pd.read_csv(data_file)
    logger.info(f"Data shape: {data.shape}")
    logger.info(f"Columns: {list(data.columns)}")
    
    X = data.drop(columns=['price'])
    y = data['price']
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    logger.info(f"Training set shape: {X_train.shape}")
    
    # Train XGBoost model
    model = xgb.XGBRegressor(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    
    # Save model
    model_file = os.path.join(model_path, "house_price_model.pkl")
    joblib.dump(model, model_file)
    logger.info(f"Model saved to: {model_file}")
    
    # Log metrics
    y_pred = model.predict(X_test)
    mae = float(mean_absolute_error(y_test, y_pred))
    r2 = float(r2_score(y_test, y_pred))
    
    logger.info(f"Model trained - MAE: {mae:.2f}, R²: {r2:.4f}")
    print(f"Training completed successfully!")
    print(f"MAE: {mae:.2f}, R²: {r2:.4f}")
    print(f"Model saved to {model_path}")
    
    # Exit successfully
    sys.exit(0)
