#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# CraftbyZR Client VPS Installer (Netdata Child)
# Target: Ubuntu/Debian
# Installs:
# - Netdata agent (child) and streams metrics to Netdata Parent
# - Optional: basic security hardening (UFW + fail2ban)
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

  : "${PARENT_IP:?Missing PARENT_IP}"
  : "${STREAM_API_KEY:?Missing STREAM_API_KEY}"
  : "${PARENT_PORT:=19999}"
}

main() {
  require_root
  load_env

  log "1) Base packages"
  apt-get update -y
  apt-get install -y curl ca-certificates ufw fail2ban

  log "2) Optional security (UFW + fail2ban)"
  bash "${SCRIPT_DIR}/security/ufw.sh" || true
  bash "${SCRIPT_DIR}/security/fail2ban.sh" || true

  log "3) Install and configure Netdata child"
  bash "${SCRIPT_DIR}/netdata/child-install.sh"

  log "Done ✅"
  echo "----------------------------------------------"
  echo "This VPS is now streaming Netdata metrics to: ${PARENT_IP}:${PARENT_PORT}"
  echo "Check dashboard: https://monitor.craftbyzr.my.id/netdata/"
  echo "----------------------------------------------"
}

main "$@"
