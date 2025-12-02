#!/bin/bash
# Backup complet
BACKUP_DIR="/srv/infrastructure/backups/backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "💾 Backup vers $BACKUP_DIR"
sudo docker exec postgres pg_dumpall -U postgres > "$BACKUP_DIR/postgres.sql"
sudo docker exec redis redis-cli --rdb - > "$BACKUP_DIR/redis.rdb"
cp -r /srv/infrastructure/{traefik,prometheus,grafana,*.yml,.env} "$BACKUP_DIR/" 2>/dev/null
echo "✓ Backup terminé"
ls -lh "$BACKUP_DIR"
