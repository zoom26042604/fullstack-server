#!/bin/bash
# Backup Kubernetes configurations

set -e

BACKUP_DIR="/srv/backups/k8s-$(date +%Y%m%d-%H%M%S)"

echo "Creating backup in $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

echo "Backing up manifests..."
cp -r /srv/homelab/kubernetes/* "$BACKUP_DIR/"

echo "Backing up namespace resources..."
for ns in infrastructure monitoring nathan-ferre zoom2604; do
    echo "  Namespace: $ns"
    kubectl get all -n "$ns" -o yaml > "$BACKUP_DIR/namespace-$ns.yaml" 2>/dev/null || true
done

echo "Backing up IngressRoutes..."
kubectl get ingressroute -A -o yaml > "$BACKUP_DIR/ingressroutes.yaml"

echo "Backing up PVCs..."
kubectl get pvc -A -o yaml > "$BACKUP_DIR/pvcs.yaml"

echo ""
echo "Backup completed: $BACKUP_DIR"
echo "Size: $(du -sh $BACKUP_DIR | cut -f1)"

# Keep only last 7 backups
echo ""
echo "Cleaning old backups (keeping last 7)..."
ls -dt /srv/backups/k8s-* | tail -n +8 | xargs rm -rf 2>/dev/null || true
echo "Done"
