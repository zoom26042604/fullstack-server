#!/bin/bash
# Vue d'ensemble rapide de l'infrastructure

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}     🚀 FULLSTACK SERVER - INFRASTRUCTURE${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Charger les variables d'environnement
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

echo -e "${GREEN}📊 SERVICES (docker-compose)${NC}"
echo ""
sudo docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo -e "${GREEN}🌐 ACCÈS WEB${NC}"
echo ""
echo -e "  Traefik Dashboard: ${BLUE}https://traefik.${DOMAIN}${NC}"
echo -e "  Grafana:          ${BLUE}https://grafana.${DOMAIN}${NC}"
echo -e "  Prometheus:       ${BLUE}http://localhost:9090${NC}"
echo ""

echo -e "${GREEN}💾 RESSOURCES${NC}"
echo ""

# RAM
RAM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
RAM_USED=$(free -h | awk '/^Mem:/ {print $3}')
RAM_PERCENT=$(free | awk '/^Mem:/ {printf "%.1f%%", ($3/$2)*100}')
echo -e "  RAM:  $RAM_USED / $RAM_TOTAL ($RAM_PERCENT)"

# Disk
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_PERCENT=$(df -h / | awk 'NR==2 {print $5}')
echo -e "  Disk: $DISK_USED / $DISK_TOTAL ($DISK_PERCENT)"

# CPU
CPU_PERCENT=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
echo -e "  CPU:  ${CPU_PERCENT}%"
echo ""

echo -e "${GREEN}🔧 SCRIPTS DISPONIBLES${NC}"
echo ""
echo -e "  ${BLUE}./scripts/menu.sh${NC}           - Menu principal interactif"
echo -e "  ${BLUE}./scripts/deploy/deploy.sh${NC} - Déployer une nouvelle app"
echo -e "  ${BLUE}./scripts/apps/list-apps.sh${NC} - Lister toutes les apps"
echo -e "  ${BLUE}./scripts/quick/full-status.sh${NC} - Status rapide complet"
echo ""

echo -e "${GREEN}📚 DOCUMENTATION${NC}"
echo ""
echo -e "  README:     ../README.md"
echo -e "  Scripts:    ./scripts/README.md"
echo -e "  Monitoring: ../TEST_MONITORING.md"
echo -e "  Déploiement: ../doc/DEPLOYMENT.md"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
