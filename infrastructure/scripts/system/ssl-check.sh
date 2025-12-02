#!/bin/bash
# Vérification certificats SSL
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
echo -e "${BLUE}🔒 Vérification Certificats SSL${NC}"
echo ""
DOMAINS=$(sudo docker exec traefik cat /acme/acme.json 2>/dev/null | grep -o '"Main":"[^"]*"' | cut -d'"' -f4 | sort -u)
if [ -z "$DOMAINS" ]; then
    echo "Aucun certificat trouvé"
    exit 0
fi
for domain in $DOMAINS; do
    EXPIRY=$(echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
    if [ -n "$EXPIRY" ]; then
        EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
        NOW_EPOCH=$(date +%s)
        DAYS_LEFT=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))
        if [ $DAYS_LEFT -lt 7 ]; then
            echo -e "${RED}✗ $domain: expire dans $DAYS_LEFT jours${NC}"
        elif [ $DAYS_LEFT -lt 30 ]; then
            echo -e "${YELLOW}⚠ $domain: expire dans $DAYS_LEFT jours${NC}"
        else
            echo -e "${GREEN}✓ $domain: expire dans $DAYS_LEFT jours${NC}"
        fi
    fi
done
