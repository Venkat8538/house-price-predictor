# SageMaker Module
resource "aws_sagemaker_model_package_group" "house_price_model_group" {
  model_package_group_name        = "${var.project_name}-model-group"
  model_package_group_description = "House Price Prediction Model Group"
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