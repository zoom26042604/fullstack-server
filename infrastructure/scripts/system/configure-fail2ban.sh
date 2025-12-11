#!/bin/bash
#
# Configure fail2ban for SSH protection
# This script sets up fail2ban to protect against brute force attacks
#

set -e

echo "Configuring fail2ban..."

# Create local jail configuration
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
# Ban hosts for 1 hour (3600 seconds)
bantime = 3600

# A host is banned if it has generated "maxretry" during the last "findtime"
findtime = 600

# "maxretry" is the number of failures before a host get banned
maxretry = 5

# Email notifications (disabled by default)
destemail = admin@zoom2604.dev
sendername = Fail2Ban
action = %(action_)s

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF

# Restart fail2ban
systemctl restart fail2ban
systemctl enable fail2ban

# Show status
fail2ban-client status

echo "fail2ban configured successfully!"
echo "SSH protection enabled with 3 max retries"
