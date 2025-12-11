# Grafana Alerting Configuration

Cette configuration définit les alertes Grafana pour surveiller l'infrastructure.

## Alertes configurées

### 1. High CPU Usage
- **Seuil**: CPU > 80% pendant 5 minutes
- **Gravité**: Warning
- **Action**: Email notification

### 2. High Memory Usage
- **Seuil**: Memory > 90% pendant 5 minutes
- **Gravité**: Critical
- **Action**: Email notification

### 3. Container Down
- **Seuil**: Container stopped
- **Gravité**: Critical
- **Action**: Email + SMS

### 4. Disk Space Low
- **Seuil**: < 10% free space
- **Gravité**: Warning
- **Action**: Email notification

### 5. High HTTP Error Rate
- **Seuil**: >5% 5xx errors pendant 5 minutes
- **Gravité**: Warning
- **Action**: Email notification

## Configuration

Les alertes doivent être configurées manuellement dans l'interface Grafana :

1. Accéder à Grafana: https://zoom2604.dev/monitoring
2. Aller dans Alerting > Alert rules
3. Créer des règles basées sur les datasources:
   - **Prometheus** pour les métriques système
   - **cAdvisor** pour les conteneurs Docker

## Notification Channels

Configurer les canaux de notification dans Alerting > Contact points :

```yaml
Email:
  Type: email
  Addresses: admin@zoom2604.dev
  
Slack (optionnel):
  Type: slack
  Webhook URL: [À configurer]
  
Webhook (optionnel):
  Type: webhook
  URL: [À configurer]
```

## Exemple de Query pour Alert

### CPU Alert Query
```promql
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
```

### Memory Alert Query
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90
```

### Container Down Query
```promql
absent(container_last_seen{name=~".+"}) == 1
```

## Auto-configuration (Future)

Pour automatiser la configuration des alertes, créer un fichier de provisioning:
`/srv/fullstack-server/infrastructure/grafana/provisioning/alerting/alerts.yml`
