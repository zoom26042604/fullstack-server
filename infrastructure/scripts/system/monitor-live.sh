#!/bin/bash
# Monitoring temps réel
BLUE='\033[0;34m'; NC='\033[0m'
echo -e "${BLUE}📊 Monitoring en direct${NC}"
if command -v htop &> /dev/null; then
    htop
else
    echo "htop non trouvé, utilisation de top..."
    top
fi
