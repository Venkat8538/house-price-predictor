import pandas as pd
import joblib
import json
import numpy as np
from sklearn.metrics import mean_absolute_error, r2_score, mean_squared_error
import logging
import os
import sys

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def evaluate_model():
    """Evaluate trained model and determine approval status."""
    
    try:
        # SageMaker paths
        input_path = "/opt/ml/processing/input"
        output_path = "/opt/ml/processing/output"
        
        logger.info("Starting model evaluation")
        logger.info(f"Input path contents: {os.listdir(input_path)}")
        
        # Load model
        model_file = os.path.join(input_path, "model", "house_price_model.pkl")
        if not os.path.exists(model_file):
            logger.error(f"Model file not found: {model_file}")
            logger.info(f"Model directory contents: {os.listdir(os.path.join(input_path, 'model'))}")
            sys.exit(1)
            
        model = joblib.load(model_file)
        logger.info("Model loaded successfully")
        
        # Load test data
        data_path = os.path.join(input_path, "data")
        if not os.path.exists(data_path):
            logger.error(f"Data path not found: {data_path}")
            sys.exit(1)
            
        data_files = [f for f in os.listdir(data_path) if f.endswith('.csv')]
        if not data_files:
            logger.error("No CSV test data found")
            logger.info(f"Data directory contents: {os.listdir(data_path)}")
            sys.exit(1)
        
        test_data = pd.read_csv(os.path.join(data_path, data_files[0]))
        logger.info(f"Loaded test data: {data_files[0]}")
        logger.info(f"Test data columns: {list(test_data.columns)}")
        
        if 'price' not in test_data.columns:
            logger.error("Price column not found in test data")
            sys.exit(1)
            
        X_test = test_data.drop('price', axis=1)
        y_test = test_data['price']
        
        logger.info(f"Test data shape: {X_test.shape}")
        
        # Make predictions
        y_pred = model.predict(X_test)
        
        # Calculate metrics
        mae = float(mean_absolute_error(y_test, y_pred))
        rmse = float(np.sqrt(mean_squared_error(y_test, y_pred)))
        r2 = float(r2_score(y_test, y_pred))
        mape = float(np.mean(np.abs((y_test - y_pred) / y_test)) * 100)
        
        metrics = {
            "mae": mae,
            "rmse": rmse,
            "r2": r2,
            "mape": mape
        }
        
        # Performance gates
        performance_passed = (
            r2 > 0.6 and 
            mae < 80000 and
            mape < 20
        )
        
        # Create evaluation report
        report = {
            "metrics": metrics,
            "performance_passed": performance_passed,
            "model_approved": performance_passed,
            "thresholds": {
                "min_r2": 0.6,
                "max_mae": 80000,
                "max_mape": 20
            }
        }
        
        # Save evaluation report
        os.makedirs(output_path, exist_ok=True)
        report_file = os.path.join(output_path, "evaluation.json")
        with open(report_file, "w") as f:
            json.dump(report, f, indent=2)
        
        logger.info(f"Evaluation completed:")
        logger.info(f"  R²: {r2:.4f}")
        logger.info(f"  MAE: {mae:.2f}")
        logger.info(f"  RMSE: {rmse:.2f}")
        logger.info(f"  MAPE: {mape:.2f}%")
        logger.info(f"  Performance Passed: {performance_passed}")
        
        return report
        
    except Exception as e:
        logger.error(f"Error in evaluation: {str(e)}")
        import traceback
        logger.error(traceback.format_exc())
        sys.exit(1)

if __name__ == "__main__":
    evaluate_model()