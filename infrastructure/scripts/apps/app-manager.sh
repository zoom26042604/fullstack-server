#!/bin/bash
# Gestionnaire d'applications déployées

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Fonction pour lister toutes les apps
list_apps() {
    echo -e "${BLUE}📱 Applications déployées:${NC}"
    echo ""
    
    for domain in /srv/*/; do
        domain_name=$(basename "$domain")
        if [[ "$domain_name" != "infrastructure" && "$domain_name" != "doc" && "$domain_name" != "fullstack-server" ]]; then
            echo -e "${GREEN}🌐 $domain_name${NC}"
            for app_dir in "$domain"/*/; do
                if [ -f "$app_dir/docker-compose.yml" ]; then
                    app_name=$(basename "$app_dir")
                    # Vérifier si l'app tourne
                    if sudo docker-compose -f "$app_dir/docker-compose.yml" ps | grep -q "Up"; then
                        echo -e "  ├─ $app_name ${GREEN}● Running${NC}"
                    else
                        echo -e "  ├─ $app_name ${YELLOW}○ Stopped${NC}"
                    fi
                fi
            done
        fi
    done
    echo ""
}

# Fonction pour sélectionner une app
select_app() {
    apps=()
    for domain in /srv/*/; do
        domain_name=$(basename "$domain")
        if [[ "$domain_name" != "infrastructure" && "$domain_name" != "doc" && "$domain_name" != "fullstack-server" ]]; then
            for app_dir in "$domain"/*/; do
                if [ -f "$app_dir/docker-compose.yml" ]; then
                    apps+=("$app_dir")
                fi
            done
        fi
    done
    
    if [ ${#apps[@]} -eq 0 ]; then
        echo -e "${YELLOW}Aucune application trouvée${NC}"
        exit 1
    fi
    
    echo "Sélectionnez une application:"
    echo ""
    for i in "${!apps[@]}"; do
        app_path="${apps[$i]}"
        domain=$(basename "$(dirname "$app_path")")
        app_name=$(basename "$app_path")
        echo "  $((i+1))) $domain/$app_name"
    done
    echo ""
    read -p "Votre choix [1-${#apps[@]}]: " choice
    
    if [[ $choice -ge 1 && $choice -le ${#apps[@]} ]]; then
        selected_app="${apps[$((choice-1))]}"
    else
        echo -e "${RED}Choix invalide${NC}"
        exit 1
    fi
}

clear
cat << "EOF"
    _                  __  __                                   
   / \   _ __  _ __   |  \/  | __ _ _ __   __ _  __ _  ___ _ __ 
  / _ \ | '_ \| '_ \  | |\/| |/ _` | '_ \ / _` |/ _` |/ _ \ '__|
 / ___ \| |_) | |_) | | |  | | (_| | | | | (_| | (_| |  __/ |   
/_/   \_\ .__/| .__/  |_|  |_|\__,_|_| |_|\__,_|\__, |\___|_|   
        |_|   |_|                               |___/            
EOF

echo -e "${BLUE}=== GESTION DES APPLICATIONS ===${NC}"
echo ""

list_apps

echo "Actions disponibles:"
echo ""
echo -e "  ${GREEN}1)${NC} Start - Démarrer une app"
echo -e "  ${GREEN}2)${NC} Stop - Arrêter une app"
echo -e "  ${GREEN}3)${NC} Restart - Redémarrer une app"
echo -e "  ${GREEN}4)${NC} Logs - Voir les logs"
echo -e "  ${GREEN}5)${NC} Status - Voir le status"
echo -e "  ${GREEN}6)${NC} Rebuild - Rebuild l'image"
echo -e "  ${GREEN}7)${NC} Rebuild + Restart - Rebuild et redémarrer"
echo -e "  ${GREEN}8)${NC} Delete - Supprimer une app"
echo -e "  ${YELLOW}0)${NC} Retour"
echo ""
read -p "Votre choix [0-8]: " ACTION

if [ "$ACTION" = "0" ]; then
    exit 0
fi

select_app

cd "$selected_app"
APP_NAME=$(basename "$selected_app")
DOMAIN=$(basename "$(dirname "$selected_app")")

case $ACTION in
    1)
        echo -e "${GREEN}▶ Démarrage de $DOMAIN/$APP_NAME...${NC}"
        sudo docker-compose up -d
        ;;
    2)
        echo -e "${YELLOW}■ Arrêt de $DOMAIN/$APP_NAME...${NC}"
        sudo docker-compose down
        ;;
    3)
        echo -e "${BLUE}🔄 Redémarrage de $DOMAIN/$APP_NAME...${NC}"
        sudo docker-compose restart
        ;;
    4)
        echo -e "${BLUE}📋 Logs de $DOMAIN/$APP_NAME (Ctrl+C pour quitter):${NC}"
        echo ""
        sudo docker-compose logs -f
        ;;
    5)
        echo -e "${BLUE}📊 Status de $DOMAIN/$APP_NAME:${NC}"
        echo ""
        sudo docker-compose ps
        ;;
    6)
        echo -e "${YELLOW}🔨 Rebuild de $DOMAIN/$APP_NAME...${NC}"
        sudo docker-compose build --no-cache
        echo -e "${GREEN}✓ Rebuild terminé${NC}"
        ;;
    7)
        echo -e "${YELLOW}🔨 Rebuild + Restart de $DOMAIN/$APP_NAME...${NC}"
        sudo docker-compose down
        sudo docker-compose build --no-cache
        sudo docker-compose up -d
        echo -e "${GREEN}✓ Rebuild et redémarrage terminés${NC}"
        ;;
    8)
        echo -e "${RED}⚠️  ATTENTION: Cela va supprimer $DOMAIN/$APP_NAME${NC}"
        read -p "Êtes-vous sûr? (yes/no): " CONFIRM
        if [ "$CONFIRM" = "yes" ]; then
            sudo docker-compose down -v
            cd ..
            rm -rf "$selected_app"
            echo -e "${GREEN}✓ Application supprimée${NC}"
        else
            echo "Annulé"
        fi
        ;;
    *)
        echo -e "${RED}Choix invalide${NC}"
        exit 1
        ;;
esac

echo ""
read -p "Appuyez sur Entrée pour continuer..."
