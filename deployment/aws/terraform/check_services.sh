#!/bin/bash

# MLOps Services Health Check Script
SERVER_IP="34.195.240.100"
SSH_KEY="~/.ssh/id_rsa"

echo "🔍 Checking MLOps Services Status..."
echo "=================================="

# Function to check service
check_service() {
    local service_name=$1
    local port=$2
    local url="http://${SERVER_IP}:${port}"
    
    echo -n "Checking $service_name ($port): "
    if curl -s --connect-timeout 5 "$url" > /dev/null 2>&1; then
        echo "✅ UP"
    else
        echo "❌ DOWN"
    fi
}

# Check all services
check_service "Airflow" "8080"
check_service "MLflow" "5555"
check_service "FastAPI" "8000"
check_service "Streamlit" "8501"

echo ""
echo "🖥️  SSH into server to check details:"
echo "ssh -i ~/.ssh/id_rsa ubuntu@${SERVER_IP}"
echo ""
echo "📋 Quick server status check:"
ssh -i ~/.ssh/id_rsa ubuntu@${SERVER_IP} '
echo "=== Docker Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""
echo "=== Setup Log ==="
tail -5 /var/log/mlops-setup.log 2>/dev/null || echo "Setup log not found yet"
echo ""
echo "=== System Resources ==="
free -h | head -2
df -h / | tail -1
'