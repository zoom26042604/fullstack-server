#!/bin/bash
# Accès shell à un conteneur
BLUE='\033[0;34m'; GREEN='\033[0;32m'; NC='\033[0m'
echo -e "${BLUE}🐳 Accès shell conteneur${NC}"
echo ""
echo "Conteneurs actifs:"
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
echo ""
read -p "Nom du conteneur: " CONTAINER
read -p "Shell [bash]: " SHELL
SHELL=${SHELL:-bash}
echo ""
sudo docker exec -it "$CONTAINER" "$SHELL" || sudo docker exec -it "$CONTAINER" sh
