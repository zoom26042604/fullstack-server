#!/bin/bash
# Health Check - Modern & Minimal

DIM='\033[2m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'
BOLD='\033[1m'

echo ""
echo -e "${BOLD}Health Check${NC}"
echo ""

cd /srv/fullstack-server/infrastructure

# Check containers
services=(traefik postgres pgbouncer redis prometheus grafana node_exporter cadvisor homer uptime-kuma portainer azrael)
for service in "${services[@]}"; do
    if sudo docker ps --format '{{.Names}}' | grep -q "^${service}$"; then
        health=$(sudo docker inspect "$service" --format='{{.State.Health.Status}}' 2>/dev/null || echo "none")
        if [ "$health" = "healthy" ]; then
            echo -e "  ${GREEN}●${NC} $service"
        elif [ "$health" = "unhealthy" ]; then
            echo -e "  ${RED}●${NC} $service ${DIM}unhealthy${NC}"
        else
            echo -e "  ${YELLOW}●${NC} $service ${DIM}no healthcheck${NC}"
        fi
    else
        echo -e "  ${RED}○${NC} $service ${DIM}down${NC}"
    fi
done

echo ""
echo -e "${BOLD}Connectivity${NC}"
echo ""

# Check services
curl -sf http://localhost:9090/-/healthy > /dev/null && echo -e "  ${GREEN}●${NC} prometheus" || echo -e "  ${RED}●${NC} prometheus"
sudo docker exec postgres pg_isready -U postgres > /dev/null 2>&1 && echo -e "  ${GREEN}●${NC} postgresql" || echo -e "  ${RED}●${NC} postgresql"
sudo docker exec redis redis-cli ping > /dev/null 2>&1 && echo -e "  ${GREEN}●${NC} redis" || echo -e "  ${RED}●${NC} redis"
echo ""
