#!/bin/bash
# Ports ouverts
BLUE='\033[0;34m'; GREEN='\033[0;32m'; NC='\033[0m'
echo -e "${BLUE}🔌 Ports Ouverts${NC}"
echo ""
if command -v netstat &> /dev/null; then
    sudo netstat -tuln | grep LISTEN
else
    sudo ss -tuln | grep LISTEN
fi
