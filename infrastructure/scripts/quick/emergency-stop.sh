#!/bin/bash
# Arrêt d'urgence
RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
echo -e "${RED}⚠️  ARRÊT D'URGENCE${NC}"
echo ""
read -p "Êtes-vous sûr? (yes/no): " CONFIRM
if [ "$CONFIRM" = "yes" ]; then
    echo -e "${YELLOW}Arrêt de tous les services...${NC}"
    cd /srv/infrastructure
    sudo docker-compose down
    echo ""
    for domain in /srv/*/; do
        domain_name=$(basename "$domain")
        if [[ "$domain_name" != "infrastructure" && "$domain_name" != "doc" && "$domain_name" != "fullstack-server" ]]; then
            for app_dir in "$domain"/*/; do
                if [ -f "$app_dir/docker-compose.yml" ]; then
                    echo "Arrêt de $(basename "$app_dir")..."
                    cd "$app_dir" && sudo docker-compose down
                fi
            done
        fi
    done
    echo -e "${RED}✓ Tout est arrêté${NC}"
else
    echo "Annulé"
fi
