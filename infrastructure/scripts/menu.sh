#!/bin/bash
# SCRIPT PRINCIPAL - GESTION INFRASTRUCTURE

BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

clear
cat << "EOF"
 ___        __                 _                   _                  
|_ _|_ __  / _|_ __ __ _  ___| |_ _ __ _   _  ___| |_ _   _ _ __ ___ 
 | || '_ \| |_| '__/ _` |/ __| __| '__| | | |/ __| __| | | | '__/ _ \
 | || | | |  _| | | (_| |\__ \ |_| |  | |_| | (__| |_| |_| | | |  __/
|___|_| |_|_| |_|  \__,_||___/\__|_|   \__,_|\___|\__|\__,_|_|  \___|
                                                                       
EOF

echo -e "${BLUE}=== GESTION INFRASTRUCTURE ===${NC}"
echo ""
echo "Que voulez-vous faire?"
echo ""
echo -e "  ${GREEN}1)${NC} Déployer une nouvelle application (Next.js, React, Node.js, etc.)"
echo -e "  ${GREEN}2)${NC} Gérer les applications (start, stop, logs, rebuild, etc.)"
echo -e "  ${GREEN}3)${NC} Maintenance infrastructure (logs, backup, restart, etc.)"
echo -e "  ${GREEN}4)${NC} Monitoring & Système (info, disk, SSL, firewall, ports)"
echo -e "  ${GREEN}5)${NC} Bases de données (PostgreSQL, Redis, backup, query)"
echo -e "  ${GREEN}6)${NC} Actions rapides (status, restart, emergency, Docker)"
echo -e "  ${YELLOW}0)${NC} Quitter"
echo ""
read -p "Votre choix [0-6]: " CHOICE

case $CHOICE in
    1)
        echo -e "${GREEN}▶ Lancement du menu de déploiement...${NC}"
        exec ./deploy/deploy.sh
        ;;
    2)
        echo -e "${GREEN}▶ Lancement de la gestion des applications...${NC}"
        exec ./apps/app-manager.sh
        ;;
    3)
        echo ""
        echo -e "${BLUE}=== SCRIPTS DE MAINTENANCE ===${NC}"
        echo ""
        echo "Scripts disponibles dans ./maintenance/:"
        echo ""
        ls -1 ./maintenance/*.sh | xargs -n1 basename | sed 's/^/  - /'
        echo ""
        read -p "Entrez le nom du script à exécuter (sans .sh): " SCRIPT_NAME
        if [ -f "./maintenance/${SCRIPT_NAME}.sh" ]; then
            exec "./maintenance/${SCRIPT_NAME}.sh"
        else
            echo -e "${YELLOW}Script non trouvé.${NC}"
        fi
        ;;
    4)
        echo ""
        echo -e "${BLUE}=== MONITORING & SYSTÈME ===${NC}"
        echo ""
        echo "Scripts disponibles:"
        echo ""
        echo -e "  ${GREEN}1)${NC} system-info      - Info complète du serveur"
        echo -e "  ${GREEN}2)${NC} disk-usage       - Analyse espace disque"
        echo -e "  ${GREEN}3)${NC} monitor-live     - Monitoring temps réel"
        echo -e "  ${GREEN}4)${NC} ssl-check        - Vérification certificats SSL"
        echo -e "  ${GREEN}5)${NC} firewall-status  - Status firewall"
        echo -e "  ${GREEN}6)${NC} open-ports       - Ports ouverts"
        echo ""
        read -p "Votre choix [1-6]: " SYS_CHOICE
        case $SYS_CHOICE in
            1) exec ./system/system-info.sh ;;
            2) exec ./system/disk-usage.sh ;;
            3) exec ./system/monitor-live.sh ;;
            4) exec ./system/ssl-check.sh ;;
            5) exec ./system/firewall-status.sh ;;
            6) exec ./system/open-ports.sh ;;
            *) echo -e "${YELLOW}Choix invalide.${NC}" ;;
        esac
        ;;
    5)
        echo ""
        echo -e "${BLUE}=== BASES DE DONNÉES ===${NC}"
        echo ""
        echo "Scripts disponibles:"
        echo ""
        echo -e "  ${GREEN}1)${NC} db-shell         - Shell PostgreSQL"
        echo -e "  ${GREEN}2)${NC} redis-cli        - CLI Redis"
        echo -e "  ${GREEN}3)${NC} db-backup-now    - Backup immédiat PostgreSQL"
        echo -e "  ${GREEN}4)${NC} db-query         - Exécuter requête SQL"
        echo ""
        read -p "Votre choix [1-4]: " DB_CHOICE
        case $DB_CHOICE in
            1) exec ./database/db-shell.sh ;;
            2) exec ./database/redis-cli.sh ;;
            3) exec ./database/db-backup-now.sh ;;
            4) exec ./database/db-query.sh ;;
            *) echo -e "${YELLOW}Choix invalide.${NC}" ;;
        esac
        ;;
    6)
        echo ""
        echo -e "${BLUE}=== ACTIONS RAPIDES ===${NC}"
        echo ""
        echo "Scripts disponibles:"
        echo ""
        echo -e "  ${GREEN}1)${NC} full-status         - Status complet rapide"
        echo -e "  ${GREEN}2)${NC} quick-restart       - Restart rapide infra"
        echo -e "  ${GREEN}3)${NC} emergency-stop      - Arrêt d'urgence"
        echo -e "  ${GREEN}4)${NC} url-test            - Tester une URL"
        echo -e "  ${GREEN}5)${NC} docker-stats-live   - Stats Docker live"
        echo -e "  ${GREEN}6)${NC} container-shell     - Shell conteneur"
        echo -e "  ${GREEN}7)${NC} docker-prune-all    - Nettoyage Docker"
        echo ""
        read -p "Votre choix [1-7]: " QUICK_CHOICE
        case $QUICK_CHOICE in
            1) exec ./quick/full-status.sh ;;
            2) exec ./quick/quick-restart.sh ;;
            3) exec ./quick/emergency-stop.sh ;;
            4) exec ./quick/url-test.sh ;;
            5) exec ./quick/docker-stats-live.sh ;;
            6) exec ./quick/container-shell.sh ;;
            7) exec ./quick/docker-prune-all.sh ;;
            *) echo -e "${YELLOW}Choix invalide.${NC}" ;;
        esac
        ;;
    0)
        echo -e "${YELLOW}Au revoir.${NC}"
        exit 0
        ;;
    *)
        echo -e "${YELLOW}Choix invalide.${NC}"
        exit 1
        ;;
esac
