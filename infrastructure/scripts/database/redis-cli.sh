#!/bin/bash
# Accès Redis CLI
BLUE='\033[0;34m'; NC='\033[0m'
echo -e "${BLUE}📦 Redis CLI${NC}"
echo ""
sudo docker exec -it redis redis-cli
