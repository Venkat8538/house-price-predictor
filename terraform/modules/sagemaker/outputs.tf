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