#!/bin/bash
# ================================
# Setup Kubernetes Namespaces
# ================================

set -e

echo "🏗️  Creating Kubernetes namespaces..."

# Create namespaces
kubectl create namespace infrastructure --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace nathan-ferre --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace zoom2604 --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -

# Label namespaces
kubectl label namespace infrastructure app.kubernetes.io/part-of=homelab --overwrite
kubectl label namespace nathan-ferre app.kubernetes.io/part-of=homelab --overwrite
kubectl label namespace zoom2604 app.kubernetes.io/part-of=homelab --overwrite
kubectl label namespace monitoring app.kubernetes.io/part-of=homelab --overwrite
kubectl label namespace cert-manager app.kubernetes.io/part-of=homelab --overwrite

echo "✅ Namespaces created:"
kubectl get namespaces --show-labels | grep homelab
