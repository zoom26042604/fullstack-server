#!/bin/bash
# Restart a deployment

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <service-name> [namespace]"
    echo ""
    echo "Available services:"
    kubectl get deployments -A --no-headers | awk '{printf "  %s (namespace: %s)\n", $2, $1}'
    exit 1
fi

SERVICE=$1
NAMESPACE=${2:-}

if [ -z "$NAMESPACE" ]; then
    NAMESPACE=$(kubectl get deployment -A | grep "$SERVICE" | head -1 | awk '{print $1}')
fi

if [ -z "$NAMESPACE" ]; then
    echo "Error: Service '$SERVICE' not found"
    exit 1
fi

echo "Restarting $SERVICE in namespace $NAMESPACE..."
kubectl rollout restart deployment/"$SERVICE" -n "$NAMESPACE"
echo "Waiting for rollout to complete..."
kubectl rollout status deployment/"$SERVICE" -n "$NAMESPACE"
echo "Done"
