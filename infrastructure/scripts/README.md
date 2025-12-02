# 🔧 Scripts Infrastructure

Collection de 37 scripts pour gérer l'infrastructure et déployer des applications.

## 📁 Organisation

```
scripts/
├── menu.sh                    # 🎯 Menu principal interactif
├── deploy/          (6)       # 🚀 Déploiement d'applications
├── apps/            (8)       # 📱 Gestion des apps déployées
├── maintenance/     (5)       # 🛠️ Maintenance infrastructure
├── system/          (6)       # 🖥️ Monitoring système
├── database/        (4)       # 🗄️ Accès bases de données
└── quick/           (7)       # ⚡ Actions rapides
```

## 🚀 Quick Start

### Menu Principal
```bash
cd /srv/infrastructure/scripts
./menu.sh
```

## 📋 Scripts par Catégorie

### 🚀 Déploiement (deploy/)
- `deploy.sh` - Menu de déploiement
- `deploy-nextjs.sh` - Déployer Next.js
- `deploy-react.sh` - Déployer React/Vite
- `deploy-angular.sh` - Déployer Angular
- `deploy-node.sh` - Déployer Node.js/Express
- `deploy-static.sh` - Déployer site statique

### 📱 Gestion Apps (apps/)
- `app-manager.sh` - Menu interactif complet
- `list-apps.sh` - Lister toutes les apps
- `start-app.sh` - Démarrer une app
- `stop-app.sh` - Arrêter une app
- `restart-app.sh` - Redémarrer une app
- `logs-app.sh` - Voir les logs
- `status-app.sh` - Status d'une app
- `rebuild-app.sh` - Rebuild une app

### 🛠️ Maintenance (maintenance/)
- `deploy-infrastructure.sh` - Déployer l'infrastructure
- `backup.sh` - Backup complet
- `restore.sh` - Restaurer un backup
- `logs.sh` - Consulter les logs
- `stats.sh` - Statistiques système

### 🖥️ System (system/)
- `system-info.sh` - Info complète du serveur
- `disk-usage.sh` - Analyse espace disque
- `monitor-live.sh` - Monitoring temps réel
- `ssl-check.sh` - Vérification certificats SSL
- `firewall-status.sh` - Status firewall
- `open-ports.sh` - Ports ouverts

### 🗄️ Database (database/)
- `db-shell.sh` - Shell PostgreSQL
- `redis-cli.sh` - CLI Redis
- `db-backup-now.sh` - Backup immédiat
- `db-query.sh` - Exécuter requête SQL

### ⚡ Quick Actions (quick/)
- `full-status.sh` - Status complet rapide
- `quick-restart.sh` - Restart rapide infra
- `emergency-stop.sh` - Arrêt d'urgence
- `url-test.sh` - Tester une URL
- `docker-stats-live.sh` - Stats Docker live
- `container-shell.sh` - Shell conteneur
- `docker-prune-all.sh` - Nettoyage Docker

## 💡 Exemples

### Déployer une app Next.js
```bash
cd deploy/
./deploy-nextjs.sh
```

### Voir toutes les apps
```bash
cd apps/
./list-apps.sh
```

### Status rapide du serveur
```bash
cd quick/
./full-status.sh
```

### Backup de l'infrastructure
```bash
cd maintenance/
./backup.sh
```

## 📚 Documentation

Voir le README principal : `/srv/infrastructure/README.md`
