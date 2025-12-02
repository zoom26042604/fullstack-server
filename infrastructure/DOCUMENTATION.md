# 📚 Documentation Infrastructure

## Vue d'ensemble

Cette infrastructure fournit tous les services nécessaires pour héberger vos applications fullstack en production.

## Services

### Traefik (Reverse Proxy + SSL)
- **Version**: v3.1
- **Ports**: 80 (HTTP), 443 (HTTPS), 8080 (Dashboard)
- **Dashboard**: https://traefik.zoom2604.dev
- **Auth**: Basic Auth (voir credentials.txt)
- **Fonctionnalités**:
  - SSL automatique Let's Encrypt
  - Renouvellement automatique des certificats
  - Routing multi-domaines avec PathPrefix
  - Load balancing
  - Headers de sécurité (HSTS, CSP, X-Frame-Options)

### PostgreSQL (Base de données)
- **Version**: 16
- **Port**: 5432 (localhost uniquement)
- **Optimisations**:
  - shared_buffers: 3GB
  - effective_cache_size: 9GB
  - maintenance_work_mem: 768MB
  - max_connections: 200

### pgBouncer (Connection Pooling)
- **Version**: 1.23
- **Port**: 6432 (localhost uniquement)
- **Configuration**:
  - Mode: transaction
  - Max connections: 1000
  - Pool size: 25
  - Reserve pool: 5

### Redis (Cache)
- **Version**: 7
- **Port**: 6379 (localhost uniquement)
- **Configuration**:
  - Max memory: 512MB
  - Eviction policy: allkeys-lru
  - Persistence: AOF activé

### Prometheus (Métriques)
- **Version**: v2.53
- **Port**: 9090 (localhost uniquement)
- **Rétention**: 15 jours
- **Scrape interval**: 15s
- **Targets**:
  - Node Exporter (métriques système)
  - cAdvisor (métriques Docker)
  - Traefik (métriques proxy)

### Grafana (Visualisation)
- **Version**: v11.0
- **URL**: https://grafana.zoom2604.dev
- **Auth**: Authentification requise (voir credentials.txt)
- **Dashboards préconfigurés**: 3
  - System Overview - CPU, Memory, Disk
  - Docker Containers - Métriques par container
  - Infrastructure Health - Status services (Traefik, PostgreSQL, Redis, Prometheus)

### Node Exporter (Métriques Système)
- **Port**: 9100 (localhost uniquement)
- **Métriques**:
  - CPU, RAM, Disk
  - Network I/O
  - File descriptors
  - Load average

### cAdvisor (Métriques Docker)
- **Port**: 8080 (localhost uniquement)
- **Métriques**:
  - Containers running
  - CPU/RAM par container
  - Network I/O par container
  - Disk I/O par container

## Configuration

### Variables d'environnement (.env)

```env
# Domaine principal
DOMAIN=zoom2604.dev
TZ=Europe/Paris
NETWORK_NAME=zoom2604_network

# Versions
TRAEFIK_VERSION=v3.1
POSTGRES_VERSION=16
PGBOUNCER_VERSION=1.23
REDIS_VERSION=7
PROMETHEUS_VERSION=v2.53.0
GRAFANA_VERSION=11.0.0

# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=votre-mot-de-passe-securise
POSTGRES_DB=postgres
POSTGRES_PORT=5432

# pgBouncer
PGBOUNCER_PORT=6432

# Redis
REDIS_PASSWORD=votre-mot-de-passe-redis
REDIS_PORT=6379

# Prometheus
PROMETHEUS_PORT=9090

# Grafana
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=votre-mot-de-passe-grafana

# Traefik Dashboard
TRAEFIK_DASHBOARD_USER=admin
TRAEFIK_DASHBOARD_PASSWORD_HASH=hash-bcrypt
```

### Générer les secrets

```bash
./generate-secrets.sh
```

Ce script génère automatiquement :
- Mots de passe PostgreSQL, Redis, Grafana
- Hash bcrypt pour Traefik dashboard
- Met à jour le fichier .env

## Déploiement

### Initial

```bash
cd /srv/fullstack-server/infrastructure
./scripts/maintenance/deploy-infrastructure.sh
```

### Vérifier le statut

```bash
sudo docker-compose ps
./overview.sh
```

### Voir les logs

```bash
./scripts/maintenance/logs.sh
```

## Backup & Restore

### Backup complet

```bash
./scripts/maintenance/backup.sh
```

Sauvegarde :
- Toutes les bases PostgreSQL (pg_dumpall)
- Dump Redis (RDB)
- Configurations (traefik, prometheus, grafana)
- Variables d'environnement (.env)

Dossier : `/srv/fullstack-server/infrastructure/backups/backup-YYYYMMDD-HHMMSS/`

### Restore

```bash
./scripts/maintenance/restore.sh
```

Sélectionne interactivement le backup à restaurer.

## Monitoring

### Accès Grafana

1. Ouvrir https://grafana.votre-domaine.com
2. Login: admin
3. Password: (voir .env)
4. Aller dans Dashboards
5. 3 dashboards disponibles

### Accès Prometheus

```bash
# Via navigateur (localhost uniquement)
http://localhost:9090

# Ou via tunnel SSH depuis votre machine locale
ssh -L 9090:localhost:9090 user@votre-serveur
# Puis ouvrir http://localhost:9090
```

### Requêtes utiles Prometheus

**CPU Usage**:
```promql
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

**Memory Usage**:
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

**Disk Usage**:
```promql
100 - ((node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100)
```

**Containers Running**:
```promql
count(container_last_seen)
```

## Maintenance

### Redémarrer un service

```bash
cd /srv/fullstack-server/infrastructure
sudo docker-compose restart <service>
```

### Voir les logs d'un service

```bash
sudo docker-compose logs -f <service>
```

### Nettoyer Docker

```bash
./scripts/maintenance/docker-cleanup.sh
```

### Mettre à jour l'infrastructure

```bash
./scripts/maintenance/update.sh
```

## Sécurité

### Pare-feu (UFW)

```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

### Headers de sécurité

Configurés automatiquement par Traefik :
- HSTS (Strict-Transport-Security)
- X-Frame-Options: SAMEORIGIN
- X-Content-Type-Options: nosniff
- X-XSS-Protection

### SSL/TLS

- Certificats Let's Encrypt automatiques
- Renouvellement automatique tous les 60 jours
- Stockage dans volume Docker `traefik_acme`

### Isolation réseau

- PostgreSQL et Redis accessibles uniquement en localhost
- Prometheus et Node Exporter en localhost
- Seuls Traefik et Grafana exposés publiquement
- Réseau Docker isolé `app_network`

## Troubleshooting

### Service ne démarre pas

```bash
# Voir les logs
sudo docker-compose logs <service>

# Vérifier la configuration
sudo docker-compose config

# Recréer le conteneur
sudo docker-compose up -d --force-recreate <service>
```

### Problème SSL

```bash
# Vérifier les certificats
sudo docker exec traefik cat /acme/acme.json

# Supprimer et regénérer
sudo docker-compose down
sudo docker volume rm traefik_acme
sudo docker-compose up -d
```

### Base de données inaccessible

```bash
# Vérifier PostgreSQL
sudo docker exec -it postgres psql -U postgres -c "SELECT 1"

# Vérifier pgBouncer
sudo docker exec -it pgbouncer psql -h 127.0.0.1 -p 6432 -U postgres -c "SELECT 1"
```

### Métriques manquantes

```bash
# Vérifier Prometheus targets
curl http://localhost:9090/api/v1/targets

# Redémarrer Prometheus
sudo docker-compose restart prometheus
```

## Réseau

### Architecture réseau

```
Internet
    ↓
Traefik (80, 443)
    ↓
app_network (bridge)
    ↓
├── Applications (containers)
├── PostgreSQL (localhost:5432)
├── Redis (localhost:6379)
├── Prometheus (localhost:9090)
└── Grafana (container)
```

### Ajouter une application au réseau

Dans le `docker-compose.yml` de votre app :

```yaml
networks:
  default:
    external: true
    name: app_network
```

## Performance

### Optimisations PostgreSQL

Voir `postgres/postgresql.conf` :
- shared_buffers optimisé pour 12GB RAM
- effective_cache_size configuré
- checkpoint_completion_target ajusté
- wal_buffers dimensionné

### Optimisations Redis

- maxmemory-policy: allkeys-lru (éviction LRU)
- AOF activé pour persistence
- 512MB max memory

### Optimisations Traefik

- Compression activée
- Headers de sécurité en middleware
- Keep-alive configuré

## Support

- 📧 Email : support@votre-domaine.com
- 🐛 Issues : GitHub Issues
- 📖 Documentation : README principal
