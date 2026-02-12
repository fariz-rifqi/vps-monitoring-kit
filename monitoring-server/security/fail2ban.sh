#!/usr/bin/env bash
set -euo pipefail

log(){ echo -e "\n[+] $*\n"; }

log "Enable fail2ban"
systemctl enable --now fail2ban

# Optional basic jail config (ssh)
JAIL_LOCAL="/etc/fail2ban/jail.d/sshd.local"
cat > "${JAIL_LOCAL}" <<EOF
[sshd]
enabled = true
maxretry = 5
findtime = 10m
bantime = 1h
EOF

systemctl restart fail2ban
