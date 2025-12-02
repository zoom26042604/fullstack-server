#!/bin/bash
# Déployer l'infrastructure
cd /srv/infrastructure
echo "🚀 Déploiement de l'infrastructure..."
sudo docker-compose up -d
echo "✓ Infrastructure déployée"
sudo docker-compose ps
