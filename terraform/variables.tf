variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "house-price"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "create_studio_domain" {
  description = "Whether to create SageMaker Studio domain (expensive)"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for SageMaker Studio (if enabled)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs for SageMaker Studio (if enabled)"
  type        = list(string)
  default     = []
}

variable "github_username" {
  description = "GitHub username for repository reference"
  type        = string
  default     = "your-github-username"
}