#!/bin/bash
# Backup PostgreSQL immédiat
GREEN='\033[0;32m'; BLUE='\033[0;34m'; NC='\033[0m'
echo -e "${BLUE}💾 Backup PostgreSQL${NC}"
BACKUP_FILE="/tmp/postgres_backup_$(date +%Y%m%d_%H%M%S).sql"
echo "Sauvegarde vers: $BACKUP_FILE"
sudo docker exec postgres pg_dumpall -U ${POSTGRES_USER:-postgres} > "$BACKUP_FILE"
echo -e "${GREEN}✓ Backup terminé: $BACKUP_FILE${NC}"
ls -lh "$BACKUP_FILE"
