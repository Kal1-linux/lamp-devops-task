#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Automated Infrastructure & Application Health Check Script
# ---------------------------------------------------------------------------
set -euo pipefail

echo "========================================================"
echo "🩺 Running Infrastructure Health Diagnostics"
echo "========================================================"

# 1. Check Docker Daemon
echo -n "Checking Docker status: "
if docker info > /dev/null 2>&1; then
    echo "OK (Running)"
else
    echo "ERROR (Daemon unreachable)"
fi

# 2. Check Kubernetes Nodes
echo -n "Checking Kubernetes Cluster status: "
if kubectl get nodes > /dev/null 2>&1; then
    echo "OK"
    kubectl get nodes -o wide
else
    echo "WARN (No active kubectl context)"
fi

# 3. Check AWS STS Identity
echo -n "Checking AWS STS Credentials: "
if aws sts get-caller-identity > /dev/null 2>&1; then
    echo "OK"
    aws sts get-caller-identity --output json
else
    echo "WARN (AWS CLI not configured)"
fi

echo "========================================================"
echo "✅ Health check completed!"
echo "========================================================"
