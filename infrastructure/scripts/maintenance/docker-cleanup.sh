#!/bin/bash
# Nettoyage Docker
echo "🧹 Nettoyage Docker"
echo ""
echo "Espace avant:"
sudo docker system df
echo ""
read -p "Nettoyer les images/conteneurs inutilisés? (y/n): " CONFIRM
if [ "$CONFIRM" = "y" ]; then
    sudo docker system prune -f
    echo ""
    echo "Espace après:"
    sudo docker system df
else
    echo "Annulé"
fi
