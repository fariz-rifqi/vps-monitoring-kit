#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "${SCRIPT_DIR}/.env"

htpasswd -bc /etc/nginx/.htpasswd "${BASIC_AUTH_USER}" "${BASIC_AUTH_PASS}"

cat > /etc/nginx/sites-available/kuma <<EOF
server {
  listen 80;
  server_name ${KUMA_DOMAIN};

  auth_basic "Restricted";
  auth_basic_user_file /etc/nginx/.htpasswd;

  location / {
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

cat > /etc/nginx/sites-available/netdata <<EOF
server {
  listen 80;
  server_name ${NETDATA_DOMAIN};

  auth_basic "Restricted";
  auth_basic_user_file /etc/nginx/.htpasswd;

  location / {
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;

    proxy_http_version 1.1;
    proxy_set_header Connection "keep-alive";

    proxy_pass http://127.0.0.1:19999/;
  }
}
EOF

ln -sf /etc/nginx/sites-available/kuma /etc/nginx/sites-enabled/kuma
ln -sf /etc/nginx/sites-available/netdata /etc/nginx/sites-enabled/netdata

rm -f /etc/nginx/sites-enabled/monitoring || true
rm -f /etc/nginx/sites-available/monitoring || true
rm -f /etc/nginx/sites-enabled/default || true

nginx -t
systemctl reload nginx
