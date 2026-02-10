# 📜 Scripts d'installation Kubernetes

Ce dossier contient tous les scripts nécessaires pour installer et configurer votre homelab Kubernetes.

## 🎯 Utilisation

### Installation automatique (recommandé)
```bash
cd /srv/homelab/kubernetes
sudo ./install.sh
```

### Scripts individuels

| Script | Description | Usage |
|--------|-------------|-------|
| `install-k3s.sh` | Installation K3s optimisée | `sudo ./install-k3s.sh` |
| `setup-namespaces.sh` | Création des namespaces | `./setup-namespaces.sh` |
| `create-secrets.sh` | Import des secrets K8s | `./create-secrets.sh` |
| `install-cert-manager.sh` | Installation cert-manager | `./install-cert-manager.sh` |
| `install-monitoring.sh` | Prometheus + Grafana | `./install-monitoring.sh` |
| `install-loki.sh` | Loki pour les logs | `./install-loki.sh` |
| `build-images.sh` | Build Docker images | `./build-images.sh` |
| `import-images-to-k3s.sh` | Import images K3s | `./import-images-to-k3s.sh` |

## 📋 Ordre d'exécution recommandé

1. **install-k3s.sh** - Base K3s
2. **setup-namespaces.sh** - Namespaces
3. **create-secrets.sh** - Secrets
4. **install-cert-manager.sh** - SSL
5. Déployer Traefik et bases de données (manifests)
6. **build-images.sh** - Build apps
7. **import-images-to-k3s.sh** - Import apps
8. Déployer les applications (manifests)
9. **install-monitoring.sh** - Monitoring
10. **install-loki.sh** - Logs

## ⚙️ Configuration

La plupart des scripts utilisent le fichier `.env` dans `../infrastructure/`.

Assurez-vous que ce fichier existe avant d'exécuter `create-secrets.sh`.

## 🔍 Logs et debugging

Tous les scripts affichent des messages informatifs. En cas d'erreur :

```bash
# Vérifier les pods
kubectl get pods -A

# Vérifier les logs
kubectl logs -n namespace pod-name

# Vérifier les événements
kubectl get events -n namespace
```

## 📚 Documentation

- Guide complet : [../MIGRATION_GUIDE.md](../MIGRATION_GUIDE.md)
- Documentation : [../README.md](../README.md)
