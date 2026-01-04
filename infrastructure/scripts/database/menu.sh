#!/bin/bash
# Database CLI - Modern & Minimal

set -e

DIM='\033[2m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_menu() {
    clear
    echo ""
    echo -e "${BOLD}infra${NC} ${DIM}database${NC}"
    echo ""
    echo -e "  ${CYAN}1${NC}  psql     ${DIM}PostgreSQL shell${NC}"
    echo -e "  ${CYAN}2${NC}  redis    ${DIM}Redis CLI${NC}"
    echo -e "  ${CYAN}3${NC}  backup   ${DIM}Backup PostgreSQL now${NC}"
    echo -e "  ${CYAN}4${NC}  query    ${DIM}Execute SQL query${NC}"
    echo ""
    echo -e "  ${DIM}0${NC}  ${DIM}back${NC}"
    echo ""
}

show_menu
read -p "› " choice

case $choice in
    1) exec "$SCRIPT_DIR/db-shell.sh" ;;
    2) exec "$SCRIPT_DIR/redis-cli.sh" ;;
    3) exec "$SCRIPT_DIR/db-backup-now.sh" ;;
    4) exec "$SCRIPT_DIR/db-query.sh" ;;
    0|q|b|back) exit 0 ;;
    *) echo -e "\n\033[0;31mInvalid option\033[0m\n"; exit 1 ;;
esac
