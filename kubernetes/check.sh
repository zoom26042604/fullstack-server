#!/bin/bash
# ================================
# Test script installation
# Vérifie que tous les fichiers sont présents
# ================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🧪 Vérification de l'installation..."
echo ""

ERRORS=0

# Check scripts
echo "📁 Vérification des scripts..."
SCRIPTS=(
    "scripts/install-k3s.sh"
    "scripts/setup-namespaces.sh"
    "scripts/create-secrets.sh"
    "scripts/install-cert-manager.sh"
    "scripts/install-monitoring.sh"
    "scripts/install-loki.sh"
    "scripts/build-images.sh"
    "scripts/import-images-to-k3s.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ] && [ -x "$script" ]; then
        echo "  ✓ $script"
    else
        echo "  ✗ $script (manquant ou non exécutable)"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check manifests
echo ""
echo "📦 Vérification des manifests..."
MANIFESTS=(
    "infrastructure/postgres.yaml"
    "infrastructure/redis.yaml"
    "infrastructure/traefik.yaml"
    "infrastructure/cert-manager-issuer.yaml"
    "apps/portfolio-azrael.yaml"
    "apps/cv.yaml"
    "apps/game-2048.yaml"
    "apps/admin-panel.yaml"
    "base/namespaces.yaml"
)

for manifest in "${MANIFESTS[@]}"; do
    if [ -f "$manifest" ]; then
        echo "  ✓ $manifest"
    else
        echo "  ✗ $manifest (manquant)"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check .env file
echo ""
echo "⚙️  Vérification de la configuration..."
if [ -f "../infrastructure/.env" ]; then
    echo "  ✓ infrastructure/.env"
else
    echo "  ✗ infrastructure/.env (manquant)"
    echo "     Créez ce fichier depuis infrastructure/.env.example"
    ERRORS=$((ERRORS + 1))
fi

# Check documentation
echo ""
echo "📚 Vérification de la documentation..."
DOCS=(
    "README.md"
    "MIGRATION_GUIDE.md"
    "QUICKSTART.md"
)

for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        echo "  ✓ $doc"
    else
        echo "  ✗ $doc (manquant)"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check main installer
echo ""
echo "🚀 Vérification du script principal..."
if [ -f "install.sh" ] && [ -x "install.sh" ]; then
    echo "  ✓ install.sh"
else
    echo "  ✗ install.sh (manquant ou non exécutable)"
    ERRORS=$((ERRORS + 1))
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ]; then
    echo "✅ Tous les fichiers sont présents !"
    echo ""
    echo "Vous pouvez lancer l'installation :"
    echo "  sudo ./install.sh"
    exit 0
else
    echo "❌ $ERRORS erreur(s) détectée(s)"
    echo ""
    echo "Veuillez corriger les problèmes avant de continuer."
    exit 1
fi
