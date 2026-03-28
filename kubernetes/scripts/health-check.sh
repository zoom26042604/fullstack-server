#!/bin/bash

# Homelab Health Check Script
# Vérifie l'état de tous les services Kubernetes

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}       HOMELAB KUBERNETES - HEALTH CHECK          ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

check_service() {
    local namespace=$1
    local label=$2
    local name=$3
    
    local status=$(kubectl get pods -n $namespace -l $label -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
    local ready=$(kubectl get pods -n $namespace -l $label -o jsonpath='{.items[0].status.containerStatuses[0].ready}' 2>/dev/null)
    
    if [[ "$status" == "Running" ]] && [[ "$ready" == "true" ]]; then
        echo -e "  ${GREEN}✓${NC} $name"
        return 0
    elif [[ "$status" == "Running" ]]; then
        echo -e "  ${YELLOW}⚠${NC} $name (running but not ready)"
        return 1
    else
        echo -e "  ${RED}✗${NC} $name (status: $status)"
        return 1
    fi
}

echo -e "${BLUE}Infrastructure Services:${NC}"
check_service "infrastructure" "app=postgres" "PostgreSQL"
check_service "infrastructure" "app=redis" "Redis"
check_service "infrastructure" "app=traefik" "Traefik"
echo ""

echo -e "${BLUE}Applications Web:${NC}"
check_service "infrastructure" "app=homer" "Homer Dashboard (zoom2604.dev)"
check_service "nathan-ferre" "app=portfolio-azrael" "Portfolio (nathan-ferre.fr)"
check_service "nathan-ferre" "app=cv" "CV (cv.nathan-ferre.fr)"
check_service "zoom2604" "app=game-2048" "Game 2048 (2048.zoom2604.dev)"
echo ""

echo -e "${BLUE}Monitoring & Alerting:${NC}"
check_service "monitoring" "app.kubernetes.io/name=grafana" "Grafana (grafana.zoom2604.dev)"
check_service "monitoring" "app=uptime-kuma" "Uptime Kuma (uptime.zoom2604.dev)"
check_service "monitoring" "app.kubernetes.io/name=prometheus" "Prometheus"
echo ""

echo -e "${BLUE}Security:${NC}"
check_service "cert-manager" "app=cert-manager" "cert-manager"
check_service "cert-manager" "app=webhook" "cert-manager-webhook" || true
echo ""

echo -e "${BLUE}Certificats SSL:${NC}"
for cert in $(kubectl get certificates -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}'); do
    namespace=$(echo $cert | cut -d'/' -f1)
    name=$(echo $cert | cut -d'/' -f2)
    ready=$(kubectl get certificate -n $namespace $name -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
    
    if [[ "$ready" == "True" ]]; then
        echo -e "  ${GREEN}✓${NC} $namespace/$name"
    else
        echo -e "  ${YELLOW}⏳${NC} $namespace/$name (en cours d'émission)"
    fi
done
echo ""

echo -e "${BLUE}Ingress Routes:${NC}"
kubectl get ingress -A --no-headers | while read namespace name class hosts address ports age; do
    echo -e "  ${GREEN}→${NC} $hosts"
done
echo ""

echo -e "${BLUE}Ressources Système:${NC}"
total_pods=$(kubectl get pods -A --no-headers | wc -l)
running_pods=$(kubectl get pods -A --field-selector=status.phase=Running --no-headers | wc -l)
echo -e "  Pods: ${GREEN}$running_pods${NC}/$total_pods running"

total_pvc=$(kubectl get pvc -A --no-headers | wc -l)
bound_pvc=$(kubectl get pvc -A --field-selector=status.phase=Bound --no-headers | wc -l)
echo -e "  PVC: ${GREEN}$bound_pvc${NC}/$total_pvc bound"
echo ""

echo -e "${BLUE}Accès Services:${NC}"
echo -e "  HTTP:  ${YELLOW}http://localhost:30080${NC} → Traefik"
echo -e "  HTTPS: ${YELLOW}https://localhost:30443${NC} → Traefik"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [[ $running_pods -eq $total_pods ]]; then
    echo -e "${GREEN}✓ Tous les services sont opérationnels !${NC}"
else
    echo -e "${YELLOW}⚠ Certains services nécessitent une attention${NC}"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
