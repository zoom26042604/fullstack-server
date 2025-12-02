#!/bin/bash
# Analyse espace disque
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
echo -e "${BLUE}💿 Analyse Espace Disque${NC}"
echo ""
echo "Partitions:"
df -h | awk 'NR==1 {print}; /^\/dev\// {
    usage = int($5);
    if (usage >= 90) color = "\033[0;31m";
    else if (usage >= 75) color = "\033[1;33m";
    else color = "\033[0;32m";
    printf "%s%s\033[0m\n", color, $0
}'
echo ""
echo "Top 10 dossiers volumineux dans /srv:"
du -sh /srv/*/ 2>/dev/null | sort -rh | head -10
echo ""
echo "Docker volumes:"
sudo docker system df
