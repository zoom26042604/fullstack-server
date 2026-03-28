# Homelab Infrastructure

Infrastructure homelab deployee sur VPS unique, orchestree via Kubernetes (K3s) avec deploiement continu GitOps via ArgoCD.

---

## Stack technique

| Composant | Version | Role |
|-----------|---------|------|
| K3s | v1.34.3 | Distribution Kubernetes allegee |
| Traefik | v3.0 | Reverse proxy et ingress controller |
| cert-manager | v1.20.1 | Gestion automatique des certificats SSL |
| ArgoCD | v3.3.6 | Deploiement continu (GitOps) |
| Helm | v3.20.0 | Gestionnaire de paquets Kubernetes |
| Prometheus | v0.88.1 | Collecte de metriques |
| Grafana | v11.x | Visualisation et dashboards |
| Uptime Kuma | v1.x | Supervision de disponibilite |
| PostgreSQL | 16 | Base de donnees relationnelle |
| Redis | 7 | Cache en memoire |

---

## Serveur

- **OS** : Debian GNU/Linux 13 (Trixie)
- **CPU** : 6 vCPU
- **RAM** : 12 Go
- **Disque** : 99 Go
- **IP** : 51.91.76.23

---

## Applications deployees

| Application | URL | Namespace |
|-------------|-----|-----------|
| Portfolio | https://nathan-ferre.fr | nathan-ferre |
| CV | https://cv.nathan-ferre.fr | nathan-ferre |
| Game 2048 | https://2048.zoom2604.dev | zoom2604 |
| Homer Dashboard | https://zoom2604.dev | infrastructure |

## Outils d'administration

| Outil | URL | Role |
|-------|-----|------|
| ArgoCD | https://argocd.zoom2604.dev | GitOps et deploiements |
| Grafana | https://grafana.zoom2604.dev | Metriques et dashboards |
| Uptime Kuma | https://uptime.zoom2604.dev | Disponibilite des services |
| Traefik | https://traefik.zoom2604.dev | Etat du reverse proxy |

---

## GitOps : deployer une modification

Toutes les modifications de l'infrastructure passent par Git. ArgoCD surveille ce depot et applique automatiquement les changements dans les 3 minutes suivant un push.

```bash
# Modifier un manifest
vim kubernetes/apps/mon-app.yaml

# Pousser
git add kubernetes/apps/mon-app.yaml
git commit -m "feat: description de la modification"
git push origin main

# ArgoCD applique automatiquement
```

---

## Structure du depot

```
kubernetes/
├── base/           # Namespaces
├── infrastructure/ # Traefik, PostgreSQL, Redis, cert-manager
├── apps/           # Applications (portfolio, cv, game-2048, homer, uptime-kuma)
├── monitoring/     # Configuration Grafana
├── argocd/         # Applications ArgoCD (GitOps self-managed)
└── scripts/        # Scripts d'administration du cluster
```

---

## Namespaces

| Namespace | Contenu |
|-----------|---------|
| infrastructure | Traefik, Homer, PostgreSQL, Redis |
| nathan-ferre | Portfolio, CV |
| zoom2604 | Game 2048 |
| monitoring | Prometheus, Grafana, Uptime Kuma |
| cert-manager | Gestion des certificats SSL |
| argocd | ArgoCD |

---

## Documentation complete

La documentation detaillee de l'infrastructure, incluant l'explication de chaque technologie, l'architecture reseau et les procedures operationnelles, se trouve dans [doc/INFRASTRUCTURE.md](doc/INFRASTRUCTURE.md).

---

## Licence

MIT License - voir [LICENSE](LICENSE)
