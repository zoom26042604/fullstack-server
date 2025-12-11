# Trivy Vulnerability Scanning

Guide pour l'utilisation de Trivy pour scanner les vulnérabilités.

## Installation

Trivy est installé automatiquement lors de la première exécution du script.

Ou installation manuelle :

```bash
sudo apt-get install -y wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | \
  sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install -y trivy
```

## Utilisation

### Scan automatique (tous les conteneurs)

```bash
/srv/fullstack-server/infrastructure/scripts/maintenance/trivy-scan.sh
```

### Scan manuel d'une image

```bash
# Scan avec sévérité critique uniquement
trivy image --severity CRITICAL nginx:latest

# Scan complet
trivy image --severity CRITICAL,HIGH,MEDIUM,LOW traefik:v3.1

# Format JSON pour automatisation
trivy image --format json -o results.json postgres:16-alpine

# Ignorer non fixés
trivy image --ignore-unfixed redis:7-alpine
```

### Scan du filesystem

```bash
# Scan d'un répertoire
trivy fs /srv/nathan-ferre.fr/azrael

# Scan avec template
trivy fs --format template --template "@contrib/html.tpl" -o report.html ./
```

## Scan automatique

Ajouter au cron pour scan hebdomadaire :

```bash
# Chaque dimanche à 3h du matin
0 3 * * 0 /srv/fullstack-server/infrastructure/scripts/maintenance/trivy-scan.sh >> /var/log/trivy/cron.log 2>&1
```

Configuration :

```bash
(sudo crontab -l 2>/dev/null; echo "0 3 * * 0 /srv/fullstack-server/infrastructure/scripts/maintenance/trivy-scan.sh >> /var/log/trivy/cron.log 2>&1") | sudo crontab -
```

## Interprétation des résultats

### Niveaux de sévérité

- **CRITICAL**: Patch immédiat requis
- **HIGH**: Corriger dans les 7 jours
- **MEDIUM**: Corriger dans le mois
- **LOW**: Optionnel, suivant ressources

### Actions recommandées

```bash
# Si vulnérabilités CRITICAL détectées:
1. Vérifier si update image disponible
   docker pull <image>:latest
   
2. Redéployer avec nouvelle version
   cd /srv/fullstack-server/infrastructure
   docker compose pull <service>
   docker compose up -d <service>

3. Vérifier après update
   trivy image <image>:latest
```

## Exemples de commandes utiles

```bash
# Liste toutes vulnérabilités d'un container
trivy image --severity CRITICAL,HIGH traefik:v3.1

# Scan avec exit code si vulnérabilités trouvées
trivy image --exit-code 1 --severity CRITICAL postgres:16-alpine

# Export CSV
trivy image --format json postgres:16-alpine | \
  jq -r '.Results[].Vulnerabilities[] | [.VulnerabilityID,.Severity,.PkgName,.InstalledVersion,.FixedVersion] | @csv'

# Scan de configuration Kubernetes/Docker Compose
trivy config docker-compose.yml
```

## Intégration CI/CD

### GitHub Actions

```yaml
name: Security Scan
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly
  push:
    branches: [main]

jobs:
  trivy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Run Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'nathan-ferre-portfolio:latest'
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
```

## Rapports

Les rapports sont sauvegardés dans `/var/log/trivy/` :

```bash
# Voir dernier scan
ls -lth /var/log/trivy/ | head -5

# Lire summary
cat /var/log/trivy/summary_*.txt | tail -1

# Rechercher vulnérabilités critiques
grep -r "CRITICAL" /var/log/trivy/ | tail -20
```

## Best Practices

1. **Scan régulier**: Hebdomadaire minimum
2. **Update images**: Utiliser tags spécifiques, pas `latest`
3. **Priorisation**: CRITICAL > HIGH > MEDIUM > LOW
4. **Documentation**: Noter les CVE ignorés volontairement
5. **Monitoring**: Alerter sur nouvelles vulnérabilités CRITICAL

## Vulnérabilités courantes

### False positives

Certaines CVE peuvent être "false positives" si :
- Le vecteur d'attaque ne s'applique pas
- La fonctionnalité vulnérable n'est pas utilisée
- La configuration mitige le risque

Documenter dans `.trivyignore` :

```bash
# .trivyignore
# CVE-2021-12345 - Not applicable, feature disabled
CVE-2021-12345

# CVE-2022-67890 - Fixed in next major release, low risk
CVE-2022-67890
```

### Images officielles recommandées

Privilégier :
- Images `alpine` (surface d'attaque réduite)
- Tags `X.Y` spécifiques (pas `latest`)
- Images officielles vérifiées

```yaml
# Bon
postgres:16-alpine

# Éviter  
postgres:latest
postgres
```

## Ressources

- **Documentation**: https://aquasecurity.github.io/trivy/
- **CVE Database**: https://cve.mitre.org/
- **Docker Security**: https://docs.docker.com/engine/security/
- **OWASP Top 10**: https://owasp.org/www-project-top-ten/

## Troubleshooting

### Trivy base de données obsolète

```bash
trivy image --download-db-only
trivy image --reset
```

### Scan très lent

```bash
# Utiliser cache
trivy image --cache-dir /tmp/trivy-cache <image>

# Scanner sans mise à jour DB
trivy image --skip-update <image>
```

### Erreurs réseau

```bash
# Utiliser miroir DB alternatif
trivy image --db-repository ghcr.io/aquasecurity/trivy-db <image>
```
