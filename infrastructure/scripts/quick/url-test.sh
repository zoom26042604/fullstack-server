#!/bin/bash
# Tester une URL
BLUE='\033[0;34m'; GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
echo -e "${BLUE}🌐 Test d'URL${NC}"
echo ""
read -p "URL à tester: " URL
echo ""
echo "Test en cours..."
HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" "$URL")
RESPONSE_TIME=$(curl -o /dev/null -s -w "%{time_total}" "$URL")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ OK${NC}"
    echo "  Status: $HTTP_CODE"
    echo "  Temps de réponse: ${RESPONSE_TIME}s"
else
    echo -e "${RED}✗ Erreur${NC}"
    echo "  Status: $HTTP_CODE"
fi
