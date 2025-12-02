# 🚀 Guide de Déploiement Production

Guide complet pour déployer cette infrastructure de monitoring et base de données sur n'importe quel VPS.

> **Template réutilisable** : Infrastructure seule (sans applications) → Ajoute ensuite tes propres apps !

---

## ✅ Pré-requis

### Serveur
- **RAM** : 8GB minimum (12GB recommandé)
- **Stockage** : 50GB minimum (100GB recommandé)
- **CPU** : 2 cores minimum
- **OS** : Debian 11+ ou Ubuntu 20.04+

### DNS (si tu veux accéder aux dashboards via sous-domaines)
```
ton-domaine.com       → IP_VPS
*.ton-domaine.com     → IP_VPS (wildcard pour grafana.*, prometheus.*, etc.)
```

> **Optionnel** : Tu peux aussi utiliser uniquement l'IP et accéder via ports (ex: http://IP:3000)

### Logiciels
- Docker 24+
- Docker Compose v2
- Git

---

## 📝 Installation Complète

### 1. Préparer le Serveur

```bash
# Mise à jour
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git ufw htop

# Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Installer Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Vérifier
docker --version
docker-compose --version
```

### 2. Configurer le Firewall

```bash
# Reset UFW
sudo ufw --force reset

# Règles par défaut
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Autoriser SSH (port custom recommandé)
sudo ufw allow 22/tcp comment 'SSH'

# Autoriser HTTP/HTTPS
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'

# Activer
sudo ufw --force enable
sudo ufw status verbose
```

### 3. Configurer SSH (Sécurité)

```bash
sudo nano /etc/ssh/sshd_config

# Modifications recommandées :
Port 22
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes

# Redémarrer SSH
sudo systemctl restart sshd
```

### 4. Déployer l'Infrastructure

```bash
# Cloner le template d'infrastructure
cd /srv
git clone https://github.com/ton-user/infrastructure-template .

# Générer automatiquement tous les secrets
cd infrastructure
chmod +x generate-secrets.sh
./generate-secrets.sh

# Personnaliser (domaine, passwords, etc.)
nano .env
# Modifier au minimum: DOMAIN=ton-domaine.com
# Changer DOMAIN=votre-domaine.com

# Configurer SWAP
cd scripts
sudo ./setup-swap.sh

# Configurer log rotation Docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
sudo systemctl restart docker

# Créer acme.json pour SSL
sudo touch /srv/infrastructure/traefik/acme.json
sudo chmod 600 /srv/infrastructure/traefik/acme.json

# Lancer l'infrastructure complète
cd /srv/infrastructure
sudo docker-compose up -d

# Attendre que tout soit prêt (SSL peut prendre 1-2 min)
sleep 90

# Vérifier que tout fonctionne
cd scripts
sudo ./health-check.sh
```

**✅ Infrastructure opérationnelle !** Grafana, Prometheus, PostgreSQL, Redis sont prêts.

### 5. Ajouter Tes Applications (Optionnel)

Maintenant que l'infra est prête, ajoute tes propres applications :

```bash
# Exemple: Application Next.js
mkdir -p /srv/my-apps/my-app
cd /srv/my-apps/my-app

# Créer ton Dockerfile + docker-compose.yml
# (voir README.md section "Ajouter Tes Applications")

# Déployer
docker-compose up -d
```

Tes apps se connectent automatiquement à PostgreSQL, Redis via le réseau `app_network`.

### 6. Vérifier le Déploiement

```bash
# Health check complet
cd /srv/infrastructure/scripts
sudo ./health-check.sh

# Vérifier les containers
sudo docker ps -a

# Vérifier les logs
cd /srv/infrastructure
sudo docker-compose logs traefik | tail -20
sudo docker-compose logs postgres | tail -20

# Tester l'accès aux dashboards
curl -I https://grafana.ton-domaine.com
curl -I https://prometheus.ton-domaine.com
```

---

## ⚙️ Configuration Post-Déploiement

### Automatiser les Backups

```bash
sudo crontab -e

# Ajouter :
0 2 * * * /srv/infrastructure/scripts/backup-postgres.sh >> /var/log/backup-postgres.log 2>&1
0 3 * * * /srv/infrastructure/scripts/docker-cleanup.sh >> /var/log/docker-cleanup.log 2>&1
0 4 * * 0 /srv/infrastructure/scripts/maintenance.sh >> /var/log/maintenance.log 2>&1
```

### Configurer Grafana

1. Accéder : `https://grafana.votre-domaine.com`
2. Login : `admin` / (password dans `.env`)
3. Ajouter datasources :
   - Prometheus : `http://prometheus:9090`
   - PostgreSQL : `postgres:5432`
4. Importer dashboards prédéfinis

---

## 🔧 Optimisations Appliquées

### PostgreSQL (12GB RAM)
```
shared_buffers = 512MB
effective_cache_size = 3GB
maintenance_work_mem = 256MB
work_mem = 2621kB
max_connections = 100
```

### pgBouncer
```
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 25
```

### Redis
```
maxmemory 512mb
maxmemory-policy allkeys-lru
```

### Traefik
- Rate limiting : 100 req/s
- Circuit breaker activé
- HSTS 2 ans
- CSP strict

---

## 🐛 Troubleshooting Production

### Container restart en boucle

```bash
# Voir les logs
sudo docker logs <container> --tail 100

# Vérifier les ressources
free -h
df -h
sudo docker stats

# Redémarrer proprement
cd /srv/infrastructure
sudo docker-compose stop <service>
sudo docker-compose rm -f <service>
sudo docker-compose up -d <service>
```

### SSL ne se génère pas

```bash
# Vérifier permissions acme.json
ls -la /srv/infrastructure/traefik/acme.json
# Doit être: -rw------- (600)

# Fix
sudo chmod 600 /srv/infrastructure/traefik/acme.json

# Supprimer et régénérer
sudo rm /srv/infrastructure/traefik/acme.json
sudo touch /srv/infrastructure/traefik/acme.json
sudo chmod 600 /srv/infrastructure/traefik/acme.json

# Restart Traefik
cd /srv/infrastructure
sudo docker-compose restart traefik

# Suivre les logs
sudo docker logs -f traefik
```

### BDD inaccessible

```bash
# Vérifier PostgreSQL
sudo docker logs postgres | tail -50

# Vérifier pgBouncer
sudo docker logs pgbouncer | tail -50

# Test connexion directe
sudo docker exec -it postgres psql -U postgres -c 'SELECT 1;'

# Test via pgBouncer
sudo docker exec -it postgres psql -h pgbouncer -U postgres -p 6432 -c 'SELECT 1;'

# Restart stack BDD
cd /srv/infrastructure
sudo docker-compose restart postgres pgbouncer
```

### Mémoire saturée

```bash
# Vérifier SWAP
free -h
# Si pas de SWAP, exécuter:
cd /srv/infrastructure/scripts
sudo ./setup-swap.sh

# Identifier les containers gourmands
sudo docker stats --no-stream | sort -k4 -h

# Redémarrer les services
cd /srv/infrastructure
sudo docker-compose restart
```

---

## 📊 Monitoring Production

### Métriques Clés

**Vérifier quotidiennement** :
- CPU < 80%
- RAM < 90%
- Disk < 90%
- Aucune alerte Prometheus

**Vérifier hebdomadairement** :
- Backups créés (7 derniers jours)
- Logs Traefik (pas d'erreurs 5xx massives)
- SSL expire > 30 jours
- Containers tous healthy

### Scripts Monitoring

```bash
# Stats système
cd /srv/infrastructure/scripts
sudo ./stats.sh

# Health check complet
sudo ./health-check.sh

# Voir tous les logs
sudo ./logs.sh
```

---

## �� Procédure de Rollback

Si un déploiement échoue :

```bash
# 1. Arrêter les nouveaux containers
cd /srv/zoom2604.dev
sudo docker-compose stop

# 2. Revenir au commit précédent
git log --oneline  # Trouver le commit
git checkout <commit-hash>

# 3. Rebuild et redéployer
sudo docker-compose build
sudo docker-compose up -d

# 4. Vérifier
cd /srv/infrastructure/scripts
sudo ./health-check.sh
```

---

## 📦 Backup & Restore

### Backup Manuel

```bash
cd /srv/infrastructure/scripts
sudo ./backup-postgres.sh

# Fichier créé dans :
/srv/infrastructure/backups/postgresql_YYYYMMDD_HHMMSS.sql.gz
```

### Restore

```bash
# 1. Arrêter les apps
cd /srv/zoom2604.dev
sudo docker-compose stop

# 2. Restore
cd /srv/infrastructure/scripts
sudo ./restore.sh /srv/infrastructure/backups/postgresql_<date>.sql.gz

# 3. Redémarrer
cd /srv/zoom2604.dev
sudo docker-compose start
```

---

## 🚀 Mise à Jour

```bash
# Mettre à jour le code
cd /srv
git pull

# Rebuilder les images
cd /srv/infrastructure
sudo docker-compose build --pull
sudo docker-compose up -d

cd /srv/zoom2604.dev
sudo docker-compose build --pull
sudo docker-compose up -d

# Vérifier
cd /srv/infrastructure/scripts
sudo ./health-check.sh
```

---

**Dernière MAJ** : 2025-12-02
