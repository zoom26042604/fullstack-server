#!/bin/bash
#
# PostgreSQL Automated Backup Script
# Performs daily backups of all databases with rotation
#

set -e

# Configuration
BACKUP_DIR="/var/backups/postgresql"
RETENTION_DAYS=7
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CONTAINER_NAME="postgres"

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting PostgreSQL backup..."

# Get list of databases
DATABASES=$(sudo docker exec "$CONTAINER_NAME" psql -U postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false AND datname != 'postgres';" | grep -v '^$')

# Backup each database
for DB in $DATABASES; do
    DB_CLEAN=$(echo "$DB" | tr -d '[:space:]')
    if [ ! -z "$DB_CLEAN" ]; then
        BACKUP_FILE="$BACKUP_DIR/${DB_CLEAN}_${TIMESTAMP}.sql.gz"
        echo "Backing up database: $DB_CLEAN"
        
        sudo docker exec "$CONTAINER_NAME" pg_dump -U postgres "$DB_CLEAN" | gzip > "$BACKUP_FILE"
        
        if [ $? -eq 0 ]; then
            echo "✓ Backup successful: $BACKUP_FILE"
            # Set proper permissions
            chmod 600 "$BACKUP_FILE"
        else
            echo "✗ Backup failed for $DB_CLEAN"
        fi
    fi
done

# Backup globals (users, roles)
GLOBALS_FILE="$BACKUP_DIR/globals_${TIMESTAMP}.sql.gz"
echo "Backing up global objects (users, roles)..."
sudo docker exec "$CONTAINER_NAME" pg_dumpall -U postgres --globals-only | gzip > "$GLOBALS_FILE"
chmod 600 "$GLOBALS_FILE"

# Cleanup old backups
echo "Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

# Show backup summary
echo ""
echo "=== Backup Summary ==="
echo "Location: $BACKUP_DIR"
echo "Current backups:"
ls -lh "$BACKUP_DIR"/*.sql.gz 2>/dev/null | tail -10
echo ""
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
echo "Total backup size: $TOTAL_SIZE"
echo "[$(date)] Backup completed successfully!"
