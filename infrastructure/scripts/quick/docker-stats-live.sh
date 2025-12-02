#!/bin/bash
# Stats Docker en temps réel
BLUE='\033[0;34m'; NC='\033[0m'
echo -e "${BLUE}📊 Stats Docker (Ctrl+C pour quitter)${NC}"
echo ""
sudo docker stats
