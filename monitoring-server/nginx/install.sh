#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "${SCRIPT_DIR}/.env"

log(){ echo -e "\n[+] $*\n"; }

log "Create Basic Auth credentials for Nginx"
htpasswd -bc /etc/nginx/.htpasswd "${BASIC_AUTH_USER}" "${BASIC_AUTH_PASS}"

log "Install Nginx site config"
CONF_PATH="/etc/nginx/sites-available/monitoring"
cat > "${CONF_PATH}" <<EOF
server {
  listen 80;
  server_name ${MON_DOMAIN};

  # Global Basic Auth (protect everything)
  auth_basic "Restricted";
  auth_basic_user_file /etc/nginx/.htpasswd;

  # Health root
  location = / {
    return 200 "OK\\nNetdata: ${NETDATA_PUBLIC_PATH}/\\nKuma: ${KUMA_PUBLIC_PATH}/\\n";
    add_header Content-Type text/plain;
  }

  # Netdata (binds to localhost:19999)
  location ${NETDATA_PUBLIC_PATH}/ {
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;

    proxy_http_version 1.1;
    proxy_set_header Connection "keep-alive";

    proxy_pass http://127.0.0.1:19999/;
  }

  # Uptime Kuma (binds to localhost:\$KUMA_HOST_PORT)
  location ${KUMA_PUBLIC_PATH}/ {
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;

    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";

    proxy_pass http://127.0.0.1:${KUMA_HOST_PORT}/;
  }
}
EOF

ln -sf /etc/nginx/sites-available/monitoring /etc/nginx/sites-enabled/monitoring
rm -f /etc/nginx/sites-enabled/default || true

nginx -t
systemctl reload nginx

log "Nginx configured. HTTP ready (Certbot will enable HTTPS)."
