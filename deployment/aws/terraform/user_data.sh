#!/bin/bash

# MLOps Server Setup Script
# Automatically installs Docker, Airflow, MLflow, and ML services

set -e

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Git and other tools
apt install -y git curl wget unzip

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Clone repository
cd /home/ubuntu
git clone ${github_repo}
cd house-price-predictor

# Create directories for persistent data
mkdir -p /opt/airflow/{dags,logs,plugins}
mkdir -p /opt/mlflow
chown -R 50000:0 /opt/airflow
chown -R ubuntu:ubuntu /opt/mlflow

# Copy production docker-compose
cp deployment/aws/docker-compose-prod.yml docker-compose-airflow.yml

# Copy DAGs
cp airflow/dags/* /opt/airflow/dags/
chown -R 50000:0 /opt/airflow/dags/

# Start Airflow services
docker-compose -f docker-compose-airflow.yml up -d

# Start MLflow
docker-compose -f deployment/mlflow/mlflow-docker-compose.yml up -d

# Start FastAPI and Streamlit
docker-compose -f docker-compose.yaml up -d

# Wait for services to be ready
sleep 60

# Create systemd service for auto-restart
cat > /etc/systemd/system/mlops-stack.service << EOF
[Unit]
Description=MLOps Stack
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/house-price-predictor
ExecStart=/bin/bash -c 'docker-compose -f docker-compose-airflow.yml up -d && docker-compose -f deployment/mlflow/mlflow-docker-compose.yml up -d && docker-compose -f docker-compose.yaml up -d'
ExecStop=/bin/bash -c 'docker-compose -f docker-compose-airflow.yml down && docker-compose -f deployment/mlflow/mlflow-docker-compose.yml down && docker-compose -f docker-compose.yaml down'
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

systemctl enable mlops-stack.service

# Log completion
echo "MLOps stack deployed successfully!" > /var/log/mlops-setup.log
echo "Airflow: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080" >> /var/log/mlops-setup.log
echo "MLflow: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):5555" >> /var/log/mlops-setup.log
echo "FastAPI: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8000" >> /var/log/mlops-setup.log
echo "Streamlit: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8501" >> /var/log/mlops-setup.log
echo "Setup completed at: $(date)" >> /var/log/mlops-setup.log