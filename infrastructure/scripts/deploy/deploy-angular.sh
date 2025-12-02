#!/bin/bash
# Déploiement Angular
echo "🚀 Déploiement Angular"
read -p "Domaine: " DOMAIN
read -p "App: " APP
APP_DIR="/srv/$DOMAIN/$APP"
mkdir -p "$APP_DIR"
cd "$APP_DIR"
cat > docker-compose.yml << EOF
version: '3.9'
services:
  $APP:
    image: nginx:alpine
    container_name: $APP
    volumes:
      - ./dist:/usr/share/nginx/html
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
mkdir -p dist
echo "<h1>$APP - Angular</h1>" > dist/index.html
sudo docker-compose up -d
echo "✓ Déployé sur https://$DOMAIN/$APP"
