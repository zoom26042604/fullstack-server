#!/bin/bash
# Statistiques système
echo "📊 Statistiques Système & Docker"
echo ""
echo "=== SYSTÈME ==="
echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%"
echo "RAM: $(free | grep Mem | awk '{printf "%.1f%%", ($3/$2)*100}')"
echo "Disk: $(df -h / | awk 'NR==2 {print $5}')"
echo ""
echo "=== DOCKER ==="
sudo docker stats --no-stream
