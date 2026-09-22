#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Automated Deployment Script for LAMP Stack Infrastructure & Application
# ---------------------------------------------------------------------------
set -euo pipefail

echo "========================================================"
echo "🚀 Starting Automated Production Deployment"
echo "========================================================"

# 1. Build Local Docker Container
echo "[1/3] Building application Docker image..."
cd app
docker build -t lamp-web:latest .
cd ..

# 2. Deploy Kubernetes Cluster Resources
echo "[2/3] Deploying Kubernetes workloads..."
cd kubernetes
kubectl apply -f namespace.yaml
kubectl apply -f secret.yaml -f configmap.yaml
kubectl apply -f mysql-pv.yaml -f mysql-statefulset.yaml -f mysql-networkpolicy.yaml
kubectl apply -f frontend-deployment.yaml -f frontend-service.yaml
kubectl apply -f frontend-hpa.yaml -f mysql-hpa.yaml
kubectl apply -f mysql-backup-cronjob.yaml
cd ..

# 3. Validate Terraform Infrastructure Code
echo "[3/3] Validating Terraform AWS infrastructure..."
cd infrastructure/terraform
terraform init -backend=false
terraform validate
cd ../..

echo "========================================================"
echo "✅ Deployment completed successfully!"
echo "========================================================"
