#!/bin/bash
# Déploiement Next.js
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; NC='\033[0m'
echo -e "${BLUE}🚀 Déploiement Application Next.js${NC}"
echo ""
read -p "Nom de domaine: " DOMAIN
read -p "Nom de l'application: " APP_NAME
read -p "Port interne [3000]: " PORT
PORT=${PORT:-3000}
read -p "PostgreSQL (y/n): " USE_PG
read -p "Redis (y/n): " USE_REDIS
APP_DIR="/srv/$DOMAIN/$APP_NAME"
mkdir -p "$APP_DIR"
cd "$APP_DIR"
# Créer package.json
cat > package.json << EOF
{
  "name": "$APP_NAME",
  "version": "1.0.0",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start -p $PORT"
  },
  "dependencies": {
    "next": "latest",
    "react": "latest",
    "react-dom": "latest"
  }
}
EOF
# Créer docker-compose.yml
cat > docker-compose.yml << EOFCOMPOSE
version: '3.9'
services:
  $APP_NAME:
    build: .
    container_name: $APP_NAME
    restart: unless-stopped
    networks:
      - app_network
    environment:
      - NODE_ENV=production
      - NEXTAUTH_URL=https://$DOMAIN/$APP_NAME
EOFCOMPOSE
[ "$USE_PG" = "y" ] && cat >> docker-compose.yml << EOFPG
      - DATABASE_URL=postgresql://postgres:\${POSTGRES_PASSWORD}@postgres:5432/$APP_NAME
EOFPG
[ "$USE_REDIS" = "y" ] && cat >> docker-compose.yml << EOFREDIS
      - REDIS_URL=redis://:\${REDIS_PASSWORD}@redis:6379
EOFREDIS
cat >> docker-compose.yml << EOFCOMPOSE2
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.$APP_NAME.rule=Host(\`$DOMAIN\`) && PathPrefix(\`/$APP_NAME\`)"
      - "traefik.http.routers.$APP_NAME.entrypoints=websecure"
      - "traefik.http.routers.$APP_NAME.tls.certresolver=letsencrypt"
      - "traefik.http.services.$APP_NAME.loadbalancer.server.port=$PORT"
      - "traefik.http.middlewares.${APP_NAME}-strip.stripprefix.prefixes=/$APP_NAME"
      - "traefik.http.routers.$APP_NAME.middlewares=${APP_NAME}-strip"
networks:
  app_network:
    external: true
EOFCOMPOSE2
# Créer Dockerfile
cat > Dockerfile << EOFDOCKER
FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE $PORT
CMD ["npm", "start"]
EOFDOCKER
# Créer next.config.ts
cat > next.config.ts << EOFNEXTCONF
export default {
  basePath: '/$APP_NAME',
  assetPrefix: '/$APP_NAME',
  output: 'standalone'
}
EOFNEXTCONF
# Créer structure Next.js de base
mkdir -p src/app
cat > src/app/page.tsx << EOFPAGE
export default function Home() {
  return <main><h1>$APP_NAME</h1><p>Déployé avec succès!</p></main>
}
EOFPAGE
echo -e "${GREEN}✓ Application créée dans $APP_DIR${NC}"
echo -e "${YELLOW}Déploiement...${NC}"
sudo docker-compose up -d --build
echo -e "${GREEN}✓ Déployé sur https://$DOMAIN/$APP_NAME${NC}"
