#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "${SCRIPT_DIR}/.env"

apt-get install -y certbot python3-certbot-nginx

EMAIL="admin@${KUMA_DOMAIN#*.}"
certbot --nginx -d "${KUMA_DOMAIN}" -d "${NETDATA_DOMAIN}" \
  --non-interactive --agree-tos -m "${EMAIL}" --redirect || true

systemctl reload nginx
