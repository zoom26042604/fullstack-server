#!/bin/bash
# Informations complètes du système
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}     📊 INFORMATIONS SYSTÈME${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# OS Info
echo -e "${GREEN}🖥️  Système d'exploitation${NC}"
echo "  OS: $(lsb_release -d | cut -f2)"
echo "  Kernel: $(uname -r)"
echo "  Uptime: $(uptime -p)"
echo ""

# CPU
echo -e "${GREEN}⚙️  Processeur${NC}"
echo "  Modèle: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
echo "  Cores: $(nproc) cores"
echo "  Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')% utilisé"
echo ""

# RAM
echo -e "${GREEN}💾 Mémoire${NC}"
free -h | awk '/^Mem:/ {printf "  Total: %s\n  Utilisé: %s (%.1f%%)\n  Libre: %s\n", $2, $3, ($3/$2)*100, $4}'
echo ""

# Disk
echo -e "${GREEN}💿 Disques${NC}"
df -h | grep -E '^/dev/' | awk '{printf "  %s: %s utilisé sur %s (%.0f%%)\n", $1, $3, $2, ($3/$2)*100}'
echo ""

# Network
echo -e "${GREEN}🌐 Réseau${NC}"
echo "  Hostname: $(hostname)"
echo "  IP Publique: $(curl -s ifconfig.me 2>/dev/null || echo 'N/A')"
echo "  IP Locale: $(hostname -I | awk '{print $1}')"
echo ""

# Docker
echo -e "${GREEN}🐳 Docker${NC}"
if command -v docker &> /dev/null; then
    echo "  Version: $(sudo docker --version | cut -d' ' -f3 | tr -d ',')"
    echo "  Conteneurs actifs: $(sudo docker ps -q 2>/dev/null | wc -l)"
    echo "  Images: $(sudo docker images -q 2>/dev/null | wc -l)"
else
    echo "  Docker non installé"
fi
echo ""

# Uptime & Load
echo -e "${GREEN}⏱️  Uptime & Load${NC}"
uptime
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
