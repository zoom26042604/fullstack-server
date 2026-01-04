#!/bin/bash
# Maintenance CLI - Modern & Minimal

set -e

DIM='\033[2m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_menu() {
    clear
    echo ""
    echo -e "${BOLD}infra${NC} ${DIM}maintenance${NC}"
    echo ""
    echo -e "  ${CYAN}1${NC}  deploy     ${DIM}Deploy infrastructure${NC}"
    echo -e "  ${CYAN}2${NC}  backup     ${DIM}Full backup${NC}"
    echo -e "  ${CYAN}3${NC}  restore    ${DIM}Restore from backup${NC}"
    echo -e "  ${CYAN}4${NC}  health     ${DIM}Health check${NC}"
    echo -e "  ${CYAN}5${NC}  cleanup    ${DIM}Docker cleanup${NC}"
    echo -e "  ${CYAN}6${NC}  update     ${DIM}Update containers${NC}"
    echo -e "  ${CYAN}7${NC}  logs       ${DIM}View logs${NC}"
    echo -e "  ${CYAN}8${NC}  trivy      ${DIM}Security scan${NC}"
    echo ""
    echo -e "  ${DIM}0${NC}  ${DIM}back${NC}"
    echo ""
}

show_menu
read -p "› " choice

case $choice in
    1) exec "$SCRIPT_DIR/deploy-infrastructure.sh" ;;
    2) exec "$SCRIPT_DIR/backup.sh" ;;
    3) exec "$SCRIPT_DIR/restore.sh" ;;
    4) exec "$SCRIPT_DIR/health-check.sh" ;;
    5) exec "$SCRIPT_DIR/docker-cleanup.sh" ;;
    6) exec "$SCRIPT_DIR/update.sh" ;;
    7) exec "$SCRIPT_DIR/logs.sh" ;;
    8) exec "$SCRIPT_DIR/trivy-scan.sh" ;;
    0|q|b|back) exit 0 ;;
    *) echo -e "\n\033[0;31mInvalid option\033[0m\n"; exit 1 ;;
esac
