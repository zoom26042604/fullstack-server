#!/bin/bash
# Configurer le swap
echo "💾 Configuration du Swap"
SWAP_SIZE="4G"
SWAP_FILE="/swapfile"
if [ -f "$SWAP_FILE" ]; then
    echo "Swap déjà configuré"
    swapon --show
    exit 0
fi
echo "Création du swap de $SWAP_SIZE..."
sudo fallocate -l $SWAP_SIZE $SWAP_FILE
sudo chmod 600 $SWAP_FILE
sudo mkswap $SWAP_FILE
sudo swapon $SWAP_FILE
echo "$SWAP_FILE none swap sw 0 0" | sudo tee -a /etc/fstab
echo "✓ Swap configuré"
swapon --show
