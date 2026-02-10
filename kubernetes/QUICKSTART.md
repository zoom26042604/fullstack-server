# 🎯 Quick Start - Homelab Kubernetes

## 🚀 Installation en 1 commande

```bash
cd /srv/homelab/kubernetes
sudo ./install.sh
```

C'est tout ! Le script interactif fait le reste. ⚡

---

## 📦 Ce qui sera installé

```
┌─────────────────────────────────────────┐
│  🏗️  Infrastructure Kubernetes         │
├─────────────────────────────────────────┤
│  • K3s (Kubernetes léger)              │
│  • Traefik (Ingress + SSL)             │
│  • cert-manager (Let's Encrypt)        │
│  • PostgreSQL (base de données)        │
│  • Redis (cache)                       │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  📱 Applications                        │
├─────────────────────────────────────────┤
│  • Portfolio (nathan-ferre.fr)         │
│  • CV (cv.nathan-ferre.fr)             │
│  • Game 2048 (2048.zoom2604.dev)       │
│  • Admin Panel (admin.zoom2604.dev)    │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  📊 Monitoring (optionnel)             │
├─────────────────────────────────────────┤
│  • Prometheus (métriques)              │
│  • Grafana (dashboards)                │
│  • Loki (logs centralisés)             │
└─────────────────────────────────────────┘
```

---

## ⏱️ Temps d'installation

| Méthode | Temps | Difficulté |
|---------|-------|------------|
| 🚀 **Automatique** (`./install.sh`) | **30-60 min** | ⭐ Facile |
| 📖 Manuelle (guide complet) | 2-3 heures | ⭐⭐⭐ Avancé |

---

## 🎬 Démo de l'installation automatique

```bash
$ sudo ./install.sh

╔════════════════════════════════════════════════╗
║                                                ║
║   🏠 Homelab Kubernetes Installation          ║
║      K3s + Applications + Monitoring           ║
║                                                ║
╚════════════════════════════════════════════════╝

ℹ  Installation du homelab Kubernetes K3s
ℹ  Temps estimé: 30-60 minutes

Voulez-vous continuer? (y/N) y

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Vérification des prérequis
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓  RAM suffisante: 12GB
✓  Disque suffisant: 100GB
✓  Docker installé

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phase 1: Installation K3s
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Installing K3s...
✓  K3s installé avec succès

...et ainsi de suite...
```

---

## 📚 Documentation

| Fichier | Description |
|---------|-------------|
| [README.md](README.md) | Documentation technique complète |
| [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) | Guide de migration détaillé |
| [scripts/README.md](scripts/README.md) | Documentation des scripts |
| [../KUBERNETES_RECAP.md](../KUBERNETES_RECAP.md) | Récapitulatif de la migration |

---

## 🔧 Commandes utiles après installation

```bash
# Voir tous les pods
kubectl get pods -A

# Ressources du cluster
kubectl top nodes
kubectl top pods -A

# Services exposés
kubectl get ingress -A

# Certificats SSL
kubectl get certificates -A
```

---

## 🌐 Accès aux services

Après installation, vos services seront accessibles :

- 🏠 **Portfolio** : https://nathan-ferre.fr
- 📄 **CV** : https://cv.nathan-ferre.fr
- 🎮 **Game 2048** : https://2048.zoom2604.dev
- 🔧 **Admin** : https://admin.zoom2604.dev
- 📊 **Grafana** : https://grafana.zoom2604.dev
- 🚦 **Traefik** : https://traefik.zoom2604.dev

---

## ❓ Besoin d'aide ?

1. Lire la [documentation complète](README.md)
2. Consulter le [guide de migration](MIGRATION_GUIDE.md)
3. Vérifier les logs : `kubectl logs -n namespace pod-name`
4. Décrire le problème : `kubectl describe pod -n namespace pod-name`

---

## 🎉 Prêt ?

```bash
cd /srv/homelab/kubernetes
sudo ./install.sh
```

Bonne installation ! 🚀
