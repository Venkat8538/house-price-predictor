output "s3_bucket_name" {
  description = "Name of the S3 bucket for MLOps artifacts"
  value       = module.s3.bucket_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}

output "sagemaker_execution_role_arn" {
  description = "SageMaker execution role ARN"
  value       = module.iam.sagemaker_execution_role_arn
}

output "model_package_group_name" {
  description = "SageMaker model package group name"
  value       = module.sagemaker.model_package_group_name
}

output "sagemaker_pipeline_name" {
  description = "SageMaker pipeline name"
  value       = module.sagemaker.pipeline_name
}

output "eventbridge_rule_name" {
  description = "EventBridge rule name for pipeline triggers"
  value       = module.eventbridge.rule_name
}

output "model_package_registered" {
  description = "Model package registration status"
  value       = module.sagemaker.model_package_registered
}

output "sagemaker_endpoint_name" {
  description = "SageMaker endpoint name"
  value       = module.sagemaker.endpoint_name
}

output "sagemaker_endpoint_url" {
  description = "SageMaker endpoint URL for inference"
  value       = module.sagemaker.endpoint_url
}

output "model_version" {
  description = "Current model version with Git commit"
  value       = module.sagemaker.model_version
}

output "git_commit" {
  description = "Git commit hash used for versioning"
  value       = module.sagemaker.git_commit
}