#!/bin/bash
# Menu de déploiement d'applications

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
cat << "EOF"
 ____             _             
|  _ \  ___ _ __ | | ___  _   _ 
| | | |/ _ \ '_ \| |/ _ \| | | |
| |_| |  __/ |_) | | (_) | |_| |
|____/ \___| .__/|_|\___/ \__, |
           |_|            |___/ 
EOF

echo -e "${BLUE}=== DÉPLOIEMENT D'APPLICATIONS ===${NC}"
echo ""
echo "Quel type d'application voulez-vous déployer ?"
echo ""
echo -e "  ${GREEN}1)${NC} Next.js - Application React avec SSR"
echo -e "  ${GREEN}2)${NC} React/Vite - Single Page Application"
echo -e "  ${GREEN}3)${NC} Angular - Application Angular"
echo -e "  ${GREEN}4)${NC} Node.js - API/Backend Node.js/Express"
echo -e "  ${GREEN}5)${NC} Site statique - HTML/CSS/JavaScript"
echo -e "  ${YELLOW}0)${NC} Retour"
echo ""
read -p "Votre choix [0-5]: " CHOICE

case $CHOICE in
    1)
        exec ./deploy-nextjs.sh
        ;;
    2)
        exec ./deploy-react.sh
        ;;
    3)
        exec ./deploy-angular.sh
        ;;
    4)
        exec ./deploy-node.sh
        ;;
    5)
        exec ./deploy-static.sh
        ;;
    0)
        exit 0
        ;;
    *)
        echo -e "${YELLOW}Choix invalide${NC}"
        exit 1
        ;;
esac
