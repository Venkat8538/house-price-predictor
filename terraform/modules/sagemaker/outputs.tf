output "model_package_group_name" {
  description = "Name of the SageMaker model package group"
  value       = aws_sagemaker_model_package_group.house_price_model_group.model_package_group_name
}

output "pipeline_name" {
  description = "Name of the SageMaker pipeline"
  value       = aws_sagemaker_pipeline.house_price_pipeline.pipeline_name
}

output "studio_domain_id" {
  description = "ID of the SageMaker Studio domain"
  value       = var.create_studio_domain ? aws_sagemaker_domain.studio_domain[0].id : null
}

output "model_package_registered" {
  description = "Model package registration status"
  value       = null_resource.register_versioned_model.id
}

output "model_version" {
  description = "Current model version"
  value       = data.external.git_version.result.version
}

output "git_commit" {
  description = "Git commit hash"
  value       = data.external.git_version.result.git_commit
}

output "endpoint_name" {
  description = "SageMaker endpoint name"
  value       = aws_sagemaker_endpoint.house_price_endpoint.name
}

output "endpoint_url" {
  description = "SageMaker endpoint URL"
  value       = "https://runtime.sagemaker.${var.aws_region}.amazonaws.com/endpoints/${aws_sagemaker_endpoint.house_price_endpoint.name}/invocations"
}