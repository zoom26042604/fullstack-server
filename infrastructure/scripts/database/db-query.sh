#!/bin/bash
# Exécuter une requête SQL rapide
BLUE='\033[0;34m'; NC='\033[0m'
echo -e "${BLUE}🗄️  PostgreSQL Query${NC}"
echo ""
read -p "Database name: " DB_NAME
read -p "SQL Query: " QUERY
echo ""
sudo docker exec -it postgres psql -U ${POSTGRES_USER:-postgres} -d "$DB_NAME" -c "$QUERY"
