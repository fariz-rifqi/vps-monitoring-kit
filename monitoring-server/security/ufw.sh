#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "${SCRIPT_DIR}/.env"
ufw default deny incoming
ufw default allow outgoing
ufw allow 80/tcp
ufw allow 443/tcp
if [[ -n "${ALLOW_SSH_IP:-}" ]]; then
  ufw delete allow 22/tcp >/dev/null 2>&1 || true
  ufw allow from "${ALLOW_SSH_IP}" to any port 22 proto tcp
else
  ufw allow 22/tcp
fi
ufw --force enable
