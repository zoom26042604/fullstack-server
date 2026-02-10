# 🚀 Migration vers Kubernetes (K3s) - Guide Complet

Ce guide détaille la migration complète de votre infrastructure Docker Compose vers Kubernetes K3s.

## 📋 Prérequis

- VPS OVH avec 12GB RAM / 100GB disque
- Ubuntu/Debian avec Docker installé
- Accès root (sudo)
- Domaines configurés : nathan-ferre.fr, zoom2604.dev

## ⏱️ Temps estimé : 30 minutes à 2 heures

---

## 🚀 Option A : Installation automatique (RECOMMANDÉ)

La méthode la plus simple et rapide :

```bash
cd /srv/homelab/kubernetes
sudo ./install.sh
```

Le script interactif va :
1. ✅ Vérifier les prérequis
2. ✅ Installer K3s
3. ✅ Créer les namespaces et secrets
4. ✅ Installer cert-manager (SSL)
5. ✅ Configurer iptables
6. ✅ Déployer Traefik
7. ✅ Déployer PostgreSQL et Redis
8. ✅ Builder et déployer les applications
9. ✅ Installer le monitoring (optionnel)

**Temps estimé : 30-60 minutes**

---

## 📖 Option B : Installation manuelle (étape par étape)

Pour plus de contrôle sur chaque étape :

---

## Phase 1 : Installation K3s (30 minutes)

### 1.1 - Installer K3s

```bash
cd /srv/homelab/kubernetes
chmod +x scripts/install-k3s.sh
sudo ./scripts/install-k3s.sh
```

**Vérification :**
```bash
kubectl get nodes
kubectl get pods -A
```

### 1.2 - Créer les namespaces

```bash
chmod +x scripts/setup-namespaces.sh
./scripts/setup-namespaces.sh
```

**Vérification :**
```bash
kubectl get namespaces
```

### 1.3 - Créer les secrets

```bash
chmod +x scripts/create-secrets.sh
./scripts/create-secrets.sh
```

**Vérification :**
```bash
kubectl get secrets -n infrastructure
kubectl get secrets -n monitoring
kubectl get secrets -n zoom2604
```

---

## Phase 2 : Infrastructure de base (30 minutes)

### 2.1 - Installer cert-manager

```bash
chmod +x scripts/install-cert-manager.sh
./scripts/install-cert-manager.sh
```

**Attendre que cert-manager soit prêt (2-3 minutes)**

```bash
kubectl get pods -n cert-manager
```

### 2.2 - Créer les ClusterIssuers

```bash
kubectl apply -f infrastructure/cert-manager-issuer.yaml
```

**Vérification :**
```bash
kubectl get clusterissuer
```

### 2.3 - Déployer Traefik

```bash
kubectl apply -f infrastructure/traefik.yaml
```

**Vérification :**
```bash
kubectl get pods -n infrastructure
kubectl get svc -n infrastructure
```

### 2.4 - Configurer iptables pour redirection de ports

K3s utilise NodePort, il faut rediriger les ports 80/443 :

```bash
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 30080
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 30443

# Sauvegarder les règles
sudo apt-get install iptables-persistent
sudo netfilter-persistent save
```

---

## Phase 3 : Bases de données (30 minutes)

### 3.1 - Backup des bases de données existantes

**IMPORTANT : Sauvegarder les données avant migration !**

```bash
# PostgreSQL
cd /srv/homelab/infrastructure
sudo docker-compose exec postgres pg_dumpall -U postgres > /tmp/postgres_backup.sql

# Copier le backup en lieu sûr
cp /tmp/postgres_backup.sql ~/backups/
```

### 3.2 - Déployer PostgreSQL sur K8s

```bash
cd /srv/homelab/kubernetes
kubectl apply -f infrastructure/postgres.yaml
```

**Attendre que PostgreSQL soit prêt (2-3 minutes)**

```bash
kubectl get pods -n infrastructure -w
```

### 3.3 - Restaurer les données

```bash
# Copier le backup dans le pod
kubectl cp /tmp/postgres_backup.sql infrastructure/postgres-0:/tmp/

# Restaurer
kubectl exec -n infrastructure postgres-0 -- psql -U postgres -f /tmp/postgres_backup.sql
```

### 3.4 - Déployer Redis

```bash
kubectl apply -f infrastructure/redis.yaml
```

**Vérification :**
```bash
kubectl get pods -n infrastructure
kubectl get svc -n infrastructure
```

---

## Phase 4 : Applications (1 heure)

### 4.1 - Builder les images Docker

```bash
cd /srv/homelab/kubernetes
chmod +x scripts/build-images.sh
./scripts/build-images.sh
```

**Temps estimé : 15-20 minutes**

### 4.2 - Importer les images dans K3s

```bash
chmod +x scripts/import-images-to-k3s.sh
./scripts/import-images-to-k3s.sh
```

### 4.3 - Déployer les applications

**Portfolio et CV (nathan-ferre.fr) :**

```bash
kubectl apply -f apps/portfolio-azrael.yaml
kubectl apply -f apps/cv.yaml
```

**Game 2048 et Admin (zoom2604.dev) :**

```bash
kubectl apply -f apps/game-2048.yaml
kubectl apply -f apps/admin-panel.yaml
```

### 4.4 - Vérifier les déploiements

```bash
kubectl get pods -n nathan-ferre
kubectl get pods -n zoom2604
kubectl get ingress -A
```

### 4.5 - Vérifier les certificats SSL

```bash
kubectl get certificates -A
```

**Les certificats peuvent prendre 2-5 minutes à être émis**

---

## Phase 5 : Monitoring (30 minutes)

### 5.1 - Installer kube-prometheus-stack

```bash
cd /srv/homelab/kubernetes
chmod +x scripts/install-monitoring.sh
./scripts/install-monitoring.sh
```

**Attendre que tout soit prêt (5-10 minutes)**

```bash
kubectl get pods -n monitoring -w
```

### 5.2 - Installer Loki

```bash
chmod +x scripts/install-loki.sh
./scripts/install-loki.sh
```

### 5.3 - Accéder à Grafana

Ouvrir : https://grafana.zoom2604.dev

**Identifiants :**
- Username: admin
- Password: (voir secret grafana-credentials)

```bash
kubectl get secret grafana-credentials -n monitoring -o jsonpath='{.data.admin-password}' | base64 -d
```

### 5.4 - Ajouter Loki comme data source dans Grafana

1. Configuration → Data Sources → Add data source
2. Choisir "Loki"
3. URL: `http://loki:3100`
4. Save & Test

---

## Phase 6 : Tests et validation (30 minutes)

### 6.1 - Tester les applications

- ✅ https://nathan-ferre.fr (Portfolio)
- ✅ https://cv.nathan-ferre.fr (CV)
- ✅ https://2048.zoom2604.dev (Game 2048)
- ✅ https://admin.zoom2604.dev (Admin Panel)
- ✅ https://grafana.zoom2604.dev (Grafana)
- ✅ https://traefik.zoom2604.dev (Traefik Dashboard)

### 6.2 - Vérifier les certificats SSL

```bash
curl -I https://nathan-ferre.fr
curl -I https://grafana.zoom2604.dev
```

### 6.3 - Vérifier les logs

```bash
# Logs d'une application
kubectl logs -n nathan-ferre deployment/portfolio-azrael

# Logs Traefik
kubectl logs -n infrastructure deployment/traefik

# Logs dans Grafana
# Aller dans Grafana → Explore → Choisir Loki → {namespace="nathan-ferre"}
```

### 6.4 - Vérifier les métriques

Dans Grafana :
- Kubernetes / Compute Resources / Cluster
- Kubernetes / Compute Resources / Namespace
- Node Exporter / Nodes

---

## Phase 7 : Arrêt de l'ancien système (15 minutes)

**⚠️ ATTENTION : Ne faire qu'après validation complète !**

### 7.1 - Arrêter Docker Compose

```bash
cd /srv/homelab/infrastructure
sudo docker-compose down
```

### 7.2 - (Optionnel) Nettoyer les volumes Docker

```bash
# Lister les volumes
docker volume ls

# Supprimer si tout fonctionne sur K8s
# docker volume rm traefik_acme postgres_data redis_data
```

---

## 🎉 Migration terminée !

Votre infrastructure tourne maintenant sur Kubernetes K3s !

## 📊 Commandes utiles

### Surveillance générale

```bash
# Voir tous les pods
kubectl get pods -A

# Voir les ressources utilisées
kubectl top nodes
kubectl top pods -A

# Logs en temps réel
kubectl logs -f -n namespace pod-name
```

### Gestion des applications

```bash
# Redémarrer une application
kubectl rollout restart deployment/portfolio-azrael -n nathan-ferre

# Scaler une application
kubectl scale deployment/game-2048 --replicas=2 -n zoom2604

# Voir l'historique des déploiements
kubectl rollout history deployment/portfolio-azrael -n nathan-ferre
```

### Debugging

```bash
# Entrer dans un pod
kubectl exec -it -n namespace pod-name -- /bin/sh

# Port-forward pour debug
kubectl port-forward -n namespace svc/service-name 8080:80

# Décrire un pod pour voir les événements
kubectl describe pod -n namespace pod-name
```

### Monitoring

```bash
# Voir les certificats SSL
kubectl get certificates -A

# Voir les ingress
kubectl get ingress -A

# Voir les PVC (stockage)
kubectl get pvc -A
```

---

## 🔧 Troubleshooting

### Problème : Pod en CrashLoopBackOff

```bash
kubectl describe pod -n namespace pod-name
kubectl logs -n namespace pod-name --previous
```

### Problème : Certificat SSL non émis

```bash
kubectl describe certificate -n namespace cert-name
kubectl logs -n cert-manager deployment/cert-manager
```

### Problème : Application non accessible

```bash
# Vérifier l'ingress
kubectl get ingress -A
kubectl describe ingress -n namespace ingress-name

# Vérifier Traefik
kubectl logs -n infrastructure deployment/traefik
```

### Problème : Base de données non accessible

```bash
# Tester la connexion depuis un pod
kubectl run -it --rm debug --image=postgres:16-alpine --restart=Never -- psql -h postgres.infrastructure.svc.cluster.local -U postgres
```

---

## 🔄 Mises à jour futures

### Mettre à jour une application

```bash
# 1. Rebuilder l'image
cd /srv/nathan-ferre.fr/azrael
docker build -t portfolio-azrael:latest .

# 2. Importer dans K3s
docker save portfolio-azrael:latest -o /tmp/portfolio.tar
sudo k3s ctr images import /tmp/portfolio.tar

# 3. Redémarrer le déploiement
kubectl rollout restart deployment/portfolio-azrael -n nathan-ferre
```

### Backups réguliers

```bash
# PostgreSQL
kubectl exec -n infrastructure postgres-0 -- pg_dumpall -U postgres > backup_$(date +%Y%m%d).sql

# Volumes
# Utiliser Velero pour backup automatique des PVC
```

---

## 📚 Ressources

- [Documentation K3s](https://docs.k3s.io/)
- [Documentation Kubernetes](https://kubernetes.io/docs/)
- [Documentation Traefik](https://doc.traefik.io/traefik/)
- [Documentation cert-manager](https://cert-manager.io/docs/)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

---

## 🆘 Support

En cas de problème :
1. Vérifier les logs : `kubectl logs -n namespace pod-name`
2. Vérifier les événements : `kubectl get events -n namespace`
3. Vérifier l'état : `kubectl describe pod -n namespace pod-name`
