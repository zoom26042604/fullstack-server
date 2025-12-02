#!/bin/bash
# Mettre à jour l'infrastructure
echo "⬆️  Mise à jour de l'infrastructure"
cd /srv/infrastructure
echo "Pull des nouvelles images..."
sudo docker-compose pull
echo ""
echo "Redémarrage avec les nouvelles images..."
sudo docker-compose up -d
echo "✓ Infrastructure mise à jour"
sudo docker-compose ps
