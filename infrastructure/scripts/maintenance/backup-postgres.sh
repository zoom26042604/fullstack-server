#!/bin/bash
# Backup PostgreSQL uniquement
DATE=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="/srv/infrastructure/backups/postgres-$DATE.sql"
mkdir -p /srv/infrastructure/backups
echo "💾 Backup PostgreSQL vers $BACKUP_FILE"
sudo docker exec postgres pg_dumpall -U postgres > "$BACKUP_FILE"
echo "✓ Backup terminé: $(du -h "$BACKUP_FILE" | cut -f1)"
