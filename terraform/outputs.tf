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