#!/bin/bash
# Vérifier la configuration DNS
echo "🌐 Vérification DNS"
echo ""
if [ -f .env ]; then
    source .env
    echo "Domaine principal: $DOMAIN"
    echo ""
    for subdomain in traefik grafana; do
        echo -n "  $subdomain.$DOMAIN: "
        dig +short "$subdomain.$DOMAIN" A | head -1
    done
else
    echo "Fichier .env non trouvé"
fi
