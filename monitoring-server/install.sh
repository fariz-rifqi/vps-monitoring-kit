#!/usr/bin/env bash
set -euo pipefail

# CraftbyZR Monitoring Server Installer (Subdomain mode)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

log(){ echo -e "\n[+] $*\n"; }
die(){ echo -e "\n[!] $*\n" >&2; exit 1; }

require_root() { [[ "${EUID}" -eq 0 ]] || die "Run as root: sudo bash ${BASH_SOURCE[0]}"; }

load_env() {
  [[ -f "${ENV_FILE}" ]] || die ".env not found. Do:\n  cp .env.example .env\n  nano .env"
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a

  : "${KUMA_DOMAIN:?Missing KUMA_DOMAIN}"
  : "${NETDATA_DOMAIN:?Missing NETDATA_DOMAIN}"
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

  log "6) Configure Nginx (two subdomains) + Basic Auth"
  bash "${SCRIPT_DIR}/nginx/install.sh"

  log "7) Enable HTTPS via Certbot (both subdomains)"
  bash "${SCRIPT_DIR}/certbot/install.sh"

  log "Done ✅"
  echo "----------------------------------------------"
  echo "Uptime Kuma : https://${KUMA_DOMAIN}/"
  echo "Netdata     : https://${NETDATA_DOMAIN}/"
  echo "----------------------------------------------"
  echo "Notes:"
  echo "1) Ensure both DNS A records point to this VPS IP (DNS only while issuing SSL):"
  echo "   - ${KUMA_DOMAIN}"
  echo "   - ${NETDATA_DOMAIN}"
}

main "$@"
