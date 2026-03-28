#!/bin/bash
# Infrastructure Status Check

set -e

echo "=== K3s Cluster Status ==="
kubectl cluster-info | head -1
echo ""

echo "=== Nodes ==="
kubectl get nodes
echo ""

echo "=== Deployments ==="
kubectl get deployments -A
echo ""

echo "=== Pods Status ==="
kubectl get pods -A
echo ""

echo "=== Services ==="
kubectl get svc -A | grep -E "LoadBalancer|NodePort|ClusterIP.*80"
echo ""

echo "=== IngressRoutes ==="
kubectl get ingressroute -A
echo ""

echo "=== Storage ==="
kubectl get pvc -A
df -h / | grep -E "Filesystem|/dev"
echo ""

echo "=== Issues ==="
FAILING_PODS=$(kubectl get pods -A | grep -v "Running" | grep -v "NAMESPACE" | wc -l)
if [ "$FAILING_PODS" -eq 0 ]; then
    echo "No failing pods"
else
    echo "Failing pods detected:"
    kubectl get pods -A | grep -v "Running" | grep -v "NAMESPACE"
fi
