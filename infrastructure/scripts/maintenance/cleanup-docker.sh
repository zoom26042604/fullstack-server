#!/bin/bash

################################################################################
# Script: cleanup-docker.sh
# Description: Nettoie automatiquement Docker (build cache, images, volumes)
# Usage: ./cleanup-docker.sh [--dry-run]
################################################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
LOG_DIR="/srv/fullstack-server/infrastructure/logs"
LOG_FILE="$LOG_DIR/docker-cleanup.log"
DRY_RUN=false

# Créer le dossier de logs s'il n'existe pas
mkdir -p "$LOG_DIR"

# Parser les arguments
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}Mode DRY-RUN activé${NC}"
fi

# Fonction de log
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🧹 Nettoyage Docker automatique${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

log "Début du nettoyage Docker"

# 1. État initial
echo -e "${YELLOW}📊 État initial:${NC}"
docker system df
echo ""

# Calculer l'espace utilisé avant
DISK_BEFORE=$(df / | tail -1 | awk '{print $3}')

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}⚠️  Mode simulation - aucune suppression réelle${NC}"
    echo ""
    
    echo -e "${BLUE}🔍 Build Cache à supprimer:${NC}"
    docker builder prune -a --filter "until=24h" --dry-run
    echo ""
    
    echo -e "${BLUE}🔍 Images à supprimer:${NC}"
    docker image prune -a --filter "until=24h" --dry-run
    echo ""
    
    echo -e "${BLUE}🔍 Volumes à supprimer:${NC}"
    docker volume prune --filter "until=24h" --dry-run
    echo ""
    
    log "Nettoyage simulé (dry-run)"
else
    # 2. Nettoyer le Build Cache (>24h)
    echo -e "${GREEN}🗑️  Suppression Build Cache (>24h)...${NC}"
    CACHE_DELETED=$(docker builder prune -af --filter "until=24h" 2>&1 | grep "Total" | awk '{print $3" "$4}')
    log "Build Cache supprimé: $CACHE_DELETED"
    echo ""
    
    # 3. Nettoyer les images non utilisées (>24h)
    echo -e "${GREEN}🗑️  Suppression images non utilisées (>24h)...${NC}"
    IMAGES_DELETED=$(docker image prune -af --filter "until=24h" 2>&1 | grep "Total" | awk '{print $4}')
    log "Images supprimées: $IMAGES_DELETED"
    echo ""
    
    # 4. Nettoyer les volumes orphelins (>24h)
    echo -e "${GREEN}🗑️  Suppression volumes orphelins (>24h)...${NC}"
    VOLUMES_DELETED=$(docker volume prune -f --filter "until=24h" 2>&1 | grep "Total" | awk '{print $4}')
    log "Volumes supprimés: $VOLUMES_DELETED"
    echo ""
    
    # 5. Nettoyer les réseaux non utilisés
    echo -e "${GREEN}🗑️  Suppression réseaux non utilisés...${NC}"
    docker network prune -f > /dev/null 2>&1 || true
    log "Réseaux nettoyés"
    echo ""
    
    # 6. Nettoyer les conteneurs arrêtés (>7 jours)
    echo -e "${GREEN}🗑️  Suppression conteneurs arrêtés (>7j)...${NC}"
    docker container prune -f --filter "until=168h" > /dev/null 2>&1 || true
    log "Conteneurs arrêtés supprimés"
    echo ""
fi

# 7. État final
echo -e "${YELLOW}📊 État final:${NC}"
docker system df
echo ""

# Calculer l'espace libéré
DISK_AFTER=$(df / | tail -1 | awk '{print $3}')
DISK_FREE=$((DISK_BEFORE - DISK_AFTER))
DISK_FREE_MB=$((DISK_FREE / 1024))

if [ "$DRY_RUN" = false ]; then
    echo -e "${GREEN}✅ Nettoyage terminé !${NC}"
    echo -e "${GREEN}💾 Espace libéré: ${DISK_FREE_MB} MB${NC}"
    log "Nettoyage terminé - Espace libéré: ${DISK_FREE_MB} MB"
else
    echo -e "${YELLOW}ℹ️  Simulation terminée${NC}"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
