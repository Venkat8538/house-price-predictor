# SageMaker MLOps Infrastructure with Terraform

This Terraform configuration creates the complete AWS SageMaker MLOps infrastructure based on the AWS architecture diagram.

## Architecture Components

- **S3 Bucket**: Data and model artifacts storage
- **CodeCommit**: Source code repository
- **ECR**: Container registry for custom images
- **SageMaker Model Registry**: Model versioning and management
- **EventBridge**: Scheduled pipeline triggers
- **IAM Roles**: Proper permissions for SageMaker
- **SageMaker Studio** (optional): Development environment

## Cost Estimation

### Minimal Setup (Studio disabled)
- **S3 Storage**: ~$1-5/month
- **CodeCommit**: Free (up to 5 users)
- **ECR**: ~$1/month
- **EventBridge**: ~$1/month
- **Total**: ~$5-10/month

### With SageMaker Studio
- **Studio Domain**: ~$50/month
- **Notebook Instances**: ~$36-72/month (ml.t3.medium/large)
- **Total**: ~$90-130/month

## Quick Start

1. **Copy variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars:**
   ```hcl
   aws_region = "us-east-1"
   project_name = "house-price"
   create_studio_domain = false  # Set to true if you want Studio
   ```

3. **Deploy infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Get outputs:**
   ```bash
   terraform output
   ```

## Usage

After deployment, you'll have:
- S3 bucket for storing data and models
- CodeCommit repository for your ML code
- ECR repository for custom containers
- SageMaker Model Registry for model versions
- EventBridge rule for automated triggers

## Cleanup

```bash
terraform destroy
```

## Next Steps

1. Upload your house price data to the S3 bucket
2. Push your ML code to CodeCommit
3. Create SageMaker pipelines using the provided execution role
4. Set up automated model training and deployment