#!/bin/bash
# Nettoyage complet Docker
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
echo -e "${YELLOW}🧹 Nettoyage Docker complet${NC}"
echo ""
echo "Espace avant nettoyage:"
sudo docker system df
echo ""
read -p "Nettoyer tout (images, volumes, cache)? (yes/no): " CONFIRM
if [ "$CONFIRM" = "yes" ]; then
    echo ""
    sudo docker system prune -a --volumes -f
    echo ""
    echo -e "${GREEN}✓ Nettoyage terminé${NC}"
    echo ""
    echo "Espace après nettoyage:"
    sudo docker system df
else
    echo "Annulé"
fi
