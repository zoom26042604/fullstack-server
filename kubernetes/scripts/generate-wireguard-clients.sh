#!/bin/bash
# Script de génération de configs clients WireGuard

set -e

SERVER_PUBLIC=$(sudo cat /etc/wireguard/server_public.key)
SERVER_IP="51.91.76.23"
ENDPOINT_PORT="51820"

# Créer le répertoire clients
sudo mkdir -p /etc/wireguard/clients

echo "🔧 Génération des configs clients WireGuard..."
echo ""

# Fonction pour créer un client
create_client() {
    local CLIENT_NAME=$1
    local CLIENT_IP=$2
    
    # Générer les clés
    CLIENT_PRIVATE=$(wg genkey)
    CLIENT_PUBLIC=$(echo "$CLIENT_PRIVATE" | wg pubkey)
    
    # Sauvegarder les clés
    echo "$CLIENT_PRIVATE" | sudo tee /etc/wireguard/clients/${CLIENT_NAME}_private.key > /dev/null
    echo "$CLIENT_PUBLIC" | sudo tee /etc/wireguard/clients/${CLIENT_NAME}_public.key > /dev/null
    
    # Créer le fichier de config
    cat <<EOF | sudo tee /etc/wireguard/clients/${CLIENT_NAME}.conf > /dev/null
[Interface]
# Client WireGuard: ${CLIENT_NAME}
PrivateKey = $CLIENT_PRIVATE
Address = $CLIENT_IP/32
DNS = 1.1.1.1

[Peer]
# Serveur zoom2604.dev
PublicKey = $SERVER_PUBLIC
Endpoint = $SERVER_IP:$ENDPOINT_PORT
AllowedIPs = 10.8.0.0/24, 10.42.0.0/16
PersistentKeepalive = 25
EOF
    
    # Ajouter le peer au serveur
    cat <<EOF | sudo tee -a /etc/wireguard/wg0.conf > /dev/null

[Peer]
# Client: ${CLIENT_NAME}
PublicKey = $CLIENT_PUBLIC
AllowedIPs = $CLIENT_IP/32
EOF
    
    # Générer le QR code
    echo "📱 QR Code pour ${CLIENT_NAME}:"
    sudo cat /etc/wireguard/clients/${CLIENT_NAME}.conf | qrencode -t ansiutf8
    echo ""
    echo "📄 Config ${CLIENT_NAME} sauvegardée: /etc/wireguard/clients/${CLIENT_NAME}.conf"
    echo "   IP: $CLIENT_IP"
    echo ""
}

# Créer les clients
create_client "laptop" "10.8.0.2"
create_client "phone" "10.8.0.3"

echo "✅ Configs clients créées !"
echo ""
echo "⚠️  IMPORTANT:"
echo "   - WireGuard N'EST PAS démarré (SSH reste accessible)"
echo "   - Scanne les QR codes ci-dessus avec l'app WireGuard"
echo "   - Pour démarrer: sudo systemctl start wg-quick@wg0"
echo "   - Pour ouvrir le port: sudo ufw allow 51820/udp"
