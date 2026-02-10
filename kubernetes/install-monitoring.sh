#!/bin/bash
# ================================
# Install kube-prometheus-stack via Helm
# ================================

set -e

echo "📊 Installing kube-prometheus-stack (Prometheus + Grafana + Alertmanager)..."

# Add Prometheus Community Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create values file for customization
cat > /tmp/prometheus-values.yaml <<EOF
prometheus:
  prometheusSpec:
    retention: 15d
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: local-path
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 20Gi
    resources:
      requests:
        memory: 1Gi
        cpu: 500m
      limits:
        memory: 2Gi
        cpu: 1000m

grafana:
  adminPassword: "$(kubectl get secret grafana-credentials -n monitoring -o jsonpath='{.data.admin-password}' 2>/dev/null | base64 -d || echo 'admin')"
  persistence:
    enabled: true
    storageClassName: local-path
    size: 5Gi
  ingress:
    enabled: true
    ingressClassName: traefik
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    hosts:
      - grafana.zoom2604.dev
    tls:
      - secretName: grafana-tls
        hosts:
          - grafana.zoom2604.dev
  resources:
    requests:
      memory: 200Mi
      cpu: 100m
    limits:
      memory: 400Mi
      cpu: 500m

alertmanager:
  enabled: true
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: local-path
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 2Gi

kubeStateMetrics:
  enabled: true

nodeExporter:
  enabled: true

prometheusOperator:
  resources:
    requests:
      memory: 100Mi
      cpu: 100m
    limits:
      memory: 200Mi
      cpu: 200m
EOF

# Install kube-prometheus-stack
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    --values /tmp/prometheus-values.yaml

echo "⏳ Waiting for Prometheus stack to be ready..."
sleep 30

echo "✅ kube-prometheus-stack installed successfully!"
echo ""
echo "📋 Access:"
echo "   Grafana: https://grafana.zoom2604.dev"
echo "   Prometheus: kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090"
echo ""
echo "🔍 Useful commands:"
echo "   kubectl get pods -n monitoring"
echo "   kubectl get svc -n monitoring"
