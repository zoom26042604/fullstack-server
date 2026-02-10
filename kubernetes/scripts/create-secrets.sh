#!/bin/bash
# ================================
# Create Kubernetes Secrets
# ================================

set -e

echo "🔐 Creating Kubernetes secrets from .env file..."

# Source the .env file
if [ ! -f "../infrastructure/.env" ]; then
    echo "❌ .env file not found in infrastructure directory"
    exit 1
fi

source ../infrastructure/.env

# PostgreSQL Secret
kubectl create secret generic postgres-credentials \
    --from-literal=POSTGRES_USER="$POSTGRES_USER" \
    --from-literal=POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    --from-literal=POSTGRES_DB="$POSTGRES_DB" \
    --namespace=infrastructure \
    --dry-run=client -o yaml | kubectl apply -f -

# Redis Secret
kubectl create secret generic redis-credentials \
    --from-literal=REDIS_PASSWORD="$REDIS_PASSWORD" \
    --namespace=infrastructure \
    --dry-run=client -o yaml | kubectl apply -f -

# Grafana Secret
kubectl create secret generic grafana-credentials \
    --from-literal=admin-user="$GRAFANA_ADMIN_USER" \
    --from-literal=admin-password="$GRAFANA_ADMIN_PASSWORD" \
    --namespace=monitoring \
    --dry-run=client -o yaml | kubectl apply -f -

# Admin App Secrets
kubectl create secret generic admin-app-secrets \
    --from-literal=DATABASE_URL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@postgres.infrastructure.svc.cluster.local:5432/$ADMIN_DB_NAME?schema=public" \
    --from-literal=JWT_SECRET="$ADMIN_JWT_SECRET" \
    --from-literal=NEXTAUTH_SECRET="$NEXTAUTH_SECRET" \
    --from-literal=NEXTAUTH_URL="$NEXTAUTH_URL" \
    --namespace=zoom2604 \
    --dry-run=client -o yaml | kubectl apply -f -

# Traefik Dashboard Secret
TRAEFIK_DASHBOARD_AUTH=$(echo -n "$TRAEFIK_DASHBOARD_USER:$TRAEFIK_DASHBOARD_PASSWORD_HASH" | base64)
kubectl create secret generic traefik-dashboard-auth \
    --from-literal=users="$TRAEFIK_DASHBOARD_USER:$TRAEFIK_DASHBOARD_PASSWORD_HASH" \
    --namespace=infrastructure \
    --dry-run=client -o yaml | kubectl apply -f -

echo "✅ Secrets created successfully!"
echo ""
echo "📋 Verify secrets:"
echo "   kubectl get secrets -n infrastructure"
echo "   kubectl get secrets -n monitoring"
echo "   kubectl get secrets -n zoom2604"
