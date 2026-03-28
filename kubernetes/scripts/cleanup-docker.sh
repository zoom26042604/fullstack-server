#!/bin/bash

# Script de nettoyage des anciennes images Docker
# Supprime les images Docker qui ne sont plus utilisées après la migration vers Kubernetes

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   NETTOYAGE DES IMAGES DOCKER (OPTIONNEL)        ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${YELLOW}⚠️  Les images Docker sont maintenant dans K3s (containerd).${NC}"
echo -e "${YELLOW}    Vous pouvez supprimer les anciennes images Docker pour libérer de l'espace.${NC}"
echo ""

# Afficher l'espace disque utilisé par Docker
docker_size=$(sudo docker system df 2>/dev/null | grep "Images" | awk '{print $4}' || echo "0B")
echo -e "${BLUE}Espace utilisé par les images Docker: ${YELLOW}$docker_size${NC}"
echo ""

echo -e "${BLUE}Images Docker actuelles:${NC}"
sudo docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | head -20
echo ""

read -p "$(echo -e ${YELLOW}"Voulez-vous supprimer TOUTES les images Docker inutilisées ? (y/N): "${NC})" response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🗑️  Nettoyage en cours...${NC}"
    
    # Supprimer les containers arrêtés
    echo -e "${BLUE}Suppression des containers arrêtés...${NC}"
    sudo docker container prune -f
    
    # Supprimer les images non utilisées
    echo -e "${BLUE}Suppression des images non utilisées...${NC}"
    sudo docker image prune -a -f
    
    # Supprimer les volumes non utilisés
    echo -e "${BLUE}Suppression des volumes non utilisés...${NC}"
    sudo docker volume prune -f
    
    # Supprimer les réseaux non utilisés
    echo -e "${BLUE}Suppression des réseaux non utilisés...${NC}"
    sudo docker network prune -f
    
    # Afficher l'espace récupéré
    echo ""
    sudo docker system df
    
    echo ""
    echo -e "${GREEN}✓ Nettoyage terminé !${NC}"
else
    echo -e "${BLUE}Nettoyage annulé. Les images Docker sont conservées.${NC}"
    echo -e "${YELLOW}💡 Astuce: Vous pouvez les garder comme backup ou les supprimer plus tard avec:${NC}"
    echo -e "   ${BLUE}sudo docker system prune -a${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
