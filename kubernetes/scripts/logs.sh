#!/bin/bash
# View logs for services

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

echo "Logs for $SERVICE in namespace $NAMESPACE"
echo "Press Ctrl+C to exit"
echo ""

kubectl logs -n "$NAMESPACE" deployment/"$SERVICE" --tail=100 -f
