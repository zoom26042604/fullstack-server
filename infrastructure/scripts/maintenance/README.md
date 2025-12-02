# Scripts de Maintenance

Scripts pour la maintenance automatique de l'infrastructure.

## 📋 Scripts Disponibles

### 1. Backup PostgreSQL Automatique
**Fichier:** `backup-postgres-auto.sh`

Effectue une sauvegarde complète de toutes les bases PostgreSQL avec rotation automatique.

**Configuration:**
- Répertoire de backup: `/srv/backups/postgres/`
- Rétention: 7 jours
- Planification: Tous les jours à 2h00 (cron)

**Utilisation manuelle:**
```bash
./backup-postgres-auto.sh
```

**Cron:**
```cron
0 2 * * * /srv/fullstack-server/infrastructure/scripts/maintenance/backup-postgres-auto.sh >> /var/log/postgres-backup.log 2>&1
```

---

### 2. Nettoyage Docker
**Fichier:** `cleanup-docker.sh`

Nettoie automatiquement Docker pour libérer de l'espace disque :
- Build cache (>24h)
- Images non utilisées (>24h)
- Volumes orphelins (>24h)
- Réseaux non utilisés
- Conteneurs arrêtés (>7 jours)

**Configuration:**
- Logs: `/srv/fullstack-server/infrastructure/logs/docker-cleanup.log`
- Planification: Tous les dimanches à 3h00 (cron)
- Seuil: Éléments de plus de 24h

**Utilisation manuelle:**
```bash
# Mode normal
./cleanup-docker.sh

# Mode simulation (dry-run)
./cleanup-docker.sh --dry-run
```

**Cron:**
```cron
0 3 * * 0 /srv/fullstack-server/infrastructure/scripts/maintenance/cleanup-docker.sh >> /srv/fullstack-server/infrastructure/logs/docker-cleanup-cron.log 2>&1
```

---

## 📊 Surveillance

### Vérifier les logs

**Backup PostgreSQL:**
```bash
tail -f /var/log/postgres-backup.log
```

**Nettoyage Docker:**
```bash
tail -f /srv/fullstack-server/infrastructure/logs/docker-cleanup.log
tail -f /srv/fullstack-server/infrastructure/logs/docker-cleanup-cron.log
```

### Vérifier l'espace disque
```bash
df -h /
docker system df
```

### Lister les backups
```bash
ls -lh /srv/backups/postgres/
```

---

## 🔧 Maintenance Manuelle

### Forcer un backup immédiat
```bash
/srv/fullstack-server/infrastructure/scripts/maintenance/backup-postgres-auto.sh
```

### Nettoyer Docker en urgence (tout supprimer)
```bash
# ATTENTION: Supprime TOUT le cache et images non utilisées
docker system prune -a --volumes -f
```

### Restaurer un backup
```bash
# Lister les backups disponibles
ls -lh /srv/backups/postgres/

# Restaurer un backup spécifique
gunzip < /srv/backups/postgres/postgres_all_20251202_020000.sql.gz | docker exec -i postgres psql -U postgres
```

---

## ⚙️ Configuration des Crons

**Voir les crons actifs:**
```bash
crontab -l
```

**Modifier les crons:**
```bash
crontab -e
```

**Planning actuel:**
- `2h00` : Backup PostgreSQL (quotidien)
- `3h00` : Nettoyage Docker (hebdomadaire, dimanche)
