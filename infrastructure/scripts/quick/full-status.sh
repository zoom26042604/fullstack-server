#!/bin/bash
# Status complet rapide
BLUE='\033[0;34m'; GREEN='\033[0;32m'; NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}     📊 STATUS RAPIDE${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Uptime
echo -e "${GREEN}⏱️  Uptime:${NC} $(uptime -p)"

# CPU
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
echo -e "${GREEN}⚙️  CPU:${NC} ${CPU}% utilisé"

# RAM
RAM=$(free | grep Mem | awk '{printf "%.1f%%", ($3/$2)*100}')
echo -e "${GREEN}💾 RAM:${NC} $RAM utilisé"

# Disk
DISK=$(df -h / | awk 'NR==2 {print $5}')
echo -e "${GREEN}💿 Disk:${NC} $DISK utilisé"

# Docker
CONTAINERS=$(sudo docker ps -q 2>/dev/null | wc -l)
echo -e "${GREEN}🐳 Docker:${NC} $CONTAINERS conteneurs actifs"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
