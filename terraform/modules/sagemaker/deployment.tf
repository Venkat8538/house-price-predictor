# Get latest model package
data "external" "latest_model_package" {
  program = ["bash", "-c", <<-EOT
    MODEL_ARN=$(aws sagemaker list-model-packages \
      --model-package-group-name ${aws_sagemaker_model_package_group.house_price_model_group.model_package_group_name} \
      --region ${var.aws_region} \
      --query 'ModelPackageSummaryList[0].ModelPackageArn' \
      --output text)
    echo "{\"model_package_arn\": \"$MODEL_ARN\"}"
  EOT
  ]
}

# Approve model package
resource "null_resource" "approve_model" {
  provisioner "local-exec" {
    command = <<-EOT
      aws sagemaker update-model-package \
        --model-package-arn ${data.external.latest_model_package.result.model_package_arn} \
        --model-approval-status Approved \
        --region ${var.aws_region}
    EOT
  }
  
  triggers = {
    model_arn = data.external.latest_model_package.result.model_package_arn
  }
}

# SageMaker Model
resource "aws_sagemaker_model" "house_price_model" {
  name               = "${var.project_name}-model"
  execution_role_arn = var.sagemaker_execution_role_arn

  primary_container {
    image          = "${var.ecr_repository_url}:sagemaker"
    model_data_url = "s3://${var.s3_bucket_name}/models/house-price-model/latest/model.tar.gz"
  }

  depends_on = [null_resource.approve_model]
}

# SageMaker Endpoint Configuration
resource "aws_sagemaker_endpoint_configuration" "house_price_config" {
  name = "${var.project_name}-endpoint-config"

  production_variants {
    variant_name           = "primary"
    model_name            = aws_sagemaker_model.house_price_model.name
    initial_instance_count = 1
    instance_type         = "ml.t2.medium"
  }
}

# SageMaker Endpoint
resource "aws_sagemaker_endpoint" "house_price_endpoint" {
  name                 = "${var.project_name}-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.house_price_config.name
}