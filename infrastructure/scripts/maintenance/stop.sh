#!/bin/bash
# Arrêter l'infrastructure
echo "⏹️  Arrêt de l'infrastructure"
read -p "Êtes-vous sûr? (yes/no): " CONFIRM
if [ "$CONFIRM" = "yes" ]; then
    cd /srv/infrastructure
    sudo docker-compose down
    echo "✓ Infrastructure arrêtée"
else
    echo "Annulé"
fi
