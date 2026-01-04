#!/bin/bash
# System CLI - Modern & Minimal

set -e

DIM='\033[2m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_menu() {
    clear
    echo ""
    echo -e "${BOLD}infra${NC} ${DIM}system${NC}"
    echo ""
    echo -e "  ${CYAN}1${NC}  info      ${DIM}Full system info${NC}"
    echo -e "  ${CYAN}2${NC}  disk      ${DIM}Disk usage analysis${NC}"
    echo -e "  ${CYAN}3${NC}  live      ${DIM}Live monitoring${NC}"
    echo -e "  ${CYAN}4${NC}  ssl       ${DIM}SSL certificates check${NC}"
    echo -e "  ${CYAN}5${NC}  firewall  ${DIM}Firewall status${NC}"
    echo -e "  ${CYAN}6${NC}  ports     ${DIM}Open ports${NC}"
    echo ""
    echo -e "  ${DIM}0${NC}  ${DIM}back${NC}"
    echo ""
}

show_menu
read -p "› " choice

case $choice in
    1) exec "$SCRIPT_DIR/system-info.sh" ;;
    2) exec "$SCRIPT_DIR/disk-usage.sh" ;;
    3) exec "$SCRIPT_DIR/monitor-live.sh" ;;
    4) exec "$SCRIPT_DIR/ssl-check.sh" ;;
    5) exec "$SCRIPT_DIR/firewall-status.sh" ;;
    6) exec "$SCRIPT_DIR/open-ports.sh" ;;
    0|q|b|back) exit 0 ;;
    *) echo -e "\n\033[0;31mInvalid option\033[0m\n"; exit 1 ;;
esac
