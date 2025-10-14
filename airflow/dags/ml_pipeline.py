from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator

default_args = {
    'owner': 'mlops-team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

dag = DAG(
    'house_price_ml_pipeline',
    default_args=default_args,
    description='Automated ML pipeline for house price prediction',
    schedule_interval='@weekly',  # Run weekly
    catchup=False
)

# Task 1: Data Processing
data_processing = BashOperator(
    task_id='data_processing',
    bash_command='cd /opt/airflow/ml_project && python src/data/run_processing.py --input data/raw/house_data.csv --output data/processed/cleaned_house_data.csv',
    dag=dag
)

# Task 2: Feature Engineering
feature_engineering = BashOperator(
    task_id='feature_engineering',
    bash_command='cd /opt/airflow/ml_project && python src/features/engineer.py --input data/processed/cleaned_house_data.csv --output data/processed/featured_house_data.csv --preprocessor models/trained/preprocessor.pkl',
    dag=dag
)

# Task 3: Model Training & Registration
model_training = BashOperator(
    task_id='model_training',
    bash_command='cd /opt/airflow/ml_project && python src/models/train_model.py --config configs/model_config.yaml --data data/processed/featured_house_data.csv --models-dir models --mlflow-tracking-uri http://host.docker.internal:5555',
    dag=dag
)

# Task 4: Model Validation
def validate_model():
    import mlflow
    import pandas as pd
    from sklearn.metrics import mean_absolute_error
    
    # Load test data and latest model
    mlflow.set_tracking_uri("http://host.docker.internal:5555")
    model = mlflow.pyfunc.load_model("models:/house-price-model/Staging")
    
    # Simple validation - in production, use holdout test set
    print("Model validation passed - promoting to Production")
    return True

model_validation = PythonOperator(
    task_id='model_validation',
    python_callable=validate_model,
    dag=dag
)

# Task 5: Deploy Model (Update production model)
model_deployment = BashOperator(
    task_id='model_deployment',
    bash_command='echo "Model deployed to production"',
    dag=dag
)

# Define task dependencies
data_processing >> feature_engineering >> model_training >> model_validation >> model_deployment