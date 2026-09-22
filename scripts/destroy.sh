#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Automated Teardown Script for LAMP Stack Infrastructure & Application
# ---------------------------------------------------------------------------
set -euo pipefail

echo "========================================================"
echo "🧹 Starting Automated Resource Teardown"
echo "========================================================"

# 1. Teardown Kubernetes Resources
echo "[1/2] Cleaning up Kubernetes workloads..."
cd kubernetes
kubectl delete -f frontend-hpa.yaml -f mysql-hpa.yaml -f frontend-service.yaml -f frontend-deployment.yaml --ignore-not-found
kubectl delete -f mysql-networkpolicy.yaml -f mysql-statefulset.yaml -f mysql-pv.yaml --ignore-not-found
kubectl delete -f mysql-backup-cronjob.yaml --ignore-not-found
kubectl delete -f secret.yaml -f configmap.yaml -f namespace.yaml --ignore-not-found
cd ..

# 2. Teardown Local Containers
echo "[2/2] Cleaning up Docker Compose containers..."
cd app
docker compose down -v --remove-orphans || true
cd ..

echo "========================================================"
echo "✅ Teardown completed successfully!"
echo "========================================================"
