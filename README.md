# 🏠 Homelab Infrastructure

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-K3s-326CE5.svg)](https://k3s.io/)
[![Docker](https://img.shields.io/badge/Docker-24.0+-blue.svg)](https://www.docker.com/)
[![Traefik](https://img.shields.io/badge/Traefik-v3.1-00ADD8.svg)](https://traefik.io/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-336791.svg)](https://www.postgresql.org/)
[![Grafana](https://img.shields.io/badge/Grafana-11.0-F46800.svg)](https://grafana.com/)

**Infrastructure homelab production-ready** pour déployer vos applications sur VPS avec Kubernetes (K3s), SSL automatique, monitoring complet et GitOps.

---

## ✨ Fonctionnalités

- 🔒 **SSL Automatique** - Let's Encrypt via Traefik, renouvellement auto
- 🔄 **Reverse Proxy** - Routing intelligent multi-domaines avec PathPrefix
- 🗄️ **Base de Données** - PostgreSQL 16 + pgBouncer (connection pooling)
- ⚡ **Cache Redis** - Performance maximale avec stratégie LRU
- 📊 **Monitoring Complet** - Prometheus + Grafana avec 3 dashboards
- 🛠️ **46 Scripts Admin** - Déploiement, gestion apps, maintenance, monitoring
- 🔐 **Production-Ready** - Headers sécurité, HSTS, isolation containers
- 📦 **Multi-Framework** - Next.js, React, Angular, Node.js, sites statiques

---

## 🎯 Quick Start

### Prérequis

- VPS avec 8GB RAM minimum (12GB recommandé)
- Debian 11+ ou Ubuntu 20.04+
- Docker & Docker Compose installés
- Nom de domaine pointant vers votre VPS

### Installation (5 minutes)

```bash
# 1. Cloner le repo
git clone https://github.com/zoom26042604/homelab.git
cd homelab

# 2. Option A: Docker Compose (legacy)
cd infrastructure
cp .env.example .env
nano .env
./generate-secrets.sh

# 2. Option B: Kubernetes (recommandé)
cd kubernetes
chmod +x install-k3s.sh
sudo ./install-k3s.sh
chmod +x scripts/maintenance/deploy-infrastructure.sh
./scripts/maintenance/deploy-infrastructure.sh

# 5. Déployer votre première app
cd scripts/deploy
./deploy.sh
```

**C'est tout ! Votre infrastructure est prête.** 🎉

---

## 📋 Stack Technique

| Composant | Version | Rôle |
|-----------|---------|------|
| **Traefik** | v3.1 | Reverse proxy + SSL automatique |
| **PostgreSQL** | 16 | Base de données relationnelle |
| **pgBouncer** | 1.23 | Connection pooling (max 1000 connexions) |
| **Redis** | 7 | Cache en mémoire (512MB) |
| **Prometheus** | v2.53 | Collecte de métriques |
| **Grafana** | v11.0 | Visualisation et dashboards |
| **Node Exporter** | latest | Métriques système |
| **cAdvisor** | latest | Métriques Docker |

---

## 🛠️ Scripts d'Administration (46 scripts)

### Menu Principal
```bash
cd infrastructure/scripts
./menu.sh
```

### 6 Catégories

#### 🚀 **deploy/** - Déploiement Applications (6 scripts)
- `deploy-nextjs.sh` - Déployer Next.js avec SSR
- `deploy-react.sh` - Déployer React/Vite SPA
- `deploy-angular.sh` - Déployer Angular
- `deploy-node.sh` - Déployer API Node.js/Express
- `deploy-static.sh` - Déployer site HTML/CSS/JS

#### 📱 **apps/** - Gestion Applications (8 scripts)
- `app-manager.sh` - Menu interactif complet
- `list-apps.sh`, `start-app.sh`, `stop-app.sh`, `restart-app.sh`
- `logs-app.sh`, `status-app.sh`, `rebuild-app.sh`

#### 🛠️ **maintenance/** - Maintenance Infrastructure (14 scripts)
- `backup.sh`, `restore.sh` - Sauvegardes complètes
- `health-check.sh` - Vérification santé services
- `logs.sh`, `stats.sh` - Monitoring et diagnostics
- `docker-cleanup.sh` - Nettoyage images/conteneurs

#### 🖥️ **system/** - Monitoring Système (6 scripts)
- `system-info.sh` - Info complète serveur
- `disk-usage.sh` - Analyse espace disque
- `ssl-check.sh` - Vérification certificats SSL
- `firewall-status.sh`, `open-ports.sh`

#### 🗄️ **database/** - Gestion BDD (4 scripts)
- `db-shell.sh` - Shell PostgreSQL direct
- `redis-cli.sh` - CLI Redis
- `db-backup-now.sh`, `db-query.sh`

#### ⚡ **quick/** - Actions Rapides (7 scripts)
- `full-status.sh` - Status complet en 2 secondes
- `quick-restart.sh` - Restart rapide infrastructure
- `emergency-stop.sh` - Arrêt d'urgence
- `container-shell.sh`, `docker-stats-live.sh`

---

## 📊 Monitoring & Dashboards

### Grafana - 3 Dashboards Préconfigurés

1. **System Overview** - CPU, RAM, Disk, Network
2. **Docker Containers** - Métriques containers en temps réel
3. **Infrastructure Health** - Vue d'ensemble globale

**Accès** : `https://grafana.zoom2604.dev`  
**Credentials** : Voir `infrastructure/credentials.txt`

### Prometheus

- Rétention : 15 jours
- Scrape interval : 15s
- Métriques système + Docker + applications

**Accès** : `https://prometheus.zoom2604.dev`  
**Auth** : Basic Auth (mêmes identifiants que Traefik)

---

## 🏗️ Architecture

```
/srv/
├── fullstack-server/
│   └── infrastructure/
│       ├── docker-compose.yml      # 8 services
│       ├── traefik/                # Reverse proxy config
│       ├── postgres/               # DB init scripts
│       ├── grafana/                # 3 dashboards
│       ├── prometheus/             # Métriques
│       └── scripts/                # 46 scripts admin
│           ├── menu.sh             # Menu principal
│           ├── deploy/             # 6 scripts
│           ├── apps/               # 8 scripts
│           ├── maintenance/        # 14 scripts
│           ├── system/             # 6 scripts
│           ├── database/           # 4 scripts
│           └── quick/              # 7 scripts
│
├── domain1.com/
│   ├── app1/                       # Next.js
│   │   ├── docker-compose.yml
│   │   └── ...
│   └── app2/                       # React
│
└── domain2.com/
    └── app1/                       # Node.js API
```

**Organisation multi-domaines** : Chaque app dans `/srv/domain.com/app-name/`

**URLs** : `https://domain.com/app-name` (PathPrefix routing)

---

## 🚀 Déployer une Application

### Exemple : Blog Next.js

```bash
cd infrastructure/scripts/deploy
./deploy-nextjs.sh

# Questions interactives :
# - Domaine : monsite.com
# - Nom app : blog
# - PostgreSQL : yes
# - Redis : yes

# Résultat :
# ✅ App déployée dans /srv/monsite.com/blog/
# ✅ Accessible sur https://monsite.com/blog
# ✅ SSL automatique
# ✅ Base de données créée
```

### Frameworks Supportés

- ✅ **Next.js** - SSR, API Routes, Image optimization
- ✅ **React/Vite** - SPA optimisé, build multi-stage
- ✅ **Angular** - Version configurable, build AOT
- ✅ **Node.js** - Express, NestJS, API REST/GraphQL
- ✅ **HTML/CSS/JS** - Sites statiques, nginx

---

## 🔐 Sécurité

- ✅ SSL/TLS automatique (Let's Encrypt)
- ✅ Headers de sécurité (HSTS, CSP, X-Frame-Options)
- ✅ Isolation réseau Docker
- ✅ Secrets via variables d'environnement
- ✅ PostgreSQL en localhost uniquement
- ✅ Redis protected mode
- ✅ Traefik dashboard avec auth
- ✅ Grafana avec authentification

---

## 📚 Documentation

- [Déploiement](/doc/DEPLOYMENT.md) - Guide complet de déploiement
- [Monitoring](/TEST_MONITORING.md) - Tester Prometheus & Grafana
- [Scripts](/infrastructure/scripts/README.md) - Documentation des 46 scripts
- [Sécurité](/SECURITY.md) - Best practices de sécurité

---

## 🔧 Configuration

### Variables d'Environnement

Fichier `.env` :

```env
# Domaine principal
DOMAIN=votre-domaine.com

# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=votre-mot-de-passe-securise
POSTGRES_DB=postgres

# Redis
REDIS_PASSWORD=votre-mot-de-passe-redis

# Traefik Dashboard
TRAEFIK_DASHBOARD_USER=admin
TRAEFIK_DASHBOARD_PASSWORD_HASH=hash-bcrypt

# Grafana
GRAFANA_ADMIN_PASSWORD=votre-mot-de-passe-grafana
```

Générer les secrets :
```bash
./infrastructure/generate-secrets.sh
```

---

## 📦 Exemples d'Applications

Le dossier `examples/` contient des apps prêtes à déployer :

- **nextjs-app/** - Blog avec Prisma + PostgreSQL
- **react-app/** - Dashboard avec React + Vite
- **node-api/** - API REST avec Express
- (plus à venir...)

---

## 🤝 Contribution

Les contributions sont les bienvenues !

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

---

## 📝 License

MIT License - voir [LICENSE](LICENSE)

---

## 🎯 Roadmap

- [ ] Support Kubernetes (Helm charts)
- [ ] Logs centralisés (Loki + Promtail)
- [ ] CI/CD GitHub Actions
- [ ] Backups automatisés S3
- [ ] Support MariaDB/MySQL
- [ ] Support MongoDB
- [ ] Templates Terraform/Ansible

---

## 💡 Support

- 🐛 Issues : [GitHub Issues](https://github.com/zoom26042604/fullstack-server/issues)
- 📖 Documentation : [infrastructure/DOCUMENTATION.md](infrastructure/DOCUMENTATION.md)
- 🚀 Examples : [examples/](examples/)

---

## 🌟 Déjà Déployé

**Production en ligne** :
- 🌐 Portfolio : https://zoom2604.dev/portfolio

---

⭐ Si ce projet vous aide, n'oubliez pas de mettre une étoile sur [GitHub](https://github.com/zoom26042604/fullstack-server) !
