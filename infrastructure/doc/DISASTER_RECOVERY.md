# Plan de Reprise d'Activité (Disaster Recovery)

Documentation complète pour restaurer l'infrastructure en cas de sinistre.

## Vue d'ensemble

Cette documentation permet de restaurer l'infrastructure complète depuis zéro.

### Informations critiques

- **Serveur**: OVH VPS - 51.91.76.23
- **OS**: Debian 13 (Trixie)
- **Domaines**: zoom2604.dev, nathan-ferre.fr
- **Registrar**: OVH
- **Repository**: GitHub (zoom26042604)

## Scénarios de sinistre

### 1. Panne conteneur unique
**Temps de récupération**: < 5 minutes

```bash
cd /srv/fullstack-server/infrastructure
sudo docker compose up -d <service_name>
```

### 2. Corruption base de données
**Temps de récupération**: 10-30 minutes

```bash
# Arrêter le conteneur
sudo docker compose stop postgres

# Restaurer depuis backup
cd /var/backups/postgresql
gunzip -c admin_db_YYYYMMDD_HHMMSS.sql.gz | \
  sudo docker exec -i postgres psql -U postgres admin_db

# Redémarrer
sudo docker compose start postgres
```

### 3. Perte complète du serveur
**Temps de récupération**: 2-4 heures

## Procédure de restauration complète

### Phase 1: Nouveau serveur (30 min)

#### 1.1 Provisioning serveur
```bash
# Chez OVH :
# - Créer nouveau VPS
# - Installer Debian 13
# - Noter nouvelle IP

# Configurer DNS (OVH ou registrar)
# A zoom2604.dev → NOUVELLE_IP
# A nathan-ferre.fr → NOUVELLE_IP
# A portainer.zoom2604.dev → NOUVELLE_IP
# A traefik.zoom2604.dev → NOUVELLE_IP
```

#### 1.2 Configuration système
```bash
# SSH vers nouveau serveur
ssh root@NOUVELLE_IP

# Mise à jour système
apt update && apt upgrade -y

# Installation paquets essentiels
apt install -y \
  docker.io \
  docker-compose \
  git \
  curl \
  wget \
  ufw \
  fail2ban \
  vim

# Configuration utilisateur
adduser zoom
usermod -aG sudo,docker zoom
su - zoom
```

#### 1.3 Configuration firewall
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'
sudo ufw --force enable
```

#### 1.4 Configuration fail2ban
```bash
sudo cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = ssh
maxretry = 3
EOF

sudo systemctl restart fail2ban
sudo systemctl enable fail2ban
```

### Phase 2: Restauration code (15 min)

#### 2.1 Cloner les repositories
```bash
cd /
sudo mkdir -p srv
sudo chown zoom:zoom srv
cd /srv

# Clone infrastructure
git clone git@github.com:zoom26042604/fullstack-server.git
git clone git@github.com:zoom26042604/nathan-ferre.fr.git
git clone git@github.com:zoom26042604/yggdrasil.git
git clone git@github.com:zoom26042604/zoom2604.dev.git
```

#### 2.2 Restaurer configurations
```bash
cd /srv/fullstack-server/infrastructure

# Créer .env depuis backup ou template
cp .env.example .env

# ÉDITER .env avec valeurs correctes:
nano .env
```

Variables critiques dans `.env` :
```bash
DOMAIN=zoom2604.dev
TZ=Europe/Paris
TRAEFIK_VERSION=v3.1

# PostgreSQL
POSTGRES_VERSION=16-alpine
POSTGRES_USER=postgres
POSTGRES_PASSWORD=[DEPUIS BACKUP]
POSTGRES_DB=postgres

# Grafana
GRAFANA_VERSION=11.0.0
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=[DEPUIS BACKUP]

# Traefik Dashboard
TRAEFIK_DASHBOARD_USER=admin
TRAEFIK_DASHBOARD_PASSWORD=[DEPUIS BACKUP]
```

### Phase 3: Restauration données (30 min)

#### 3.1 Créer réseau Docker
```bash
sudo docker network create zoom2604_network
```

#### 3.2 Restaurer volumes critiques

```bash
# Si backups disponibles sur stockage externe/S3
# Télécharger backups
mkdir -p /tmp/restore
cd /tmp/restore

# Exemple avec S3 (si configuré)
# aws s3 sync s3://backups-zoom2604/postgresql/ ./postgresql/
# aws s3 sync s3://backups-zoom2604/grafana/ ./grafana/

# Ou depuis backup local si disponible
scp user@backup-server:/backups/postgresql/* ./postgresql/
```

#### 3.3 Démarrer base de données
```bash
cd /srv/fullstack-server/infrastructure

# Démarrer seulement PostgreSQL
sudo docker compose up -d postgres

# Attendre démarrage
sleep 10

# Restaurer données
cd /tmp/restore/postgresql
for backup in *.sql.gz; do
    db_name=$(echo $backup | cut -d'_' -f1)
    echo "Restoring $db_name..."
    gunzip -c $backup | sudo docker exec -i postgres psql -U postgres -d $db_name
done

# Restaurer globals (users, roles)
gunzip -c globals_*.sql.gz | sudo docker exec -i postgres psql -U postgres
```

### Phase 4: Démarrage services (45 min)

#### 4.1 Build images custom
```bash
cd /srv/fullstack-server/infrastructure

# Build Azrael portfolio
sudo docker compose build azrael
```

#### 4.2 Démarrer infrastructure
```bash
# Démarrer tous les services
sudo docker compose up -d

# Vérifier statut
sudo docker compose ps

# Vérifier logs
sudo docker compose logs -f --tail=50
```

#### 4.3 Vérifications
```bash
# Test DNS
dig zoom2604.dev
dig nathan-ferre.fr

# Test HTTPS
curl -I https://zoom2604.dev
curl -I https://nathan-ferre.fr
curl -I https://portainer.zoom2604.dev
curl -I https://traefik.zoom2604.dev

# Test services
curl https://zoom2604.dev/monitoring  # Grafana
curl https://zoom2604.dev/uptime       # Uptime Kuma
```

### Phase 5: Configuration post-restauration (30 min)

#### 5.1 Cron jobs
```bash
# Backup PostgreSQL
(sudo crontab -l 2>/dev/null; echo "0 2 * * * /srv/fullstack-server/infrastructure/scripts/database/backup-postgres.sh >> /var/log/postgresql-backup.log 2>&1") | sudo crontab -

# Docker cleanup
(sudo crontab -l 2>/dev/null; echo "0 3 * * * docker system prune -af --filter 'until=72h' >> /var/log/docker-cleanup.log 2>&1") | sudo crontab -
```

#### 5.2 Grafana
```bash
# Accéder https://zoom2604.dev/monitoring
# Login: admin / [password depuis .env]

# Reconfigurer:
# - Data sources (Prometheus, Loki si installé)
# - Dashboards (importer depuis backup ou IDs)
# - Alerting (contact points, alert rules)
```

#### 5.3 Portainer
```bash
# Accéder https://portainer.zoom2604.dev
# Créer compte admin initial
# Connecter à environnement Docker local
```

## Backups critiques

### Localisation des backups

```
/var/backups/
├── postgresql/          # Bases de données (cron quotidien 2AM)
│   ├── admin_db_*.sql.gz
│   └── globals_*.sql.gz
├── volumes/            # Volumes Docker (manuel)
│   ├── grafana_data/
│   ├── prometheus_data/
│   └── traefik_acme/
└── configs/           # Configurations (manuel)
    ├── .env
    ├── docker-compose.yml
    └── traefik/
```

### Script backup complet

```bash
#!/bin/bash
# /srv/fullstack-server/infrastructure/scripts/maintenance/full-backup.sh

BACKUP_DIR="/tmp/full-backup-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup PostgreSQL
/srv/fullstack-server/infrastructure/scripts/database/backup-postgres.sh

# Backup volumes
docker run --rm -v grafana_data:/data -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/grafana_data.tar.gz -C /data .

docker run --rm -v prometheus_data:/data -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/prometheus_data.tar.gz -C /data .

docker run --rm -v traefik_acme:/data -v $BACKUP_DIR:/backup \
  alpine tar czf /backup/traefik_acme.tar.gz -C /data .

# Backup configurations
cp -r /srv/fullstack-server/infrastructure/.env $BACKUP_DIR/
cp -r /srv/fullstack-server/infrastructure/traefik $BACKUP_DIR/

# Créer archive finale
cd /tmp
tar czf full-backup-$(date +%Y%m%d).tar.gz full-backup-$(date +%Y%m%d)

echo "Backup complet: /tmp/full-backup-$(date +%Y%m%d).tar.gz"
```

### Backup externe (recommandé)

```bash
# S3 (recommandé pour production)
apt install -y awscli
aws configure  # Configurer credentials

# Upload backup vers S3
aws s3 sync /var/backups/postgresql/ s3://backups-zoom2604/postgresql/
aws s3 cp /tmp/full-backup-*.tar.gz s3://backups-zoom2604/full/

# Ou rsync vers serveur backup
rsync -avz /var/backups/ backup-server:/backups/zoom2604/
```

## Contacts d'urgence

### Fournisseurs
- **OVH Support**: https://www.ovh.com/manager/
- **Registrar DNS**: OVH
- **GitHub**: https://github.com

### Documentation
- **Infrastructure**: /srv/fullstack-server/infrastructure/
- **Traefik**: https://doc.traefik.io/traefik/
- **Docker**: https://docs.docker.com/

## Tests du plan DR

### Test trimestriel recommandé

```bash
# 1. Test restauration DB (environnement dev)
# 2. Test déploiement complet (serveur test)
# 3. Vérifier backups accessibles
# 4. Documenter temps réel vs estimé
# 5. Mettre à jour procédures si nécessaire
```

### Checklist validation

- [ ] DNS pointe vers nouveau serveur
- [ ] SSL/TLS fonctionne (Let's Encrypt)
- [ ] Tous conteneurs healthy
- [ ] Bases de données restaurées
- [ ] Grafana accessible avec données
- [ ] Prometheus collecte métriques
- [ ] Traefik route correctement
- [ ] Uptime Kuma monitore services
- [ ] Backups automatiques configurés
- [ ] Firewall actif
- [ ] Fail2ban actif
- [ ] Cron jobs configurés

## Améliorations futures

### Automatisation

1. **Terraform**: Infrastructure as Code
2. **Ansible**: Configuration automatique
3. **GitHub Actions**: CI/CD pour backups
4. **S3**: Stockage offsite automatique

### Haute disponibilité

1. **Load Balancer**: Multi-serveurs
2. **PostgreSQL Replication**: Standby automatique
3. **DNS failover**: Automatic DNS switch
4. **Monitoring externe**: UptimeRobot + PagerDuty

## Mesures préventives

- Backups quotidiens automatiques ✓
- Monitoring 24/7 avec alertes ✓
- Firewall configuré ✓
- Fail2ban actif ✓
- Updates régulières
- Documentation à jour ✓
- Tests DR trimestriels (à planifier)

## Notes importantes

⚠️ **Ne jamais**:
- Exposer ports DB directement (127.0.0.1 only)
- Commit secrets dans Git
- Négliger les backups
- Ignorer les alertes monitoring

✓ **Toujours**:
- Tester les backups régulièrement
- Maintenir documentation à jour
- Vérifier Let's Encrypt renouvelle
- Monitorer espace disque
- Suivre logs d'erreurs
