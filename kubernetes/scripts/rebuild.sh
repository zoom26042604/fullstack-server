#!/bin/bash
# Rebuild and redeploy an application

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <app-name>"
    echo ""
    echo "Available apps:"
    echo "  cv              - CV (nathan-ferre.fr)"
    echo "  azrael          - Portfolio (nathan-ferre.fr)"
    echo "  game-2048       - Game 2048 (zoom2604.dev)"
    echo "  asteria-front   - Asteria frontend (asteria-jdr.fr)"
    echo "  asteria-back    - Asteria backend (api.asteria-jdr.fr)"
    exit 1
fi

APP=$1

case $APP in
    cv)
        echo "Building CV..."
        cd /srv/nathan-ferre.fr/cv
        docker build -t nathan-ferrefr-cv:latest .
        echo "Restarting deployment..."
        kubectl rollout restart deployment/cv -n nathan-ferre
        kubectl rollout status deployment/cv -n nathan-ferre
        echo "Done"
        ;;
    azrael)
        echo "Building Azrael portfolio..."
        cd /srv/nathan-ferre.fr/azrael
        docker build -t nathan-ferrefr-azrael:latest .
        echo "Restarting deployment..."
        kubectl rollout restart deployment/portfolio-azrael -n nathan-ferre
        kubectl rollout status deployment/portfolio-azrael -n nathan-ferre
        echo "Done"
        ;;
    game-2048)
        echo "Building Game 2048..."
        cd /srv/zoom2604.dev/game-2048
        docker build -t zoom2604dev-game-2048:latest .
        echo "Restarting deployment..."
        kubectl rollout restart deployment/game-2048 -n zoom2604
        kubectl rollout status deployment/game-2048 -n zoom2604
        echo "Done"
        ;;
    asteria-front)
        echo "Building Asteria frontend..."
        cd /srv/asteria-jdr.fr/asteria-front
        docker build -t asteria-jdr-front:latest .
        echo "Restarting deployment..."
        kubectl rollout restart deployment/asteria-front -n asteria-jdr
        kubectl rollout status deployment/asteria-front -n asteria-jdr
        echo "Done"
        ;;
    asteria-back)
        echo "Building Asteria backend..."
        cd /srv/asteria-jdr.fr/asteria-back
        docker build -t asteria-jdr-back:latest .
        echo "Restarting deployment..."
        kubectl rollout restart deployment/asteria-back -n asteria-jdr
        kubectl rollout status deployment/asteria-back -n asteria-jdr
        echo "Done"
        ;;
    *)
        echo "Error: Unknown app '$APP'"
        exit 1
        ;;
esac
