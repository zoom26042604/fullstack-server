#!/bin/bash
# Déploiement site statique
echo "🚀 Déploiement Site Statique"
read -p "Domaine: " DOMAIN
read -p "App: " APP
APP_DIR="/srv/$DOMAIN/$APP"
mkdir -p "$APP_DIR/html"
cd "$APP_DIR"
cat > html/index.html << EOF
<!DOCTYPE html>
<html><head><title>$APP</title></head>
<body><h1>$APP</h1><p>Site statique déployé</p></body></html>
EOF
cat > docker-compose.yml << EOF
version: '3.9'
services:
  $APP:
    image: nginx:alpine
    container_name: $APP
    volumes:
      - ./html:/usr/share/nginx/html
    networks:
      - app_network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.$APP.rule=Host(\`$DOMAIN\`) && PathPrefix(\`/$APP\`)"
      - "traefik.http.routers.$APP.entrypoints=websecure"
      - "traefik.http.routers.$APP.tls.certresolver=letsencrypt"
networks:
  app_network:
    external: true
EOF
sudo docker-compose up -d
echo "✓ Déployé sur https://$DOMAIN/$APP"
