#!/bin/bash
# Redémarrage rapide de l'infrastructure
GREEN='\033[0;32m'; BLUE='\033[0;34m'; NC='\033[0m'
echo -e "${BLUE}🔄 Redémarrage rapide de l'infrastructure${NC}"
echo ""
cd /srv/infrastructure
sudo docker-compose restart
echo ""
echo -e "${GREEN}✓ Infrastructure redémarrée${NC}"
