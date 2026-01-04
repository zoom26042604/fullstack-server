#!/bin/bash
# Deploy CLI - Modern & Minimal

set -e

DIM='\033[2m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_menu() {
    clear
    echo ""
    echo -e "${BOLD}infra${NC} ${DIM}deploy${NC}"
    echo ""
    echo -e "  ${CYAN}1${NC}  nextjs   ${DIM}Next.js with SSR${NC}"
    echo -e "  ${CYAN}2${NC}  react    ${DIM}React/Vite SPA${NC}"
    echo -e "  ${CYAN}3${NC}  node     ${DIM}Node.js API${NC}"
    echo -e "  ${CYAN}4${NC}  static   ${DIM}Static HTML/CSS/JS${NC}"
    echo ""
    echo -e "  ${DIM}0${NC}  ${DIM}back${NC}"
    echo ""
}

show_menu
read -p "› " choice

case $choice in
    1) exec "$SCRIPT_DIR/deploy-nextjs.sh" ;;
    2) exec "$SCRIPT_DIR/deploy-react.sh" ;;
    3) exec "$SCRIPT_DIR/deploy-node.sh" ;;
    4) exec "$SCRIPT_DIR/deploy-static.sh" ;;
    0|q|b|back) exit 0 ;;
    *) echo -e "\n\033[0;31mInvalid option\033[0m\n"; exit 1 ;;
esac
