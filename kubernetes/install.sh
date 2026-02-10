#!/bin/bash
# ================================
# Homelab Kubernetes - Installation Automatique
# ================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}ℹ${NC}  $1"
}

log_success() {
    echo -e "${GREEN}✓${NC}  $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

log_error() {
    echo -e "${RED}✗${NC}  $1"
}

print_banner() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                                                ║${NC}"
    echo -e "${BLUE}║   🏠 Homelab Kubernetes Installation          ║${NC}"
    echo -e "${BLUE}║      K3s + Applications + Monitoring           ║${NC}"
    echo -e "${BLUE}║                                                ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

check_requirements() {
    print_step "Vérification des prérequis"
    
    # Check root
    if [ "$EUID" -ne 0 ]; then 
        log_error "Ce script doit être exécuté avec sudo"
        exit 1
    fi
    
    # Check system resources
    TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
    TOTAL_DISK=$(df -BG / | awk 'NR==2 {print $2}' | sed 's/G//')
    
    log_info "RAM disponible: ${TOTAL_RAM}GB"
    log_info "Disque disponible: ${TOTAL_DISK}GB"
    
    if [ "$TOTAL_RAM" -lt 8 ]; then
        log_warning "RAM insuffisante (${TOTAL_RAM}GB < 8GB recommandé)"
    else
        log_success "RAM suffisante: ${TOTAL_RAM}GB"
    fi
    
    if [ "$TOTAL_DISK" -lt 50 ]; then
        log_warning "Disque insuffisant (${TOTAL_DISK}GB < 50GB recommandé)"
    else
        log_success "Disque suffisant: ${TOTAL_DISK}GB"
    fi
    
    # Check if Docker is installed
    if command -v docker &> /dev/null; then
        log_success "Docker installé"
    else
        log_warning "Docker n'est pas installé (requis pour builder les images)"
    fi
    
    # Check if kubectl is already installed
    if command -v kubectl &> /dev/null; then
        log_warning "kubectl déjà installé"
    fi
}

install_k3s() {
    print_step "Phase 1: Installation K3s"
    
    if systemctl is-active --quiet k3s; then
        log_warning "K3s est déjà installé et actif"
        read -p "Voulez-vous réinstaller K3s? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation K3s ignorée"
            return
        fi
    fi
    
    cd "$(dirname "$0")"
    chmod +x scripts/install-k3s.sh
    ./scripts/install-k3s.sh
    
    log_success "K3s installé avec succès"
    sleep 5
}

setup_namespaces() {
    print_step "Phase 2: Configuration des namespaces"
    
    cd "$(dirname "$0")"
    chmod +x scripts/setup-namespaces.sh
    ./scripts/setup-namespaces.sh
    
    log_success "Namespaces créés"
}

create_secrets() {
    print_step "Phase 3: Création des secrets Kubernetes"
    
    if [ ! -f "../infrastructure/.env" ]; then
        log_error "Fichier .env non trouvé dans infrastructure/"
        log_info "Veuillez créer le fichier .env avant de continuer"
        exit 1
    fi
    
    cd "$(dirname "$0")"
    chmod +x scripts/create-secrets.sh
    ./scripts/create-secrets.sh
    
    log_success "Secrets créés"
}

install_cert_manager() {
    print_step "Phase 4: Installation cert-manager (SSL)"
    
    cd "$(dirname "$0")"
    chmod +x scripts/install-cert-manager.sh
    ./scripts/install-cert-manager.sh
    
    log_info "Création des ClusterIssuers..."
    kubectl apply -f infrastructure/cert-manager-issuer.yaml
    
    log_success "cert-manager configuré"
}

configure_iptables() {
    print_step "Phase 5: Configuration iptables"
    
    log_info "Configuration de la redirection des ports 80 → 30080 et 443 → 30443"
    
    # Check if rules already exist
    if iptables -t nat -L PREROUTING -n | grep -q "30080"; then
        log_warning "Règles iptables déjà configurées"
    else
        iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 30080
        iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 30443
        
        # Save rules
        if command -v netfilter-persistent &> /dev/null; then
            netfilter-persistent save
        else
            log_warning "netfilter-persistent non installé, les règles ne seront pas persistantes"
            log_info "Installez avec: apt-get install iptables-persistent"
        fi
        
        log_success "Règles iptables configurées"
    fi
}

deploy_traefik() {
    print_step "Phase 6: Déploiement Traefik"
    
    cd "$(dirname "$0")"
    kubectl apply -f infrastructure/traefik.yaml
    
    log_info "Attente du démarrage de Traefik (30s)..."
    sleep 30
    
    kubectl wait --for=condition=available --timeout=120s deployment/traefik -n infrastructure || true
    
    log_success "Traefik déployé"
}

deploy_databases() {
    print_step "Phase 7: Déploiement des bases de données"
    
    cd "$(dirname "$0")"
    
    log_info "Déploiement PostgreSQL..."
    kubectl apply -f infrastructure/postgres.yaml
    
    log_info "Déploiement Redis..."
    kubectl apply -f infrastructure/redis.yaml
    
    log_info "Attente du démarrage des bases de données (60s)..."
    sleep 60
    
    kubectl wait --for=condition=ready --timeout=120s pod -l app=postgres -n infrastructure || true
    kubectl wait --for=condition=ready --timeout=120s pod -l app=redis -n infrastructure || true
    
    log_success "Bases de données déployées"
}

build_and_deploy_apps() {
    print_step "Phase 8: Build et déploiement des applications"
    
    read -p "Voulez-vous builder les images Docker? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$(dirname "$0")"
        chmod +x scripts/build-images.sh
        ./scripts/build-images.sh
        
        chmod +x scripts/import-images-to-k3s.sh
        ./scripts/import-images-to-k3s.sh
    else
        log_warning "Build des images ignoré"
    fi
    
    log_info "Déploiement des applications..."
    cd "$(dirname "$0")"
    
    kubectl apply -f apps/portfolio-azrael.yaml
    kubectl apply -f apps/cv.yaml
    kubectl apply -f apps/game-2048.yaml
    kubectl apply -f apps/admin-panel.yaml
    
    log_success "Applications déployées"
}

install_monitoring() {
    print_step "Phase 9: Installation du monitoring"
    
    read -p "Voulez-vous installer le monitoring (Prometheus/Grafana/Loki)? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation du monitoring ignorée"
        return
    fi
    
    cd "$(dirname "$0")"
    
    log_info "Installation kube-prometheus-stack..."
    chmod +x scripts/install-monitoring.sh
    ./scripts/install-monitoring.sh
    
    log_info "Installation Loki..."
    chmod +x scripts/install-loki.sh
    ./scripts/install-loki.sh
    
    log_success "Monitoring installé"
}

print_summary() {
    print_step "Installation terminée ! 🎉"
    
    echo ""
    echo -e "${GREEN}Services déployés:${NC}"
    echo ""
    kubectl get pods -A | grep -v "kube-system"
    
    echo ""
    echo -e "${GREEN}Ingress configurés:${NC}"
    echo ""
    kubectl get ingress -A
    
    echo ""
    echo -e "${GREEN}Certificats SSL:${NC}"
    echo ""
    kubectl get certificates -A 2>/dev/null || echo "Aucun certificat encore émis (attendez 2-5 minutes)"
    
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}Accès aux services:${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
    echo "  📱 Portfolio:     https://nathan-ferre.fr"
    echo "  📄 CV:            https://cv.nathan-ferre.fr"
    echo "  🎮 Game 2048:     https://2048.zoom2604.dev"
    echo "  🔧 Admin Panel:   https://admin.zoom2604.dev"
    echo "  📊 Grafana:       https://grafana.zoom2604.dev"
    echo "  🚦 Traefik:       https://traefik.zoom2604.dev"
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Commandes utiles:${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    echo ""
    echo "  kubectl get pods -A              # Voir tous les pods"
    echo "  kubectl get svc -A               # Voir tous les services"
    echo "  kubectl top nodes                # Ressources du cluster"
    echo "  kubectl logs -n namespace pod    # Voir les logs"
    echo ""
    echo -e "${GREEN}Documentation:${NC}"
    echo "  - Guide de migration: MIGRATION_GUIDE.md"
    echo "  - Documentation:      README.md"
    echo "  - Récapitulatif:      ../KUBERNETES_RECAP.md"
    echo ""
}

# Main installation flow
main() {
    print_banner
    
    log_info "Installation du homelab Kubernetes K3s"
    log_info "Temps estimé: 30-60 minutes"
    echo ""
    
    read -p "Voulez-vous continuer? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Installation annulée"
        exit 0
    fi
    
    check_requirements
    install_k3s
    setup_namespaces
    create_secrets
    install_cert_manager
    configure_iptables
    deploy_traefik
    deploy_databases
    build_and_deploy_apps
    install_monitoring
    print_summary
    
    echo ""
    log_success "Installation terminée avec succès ! 🚀"
    echo ""
}

# Run main function
main "$@"
