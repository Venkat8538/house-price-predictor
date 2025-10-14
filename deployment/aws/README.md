# AWS EC2 Airflow Deployment

## 🚀 Step-by-Step Deployment

### 1. Launch EC2 Instance

**Instance Details:**
- **AMI**: Ubuntu 22.04 LTS
- **Instance Type**: t2.micro (Free Tier)
- **Storage**: 20 GB gp3
- **Security Group**: Create new with these rules:

| Type | Port | Source | Description |
|------|------|--------|-------------|
| SSH | 22 | Your IP | SSH access |
| HTTP | 8080 | 0.0.0.0/0 | Airflow UI |
| HTTP | 5555 | 0.0.0.0/0 | MLflow UI |

### 2. Connect to EC2

```bash
# Download your key pair and connect
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

### 3. Run Setup Script

```bash
# On EC2 instance
wget https://raw.githubusercontent.com/YOUR_USERNAME/house-price-predictor/main/deployment/aws/ec2-setup.sh
chmod +x ec2-setup.sh
./ec2-setup.sh
```

### 4. Update GitHub Secrets

In your GitHub repository settings, update:
- **AIRFLOW_URL**: `http://YOUR_EC2_PUBLIC_IP:8080`
- **AIRFLOW_AUTH**: `YWRtaW46YWRtaW4=`

### 5. Copy DAGs to EC2

```bash
# Copy your DAG file
sudo cp airflow/dags/ml_pipeline.py /opt/airflow/dags/
sudo chown 50000:0 /opt/airflow/dags/ml_pipeline.py
```

### 6. Test the Setup

1. **Access Airflow**: http://YOUR_EC2_PUBLIC_IP:8080
2. **Login**: admin / admin
3. **Enable DAG**: Toggle on `house_price_ml_pipeline`
4. **Test GitHub Actions**: Push code changes

## 🔧 Troubleshooting

**Check Airflow logs:**
```bash
docker-compose logs airflow-webserver
docker-compose logs airflow-scheduler
```

**Restart services:**
```bash
docker-compose restart
```

**Update DAGs:**
```bash
# After code changes
git pull
sudo cp airflow/dags/* /opt/airflow/dags/
sudo chown -R 50000:0 /opt/airflow/dags/
```

## 💰 Cost Estimate

- **EC2 t2.micro**: Free for 12 months
- **EBS 20GB**: ~$2/month
- **Data Transfer**: Minimal for testing

**Total**: ~$2/month (after free tier)