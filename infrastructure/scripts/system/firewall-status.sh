#!/bin/bash
# Status firewall
BLUE='\033[0;34m'; GREEN='\033[0;32m'; NC='\033[0m'
echo -e "${BLUE}🛡️  Status Firewall${NC}"
echo ""
if command -v ufw &> /dev/null; then
    sudo ufw status verbose
elif command -v iptables &> /dev/null; then
    sudo iptables -L -n -v
else
    echo "Aucun firewall détecté"
fi
