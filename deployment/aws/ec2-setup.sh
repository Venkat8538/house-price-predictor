#!/bin/bash

# EC2 Airflow Setup Script
# Run this on your EC2 instance

set -e

echo "🚀 Setting up Airflow on EC2..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# Install Git
sudo apt install -y git

# Clone your repository
cd /home/ubuntu
git clone https://github.com/YOUR_USERNAME/house-price-predictor.git
cd house-price-predictor

# Create directories for persistent data
sudo mkdir -p /opt/airflow/{dags,logs,plugins}
sudo chown -R 50000:0 /opt/airflow

# Copy your docker-compose with production settings
cp deployment/aws/docker-compose-prod.yml docker-compose.yml

# Start Airflow
docker-compose up -d

echo "✅ Airflow setup complete!"
echo "🌐 Access Airflow at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "👤 Username: admin"
echo "🔑 Password: admin"