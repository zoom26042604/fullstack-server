#!/bin/bash
# Clean up orphaned resources

set -e

echo "Cleaning orphaned pods..."
kubectl delete pods --field-selector status.phase=Failed -A 2>/dev/null || true
kubectl delete pods --field-selector status.phase=Unknown -A 2>/dev/null || true

echo "Cleaning completed pods..."
kubectl delete pods --field-selector status.phase=Succeeded -A 2>/dev/null || true

echo "Cleaning evicted pods..."
kubectl get pods -A | grep Evicted | awk '{print "kubectl delete pod " $2 " -n " $1}' | sh 2>/dev/null || true

echo "Cleaning Docker system..."
docker system prune -f 2>/dev/null || true

echo "Cleaning old backups (keeping last 7)..."
ls -dt /srv/backups/k8s-* 2>/dev/null | tail -n +8 | xargs rm -rf 2>/dev/null || true

echo "Done"
