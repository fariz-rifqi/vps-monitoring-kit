#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "${SCRIPT_DIR}/.env"

log(){ echo -e "\n[+] $*\n"; }

log "Configure UFW (client VPS)"
ufw default deny incoming
ufw default allow outgoing

# Allow SSH
if [[ -n "${ALLOW_SSH_IP:-}" ]]; then
  log "Restrict SSH to ${ALLOW_SSH_IP}"
  ufw delete allow 22/tcp >/dev/null 2>&1 || true
  ufw allow from "${ALLOW_SSH_IP}" to any port 22 proto tcp
else
  ufw allow 22/tcp
fi

# Allow HTTP/HTTPS (most web servers need this)
ufw allow 80/tcp
ufw allow 443/tcp

ufw --force enable
