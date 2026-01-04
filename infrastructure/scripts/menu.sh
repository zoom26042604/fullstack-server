#!/bin/bash
# Infrastructure CLI - Modern & Minimal

set -e

# Colors (minimal)
DIM='\033[2m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_menu() {
    clear
    echo ""
    echo -e "${BOLD}infra${NC} ${DIM}v1.0.0${NC}"
    echo ""
    echo -e "  ${CYAN}1${NC}  deploy      ${DIM}Deploy new application${NC}"
    echo -e "  ${CYAN}2${NC}  apps        ${DIM}Manage applications${NC}"
    echo -e "  ${CYAN}3${NC}  maintenance ${DIM}Backup, restore, update${NC}"
    echo -e "  ${CYAN}4${NC}  system      ${DIM}System info & monitoring${NC}"
    echo -e "  ${CYAN}5${NC}  database    ${DIM}PostgreSQL & Redis${NC}"
    echo -e "  ${CYAN}6${NC}  quick       ${DIM}Quick actions${NC}"
    echo ""
    echo -e "  ${DIM}0${NC}  ${DIM}exit${NC}"
    echo ""
}

show_menu
read -p "› " choice

case $choice in
    1) exec "$SCRIPT_DIR/deploy/deploy.sh" ;;
    2) exec "$SCRIPT_DIR/apps/app-manager.sh" ;;
    3) exec "$SCRIPT_DIR/maintenance/menu.sh" ;;
    4) exec "$SCRIPT_DIR/system/menu.sh" ;;
    5) exec "$SCRIPT_DIR/database/menu.sh" ;;
    6) exec "$SCRIPT_DIR/quick/menu.sh" ;;
    0|q|quit|exit) echo -e "\n${DIM}Goodbye${NC}\n"; exit 0 ;;
    *) echo -e "\n${RED}Invalid option${NC}\n"; exit 1 ;;
esac
