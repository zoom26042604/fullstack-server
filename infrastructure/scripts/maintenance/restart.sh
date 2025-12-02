#!/bin/bash
# Redémarrer l'infrastructure
echo "🔄 Redémarrage de l'infrastructure"
cd /srv/infrastructure
sudo docker-compose restart
echo "✓ Infrastructure redémarrée"
