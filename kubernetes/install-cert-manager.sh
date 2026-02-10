#!/bin/bash
# ================================
# Install cert-manager via Helm
# ================================

set -e

echo "🔐 Installing cert-manager..."

# Add Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install cert-manager
helm install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.14.2 \
    --set installCRDs=true \
    --set global.leaderElection.namespace=cert-manager

echo "⏳ Waiting for cert-manager to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n cert-manager
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n cert-manager
kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-cainjector -n cert-manager

echo "✅ cert-manager installed successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Create ClusterIssuer: kubectl apply -f infrastructure/cert-manager-issuer.yaml"
echo "   2. Verify: kubectl get clusterissuer"
