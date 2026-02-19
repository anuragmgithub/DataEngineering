#!/bin/bash
set -e

ENV=${1:-dev}
NAMESPACE=airflow
RELEASE_NAME=airflow

echo "Deploying Airflow to $ENV..."

# 1. Create namespace
kubectl apply -f iac/kubernetes/airflow/namespace.yaml

# 2. Apply secrets
kubectl apply -f iac/kubernetes/airflow/secrets.yaml

# 3. Add repo (idempotent)
helm repo add apache-airflow https://airflow.apache.org || true
helm repo update

# 4. Deploy via Helm
helm upgrade --install $RELEASE_NAME apache-airflow/airflow \
  --namespace $NAMESPACE \
  --values iac/helm/airflow/values-${ENV}.yaml

echo "✅ Airflow deployment triggered"
