# Terraform MLOps Infrastructure

## 🚀 One-Command Deployment

This Terraform configuration creates a complete MLOps infrastructure on AWS:

- **EC2 Instance** (t2.micro - Free Tier)
- **Security Groups** (ports 22, 8080, 5555, 8000, 8501)
- **Elastic IP** (static IP address)
- **Automated Setup** (Docker, Airflow, MLflow, ML services)

## 📋 Prerequisites

1. **AWS CLI configured**
   ```bash
   aws configure
   ```

2. **Terraform installed**
   ```bash
   # macOS
   brew install terraform
   
   # Ubuntu
   wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt update && sudo apt install terraform
   ```

3. **SSH Key Pair**
   ```bash
   # Generate if you don't have one
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

## 🛠️ Deployment Steps

### 1. Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 2. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Deploy (creates everything automatically)
terraform apply
```

### 3. Get Connection Info
```bash
# Get all URLs and connection details
terraform output
```

## 📊 What Gets Created

- **EC2 Instance**: Ubuntu 22.04 with Docker
- **Airflow**: http://YOUR_IP:8080 (admin/admin)
- **MLflow**: http://YOUR_IP:5555
- **FastAPI**: http://YOUR_IP:8000
- **Streamlit**: http://YOUR_IP:8501

## 🔧 Management Commands

```bash
# Check status
terraform show

# Update infrastructure
terraform apply

# Destroy everything
terraform destroy

# SSH to server
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -raw instance_public_ip)
```

## 💰 Cost Estimate

- **EC2 t2.micro**: Free for 12 months
- **EBS 20GB**: ~$2/month
- **Elastic IP**: Free when attached
- **Data Transfer**: Minimal

**Total**: ~$2/month (after free tier)

## 🔍 Troubleshooting

**Check deployment logs:**
```bash
ssh -i ~/.ssh/id_rsa ubuntu@$(terraform output -raw instance_public_ip)
sudo tail -f /var/log/cloud-init-output.log
```

**Restart services:**
```bash
sudo systemctl restart mlops-stack
```