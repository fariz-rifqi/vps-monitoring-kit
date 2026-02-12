#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# CraftbyZR Monitoring Server Installer
# Target: Ubuntu 22.04 LTS / 24.04 LTS
# Installs:
# - Netdata (Parent) + Telegram alerts (optional)
# - Uptime Kuma (Docker)
# - Nginx reverse proxy + Basic Auth
# - UFW + Fail2ban
# - HTTPS via Certbot (Let's Encrypt)
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

log(){ echo -e "\n[+] $*\n"; }
die(){ echo -e "\n[!] $*\n" >&2; exit 1; }

require_root() {
  [[ "${EUID}" -eq 0 ]] || die "Run as root: sudo bash ${BASH_SOURCE[0]}"
}

load_env() {
  if [[ ! -f "${ENV_FILE}" ]]; then
    die ".env not found. Copy and edit:\n  cp .env.example .env\n  nano .env"
  fi

  # shellcheck disable=SC1090
  set -a
  source "${ENV_FILE}"
  set +a

  : "${MON_DOMAIN:?Missing MON_DOMAIN}"
  : "${NETDATA_PUBLIC_PATH:=/netdata}"
  : "${KUMA_PUBLIC_PATH:=/kuma}"
  : "${BASIC_AUTH_USER:?Missing BASIC_AUTH_USER}"
  : "${BASIC_AUTH_PASS:?Missing BASIC_AUTH_PASS}"
  : "${KUMA_HOST_PORT:=3001}"
}

main() {
  require_root
  load_env

  log "1) Base packages + updates"
  apt-get update -y
  apt-get upgrade -y
  apt-get install -y curl wget git ca-certificates gnupg lsb-release \
    ufw fail2ban nginx apache2-utils

  log "2) Security hardening (UFW + Fail2ban)"
  bash "${SCRIPT_DIR}/security/ufw.sh"
  bash "${SCRIPT_DIR}/security/fail2ban.sh"

  log "3) Install Docker + Compose plugin"
  bash "${SCRIPT_DIR}/uptime-kuma/install-docker.sh"

  log "4) Install Netdata Parent + streaming receiver"
  bash "${SCRIPT_DIR}/netdata/parent-install.sh"

  log "5) Deploy Uptime Kuma (Docker Compose)"
  bash "${SCRIPT_DIR}/uptime-kuma/install.sh"

  log "6) Configure Nginx reverse proxy + Basic Auth"
  bash "${SCRIPT_DIR}/nginx/install.sh"

  log "7) Enable HTTPS via Certbot"
  bash "${SCRIPT_DIR}/certbot/install.sh"

  log "Done ✅"
  echo "----------------------------------------------"
  echo "Domain: https://${MON_DOMAIN}"
  echo "Netdata: https://${MON_DOMAIN}${NETDATA_PUBLIC_PATH}/"
  echo "Kuma:    https://${MON_DOMAIN}${KUMA_PUBLIC_PATH}/"
  echo "----------------------------------------------"
  echo "Next steps:"
  echo "1) Ensure DNS A record: monitor -> VPS IP"
  echo "2) Open Kuma and set Telegram notifications"
  echo "3) Run Netdata child installer on each VPS client"
}

main "$@"
