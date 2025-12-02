#!/bin/bash
# Déploiement Node.js/Express
echo "🚀 Déploiement Node.js API"
read -p "Domaine: " DOMAIN
read -p "App: " APP
read -p "Port [3000]: " PORT
PORT=${PORT:-3000}
APP_DIR="/srv/$DOMAIN/$APP"
mkdir -p "$APP_DIR"
cd "$APP_DIR"
cat > package.json << EOF
{"name":"$APP","version":"1.0.0","scripts":{"start":"node server.js"},"dependencies":{"express":"latest"}}
EOF
cat > server.js << EOF
const express = require('express');
const app = express();
app.get('*', (req, res) => res.json({app:'$APP',status:'running'}));
app.listen($PORT, () => console.log('Server running on $PORT'));
EOF
cat > Dockerfile << EOF
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE $PORT
CMD ["npm","start"]
EOF
cat > docker-compose.yml << EOF
version: '3.9'
services:
  $APP:
    build: .
    container_name: $APP
    networks:
      - app_network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.$APP.rule=Host(\`$DOMAIN\`) && PathPrefix(\`/$APP\`)"
      - "traefik.http.routers.$APP.entrypoints=websecure"
      - "traefik.http.routers.$APP.tls.certresolver=letsencrypt"
      - "traefik.http.services.$APP.loadbalancer.server.port=$PORT"
networks:
  app_network:
    external: true
EOF
sudo docker-compose up -d --build
echo "✓ Déployé sur https://$DOMAIN/$APP"
