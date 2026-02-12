#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "${SCRIPT_DIR}/.env"

log(){ echo -e "\n[+] $*\n"; }

log "Deploy Uptime Kuma via Docker Compose"
mkdir -p /opt/uptime-kuma
cp -f "${SCRIPT_DIR}/uptime-kuma/compose.yml" /opt/uptime-kuma/compose.yml

# Export env for compose variable substitution
export KUMA_HOST_PORT="${KUMA_HOST_PORT:-3001}"

docker compose -f /opt/uptime-kuma/compose.yml up -d
