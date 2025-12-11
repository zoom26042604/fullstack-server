# 🔧 Infrastructure Docker Production

Infrastructure complète avec Traefik, PostgreSQL, Redis, Prometheus et Grafana.

## 🚀 Quick Start

```bash
# Configurer
cp .env.example .env
nano .env

# Générer les secrets
./generate-secrets.sh

# Déployer
cd scripts/maintenance
./deploy-infrastructure.sh
```

## 📊 Services

- **Traefik** - Reverse proxy + SSL auto
- **PostgreSQL 16** - Base de données
- **pgBouncer** - Connection pooling
- **Redis 7** - Cache
- **Prometheus** - Métriques
- **Grafana** - Dashboards (3 préconfigurés)
- **Node Exporter** - Métriques système
- **cAdvisor** - Métriques Docker

## 🛠️ Scripts (46 total)

```bash
cd scripts
./menu.sh  # Menu interactif principal
```

### Catégories

- **deploy/** (6) - Déployer Next.js, React, Angular, Node.js, sites statiques
- **apps/** (8) - Gérer les apps (start, stop, logs, rebuild)
- **maintenance/** (14) - Backup, restore, health-check, logs
- **system/** (6) - Monitoring système (disk, SSL, firewall, ports)
- **database/** (4) - Accès PostgreSQL/Redis, backups
- **quick/** (7) - Actions rapides (status, restart, emergency)

## 📚 Documentation

### Guides d'administration
- **ADMIN_GUIDE.md** - Guide complet d'administration
- **doc/DISASTER_RECOVERY.md** - Plan de reprise d'activité
- **doc/CLOUDFLARE_SETUP.md** - Configuration CDN Cloudflare
- **doc/LOKI_SETUP.md** - Logs centralisés avec Loki
- **doc/TRIVY_SCANNING.md** - Scan de vulnérabilités
- **grafana/ALERTING.md** - Configuration des alertes Grafana

### URLs des services
- `https://zoom2604.dev` - Homer Dashboard
- `https://zoom2604.dev/monitoring` - Grafana
- `https://zoom2604.dev/uptime` - Uptime Kuma
- `https://portainer.zoom2604.dev` - Portainer
- `https://traefik.zoom2604.dev` - Traefik Dashboard
- `https://nathan-ferre.fr` - Portfolio Azrael

## 🔐 Sécurité

✅ **Configuré**:
- SSL automatique Let's Encrypt
- Headers de sécurité Traefik
- Firewall UFW (ports 22, 80, 443)
- Fail2ban pour SSH (3 tentatives max)
- Isolation réseau Docker
- Permissions .env restrictives (600)
- Backups PostgreSQL automatiques (2h du matin)
- Resource limits sur tous les conteneurs
- Security scanning (Trivy)

## 🔄 Maintenance

### Automatique (cron)
- **02:00** - Backup PostgreSQL quotidien
- **03:00** - Nettoyage Docker
- **04:00** - Maintenance générale (dimanche)

### Commandes utiles
```bash
# Status services
sudo docker compose ps

# Logs en temps réel
sudo docker compose logs -f <service>

# Redémarrer un service
sudo docker compose restart <service>

# Backup manuel
/srv/fullstack-server/infrastructure/scripts/database/backup-postgres.sh

# Scan sécurité
/srv/fullstack-server/infrastructure/scripts/maintenance/trivy-scan.sh
```
