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
        DefaultValue = "ml.t3.medium"
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
              InstanceType = "ml.t3.medium"
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
                  S3Uri = "s3://${var.s3_bucket_name}/models/house-price-model/"
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
        Name = "EvaluateModel"
        Type = "Processing"
        DependsOn = ["TrainModel"]
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
            ContainerEntrypoint = ["python3", "src/models/evaluate_model.py"]
          }
          ProcessingInputs = [
            {
              InputName = "model"
              S3Input = {
                S3Uri = "s3://${var.s3_bucket_name}/models/house-price-model/"
                LocalPath = "/opt/ml/processing/input/model"
                S3DataType = "S3Prefix"
                S3InputMode = "File"
              }
            },
            {
              InputName = "test-data"
              S3Input = {
                S3Uri = "s3://${var.s3_bucket_name}/data/featured/"
                LocalPath = "/opt/ml/processing/input/data"
                S3DataType = "S3Prefix"
                S3InputMode = "File"
              }
            }
          ]
          ProcessingOutputConfig = {
            Outputs = [
              {
                OutputName = "evaluation"
                S3Output = {
                  S3Uri = "s3://${var.s3_bucket_name}/evaluation/"
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
        Name = "RegisterModel"
        Type = "RegisterModel"
        DependsOn = ["EvaluateModel"]
        Arguments = {
          ModelPackageGroupName = "${var.project_name}-model-group"
          ModelApprovalStatus = "PendingManualApproval"
          InferenceSpecification = {
            Containers = [
              {
                Image = var.ecr_repository_url
                ModelDataUrl = "s3://${var.s3_bucket_name}/models/house-price-model/latest/model.tar.gz"
              }
            ]
            SupportedContentTypes = ["application/json"]
            SupportedResponseMIMETypes = ["application/json"]
          }
        }
      }
    ]
  })
}

# Get Git commit for versioning
data "external" "git_version" {
  program = ["bash", "-c", <<-EOT
    GIT_COMMIT=$(git rev-parse HEAD 2>/dev/null | cut -c1-8 || echo "local")
    VERSION="v1.0.0-$GIT_COMMIT"
    echo "{\"version\": \"$VERSION\", \"git_commit\": \"$GIT_COMMIT\"}"
  EOT
  ]
}

# Model Package Registration with versioning
resource "null_resource" "register_versioned_model" {
  provisioner "local-exec" {
    command = <<-EOT
      VERSION="${data.external.git_version.result.version}"
      aws sagemaker create-model-package \
        --model-package-group-name ${aws_sagemaker_model_package_group.house_price_model_group.model_package_group_name} \
        --model-package-description "House Price Model $VERSION" \
        --inference-specification '{
          "Containers": [{
            "Image": "${var.ecr_repository_url}:latest",
            "ModelDataUrl": "s3://${var.s3_bucket_name}/models/house-price-model/$VERSION/model.tar.gz"
          }],
          "SupportedContentTypes": ["application/json"],
          "SupportedResponseMIMETypes": ["application/json"]
        }' \
        --model-approval-status PendingManualApproval \
        --additional-model-data-url "s3://${var.s3_bucket_name}/models/house-price-model/$VERSION/metadata.json" || true
    EOT
  }
  
  triggers = {
    model_group = aws_sagemaker_model_package_group.house_price_model_group.model_package_group_name
    version = data.external.git_version.result.version
  }
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