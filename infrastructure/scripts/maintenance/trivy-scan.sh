#!/bin/bash
#
# Trivy Vulnerability Scanner
# Scans Docker images for security vulnerabilities
#

set -e

# Configuration
REPORT_DIR="/var/log/trivy"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SEVERITY="CRITICAL,HIGH,MEDIUM"

# Create report directory
mkdir -p "$REPORT_DIR"

echo "=== Trivy Security Scan ==="
echo "Date: $(date)"
echo "Report directory: $REPORT_DIR"
echo ""

# Install Trivy if not present
if ! command -v trivy &> /dev/null; then
    echo "Installing Trivy..."
    sudo apt-get install -y wget apt-transport-https gnupg lsb-release
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update
    sudo apt-get install -y trivy
fi

# Get list of running containers
CONTAINERS=$(sudo docker ps --format "{{.Names}}")

echo "Scanning containers..."
echo ""

# Scan each container
for CONTAINER in $CONTAINERS; do
    IMAGE=$(sudo docker inspect --format='{{.Config.Image}}' "$CONTAINER")
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Container: $CONTAINER"
    echo "Image: $IMAGE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    REPORT_FILE="$REPORT_DIR/${CONTAINER}_${TIMESTAMP}.txt"
    
    # Run Trivy scan
    trivy image \
        --severity "$SEVERITY" \
        --no-progress \
        --format table \
        "$IMAGE" | tee "$REPORT_FILE"
    
    echo ""
    
    # Count vulnerabilities
    CRITICAL=$(grep -c "CRITICAL" "$REPORT_FILE" || echo "0")
    HIGH=$(grep -c "HIGH" "$REPORT_FILE" || echo "0")
    MEDIUM=$(grep -c "MEDIUM" "$REPORT_FILE" || echo "0")
    
    echo "Summary for $CONTAINER:"
    echo "  CRITICAL: $CRITICAL"
    echo "  HIGH: $HIGH"
    echo "  MEDIUM: $MEDIUM"
    echo ""
done

# Generate summary report
SUMMARY_FILE="$REPORT_DIR/summary_${TIMESTAMP}.txt"
{
    echo "=== Security Scan Summary ==="
    echo "Date: $(date)"
    echo ""
    echo "Containers scanned: $(echo "$CONTAINERS" | wc -w)"
    echo ""
    
    for CONTAINER in $CONTAINERS; do
        REPORT_FILE="$REPORT_DIR/${CONTAINER}_${TIMESTAMP}.txt"
        if [ -f "$REPORT_FILE" ]; then
            CRITICAL=$(grep -c "CRITICAL" "$REPORT_FILE" || echo "0")
            HIGH=$(grep -c "HIGH" "$REPORT_FILE" || echo "0")
            MEDIUM=$(grep -c "MEDIUM" "$REPORT_FILE" || echo "0")
            TOTAL=$((CRITICAL + HIGH + MEDIUM))
            
            echo "$CONTAINER: $TOTAL vulnerabilities (C:$CRITICAL H:$HIGH M:$MEDIUM)"
        fi
    done
    
    echo ""
    echo "Detailed reports: $REPORT_DIR/*_${TIMESTAMP}.txt"
} | tee "$SUMMARY_FILE"

# Cleanup old reports (keep 30 days)
find "$REPORT_DIR" -type f -name "*.txt" -mtime +30 -delete

echo ""
echo "Scan complete! Reports saved to $REPORT_DIR"
