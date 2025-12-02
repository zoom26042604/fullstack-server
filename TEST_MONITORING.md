# 🧪 TESTER LE MONITORING

## ✅ Vérifier que tout fonctionne

### 1. Vérifier les services

```bash
cd /srv/infrastructure
sudo docker-compose ps
```

Tous les services doivent être **Up** :
- traefik
- postgres
- pgbouncer
- redis
- prometheus
- grafana
- node_exporter
- cadvisor

### 2. Tester Prometheus

```bash
# Via curl
curl -s http://localhost:9090/-/healthy
# Doit retourner: Prometheus is Healthy.

# Vérifier les targets
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'
```

**Tous les targets doivent être "up"** :
- prometheus
- node_exporter
- cadvisor
- traefik

### 3. Tester Grafana

```bash
# Health check
curl -s http://localhost:3000/api/health | jq

# Lister les datasources
curl -s -u admin:${GRAFANA_ADMIN_PASSWORD} http://localhost:3000/api/datasources | jq

# Lister les dashboards
curl -s -u admin:${GRAFANA_ADMIN_PASSWORD} http://localhost:3000/api/search?type=dash-db | jq
```

**Doit afficher 3 dashboards** :
- System Overview - Performance
- Docker Containers - Monitoring
- Infrastructure Health - Overview

### 4. Accès Web

```bash
# Ouvrir dans le navigateur
https://grafana.ton-domaine.com

Login: admin
Password: (voir dans .env)
```

**Navigation** :
1. Menu → Dashboards
2. Tu verras 3 dashboards prêts à l'emploi
3. Clique sur "System Overview - Performance"
4. Tu dois voir les graphiques se remplir avec les données !

### 5. Exemples de requêtes Prometheus

```bash
# Depuis le terminal
# CPU Usage
curl -s "http://localhost:9090/api/v1/query?query=100-(avg(irate(node_cpu_seconds_total{mode=\"idle\"}[5m]))*100)" | jq '.data.result[0].value'

# Memory Usage
curl -s "http://localhost:9090/api/v1/query?query=(1-(node_memory_MemAvailable_bytes/node_memory_MemTotal_bytes))*100" | jq '.data.result[0].value'

# Containers running
curl -s "http://localhost:9090/api/v1/query?query=count(container_last_seen)" | jq '.data.result[0].value'
```

### 6. Vérifier les métriques collectées

```bash
# Nombre de métriques
curl -s http://localhost:9090/api/v1/label/__name__/values | jq '.data | length'

# Doit afficher plusieurs centaines de métriques
```

## 📊 Dashboards Disponibles

### Dashboard 1: System Overview
**URL**: https://grafana.ton-domaine.com/d/system-overview

**Contient** :
- CPU Usage (gauge + timeline)
- Memory Usage (gauge + timeline)
- Disk Usage (gauge)
- System Load (1m, 5m, 15m)
- Network Traffic (RX/TX)
- Disk I/O (read/write)

### Dashboard 2: Docker Containers
**URL**: https://grafana.ton-domaine.com/d/docker-containers

**Contient** :
- CPU par container
- Memory par container
- Network par container
- Disk I/O par container
- Liste des containers actifs

### Dashboard 3: Infrastructure Health
**URL**: https://grafana.ton-domaine.com/d/infrastructure-health

**Contient** :
- Status de chaque service
- Services UP/DOWN
- Prometheus time series
- Storage size
- HTTP requests

## 🔍 Debugging

### Prometheus ne collecte pas les métriques

```bash
# Vérifier les targets
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health, error: .lastError}'

# Vérifier la config
sudo docker exec prometheus cat /etc/prometheus/prometheus.yml
```

### Grafana n'affiche pas les dashboards

```bash
# Vérifier les fichiers
sudo docker exec grafana ls -la /etc/grafana/provisioning/dashboards/

# Vérifier les logs
sudo docker-compose logs grafana | grep -i dashboard

# Redémarrer Grafana
sudo docker-compose restart grafana
```

### Les graphiques sont vides

**Attendre 1-2 minutes** : Prometheus collecte les données toutes les 15 secondes.

```bash
# Vérifier qu'on a des données
curl -s "http://localhost:9090/api/v1/query?query=up" | jq
```

## ✅ Tests Complets

```bash
# Script de test complet
cd /srv/infrastructure/scripts
sudo ./health-check.sh

# Devrait afficher:
# ✅ Traefik: Up
# ✅ Postgres: Up
# ✅ Redis: Up
# ✅ Prometheus: Up
# ✅ Grafana: Up
# ✅ Node Exporter: Up
# ✅ cAdvisor: Up
```

## 🎉 Si tout fonctionne

Tu devrais avoir :
- ✅ 8 containers UP
- ✅ 4 targets Prometheus UP
- ✅ 3 dashboards Grafana visibles
- ✅ Graphiques qui se remplissent automatiquement
- ✅ Métriques système en temps réel
