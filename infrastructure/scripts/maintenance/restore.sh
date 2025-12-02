#!/bin/bash
# Restaurer un backup
echo "📂 Backups disponibles:"
ls -1 /srv/infrastructure/backups/ 2>/dev/null || echo "Aucun backup"
read -p "Backup à restaurer: " BACKUP
BACKUP_DIR="/srv/infrastructure/backups/$BACKUP"
[ ! -d "$BACKUP_DIR" ] && echo "Backup introuvable" && exit 1
echo "⚠️  Restauration depuis $BACKUP"
read -p "Continuer? (yes/no): " CONFIRM
[ "$CONFIRM" != "yes" ] && echo "Annulé" && exit 0
[ -f "$BACKUP_DIR/postgres.sql" ] && cat "$BACKUP_DIR/postgres.sql" | sudo docker exec -i postgres psql -U postgres
echo "✓ Restauration terminée"
