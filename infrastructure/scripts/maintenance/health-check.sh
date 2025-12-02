#!/bin/bash
# Health check complet
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
echo -e "${BLUE}🏥 Health Check Infrastructure${NC}"
echo ""
cd /srv/infrastructure
services=(traefik postgres pgbouncer redis prometheus grafana node_exporter cadvisor)
for service in "${services[@]}"; do
    if sudo docker-compose ps | grep "$service" | grep -q "Up"; then
        if sudo docker inspect "$service" 2>/dev/null | grep -q '"Status": "healthy"'; then
            echo -e "  ${GREEN}✓ $service - Healthy${NC}"
        else
            echo -e "  ${YELLOW}⚠ $service - Running (no healthcheck)${NC}"
        fi
    else
        echo -e "  ${RED}✗ $service - Down${NC}"
    fi
done
echo ""
echo "Connexions réseau:"
curl -s http://localhost:9090/-/healthy > /dev/null && echo -e "  ${GREEN}✓ Prometheus accessible${NC}" || echo -e "  ${RED}✗ Prometheus inaccessible${NC}"
sudo docker exec postgres pg_isready -U postgres > /dev/null 2>&1 && echo -e "  ${GREEN}✓ PostgreSQL accessible${NC}" || echo -e "  ${RED}✗ PostgreSQL inaccessible${NC}"
sudo docker exec redis redis-cli ping > /dev/null 2>&1 && echo -e "  ${GREEN}✓ Redis accessible${NC}" || echo -e "  ${RED}✗ Redis inaccessible${NC}"
