#!/bin/bash

# ================================
# BACKUP POSTGRESQL AUTOMATIQUE
# Backup quotidien avec rotation automatique (7 jours)
# ================================

set -e

BACKUP_DIR="/srv/backups/postgres"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Créer le répertoire de backup si nécessaire
mkdir -p "$BACKUP_DIR"

echo "🔄 Démarrage backup PostgreSQL..."

# Backup de toutes les bases
docker exec postgres pg_dumpall -U postgres | gzip > "$BACKUP_DIR/postgres_all_$DATE.sql.gz"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Backup créé: postgres_all_$DATE.sql.gz${NC}"
    
    # Taille du backup
    SIZE=$(du -h "$BACKUP_DIR/postgres_all_$DATE.sql.gz" | cut -f1)
    echo "📦 Taille: $SIZE"
    
    # Rotation des backups (garder 7 jours)
    echo "🗑️  Suppression des backups de plus de $RETENTION_DAYS jours..."
    find "$BACKUP_DIR" -name "postgres_all_*.sql.gz" -mtime +$RETENTION_DAYS -delete
    
    # Afficher les backups disponibles
    echo ""
    echo "📁 Backups disponibles:"
    ls -lh "$BACKUP_DIR" | grep "postgres_all" | tail -7
    
else
    echo -e "${RED}❌ Erreur lors du backup${NC}"
    exit 1
fi
