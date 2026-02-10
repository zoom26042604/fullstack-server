# 🔧 Troubleshooting - Guide de dépannage

## Problèmes courants lors de l'installation

### ❌ Installation échoue immédiatement

**Symptômes :**
```bash
sudo ./install.sh
# Erreur immédiate
```

**Solutions :**

1. **Vérifier les fichiers**
   ```bash
   ./check.sh
   ```

2. **Vérifier le fichier .env**
   ```bash
   ls -la ../infrastructure/.env
   ```
   Si absent, créez-le depuis `.env.example`

3. **Vérifier les permissions**
   ```bash
   chmod +x install.sh
   chmod +x scripts/*.sh
   ```

---

### ❌ K3s déjà installé

**Symptômes :**
```
K3s est déjà installé et actif
```

**Solutions :**

Option 1 - Garder K3s existant :
```bash
# Passer directement aux étapes suivantes
./scripts/setup-namespaces.sh
./scripts/create-secrets.sh
```

Option 2 - Réinstaller K3s :
```bash
# Désinstaller K3s
sudo /usr/local/bin/k3s-uninstall.sh

# Réinstaller
sudo ./install.sh
```

---

### ❌ Erreur "command not found: kubectl"

**Symptômes :**
```
kubectl: command not found
```

**Solutions :**
```bash
# K3s installe kubectl comme k3s
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Ou créer un lien symbolique
sudo ln -s /usr/local/bin/k3s /usr/local/bin/kubectl
```

---

### ❌ Pods en CrashLoopBackOff

**Symptômes :**
```bash
kubectl get pods -A
# STATUS: CrashLoopBackOff
```

**Solutions :**

1. **Voir les logs**
   ```bash
   kubectl logs -n namespace pod-name
   kubectl logs -n namespace pod-name --previous
   ```

2. **Décrire le pod**
   ```bash
   kubectl describe pod -n namespace pod-name
   ```

3. **Problèmes courants :**
   - Image non trouvée → Rebuilder et importer
   - Secret manquant → Vérifier `./scripts/create-secrets.sh`
   - Ressources insuffisantes → Vérifier `kubectl top nodes`

---

### ❌ Certificat SSL non émis

**Symptômes :**
```bash
kubectl get certificates -A
# READY: False
```

**Solutions :**

1. **Vérifier cert-manager**
   ```bash
   kubectl get pods -n cert-manager
   kubectl logs -n cert-manager deployment/cert-manager
   ```

2. **Vérifier les challenges**
   ```bash
   kubectl get challenges -A
   kubectl describe challenge -n namespace challenge-name
   ```

3. **Vérifier Traefik**
   ```bash
   kubectl logs -n infrastructure deployment/traefik
   ```

4. **Vérifier les ports**
   ```bash
   sudo iptables -t nat -L PREROUTING -n
   # Doit montrer : 80 → 30080 et 443 → 30443
   ```

---

### ❌ Application non accessible (502/503)

**Symptômes :**
```
502 Bad Gateway
503 Service Unavailable
```

**Solutions :**

1. **Vérifier que le pod tourne**
   ```bash
   kubectl get pods -n namespace
   ```

2. **Vérifier les services**
   ```bash
   kubectl get svc -n namespace
   ```

3. **Vérifier l'ingress**
   ```bash
   kubectl get ingress -n namespace
   kubectl describe ingress -n namespace ingress-name
   ```

4. **Tester en local**
   ```bash
   kubectl port-forward -n namespace pod-name 8080:3000
   # Puis accéder à http://localhost:8080
   ```

---

### ❌ Images Docker non trouvées

**Symptômes :**
```
Failed to pull image: not found
```

**Solutions :**

1. **Rebuilder les images**
   ```bash
   cd /srv/homelab/kubernetes
   ./scripts/build-images.sh
   ```

2. **Importer dans K3s**
   ```bash
   ./scripts/import-images-to-k3s.sh
   ```

3. **Vérifier les images**
   ```bash
   sudo k3s ctr images ls | grep -E "portfolio|cv|game|admin"
   ```

---

### ❌ Base de données non accessible

**Symptômes :**
```
Can't connect to PostgreSQL
Connection refused
```

**Solutions :**

1. **Vérifier PostgreSQL**
   ```bash
   kubectl get pods -n infrastructure
   kubectl logs -n infrastructure postgres-0
   ```

2. **Tester la connexion**
   ```bash
   kubectl run -it --rm debug --image=postgres:16-alpine --restart=Never -- \
     psql -h postgres.infrastructure.svc.cluster.local -U postgres
   ```

3. **Vérifier les secrets**
   ```bash
   kubectl get secret postgres-credentials -n infrastructure
   ```

---

### ❌ Manque de ressources (RAM/CPU)

**Symptômes :**
```
Insufficient memory
Insufficient CPU
```

**Solutions :**

1. **Vérifier l'utilisation**
   ```bash
   kubectl top nodes
   kubectl top pods -A
   ```

2. **Réduire les replicas**
   ```bash
   kubectl scale deployment/nom-app --replicas=0 -n namespace
   ```

3. **Ajuster les limites**
   - Éditer les manifests dans `apps/` et `infrastructure/`
   - Réduire les `resources.limits`

---

### ❌ Monitoring ne démarre pas

**Symptômes :**
```
Prometheus/Grafana pods pending
```

**Solutions :**

1. **Le monitoring est optionnel** - Vous pouvez le skip
   ```bash
   # Continuer sans monitoring
   ```

2. **Installer uniquement après les apps**
   ```bash
   # Attendre que les apps tournent d'abord
   kubectl get pods -A | grep Running
   
   # Puis installer monitoring
   ./scripts/install-monitoring.sh
   ```

---

## 🔄 Commandes de réinitialisation

### Redémarrer un service

```bash
kubectl rollout restart deployment/nom-service -n namespace
```

### Supprimer et redéployer une app

```bash
kubectl delete -f apps/portfolio-azrael.yaml
kubectl apply -f apps/portfolio-azrael.yaml
```

### Réinitialiser tout le cluster

```bash
# ⚠️ ATTENTION : Supprime tout !
sudo /usr/local/bin/k3s-uninstall.sh

# Puis réinstaller
cd /srv/homelab/kubernetes
sudo ./install.sh
```

---

## 📊 Commandes de diagnostic

```bash
# Voir tous les pods
kubectl get pods -A -o wide

# Voir les événements
kubectl get events -A --sort-by='.lastTimestamp'

# Voir les ressources
kubectl top nodes
kubectl top pods -A

# Voir les logs système K3s
sudo journalctl -u k3s -f

# Voir la configuration
kubectl cluster-info
kubectl get nodes
```

---

## 🆘 En dernier recours

Si rien ne fonctionne :

1. **Sauvegarder les données**
   ```bash
   kubectl exec -n infrastructure postgres-0 -- \
     pg_dumpall -U postgres > backup.sql
   ```

2. **Réinstaller proprement**
   ```bash
   sudo /usr/local/bin/k3s-uninstall.sh
   cd /srv/homelab/kubernetes
   sudo ./install.sh
   ```

3. **Restaurer les données**
   ```bash
   kubectl cp backup.sql infrastructure/postgres-0:/tmp/
   kubectl exec -n infrastructure postgres-0 -- \
     psql -U postgres -f /tmp/backup.sql
   ```

---

## 📚 Ressources utiles

- [Documentation K3s](https://docs.k3s.io/)
- [Kubernetes Troubleshooting](https://kubernetes.io/docs/tasks/debug/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [cert-manager Troubleshooting](https://cert-manager.io/docs/troubleshooting/)

---

## ✅ Vérifications post-installation

```bash
# 1. Cluster en bonne santé
kubectl get nodes
kubectl get pods -A

# 2. Services exposés
kubectl get svc -A
kubectl get ingress -A

# 3. Certificats SSL
kubectl get certificates -A

# 4. Ressources disponibles
kubectl top nodes
kubectl top pods -A

# 5. Tester les accès
curl -I https://nathan-ferre.fr
curl -I https://grafana.zoom2604.dev
```

Si tous ces checks passent ✅, votre installation est bonne !
