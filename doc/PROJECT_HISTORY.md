# 📖 Project History - zoom2604.dev Infrastructure

> Documentation complète du projet depuis l'installation initiale jusqu'à aujourd'hui.  
> Dernière mise à jour : 4 janvier 2026

---

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Installation initiale du serveur](#installation-initiale-du-serveur)
3. [Configuration Docker](#configuration-docker)
4. [Services déployés](#services-déployés)
5. [Configuration réseau et sécurité](#configuration-réseau-et-sécurité)
6. [Applications développées](#applications-développées)
7. [Historique des modifications](#historique-des-modifications)
8. [Commandes de référence](#commandes-de-référence)

---

## Vue d'ensemble

### Informations serveur

| Propriété | Valeur |
|-----------|--------|
| **Provider** | OVH VPS |
| **IP Publique** | 51.91.76.23 |
| **OS** | Debian 13 (Trixie) |
| **Kernel** | Linux 6.x |
| **CPU** | 6 vCPUs |
| **RAM** | 12 GB |
| **Stockage** | 99 GB SSD |
| **Domaines** | zoom2604.dev, nathan-ferre.fr |

### Architecture globale

```
┌─────────────────────────────────────────────────────────────────┐
│                        INTERNET                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │   Cloudflare      │
                    │   DNS + Proxy     │
                    └─────────┬─────────┘
                              │
                    ┌─────────┴─────────┐
                    │   UFW Firewall    │
                    │  80,443,22,51820  │
                    └─────────┬─────────┘
                              │
┌─────────────────────────────┴─────────────────────────────────┐
│                     TRAEFIK v3.1                               │
│              Reverse Proxy + SSL Let's Encrypt                 │
└─────────────────────────────┬─────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
   ┌────┴────┐          ┌─────┴─────┐         ┌────┴────┐
   │ Apps    │          │ Monitoring │         │ Infra   │
   ├─────────┤          ├───────────┤         ├─────────┤
   │ Homer   │          │ Grafana   │         │Portainer│
   │ Azrael  │          │ Uptime K. │         │ Traefik │
   │ Admin   │          │ Prometheus│         │ cAdvisor│
   │Portfolio│          │Node Export│         │         │
   └────┬────┘          └─────┬─────┘         └────┬────┘
        │                     │                     │
        └─────────────────────┴─────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │   DATA LAYER      │
                    ├───────────────────┤
                    │ PostgreSQL 16     │
                    │ Redis 7           │
                    │ pgBouncer         │
                    └───────────────────┘
```

---

## Installation initiale du serveur

### 1. Première connexion et mise à jour

```bash
# Connexion SSH initiale
ssh root@51.91.76.23

# Mise à jour du système
apt update && apt upgrade -y

# Installation des paquets essentiels
apt install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    unzip \
    ca-certificates \
    gnupg \
    lsb-release \
    ufw \
    fail2ban \
    sudo
```

### 2. Création de l'utilisateur

```bash
# Créer l'utilisateur principal
adduser zoom
usermod -aG sudo zoom

# Configurer sudoers pour éviter mot de passe
echo "zoom ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/zoom
```

### 3. Configuration SSH sécurisée

```bash
# Éditer /etc/ssh/sshd_config
Port 46622
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AllowUsers zoom

# Redémarrer SSH
systemctl restart sshd
```

### 4. Configuration du firewall

```bash
# Configuration UFW
ufw default deny incoming
ufw default allow outgoing
ufw allow 46622/tcp comment 'SSH'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw allow 51820/udp comment 'WireGuard VPN'
ufw enable
```

### 5. Configuration Fail2ban

```bash
# /etc/fail2ban/jail.local
[sshd]
enabled = true
port = 46622
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
```

---

## Configuration Docker

### Installation Docker

```bash
# Installer Docker
curl -fsSL https://get.docker.com | sh

# Ajouter l'utilisateur au groupe docker
usermod -aG docker zoom

# Installer Docker Compose v2
apt install docker-compose-plugin

# Vérification
docker --version
docker compose version
```

### Création du réseau Docker

```bash
# Créer le réseau partagé
docker network create zoom2604_network
```

### Structure des volumes

```bash
# Volumes Docker créés
docker volume create traefik_acme
docker volume create postgres_data
docker volume create redis_data
docker volume create prometheus_data
docker volume create grafana_data
docker volume create uptime_kuma_data
docker volume create portainer_data
```

---

## Services déployés

### Liste des containers

| Container | Image | Port interne | Accès externe |
|-----------|-------|--------------|---------------|
| traefik | traefik:v3.1 | 80, 443 | Ports publics |
| postgres | postgres:16-alpine | 5432 | localhost:5432 |
| redis | redis:7-alpine | 6379 | localhost:6379 |
| pgbouncer | edoburu/pgbouncer | 5432 | localhost:6432 |
| prometheus | prom/prometheus:v2.53 | 9090 | localhost:9090 |
| grafana | grafana/grafana:11.0 | 3000 | /monitoring/ |
| uptime-kuma | louislam/uptime-kuma:1 | 3001 | uptime.zoom2604.dev |
| homer | b4bz/homer:latest | 8080 | zoom2604.dev |
| portainer | portainer/portainer-ce | 9000 | portainer.zoom2604.dev |
| node_exporter | prom/node-exporter | 9100 | localhost:9100 |
| cadvisor | gcr.io/cadvisor | 8080 | localhost:8080 |
| azrael | nathan-ferre-portfolio | 3000 | nathan-ferre.fr |

### Routes Traefik configurées

| Service | Route | Type |
|---------|-------|------|
| Homer | `Host(\`zoom2604.dev\`)` | Root |
| Grafana | `Host(\`zoom2604.dev\`) && PathPrefix(\`/monitoring\`)` | Sub-path |
| Uptime Kuma | `Host(\`uptime.zoom2604.dev\`)` | Subdomain |
| Portainer | `Host(\`portainer.zoom2604.dev\`)` | Subdomain |
| Traefik | `Host(\`traefik.zoom2604.dev\`)` | Subdomain |
| Azrael | `Host(\`nathan-ferre.fr\`)` | Domain |

### Certificats SSL (Let's Encrypt)

- zoom2604.dev ✅
- uptime.zoom2604.dev ✅
- portainer.zoom2604.dev ✅
- traefik.zoom2604.dev ✅
- grafana.zoom2604.dev ✅
- prometheus.zoom2604.dev ✅
- nathan-ferre.fr ✅

---

## Configuration réseau et sécurité

### WireGuard VPN

Installation et configuration du VPN WireGuard pour accès sécurisé :

```bash
# Installation
apt install wireguard

# Génération des clés
wg genkey | tee /etc/wireguard/private.key | wg pubkey > /etc/wireguard/public.key
chmod 600 /etc/wireguard/private.key

# Activation IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
```

Configuration serveur (`/etc/wireguard/wg0.conf`) :
```ini
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <SERVER_PRIVATE_KEY>
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ens3 -j MASQUERADE

[Peer]
# Client zoom
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIPs = 10.0.0.2/32
```

```bash
# Démarrer WireGuard
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0
```

### Ports ouverts

| Port | Protocol | Service |
|------|----------|---------|
| 46622 | TCP | SSH (custom) |
| 80 | TCP | HTTP |
| 443 | TCP | HTTPS |
| 51820 | UDP | WireGuard VPN |

### Ports internes (localhost only)

| Port | Service |
|------|---------|
| 5432 | PostgreSQL |
| 6379 | Redis |
| 6432 | pgBouncer |
| 9090 | Prometheus |
| 9100 | Node Exporter |
| 8080 | cAdvisor |

---

## Applications développées

### 1. Azrael (nathan-ferre.fr)

Portfolio Next.js pour Nathan Ferré.

**Stack technique :**
- Next.js 16 (App Router)
- TypeScript
- Tailwind CSS
- Catppuccin theme

**Déploiement :**
```bash
cd /srv/nathan-ferre.fr/azrael
docker build -t nathan-ferre-portfolio .
docker-compose up -d azrael
```

### 2. Admin Panel (zoom2604.dev/admin)

Dashboard d'administration avec authentification.

**Stack technique :**
- Next.js 16
- NextAuth.js
- Prisma ORM
- PostgreSQL

### 3. Homer Dashboard

Dashboard centralisé pour tous les services.

**Configuration :** `/srv/fullstack-server/infrastructure/homer/config.yml`

**Thème :** Dark mode minimal avec CSS personnalisé.

---

## Historique des modifications

### Décembre 2025

- **11 déc.** : Migration et restructuration du projet
- **02 déc.** : Mise en place initiale de l'infrastructure

### Janvier 2026

- **04 jan.** : Modernisation complète
  - Installation WireGuard VPN
  - Refactoring des scripts (style moderne CLI)
  - Suppression de Yggdrasil
  - Fix Grafana routing (suppression stripprefix)
  - Uptime Kuma en subdomain
  - Homer dashboard modernisé (dark theme)
  - Fix erreur Prometheus (traefik.enable=false)
  - Commit Azrael sur branch dev

---

## Commandes de référence

### Gestion Docker

```bash
# Voir tous les containers
sudo docker ps -a

# Logs d'un container
sudo docker logs -f <container>

# Redémarrer un service
sudo docker-compose restart <service>

# Rebuild et restart
sudo docker-compose up -d --build <service>

# Stats en temps réel
sudo docker stats
```

### Scripts d'administration

```bash
# Menu principal
/srv/fullstack-server/infrastructure/scripts/menu.sh

# Status rapide
/srv/fullstack-server/infrastructure/scripts/quick/full-status.sh

# Backup database
/srv/fullstack-server/infrastructure/scripts/database/db-backup-now.sh

# Health check
/srv/fullstack-server/infrastructure/scripts/maintenance/health-check.sh
```

### Gestion SSL

```bash
# Voir les certificats
sudo docker exec traefik cat /acme/acme.json | python3 -c "import sys,json; d=json.load(sys.stdin); [print(c['domain']['main']) for c in d['letsencrypt']['Certificates']]"

# Forcer renouvellement (redémarrer Traefik)
sudo docker-compose restart traefik
```

### Base de données

```bash
# Connexion PostgreSQL
sudo docker exec -it postgres psql -U postgres

# Backup manuel
sudo docker exec postgres pg_dump -U postgres admin_db > backup.sql

# Redis CLI
sudo docker exec -it redis redis-cli -a <password>
```

### WireGuard

```bash
# Status VPN
sudo wg show

# Ajouter un client
sudo wg set wg0 peer <PUBLIC_KEY> allowed-ips 10.0.0.X/32

# Redémarrer
sudo systemctl restart wg-quick@wg0
```

---

## Structure des fichiers

```
/srv/
├── fullstack-server/           # Infrastructure principale
│   ├── infrastructure/
│   │   ├── docker-compose.yml  # Orchestration
│   │   ├── .env                # Variables (non-committé)
│   │   ├── traefik/            # Config reverse proxy
│   │   ├── prometheus/         # Config monitoring
│   │   ├── grafana/            # Dashboards
│   │   ├── homer/              # Dashboard homepage
│   │   ├── postgres/           # Config BDD
│   │   ├── redis/              # Config cache
│   │   ├── pgbouncer/          # Connection pooling
│   │   └── scripts/            # Scripts admin
│   └── doc/                    # Documentation
│
├── zoom2604.dev/               # Applications principales
│   ├── admin/                  # Panel admin Next.js
│   └── portfolio/              # Portfolio principal
│
└── nathan-ferre.fr/            # Domaine secondaire
    └── azrael/                 # Portfolio Nathan
```

---

## Contacts et ressources

- **GitHub** : github.com/zoom26042604
- **Repository** : fullstack-server, azrael
- **Monitoring** : https://zoom2604.dev/monitoring/
- **Status** : https://uptime.zoom2604.dev

---

*Documentation générée le 4 janvier 2026*
