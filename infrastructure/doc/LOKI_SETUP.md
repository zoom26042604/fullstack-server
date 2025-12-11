# Configuration Loki pour Logs Centralisés

Guide d'installation et configuration de la stack Loki pour centraliser les logs.

## Architecture

```
Applications → Promtail → Loki → Grafana
```

- **Loki**: Serveur de stockage des logs
- **Promtail**: Agent de collecte des logs
- **Grafana**: Interface de visualisation (déjà installé)

## Installation

### 1. Ajouter à docker-compose.yml

```yaml
  # ================================
  # LOKI - Log Aggregation
  # ================================
  loki:
    image: grafana/loki:latest
    container_name: loki
    restart: unless-stopped
    networks:
      - app_network
    ports:
      - "3100:3100"
    volumes:
      - ./loki/loki-config.yml:/etc/loki/local-config.yaml:ro
      - loki_data:/loki
    command: -config.file=/etc/loki/local-config.yaml
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.1'
          memory: 128M

  # ================================
  # PROMTAIL - Log Collector
  # ================================
  promtail:
    image: grafana/promtail:latest
    container_name: promtail
    restart: unless-stopped
    networks:
      - app_network
    volumes:
      - /var/log:/var/log:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - ./loki/promtail-config.yml:/etc/promtail/config.yml:ro
    command: -config.file=/etc/promtail/config.yml
    depends_on:
      - loki

volumes:
  loki_data:
    name: loki_data
```

### 2. Configuration Loki

Créer `/srv/fullstack-server/infrastructure/loki/loki-config.yml` :

```yaml
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_retain_period: 30s

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 168h

storage_config:
  boltdb:
    directory: /loki/index
  filesystem:
    directory: /loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
  ingestion_rate_mb: 10
  ingestion_burst_size_mb: 20

chunk_store_config:
  max_look_back_period: 0s

table_manager:
  retention_deletes_enabled: true
  retention_period: 168h
```

### 3. Configuration Promtail

Créer `/srv/fullstack-server/infrastructure/loki/promtail-config.yml` :

```yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  # Docker containers logs
  - job_name: docker
    static_configs:
      - targets:
          - localhost
        labels:
          job: docker
          __path__: /var/lib/docker/containers/*/*-json.log
    pipeline_stages:
      - json:
          expressions:
            output: log
            stream: stream
            attrs:
      - labels:
          stream:
      - output:
          source: output

  # System logs
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: system
          __path__: /var/log/*.log

  # Nginx/Traefik logs
  - job_name: traefik
    static_configs:
      - targets:
          - localhost
        labels:
          job: traefik
          __path__: /var/log/traefik/*.log
```

### 4. Déploiement

```bash
cd /srv/fullstack-server/infrastructure
mkdir -p loki
# Créer les fichiers de configuration ci-dessus
sudo docker compose up -d loki promtail
```

### 5. Configuration Grafana

1. Accéder à Grafana: `https://zoom2604.dev/monitoring`
2. Configuration > Data Sources > Add data source
3. Sélectionner "Loki"
4. URL: `http://loki:3100`
5. Save & Test

### 6. Dashboards recommandés

Importer les dashboards Grafana :

- **Loki Dashboard**: ID 13639
- **Docker Logs**: ID 12019
- **Promtail**: ID 10880

## Utilisation

### Requêtes LogQL de base

```logql
# Tous les logs d'un container
{container_name="traefik"}

# Logs avec erreurs
{job="docker"} |= "error"

# Logs HTTP 5xx
{job="docker"} |= "status=5"

# Rate des erreurs
rate({job="docker"} |= "error" [5m])

# Top 10 erreurs
topk(10, sum by (container_name) (rate({job="docker"} |= "error" [1h])))
```

### Alertes recommandées

```yaml
# Alert sur taux d'erreur élevé
- alert: HighErrorRate
  expr: |
    rate({job="docker"} |= "error" [5m]) > 10
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High error rate detected"
    description: "Error rate is {{ $value }} errors/sec"
```

## Avantages

- **Centralisé**: Tous les logs au même endroit
- **Performance**: Optimisé pour grands volumes
- **Grafana intégré**: UI familière
- **Labels**: Recherche puissante
- **Rétention**: Configurable (7 jours par défaut)
- **Faible coût**: Moins gourmand que ELK

## Maintenance

### Nettoyage des logs anciens

```bash
# Loki nettoie automatiquement selon retention_period
# Vérifier l'espace disque
sudo docker exec loki du -sh /loki
```

### Monitoring Loki

```promql
# Métriques Loki disponibles dans Prometheus
loki_ingester_streams
loki_ingester_chunks_stored_total
loki_distributor_bytes_received_total
```

## Troubleshooting

### Promtail ne collecte pas les logs

```bash
# Vérifier les permissions
sudo docker exec promtail ls -la /var/log

# Vérifier les positions
sudo docker exec promtail cat /tmp/positions.yaml

# Logs Promtail
sudo docker logs promtail
```

### Loki lent

- Augmenter les ressources (CPU/RAM)
- Optimiser `ingestion_rate_mb`
- Réduire `retention_period`
- Utiliser S3 pour storage (production)

## Production optimizations

Pour production intensive :

```yaml
storage_config:
  aws:
    s3: s3://region/bucket
    dynamodb:
      dynamodb_url: dynamodb://region
```
