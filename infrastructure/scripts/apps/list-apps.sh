#!/bin/bash
# Lister toutes les applications
BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${BLUE}📱 Applications déployées:${NC}"
echo ""

for domain in /srv/*/; do
    domain_name=$(basename "$domain")
    if [[ "$domain_name" != "infrastructure" && "$domain_name" != "doc" && "$domain_name" != "fullstack-server" ]]; then
        echo -e "${GREEN}🌐 $domain_name${NC}"
        for app_dir in "$domain"/*/; do
            if [ -f "$app_dir/docker-compose.yml" ]; then
                app_name=$(basename "$app_dir")
                if sudo docker-compose -f "$app_dir/docker-compose.yml" ps 2>/dev/null | grep -q "Up"; then
                    echo -e "  ├─ $app_name ${GREEN}● Running${NC} - https://$domain_name/$app_name"
                else
                    echo -e "  ├─ $app_name ${YELLOW}○ Stopped${NC}"
                fi
            fi
        done
    fi
done
