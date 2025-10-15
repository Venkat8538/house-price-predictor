#!/bin/bash

# Simple MLOps Server Setup Script
set -e

# Update system
apt update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.21.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Git
apt install -y git

# Clone repository (public access)
cd /home/ubuntu
git clone https://github.com/Venkat8538/house-price-predictor.git || echo "Clone failed, continuing..."

# Create basic Airflow setup
mkdir -p /opt/airflow/{dags,logs,plugins}
chown -R 50000:0 /opt/airflow

# Create simple docker-compose for Airflow only
cat > /home/ubuntu/docker-compose-simple.yml << 'EOF'
services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_USER: airflow
      POSTGRES_PASSWORD: airflow
      POSTGRES_DB: airflow
    volumes:
      - postgres_db_volume:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "airflow"]
      interval: 5s
      retries: 5

  airflow-webserver:
    image: apache/airflow:2.7.0
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      AIRFLOW__CORE__EXECUTOR: LocalExecutor
      AIRFLOW__DATABASE__SQL_ALCHEMY_CONN: postgresql+psycopg2://airflow:airflow@postgres/airflow
      AIRFLOW__CORE__FERNET_KEY: 'fb5vZzKzHkzwOtmp8VgJZkJz8VgJZkJz8VgJZkJz8Vg='
      AIRFLOW__CORE__DAGS_ARE_PAUSED_AT_CREATION: 'true'
      AIRFLOW__CORE__LOAD_EXAMPLES: 'false'
      _AIRFLOW_DB_UPGRADE: 'true'
      _AIRFLOW_WWW_USER_CREATE: 'true'
      _AIRFLOW_WWW_USER_USERNAME: admin
      _AIRFLOW_WWW_USER_PASSWORD: admin
    volumes:
      - /opt/airflow/dags:/opt/airflow/dags
      - /opt/airflow/logs:/opt/airflow/logs
      - /opt/airflow/plugins:/opt/airflow/plugins
    ports:
      - "8080:8080"
    command: webserver

  airflow-scheduler:
    image: apache/airflow:2.7.0
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      AIRFLOW__CORE__EXECUTOR: LocalExecutor
      AIRFLOW__DATABASE__SQL_ALCHEMY_CONN: postgresql+psycopg2://airflow:airflow@postgres/airflow
      AIRFLOW__CORE__FERNET_KEY: 'fb5vZzKzHkzwOtmp8VgJZkJz8VgJZkJz8VgJZkJz8Vg='
    volumes:
      - /opt/airflow/dags:/opt/airflow/dags
      - /opt/airflow/logs:/opt/airflow/logs
      - /opt/airflow/plugins:/opt/airflow/plugins
    command: scheduler

volumes:
  postgres_db_volume:
EOF

# Start Airflow
cd /home/ubuntu
docker-compose -f docker-compose-simple.yml up -d

# Log completion
echo "Simple MLOps setup completed at: $(date)" > /var/log/mlops-setup.log
echo "Airflow: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080" >> /var/log/mlops-setup.log