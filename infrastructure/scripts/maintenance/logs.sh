#!/bin/bash
# Voir les logs
cd /srv/infrastructure
echo "Services disponibles:"
sudo docker-compose ps --services
read -p "Service: " SERVICE
sudo docker-compose logs -f "$SERVICE"
