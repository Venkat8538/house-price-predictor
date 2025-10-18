import sagemaker
from sagemaker.workflow.pipeline import Pipeline
from sagemaker.workflow.steps import ProcessingStep, TrainingStep
from sagemaker.sklearn.processing import SKLearnProcessor
from sagemaker.sklearn.estimator import SKLearn

def create_pipeline():
    # Get SageMaker session and role
    session = sagemaker.Session()
    role = "arn:aws:iam::027419661856:role/house-price-sagemaker-execution-role"
    
    # Processing step
    processor = SKLearnProcessor(
        framework_version="1.0-1",
        role=role,
        instance_type="ml.t3.medium",
        instance_count=1,
        image_uri="027419661856.dkr.ecr.us-east-1.amazonaws.com/house-price-mlops:latest"
    )
    
    processing_step = ProcessingStep(
        name="ProcessData",
        processor=processor,
        code="src/data/run_processing.py",
        inputs=[
            sagemaker.processing.ProcessingInput(
                source="s3://house-price-mlops-fmrtdp01/data/raw/",
                destination="/opt/ml/processing/input"
            )
        ],
        outputs=[
            sagemaker.processing.ProcessingOutput(
                output_name="processed_data",
                source="/opt/ml/processing/output",
                destination="s3://house-price-mlops-fmrtdp01/data/processed/"
            )
        ]
    )
    
    # Training step
    estimator = SKLearn(
        entry_point="src/models/train_model.py",
        role=role,
        instance_type="ml.m5.large",
        framework_version="1.0-1",
        image_uri="027419661856.dkr.ecr.us-east-1.amazonaws.com/house-price-mlops:latest"
    )
    
    training_step = TrainingStep(
        name="TrainModel",
        estimator=estimator,
        inputs={
            "training": sagemaker.inputs.TrainingInput(
                s3_data="s3://house-price-mlops-fmrtdp01/data/processed/",
                content_type="text/csv"
            )
        }
    )
    
    # Create pipeline
    pipeline = Pipeline(
        name="house-price-pipeline",
        steps=[processing_step, training_step],
        sagemaker_session=session
    )
    
    return pipeline

if __name__ == "__main__":
    pipeline = create_pipeline()
    pipeline.upsert(role_arn="arn:aws:iam::027419661856:role/house-price-sagemaker-execution-role")
    execution = pipeline.start()
    print(f"Pipeline execution started: {execution.arn}")