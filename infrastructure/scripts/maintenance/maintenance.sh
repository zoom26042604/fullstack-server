#!/bin/bash
# Mode maintenance
echo "🔧 Mode Maintenance"
echo ""
echo "1) Activer le mode maintenance"
echo "2) Désactiver le mode maintenance"
read -p "Choix: " CHOICE
case $CHOICE in
    1)
        echo "Mode maintenance activé (TODO: implémenter page maintenance)"
        ;;
    2)
        echo "Mode maintenance désactivé"
        ;;
    *)
        echo "Choix invalide"
        ;;
esac
