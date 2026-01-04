#!/bin/bash
# Quick Status - Modern & Minimal

DIM='\033[2m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

echo ""
echo -e "${BOLD}Status${NC}"
echo ""

# System
UPTIME=$(uptime -p | sed 's/up //')
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.1f", $2}')
RAM=$(free | grep Mem | awk '{printf "%.1f", ($3/$2)*100}')
DISK=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

echo -e "  ${DIM}uptime${NC}   $UPTIME"
echo -e "  ${DIM}cpu${NC}      ${CPU}%"
echo -e "  ${DIM}ram${NC}      ${RAM}%"
echo -e "  ${DIM}disk${NC}     ${DISK}%"
echo ""

# Containers
echo -e "${BOLD}Containers${NC}"
echo ""
sudo docker ps --format "  {{.Names}}|{{.Status}}" 2>/dev/null | while IFS='|' read name status; do
    if echo "$status" | grep -q "healthy"; then
        echo -e "  ${GREEN}●${NC} $name ${DIM}$status${NC}"
    elif echo "$status" | grep -q "unhealthy"; then
        echo -e "  ${RED}●${NC} $name ${DIM}$status${NC}"
    else
        echo -e "  ${CYAN}●${NC} $name ${DIM}$status${NC}"
    fi
done
echo ""
