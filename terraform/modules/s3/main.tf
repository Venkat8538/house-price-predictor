# S3 Module for MLOps Data Storage
resource "aws_s3_bucket" "mlops_bucket" {
  bucket = "${var.project_name}-mlops-${var.random_suffix}"
}

resource "aws_s3_bucket_versioning" "mlops_bucket_versioning" {
  bucket = aws_s3_bucket.mlops_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mlops_bucket_encryption" {
  bucket = aws_s3_bucket.mlops_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "mlops_bucket_pab" {
  bucket = aws_s3_bucket.mlops_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}