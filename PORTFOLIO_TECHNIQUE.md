# 🏗️ Portfolio Technique - Infrastructure Self-Hosted

> **Projet personnel réalisé par zoom2604**  
> Infrastructure de production complète déployée sur VPS OVH  
> *Réalisé entièrement en autonomie pour développer mes compétences DevOps*

---

## 📋 Sommaire

1. [Vue d'ensemble du projet](#vue-densemble-du-projet)
2. [Stack technologique](#stack-technologique)
3. [Architecture détaillée](#architecture-détaillée)
4. [Services déployés](#services-déployés)
5. [Compétences développées](#compétences-développées)
6. [Configurations avancées](#configurations-avancées)
7. [Scripts d'administration](#scripts-dadministration)
8. [Monitoring et observabilité](#monitoring-et-observabilité)
9. [Sécurité implémentée](#sécurité-implémentée)
10. [Défis rencontrés et solutions](#défis-rencontrés-et-solutions)
11. [Évolutions futures](#évolutions-futures)

---

## 🎯 Vue d'ensemble du projet

### Objectif
Créer une **infrastructure complète de production** pour héberger mes projets personnels et ceux de mes clients, avec une approche **Infrastructure as Code** et des bonnes pratiques DevOps.

### Résultat
- **12 services Docker** fonctionnant en production
- **46 scripts d'administration** automatisés
- **3 dashboards Grafana** de monitoring
- **SSL automatique** avec Let's Encrypt
- **Haute disponibilité** avec healthchecks et auto-restart

### Sites hébergés
| Site | URL | Technologies |
|------|-----|--------------|
| Dashboard principal | https://zoom2604.dev | Homer |
| Monitoring | https://zoom2604.dev/monitoring | Grafana |
| Uptime | https://zoom2604.dev/uptime | Uptime Kuma |
| Portfolio Nathan | https://nathan-ferre.fr | Next.js 16 (Azrael) |
| Portainer | https://portainer.zoom2604.dev | Portainer CE |
| Traefik Dashboard | https://traefik.zoom2604.dev | Traefik v3.1 |

---

## 🛠️ Stack technologique

### Infrastructure Core

| Technologie | Version | Usage | Pourquoi ce choix |
|-------------|---------|-------|-------------------|
| **Docker** | 24.0+ | Containerisation | Standard industrie, isolation parfaite |
| **Docker Compose** | 3.9 | Orchestration | Simplicité pour single-node |
| **Traefik** | v3.1 | Reverse Proxy + SSL | Auto-discovery, Let's Encrypt natif |
| **Debian** | 13 (Trixie) | OS Serveur | Stabilité, sécurité, légèreté |

### Base de données

| Technologie | Version | Usage | Configuration |
|-------------|---------|-------|---------------|
| **PostgreSQL** | 16 | SGBD principal | 3GB shared_buffers, max 1000 connexions |
| **pgBouncer** | 1.23 | Connection pooling | Mode transaction, 25 pool size |
| **Redis** | 7 | Cache in-memory | 512MB max, politique LRU |

### Monitoring & Observabilité

| Technologie | Version | Usage | Métriques |
|-------------|---------|-------|-----------|
| **Prometheus** | v2.53 | Collecte métriques | Rétention 15 jours, scrape 15s |
| **Grafana** | 11.0 | Visualisation | 3 dashboards préconfigurés |
| **Node Exporter** | latest | Métriques système | CPU, RAM, Disk, Network |
| **cAdvisor** | latest | Métriques Docker | Container stats temps réel |
| **Uptime Kuma** | 1.x | Monitoring uptime | Alertes, statut pages |

### Applications Web

| Technologie | Version | Usage |
|-------------|---------|-------|
| **Next.js** | 16.x | Framework React SSR |
| **React** | 19.x | UI Components |
| **TypeScript** | 5.x | Type safety |
| **Tailwind CSS** | 4.x | Styling |
| **Prisma** | 6.x | ORM PostgreSQL |

### Outils DevOps

| Outil | Usage |
|-------|-------|
| **Homer** | Dashboard de services |
| **Portainer** | Gestion Docker GUI |
| **Git** | Versioning |
| **UFW** | Firewall |
| **Fail2ban** | Protection SSH |

---

## 🏛️ Architecture détaillée

### Diagramme d'architecture

```
                                    ┌─────────────────┐
                                    │   INTERNET      │
                                    │   (Clients)     │
                                    └────────┬────────┘
                                             │
                                             ▼
                               ┌─────────────────────────┐
                               │      CLOUDFLARE        │
                               │   (CDN + Protection)   │
                               └────────────┬───────────┘
                                            │
                              ┌─────────────▼───────────┐
                              │      OVH VPS            │
                              │   51.91.76.23           │
                              │   12GB RAM / 99GB SSD   │
                              └─────────────┬───────────┘
                                            │
┌───────────────────────────────────────────┼───────────────────────────────────────────┐
│                                           │                                           │
│   ┌───────────────────────────────────────▼───────────────────────────────────────┐   │
│   │                         TRAEFIK v3.1 (Reverse Proxy)                          │   │
│   │                         Ports: 80 → 443 redirect                              │   │
│   │                         SSL: Let's Encrypt auto                               │   │
│   └───────┬───────────┬───────────┬───────────┬───────────┬───────────┬───────────┘   │
│           │           │           │           │           │           │               │
│           ▼           ▼           ▼           ▼           ▼           ▼               │
│   ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐ │
│   │  HOMER    │ │  GRAFANA  │ │ UPTIME    │ │ AZRAEL    │ │PORTAINER  │ │ PORTFOLIO │ │
│   │ Dashboard │ │ Monitoring│ │  KUMA     │ │ Portfolio │ │  Docker   │ │ zoom2604  │ │
│   │  :8080    │ │  :3000    │ │  :3001    │ │  :3000    │ │  :9000    │ │  :3000    │ │
│   └───────────┘ └─────┬─────┘ └───────────┘ └─────┬─────┘ └───────────┘ └─────┬─────┘ │
│                       │                           │                           │       │
│                       ▼                           │                           │       │
│   ┌───────────────────────────────────┐          │                           │       │
│   │         PROMETHEUS v2.53          │          │                           │       │
│   │        Métriques :9090            │          │                           │       │
│   └───────┬───────────┬───────────────┘          │                           │       │
│           │           │                          │                           │       │
│           ▼           ▼                          │                           │       │
│   ┌───────────┐ ┌───────────┐                    │                           │       │
│   │  NODE     │ │ cADVISOR  │                    │                           │       │
│   │ EXPORTER  │ │  Docker   │                    │                           │       │
│   │  :9100    │ │  :8080    │                    │                           │       │
│   └───────────┘ └───────────┘                    │                           │       │
│                                                  │                           │       │
│   ┌──────────────────────────────────────────────┼───────────────────────────┼─────┐ │
│   │                     DATA LAYER               │                           │     │ │
│   │  ┌───────────────┐    ┌───────────────┐     │                           │     │ │
│   │  │  POSTGRESQL   │    │    REDIS      │◄────┴───────────────────────────┘     │ │
│   │  │    16         │    │      7        │                                       │ │
│   │  │   :5432       │    │    :6379      │                                       │ │
│   │  └───────┬───────┘    └───────────────┘                                       │ │
│   │          │                                                                     │ │
│   │          ▼                                                                     │ │
│   │  ┌───────────────┐                                                             │ │
│   │  │  PGBOUNCER    │                                                             │ │
│   │  │  Pool :6432   │                                                             │ │
│   │  └───────────────┘                                                             │ │
│   └───────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                     │
│                              DOCKER NETWORK: zoom2604_network                       │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

### Structure des fichiers

```
/srv/
├── fullstack-server/                    # Repo principal (ce projet)
│   ├── infrastructure/
│   │   ├── docker-compose.yml           # 12 services définis
│   │   ├── .env                         # Variables (non committé)
│   │   ├── .env.example                 # Template
│   │   ├── generate-secrets.sh          # Génération sécurisée
│   │   │
│   │   ├── traefik/
│   │   │   ├── traefik.yml              # Config principale
│   │   │   └── config.yml               # Middlewares
│   │   │
│   │   ├── postgres/
│   │   │   ├── postgresql.conf          # Optimisé 12GB RAM
│   │   │   └── init/                    # Scripts init
│   │   │
│   │   ├── grafana/
│   │   │   ├── dashboards/              # 3 dashboards JSON
│   │   │   └── provisioning/            # Auto-config
│   │   │
│   │   ├── prometheus/
│   │   │   └── prometheus.yml           # Scrape configs
│   │   │
│   │   ├── redis/
│   │   │   └── redis.conf               # Optimisé cache
│   │   │
│   │   ├── homer/
│   │   │   └── config.yml               # Dashboard config
│   │   │
│   │   ├── scripts/                     # 46 scripts admin
│   │   │   ├── menu.sh                  # Menu principal
│   │   │   ├── deploy/                  # 6 scripts déploiement
│   │   │   ├── apps/                    # 8 scripts gestion apps
│   │   │   ├── maintenance/             # 14 scripts maintenance
│   │   │   ├── system/                  # 6 scripts système
│   │   │   ├── database/                # 4 scripts BDD
│   │   │   └── quick/                   # 7 scripts rapides
│   │   │
│   │   └── doc/
│   │       ├── DISASTER_RECOVERY.md
│   │       ├── CLOUDFLARE_SETUP.md
│   │       ├── LOKI_SETUP.md
│   │       └── TRIVY_SCANNING.md
│   │
│   ├── README.md
│   ├── SECURITY.md
│   └── LICENSE (MIT)
│
├── zoom2604.dev/                        # Portfolio personnel
│   ├── portfolio/                       # Next.js 16
│   └── admin/                           # Panel admin Next.js
│
├── nathan-ferre.fr/                     # Portfolio client
│   └── azrael/                          # Next.js 16 + PWA
│
└── yggdrasil/                           # Application Next.js
    └── yggdrasil/                       # Next.js 15 + Prisma
```

---

## 🚀 Services déployés

### Détail de chaque service (11 services actifs)

#### 1. Traefik (Reverse Proxy)
```yaml
Configuration clé:
- Version: v3.1
- SSL automatique Let's Encrypt
- Routing multi-domaines
- Middlewares de sécurité (HSTS, X-Frame-Options)
- Dashboard sécurisé par Basic Auth
- Métriques Prometheus exposées
```

**Ce que j'ai appris** : Configuration avancée de labels Docker pour le routing dynamique, gestion des certificats SSL, middlewares de sécurité HTTP.

#### 2. PostgreSQL (Base de données)
```yaml
Configuration clé:
- Version: 16-alpine
- shared_buffers: 3GB (25% RAM)
- effective_cache_size: 9GB
- max_connections: 1000
- Logging complet activé
- pg_stat_statements pour monitoring
```

**Ce que j'ai appris** : Tuning de PostgreSQL selon la RAM disponible, monitoring des requêtes, backup automatisé.

#### 3. pgBouncer (Connection Pooling)
```yaml
Configuration clé:
- Mode: transaction
- Max client connections: 1000
- Default pool size: 25
- Reserve pool: 5
```

**Ce que j'ai appris** : Pourquoi le pooling est essentiel, différents modes (session, transaction, statement).

#### 4. Redis (Cache)
```yaml
Configuration clé:
- Maxmemory: 512MB
- Eviction policy: allkeys-lru
- AOF désactivé (cache pur)
- Commandes dangereuses renommées
```

**Ce que j'ai appris** : Stratégies d'éviction, sécurisation de Redis, différence entre cache et persistence.

#### 5. Prometheus (Métriques)
```yaml
Configuration clé:
- Scrape interval: 15s
- Rétention: 15 jours
- Targets: Node Exporter, cAdvisor, Traefik
```

**Ce que j'ai appris** : PromQL pour les requêtes, configuration des scrape jobs, alerting rules.

#### 6. Grafana (Dashboards)
```yaml
Configuration clé:
- 3 dashboards préconfigurés
- Provisioning automatique
- Datasource Prometheus connectée
```

**Ce que j'ai appris** : Création de dashboards, variables, alertes visuelles.

---

## 💪 Compétences développées

### DevOps & Infrastructure

| Compétence | Niveau | Détail |
|------------|--------|--------|
| **Docker** | ⭐⭐⭐⭐⭐ | Multi-stage builds, networking, volumes |
| **Docker Compose** | ⭐⭐⭐⭐⭐ | Services complexes, depends_on, healthchecks |
| **Traefik** | ⭐⭐⭐⭐ | SSL auto, routing avancé, middlewares |
| **Nginx** | ⭐⭐⭐ | Configuration serveur web |
| **Linux Admin** | ⭐⭐⭐⭐ | Systemd, cron, permissions, firewall |
| **Shell Scripting** | ⭐⭐⭐⭐ | Bash, automatisation, menus interactifs |
| **Git** | ⭐⭐⭐⭐ | Branching, .gitignore, history management |

### Bases de données

| Compétence | Niveau | Détail |
|------------|--------|--------|
| **PostgreSQL** | ⭐⭐⭐⭐ | Tuning, backup, monitoring |
| **Redis** | ⭐⭐⭐ | Cache strategies, commands |
| **Prisma ORM** | ⭐⭐⭐⭐ | Schema, migrations, queries |

### Monitoring & Observabilité

| Compétence | Niveau | Détail |
|------------|--------|--------|
| **Prometheus** | ⭐⭐⭐⭐ | PromQL, scraping, rules |
| **Grafana** | ⭐⭐⭐⭐ | Dashboards, provisioning |
| **Metrics Design** | ⭐⭐⭐ | Four golden signals |

### Sécurité

| Compétence | Niveau | Détail |
|------------|--------|--------|
| **SSL/TLS** | ⭐⭐⭐⭐ | Let's Encrypt, certificats |
| **Firewall** | ⭐⭐⭐⭐ | UFW, iptables basics |
| **Auth** | ⭐⭐⭐ | Basic Auth, JWT, sessions |
| **Secrets Management** | ⭐⭐⭐ | Env vars, .gitignore |

### Développement Web

| Compétence | Niveau | Détail |
|------------|--------|--------|
| **Next.js** | ⭐⭐⭐⭐ | App Router, SSR, API Routes |
| **React** | ⭐⭐⭐⭐ | Hooks, Context, Components |
| **TypeScript** | ⭐⭐⭐⭐ | Types, Interfaces, Generics |
| **Tailwind CSS** | ⭐⭐⭐⭐ | Utility-first, responsive |

---

## ⚙️ Configurations avancées

### Optimisation PostgreSQL (postgresql.conf)

```properties
# Mémoire - Optimisé pour 12GB RAM
shared_buffers = 3GB              # 25% de la RAM
effective_cache_size = 9GB        # 75% de la RAM  
maintenance_work_mem = 768MB
work_mem = 16MB

# WAL - Optimisé pour performance
wal_buffers = 16MB
min_wal_size = 1GB
max_wal_size = 4GB
checkpoint_completion_target = 0.9

# Monitoring
shared_preload_libraries = 'pg_stat_statements'
track_io_timing = on
```

### Sécurité Redis (redis.conf)

```properties
# Commandes dangereuses désactivées
rename-command FLUSHDB ""
rename-command FLUSHALL ""
rename-command CONFIG ""

# Mémoire
maxmemory 512mb
maxmemory-policy allkeys-lru
```

### Headers de sécurité Traefik

```yaml
# HSTS - 1 an
stsSeconds: 31536000
stsIncludeSubdomains: true
stsPreload: true

# Protection XSS et clickjacking
browserXssFilter: true
contentTypeNosniff: true
frameDeny: true
```

---

## 📜 Scripts d'administration

### Vue d'ensemble (46 scripts)

```
scripts/
├── menu.sh                    # Menu principal interactif
│
├── deploy/                    # 6 scripts
│   ├── deploy.sh              # Menu déploiement
│   ├── deploy-nextjs.sh       # Déployer Next.js
│   ├── deploy-react.sh        # Déployer React SPA
│   ├── deploy-angular.sh      # Déployer Angular
│   ├── deploy-node.sh         # Déployer Node.js API
│   └── deploy-static.sh       # Déployer site statique
│
├── apps/                      # 8 scripts
│   ├── app-manager.sh         # Gestionnaire interactif
│   ├── list-apps.sh           # Lister toutes les apps
│   ├── start-app.sh           # Démarrer une app
│   ├── stop-app.sh            # Arrêter une app
│   ├── restart-app.sh         # Redémarrer une app
│   ├── logs-app.sh            # Voir les logs
│   ├── status-app.sh          # Status détaillé
│   └── rebuild-app.sh         # Rebuild complet
│
├── maintenance/               # 14 scripts
│   ├── deploy-infrastructure.sh
│   ├── backup.sh
│   ├── restore.sh
│   ├── backup-postgres.sh
│   ├── backup-postgres-auto.sh
│   ├── health-check.sh
│   ├── docker-cleanup.sh
│   ├── cleanup-docker.sh
│   ├── logs.sh
│   ├── stats.sh
│   ├── update.sh
│   ├── maintenance.sh
│   ├── trivy-scan.sh
│   └── setup-swap.sh
│
├── system/                    # 6 scripts
│   ├── system-info.sh
│   ├── disk-usage.sh
│   ├── monitor-live.sh
│   ├── ssl-check.sh
│   ├── firewall-status.sh
│   └── open-ports.sh
│
├── database/                  # 4 scripts
│   ├── db-shell.sh
│   ├── redis-cli.sh
│   ├── db-backup-now.sh
│   └── db-query.sh
│
└── quick/                     # 7 scripts
    ├── full-status.sh
    ├── quick-restart.sh
    ├── emergency-stop.sh
    ├── container-shell.sh
    └── docker-stats-live.sh
```

### Exemple de script (menu.sh)

```bash
#!/bin/bash
# Menu principal avec ASCII art
# Navigation interactive avec couleurs
# Appel des sous-menus par catégorie
```

---

## 📊 Monitoring et observabilité

### Dashboards Grafana

#### 1. System Overview
- CPU usage (user, system, idle)
- Memory usage (used, buffers, cached)
- Disk I/O (read/write bytes)
- Network traffic (in/out)
- Load average (1m, 5m, 15m)

#### 2. Docker Containers
- Container count (running, stopped)
- CPU per container
- Memory per container
- Network I/O per container
- Restart count

#### 3. Infrastructure Health
- Service status (up/down)
- Response times
- Error rates
- Resource saturation

### Alertes configurées

| Alerte | Condition | Sévérité |
|--------|-----------|----------|
| High CPU | > 80% pendant 5min | Warning |
| High Memory | > 90% pendant 5min | Critical |
| Disk Space | < 20% libre | Warning |
| Container Down | Healthcheck failed | Critical |
| SSL Expiring | < 30 jours | Warning |

---

## 🔐 Sécurité implémentée

### Checklist de sécurité

- [x] SSL/TLS sur tous les endpoints (Let's Encrypt)
- [x] HSTS avec preload activé
- [x] Headers de sécurité (CSP, X-Frame-Options, etc.)
- [x] Firewall UFW (ports 22, 80, 443 uniquement)
- [x] Fail2ban pour SSH (3 tentatives max)
- [x] PostgreSQL accessible localhost uniquement
- [x] Redis accessible localhost uniquement
- [x] Secrets via variables d'environnement
- [x] .gitignore strict (pas de secrets committé)
- [x] Resource limits sur tous les containers
- [x] no-new-privileges sur containers sensibles
- [x] Scan de vulnérabilités Trivy
- [x] Backups automatiques PostgreSQL (02:00 daily)
- [x] Logs avec rotation automatique

### Commandes sécurité utiles

```bash
# Scan vulnérabilités
./scripts/maintenance/trivy-scan.sh

# Vérifier SSL
./scripts/system/ssl-check.sh

# Status firewall
./scripts/system/firewall-status.sh

# Ports ouverts
./scripts/system/open-ports.sh
```

---

## 🧩 Défis rencontrés et solutions

### 1. SSL avec sous-chemins (PathPrefix)

**Problème** : Grafana et Uptime Kuma ne fonctionnaient pas sur `/monitoring` et `/uptime`.

**Solution** : 
- Middleware `stripprefix` pour retirer le préfixe
- Configuration `GF_SERVER_SERVE_FROM_SUB_PATH=true` pour Grafana
- Headers personnalisés `X-Forwarded-Prefix`

### 2. Connection pooling PostgreSQL

**Problème** : "too many connections" avec plusieurs apps Next.js.

**Solution** :
- Ajout de pgBouncer en mode transaction
- Apps connectées à pgBouncer (port 6432) au lieu de PostgreSQL direct
- Pool de 25 connexions réutilisables

### 3. Healthchecks qui échouent au démarrage

**Problème** : Containers marqués unhealthy avant d'être prêts.

**Solution** :
- Ajout de `start_period: 30s` sur tous les healthchecks
- Augmentation du `timeout` à 10s
- Utilisation de `depends_on` avec `condition: service_healthy`

### 4. Performances Redis

**Problème** : Redis utilisait trop de mémoire.

**Solution** :
- Configuration `maxmemory 512mb`
- Politique d'éviction `allkeys-lru`
- Désactivation AOF pour usage cache

---

## 🚀 Évolutions futures

### Court terme (1-3 mois)
- [ ] Logs centralisés avec Loki + Promtail
- [ ] CI/CD avec GitHub Actions
- [ ] Backups incrémentaux avec Restic
- [ ] Mise à jour Yggdrasil vers Next.js 16

### Moyen terme (3-6 mois)
- [ ] Kubernetes local (k3s) pour apprendre
- [ ] GitOps avec ArgoCD
- [ ] Secrets management avec Vault
- [ ] CDN CloudFlare complet

### Long terme (6-12 mois)
- [ ] Multi-node avec Docker Swarm
- [ ] Infrastructure Terraform
- [ ] Automatisation Ansible
- [ ] Observability OpenTelemetry

---

## 📞 Contact

- **GitHub** : [zoom26042604](https://github.com/zoom26042604)
- **Portfolio** : [zoom2604.dev](https://zoom2604.dev)

---

*Ce document a été généré le 4 janvier 2026 et reflète l'état actuel de l'infrastructure.*
