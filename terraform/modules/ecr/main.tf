# ECR Module for Container Registry
resource "aws_ecr_repository" "mlops_ecr" {
  name = "${var.project_name}-mlops"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "mlops_ecr_policy" {
  repository = aws_ecr_repository.mlops_ecr.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}