#!/bin/bash
# ================================
# Install Loki Stack via Helm
# ================================

set -e

echo "📜 Installing Loki Stack (Loki + Promtail)..."

# Add Grafana Helm repository
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create values file for Loki
cat > /tmp/loki-values.yaml <<EOF
loki:
  auth_enabled: false
  commonConfig:
    replication_factor: 1
  storage:
    type: 'filesystem'
  persistence:
    enabled: true
    storageClassName: local-path
    size: 15Gi
  resources:
    requests:
      memory: 256Mi
      cpu: 100m
    limits:
      memory: 512Mi
      cpu: 500m

promtail:
  enabled: true
  resources:
    requests:
      memory: 64Mi
      cpu: 50m
    limits:
      memory: 128Mi
      cpu: 200m

grafana:
  enabled: false  # Already installed with kube-prometheus-stack

singleBinary:
  replicas: 1
EOF

# Install Loki
helm install loki grafana/loki-stack \
    --namespace monitoring \
    --values /tmp/loki-values.yaml

echo "⏳ Waiting for Loki to be ready..."
sleep 20

echo "✅ Loki Stack installed successfully!"
echo ""
echo "📋 Configure Grafana data source:"
echo "   1. Go to Grafana: https://grafana.zoom2604.dev"
echo "   2. Add Loki data source: http://loki:3100"
echo ""
echo "🔍 View logs:"
echo "   kubectl logs -n monitoring -l app=promtail"
