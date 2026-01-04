#!/bin/bash
# Quick Actions CLI - Modern & Minimal

set -e

DIM='\033[2m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_menu() {
    clear
    echo ""
    echo -e "${BOLD}infra${NC} ${DIM}quick${NC}"
    echo ""
    echo -e "  ${CYAN}1${NC}  status    ${DIM}Quick status check${NC}"
    echo -e "  ${CYAN}2${NC}  restart   ${DIM}Restart all services${NC}"
    echo -e "  ${CYAN}3${NC}  stop      ${DIM}Emergency stop${NC}"
    echo -e "  ${CYAN}4${NC}  stats     ${DIM}Docker stats live${NC}"
    echo -e "  ${CYAN}5${NC}  shell     ${DIM}Container shell${NC}"
    echo -e "  ${CYAN}6${NC}  prune     ${DIM}Docker prune all${NC}"
    echo ""
    echo -e "  ${DIM}0${NC}  ${DIM}back${NC}"
    echo ""
}

show_menu
read -p "› " choice

case $choice in
    1) exec "$SCRIPT_DIR/full-status.sh" ;;
    2) exec "$SCRIPT_DIR/quick-restart.sh" ;;
    3) exec "$SCRIPT_DIR/emergency-stop.sh" ;;
    4) exec "$SCRIPT_DIR/docker-stats-live.sh" ;;
    5) exec "$SCRIPT_DIR/container-shell.sh" ;;
    6) exec "$SCRIPT_DIR/docker-prune-all.sh" ;;
    0|q|b|back) exit 0 ;;
    *) echo -e "\n\033[0;31mInvalid option\033[0m\n"; exit 1 ;;
esac
