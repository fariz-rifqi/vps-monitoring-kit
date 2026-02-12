#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "${SCRIPT_DIR}/.env"

log(){ echo -e "\n[+] $*\n"; }

log "Install Certbot + Nginx plugin"
apt-get install -y certbot python3-certbot-nginx

log "Request/renew HTTPS certificate for ${MON_DOMAIN}"
# Non-interactive; if cert exists, certbot will renew/keep.
# If you want email registration prompts, run manually: certbot --nginx -d ${MON_DOMAIN}
if certbot certificates 2>/dev/null | grep -q "${MON_DOMAIN}"; then
  log "Certificate already exists. Running renewal."
  certbot renew --quiet
else
  log "Issuing new certificate. Make sure DNS A record points to this VPS and ports 80/443 are open."
  certbot --nginx -d "${MON_DOMAIN}" --non-interactive --agree-tos -m "admin@${MON_DOMAIN#*.}" --redirect
fi

systemctl reload nginx
