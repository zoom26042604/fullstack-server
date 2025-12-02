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

Voir [README principal](/README.md) pour la documentation complète.

## 🔐 Sécurité

- SSL automatique Let's Encrypt
- Headers de sécurité configurés
- Isolation réseau Docker
- Authentification sur tous les dashboards
