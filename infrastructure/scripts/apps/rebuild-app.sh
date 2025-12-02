#!/bin/bash
# Rebuild une application
YELLOW='\033[1;33m'; GREEN='\033[0;32m'; NC='\033[0m'
apps=()
for domain in /srv/*/; do
    domain_name=$(basename "$domain")
    if [[ "$domain_name" != "infrastructure" && "$domain_name" != "doc" && "$domain_name" != "fullstack-server" ]]; then
        for app_dir in "$domain"/*/; do
            [ -f "$app_dir/docker-compose.yml" ] && apps+=("$app_dir")
        done
    fi
done
[ ${#apps[@]} -eq 0 ] && echo -e "${YELLOW}Aucune application trouvée${NC}" && exit 1
echo "Sélectionnez une application:"
for i in "${!apps[@]}"; do
    echo "  $((i+1))) $(basename "$(dirname "${apps[$i]}")")/$(basename "${apps[$i]}")"
done
read -p "Choix: " choice
[[ $choice -ge 1 && $choice -le ${#apps[@]} ]] && selected="${apps[$((choice-1))]}" || exit 1
cd "$selected" && echo -e "${YELLOW}🔨 Rebuild...${NC}" && sudo docker-compose down && sudo docker-compose build --no-cache && sudo docker-compose up -d && echo -e "${GREEN}✓ Terminé${NC}"
