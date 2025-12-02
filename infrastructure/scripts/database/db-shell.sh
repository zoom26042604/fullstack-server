#!/bin/bash
# Accès PostgreSQL
BLUE='\033[0;34m'; NC='\033[0m'
echo -e "${BLUE}🗄️  PostgreSQL Shell${NC}"
echo ""
sudo docker exec -it postgres psql -U ${POSTGRES_USER:-postgres}
