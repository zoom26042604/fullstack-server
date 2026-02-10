#!/bin/bash
# ================================
# Build Docker Images for Kubernetes
# ================================

set -e

echo "🐳 Building Docker images for Kubernetes deployment..."

# Portfolio Azrael
echo "📦 Building Portfolio Azrael..."
cd /srv/nathan-ferre.fr/azrael
docker build -t portfolio-azrael:latest .
echo "✅ Portfolio Azrael built"

# CV
echo "📦 Building CV..."
cd /srv/nathan-ferre.fr/cv
docker build -t cv-nathan:latest .
echo "✅ CV built"

# Game 2048
echo "📦 Building Game 2048..."
cd /srv/zoom2604.dev/2048
docker build -t game-2048:latest .
echo "✅ Game 2048 built"

# Admin Panel
echo "📦 Building Admin Panel..."
cd /srv/zoom2604.dev/admin
docker build -t admin-panel:latest .
echo "✅ Admin Panel built"

echo ""
echo "✅ All images built successfully!"
echo ""
echo "📋 Images created:"
docker images | grep -E "portfolio-azrael|cv-nathan|game-2048|admin-panel"
echo ""
echo "💡 Next steps:"
echo "   1. Import images to K3s: ./import-images-to-k3s.sh"
echo "   2. Deploy applications: kubectl apply -k apps/"
