# SageMaker Module
resource "aws_sagemaker_model_package_group" "house_price_model_group" {
  model_package_group_name        = "${var.project_name}-model-group"
  model_package_group_description = "House Price Prediction Model Group"
}

# SageMaker Pipeline
resource "aws_sagemaker_pipeline" "house_price_pipeline" {
  pipeline_name         = "${var.project_name}-pipeline"
  pipeline_display_name = "${var.project_name}-ml-pipeline"
  role_arn             = var.sagemaker_execution_role_arn
  
  pipeline_definition = jsonencode({
    Version = "2020-12-01"
    Metadata = {}
    Parameters = [
      {
        Name = "ProcessingInstanceType"
        Type = "String"
        DefaultValue = "ml.t3.medium"
      },
      {
        Name = "TrainingInstanceType" 
        Type = "String"
        DefaultValue = "ml.m5.large"
      }
    ]
    Steps = [
      {
        Name = "ProcessData"
        Type = "Processing"
        Arguments = {
          ProcessingResources = {
            ClusterConfig = {
              InstanceType = "ml.t3.medium"
              InstanceCount = 1
              VolumeSizeInGB = 30
            }
          }
          AppSpecification = {
            ImageUri = var.ecr_repository_url
            ContainerEntrypoint = ["python3", "src/data/run_processing.py"]
          }
          ProcessingInputs = [
            {
              InputName = "input-1"
              S3Input = {
                S3Uri = "s3://${var.s3_bucket_name}/data/raw/"
                LocalPath = "/opt/ml/processing/input"
                S3DataType = "S3Prefix"
                S3InputMode = "File"
              }
            }
          ]
          ProcessingOutputConfig = {
            Outputs = [
              {
                OutputName = "cleaned_data"
                S3Output = {
                  S3Uri = "s3://${var.s3_bucket_name}/data/cleaned/"
                  LocalPath = "/opt/ml/processing/output"
                  S3UploadMode = "EndOfJob"
                }
              }
            ]
          }
          RoleArn = var.sagemaker_execution_role_arn
        }
      },
      {
        Name = "FeatureEngineering"
        Type = "Processing"
        DependsOn = ["ProcessData"]
        Arguments = {
          ProcessingResources = {
            ClusterConfig = {
              InstanceType = "ml.t3.medium"
              InstanceCount = 1
              VolumeSizeInGB = 30
            }
          }
          AppSpecification = {
            ImageUri = var.ecr_repository_url
            ContainerEntrypoint = ["python3", "src/features/engineer.py"]
          }
          ProcessingInputs = [
            {
              InputName = "cleaned-data"
              S3Input = {
                S3Uri = "s3://${var.s3_bucket_name}/data/cleaned/"
                LocalPath = "/opt/ml/processing/input"
                S3DataType = "S3Prefix"
                S3InputMode = "File"
              }
            }
          ]
          ProcessingOutputConfig = {
            Outputs = [
              {
                OutputName = "featured_data"
                S3Output = {
                  S3Uri = "s3://${var.s3_bucket_name}/data/featured/"
                  LocalPath = "/opt/ml/processing/output"
                  S3UploadMode = "EndOfJob"
                }
              }
            ]
          }
          RoleArn = var.sagemaker_execution_role_arn
        }
      },
      {
        Name = "TrainModel"
        Type = "Processing"
        DependsOn = ["FeatureEngineering"]
        Arguments = {
          ProcessingResources = {
            ClusterConfig = {
              InstanceType = "ml.m5.large"
              InstanceCount = 1
              VolumeSizeInGB = 30
            }
          }
          AppSpecification = {
            ImageUri = var.ecr_repository_url
            ContainerEntrypoint = ["python3", "src/models/train_model.py"]
          }
          ProcessingInputs = [
            {
              InputName = "training-data"
              S3Input = {
                S3Uri = "s3://${var.s3_bucket_name}/data/featured/"
                LocalPath = "/opt/ml/processing/input"
                S3DataType = "S3Prefix"
                S3InputMode = "File"
              }
            }
          ]
          ProcessingOutputConfig = {
            Outputs = [
              {
                OutputName = "model"
                S3Output = {
                  S3Uri = "s3://${var.s3_bucket_name}/models/"
                  LocalPath = "/opt/ml/processing/output"
                  S3UploadMode = "EndOfJob"
                }
              }
            ]
          }
          RoleArn = var.sagemaker_execution_role_arn
        }
      }
    ]
  })
}

# SageMaker Studio Domain (optional)
resource "aws_sagemaker_domain" "studio_domain" {
  count       = var.create_studio_domain ? 1 : 0
  domain_name = "${var.project_name}-studio"
  auth_mode   = "IAM"
  vpc_id      = var.vpc_id
  subnet_ids  = var.subnet_ids

  default_user_settings {
    execution_role = var.sagemaker_execution_role_arn
  }
}