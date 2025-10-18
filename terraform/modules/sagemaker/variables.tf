variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "create_studio_domain" {
  description = "Whether to create SageMaker Studio domain"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "VPC ID for SageMaker Studio"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "Subnet IDs for SageMaker Studio"
  type        = list(string)
  default     = []
}

variable "sagemaker_execution_role_arn" {
  description = "ARN of the SageMaker execution role"
  type        = string
}