#!/bin/bash
# ================================
# Import Docker Images to K3s
# ================================

set -e

echo "📥 Importing Docker images to K3s..."

# Save images to tar files
echo "💾 Saving images..."
docker save portfolio-azrael:latest -o /tmp/portfolio-azrael.tar
docker save cv-nathan:latest -o /tmp/cv-nathan.tar
docker save game-2048:latest -o /tmp/game-2048.tar
docker save admin-panel:latest -o /tmp/admin-panel.tar

# Import to K3s
echo "📤 Importing to K3s..."
sudo k3s ctr images import /tmp/portfolio-azrael.tar
sudo k3s ctr images import /tmp/cv-nathan.tar
sudo k3s ctr images import /tmp/game-2048.tar
sudo k3s ctr images import /tmp/admin-panel.tar

# Cleanup
echo "🧹 Cleaning up..."
rm /tmp/portfolio-azrael.tar
rm /tmp/cv-nathan.tar
rm /tmp/game-2048.tar
rm /tmp/admin-panel.tar

echo ""
echo "✅ All images imported to K3s!"
echo ""
echo "🔍 Verify images:"
sudo k3s ctr images ls | grep -E "portfolio-azrael|cv-nathan|game-2048|admin-panel"
