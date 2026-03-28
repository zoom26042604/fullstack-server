#!/bin/bash
# Health check for all services

set -e

echo "=== Infrastructure Health Check ==="
echo ""

FAILED=0

# Check K3s
echo "[K3s]"
if systemctl is-active --quiet k3s; then
    echo "  Status: OK"
else
    echo "  Status: FAILED"
    FAILED=$((FAILED + 1))
fi

# Check disk space
echo ""
echo "[Disk Space]"
DISK_USAGE=$(df -h / | grep -v Filesystem | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    echo "  Usage: ${DISK_USAGE}% - OK"
else
    echo "  Usage: ${DISK_USAGE}% - WARNING"
    FAILED=$((FAILED + 1))
fi

# Check pods
echo ""
echo "[Pods]"
FAILING_PODS=$(kubectl get pods -A | grep -v "Running\|Completed" | grep -v "NAMESPACE" | wc -l)
if [ "$FAILING_PODS" -eq 0 ]; then
    echo "  All pods running: OK"
else
    echo "  Failing pods: $FAILING_PODS - FAILED"
    kubectl get pods -A | grep -v "Running\|Completed" | grep -v "NAMESPACE"
    FAILED=$((FAILED + 1))
fi

# Check services
echo ""
echo "[Services]"
for url in "https://nathan-ferre.fr" "https://cv.nathan-ferre.fr" "https://2048.zoom2604.dev" "https://grafana.zoom2604.dev" "https://uptime.zoom2604.dev"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" -k "$url" --max-time 5 || echo "000")
    if [ "$STATUS" = "200" ] || [ "$STATUS" = "302" ] || [ "$STATUS" = "401" ]; then
        echo "  $url: OK ($STATUS)"
    else
        echo "  $url: FAILED ($STATUS)"
        FAILED=$((FAILED + 1))
    fi
done

echo ""
if [ "$FAILED" -eq 0 ]; then
    echo "Health check: PASSED"
    exit 0
else
    echo "Health check: FAILED ($FAILED issues)"
    exit 1
fi
