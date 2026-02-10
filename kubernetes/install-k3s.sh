#!/bin/bash
# ================================
# K3s Installation Script
# Optimized for OVH VPS (12GB RAM / 100GB Disk)
# ================================

set -e

echo "🚀 Installing K3s on $(hostname)..."
echo "📊 System resources:"
echo "   RAM: $(free -h | awk '/^Mem:/ {print $2}')"
echo "   Disk: $(df -h / | awk 'NR==2 {print $2}')"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (sudo)"
    exit 1
fi

# Install K3s with optimized settings
echo "📦 Installing K3s..."
curl -sfL https://get.k3s.io | sh -s - \
    --write-kubeconfig-mode 644 \
    --disable traefik \
    --disable servicelb \
    --kubelet-arg="max-pods=110" \
    --kube-apiserver-arg="default-not-ready-toleration-seconds=30" \
    --kube-apiserver-arg="default-unreachable-toleration-seconds=30"

# Wait for K3s to be ready
echo "⏳ Waiting for K3s to be ready..."
sleep 10

# Check K3s status
systemctl status k3s --no-pager | head -n 10

# Configure kubectl for non-root user
if [ -n "$SUDO_USER" ]; then
    REAL_USER=$SUDO_USER
    REAL_HOME=$(eval echo ~$SUDO_USER)
    
    echo "🔧 Configuring kubectl for user: $REAL_USER"
    mkdir -p "$REAL_HOME/.kube"
    cp /etc/rancher/k3s/k3s.yaml "$REAL_HOME/.kube/config"
    chown -R $REAL_USER:$REAL_USER "$REAL_HOME/.kube"
    chmod 600 "$REAL_HOME/.kube/config"
fi

# Create symlink for kubectl
if [ ! -f /usr/local/bin/kubectl ]; then
    ln -s /usr/local/bin/k3s /usr/local/bin/kubectl
fi

# Install Helm
if ! command -v helm &> /dev/null; then
    echo "📦 Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo ""
echo "✅ K3s installation complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Verify cluster: kubectl get nodes"
echo "   2. Create namespaces: ./setup-namespaces.sh"
echo "   3. Install infrastructure: kubectl apply -k infrastructure/"
echo ""
echo "🔍 Useful commands:"
echo "   - Check pods: kubectl get pods -A"
echo "   - Check nodes: kubectl get nodes"
echo "   - K3s logs: sudo journalctl -u k3s -f"
echo "   - Uninstall: /usr/local/bin/k3s-uninstall.sh"
