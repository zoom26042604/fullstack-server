# Documentation Infrastructure Homelab

## Table des matieres

1. [Vue d'ensemble](#1-vue-densemble)
2. [Le serveur physique](#2-le-serveur-physique)
3. [Kubernetes et K3s](#3-kubernetes-et-k3s)
4. [Organisation en namespaces](#4-organisation-en-namespaces)
5. [Traefik - Le reverse proxy](#5-traefik---le-reverse-proxy)
6. [cert-manager - Les certificats SSL](#6-cert-manager---les-certificats-ssl)
7. [PostgreSQL - La base de donnees](#7-postgresql---la-base-de-donnees)
8. [Redis - Le cache](#8-redis---le-cache)
9. [Helm - Le gestionnaire de paquets](#9-helm---le-gestionnaire-de-paquets)
10. [Prometheus et Grafana - Le monitoring](#10-prometheus-et-grafana---le-monitoring)
11. [Uptime Kuma - La supervision](#11-uptime-kuma---la-supervision)
12. [Homer - Le dashboard](#12-homer---le-dashboard)
13. [ArgoCD - Le deploiement continu (GitOps)](#13-argocd---le-deploiement-continu-gitops)
14. [Les applications deployees](#14-les-applications-deployees)
15. [Le stockage persistant](#15-le-stockage-persistant)
16. [Le flux d'une requete HTTP](#16-le-flux-dune-requete-http)
17. [GitOps : comment deployer une modification](#17-gitops--comment-deployer-une-modification)
18. [URLs et acces](#18-urls-et-acces)
19. [Structure du depot Git](#19-structure-du-depot-git)

---

## 1. Vue d'ensemble

Ce homelab est une infrastructure complete de type production, deployee sur un VPS unique et geree via des outils professionnels. L'objectif est d'heberger plusieurs applications web avec un haut niveau de fiabilite, de securite et d'observabilite, tout en automatisant au maximum le cycle de deploiement.

L'infrastructure repose sur les principes du **GitOps** : l'etat desire du systeme est defini dans un depot Git, et un outil (ArgoCD) s'assure en permanence que le cluster correspond a cet etat. Toute modification passe par un commit sur GitHub plutot que par une commande manuelle sur le serveur.

### Schéma general

```
Internet
    |
    | (ports 80 / 443)
    v
+------------------+
|  VPS (51.91.76.23)|
|  Debian 13       |
|  6 vCPU / 12 GB  |
+--------+---------+
         |
         v
+------------------+
|  K3s (Kubernetes)|
|  v1.34.3         |
+--------+---------+
         |
    +----+----+
    |         |
    v         v
 Traefik   Applications
 (ingress)  (pods)
```

---

## 2. Le serveur physique

Le VPS tourne sur **Debian GNU/Linux 13 (Trixie)** avec le noyau `6.12.63+deb13-cloud-amd64`.

| Ressource | Valeur |
|-----------|--------|
| vCPU | 6 |
| RAM | 12 Go |
| Disque | 99 Go (SSD) |
| IP publique | 51.91.76.23 |
| OS | Debian 13 |

Le serveur heberge un unique noeud Kubernetes qui joue a la fois le role de **control plane** (le cerveau du cluster qui gere l'etat) et de **worker** (le noeud qui execute les conteneurs). C'est la configuration typique d'un homelab ou d'un cluster de petite taille.

### Pourquoi un seul noeud ?

Dans un cluster de production a grande echelle, on separe les noeuds control plane des noeuds worker pour des raisons de disponibilite et de performance. Sur un VPS unique, cette separation n'a pas de sens : si la machine tombe, tout tombe de toute facon. L'architecture single-node simplifie la gestion sans compromis pratique a cette echelle.

---

## 3. Kubernetes et K3s

### Qu'est-ce que Kubernetes ?

Kubernetes est un **orchestrateur de conteneurs**. Un conteneur est une unite d'execution qui empaquete une application avec toutes ses dependances (bibliotheques, configuration, runtime) de facon isolee du systeme hote. Docker est l'outil le plus connu pour construire et executer des conteneurs.

Le probleme que Kubernetes resout est le suivant : quand on gere plusieurs dizaines ou centaines de conteneurs, les faire demarrer, les redemarrer en cas de panne, leur allouer des ressources, gerer le reseau entre eux et les exposer vers l'exterieur devient rapidement ingerable manuellement. Kubernetes automatise tout cela.

**Ce que Kubernetes fait concretement sur ce serveur :**

- Il s'assure que chaque application tourne avec le bon nombre de replicas (ici, 1 par application).
- Si un conteneur plante, il le redemarrait automatiquement.
- Il fournit un reseau interne entre les applications (elles peuvent se parler par nom de service).
- Il gere le stockage persistant (les donnees survivent au redemarrage des conteneurs).
- Il expose les applications vers l'exterieur via Traefik.

### Les objets Kubernetes fondamentaux

**Pod** : La plus petite unite deployable dans Kubernetes. Un pod contient un ou plusieurs conteneurs qui partagent le meme reseau et le meme stockage. Dans ce homelab, chaque application correspond a un pod d'un seul conteneur.

**Deployment** : Un objet qui gere les pods applicatifs. Il definit l'image Docker a utiliser, le nombre de replicas, les ressources allouees, les probes de sante, etc. Si un pod meurt, le Deployment en cree automatiquement un nouveau. C'est le type de ressource utilise pour les applications stateless (sans etat persistant propre : cv, portfolio, homer, traefik).

**StatefulSet** : Similaire au Deployment, mais pour les applications stateful (avec etat). Il garantit que chaque pod a un identifiant stable et un volume de stockage dedie qui lui reste attache. C'est le type utilise pour PostgreSQL et Redis, qui doivent conserver leurs donnees meme si le pod redemarre.

**Service** : Un objet qui expose un groupe de pods a l'interieur du cluster sous une adresse IP et un nom DNS stables. Sans Service, les pods ont des adresses IP ephemeres qui changent a chaque redemarrage. Avec un Service nomme `postgres` dans le namespace `infrastructure`, n'importe quelle application peut joindre PostgreSQL via `postgres.infrastructure.svc.cluster.local:5432`.

**ConfigMap** : Un objet qui stocke de la configuration non confidentielle sous forme de cles/valeurs ou de fichiers. La configuration de Traefik et de Redis est stockee dans des ConfigMaps.

**Secret** : Similaire au ConfigMap, mais pour les donnees sensibles (mots de passe, cles d'API). Les credentials de PostgreSQL, Redis et du dashboard Traefik sont dans des Secrets. Les Secrets sont encodes en base64 dans etcd (la base de donnees interne de Kubernetes) mais ne sont pas chiffres par defaut - ils necessitent des mesures supplementaires en production pour une securite optimale.

**PersistentVolumeClaim (PVC)** : Une demande de stockage persistant. Quand un pod demande un PVC, Kubernetes lui alloue un volume sur le disque du noeud qui persiste independamment du cycle de vie du pod.

**Namespace** : Une isolation logique au sein du cluster. Les ressources dans des namespaces differents sont separees et ne peuvent pas se voir directement (sauf configuration explicite). Ce homelab utilise plusieurs namespaces pour organiser les ressources.

**Ingress et IngressRoute** : Des objets qui decrivent comment le trafic externe doit etre route vers les Services internes. L'Ingress est le standard Kubernetes, l'IngressRoute est la ressource personnalisee de Traefik qui offre plus de flexibilite.

### Qu'est-ce que K3s ?

K3s est une distribution allegee de Kubernetes, developpee par Rancher (maintenant SUSE). Elle est optimisee pour :

- **Les ressources limitees** : K3s consomme environ 512 Mo de RAM au lieu de plusieurs gigaoctets pour un Kubernetes standard.
- **La simplicite d'installation** : Un seul binaire remplace des dizaines de composants a installer separement.
- **Les environnements embarques et les homelab** : C'est le choix standard pour les projets personnels et les petits serveurs.

K3s remplace certains composants standard de Kubernetes par des alternatives plus legeres :
- `containerd` comme runtime de conteneurs (au lieu de Docker)
- `sqlite` ou `etcd` allege comme base de donnees interne
- `local-path-provisioner` comme fournisseur de stockage par defaut

La version installee est **v1.34.3+k3s3**, ce qui correspond a Kubernetes 1.34.3 avec les patches K3s.

### Les probes de sante

Chaque application dans ce homelab configure deux types de verification de sante :

**livenessProbe** : Kubernetes interroge cette URL a intervalles reguliers. Si elle echoue plusieurs fois de suite, Kubernetes considere que le pod est mort et le redemarrait. C'est la detection des blocages (deadlocks) ou des panics.

**readinessProbe** : Kubernetes interroge cette URL pour savoir si le pod est pret a recevoir du trafic. Un pod peut etre vivant mais pas encore pret (pendant le demarrage de l'application, par exemple). Un pod non-Ready est retire de la rotation du Service jusqu'a ce qu'il repasse Ready.

```yaml
livenessProbe:
  httpGet:
    path: /
    port: 3000
  initialDelaySeconds: 30   # On attend 30s avant le premier check
  periodSeconds: 10          # Puis on verifie toutes les 10s

readinessProbe:
  httpGet:
    path: /
    port: 3000
  initialDelaySeconds: 10
  periodSeconds: 5
```

### Les requests et limits de ressources

Chaque pod declare ses besoins en ressources :

```yaml
resources:
  requests:
    memory: "200Mi"   # Garanti par le scheduler
    cpu: "100m"       # 100m = 0.1 vCPU
  limits:
    memory: "400Mi"   # Maximum autorise
    cpu: "500m"       # 0.5 vCPU maximum
```

Les **requests** sont ce que Kubernetes garantit au pod. Le scheduler utilise les requests pour decider sur quel noeud placer le pod. Les **limits** sont le plafond : si un pod depasse sa memory limit, il est tue (OOMKilled). S'il depasse sa CPU limit, il est throttle (ralenti) mais pas tue.

---

## 4. Organisation en namespaces

Le cluster est organise en 6 namespaces :

| Namespace | Contenu |
|-----------|---------|
| `infrastructure` | Traefik, Homer, PostgreSQL, Redis |
| `nathan-ferre` | Portfolio Azrael, CV |
| `zoom2604` | Game 2048 |
| `monitoring` | Prometheus, Grafana, Uptime Kuma |
| `cert-manager` | cert-manager (gestionnaire de certificats SSL) |
| `argocd` | ArgoCD (deploiement continu) |
| `kube-system` | Composants internes de K3s (CoreDNS, metrics-server...) |

Cette organisation repond a plusieurs objectifs :

- **Clarte** : Il est immediatement visible a quel domaine ou fonction appartient chaque ressource.
- **Isolation** : Les applications de `nathan-ferre` ne peuvent pas acceder directement aux ressources de `zoom2604` sans passer par des Services explicitement exposes.
- **Gestion des permissions** : On peut appliquer des politiques de securite (RBAC, NetworkPolicies) par namespace.
- **ArgoCD** : Chaque ArgoCD Application gere un dossier du depot Git et le deploie dans un namespace cible, ce qui correspond directement a cette organisation.

---

## 5. Traefik - Le reverse proxy

### Qu'est-ce qu'un reverse proxy ?

Un reverse proxy est un serveur qui se positionne devant les applications web et qui redistribue les requetes entrantes vers la bonne application en fonction de criteres (nom de domaine, chemin URL, etc.). Il est le point d'entree unique de toute l'infrastructure.

Sans reverse proxy, chaque application devrait ecouter sur un port different (`:3000`, `:3001`, `:8080`...) et les utilisateurs devraient connaitre ces ports. Le reverse proxy permet d'avoir toutes les applications sur le port standard 443 (HTTPS), differenciees par leur nom de domaine.

### Pourquoi Traefik ?

Traefik est un reverse proxy moderne concu nativement pour Kubernetes. Sa particularite principale est sa **decouverte automatique de la configuration** : il surveille l'API Kubernetes en temps reel et met a jour sa configuration automatiquement quand de nouveaux Ingress ou IngressRoutes sont crees, sans redemarrage.

Il gere egalement les certificats SSL Let's Encrypt nativement, sans outil supplementaire (bien que cert-manager soit aussi utilise dans ce homelab pour les ressources Ingress standard).

### Configuration dans ce homelab

Traefik est deploye comme un **Deployment** dans le namespace `infrastructure` avec `hostNetwork: true`. Cette option est importante : elle signifie que Traefik ecoute directement sur les ports de la machine hote (80 et 443) plutot que sur un reseau virtuel Kubernetes. C'est necessaire pour recevoir le trafic internet entrant.

Les ports sont egalement exposes via un **Service NodePort** (30080 pour HTTP, 30443 pour HTTPS), mais le vrai trafic arrive via hostNetwork.

**Les entrypoints** definis dans la configuration de Traefik :

- `web` : Port 80 (HTTP) - Traefik redirige automatiquement vers HTTPS.
- `websecure` : Port 443 (HTTPS) - Toutes les applications sont servies ici.
- `admin` : Port 8080 - Interface d'administration de Traefik (non accessible depuis internet, uniquement en interne).

**Le certificat ACME (Let's Encrypt)** : Traefik gere lui-meme la demande et le renouvellement des certificats SSL via le protocole ACME et la methode de validation HTTP-01. Quand Let's Encrypt veut verifier que tu controles un domaine, il demande a Traefik de servir un fichier specifique sur `http://domaine.com/.well-known/acme-challenge/...`. Traefik le fait automatiquement. Les certificats sont stockes dans un fichier `acme.json` sur un volume persistant de 1 Go.

**Les middlewares** sont des transformations appliquees aux requetes ou reponses :

- `auth` : Ajoute une authentification HTTP Basic sur le dashboard Traefik.
- `dashboard-redirect` : Redirige `traefik.zoom2604.dev/` vers `traefik.zoom2604.dev/dashboard/`.
- `acme-http` : Laisse passer les requetes de validation ACME sans les rediriger vers HTTPS.

**Le RBAC Traefik** : Pour lire la configuration des Ingress et IngressRoutes dans Kubernetes, Traefik a besoin de permissions. Ces permissions sont definies via un `ServiceAccount`, un `ClusterRole` (qui liste les permissions) et un `ClusterRoleBinding` (qui lie le role au ServiceAccount).

### IngressRoute vs Ingress

Ce homelab utilise deux types de ressources de routage :

**Ingress** (standard Kubernetes) : Format universel supporte par tous les ingress controllers. Il est moins expressif mais plus portable. Les annotations specifiques a Traefik sont utilisees pour le configurer.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
spec:
  rules:
  - host: cv.nathan-ferre.fr
    http:
      paths:
      - path: /
        backend:
          service:
            name: cv
            port:
              number: 80
```

**IngressRoute** (CRD Traefik) : Format propre a Traefik, plus puissant et expressif. Il permet d'utiliser toutes les fonctionnalites de Traefik (middlewares avances, routage TCP/UDP, etc.).

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: cv
  namespace: nathan-ferre
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`cv.nathan-ferre.fr`)
      kind: Rule
      services:
        - name: cv
          port: 80
  tls:
    certResolver: letsencrypt
```

Dans ce homelab, les deux coexistent : les IngressRoutes sont les ressources actives, les Ingress standard servent a la gestion des certificats par cert-manager.

---

## 6. cert-manager - Les certificats SSL

### Le probleme des certificats SSL

Pour servir un site en HTTPS, il faut un certificat SSL signe par une autorite de certification (CA) reconnue par les navigateurs. Let's Encrypt est une CA gratuite et automatisee. Mais obtenir et renouveler ces certificats manuellement (tous les 90 jours pour Let's Encrypt) est une tache fastidieuse.

### Qu'est-ce que cert-manager ?

cert-manager est un operateur Kubernetes qui automatise completement la gestion des certificats SSL. Il surveille des ressources Kubernetes (Certificate, ClusterIssuer) et interagit avec les CA (Let's Encrypt, etc.) pour obtenir et renouveler les certificats automatiquement.

### Comment ca marche dans ce homelab

**ClusterIssuer** : Une ressource qui definit comment obtenir des certificats. Il y en a deux :

- `letsencrypt-prod` : Utilise l'API de production de Let's Encrypt. Les certificats emis sont valides et reconnus par les navigateurs.
- `letsencrypt-staging` : Utilise l'API de test. Les certificats ne sont pas reconnus par les navigateurs mais permettent de tester la configuration sans risquer de se faire bloquer par les rate limits de production.

La methode de validation utilisee est **HTTP-01** : Let's Encrypt demande a cert-manager de creer un fichier accessible sur `http://domaine.com/.well-known/acme-challenge/TOKEN`. cert-manager cree un pod temporaire (`cm-acme-http-solver`) pour servir ce fichier. Une fois la validation reussie, Let's Encrypt emet le certificat.

Les certificats obtenus sont stockes dans des **Secrets** Kubernetes (par exemple, `cv-tls` pour le certificat de `cv.nathan-ferre.fr`). Les ressources Ingress referencent ces Secrets dans leur section `tls`.

cert-manager est installe via **Helm** (chart `jetstack/cert-manager` v1.20.1) dans le namespace `cert-manager`.

---

## 7. PostgreSQL - La base de donnees

### Qu'est-ce que PostgreSQL ?

PostgreSQL est un systeme de gestion de bases de donnees relationnelles (SGBDR) open source. Il stocke des donnees de facon structuree en tables, avec des relations entre elles, et supporte le langage SQL. C'est l'une des bases de donnees les plus populaires au monde, reconnue pour sa fiabilite et sa conformite aux standards.

### Deploiement dans ce homelab

PostgreSQL est deploye comme un **StatefulSet** (et non un Deployment) car c'est une application stateful : ses donnees doivent persister meme si le pod redemarre ou est replanifie.

**L'image utilisee** est `postgres:16-alpine`. L'alpine signifie que l'image est construite sur Alpine Linux, une distribution ultra-legere (~5 Mo), ce qui reduit la taille de l'image et la surface d'attaque.

**Le stockage** : Un volume de 20 Go est alloue via un `volumeClaimTemplate` dans le StatefulSet. Ce template cree automatiquement un PVC nomme `postgres-data-postgres-0` pour le pod `postgres-0`. La notation `-0` vient du StatefulSet : les pods sont numerotes et gardent toujours le meme nom, ce qui garantit que le bon volume est reattache au bon pod.

**Les credentials** sont passes via un Secret Kubernetes nomme `postgres-credentials`, avec les cles `POSTGRES_USER`, `POSTGRES_PASSWORD` et `POSTGRES_DB`. Le pod lit ces valeurs via `valueFrom.secretKeyRef`, ce qui evite de coder les mots de passe en dur dans les manifests.

**Les probes** utilisent la commande `pg_isready` plutot qu'une requete HTTP, car PostgreSQL est une base de donnees et non un serveur web.

**Le Service** de PostgreSQL est de type `headless` (clusterIP: None). Un Service headless ne cree pas d'IP virtuelle : les requetes DNS retournent directement l'IP du pod. C'est le comportement standard pour les StatefulSets, qui ont besoin d'adresses stables et previsibles.

PostgreSQL est accessible uniquement en interne au cluster, sur `postgres.infrastructure.svc.cluster.local:5432`. Il n'est jamais expose vers internet.

---

## 8. Redis - Le cache

### Qu'est-ce que Redis ?

Redis est un store de donnees en memoire, utilise principalement comme cache. La difference fondamentale avec PostgreSQL est que Redis stocke les donnees en RAM (extremement rapide) plutot que sur disque (plus lent). Il est ideal pour les donnees qui doivent etre lues tres frequemment et peuvent etre recalculees si perdues (sessions utilisateurs, resultats de requetes frequentes, files d'attente).

### Configuration dans ce homelab

Redis est deploye comme un **StatefulSet** avec un volume de 5 Go pour la persistance. Meme si Redis est principalement un cache memoire, il peut persister ses donnees sur disque pour eviter de tout perdre en cas de redemarrage.

**La configuration** est stockee dans un ConfigMap :

```
maxmemory 256mb              # Limite la RAM utilisee par Redis
maxmemory-policy allkeys-lru # Quand la memoire est pleine, supprime les cles
                              # les moins recemment utilisees (LRU)
save 900 1                   # Sauvegarde sur disque si 1 cle change en 900s
save 300 10                  # Sauvegarde si 10 cles changent en 300s
save 60 10000                # Sauvegarde si 10000 cles changent en 60s
appendonly yes               # Active le journal de toutes les ecritures (AOF)
appendfsync everysec         # Flush le journal sur disque toutes les secondes
```

**La politique LRU** (Least Recently Used) signifie que quand Redis atteint sa limite memoire de 256 Mo, il supprime automatiquement les cles qui ont ete accedees le moins recemment. C'est le comportement optimal pour un cache.

**Le mot de passe** Redis est passe via un Secret (`redis-credentials`) et injected dans la commande de demarrage de Redis via la variable d'environnement `REDIS_PASSWORD`.

Comme PostgreSQL, Redis est uniquement accessible en interne : `redis.infrastructure.svc.cluster.local:6379`.

---

## 9. Helm - Le gestionnaire de paquets

### Qu'est-ce que Helm ?

Helm est le gestionnaire de paquets pour Kubernetes. Il joue un role similaire a `apt` sur Debian ou `npm` pour Node.js. Un **chart Helm** est un paquet qui contient tous les manifests Kubernetes necessaires pour deployer une application, avec des valeurs configurables.

Plutot que d'ecrire et maintenir manuellement des dizaines de manifests Kubernetes pour des applications complexes comme Prometheus ou ArgoCD, Helm permet d'installer et de mettre a jour ces applications en une seule commande, avec une configuration centralisee.

### Utilisation dans ce homelab

Trois applications sont deployees via Helm dans ce homelab :

| Chart | Namespace | Description |
|-------|-----------|-------------|
| `argo/argo-cd` v9.4.17 | argocd | ArgoCD (GitOps) |
| `jetstack/cert-manager` v1.20.1 | cert-manager | Gestion des certificats SSL |
| `prometheus-community/kube-prometheus-stack` v81.6.0 | monitoring | Prometheus + Grafana + alerting |

Ces applications sont deployees via Helm et non par ArgoCD car elles sont la fondation de l'infrastructure. ArgoCD ne peut pas se gerer lui-meme lors de son installation initiale, et cert-manager doit etre present avant qu'ArgoCD puisse synchroniser les manifests qui en dependent.

### La version Helm installee

Helm v3.20.0 est installe directement sur le serveur.

---

## 10. Prometheus et Grafana - Le monitoring

### Qu'est-ce que le monitoring ?

Le monitoring consiste a collecter, stocker et visualiser des metriques sur l'etat du systeme et des applications : CPU, memoire, nombre de requetes par seconde, latence, erreurs, etc. Sans monitoring, on ne sait pas ce qui se passe sur le serveur et on decouvre les problemes seulement quand les utilisateurs se plaignent.

### Prometheus

**Prometheus** est un systeme de collecte et de stockage de metriques, open source, cree par SoundCloud et maintenant sous la garde de la CNCF (Cloud Native Computing Foundation). Il fonctionne par **scraping** : il interroge periodiquement (toutes les 15 secondes par defaut) des endpoints `/metrics` exposes par les applications et les composants du systeme, et stocke les valeurs dans sa base de donnees de series temporelles (TSDB).

Les composants deployes via le chart `kube-prometheus-stack` :

- **Prometheus** : Le moteur principal de collecte et de stockage.
- **Alertmanager** : Gere les alertes (routes, silences, notifications).
- **kube-state-metrics** : Expose des metriques sur l'etat des objets Kubernetes (nombre de pods, deployments, etc.).
- **node-exporter** : Expose des metriques systeme du noeud (CPU, RAM, disque, reseau).
- **Prometheus Operator** : Un operateur Kubernetes qui simplifie la configuration de Prometheus via des ressources personnalisees (ServiceMonitor, PodMonitor).

### Grafana

**Grafana** est l'outil de visualisation qui se connecte a Prometheus comme source de donnees et permet de creer des dashboards. Il est deploye dans le namespace `monitoring` et accessible sur `grafana.zoom2604.dev`.

La configuration de Grafana dans ce homelab est stockee dans des ConfigMaps (`grafana-config.yaml` dans `kubernetes/monitoring/`) qui definissent :

- **Les datasources** : La connexion vers Prometheus (`http://prometheus-kube-prometheus-prometheus:9090`).
- **Les dashboard providers** : Des chemins ou Grafana cherche automatiquement des fichiers JSON de dashboards.
- **Les dashboards** : Des definitions JSON de visualisations preconstruites (Node Exporter Full, Kubernetes Cluster).

---

## 11. Uptime Kuma - La supervision

**Uptime Kuma** est un outil de monitoring de disponibilite (uptime monitoring). Il verifie periodiquement si des URLs ou services sont accessibles et affiche un historique de disponibilite. C'est l'equivalent self-hosted de services comme UptimeRobot.

Il est deploye dans le namespace `monitoring` avec un volume persistant de 1 Go pour stocker sa base de donnees SQLite. Accessible sur `uptime.zoom2604.dev`.

La difference avec Prometheus est la suivante :
- Prometheus collecte des metriques detaillees (CPU, latence, nb de requetes) pour l'analyse et l'alerting.
- Uptime Kuma verifie simplement "est-ce que le site repond ?" et maintient un historique visuel de la disponibilite.

---

## 12. Homer - Le dashboard

**Homer** est une page d'accueil statique qui centralise les liens vers toutes les applications et services de l'infrastructure. C'est simplement une page web configuree via un fichier YAML.

Il est deploye dans le namespace `infrastructure` et accessible sur `zoom2604.dev` (le domaine racine). Sa configuration est stockee dans un ConfigMap qui definit le titre, les sections et les liens.

Homer ne fait rien de dynamique : il ne verifie pas si les services sont disponibles, il ne collecte pas de metriques. C'est un simple lanceur de liens, utile pour centraliser l'acces a toute l'infrastructure.

---

## 13. ArgoCD - Le deploiement continu (GitOps)

### Le concept GitOps

Le GitOps est une methode de deploiement ou **le depot Git est la source de verite unique** pour l'etat desire du systeme. Plutot que d'appliquer des modifications directement sur le cluster avec `kubectl apply`, on pousse les modifications dans Git, et un outil se charge de les appliquer automatiquement sur le cluster.

Les avantages sont nombreux :
- **Historique complet** : Chaque modification de l'infrastructure est tracee dans Git avec un auteur et un message de commit.
- **Reversibilite** : Un `git revert` suffit pour annuler une modification de l'infrastructure.
- **Review possible** : Les modifications d'infrastructure peuvent passer par des Pull Requests, revues par un pair avant d'etre appliquees.
- **Coherence** : Le cluster est toujours dans l'etat defini dans Git. Si quelqu'un fait une modification manuelle sur le cluster, ArgoCD la detecte et la corrige.

### Qu'est-ce qu'ArgoCD ?

ArgoCD est un outil GitOps pour Kubernetes. Il surveille un ou plusieurs depots Git et s'assure que l'etat du cluster correspond a ce qui est decrit dans ces depots. Si une difference est detectee (drift), ArgoCD peut la corriger automatiquement (mode `selfHeal`) ou alerter l'operateur.

### Architecture ArgoCD dans ce homelab

ArgoCD est installe via Helm dans le namespace `argocd`. Il expose son interface web sur `argocd.zoom2604.dev` via une IngressRoute Traefik.

**Les Applications ArgoCD** : Une Application ArgoCD est un objet Kubernetes qui definit :
- Le depot Git source et le chemin a surveiller.
- Le cluster et le namespace de destination.
- La politique de synchronisation.

Cinq Applications sont configurees, chacune correspondant a un dossier du depot :

| Application | Chemin Git | Namespace cible | Contenu |
|-------------|------------|-----------------|---------|
| `base` | `kubernetes/base` | default | Namespaces |
| `infrastructure` | `kubernetes/infrastructure` | infrastructure | Traefik, PostgreSQL, Redis, cert-manager issuers |
| `apps` | `kubernetes/apps` | default | Applications (portfolio, cv, game-2048, homer, uptime-kuma) |
| `monitoring` | `kubernetes/monitoring` | monitoring | Configuration Grafana |
| `argocd-config` | `kubernetes/argocd` | argocd | Les Applications ArgoCD elles-memes |

L'Application `argocd-config` est particulierement importante : elle gere les autres Applications ArgoCD. Cela signifie que les Applications sont elles-memes des objets Kubernetes geres par Git, ce qu'on appelle le pattern **App of Apps**.

**La politique de synchronisation** configuree sur toutes les Applications :

```yaml
syncPolicy:
  automated:
    prune: false     # Ne supprime PAS les ressources supprimees dans Git
    selfHeal: true   # Corrige automatiquement les drifts
  syncOptions:
    - CreateNamespace=true  # Cree le namespace si il n'existe pas
```

`prune: false` est une mesure de securite : si un fichier est accidentellement supprime dans Git, ArgoCD ne supprimera pas la ressource correspondante dans le cluster. Il faut activer le pruning explicitement quand on veut supprimer une ressource.

**L'acces au depot Git** : ArgoCD se connecte au depot GitHub `zoom26042604/homelab` via SSH. La cle privee SSH est stockee dans un Secret Kubernetes dans le namespace `argocd`, labellise avec `argocd.argoproj.io/secret-type: repository`. La cle publique correspondante est enregistree dans les parametres SSH du compte GitHub (`github.com/settings/keys`).

### Le cycle de deploiement avec ArgoCD

```
1. Modification d'un manifest YAML localement
      |
      v
2. git push origin main
      |
      v
3. GitHub recoit le commit
      |
      v
4. ArgoCD poll GitHub toutes les 3 minutes
   (ou peut etre declenche via webhook)
      |
      v
5. ArgoCD detecte un diff entre Git et le cluster
      |
      v
6. ArgoCD applique les changements (kubectl apply equivalent)
      |
      v
7. Kubernetes execute les changements
   (nouveau pod, mise a jour de ConfigMap, etc.)
```

---

## 14. Les applications deployees

### Portfolio Azrael (nathan-ferre.fr)

**Namespace** : `nathan-ferre`
**Image Docker** : `nathan-ferrefr-azrael:latest`
**Domaines** : `nathan-ferre.fr` et `www.nathan-ferre.fr`
**Port** : 3000 (application Node.js)
**Type** : Portfolio personnel, application Next.js

L'image est construite localement sur le serveur (d'ou `imagePullPolicy: IfNotPresent` : Kubernetes n'essaie pas de la telecharger depuis un registry distant). Le code source se trouve dans `/srv/nathan-ferre.fr/azrael/`.

### CV (cv.nathan-ferre.fr)

**Namespace** : `nathan-ferre`
**Image Docker** : `nathan-ferrefr-cv:latest`
**Domaine** : `cv.nathan-ferre.fr`
**Port** : 3000
**Type** : CV en ligne, application Next.js

Meme logique que le portfolio, image construite localement depuis `/srv/nathan-ferre.fr/cv/`.

### Game 2048 (2048.zoom2604.dev)

**Namespace** : `zoom2604`
**Image Docker** : `game-2048:latest`
**Domaine** : `2048.zoom2604.dev`
**Port** : 3000
**Type** : Jeu web avec persistance
**Stockage** : Volume de 2 Go monte sur `/app/data`, base de donnees SQLite a `file:/app/data/game2048.db`

Cette application a de la persistance locale via SQLite (contrairement aux deux autres qui sont stateless). Un PVC de 2 Go lui est dedie.

### Homer (zoom2604.dev)

**Namespace** : `infrastructure`
**Image Docker** : `b4bz/homer:latest`
**Domaines** : `zoom2604.dev` et `www.zoom2604.dev`
**Port** : 8080
**Type** : Dashboard statique

### Uptime Kuma (uptime.zoom2604.dev)

**Namespace** : `monitoring`
**Image Docker** : `louislam/uptime-kuma:1`
**Domaine** : `uptime.zoom2604.dev`
**Port** : 3001
**Stockage** : Volume de 1 Go pour la base de donnees SQLite

---

## 15. Le stockage persistant

### La problematique du stockage dans Kubernetes

Par defaut, les donnees ecrites a l'interieur d'un conteneur sont ephemeres : si le conteneur est detruit et recrée, toutes les donnees sont perdues. Pour les bases de donnees et les applications avec etat, c'est inacceptable.

Kubernetes resout ce probleme via les **PersistentVolumes (PV)** et les **PersistentVolumeClaims (PVC)**. Un PVC est une demande de stockage faite par une application. Un PV est le volume physique alloue sur un noeud.

### local-path-provisioner

Dans ce homelab, le provisioner de stockage utilise est `local-path`, inclus par defaut dans K3s. Il alloue du stockage directement sur le disque du noeud, dans le repertoire `/var/lib/rancher/k3s/storage/`.

La limitation principale est que ce stockage est **lie a un noeud specifique**. Si un pod est deplace sur un autre noeud (ce qui ne peut pas arriver dans un cluster single-node), il ne pourra pas acceder a son volume. Pour un homelab single-node, c'est acceptable.

### Inventaire des volumes

| PVC | Namespace | Taille | Application |
|-----|-----------|--------|-------------|
| `traefik-pvc` | infrastructure | 1 Go | Certificats ACME (acme.json) |
| `postgres-data-postgres-0` | infrastructure | 20 Go | Donnees PostgreSQL |
| `redis-data-redis-0` | infrastructure | 5 Go | Donnees Redis |
| `game2048-pvc` | zoom2604 | 2 Go | Base SQLite du jeu |
| `uptime-kuma-pvc` | monitoring | 1 Go | Base SQLite Uptime Kuma |

**Total stockage utilise pour la persistance** : 29 Go sur 99 Go disponibles.

---

## 16. Le flux d'une requete HTTP

Voici le chemin complet d'une requete d'un utilisateur qui visite `cv.nathan-ferre.fr` :

```
1. L'utilisateur tape cv.nathan-ferre.fr dans son navigateur

2. DNS : cv.nathan-ferre.fr -> 51.91.76.23 (IP du VPS)

3. Le navigateur envoie une requete HTTPS sur 51.91.76.23:443

4. Traefik recoit la requete (hostNetwork: true, il ecoute directement
   sur le port 443 de la machine)

5. Traefik consulte ses regles de routage :
   - IngressRoute cv dans le namespace nathan-ferre
   - Regle : Host(`cv.nathan-ferre.fr`)
   - Service cible : cv:80 dans le namespace nathan-ferre

6. Traefik etablit la connexion TLS avec le certificat SSL
   de cv.nathan-ferre.fr (gere par cert-manager)

7. Traefik fait un proxy vers le Service Kubernetes "cv"
   dans le namespace "nathan-ferre" sur le port 80

8. Le Service "cv" route vers le Pod "cv-xxxxx"
   sur le port 3000 (le port reel de l'application)

9. L'application Node.js dans le pod genere la reponse HTML

10. La reponse remonte : Pod -> Service -> Traefik -> Utilisateur
```

---

## 17. GitOps : comment deployer une modification

### Modifier une application existante

Exemple : changer l'image du portfolio vers une nouvelle version.

```bash
# 1. Modifier le manifest sur le serveur
nano /srv/homelab/kubernetes/apps/portfolio-azrael.yaml
# Changer : image: nathan-ferrefr-azrael:latest
# En :      image: nathan-ferrefr-azrael:v2.0

# 2. Commiter et pousser
cd /srv/homelab
git add kubernetes/apps/portfolio-azrael.yaml
git commit -m "feat: update portfolio to v2.0"
git push origin main

# 3. ArgoCD detecte le changement dans les 3 minutes
# et applique automatiquement le nouveau manifest

# 4. Kubernetes effectue un rolling update :
# - Lance un nouveau pod avec la nouvelle image
# - Attend qu'il soit Ready
# - Supprime l'ancien pod
```

### Ajouter une nouvelle application

```bash
# 1. Creer le manifest YAML
cat > /srv/homelab/kubernetes/apps/ma-nouvelle-app.yaml << 'EOF'
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ma-nouvelle-app
  namespace: zoom2604
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ma-nouvelle-app
  template:
    metadata:
      labels:
        app: ma-nouvelle-app
    spec:
      containers:
      - name: app
        image: mon-image:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "200Mi"
            cpu: "100m"
          limits:
            memory: "400Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: ma-nouvelle-app
  namespace: zoom2604
spec:
  selector:
    app: ma-nouvelle-app
  ports:
  - port: 80
    targetPort: 3000
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: ma-nouvelle-app
  namespace: zoom2604
spec:
  entryPoints:
    - websecure
  routes:
    - match: Host(`app.zoom2604.dev`)
      kind: Rule
      services:
        - name: ma-nouvelle-app
          port: 80
  tls:
    certResolver: letsencrypt
EOF

# 2. Commiter et pousser
git add kubernetes/apps/ma-nouvelle-app.yaml
git commit -m "feat: add ma-nouvelle-app"
git push origin main

# 3. ArgoCD applique automatiquement
```

---

## 18. URLs et acces

### Applications publiques

| URL | Application | Namespace |
|-----|-------------|-----------|
| `https://nathan-ferre.fr` | Portfolio Azrael | nathan-ferre |
| `https://www.nathan-ferre.fr` | Portfolio Azrael | nathan-ferre |
| `https://cv.nathan-ferre.fr` | CV | nathan-ferre |
| `https://2048.zoom2604.dev` | Game 2048 | zoom2604 |
| `https://zoom2604.dev` | Homer Dashboard | infrastructure |
| `https://www.zoom2604.dev` | Homer Dashboard | infrastructure |

### Outils d'administration

| URL | Outil | Acces |
|-----|-------|-------|
| `https://argocd.zoom2604.dev` | ArgoCD UI | Identifiants admin ArgoCD |
| `https://grafana.zoom2604.dev` | Grafana | Identifiants Grafana |
| `https://uptime.zoom2604.dev` | Uptime Kuma | Identifiants Uptime Kuma |
| `https://traefik.zoom2604.dev` | Traefik Dashboard | HTTP Basic Auth |

### Services internes (non exposes sur internet)

| Service | Adresse interne | Port |
|---------|-----------------|------|
| PostgreSQL | `postgres.infrastructure.svc.cluster.local` | 5432 |
| Redis | `redis.infrastructure.svc.cluster.local` | 6379 |
| Prometheus | `prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local` | 9090 |

---

## 19. Structure du depot Git

```
homelab/
├── README.md                          # Vue d'ensemble du projet
├── doc/
│   └── INFRASTRUCTURE.md             # Ce document
├── kubernetes/
│   ├── base/
│   │   └── namespaces.yaml           # Definition des namespaces
│   ├── infrastructure/
│   │   ├── traefik.yaml              # Reverse proxy (RBAC, ConfigMap, Deployment, Services, Middlewares)
│   │   ├── traefik-ingressclass.yaml # IngressClass par defaut
│   │   ├── traefik-acme-middleware.yaml # Middleware pour les challenges ACME
│   │   ├── postgres.yaml             # Base de donnees (StatefulSet, Service, PVC)
│   │   ├── redis.yaml                # Cache (StatefulSet, Service, ConfigMap)
│   │   └── cert-manager-issuer.yaml  # ClusterIssuers Let's Encrypt
│   ├── apps/
│   │   ├── portfolio-azrael.yaml     # Portfolio (Deployment, Service, Ingress)
│   │   ├── portfolio-ingressroute.yaml # IngressRoute Traefik
│   │   ├── cv.yaml                   # CV (Deployment, Service, Ingress)
│   │   ├── cv-ingressroute.yaml      # IngressRoute Traefik
│   │   ├── game-2048.yaml            # Jeu (Deployment, Service, Ingress, PVC)
│   │   ├── game2048-ingressroute.yaml # IngressRoute Traefik
│   │   ├── homer.yaml                # Dashboard (Deployment, ConfigMap, Service, Ingress)
│   │   ├── homer-ingressroute.yaml   # IngressRoute Traefik
│   │   ├── uptime-kuma.yaml          # Supervision (Deployment, PVC, Service, Ingress)
│   │   ├── uptime-kuma-ingressroute.yaml # IngressRoute Traefik
│   │   ├── grafana-ingress.yaml      # Ingress Grafana
│   │   └── grafana-ingressroute.yaml # IngressRoute Grafana
│   ├── monitoring/
│   │   └── grafana-config.yaml       # ConfigMaps Grafana (datasources, dashboards)
│   ├── argocd/
│   │   ├── argocd-ingressroute.yaml  # Exposition ArgoCD via Traefik
│   │   ├── app-base.yaml             # ArgoCD Application -> kubernetes/base
│   │   ├── app-infrastructure.yaml   # ArgoCD Application -> kubernetes/infrastructure
│   │   ├── app-apps.yaml             # ArgoCD Application -> kubernetes/apps
│   │   ├── app-monitoring.yaml       # ArgoCD Application -> kubernetes/monitoring
│   │   └── app-argocd.yaml           # ArgoCD Application -> kubernetes/argocd (self)
│   └── scripts/
│       ├── check.sh                  # Verification post-installation
│       ├── health.sh                 # Sante du cluster
│       ├── status.sh                 # Status de toutes les ressources
│       ├── logs.sh                   # Acces aux logs
│       ├── restart.sh                # Redemarrage d'un deploiement
│       ├── rebuild.sh                # Rebuild d'une image locale et rollout
│       ├── backup.sh                 # Sauvegarde des donnees
│       ├── cleanup.sh                # Nettoyage des ressources
│       ├── cleanup-docker.sh         # Nettoyage des images Docker locales
│       ├── install.sh                # Script d'installation complet
│       ├── health-check.sh           # Verification de sante approfondie
│       └── generate-wireguard-clients.sh # Generation de configs VPN
```

---

*Documentation realisee le 28 mars 2026. Version du cluster : K3s v1.34.3+k3s3.*
