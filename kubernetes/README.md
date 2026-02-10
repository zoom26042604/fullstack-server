# 🏠 Kubernetes Homelab Infrastructure

Infrastructure complète Kubernetes (K3s) pour homelab sur VPS OVH (12GB RAM / 100GB disk).

## 📁 Structure

```
kubernetes/
├── base/                          # Resources de base
│   └── namespaces.yaml           # Définition des namespaces
├── infrastructure/                # Services d'infrastructure
│   ├── postgres.yaml             # Base de données PostgreSQL
│   ├── redis.yaml                # Cache Redis
│   ├── traefik.yaml              # Reverse proxy & Ingress
│   └── cert-manager-issuer.yaml  # SSL certificates issuer
├── apps/                          # Applications
│   ├── portfolio-azrael.yaml     # Portfolio (nathan-ferre.fr)
│   ├── cv.yaml                   # CV (cv.nathan-ferre.fr)
│   ├── game-2048.yaml            # Game 2048 (2048.zoom2604.dev)
│   └── admin-panel.yaml          # Admin panel (admin.zoom2604.dev)
├── monitoring/                    # Stack de monitoring
│   └── (installé via Helm)
├── install-k3s.sh                # Installation K3s
├── setup-namespaces.sh           # Création namespaces
├── create-secrets.sh             # Création secrets K8s
├── install-cert-manager.sh       # Installation cert-manager
├── install-monitoring.sh         # Installation Prometheus/Grafana
├── install-loki.sh               # Installation Loki
├── build-images.sh               # Build Docker images
├── import-images-to-k3s.sh       # Import images dans K3s
└── MIGRATION_GUIDE.md            # Guide de migration complet
```

## 🚀 Quick Start

### 1. Installer K3s

```bash
cd /srv/homelab/kubernetes
sudo ./install-k3s.sh
```

### 2. Créer les namespaces et secrets

```bash
./setup-namespaces.sh
./create-secrets.sh
```

### 3. Installer l'infrastructure de base

```bash
# cert-manager pour SSL
./install-cert-manager.sh
kubectl apply -f infrastructure/cert-manager-issuer.yaml

# Traefik Ingress Controller
kubectl apply -f infrastructure/traefik.yaml

# Configurer iptables pour redirection ports
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 30080
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 30443
sudo netfilter-persistent save
```

### 4. Déployer les bases de données

```bash
kubectl apply -f infrastructure/postgres.yaml
kubectl apply -f infrastructure/redis.yaml
```

### 5. Builder et déployer les applications

```bash
./build-images.sh
./import-images-to-k3s.sh

kubectl apply -f apps/portfolio-azrael.yaml
kubectl apply -f apps/cv.yaml
kubectl apply -f apps/game-2048.yaml
kubectl apply -f apps/admin-panel.yaml
```

### 6. Installer le monitoring

```bash
./install-monitoring.sh
./install-loki.sh
```

## 🌐 Services déployés

| Service | URL | Namespace |
|---------|-----|-----------|
| Portfolio | https://nathan-ferre.fr | nathan-ferre |
| CV | https://cv.nathan-ferre.fr | nathan-ferre |
| Game 2048 | https://2048.zoom2604.dev | zoom2604 |
| Admin Panel | https://admin.zoom2604.dev | zoom2604 |
| Grafana | https://grafana.zoom2604.dev | monitoring |
| Traefik Dashboard | https://traefik.zoom2604.dev | infrastructure |

## 📊 Monitoring

### Grafana

Accès : https://grafana.zoom2604.dev

```bash
# Récupérer le mot de passe
kubectl get secret grafana-credentials -n monitoring -o jsonpath='{.data.admin-password}' | base64 -d
```

### Prometheus

```bash
# Port-forward pour accès local
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
```

### Loki (Logs)

Intégré dans Grafana :
- Data Source: `http://loki:3100`
- Query: `{namespace="nathan-ferre"}`

## 🔧 Commandes utiles

### État du cluster

```bash
# Voir tous les pods
kubectl get pods -A

# Ressources
kubectl top nodes
kubectl top pods -A

# Services
kubectl get svc -A

# Ingress
kubectl get ingress -A

# Certificats SSL
kubectl get certificates -A
```

### Logs

```bash
# Logs d'une application
kubectl logs -n nathan-ferre deployment/portfolio-azrael

# Logs en temps réel
kubectl logs -f -n zoom2604 deployment/game-2048

# Logs d'un pod spécifique
kubectl logs -n infrastructure pod-name
```

### Debugging

```bash
# Décrire un pod
kubectl describe pod -n namespace pod-name

# Événements
kubectl get events -n namespace

# Shell dans un pod
kubectl exec -it -n namespace pod-name -- /bin/sh

# Port-forward
kubectl port-forward -n namespace svc/service-name 8080:80
```

### Gestion des déploiements

```bash
# Redémarrer un déploiement
kubectl rollout restart deployment/name -n namespace

# Historique
kubectl rollout history deployment/name -n namespace

# Rollback
kubectl rollout undo deployment/name -n namespace

# Scaler
kubectl scale deployment/name --replicas=2 -n namespace
```

## 🔄 Mises à jour

### Mettre à jour une application

```bash
# 1. Rebuild l'image
cd /srv/nathan-ferre.fr/azrael
docker build -t portfolio-azrael:latest .

# 2. Import dans K3s
docker save portfolio-azrael:latest -o /tmp/portfolio.tar
sudo k3s ctr images import /tmp/portfolio.tar

# 3. Restart
kubectl rollout restart deployment/portfolio-azrael -n nathan-ferre
```

### Mettre à jour K3s

```bash
# Vérifier la version actuelle
k3s --version

# Mise à jour
curl -sfL https://get.k3s.io | sh -
```

## 💾 Backups

### PostgreSQL

```bash
# Backup
kubectl exec -n infrastructure postgres-0 -- pg_dumpall -U postgres > backup_$(date +%Y%m%d).sql

# Restore
kubectl cp backup.sql infrastructure/postgres-0:/tmp/
kubectl exec -n infrastructure postgres-0 -- psql -U postgres -f /tmp/backup.sql
```

### Volumes persistants

```bash
# Lister les PVC
kubectl get pvc -A

# Backup d'un volume (exemple)
kubectl exec -n namespace pod-name -- tar czf - /data > backup.tar.gz
```

## 🚨 Troubleshooting

### Pod en CrashLoopBackOff

```bash
kubectl describe pod -n namespace pod-name
kubectl logs -n namespace pod-name --previous
```

### Certificat SSL non émis

```bash
kubectl describe certificate -n namespace cert-name
kubectl get challenges -A
kubectl logs -n cert-manager deployment/cert-manager
```

### Application non accessible

```bash
# Vérifier ingress
kubectl describe ingress -n namespace ingress-name

# Vérifier Traefik
kubectl logs -n infrastructure deployment/traefik
```

## 📚 Documentation

- **Guide de migration complet** : [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)
- [K3s Documentation](https://docs.k3s.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 🎯 Architecture

```
Internet
    ↓
VPS (51.xx.xx.xx)
    ↓
iptables (80→30080, 443→30443)
    ↓
Traefik Ingress (NodePort)
    ├── nathan-ferre.fr → Portfolio
    ├── cv.nathan-ferre.fr → CV
    ├── 2048.zoom2604.dev → Game 2048
    ├── admin.zoom2604.dev → Admin
    └── grafana.zoom2604.dev → Grafana
    
Infrastructure Services:
    ├── PostgreSQL (StatefulSet)
    ├── Redis (StatefulSet)
    └── cert-manager (SSL/TLS)

Monitoring:
    ├── Prometheus
    ├── Grafana
    ├── Loki
    └── Promtail
```

## 💡 Best Practices

1. **Toujours faire des backups** avant toute modification
2. **Tester en staging** avec letsencrypt-staging
3. **Limiter les ressources** pour éviter OOM
4. **Surveiller les logs** régulièrement
5. **Utiliser des secrets K8s** pour les données sensibles

## 🔐 Sécurité

- Tous les services exposés utilisent HTTPS (Let's Encrypt)
- Authentification sur Grafana et Traefik Dashboard
- Secrets Kubernetes pour les credentials
- Network policies (à implémenter)
- Resource limits sur tous les pods

## 📊 Ressources utilisées

| Component | RAM | CPU | Storage |
|-----------|-----|-----|---------|
| K3s | ~800MB | 0.5 | 5GB |
| PostgreSQL | ~1GB | 0.5 | 20GB |
| Redis | ~256MB | 0.2 | 5GB |
| Traefik | ~150MB | 0.2 | 1GB |
| Applications (x4) | ~1.6GB | 1.0 | 5GB |
| Monitoring | ~2.5GB | 1.5 | 40GB |
| **TOTAL** | ~6.3GB / 12GB | ~4 / 6 | ~76GB / 100GB |

✅ Marge confortable pour croissance !
