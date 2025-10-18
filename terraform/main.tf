# AWS SageMaker MLOps Infrastructure
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Random suffix for unique naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Module
module "s3" {
  source = "./modules/s3"
  
  project_name  = var.project_name
  random_suffix = random_string.suffix.result
}

# IAM Module
module "iam" {
  source = "./modules/iam"
  
  project_name  = var.project_name
  s3_bucket_arn = module.s3.bucket_arn
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"
  
  project_name = var.project_name
}

# SageMaker Module
module "sagemaker" {
  source = "./modules/sagemaker"
  
  project_name                  = var.project_name
  create_studio_domain          = var.create_studio_domain
  vpc_id                        = var.vpc_id
  subnet_ids                    = var.subnet_ids
  sagemaker_execution_role_arn  = module.iam.sagemaker_execution_role_arn
  ecr_repository_url            = module.ecr.repository_url
  s3_bucket_name                = module.s3.bucket_name
}

# EventBridge Module
module "eventbridge" {
  source = "./modules/eventbridge"
  
  project_name = var.project_name
}