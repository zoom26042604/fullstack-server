# Configuration Cloudflare CDN

Guide pour configurer Cloudflare comme CDN pour les domaines.

## Prérequis

- Compte Cloudflare actif
- Accès aux DNS des domaines
- API Token Cloudflare (optionnel pour automatisation)

## Configuration DNS

### 1. Ajouter les domaines à Cloudflare

Domaines à configurer :
- `zoom2604.dev`
- `nathan-ferre.fr`

### 2. Configuration DNS dans Cloudflare

```dns
# zoom2604.dev
Type: A    Name: @              Value: 51.91.76.23    Proxy: ✓ (Orange Cloud)
Type: A    Name: portainer      Value: 51.91.76.23    Proxy: ✓
Type: A    Name: traefik        Value: 51.91.76.23    Proxy: ✓

# nathan-ferre.fr  
Type: A    Name: @              Value: 51.91.76.23    Proxy: ✓
Type: A    Name: www            Value: 51.91.76.23    Proxy: ✓
```

## Paramètres Cloudflare recommandés

### SSL/TLS
- **Mode**: Full (Strict)
- **Always Use HTTPS**: ON
- **Automatic HTTPS Rewrites**: ON
- **Minimum TLS Version**: 1.2

### Speed
- **Auto Minify**: ON (CSS, JS, HTML)
- **Brotli**: ON
- **Early Hints**: ON
- **HTTP/2**: ON
- **HTTP/3 (with QUIC)**: ON

### Caching
- **Caching Level**: Standard
- **Browser Cache TTL**: 4 hours
- **Always Online**: ON

### Security
- **Security Level**: Medium
- **Challenge Passage**: 30 minutes
- **Browser Integrity Check**: ON
- **Privacy Pass Support**: ON

### Firewall
Créer des règles WAF :

```
Rule 1: Rate Limiting
- If: Incoming Requests > 100/minute
- Then: Challenge

Rule 2: Block Bad Bots
- If: Known Bot
- Then: Block

Rule 3: Geographic Restriction (optionnel)
- If: Country not in [FR, EU, US]
- Then: Challenge
```

### Page Rules

```
Rule 1: Static Assets Caching
- URL: *zoom2604.dev/assets/*
- Cache Level: Cache Everything
- Edge Cache TTL: 1 month

Rule 2: Portfolio Caching
- URL: *nathan-ferre.fr/*
- Cache Level: Cache Everything
- Edge Cache TTL: 1 day
- Browser Cache TTL: 1 day
```

## Validation

Après configuration, vérifier :

```bash
# Vérifier résolution DNS
dig zoom2604.dev
dig nathan-ferre.fr

# Vérifier que le trafic passe par Cloudflare
curl -I https://zoom2604.dev | grep -i cf-

# Test performance
curl -w "@curl-format.txt" -o /dev/null -s https://zoom2604.dev
```

## Avantages

- **CDN Global**: 200+ data centers
- **DDoS Protection**: Automatique
- **WAF**: Web Application Firewall
- **Analytics**: Statistiques détaillées
- **Cache**: Réduction charge serveur ~60%
- **SSL**: Certificats gratuits

## Coûts

- **Plan Free**: Suffisant pour débuter
  - Bande passante illimitée
  - SSL gratuit
  - CDN global
  - DDoS protection basique
  
- **Plan Pro** ($20/mois): Recommandé pour production
  - WAF avancé
  - Image optimization
  - Mobile optimization
  - Support prioritaire

## Migration

1. Vérifier que tous les services fonctionnent sans Cloudflare
2. Ajouter le domaine à Cloudflare
3. Copier les DNS records existants
4. Activer le proxy (Orange Cloud)
5. Attendre propagation DNS (24-48h)
6. Vérifier fonctionnement
7. Optimiser cache rules

## Rollback

En cas de problème :
1. Désactiver le proxy Cloudflare (Grey Cloud)
2. Attendre propagation DNS
3. Revenir aux DNS précédents si nécessaire
